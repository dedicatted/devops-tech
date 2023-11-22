variable "alb_chart_version" {
  description = "ALB controller chart version to use for the ALB controller addons(i.e.: `1.5.4`)"
  type        = string
  default     = "1.5.4"
}
variable "autoscaler_chart_version" {
  description = "Cluster autoscaler chart version to use for the cluster autoscaler addons (i.e.: 9.29.1)"
  type        = string
  default     = "9.29.1"
}
variable "external_dns_chart_version" {
  description = "External DNS chart version to use for the external DNS addons(i.e.: `6.20.4`)"
  type        = string
  default     = "6.20.4"
}
variable "external_secrets_chart_version" {
  description = "External secrets chart version to use for the external secrets addons(i.e.: `0.9.0`)"
  default     = "0.9.0"
}
variable "velero_chart_version" {
  description = "Valero chart version to use for the valero addons(i.e.: `4.1.3`)"
  type        = string
  default     = "4.1.3"
}
variable "ebs_chart_version" {
  description = "EBS chart version to use for the ebs addons(i.e.: `2.20.0`)"
  type        = string
  default     = "2.20.0"
}
variable "vpc_id" {
  description = "ID of the VPC where the cluster was provisioned"
  type        = string
}
variable "region" {
  description = "Indicates where EKS cluster located (default value us-east-1)"
  type        = string
  default     = "us-east-1"
}
variable "oidc_provider_arn" {
  description = "AWS EKS cluster oidc provider arn"
  type        = string
}
variable "cluster_name" {
  description = "AWS EKS cluster name with which terraform works"
  type        = string
}
variable "route53_zone_name" {
  description = "Name of route 53 for external dns"
  type        = string
}
variable "kms_key_arn" {
  description = "kms key arn"
  type        = string
}
variable "eks_cluster_certificate" {
  description = "Cluster certicate which give ability to work with cluster"
  type        = string
}
variable "eks_cluster_endpoint" {
  description = "Cluster endpoint which give ability to work with cluster"
  type        = string
}

variable "cluster_autoscaler" {
  description = "Enable cluster autoscaler add-ons"
  type        = bool
  default     = true
}
variable "aws_load_balancer_controller" {
  description = "Enable load balancer controller add-ons"
  type        = bool
  default     = true
}
variable "aws_ebs_csi_driver" {
  description = "Enable ebs csi add-ons"
  type        = bool
  default     = true
}
variable "external_secrets" {
  description = "Enable external secret add-ons"
  type        = bool
  default     = true
}
variable "velero" {
  description = "Enable velero add-ons"
  type        = bool
  default     = true
}
variable "external_dns" {
  description = "Enable external dns add-ons"
  type        = bool
  default     = true
}