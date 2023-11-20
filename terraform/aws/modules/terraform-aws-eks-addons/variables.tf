variable "alb_chart_version" {
  default = "1.5.4"
}
variable "autoscaler_chart_version" {
  default = "9.29.1"
}
variable "external_dns_chart_version" {
  default = "6.20.4"
}
variable "external_secrets_chart_version" {
  default = "0.9.0"
}
variable "velero_chart_version" {
  default = "4.1.3"
}
variable "ebs_chart_version" {
  default = "2.20.0"
}
variable "vpc_id" {
  default = "vpc-0f5e6ce17bb4dd77d"
}
variable "region" {
  default = "us-east-1"
}
variable "oidc_provider_arn" {
  default = "test"
}
variable "cluster_name" {
  default = "devops-eks"
}
variable "route53_zone_name" {
  default = "testterraform.com"
}
variable "kms_key_arn" {
  default = "bla-bla"
}
variable "tags" {
  default = "test tag"
  
}
variable "cluster_autoscaler" {
  description = "parameters which defaine creation cluster autoscaler addons"
  type = bool
  default = true
}
variable "aws_load_balancer_controller" {
  type = bool
  default = true
}
variable "aws_ebs_csi_driver" {
  type = bool
  default = true
}
variable "external_secrets" {
  type = bool
  default = true
}
variable "velero" {
  type = bool
  default = true
}
variable "external_dns" {
  type = bool
  default = true
}