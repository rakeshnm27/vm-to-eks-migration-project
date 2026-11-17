
# --------------------------------------------------
# Amazon EKS Cluster
# --------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [
      for subnet in aws_subnet.private : subnet.id
    ]

    security_group_ids = [
      aws_security_group.eks_cluster.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true

    public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]

  tags = {
    Name = var.cluster_name
  }
}

