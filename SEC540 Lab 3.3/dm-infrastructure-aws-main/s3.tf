resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket" "dm" {
  bucket        = "dm-${var.deployment_id}"
  force_destroy = true

  tags = merge(local.tags, {
    Product = "dm-app"
  })

}

resource "aws_s3_bucket_ownership_controls" "dm" {
  bucket = aws_s3_bucket.dm.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_cors_configuration" "dm" {
  bucket = aws_s3_bucket.dm.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_public_access_block" "dm" {
  bucket = aws_s3_bucket.dm.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "dm_s3" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.dm.arn}/coupons/*"]
  }
}

resource "aws_s3_bucket_policy" "dm" {
  bucket = aws_s3_bucket.dm.id
  policy = data.aws_iam_policy_document.dm_s3.json

  depends_on = [
    aws_s3_bucket_public_access_block.dm,
    aws_s3_bucket_ownership_controls.dm,
  ]
}

resource "aws_s3_object" "dm_coupons_5reamsfree" {
  bucket      = aws_s3_bucket.dm.bucket
  key         = "coupons/5reamsfree.jpg"
  source      = "${path.module}/resources/coupons/5reamsfree.jpg"
  source_hash = filemd5("${path.module}/resources/coupons/5reamsfree.jpg")

  tags = {
    Name        = "5 Reams Free"
    Description = "Buy 50 reams of paper and get 5 reams free."
  }
}

resource "aws_s3_object" "dm_coupons_25percentoff" {
  bucket      = aws_s3_bucket.dm.bucket
  key         = "coupons/25percentoff.jpg"
  source      = "${path.module}/resources/coupons/25percentoff.jpg"
  source_hash = filemd5("${path.module}/resources/coupons/25percentoff.jpg")

  tags = {
    Name        = "New Customer Discount"
    Description = "New customers receive 25 percent off their first order."
  }
}

resource "aws_s3_object" "dm_coupons_200dollarsoff" {
  bucket      = aws_s3_bucket.dm.bucket
  key         = "coupons/200dollarsoff.jpg"
  source      = "${path.module}/resources/coupons/200dollarsoff.jpg"
  source_hash = filemd5("${path.module}/resources/coupons/200dollarsoff.jpg")

  tags = {
    Name        = "200 Hundred Dollar Credit"
    Description = "Spend 1000 dollars and receive a 200 hundred dollar credit towards your next purchase."
  }
}

resource "aws_s3_object" "dm_w2" {
  for_each = fileset("${path.module}/resources", "w2/**")

  bucket      = aws_s3_bucket.dm.bucket
  key         = each.value
  source      = "${path.module}/resources/${each.value}"
  source_hash = filemd5("${path.module}/resources/${each.value}")
}

resource "aws_s3_bucket" "access_logs" {
  bucket        = "dm-access-logs-${var.deployment_id}"
  force_destroy = true

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "dm-cloudtrail-logs-${var.deployment_id}"
  force_destroy = true

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_iam_policy_document" "cloudtrail_bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.cloudtrail.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${var.region}:${data.aws_caller_identity.this.account_id}:trail/${local.dm_cloudtrail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${var.region}:${data.aws_caller_identity.this.account_id}:trail/${local.dm_cloudtrail_name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket.json
}

resource "aws_s3_bucket" "prowler" {
  bucket        = "dm-audit-prowler-${var.deployment_id}"
  force_destroy = true

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_s3_bucket_versioning" "prowler" {
  bucket = aws_s3_bucket.prowler.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "prowler_bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["*"]

    resources = [
      "${aws_s3_bucket.prowler.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "prowler" {
  bucket = aws_s3_bucket.prowler.id
  policy = data.aws_iam_policy_document.prowler_bucket.json
}
