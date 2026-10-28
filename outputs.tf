# =============================================================================
# Network Outputs
# =============================================================================
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

# =============================================================================
# Identity & Monitoring Outputs
# =============================================================================
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

# =============================================================================
# Basic Provisioning Outputs
# =============================================================================
output "key_vault_id" {
  description = "Resource ID of Key Vault"
  value       = module.keyvault.key_vault_id
}

output "key_vault_uri" {
  description = "URI of Key Vault"
  value       = module.keyvault.key_vault_uri
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint URL"
  value       = module.storage.primary_blob_endpoint
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = module.acr.login_server
}

output "servicebus_namespace_name" {
  description = "Name of the Service Bus namespace"
  value       = module.servicebus.namespace_name
}

output "postgres_server_fqdn" {
  description = "FQDN of PostgreSQL Flexible Server"
  value       = module.postgres.server_fqdn
}

output "postgres_database_name" {
  description = "Default database name on PostgreSQL"
  value       = module.postgres.database_name
}

# =============================================================================
# Container Apps Environment Outputs
# =============================================================================
output "container_app_environment_id" {
  description = "Resource ID of the Container Apps Environment"
  value       = module.container_app_env.environment_id
}

output "container_app_environment_default_domain" {
  description = "Default domain of the Container Apps Environment"
  value       = module.container_app_env.default_domain
}

output "container_app_environment_static_ip" {
  description = "Static IP of internal load balancer for Container Apps Environment"
  value       = module.container_app_env.static_ip_address
}