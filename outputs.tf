output "vnet_id" {
  description = "Resource ID of the Virtual Network"
  value       = module.vnet.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet key → subnet resource ID (aca, psql, pep, mgmt)"
  value       = module.vnet.subnet_ids
}

output "nsg_ids" {
  description = "Map of subnet key → NSG resource ID"
  value       = module.vnet.nsg_ids
}

output "private_dns_zone_ids" {
  description = "Map of friendly key → Private DNS Zone resource ID"
  value       = module.private_dns.dns_zone_ids
}

output "managed_identity_client_ids" {
  description = "Map of service name → managed identity client ID"
  value       = module.identity.client_ids
}

output "managed_identity_principal_ids" {
  description = "Map of service name → managed identity principal ID"
  value       = module.identity.principal_ids
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = module.monitoring.workspace_id
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}