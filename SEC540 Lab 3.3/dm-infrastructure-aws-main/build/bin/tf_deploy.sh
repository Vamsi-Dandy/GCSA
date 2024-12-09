#!/bin/bash
set -e

test -z "${1}" && exit 1   #State Bucket
test -z "${2}" && exit 2   #Deployment Id
test -z "${3}" && exit 3   #Region
test -z "${4}" && exit 4   #Admin IP
test -z "${5}" && exit 5   #Bastion public SSH key file path
test -z "${6}" && exit 6   #ACM Private Key file path
test -z "${7}" && exit 7   #ACM Cert Body file path
test -z "${8}" && exit 8   #ACM Cert Chain file path
test -z "${9}" && exit 9   #Discord webhook
test -z "${10}" && exit 10 #CloudFront public key
test -z "${11}" && exit 11 #CloudFront private key
# test -z "${12}" && exit 12 #JWT Secret (skip until lab 4.4)

export TF_VAR_state_bucket=${1}
export TF_VAR_deployment_id=${2}
export TF_VAR_region=${3}
export TF_VAR_admin_ip_address=${4}
export TF_VAR_bastion_ssh_public_key=${5}
export TF_VAR_acm_private_key=${6}
export TF_VAR_acm_certificate_body=${7}
export TF_VAR_acm_certificate_chain=${8}
export TF_VAR_discord_webhook=${9}
export TF_VAR_cloudfront_public_key=${10}
export TF_VAR_cloudfront_private_der=${11}
export TF_VAR_jwt_secret=${12}

# Search for dm custom bastion image
export TF_VAR_bastion_image_id=$(aws ssm get-parameters --name "/dm/images/linux/latest" | jq -r '.Parameters[].Value' || echo "")
echo "Deploying $TF_VAR_bastion_image_id virtual machine image."

# Search for dm eks apps container insights log group
export TF_VAR_eks_container_insights_application_log_group=$(aws logs describe-log-groups | jq -r '.logGroups[] | select(.logGroupName=="/aws/containerinsights/dm-app-eks-cluster/application").logGroupName')
echo "Configuring container insights metrics for log group: $TF_VAR_eks_container_insights_application_log_group"

# Search for the dm web load balancer
export TF_VAR_web_alb_arn=$(aws elbv2 describe-load-balancers | jq -r '.LoadBalancers[] | select(.LoadBalancerName=="dm-web").LoadBalancerArn')
echo "Configuring waf web acl for alb: $TF_VAR_web_alb_arn"

# init with tf backend
terraform init --backend-config="bucket=$TF_VAR_state_bucket" --backend-config="region=$TF_VAR_region"

# validate configuration
terraform validate

# plan resource configuration
terraform plan -out dm.plan

# apply changes
terraform apply -lock=false -auto-approve dm.plan

# read output data
DM_EKS_NAME=$(terraform output --json | jq -r '.dm_cluster_name.value')
DM_ACM_CERTIFICATE_ARN=$(terraform output --json | jq -r '.dm_acm_certificate_arn.value')
DM_WEB_BUCKET_ID=$(terraform output --json | jq -r '.dm_bucket_id.value')
DM_WEB_CLOUDFRONT_DISTRIBUTION_ID=$(terraform output --json | jq -r '.dm_cloudfront_distribution_id.value')
DM_REDIS_CLUSTER_PASSWORD=$(terraform output --json | jq -r '.dm_redis_cluster_password.value')
DM_EKS_ALB_CONTROLLER_ROLE_ARN=$(terraform output --json | jq -r '.dm_cluster_alb_controller_role_arn.value')
DM_EKS_CLUSTER_VPC_CIDR_BLOCK=$(terraform output --json | jq -r '.dm_cluster_vpc_cidr_block.value')
DM_INTERNAL_R53_PHZ_ID=$(terraform output --json | jq -r '.dm_internal_route53_phz_id.value')
DM_BASTION_BASE_AMI_ID=$(terraform output --json | jq -r '.dm_bastion_base_ami_id.value')
DM_API_GATEWAY_URL=$(terraform output --json | jq -r '.dm_api_gateway_url.value')
DM_JWT_AUTHORIZER_LAMBDA_ARN=$(terraform output --json | jq -r '.dm_jwt_authorizer_lambda_arn.value')
DM_ECR_LOGIN_SERVER="$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${TF_VAR_region}.amazonaws.com"
DM_WEB_POD_ROLE_ARN=$(terraform output --json | jq -r '.dm_web_pod_role_arn.value')

# store vault output values
vault kv patch kv/aws/deployment/status aws_active=true
vault kv put kv/aws/deployment/metadata \
    deployment_id="$DEPLOYMENT_ID" \
    eks_name="$DM_EKS_NAME" \
    dm_ecr_login_server="$DM_ECR_LOGIN_SERVER" \
    acm_certificate_arn="$DM_ACM_CERTIFICATE_ARN" \
    dm_web_bucket_id="$DM_WEB_BUCKET_ID" \
    dm_web_cloudfront_distribution_id="$DM_WEB_CLOUDFRONT_DISTRIBUTION_ID" \
    dm_redis_cluster_password="$DM_REDIS_CLUSTER_PASSWORD" \
    dm_cluster_alb_controller_role_arn="$DM_EKS_ALB_CONTROLLER_ROLE_ARN" \
    dm_cluster_vpc_cidr_block="$DM_EKS_CLUSTER_VPC_CIDR_BLOCK" \
    dm_internal_route53_phz_id="$DM_INTERNAL_R53_PHZ_ID" \
    dm_bastion_base_ami_id="$DM_BASTION_BASE_AMI_ID" \
    dm_api_gateway_url="$DM_API_GATEWAY_URL" \
    dm_jwt_authorizer_lambda_arn="$DM_JWT_AUTHORIZER_LAMBDA_ARN" \
    dm_web_pod_role_arn="$DM_WEB_POD_ROLE_ARN"
