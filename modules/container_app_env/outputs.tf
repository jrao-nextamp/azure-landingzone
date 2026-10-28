output "environment_id" {
  description = "Resource ID of the Container Apps Environment"
  value       = azurerm_container_app_environment.cae.id
}

output "environment_name" {
  description = "Name of the Container Apps Environment"
  value       = azurerm_container_app_environment.cae.name
}

output "default_domain" {
  description = "Default domain of the Container Apps Environment"
  value       = azurerm_container_app_environment.cae.default_domain
}

output "static_ip_address" {
  description = "Static IP of the internal load balancer for the Container Apps Environment"
  value       = azurerm_container_app_environment.cae.static_ip_address
}
