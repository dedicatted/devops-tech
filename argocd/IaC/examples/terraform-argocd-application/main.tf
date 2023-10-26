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
resource "github_repository_file" "application" {
  repository          = var.argocd_repo_name
  branch              = "main"
  file                = "${var.name}-application/README.md"
  content             = "This folder contain all the needed configuration files for ArgoCD to deploy ${var.name} applications"
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}
resource "argocd_project" "argocd_project" {
  lifecycle {
    create_before_destroy = true
  }
  metadata {
    name      = var.name
    namespace = "argocd"
    labels = {
      acceptance = "true"
    }
  }
  spec {
    description = "${var.name} project"

    source_namespaces = ["*"]
    source_repos      = ["*"]

    dynamic "destination" {
      for_each = var.cluster_list
      content {
        server    = destination.value
        namespace = "*"
      }
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
      server    = var.cluster_endpoint
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
  lifecycle {
    ignore_changes = [spec[0].source]
  }
}

resource "argocd_application" "appofapp" {
  depends_on = [argocd_project.argocd_project]
  metadata {
    name      = "${var.name}-applications"
    namespace = "argocd"
  }

  spec {
    project = var.name

    source {
      repo_url        = var.argocd_repo_url
      target_revision = "HEAD"
      ref             = "main"
      path            = "${var.name}-application"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
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
  lifecycle {
    ignore_changes = [spec[0].source]
  }
}
