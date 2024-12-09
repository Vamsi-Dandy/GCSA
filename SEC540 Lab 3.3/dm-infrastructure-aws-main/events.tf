resource "aws_cloudwatch_event_rule" "prowler" {
  name                = "dm-audit-prowler-codebuild-event"
  description         = "CW Event that triggers the DM Audit CodeBuild job"
  schedule_expression = local.dm_prowler_schedule

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_cloudwatch_event_target" "prowler" {
  target_id = "dm-audit-prowler-codebuild-event"
  rule      = aws_cloudwatch_event_rule.prowler.name
  arn       = aws_codebuild_project.prowler.arn
  role_arn  = aws_iam_role.prowler_start_build.arn
}
