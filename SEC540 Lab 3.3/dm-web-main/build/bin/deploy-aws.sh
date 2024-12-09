#!/bin/bash
set -e

# set vars
DEPLOYMENT_FILE=$1
SERVICE_FILE=$2

# check active and quit
if [[ "true" != "${AWS_ACTIVE}" ]]; then
    echo "AWS deployment is not enabled."
    exit 0
fi

# read creds from the vault
export AWS_DEFAULT_REGION=$(vault kv get -field=region kv/aws/iam/devsecops) || echo ""
export AWS_ACCESS_KEY_ID=$(vault kv get -field=access_key_id kv/aws/iam/devsecops) || echo ""
export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secret_access_key kv/aws/iam/devsecops) || echo ""

# smoke test creds
echo -n "DEVSECOPS IAM USER - "
aws iam get-user | jq -r '.User.UserName' | grep -qE 'devsecops'
echo "OK"

# sign in to cluster
EKS_CLUSTER_NAME=$(vault kv get -field=eks_name kv/aws/deployment/metadata) || echo ""

aws eks update-kubeconfig --name "${EKS_CLUSTER_NAME}"

# create dm namespace
if [[ "" == "$(kubectl get ns --output=json | jq -r '.items[] | select(.metadata.name=="dm").metadata.uid')" ]]; then
    echo "Creating dm namespace..."
    kubectl create ns dm
fi

# read vars from vault
ADMIN_IP="$(curl -s https://checkip.amazonaws.com)/32"
IMAGE_NAME=$(vault kv get -field=image_name kv/aws/ecr/web) || echo ""
REDIS_NAME=$(vault kv get -field=redis_name kv/aws/ecr/web) || echo ""
DM_ACM_CERTIFICATE_ARN=$(vault kv get -field=acm_certificate_arn kv/aws/deployment/metadata) || echo ""
DM_INTERNAL_R53_PHZ_ID=$(vault kv get -field=dm_internal_route53_phz_id kv/aws/deployment/metadata) || echo ""
DM_REDIS_CLUSTER_PASSWORD=$(vault kv get -field=dm_redis_cluster_password kv/aws/deployment/metadata) || echo ""
DM_WEB_POD_ROLE_ARN=$(vault kv get -field=dm_web_pod_role_arn kv/aws/deployment/metadata) || echo ""

# deploy redis service
sed -i -e "s#{REDIS_PASSWORD}#${DM_REDIS_CLUSTER_PASSWORD}#g" ./manifests/redis/configmap.yml
sed -i -e "s#image: redis:7.2.0#image: ${REDIS_NAME}#g" ./manifests/redis/statefulset.yml

kubectl apply -f ./manifests/redis/service.yml
kubectl apply -f ./manifests/redis/configmap.yml
kubectl apply -f ./manifests/redis/statefulset.yml

# deploy web service
sed -i -e "s#{IMAGE_NAME}#${IMAGE_NAME}#g" -e "s#{DM_WEB_ROLE_ARN}#${DM_WEB_POD_ROLE_ARN}#g" "./manifests/aws/${DEPLOYMENT_FILE}"
sed -i -e "s#{ACM_CERTIFICATE_ARN}#${DM_ACM_CERTIFICATE_ARN}#g" ./manifests/aws/ingress.yml
sed -i -e "s#{ADMIN_IP}#${ADMIN_IP}#g" ./manifests/aws/ingress.yml

kubectl apply -f "./manifests/aws/${DEPLOYMENT_FILE}"
kubectl apply -f "./manifests/aws/${SERVICE_FILE}"
kubectl apply -f ./manifests/aws/ingress.yml

# Wait for the alb controller to create the load balancer (usually takes < 30 seconds)
MAX_WAIT=$((SECONDS + 300)) #5 min
LOADBALANCER_COUNT=$(kubectl get ingress -o json -n dm | jq '.items[] | select(.metadata.name=="web-alb").status.loadBalancer | length')
while [[ "0" == "$LOADBALANCER_COUNT" ]]; do
    echo "Waiting for Web load balancer to provision..."
    sleep 30

    if [ $MAX_WAIT -lt $SECONDS ]; then
        echo "Web load balancer failed to provision. Run the following command to check the aws-load-balancer-controller logs for failures."
        echo "kubectl logs -n kube-system --tail -1 -l app.kubernetes.io/name=aws-load-balancer-controller | grep 'web-alb'"
        exit 1
    fi

    LOADBALANCER_COUNT=$(kubectl get ingress -o json -n dm | jq '.items[] | select(.metadata.name=="web-alb").status.loadBalancer | length')
done

# set external ALB
WEB_ALB_HOSTNAME=$(kubectl get ingress -o json -n dm | jq -r '.items[] | select(.metadata.name=="web-alb").status.loadBalancer.ingress[].hostname')
vault kv patch kv/aws/deployment/status dm_url="https://${WEB_ALB_HOSTNAME}"

# set PHZ alias record for www.aws.dm.paper
echo "Setting r53 record for ${WEB_ALB_HOSTNAME}..."
WEB_ALB_PHZ_ID=$(aws elbv2 describe-load-balancers | jq -r '.LoadBalancers[] | select(.DNSName=="'${WEB_ALB_HOSTNAME}'").CanonicalHostedZoneId')
sed -i -e "s#{TAG}#${CI_PIPELINE_ID}#g" -e "s#{ALB_ZONE_ID}#${WEB_ALB_PHZ_ID}#g" -e "s#{ALB_HOSTNAME}#${WEB_ALB_HOSTNAME}#g" ./build/bin/r53-record-set.json
aws route53 change-resource-record-sets --hosted-zone-id "${DM_INTERNAL_R53_PHZ_ID}" --change-batch file://build/bin/r53-record-set.json
