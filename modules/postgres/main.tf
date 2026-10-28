resource "random_password" "admin_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_postgresql_flexible_server" "psql" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.pg_version
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false
  administrator_login           = var.administrator_login
  administrator_password        = random_password.admin_password.result
  sku_name                      = var.sku_name
  storage_mb                    = var.storage_mb
  backup_retention_days         = 7

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.psql.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Optional: Store password and connection string in Key Vault
resource "azurerm_key_vault_secret" "psql_password" {
  count        = var.store_secrets_in_key_vault ? 1 : 0
  name         = "postgres-admin-password"
  value        = random_password.admin_password.result
  key_vault_id = var.key_vault_id

  depends_on = [var.key_vault_rbac_ready]
}

resource "azurerm_key_vault_secret" "psql_connection_string" {
  count        = var.store_secrets_in_key_vault ? 1 : 0
  name         = "postgres-connection-string"
  value        = "postgresql://${var.administrator_login}:${random_password.admin_password.result}@${azurerm_postgresql_flexible_server.psql.fqdn}:5432/${var.database_name}?sslmode=require"
  key_vault_id = var.key_vault_id

  depends_on = [var.key_vault_rbac_ready]
}
