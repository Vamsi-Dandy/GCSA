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

# read environment vars
DM_ECR_LOGIN_SERVER=$(vault kv get -field=dm_ecr_login_server kv/aws/deployment/metadata) || echo ""

# configure ecr image auth
DOCKER_USERNAME="$(vault kv get -field=username kv/aws/ecr/api)"
DOCKER_ACCESS_TOKEN="$(aws ecr get-login-password --region "${AWS_DEFAULT_REGION}")"
IMAGE_NAME="$(vault kv get -field=image_name kv/aws/ecr/api)"

# authenticate to docker registry
docker login --username "${DOCKER_USERNAME}" --password-stdin "${DM_ECR_LOGIN_SERVER}" <<<"${DOCKER_ACCESS_TOKEN}"

# Generate SBOMS for the image
echo "Using syft to generate an SBOM for ${IMAGE_NAME}..."
syft --version

#LAB24: Implement SBOM
syft "docker:${IMAGE_NAME}" \
    -o "json=${RESULTS_DIR}/${SYFT_SBOM}" \
    -o "spdx-json=${RESULTS_DIR}/${SPDX_SBOM}" \
    -o "cyclonedx-json=${RESULTS_DIR}/${CYCLONEDX_SBOM}"
