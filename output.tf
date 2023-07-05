output "name" {
  value = azurerm_eventhub_namespace.eventhub_ns.name
}

output "id" {
  value = azurerm_eventhub_namespace.eventhub_ns.id
}

output "hubs" {
  description = "hubs"
  value       = [for hubs in azurerm_eventhub.eventhub : hubs.id]
}