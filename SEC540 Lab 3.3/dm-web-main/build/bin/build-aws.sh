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
DM_WEB_BUCKET_ID=$(vault kv get -field=dm_web_bucket_id kv/aws/deployment/metadata) || echo ""
DM_WEB_CLOUDFRONT_DISTRIBUTION_ID=$(vault kv get -field=dm_web_cloudfront_distribution_id kv/aws/deployment/metadata) || echo ""
DM_REDIS_CLUSTER_PASSWORD=$(vault kv get -field=dm_redis_cluster_password kv/aws/deployment/metadata) || echo ""
DM_REDIS_CLUSTER_HOST="redis-ss-0.redis-service.dm"
DM_API_ENDPOINT="api.aws.dm.paper"

# configure image registry image auth
DOCKER_USERNAME="AWS"
DOCKER_ACCESS_TOKEN=$(aws ecr get-login-password --region "${AWS_DEFAULT_REGION}")
IMAGE_NAME="${DM_ECR_LOGIN_SERVER}/dm-web-${DEPLOYMENT_ID}:v${CI_PIPELINE_ID}"
REDIS_NAME="${DM_ECR_LOGIN_SERVER}/public-redis-${DEPLOYMENT_ID}:v7.2.0"

# authenticate to docker registry
docker login --username "${DOCKER_USERNAME}" --password-stdin "${DM_ECR_LOGIN_SERVER}" <<<"${DOCKER_ACCESS_TOKEN}"

# set environment properties
sed -i -e "s#{SERVICE_ENDPOINT}#${DM_API_ENDPOINT}#g" -e "s#{REDIS_HOST}#${DM_REDIS_CLUSTER_HOST}#g" -e "s#{REDIS_PASSWORD}#${DM_REDIS_CLUSTER_PASSWORD}#g" ./src/main/resources/application.properties
sed -i -e "s#{BUCKET_ID}#${DM_WEB_BUCKET_ID}#g" -e "s#{DISTRIBUTION_ID}#${DM_WEB_CLOUDFRONT_DISTRIBUTION_ID}#g" ./src/main/resources/application-aws.properties

# build container image
docker build --build-arg SPRING_PROFILE=aws --build-arg PORT=8443 -t "${IMAGE_NAME}" .
docker push "${IMAGE_NAME}"

docker build -t "${REDIS_NAME}" -f Dockerfile.redis .
docker push "${REDIS_NAME}"

vault kv put kv/aws/ecr/web \
    username="${DOCKER_USERNAME}" \
    access_token="${DOCKER_ACCESS_TOKEN}" \
    image_name="${IMAGE_NAME}" \
    redis_name="${REDIS_NAME}"
