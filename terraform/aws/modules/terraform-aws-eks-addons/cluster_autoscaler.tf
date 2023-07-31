module "cluster_autoscaler_irsa_role" {
  source                           = "./irsa_roles"
  role_name                        = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]
  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  name       = "cluster-autoscaler"
  chart      = "cluster-autoscaler"
  wait       = true
  version    = var.autoscaler_chart_version
  timeout    = "300"
  values = [<<EOF
cloudProvider: aws
awsRegion: ${var.region}
autoDiscovery:
  clusterName: ${var.cluster_name}
fullnameOverride: cluster-autoscaler
rbac:
  create: true
  pspEnabled: false
  serviceAccount:
    create: true
    name: cluster-autoscaler
    annotations:
      eks.amazonaws.com/role-arn: ${module.cluster_autoscaler_irsa_role.iam_role_arn}
EOF
  ]
}
