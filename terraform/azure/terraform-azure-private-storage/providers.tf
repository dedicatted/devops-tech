terraform {
  required_version = "~> 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.98.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.52.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}
