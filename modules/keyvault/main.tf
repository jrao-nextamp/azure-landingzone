resource "azurerm_key_vault" "kv" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = var.sku_name
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  rbac_authorization_enabled    = var.enable_rbac_authorization
  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = var.allowed_ip_addresses
  }

  tags = var.tags
}

# Azure's Key Vault firewall/network ACL changes take a short time to
# propagate; without this, secret reads/writes immediately after an ACL
# change can intermittently fail with 403 ForbiddenByConnection.
resource "time_sleep" "wait_for_network_acls" {
  depends_on      = [azurerm_key_vault.kv]
  create_duration = "60s"
}

resource "azurerm_private_endpoint" "pep" {
  name                = "pep-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

# Grant deployer Key Vault Administrator role if admin_principal_id is passed and RBAC is enabled
resource "azurerm_role_assignment" "admin" {
  count                = var.admin_principal_id != null && var.enable_rbac_authorization ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.admin_principal_id
}

# Diagnostic setting to send all Key Vault audit logs and metrics to Log Analytics Workspace
resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
