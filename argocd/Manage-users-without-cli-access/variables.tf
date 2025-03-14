variable "aws_region" {
  description = "AWS Region to provision infrastructure in"
  type        = string
  default     = "eu-central-1"
}

################################################################################
# VPC
################################################################################

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "my-vpc-for-argocd-tutorial"
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/18"
}

variable "vpc_azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.10.0.0/22", "10.10.4.0/22"]
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.10.8.0/22", "10.10.12.0/22"]
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "vpc_enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

################################################################################
# EKS
################################################################################

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-for-argocd-tutorial"
}

variable "eks_cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  default     = "1.32"
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default = {
    example = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["c5a.large", "c6a.large"]
      capacity_type  = "SPOT"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }
    }
  }
}

variable "eks_cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "eks_enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = true
}

variable "eks_cluster_addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }
}

################################################################################
# Secrets Manager
################################################################################

variable "secrets_manager_secret_name" {
  description = "AWS Secrets Manager secret name"
  type        = string
  default     = "argocd-local-users"
}

variable "secrets_manager_secret_keys" {
  description = "List of AWS Secrets Manager secret keys"
  type        = list(string)
  default     = ["ARGO_CD_ALICE_USER_PASSWORD_BCRYPT", "ARGO_CD_BOB_USER_PASSWORD_BCRYPT"]
}

################################################################################
# Helm
################################################################################

variable "argocd_release_name" {
  description = "Release name"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Specify the exact chart version to install"
  type        = string
  default     = "7.8.9"
}

variable "argocd_create_namespace" {
  description = "Create the namespace if it does not exist"
  type        = string
  default     = true
}

variable "argocd_namespace" {
  description = "Namespace to install the release into"
  type        = string
  default     = "argocd"
}

variable "argocd_timeout" {
  description = "Time in seconds to wait for any individual kubernetes operation"
  type        = number
  default     = 1200
}
