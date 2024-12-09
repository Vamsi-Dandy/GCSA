data "aws_caller_identity" "this" {}

data "aws_partition" "this" {}

# Random password for the redis cluster
resource "random_string" "redis_cluster" {
  length  = 20
  lower   = true
  numeric = true
  special = false
  upper   = true
}
