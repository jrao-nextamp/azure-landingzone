output "acr_id" {
  description = "Resource ID of the Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "Login server URL for the Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "Admin username for ACR"
  value       = azurerm_container_registry.acr.admin_username
}

output "admin_password" {
  description = "Admin password for ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
