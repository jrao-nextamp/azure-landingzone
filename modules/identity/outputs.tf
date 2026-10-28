output "client_ids" {
  description = "Map of service name to managed identity client ID"
  value       = { for k, v in azurerm_user_assigned_identity.svc : k => v.client_id }
}

output "principal_ids" {
  description = "Map of service name to managed identity principal ID"
  value       = { for k, v in azurerm_user_assigned_identity.svc : k => v.principal_id }
}

output "identity_ids" {
  description = "Map of service name to managed identity resource ID"
  value       = { for k, v in azurerm_user_assigned_identity.svc : k => v.id }
}
