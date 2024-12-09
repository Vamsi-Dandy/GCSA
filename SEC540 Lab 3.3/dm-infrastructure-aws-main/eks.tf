# https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
resource "aws_eks_cluster" "dm_app" {
  name     = "${local.dm_eks_cluster_name}-eks-cluster"
  role_arn = aws_iam_role.eks.arn
  version  = 1.28

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_config {
    subnet_ids = [
      aws_subnet.app_private_a.id,
      aws_subnet.app_private_b.id
    ]
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.30.0.0/16"
  }

  tags = merge(local.tags, {
    Product = "dm-app"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_iam_role_policy_attachment.eks_cluster_vpc
  ]
}

# https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_eks_node_group" "dm_app" {
  cluster_name         = aws_eks_cluster.dm_app.name
  node_group_name      = "${local.dm_eks_cluster_name}-eks-node-group"
  node_role_arn        = aws_iam_role.eks_node.arn
  instance_types       = [var.eks_instance_type]
  force_update_version = true

  subnet_ids = [
    aws_subnet.app_private_a.id,
    aws_subnet.app_private_b.id
  ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.dm_app.id
    version = aws_launch_template.dm_app.latest_version
  }

  tags = merge(local.tags, {
    Product = "dm-app"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker,
    aws_iam_role_policy_attachment.eks_node_cni,
    aws_iam_role_policy_attachment.eks_node_container,
  ]
}

# launch template for EKS nodes
resource "aws_launch_template" "dm_app" {
  name = "${local.dm_eks_cluster_name}-eks-node-template"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 50
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.tags, {
      Product = "dm-app",
      Name    = "${local.dm_eks_cluster_name}-eks-node"
    })
  }

  # IMDSv2 w/ hop limit set to 1 disables pod access to the node's IAM role creds
  # https://aws.github.io/aws-eks-best-practices/security/docs/iam/#restrict-access-to-the-instance-profile-assigned-to-the-worker-node
  # Not used in the lab environment due to node upgrades taking over 30 minutes
  # metadata_options {
  #   http_endpoint               = "enabled"
  #   http_tokens                 = "required"
  #   http_put_response_hop_limit = 1
  #   instance_metadata_tags      = "enabled"
  # }
}

# add ons required for ALB ingress
resource "aws_eks_addon" "dm_app_coredns" {
  cluster_name = aws_eks_cluster.dm_app.name
  addon_name   = "coredns"

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_eks_addon" "dm_app_kube_proxy" {
  cluster_name = aws_eks_cluster.dm_app.name
  addon_name   = "kube-proxy"

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_eks_addon" "dm_app_vpc_cni" {
  cluster_name = aws_eks_cluster.dm_app.name
  addon_name   = "vpc-cni"

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}

resource "aws_eks_addon" "dm_app_ebs_csi" {
  cluster_name             = aws_eks_cluster.dm_app.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.eks_dm_app_ebs_csi.arn

  tags = merge(local.tags, {
    Product = "dm-app"
  })
}
