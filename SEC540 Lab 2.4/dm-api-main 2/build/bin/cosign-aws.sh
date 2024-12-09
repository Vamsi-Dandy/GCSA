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

# cosign the image
echo "Using cosign to sign ${IMAGE_NAME}..."
cosign version

#LAB24: Cosign container image
# switch to the gitlab-signing-role
export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=gitlab-signing-role jwt="$VAULT_JWT")"

VAULT_TRANSIT_KEY="dm-api"
if ! vault read "transit/keys/${VAULT_TRANSIT_KEY}" >/dev/null 2>&1; then
    echo "No ${VAULT_TRANSIT_KEY} key in vault's transit secrets engine, did you generate the cosign key pair?"
    exit 1
fi

echo -n "Waiting for image to be ready: "
for _ in {1..10}; do
    docker inspect --format='{{index .RepoDigests 0}}' "${IMAGE_NAME}" >/dev/null 2>&1 && break
    echo -n "."
    sleep 5
done

MANIFEST_DIGEST="$(docker inspect --format='{{index .RepoDigests 0}}' "${IMAGE_NAME}" | cut -f2 -d@)"
IMAGE_TAG="$(docker inspect "${IMAGE_NAME}" --format='{{index .RepoTags 0}}' | cut -f2 -d:)"

cosign sign --yes --key "hashivault://${VAULT_TRANSIT_KEY}" -a "tag=${IMAGE_TAG}" -a "pipeline=${CI_PIPELINE_ID}" "${IMAGE_NAME}@${MANIFEST_DIGEST}"
