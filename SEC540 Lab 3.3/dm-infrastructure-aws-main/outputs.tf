output "dm_cluster_name" {
  description = "DM EKS cluster name"
  value       = aws_eks_cluster.dm_app.name
}

output "dm_acm_certificate_arn" {
  description = "DM ALB certificate ARN"
  value       = aws_acm_certificate.dm.arn
}

output "dm_bucket_id" {
  description = "DM S3 bucket for web assets"
  value       = aws_s3_bucket.dm.bucket
}

output "dm_cloudfront_distribution_id" {
  description = "DM CloudFront distribution id"
  value       = aws_cloudfront_distribution.dm.id
}

output "dm_cluster_alb_controller_role_arn" {
  description = "DM EKS cluster ALB controller role ARN"
  value       = aws_iam_role.eks_dm_app_alb_controller.arn
}

output "dm_cluster_vpc_cidr_block" {
  description = "DM EKS cluster VPC CIDR block"
  value       = aws_vpc.app.cidr_block
}

output "dm_redis_cluster_password" {
  sensitive   = true
  description = "DM redis cluster password"
  value       = random_string.redis_cluster.result
}

output "dm_internal_route53_phz_id" {
  description = "DM internal PHZ id"
  value       = aws_route53_zone.dm.zone_id
}

output "dm_bastion_base_ami_id" {
  sensitive   = true
  description = "DM bastion instance base AMI id"
  value       = data.aws_ssm_parameter.amazon_linux_2_ami.value
}

output "dm_web_pod_role_arn" {
  description = "IAM Role ARN for the EKS dm/web pod"
  value       = aws_iam_role.dm_app_web.arn
}
