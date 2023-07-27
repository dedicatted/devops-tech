################################################################################
# ALB-Ingress Configuration
################################################################################
module "load_balancer_controller_irsa_role" {
  source = "./irsa_roles"

  role_name                                                       = "alb-ingress"
  attach_load_balancer_controller_policy                          = true
  attach_load_balancer_controller_targetgroup_binding_only_policy = true
  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:alb-ingress"]
    }
  }

}

resource "helm_release" "alb_ingress" {
  depends_on = [module.load_balancer_controller_irsa_role]
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  wait       = true
  timeout    = "300"
  version    = var.alb_chart_version
  values = [<<EOF
clusterName: ${var.cluster_name}
region: ${var.region}
serviceAccount:
  create: true
  name: alb-ingress
  annotations:
    eks.amazonaws.com/role-arn: ${module.load_balancer_controller_irsa_role.iam_role_arn}
  vpcId: ${var.vpc_id}
EOF
  ]
}

resource "time_sleep" "wait_for_load_balancer_and_route53_record" {
  depends_on       = [helm_release.alb_ingress]
  destroy_duration = "300s"
}
