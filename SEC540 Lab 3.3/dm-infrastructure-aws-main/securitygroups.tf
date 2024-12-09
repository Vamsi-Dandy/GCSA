resource "aws_security_group" "lambda_proxy" {
  name        = "dm-api-lambda-proxy-sg"
  description = "DM API GW Lambda proxy SG"
  vpc_id      = aws_vpc.app.id

  tags = merge(local.tags, {
    Name    = "dm-api-lambda-proxy-sg"
    Product = "dm-app"
  })
}

resource "aws_security_group_rule" "lambda_proxy_api_egress" {
  security_group_id = aws_security_group.lambda_proxy.id
  description       = "Allow outbound to DM API"

  type      = "egress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  cidr_blocks = [
    local.network_addresses[var.env].subnet_private_a,
    local.network_addresses[var.env].subnet_private_b,
  ]
}

resource "aws_security_group_rule" "lambda_proxy_https_egress" {
  security_group_id = aws_security_group.lambda_proxy.id
  description       = "Allow outbound to AWS APIs"

  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "management_bastion" {
  name        = "dm-managment-bastion-sg"
  description = "DM management SG"
  vpc_id      = aws_vpc.app.id

  tags = merge(local.tags, {
    Name        = "dm-management-bastion-sg"
    dm-ops-uses = "build-image"
  })
}

resource "aws_security_group_rule" "management_bastion_ssh_ingress" {
  security_group_id = aws_security_group.management_bastion.id
  description       = "Allow inbound SSH to bastion hosts"

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [var.admin_ip_address]
}

resource "aws_security_group_rule" "management_bastion_https_egress" {
  security_group_id = aws_security_group.management_bastion.id
  description       = "Allow outbound HTTPS to Internet"

  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "management_bastion_api_egress" {
  security_group_id = aws_security_group.management_bastion.id
  description       = "Allow outbound HTTP 8080 to private subnet"

  type      = "egress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  cidr_blocks = [
    local.network_addresses[var.env].subnet_private_a,
    local.network_addresses[var.env].subnet_private_b,
  ]
}
