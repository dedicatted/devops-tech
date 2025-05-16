variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "argocd_configuration" {
  description = "A map of ArgoCD configurations"

  type = map(object({
    chart_version     = string
    helm_deploy_crds  = string
    host              = string
    additional_values = optional(string, "")
  }))
}

variable "cluster1" {
  description = "Cluster 1 credentials for EKS and Helm providers"

  type = object({
    name                       = string
    endpoint                   = string
    certificate_authority_data = string
  })
}
