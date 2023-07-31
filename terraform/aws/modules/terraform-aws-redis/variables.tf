variable "name" {
  type    = string
  default = "develop"
}
variable "engine" {
  type    = string
  default = "redis"
}
variable "node_type" {
  type    = string
  default = "cache.m4.large"
}
variable "num_cache_nodes" {
  type    = number
  default = 1
}
variable "parameter_group_name" {
  type    = string
  default = "default.redis7"
}
variable "engine_version" {
  type    = string
  default = "7.0"
}
variable "port" {
  type    = number
  default = 6379
}

variable "security_group_ids" {
  description = "default sg us-east-1"
  default = "sg-0654c85d379f6def2"
}

variable "subnet_group_name" {
  description = "should be pre-created"
}
variable "redis_ingress_ports" {
  type        = list(number)
  default     = [6379]
  description = "List of ports opened from Private Subnets CIDR to Redis Instance"
}
variable "vpc_id" {
  description = "default vpc us-east-1"
  default = "vpc-0f5e6ce17bb4dd77d"
}
