variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "devops"
}
variable "vpc_id" {
  description = "default vpc us-east-1"
  default = "vpc-0f5e6ce17bb4dd77d"
}
variable "private_subnets" {
  description = "There are default PUBLIC subnets just to test the deployment"
  default     = ["subnet-07d95e0b059c97b9a", "subnet-01750b5875e3df47d", "subnet-009315aa49ef29e26"]
}
variable "cluster_version" {
  default = "1.27"
}
variable "ami_id" {
  description = "us-east-1 ami-id"
  default = "ami-061112afff4339a5f"
}

variable "kms_key_arn" {

}
variable "cloudwatch_log_group_retention_in_days" {
  type    = number
  default = 14
}

# variable "sso_role_arn" {

# }
