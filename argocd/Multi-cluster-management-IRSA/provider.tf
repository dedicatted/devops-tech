provider "aws" {
  alias  = "account1"
  region = var.aws_region
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}

provider "aws" {
  alias  = "account2"
  region = var.aws_region
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}

provider "kubernetes" {
  host                   = var.cluster1.endpoint
  cluster_ca_certificate = base64decode(var.cluster1.certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster1.name]
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster1.endpoint
    cluster_ca_certificate = base64decode(var.cluster1.certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster1.name]
      command     = "aws"
    }
  }
}
