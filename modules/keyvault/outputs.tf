output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "private_endpoint_ip" {
  description = "Private IP address of the Key Vault private endpoint"
  value       = azurerm_private_endpoint.pep.private_service_connection[0].private_ip_address
}

output "rbac_ready" {
  description = "Depend on this to ensure the admin role assignment has had time to propagate before writing secrets"
  value       = true
  depends_on  = [time_sleep.rbac_propagation]
}