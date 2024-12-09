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
DEPLOYMENT_ID=$(vault kv get -field=deployment_id kv/aws/deployment/metadata) || echo ""
DM_ECR_LOGIN_SERVER=$(vault kv get -field=dm_ecr_login_server kv/aws/deployment/metadata) || echo ""

# configure ecr image auth
DOCKER_USERNAME="AWS"
DOCKER_ACCESS_TOKEN=$(aws ecr get-login-password --region "${AWS_DEFAULT_REGION}")
IMAGE_NAME="${DM_ECR_LOGIN_SERVER}/dm-api-${DEPLOYMENT_ID}:v${CI_PIPELINE_ID}"

vault kv put kv/aws/ecr/api \
    username="${DOCKER_USERNAME}" \
    access_token="${DOCKER_ACCESS_TOKEN}" \
    image_name="${IMAGE_NAME}"

# authenticate to docker registry
docker login --username "${DOCKER_USERNAME}" --password-stdin "${DM_ECR_LOGIN_SERVER}" <<<"${DOCKER_ACCESS_TOKEN}"

# build and push container image
docker buildx build --push --attest type=provenance,mode=max -t "${IMAGE_NAME}" .
