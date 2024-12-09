resource "aws_route53_zone" "dm" {
  name          = "dm.paper"
  comment       = "PHZ for internal DM endpoints"
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.app.id
  }

  tags = local.tags
}
