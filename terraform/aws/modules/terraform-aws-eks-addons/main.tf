module "cluster_autoscaler" {
  count             = var.cluster_autoscaler ? 1 : 0
  source            = "./addons/cluster-autoscaler"
  oidc_provider_arn = var.oidc_provider_arn
  region            = var.region
  vpc_id            = var.vpc_id
  kms_key_arn       = var.kms_key_arn
  cluster_name      = var.cluster_name
}

module "aws_load_balancer_controller" {
  count             = var.aws_load_balancer_controller ? 1 : 0
  source            = "./addons/aws-load-balancer-controller"
  oidc_provider_arn = var.oidc_provider_arn
  alb_chart_version = var.alb_chart_version
  region            = var.region
  vpc_id            = var.vpc_id
  cluster_name      = var.cluster_name
}

module "aws_ebs_csi_driver" {
  count             = var.aws_ebs_csi_driver ? 1 : 0
  source            = "./addons/aws-ebs-csi-driver"
  kms_key_arn       = var.kms_key_arn
  oidc_provider_arn = var.oidc_provider_arn
}

module "external_secrets" {
  count             = var.external_secrets ? 1 : 0
  source            = "./addons/external-secrets"
  kms_key_arn       = var.kms_key_arn
  oidc_provider_arn = var.oidc_provider_arn
}

module "velero" {
  count             = var.velero ? 1 : 0
  source            = "./addons/velero"
  oidc_provider_arn = var.oidc_provider_arn
  cluster_name      = var.cluster_name
}

module "external_dns" {
  count             = var.external_dns ? 1 : 0
  source            = "./addons/external-dns"
  kms_key_arn       = var.kms_key_arn
  route53_zone_name = var.route53_zone_name
  oidc_provider_arn = var.oidc_provider_arn
  cluster_name      = var.cluster_name
}