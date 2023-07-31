data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [module.eks.kubernetes_config_map]
  name       = module.eks.cluster_name
}
