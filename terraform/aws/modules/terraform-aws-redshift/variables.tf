variable "name" {
  default = "develop"
}

variable "admin_username" {
  default = "admin"
}
variable "random_password_length" {
  default = 16
}
variable "rs_ingress_ports" {
  type        = list(number)
  default     = [1433]
  description = "List of ports opened from Private Subnets CIDR to Redshift Instance"
}
variable "kms_key_arn" {
  description = "Should be pre-created"
}
variable "vpc_id" {
  description = "default vpc us-east-1"
  default = "vpc-0f5e6ce17bb4dd77d"
}
variable "subnet_ids" {
  description = "default subnets us-east-1"
  default = ["subnet-069e172cb12a54545", "subnet-07d95e0b059c97b9a", "subnet-01750b5875e3df47d"]
}
variable "security_group_ids" {
  description = "default sg us-east-1"
  default = "sg-0654c85d379f6def2"
}
