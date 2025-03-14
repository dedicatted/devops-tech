terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
    }
  }
}
