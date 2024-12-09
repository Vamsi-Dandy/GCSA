#!/bin/bash
set -e

# set vars
DEPLOYMENT_FILE=$1
SERVICE_FILE=$2

# check active and quit
if [[ "true" != "${AZ_ACTIVE}" ]]; then
    echo "Azure deployment is not enabled."
    exit 0
fi

# read creds from the vault
export ARM_SUBSCRIPTION_ID=$(vault kv get -field=subscription_id kv/az/principle/devsecops) || echo ""
export ARM_TENANT_ID=$(vault kv get -field=tenant_id kv/az/principle/devsecops) || echo ""
export ARM_CLIENT_ID=$(vault kv get -field=client_id kv/az/principle/devsecops) || echo ""
export ARM_CLIENT_SECRET=$(vault kv get -field=client_secret kv/az/principle/devsecops) || echo ""
export AZURE_LOCATION=$(vault kv get -field=location kv/az/principle/devsecops) || echo ""

# smoke test creds
echo -n "SERVICE PRINCIPAL LOGIN - "
az login --service-principal -u "${ARM_CLIENT_ID}" -p "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}" | jq -r '.[].tenantId' | grep -qE '^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$'
echo "OK"

# sign in to cluster
AKS_CLUSTER_NAME=$(vault kv get -field=aks_name kv/az/deployment/metadata) || echo ""
AKS_RESOURCE_GROUP_NAME=$(vault kv get -field=aks_resource_group kv/az/deployment/metadata) || echo ""
az aks get-credentials -g "${AKS_RESOURCE_GROUP_NAME}" -n "${AKS_CLUSTER_NAME}"

# create dm namespace
if [[ "" == "$(kubectl get ns --output=json | jq -r '.items[] | select(.metadata.name=="dm").metadata.uid')" ]]; then
    echo "Creating dm namespace..."
    kubectl create ns dm
fi

# read vars from vault
IMAGE_NAME=$(vault kv get -field=image_name kv/az/acr/web) || echo ""
REDIS_NAME=$(vault kv get -field=redis_name kv/az/acr/web) || echo ""
DM_WEB_SERVICE_PRINCIPAL_CLIENT_ID=$(vault kv get -field=dm_web_service_principal_client_id kv/az/deployment/metadata) || echo ""
DM_WEB_SERVICE_PRINCIPAL_CLIENT_SECRET=$(vault kv get -field=dm_web_service_principal_client_secret kv/az/deployment/metadata) || echo ""
DM_REDIS_CLUSTER_PASSWORD=$(vault kv get -field=dm_redis_cluster_password kv/az/deployment/metadata) || echo ""

# deploy redis service
sed -i -e "s#{REDIS_PASSWORD}#${DM_REDIS_CLUSTER_PASSWORD}#g" ./manifests/redis/configmap.yml
sed -i -e "s#image: redis:7.2.0#image: ${REDIS_NAME}#g" ./manifests/redis/statefulset.yml

kubectl apply -f ./manifests/redis/service.yml
kubectl apply -f ./manifests/redis/configmap.yml
kubectl apply -f ./manifests/redis/statefulset.yml

# deploy web service
sed -i -e "s#{IMAGE_NAME}#${IMAGE_NAME}#g" \
    -e "s#{AZURE_CLIENT_ID}#${DM_WEB_SERVICE_PRINCIPAL_CLIENT_ID}#g" \
    -e "s#{AZURE_CLIENT_SECRET}#${DM_WEB_SERVICE_PRINCIPAL_CLIENT_SECRET}#g" \
    -e "s#{AZURE_TENANT_ID}#${ARM_TENANT_ID}#g" \
    ./manifests/az/${DEPLOYMENT_FILE}

kubectl apply -f ./manifests/az/${DEPLOYMENT_FILE}
kubectl apply -f ./manifests/az/${SERVICE_FILE}
