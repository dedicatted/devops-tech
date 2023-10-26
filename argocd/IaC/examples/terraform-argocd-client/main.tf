data "aws_eks_cluster" "cluster" {
  count = var.create ? 1 : 0
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create ? 1 : 0
  name  = var.cluster_name
}

resource "kubernetes_secret_v1" "argocd_manager" {
  count = var.create ? 1 : 0
  metadata {

    name      = "argocd-manager-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "argocd-manager"
    }
  }
  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_service_account_v1" "argocd_manager" {
  count = var.create ? 1 : 0

  metadata {
    name      = "argocd-manager"
    namespace = "kube-system"
  }
  secret {
    name = "argocd-manager-token"
    # cannot set to this value without receiving 'secrets "argocd-manager-token-77cq8" not found'
    # name = kubernetes_secret.argocd_manager.metadata[0].name
  }

}

resource "kubernetes_cluster_role_v1" "argocd_manager" {
  count = var.create ? 1 : 0

  metadata {
    name = "argocd-manager-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "argocd_manager" {
  count = var.create ? 1 : 0

  metadata {
    name = "argocd-manager-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.argocd_manager[0].metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd_manager[0].metadata.0.name
    namespace = kubernetes_service_account_v1.argocd_manager[0].metadata.0.namespace
  }
}

data "kubernetes_secret_v1" "argocd_manager" {
  count = var.create ? 1 : 0

  metadata {
    name      = kubernetes_service_account_v1.argocd_manager[0].metadata.0.name
    namespace = kubernetes_service_account_v1.argocd_manager[0].metadata.0.namespace
  }
}



resource "argocd_cluster" "kubernetes" {
  count = var.create ? 1 : 0

  name   = "${var.cluster_name}-${var.region}"
  server = data.aws_eks_cluster.cluster[0].endpoint
  config {
    bearer_token = kubernetes_secret_v1.argocd_manager[0].data.token

    tls_client_config {
      ca_data = base64decode(data.aws_eks_cluster.cluster[0].certificate_authority[0].data)
    }
  }
  lifecycle {
    ignore_changes = [metadata[0].labels, metadata[0].annotations]
  }
}
