variable "chart_version" {
  default = "5.16.2"
}
variable "argocd_helm_deploy_crds" {
  description = "Variable defining if we want to deploy argocd CRDs"
  default     = false
}
variable "argocd_host" {
  description = "Hostname for ArgoCD deployment to create an additional record in Route53"
}
variable "cluster_name" {

}
variable "acm_certificate_arn" {

}
