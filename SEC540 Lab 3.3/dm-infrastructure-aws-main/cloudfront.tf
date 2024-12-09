resource "aws_cloudfront_origin_access_identity" "dm" {
  comment = "dm-web-oaid-${var.deployment_id}"
}

resource "aws_cloudfront_distribution" "dm" {
  origin {
    domain_name = aws_s3_bucket.dm.bucket_regional_domain_name
    origin_id   = "dm-web-origin"
  }

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_All"
  comment         = "DM CDN"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dm-web-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = [
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
      ]
    }

    viewer_protocol_policy = "https-only"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}
