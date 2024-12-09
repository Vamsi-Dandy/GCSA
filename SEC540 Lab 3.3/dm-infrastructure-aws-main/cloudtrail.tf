resource "aws_cloudtrail" "dm" {
  name                          = "dm-cloudtrail-${var.env}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  include_global_service_events = true

  is_multi_region_trail = false
  is_organization_trail = false

  tags = merge(local.tags, {
    Product = "security"
  })

  depends_on = [
    aws_s3_bucket_policy.cloudtrail
  ]
}
