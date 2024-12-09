#!/bin/bash
set -e

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

# deploy api service
IMAGE_NAME=$(vault kv get -field=image_name kv/az/acr/api) || echo ""
sed -i -e "s#{IMAGE_NAME}#${IMAGE_NAME}#g" ./manifests/az/deployment.yml

kubectl apply -f ./manifests/az/deployment.yml
kubectl apply -f ./manifests/az/service.yml
