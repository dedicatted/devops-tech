resource "azurerm_storage_account" "static_storage_account" {
  name                            = var.storage_settings.storage_account_name
  resource_group_name             = azurerm_resource_group.main_rg.name
  location                        = azurerm_resource_group.main_rg.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false
  infrastructure_encryption_enabled = true
  min_tls_version                 = "TLS1_2"

  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 3650
    last_access_time_enabled      = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_account_network_rules" "static_storage_network_rules" {
  storage_account_id = azurerm_storage_account.static_storage_account.id
  default_action     = "Deny"
  ip_rules = var.storage_settings.ip_whitelist
}

resource "azapi_resource" "static-pub-storage_container" {
  name      = var.storage_settings.blob_container_name
  parent_id = "${azurerm_storage_account.static_storage_account.id}/blobServices/default"
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01"
  body = jsonencode({
    properties = {
      publicAccess = "None"
    }
  })
}