
# --------------------------------------------------
# Custom EKS Cluster Security Group
# --------------------------------------------------

resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.project_name}-eks-cluster-"
  description = "Additional security group for EKS control plane"
  vpc_id      = aws_vpc.main.id

  # Allow Kubernetes API traffic from within the VPC
  ingress {
    description = "Kubernetes API from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = [var.vpc_cidr]
  }

  # Allow outbound traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-cluster-sg"
  }
}

