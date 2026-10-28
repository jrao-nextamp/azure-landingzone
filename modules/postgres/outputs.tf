output "server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.psql.id
}

output "server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.psql.name
}

output "server_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.psql.fqdn
}

output "database_name" {
  description = "Name of the initial PostgreSQL database"
  value       = azurerm_postgresql_flexible_server_database.db.name
}

output "administrator_login" {
  description = "Administrator login username"
  value       = azurerm_postgresql_flexible_server.psql.administrator_login
}

output "administrator_password" {
  description = "Administrator password for PostgreSQL"
  value       = random_password.admin_password.result
  sensitive   = true
}
