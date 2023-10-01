# data "aws_eks_cluster" "example" {
#   name       = var.cluster_name
#   depends_on = [aws_eks_cluster.this]
# }
# data "aws_eks_cluster_auth" "example" {
#   name       = var.cluster_name
#   depends_on = [aws_eks_cluster.this]
# }

