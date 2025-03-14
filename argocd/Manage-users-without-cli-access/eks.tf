module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name                             = var.eks_cluster_name
  cluster_version                          = var.eks_cluster_version
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  eks_managed_node_groups                  = var.eks_managed_node_groups
  cluster_endpoint_public_access           = var.eks_cluster_endpoint_public_access
  enable_cluster_creator_admin_permissions = var.eks_enable_cluster_creator_admin_permissions
  cluster_addons                           = var.eks_cluster_addons
}
