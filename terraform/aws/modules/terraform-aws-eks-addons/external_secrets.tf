module "external_secrets_irsa_role" {
  source = "./irsa_roles"

  role_name                      = "external-secrets"
  attach_external_secrets_policy = true
  external_secrets_kms_key_arns  = [var.kms_key_arn]

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:kubernetes-external-secrets"]
    }
  }
}

resource "helm_release" "external_secrets" {
  depends_on       = [module.external_secrets_irsa_role, helm_release.alb_ingress]
  repository       = "https://charts.external-secrets.io"
  name             = "external-secrets"
  chart            = "external-secrets"
  version          = var.external_secrets_chart_version
  wait             = true
  timeout          = "300"
  create_namespace = true
  namespace        = "external-secrets"
  values = [<<EOF
serviceAccount:
  create: true
  name: external-secrets
  annotations:
    eks.amazonaws.com/role-arn: ${module.external_secrets_irsa_role.iam_role_arn}
EOF
  ]
}
# Wait until external secrets addon finalizing
resource "time_sleep" "wait_for_external_secrets" {
  depends_on = [helm_release.external_secrets]

  create_duration = "30s"
}
