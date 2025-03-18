resource "helm_release" "argocd" {
  name             = var.argocd_release_name
  repository       = var.argocd_repository
  chart            = var.argocd_chart
  version          = var.argocd_chart_version
  create_namespace = var.argocd_create_namespace
  namespace        = var.argocd_namespace
  timeout          = var.argocd_timeout

  values = [templatefile("${path.module}/helm-values/argocd.yaml", {
    alice_password_bcrypt = "${module.secrets_manager.retrieved_secrets.ARGO_CD_ALICE_USER_PASSWORD_BCRYPT}",
    bob_password_bcrypt   = "${module.secrets_manager.retrieved_secrets.ARGO_CD_BOB_USER_PASSWORD_BCRYPT}"
  })]

  depends_on = [module.eks]
}
