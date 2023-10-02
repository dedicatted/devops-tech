variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "devops"
}
variable "vpc_id" {
  default = "vpc-0f5e6ce17bb4dd77d"
}
variable "private_subnets" {
 default = ["subnet-067b11f0152b7ce04", "subnet-0b71fc3428b80f0ed", "subnet-000b82a70cf385d4c"]
}
variable "cluster_version" {
  default = "1.27"
}
variable "ami_id" {
  default = "ami-0e38f9978e7cac6dc"
}

variable "kms_key_arn" {

}
variable "cloudwatch_log_group_retention_in_days" {
  type    = number
  default = 14
}

# variable "sso_role_arn" {

# }
variable "max_pods" {
  default = 29
}
variable "instance_types" {
  default = "m6i.large"
}
variable "default_instance_types" {
  default = "m6i.large"
}
variable "create" {
  type    = bool
  default = true
}
