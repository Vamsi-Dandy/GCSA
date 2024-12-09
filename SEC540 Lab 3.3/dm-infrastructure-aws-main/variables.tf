variable "deployment_id" {
  description = "This is a unique identifier for global AWS resources"
  type        = string
}

variable "region" {
  description = "Region for the region scoped resources [us-east-1|us-east-2|us-west-2|us-west-1|eu-west-1|eu-west-3|ap-northeast-1|ap-southeast-1|ap-southeast-2]"
  type        = string

  validation {
    condition     = var.region == "us-east-1" || var.region == "us-east-2" || var.region == "us-west-2" || var.region == "us-west-1" || var.region == "eu-west-1" || var.region == "eu-west-3" || var.region == "ap-northeast-1" || var.region == "ap-southeast-1" || var.region == "ap-southeast-2"
    error_message = "The environment must be a valid value: [us-east-1|us-east-2|us-west-2|us-west-1|eu-west-1|eu-west-3|ap-northeast-1|ap-southeast-1|ap-southeast-2]."
  }
}

variable "env" {
  description = "Environment to deploy the infrastructure [dev|stage|prod]"
  type        = string
  default     = "prod"

  validation {
    condition     = var.env == "dev" || var.env == "stage" || var.env == "prod"
    error_message = "The environment must be a valid value: [dev|stage|prod]."
  }
}

variable "bastion_ssh_public_key" {
  description = "Public SSH key for the bastion host"
  type        = string
}

variable "admin_ip_address" {
  description = "CIDR range of IP addresses allowed to SSH into public subnet"
  type        = string
}

variable "acm_private_key" {
  description = "ACM certifiate private key"
  type        = string
}

variable "acm_certificate_body" {
  description = "ACM certificate public key"
  type        = string
}

variable "acm_certificate_chain" {
  description = "ACM certificate chain"
  type        = string
}

variable "eks_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.large"
}

variable "eks_container_insights_application_log_group" {
  description = "Container insights application events log group"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Log retention days"
  type        = number
  default     = 7
}

variable "bastion_image_id" {
  description = "Bastion host gold image id"
  type        = string
  default     = ""
}

variable "discord_webhook" {
  description = "Discord webhook for automated notifications"
  type        = string
}

variable "cloudfront_public_key" {
  description = "Path to cloudfront public key file"
  type        = string
}

variable "cloudfront_private_der" {
  description = "Path to base64 encoded cloudfront private der file"
  type        = string
}

variable "jwt_secret" {
  description = "JWT secret used by JWT Authorizer function"
  type        = string
  default     = ""
}

variable "web_alb_arn" {
  description = "DM web ALB arn (enables WAF WebACL)"
  type        = string
  default     = ""
}

variable "tag_owner" {
  description = "Owner of the resources"
  type        = string
  default     = "dschrute"
}

variable "tag_cost_center" {
  description = "Cost center for the resources"
  type        = string
  default     = "Scranton"
}
