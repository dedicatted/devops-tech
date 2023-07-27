data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

resource "github_repository_file" "file" {
  repository          = var.argocd_repo_name
  branch              = "main"
  file                = "${var.name}/README.md"
  content             = "This folder contain all the needed configuration files for ArgoCD to deploy ${var.name} applications"
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

resource "kubernetes_secret_v1" "argocd_manager" {
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
  metadata {
    name = "argocd-manager-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.argocd_manager.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd_manager.metadata.0.name
    namespace = kubernetes_service_account_v1.argocd_manager.metadata.0.namespace
  }
}

data "kubernetes_secret_v1" "argocd_manager" {
  metadata {
    name      = kubernetes_service_account_v1.argocd_manager.metadata.0.name
    namespace = kubernetes_service_account_v1.argocd_manager.metadata.0.namespace
  }
}

resource "argocd_cluster" "kubernetes" {
  server = data.aws_eks_cluster.cluster.endpoint
  config {
    bearer_token = kubernetes_secret_v1.argocd_manager.data.token

    tls_client_config {
      ca_data = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    }
  }
}

resource "argocd_project" "argocd_project" {
  metadata {
    name      = var.name
    namespace = "argocd"
    labels = {
      acceptance = "true"
    }
  }
  spec {
    description = "${var.name} project"

    source_namespaces = ["production"]
    source_repos      = ["*"]

    destination {
      server    = data.aws_eks_cluster.cluster.endpoint
      namespace = "production"
    }
    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }
  }
}

resource "argocd_application" "application" {
  depends_on = [argocd_project.argocd_project]
  metadata {
    name      = var.name
    namespace = "argocd"
  }

  spec {
    project = var.name

    source {
      repo_url        = var.argocd_repo_url
      target_revision = "HEAD"
      ref             = "main"
      path            = var.name
    }

    destination {
      server    = data.aws_eks_cluster.cluster.endpoint
      namespace = "production"
    }
    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      # Only available from ArgoCD 1.5.0 onwards
      sync_options = ["Validate=false", "CreateNamespace=true"]
      retry {
        limit = "5"
        backoff {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }
  }
}

