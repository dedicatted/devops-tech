# resource "azurerm_private_endpoint" "priavate_access_blob" {
#   name                = "storage-private-endpoint"
#   location            = azurerm_resource_group.main_rg.location
#   resource_group_name = azurerm_resource_group.main_rg.name
#   subnet_id           = lookup(module.main_vnet.vnet_subnets_name_id, var.vnet.subnet_names[0])

#   private_service_connection {
#     name                           = "storage-connection"
#     private_connection_resource_id = azurerm_storage_account.static_storage_account.id
#     is_manual_connection           = false
#     subresource_names              = ["blob"]
#   }
# }

# resource "azurerm_private_dns_zone" "priavate_access_blob" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = azurerm_resource_group.main_rg.name
# }

# resource "azurerm_private_dns_a_record" "priavate_access_blob" {
#   name                = azurerm_storage_account.static_storage_account.name
#   zone_name           = azurerm_private_dns_zone.priavate_access_blob.name
#   resource_group_name = azurerm_resource_group.main_rg.name
#   ttl                 = 300
#   records = [
#     azurerm_private_endpoint.priavate_access_blob.private_service_connection[0].private_ip_address
#   ]
# }
