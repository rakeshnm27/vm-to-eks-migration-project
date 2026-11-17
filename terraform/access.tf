
data "aws_iam_user" "jenkins_deployer" {
  user_name = "jenkins-eks-deployer"
}

resource "aws_eks_access_entry" "jenkins_deployer" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = data.aws_iam_user.jenkins_deployer.arn
  type              = "STANDARD"
  kubernetes_groups = ["jenkins-deployers"]

  tags = {
    Name = "jenkins-eks-access"
  }
}

