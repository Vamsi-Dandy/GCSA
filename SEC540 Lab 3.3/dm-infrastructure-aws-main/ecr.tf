resource "aws_ecr_repository" "dm_web" {
  name         = "dm-web-${var.deployment_id}"
  force_delete = true

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_ecr_repository" "dm_api" {
  name         = "dm-api-${var.deployment_id}"
  force_delete = true

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_ecr_repository" "public_redis" {
  name         = "public-redis-${var.deployment_id}"
  force_delete = true

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, {
    Product = "public-redis"
  })
}
