# EKS IAM RESOURCES
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "eks" {
  name               = "dm-eks-cluster-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for DM EKS cluster"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks_cluster_vpc" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "dm-eks-node-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for DM EKS cluster nodes"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_container" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_cloudwatch" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Cluster OIDC Provider for service account role assumption
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
data "tls_certificate" "eks_dm_app" {
  url = aws_eks_cluster.dm_app.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_dm_app" {
  url = aws_eks_cluster.dm_app.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    data.tls_certificate.eks_dm_app.certificates[0].sha1_fingerprint,
  ]

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

# Cluster AWS ALB Controller
# https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
data "aws_iam_policy_document" "eks_dm_app_alb_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_dm_app.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_dm_app.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_dm_app.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "eks_dm_app_alb_controller" {
  name               = "dm-eks-alb-controller-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for DM EKS cluster ALB controller"
  assume_role_policy = data.aws_iam_policy_document.eks_dm_app_alb_controller_assume_role.json

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_iam_policy" "eks_dm_app_alb_controller" {
  name        = "dm-eks-alb-controller-policy-${var.deployment_id}"
  path        = "/"
  description = "IAM policy for DM EKS ALB controller"
  policy      = file("${path.module}/assets/eks/alb-controller-iam-policy.json")

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_iam_role_policy_attachment" "eks_alb_controller" {
  role       = aws_iam_role.eks_dm_app_alb_controller.name
  policy_arn = aws_iam_policy.eks_dm_app_alb_controller.arn
}

# Cluster AWS EBS CSI Driver
# https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
data "aws_iam_policy_document" "eks_dm_app_ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_dm_app.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_dm_app.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_dm_app.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "eks_dm_app_ebs_csi" {
  name               = "dm-eks-ebs-csi-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for DM EKS cluster EBS CSI"
  assume_role_policy = data.aws_iam_policy_document.eks_dm_app_ebs_csi_assume_role.json

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_controller" {
  role       = aws_iam_role.eks_dm_app_ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# BASTION IAM RESOURCES
data "aws_iam_policy_document" "bastion" {
  statement {
    sid    = "AllowS3Bootstrap"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::aws-quickstart/quickstart-linux-bastion/*",
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
    ]
    resources = [
      "${aws_cloudwatch_log_group.dm_bastion.arn}:*",
    ]
  }
}

resource "aws_iam_policy" "bastion" {
  name        = "dm-mgmt-bastion-policy-${var.deployment_id}"
  path        = "/"
  description = "IAM policy for Bastion host"
  policy      = data.aws_iam_policy_document.bastion.json

  tags = merge(local.tags, {
    Product = "Operations"
  })
}

resource "aws_iam_role" "bastion" {
  name               = "dm-mgmt-bastion-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for Bastion host"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.tags, {
    Product = "Operations"
  })
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion.arn
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "bastion_cloud_watch" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "dm-mgmt-bastion-ec2-role-${var.deployment_id}"
  role = aws_iam_role.bastion.name
}

# CLOUDTRAIL IAM RESOURCES
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "cloudtrail" {
  name               = "dm-cloudtrail-logs-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for CloudTrail logging"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json

  tags = merge(local.tags, {
    Product = "security"
  })
}

data "aws_iam_policy_document" "cloudtrail_policy" {
  statement {
    sid    = "AllowCloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.cloudtrail.arn}:*",
    ]
  }
}

resource "aws_iam_policy" "cloudtrail" {
  name        = "dm-cloudtrail-logs-policy-${var.deployment_id}"
  path        = "/"
  description = "IAM policy for CloudTrail logging"
  policy      = data.aws_iam_policy_document.cloudtrail_policy.json

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
  role       = aws_iam_role.cloudtrail.name
  policy_arn = aws_iam_policy.cloudtrail.arn
}

# PROWLER IAM RESOURCES
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

data "aws_iam_policy_document" "prowler" {
  statement {
    sid    = "AllowProwlerAdditionalAuditChecks"
    effect = "Allow"
    actions = [
      "ds:ListAuthorizedApplications",
      "ec2:GetEbsEncryptionByDefault",
      "ecr:Describe*",
      "elasticfilesystem:DescribeBackupPolicy",
      "glue:GetConnections",
      "glue:GetSecurityConfiguration",
      "glue:SearchTables",
      "lambda:GetFunction",
      "s3:GetAccountPublicAccessBlock",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "ssm:GetDocument",
      "support:Describe*",
      "tag:GetTagKeys",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.prowler.arn}:*",
    ]
  }

  statement {
    sid    = "AllowS3AuditLogsWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:HeadObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
    resources = [
      "${aws_s3_bucket.prowler.arn}/*",
    ]
  }

  statement {
    sid    = "AllowCodeBuildTests"
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.this.account_id}:report-group/*",
    ]
  }

  statement {
    sid    = "AllowSecurityHubPublish"
    effect = "Allow"
    actions = [
      "securityhub:BatchImportFindings",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "prowler" {
  name        = "dm-audit-prowler-codebuild-policy-${var.deployment_id}"
  path        = "/"
  description = "IAM policy for DM Audit Prowler codebuild job"
  policy      = data.aws_iam_policy_document.prowler.json

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_iam_role" "prowler" {
  name               = "dm-audit-prowler-codebuild-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for DM Audit Prowler codebuild job"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_iam_role_policy_attachment" "prowler" {
  role       = aws_iam_role.prowler.name
  policy_arn = aws_iam_policy.prowler.arn
}

resource "aws_iam_role_policy_attachment" "prowler_support_user" {
  role       = aws_iam_role.prowler.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/SupportUser"
}

resource "aws_iam_role_policy_attachment" "prowler_view_only" {
  role       = aws_iam_role.prowler.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "prowler_security_audit" {
  role       = aws_iam_role.prowler.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

data "aws_iam_policy_document" "events_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "prowler_start_build" {
  name               = "dm-audit-prowler-event-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for DM Audit Prowler CW event"
  assume_role_policy = data.aws_iam_policy_document.events_assume_role.json

  tags = merge(local.tags, {
    Product = "security"
  })
}

data "aws_iam_policy_document" "prowler_start_build" {
  statement {
    sid    = "AllowCodeBuildStart"
    effect = "Allow"
    actions = [
      "codebuild:StartBuild",
    ]
    resources = [
      aws_codebuild_project.prowler.arn
    ]
  }
}

resource "aws_iam_policy" "prowler_start_build" {
  name        = "dm-audit-prowler-event-policy-${var.deployment_id}"
  path        = "/"
  description = "IAM policy for DM Audit Prowler job"
  policy      = data.aws_iam_policy_document.prowler.json

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_iam_role_policy_attachment" "prowler_start_build" {
  role       = aws_iam_role.prowler_start_build.name
  policy_arn = aws_iam_policy.prowler_start_build.arn
}

# DM Web IAM Role Permissions
data "aws_iam_policy_document" "dm_app_web" {
  statement {
    sid    = "AllowCloudFrontAccess"
    effect = "Allow"
    actions = [
      "cloudfront:GetDistribution",
    ]
    resources = [
      aws_cloudfront_distribution.dm.arn
    ]
  }

  statement {
    sid    = "AllowS3ListAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.dm.arn
    ]
  }

  statement {
    sid    = "AllowS3DataAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:GetObjectTagging",
    ]
    resources = [
      "${aws_s3_bucket.dm.arn}/coupons/*"
    ]
  }

  statement {
    sid    = "AllowSSMAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.this.account_id}:parameter/dm/web/*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.this.account_id}:log-group:/aws/containerinsights/dm-app-eks-cluster/*"
    ]
  }
}

resource "aws_iam_policy" "dm_app_web" {
  name        = "dm-web-eks-pod-policy-${var.deployment_id}"
  path        = "/"
  description = "IAM policy for DM Web pods running in EKS"
  policy      = data.aws_iam_policy_document.dm_app_web.json

  tags = merge(local.tags, {
    Product     = "dm-app",
    Application = "dm-web",
  })
}

data "aws_iam_policy_document" "eks_dm_app_web_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_dm_app.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_dm_app.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_dm_app.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:dm:web-sa"]
    }
  }
}

resource "aws_iam_role" "dm_app_web" {
  name               = "dm-web-eks-pod-role-${var.deployment_id}"
  path               = "/"
  description        = "IAM role for DM Web pods running in EKS"
  assume_role_policy = data.aws_iam_policy_document.eks_dm_app_web_assume_role.json

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_iam_role_policy_attachment" "dm_app_web" {
  role       = aws_iam_role.dm_app_web.name
  policy_arn = aws_iam_policy.dm_app_web.arn
}

#LAMBDA
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

#API GW
data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {

    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}
