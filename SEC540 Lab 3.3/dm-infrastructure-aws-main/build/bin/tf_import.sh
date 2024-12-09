#!/bin/bash

# set tf vars
export TF_VAR_deployment_id=$(vault kv get -field=deployment_id kv/aws/deployment/metadata) || echo ""
export TF_VAR_state_bucket="dm-terraform-state-$TF_VAR_deployment_id"
export TF_VAR_region=$(vault kv get -field=region kv/aws/iam/devsecops) || echo ""
export TF_VAR_admin_ip_address="$(curl -s https://checkip.amazonaws.com)/32"
export TF_VAR_bastion_ssh_public_key="/home/student/.ssh/id_rsa.pub"
export TF_VAR_acm_private_key="/home/student/certs/www.dm.paper.key"
export TF_VAR_acm_certificate_body="/home/student/certs/www.dm.paper.crt"
export TF_VAR_acm_certificate_chain="/home/student/certs/ca.sans.labs.root.crt"
export TF_VAR_discord_webhook=$(vault kv get -field=webhook kv/dm/webhooks/discord) || echo ""
export TF_VAR_cloudfront_public_key="/home/student/.ssh/cloudfront.pub"
export TF_VAR_cloudfront_private_der="/home/student/.ssh/cloudfront.der"
export TF_VAR_jwt_secret=$(vault kv get -field=jwt-secret kv/dm/tokens/api) || echo ""
export TF_VAR_bastion_image_id=$(aws ssm get-parameters --name "/dm/images/linux/latest" | jq -r '.Parameters[].Value' || echo "")
export TF_VAR_eks_container_insights_application_log_group=$(aws logs describe-log-groups | jq -r '.logGroups[] | select(.logGroupName=="/aws/containerinsights/dm-app-eks-cluster/application").logGroupName')
export TF_VAR_web_alb_arn=$(aws elbv2 describe-load-balancers | jq -r '.LoadBalancers[] | select(.LoadBalancerName=="dm-web").LoadBalancerArn')

echo "Importing AWS resource into Terraform."

# init with tf backend
terraform init --backend-config="bucket=$TF_VAR_state_bucket" --backend-config="region=$TF_VAR_region"

# import resource
terraform import $1 $2
