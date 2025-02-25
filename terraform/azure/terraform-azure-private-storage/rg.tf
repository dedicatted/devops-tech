resource "azurerm_resource_group" "main_rg" {
  name     = var.resource_group.name
  location = var.resource_group.location
  tags     = local.tags
}
