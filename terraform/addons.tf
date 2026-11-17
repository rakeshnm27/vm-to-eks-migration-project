
# --------------------------------------------------
# EKS Managed Add-ons
# Kubernetes Version: 1.37
# --------------------------------------------------

# 1. EKS Pod Identity Agent

resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.4.1-eksbuild.3"
}

# 2. VPC CNI

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "vpc-cni"
  addon_version = "v1.23.3-eksbuild.1"

  depends_on = [
    aws_eks_addon.pod_identity
  ]
}

# 3. CoreDNS

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "coredns"
  addon_version = "v1.14.7-eksbuild.35"

  depends_on = [
    aws_eks_addon.pod_identity
  ]
}

# 4. kube-proxy

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "kube-proxy"
  addon_version = "v1.37.0-eksbuild.39"

  depends_on = [
    aws_eks_addon.pod_identity
  ]
}

# 5. Amazon EBS CSI Driver

resource "aws_eks_addon" "ebs_csi" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.68.0-eksbuild.1"

  depends_on = [
    aws_eks_addon.pod_identity
  ]
}

# --------------------------------------------------
# EKS Pod Identity Associations
# --------------------------------------------------

# VPC CNI

resource "aws_eks_pod_identity_association" "vpc_cni" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.vpc_cni.arn

  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_iam_role_policy_attachment.vpc_cni
  ]
}

# EBS CSI Driver

resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi.arn

  depends_on = [
    aws_eks_addon.ebs_csi,
    aws_iam_role_policy_attachment.ebs_csi
  ]
}

# AWS Load Balancer Controller

resource "aws_eks_pod_identity_association" "load_balancer_controller" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.load_balancer_controller.arn

  depends_on = [
    aws_eks_addon.pod_identity,
    aws_iam_role_policy_attachment.load_balancer_controller
  ]
}

