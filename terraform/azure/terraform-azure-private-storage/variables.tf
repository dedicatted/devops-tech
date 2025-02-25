variable "resource_names_suffix" {
  description = "A suffix to append to resource names to ensure uniqueness."
  type        = string
}

variable "resource_group" {
  description = "Configuration object for the Azure Resource Group. The 'name' specifies the name of the resource group, and 'location' defines the Azure region where the resource group will be created."
  type = object({
    name     = string
    location = string
  })
}

variable "dns_zone_name" {
  description = "The name of the DNS zone to be managed or created. This should be a fully qualified domain name (FQDN) that represents the DNS zone."
  type        = string
}
variable "dns_resource_group" {
  description = "The name of the resource group DNS zone to be managed or created. This should be a fully qualified domain name (FQDN) that represents the DNS zone."
  type        = string
}

variable "storage_settings" {
  description = "Configuration object for set up Public access to static files in blob storage"
  type = object({
    custom_domain_name      = string
    blob_container_name     = string
    storage_account_name    = string
    fd_profile_name         = string
    fd_sku_name             = string
    fd_endpoint_name        = string
    fd_origin_group_name    = string
    fd_origin_name          = string
    fd_route_name           = string
    fd_firewall_policy_name = string
    fd_security_policy_name = string
    ip_whitelist            = list(string)
  })
}
