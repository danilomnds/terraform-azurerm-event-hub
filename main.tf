resource "azurerm_eventhub_namespace" "eventhub_ns" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  location             = var.location
  sku                  = var.sku
  capacity             = var.capacity
  auto_inflate_enabled = var.auto_inflate_enabled
  dedicated_cluster_id = var.dedicated_cluster_id
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  maximum_throughput_units = var.maximum_throughput_units  
  tags                     = local.tags
  dynamic "network_rulesets" {
    for_each = var.network_rulesets != null ? [var.network_rulesets] : []
    content {
      default_action                 = lookup(network_rulesets.value, "default_action", "Allow")
      public_network_access_enabled  = lookup(network_rulesets.value, "public_network_access_enabled", false)
      trusted_service_access_enabled = lookup(network_rulesets.value, "trusted_service_access_enabled", true)
      dynamic "ip_rule" {
        for_each = network_rulesets.value.ip_rule != null ? [network_rulesets.value.ip_rule] : []
        content {
          action  = "Allow"
          ip_mask = ip_rule.value.ip_mask
        }
      }
      dynamic "virtual_network_rule" {
        for_each = network_rulesets.value.virtual_network_rule != null ? [network_rulesets.value.virtual_network_rule] : []
        content {          
          ignore_missing_virtual_network_service_endpoint = virtual_network_rule.value.ignore_missing_virtual_network_service_endpoint
          subnet_id                                       = virtual_network_rule.value.subnet_id
        }
      }
    }
  }
  local_authentication_enabled  = var.local_authentication_enabled
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version
  lifecycle {
    ignore_changes = [
      tags["create_date"]
    ]
  }
}

resource "azurerm_eventhub" "eventhub" {
  depends_on = [
    azurerm_eventhub_namespace.eventhub_ns
  ]
  for_each            = var.hubs_parameters != null ? { for k, v in var.hubs_parameters : k => v if v != null } : {}
  name                = each.value.name
  namespace_id      = azurerm_eventhub_namespace.eventhub_ns.id  
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
  dynamic "capture_description" {
    for_each = each.value.capture_description == null ? [] : [each.value.capture_description]
    content {
      enabled             = each.value.capture_description.enabled
      encoding            = each.value.capture_description.encoding
      interval_in_seconds = each.value.capture_description.interval_in_seconds
      size_limit_in_bytes = each.value.capture_description.size_limit_in_bytes
      skip_empty_archives = each.value.capture_description.skip_empty_archives
      destination {
        archive_name_format = each.value.capture_description.destination.archive_name_format
        blob_container_name = each.value.capture_description.destination.blob_container_name
        name                = each.value.capture_description.destination.name
        storage_account_id  = each.value.capture_description.destination.storage_account_id
      }
    }
  }
  status = each.value.status
}

resource "azurerm_role_assignment" "eventhub_reader" {
  depends_on = [
    azurerm_eventhub_namespace.eventhub_ns
  ]
  for_each = {
    for group in var.azure_ad_groups : group => group
    if var.eventhub_custom_role && var.azure_ad_groups != []
  }  
  scope                                  = azurerm_eventhub_namespace.eventhub_ns.id
  role_definition_name                   = "Event Hub Custom"
  principal_id                           = each.value
}

resource "azurerm_role_assignment" "eventhub_receiver" {
  depends_on = [
    azurerm_eventhub_namespace.eventhub_ns
  ]
  for_each = {
    for group in var.azure_ad_groups : group => group
    if var.data_receiver && var.azure_ad_groups != []
  }  
  scope                                  = azurerm_eventhub_namespace.eventhub_ns.id
  role_definition_name                   = "Azure Event Hubs Data Receiver"
  principal_id                           = each.value
}

resource "azurerm_role_assignment" "eventhub_sender" {
  depends_on = [
    azurerm_eventhub_namespace.eventhub_ns
  ]
  for_each = {
    for group in var.azure_ad_groups : group => group
    if var.data_sender && var.azure_ad_groups != []
  }  
  scope                                  = azurerm_eventhub_namespace.eventhub_ns.id
  role_definition_name                   = "Azure Event Hubs Data Sender"
  principal_id                           = each.value
}