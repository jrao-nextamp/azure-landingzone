resource "azurerm_key_vault" "kv" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  rbac_authorization_enabled = var.enable_rbac_authorization

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = var.tags
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

# Azure RBAC role assignments take time to propagate; callers writing secrets
# right after this role assignment must depend on this to avoid 403s.
resource "time_sleep" "rbac_propagation" {
  count           = var.admin_principal_id != null && var.enable_rbac_authorization ? 1 : 0
  depends_on      = [azurerm_role_assignment.admin]
  create_duration = "60s"
}