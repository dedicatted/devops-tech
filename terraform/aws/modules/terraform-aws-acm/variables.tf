variable "acm_domain_name" {
  description = "The DNS domain name used to issue the certificate"
}

variable "route53_zone_name" {
  description = "Need to be pre-created. The Route53 hosted zone name"
}

variable "subject_alternative_names" {
  description = "subject_alternative_names for ACM"
  default     = null
}
