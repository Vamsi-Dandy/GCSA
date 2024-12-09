#!/bin/bash
set -e

# check active and quit
if [[ "true" != "${AWS_ACTIVE}" ]]; then
    echo "AWS deployment is not enabled."
    exit 0
fi

# read creds from vault
export AWS_DEFAULT_REGION=$(vault kv get -field=region kv/aws/iam/devsecops) || echo ""
export AWS_ACCESS_KEY_ID=$(vault kv get -field=access_key_id kv/aws/iam/devsecops) || echo ""
export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secret_access_key kv/aws/iam/devsecops) || echo ""

# smoke test creds
echo -n "DEVSECOPS IAM USER - "
aws iam get-user | jq -r '.User.UserName' | grep -qE 'devsecops'
echo "OK"

# read vars from vault
IMAGE_NAME=$(vault kv get -field=image_name kv/aws/ecr/api) || echo ""
EKS_CLUSTER_NAME=$(vault kv get -field=eks_name kv/aws/deployment/metadata) || echo ""
EKS_CLUSTER_VPC_CIDR_BLOCK=$(vault kv get -field=dm_cluster_vpc_cidr_block kv/aws/deployment/metadata) || echo ""
DM_INTERNAL_R53_PHZ_ID=$(vault kv get -field=dm_internal_route53_phz_id kv/aws/deployment/metadata) || echo ""

# sign into the EKS cluster
aws eks update-kubeconfig --name "${EKS_CLUSTER_NAME}"

# create dm namespace
if [[ "" == "$(kubectl get ns --output=json | jq -r '.items[] | select(.metadata.name=="dm").metadata.uid')" ]]; then
    echo "Creating dm namespace..."
    kubectl create ns dm
fi

# deploy api service
sed -i -e "s#{IMAGE_NAME}#${IMAGE_NAME}#g" ./manifests/aws/deployment.yml
sed -i -e "s#{VPC_CIDR}#${EKS_CLUSTER_VPC_CIDR_BLOCK}#g" ./manifests/aws/service.yml

kubectl apply -f ./manifests/aws/deployment.yml
kubectl apply -f ./manifests/aws/service.yml

# Wait for the alb controller to create the load balancer (usually takes < 30 seconds)
MAX_WAIT=$((SECONDS + 300)) #5 min
LOADBALANCER_COUNT=$(kubectl get ingress -o json -n dm | jq '.items[] | select(.metadata.name=="api-alb").status.loadBalancer | length')
while [[ "0" == $LOADBALANCER_COUNT ]]; do
    echo "Waiting for API load balancer to provision..."
    sleep 30

    if [ $MAX_WAIT -lt $SECONDS ]; then
        echo "API load balancer failed to provision. Run the following command to check the aws-load-balancer-controller logs for failures."
        echo "kubectl logs -n kube-system --tail -1 -l app.kubernetes.io/name=aws-load-balancer-controller | grep 'api-alb'"
        exit 1
    fi

    LOADBALANCER_COUNT=$(kubectl get ingress -o json -n dm | jq '.items[] | select(.metadata.name=="api-alb").status.loadBalancer | length')
done

# set PHZ alias record for api.aws.dm.paper
API_ALB_HOSTNAME=$(kubectl get ingress -o json -n dm | jq -r '.items[] | select(.metadata.name=="api-alb").status.loadBalancer.ingress[].hostname')
echo "Setting r53 record for ${API_ALB_HOSTNAME}..."
API_ALB_PHZ_ID=$(aws elbv2 describe-load-balancers | jq -r '.LoadBalancers[] | select(.DNSName=="'$API_ALB_HOSTNAME'").CanonicalHostedZoneId')
sed -i -e "s#{TAG}#${CI_PIPELINE_ID}#g" -e "s#{ALB_ZONE_ID}#${API_ALB_PHZ_ID}#g" -e "s#{ALB_HOSTNAME}#${API_ALB_HOSTNAME}#g" ./build/bin/r53-record-set.json
aws route53 change-resource-record-sets --hosted-zone-id "${DM_INTERNAL_R53_PHZ_ID}" --change-batch file://build/bin/r53-record-set.json
