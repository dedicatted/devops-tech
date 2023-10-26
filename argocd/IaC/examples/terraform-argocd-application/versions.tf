terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "5.6.0"
    }
  }
}
