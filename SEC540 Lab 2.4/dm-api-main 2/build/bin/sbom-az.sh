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

# read environment vars
DM_ACR_NAME=$(vault kv get -field=dm_acr_name kv/az/deployment/metadata) || echo ""
DM_ACR_LOGIN_SERVER=$(vault kv get -field=dm_acr_login_server kv/az/deployment/metadata) || echo ""
IMAGE_NAME="$(vault kv get -field=image_name kv/az/acr/api)"

# authenticate to docker registry
az acr login --name "${DM_ACR_NAME}"

# Generate SBOMS for the image
echo "Using syft to generate an SBOM for ${IMAGE_NAME}..."
syft --version

#LAB24: Implement SBOM
