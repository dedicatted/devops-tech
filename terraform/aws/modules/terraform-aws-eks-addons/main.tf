module "cluster_autoscaler" {
  count                            = var.cluster_autoscaler ? 1 : 0
  source                           = "./addons/cluster-autoscaler"
  oidc_provider_arn = var.oidc_provider_arn
  region =  var.region
  vpc_id = var.vpc_id
  kms_key_arn = var.kms_key_arn
  cluster_name = var.cluster_name
}

module "aws_load_balancer_controller" {
  count                                      = var.aws_load_balancer_controller ? 1 : 0
  source                                     = "./addons/aws-load-balancer-controller"
  oidc_provider_arn = var.oidc_provider_arn
  alb_chart_version = var.alb_chart_version
  region = var.region
  vpc_id = var.vpc_id
  cluster_name = var.cluster_name
}

# module "aws_efs_csi_driver" {
#  count                            = var.aws_efs_csi_driver ? 1 : 0
#  source                           = "./addons/aws-efs-csi-driver"
#  helm_config                      = var.aws_efs_csi_driver_helm_config != null ? var.aws_efs_csi_driver_helm_config : { values = [local_file.aws_efs_csi_driver_helm_config[count.index].content] }
#  manage_via_gitops                = var.manage_via_gitops
#  addon_context                    = local.addon_context
#  eks_cluster_name                 = data.aws_eks_cluster.eks_cluster.name
#  account_id                       = data.aws_caller_identity.current.account_id
#  aws_efs_csi_driver_extra_configs = var.aws_efs_csi_driver_extra_configs
#  iampolicy_json_content           = var.aws_efs_csi_driver_iampolicy_json_content
#}

module "aws_ebs_csi_driver" {
  count                            = var.aws_ebs_csi_driver ? 1 : 0
  source                           = "./addons/aws-ebs-csi-driver"
  kms_key_arn = var.kms_key_arn
  oidc_provider_arn = var.oidc_provider_arn
}

module "external_secrets" {
  count                          = var.external_secrets ? 1 : 0
  source                         = "./addons/external-secrets"
  kms_key_arn = var.kms_key_arn
  oidc_provider_arn = var.oidc_provider_arn
}

#module "ingress_nginx" {
#  count                       = var.ingress_nginx ? 1 : 0
#  source                      = "./addons/ingress-nginx"
#  helm_config                 = var.ingress_nginx_helm_config != null ? var.ingress_nginx_helm_config : { values = [local_file.ingress_nginx_helm_config[count.index].content] }
#  manage_via_gitops           = var.manage_via_gitops
#  addon_context               = local.addon_context
#  ingress_nginx_extra_configs = var.ingress_nginx_extra_configs
#}

module "velero" {
  count                  = var.velero ? 1 : 0
  source                 = "./addons/velero"
  oidc_provider_arn = var.oidc_provider_arn
  cluster_name = var.cluster_name
}

module "external_dns" {
  count                      = var.external_dns ? 1 : 0
  source                     = "./addons/external-dns"
  kms_key_arn = var.kms_key_arn
  route53_zone_name = var.route53_zone_name
  oidc_provider_arn = var.oidc_provider_arn
  cluster_name = var.cluster_name
}