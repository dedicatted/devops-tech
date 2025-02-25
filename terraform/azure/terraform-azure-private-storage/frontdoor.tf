resource "azurerm_cdn_frontdoor_profile" "pub_storage_front_door" {
  name                = var.storage_settings.fd_profile_name
  resource_group_name = azurerm_resource_group.main_rg.name
  sku_name            = var.storage_settings.fd_sku_name
}

resource "azurerm_cdn_frontdoor_endpoint" "pub_storage_front_door_endpoint" {
  name                     = var.storage_settings.fd_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.pub_storage_front_door.id
}

resource "azurerm_cdn_frontdoor_origin_group" "pub_origin_group" {
  name                     = var.storage_settings.fd_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.pub_storage_front_door.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "pub_blob_container_origin" {
  name                          = var.storage_settings.fd_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.pub_origin_group.id

  enabled                        = true
  host_name                      = azurerm_storage_account.static_storage_account.primary_blob_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_storage_account.static_storage_account.primary_blob_host
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true

  private_link {
    private_link_target_id = azurerm_storage_account.static_storage_account.id
    target_type            = "blob"
    request_message        = "Request access for Azure Front Door Private Link origin"
    location               = azurerm_resource_group.main_rg.location
  }
}

resource "azurerm_cdn_frontdoor_route" "pub_storage_route" {
  name                          = var.storage_settings.fd_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.pub_storage_front_door_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.pub_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.pub_blob_container_origin.id]

  supported_protocols       = ["Http", "Https"]
  patterns_to_match         = ["/*"]
  forwarding_protocol       = "HttpsOnly"
  link_to_default_domain    = true
  https_redirect_enabled    = true
  cdn_frontdoor_origin_path = "/${var.storage_settings.blob_container_name}" // The path to the blob container.

  # !! If you have custom domain !!
  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.pub_storage_custom_domain.id
  ]

  cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.sas_query_rule_set.id]
}

resource "azurerm_cdn_frontdoor_firewall_policy" "pub_storage_waf_policy" {
  name                = var.storage_settings.fd_firewall_policy_name
  resource_group_name = azurerm_resource_group.main_rg.name
  sku_name            = var.storage_settings.fd_sku_name
  enabled             = true
  mode                = "Prevention"

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "pub_storage_security_policy" {
  name                     = var.storage_settings.fd_security_policy_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.pub_storage_front_door.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.pub_storage_waf_policy.id

      association {
        patterns_to_match = ["/*"]

        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.pub_storage_custom_domain.id
        }
      }
    }
  }
}


# Create a SAS token for auth in storage account
data "azurerm_storage_account_sas" "static_container_sas" {
  connection_string = azurerm_storage_account.static_storage_account.primary_connection_string
  https_only        = true
  signed_version    = "2022-11-02"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2025-01-31T00:00:00Z"
  expiry = "2035-01-01T00:00:00Z"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}


# Create a Front Door Rule Set
resource "azurerm_cdn_frontdoor_rule_set" "sas_query_rule_set" {
  name                     = "appendsas"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.pub_storage_front_door.id
}


# Define a Rule that appends the SAS
resource "azurerm_cdn_frontdoor_rule" "append_sas_rule" {
  name                      = "TokenRuleBlobStorage"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.sas_query_rule_set.id
  order                     = 0
  behavior_on_match         = "Continue"

  depends_on = [azurerm_cdn_frontdoor_origin.pub_blob_container_origin, azurerm_cdn_frontdoor_origin_group.pub_origin_group]

  actions {
    url_rewrite_action {
      source_pattern = "/"
      destination    = "/{url_path}${data.azurerm_storage_account_sas.static_container_sas.sas}"
    }
  }

  conditions {
    request_uri_condition {
      match_values = [
        "?sv=2022-11-02&ss=b&srt=",
      ]
      negate_condition = true
      operator         = "Contains"
    }
  }
}
