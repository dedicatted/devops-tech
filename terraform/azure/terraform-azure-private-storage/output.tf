output "sas_token_url" {
  value     = data.azurerm_storage_account_sas.static_container_sas.sas
  sensitive = true
}