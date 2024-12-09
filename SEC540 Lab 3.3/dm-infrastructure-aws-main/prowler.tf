# Build specification YAML
data "local_file" "prowler_build_spec" {
  filename = "${path.module}/assets/prowler/prowler-buildspec.yaml"
}

resource "aws_codebuild_project" "prowler" {
  name          = "dm-audit-prowler-codebuild"
  description   = "DM Audit Prowler CodeBuild job"
  build_timeout = "300"
  service_role  = aws_iam_role.prowler.arn

  source {
    type      = "NO_SOURCE"
    buildspec = data.local_file.prowler_build_spec.content
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      type  = "PLAINTEXT"
      name  = "BUCKET_REPORT"
      value = aws_s3_bucket.prowler.bucket
    }

    environment_variable {
      type  = "PLAINTEXT"
      name  = "PROWLER_OPTIONS"
      value = "-r ${var.region} -f ${var.region} ${local.dm_prowler_options}"
    }

    environment_variable {
      type  = "PLAINTEXT"
      name  = "PROWLER_VERSION"
      value = local.dm_prowler_version
    }

    environment_variable {
      type  = "PLAINTEXT"
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = aws_cloudwatch_log_group.prowler.name
    }
  }

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_codebuild_report_group" "prowler" {
  name = "dm-audit-prowler-codebuild-report-group"
  type = "TEST"

  export_config {
    type = "NO_EXPORT"
  }

  delete_reports = true

  tags = merge(local.tags, {
    Product = "security"
  })
}
