output "namespace_id" {
  description = "Resource ID of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.sb.id
}

output "namespace_name" {
  description = "Name of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.sb.name
}

output "primary_connection_string" {
  description = "Primary connection string for the authorization rule RootManageSharedAccessKey"
  value       = azurerm_servicebus_namespace.sb.default_primary_connection_string
  sensitive   = true
}
