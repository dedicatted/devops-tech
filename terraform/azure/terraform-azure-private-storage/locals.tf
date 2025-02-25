locals {
  tags = {
    environment = var.resource_names_suffix
    Managed     = "Terraform"
  }
}