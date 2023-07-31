################################################################################
# External-DNS Configuration
################################################################################

module "external_dns_irsa_role" {
  source                        = "./irsa_roles"
  role_name                     = "external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = [data.aws_route53_zone.zone.arn]

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }
}

resource "helm_release" "external_dns" {
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  name       = "external-dns"
  chart      = "external-dns"
  version    = var.external_dns_chart_version
  wait       = true
  timeout    = "300"
  values = [<<EOF
provider: aws
aws:
  zoneType: public
txtOwnerId: ${data.aws_route53_zone.zone.zone_id}
domainFilters[0]: ${var.route53_zone_name}
policy: sync
serviceAccount:
  create: true
  name: external-dns
  annotations:
    eks.amazonaws.com/role-arn: ${module.external_dns_irsa_role.iam_role_arn}
EOF
  ]
}

# Wait until external DNS addon finalizing
resource "time_sleep" "wait_for_external_dns" {
  depends_on = [helm_release.external_dns]

  create_duration = "30s"
}
