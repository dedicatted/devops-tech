data "aws_caller_identity" "current" {}

# data "aws_eks_cluster" "cluster" {
#   count      = var.create ? 1 : 0
#   depends_on = [module.eks]
#   name       = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   count      = var.create ? 1 : 0
#   depends_on = [module.eks]
#   name       = module.eks.cluster_name
# }

