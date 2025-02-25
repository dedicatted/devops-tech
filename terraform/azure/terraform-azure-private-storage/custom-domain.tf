resource "azurerm_cdn_frontdoor_custom_domain" "pub_storage_custom_domain" {
  name                     = var.storage_settings.custom_domain_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.pub_storage_front_door.id
  host_name                = "${var.storage_settings.custom_domain_name}.${data.azurerm_dns_zone.main_dns_zone.name}"


  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

data "azurerm_dns_zone" "main_dns_zone" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_resource_group
}

resource "azurerm_dns_cname_record" "pub_storage_custom_domain" {
  depends_on = [azurerm_cdn_frontdoor_route.pub_storage_route, azurerm_cdn_frontdoor_security_policy.pub_storage_security_policy]

  name                = "${var.storage_settings.custom_domain_name} "
  zone_name           = data.azurerm_dns_zone.main_dns_zone.name
  resource_group_name = var.dns_resource_group
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.pub_storage_front_door_endpoint.host_name
}

resource "azurerm_dns_txt_record" "pub_storage_custom_domain" {
  name                = join(".", ["_dnsauth", var.storage_settings.custom_domain_name])
  zone_name           = data.azurerm_dns_zone.main_dns_zone.name
  resource_group_name = var.dns_resource_group
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.pub_storage_custom_domain.validation_token
  }
}
