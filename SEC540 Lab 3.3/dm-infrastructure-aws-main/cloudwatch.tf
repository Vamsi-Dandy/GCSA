resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/dm/cloudtrail"
  retention_in_days = var.log_retention_days

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_cloudwatch_log_group" "dm_bastion" {
  name              = "/dm/mgmt/bastion"
  retention_in_days = var.log_retention_days

  tags = merge(local.tags, {
    Product = "Operations"
  })
}

resource "aws_cloudwatch_log_group" "prowler" {
  name              = "/aws/codebuild/dm-audit-prowler"
  retention_in_days = var.log_retention_days

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_cloudwatch_log_group" "dm_web_hook" {
  name              = "/aws/lambda/dm-web-hook-notifications-${var.deployment_id}"
  retention_in_days = var.log_retention_days

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/apigateway/dm-api-${var.deployment_id}"
  retention_in_days = 7

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_cloudwatch_log_group" "dm_lambda_proxy" {
  name              = "/aws/lambda/dm-api-gateway-proxy-${var.deployment_id}"
  retention_in_days = var.log_retention_days

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_cloudwatch_log_group" "dm_lambda_jwt_authorizer" {
  name              = "/aws/lambda/dm-api-gateway-jwt-authorizer-${var.deployment_id}"
  retention_in_days = var.log_retention_days

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_cloudwatch_log_group" "dm_web" {
  name              = "/aws/containerinsights/dm-app-eks-cluster/application"
  retention_in_days = var.log_retention_days

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}