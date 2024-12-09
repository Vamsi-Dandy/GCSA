#!/bin/bash
set -e

# check active and quit
if [[ "true" != "${AZ_ACTIVE}" ]]; then
    echo "Azure deployment is not enabled."
    exit 0
fi

# read creds from vault
export ARM_SUBSCRIPTION_ID=$(vault kv get -field=subscription_id kv/az/principle/devsecops) || echo ""
export ARM_TENANT_ID=$(vault kv get -field=tenant_id kv/az/principle/devsecops) || echo ""
export ARM_CLIENT_ID=$(vault kv get -field=client_id kv/az/principle/devsecops) || echo ""
export ARM_CLIENT_SECRET=$(vault kv get -field=client_secret kv/az/principle/devsecops) || echo ""
export AZURE_LOCATION=$(vault kv get -field=location kv/az/principle/devsecops) || echo ""

# smoke test creds
echo -n "SERVICE PRINCIPAL LOGIN - "
az login --service-principal -u "${ARM_CLIENT_ID}" -p "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}" | jq -r '.[].tenantId' | grep -qE '^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$'
echo "OK"

# read environment vars
DM_KEY_VAULT_NAME=$(vault kv get -field=dm_key_vault_name kv/az/deployment/metadata) || echo ""
DM_STORAGE_ACCOUNT_NAME=$(vault kv get -field=dm_storage_account_name kv/az/deployment/metadata) || echo ""
DM_ACR_NAME=$(vault kv get -field=dm_acr_name kv/az/deployment/metadata) || echo ""
DM_ACR_LOGIN_SERVER=$(vault kv get -field=dm_acr_login_server kv/az/deployment/metadata) || echo ""
DM_REDIS_CLUSTER_PASSWORD=$(vault kv get -field=dm_redis_cluster_password kv/az/deployment/metadata) || echo ""
DM_REDIS_CLUSTER_HOST="redis-ss-0.redis-service.dm"
DM_API_ENDPOINT="api.az.dm.paper"

# configure image registry image auth
DOCKER_USERNAME="00000000-0000-0000-0000-000000000000"
DOCKER_ACCESS_TOKEN=$(az acr login --name "${DM_ACR_NAME}" --expose-token --only-show-errors | jq -r '.accessToken')
IMAGE_NAME="${DM_ACR_LOGIN_SERVER}/dm/web:v${CI_PIPELINE_ID}"
REDIS_NAME="${DM_ACR_LOGIN_SERVER}/public/redis:v7.2.0"

# authenticate to docker registry
docker login --username ${DOCKER_USERNAME} --password-stdin "${DM_ACR_LOGIN_SERVER}" <<<"${DOCKER_ACCESS_TOKEN}"

# set environment properties
sed -i -e "s#{SERVICE_ENDPOINT}#${DM_API_ENDPOINT}#g" -e "s#{REDIS_HOST}#${DM_REDIS_CLUSTER_HOST}#g" -e "s#{REDIS_PASSWORD}#${DM_REDIS_CLUSTER_PASSWORD}#g" ./src/main/resources/application.properties
sed -i -e "s#{AZURE_STORAGE_ACCOUNT_NAME}#${DM_STORAGE_ACCOUNT_NAME}#g" -e "s#{AZURE_KEY_VAULT_NAME}#${DM_KEY_VAULT_NAME}#g" ./src/main/resources/application-azure.properties

# build container image
docker build --build-arg SPRING_PROFILE=azure --build-arg PORT=8080 -t "${IMAGE_NAME}" .
docker push "${IMAGE_NAME}"

docker build -t "${REDIS_NAME}" -f Dockerfile.redis .
docker push "${REDIS_NAME}"

vault kv put kv/az/acr/web \
    username="${DOCKER_USERNAME}" \
    access_token="${DOCKER_ACCESS_TOKEN}" \
    image_name="${IMAGE_NAME}" \
    redis_name="${REDIS_NAME}"
