# =============================================================================
# Virtual Network — Subnets, NSGs, Associations
# =============================================================================
module "vnet" {
  source = "./modules/vnet"

  name                = "vnet-${local.suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = local.location
  address_space       = [var.vnet_cidr]
  subnet_cidrs        = var.subnet_cidrs
  suffix              = local.suffix
  tags                = local.tags
}

# =============================================================================
# Private DNS Zones & VNet Links
# =============================================================================
module "private_dns" {
  source = "./modules/private_dns"

  private_dns_zones   = local.private_dns_zones
  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_id  = module.vnet.vnet_id
  suffix              = local.suffix
  tags                = local.tags
}

# =============================================================================
# Managed Identities (one per microservice)
# =============================================================================
module "identity" {
  source = "./modules/identity"

  services            = var.services
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = local.location
  tags                = local.tags
}

# =============================================================================
# Monitoring — Log Analytics Workspace + Application Insights
# =============================================================================
module "monitoring" {
  source = "./modules/monitoring"

  suffix              = local.suffix
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = local.location
  log_retention_days  = var.log_retention_days
  log_daily_quota_gb  = var.log_daily_quota_gb
  tags                = local.tags
}

# =============================================================================
# Key Vault + Private Endpoint
# =============================================================================
module "keyvault" {
  source = "./modules/keyvault"

  name                          = "kv-${local.suffix}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = local.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.keyvault_sku
  subnet_id                     = module.vnet.subnet_ids["pep"]
  private_dns_zone_id           = module.private_dns.dns_zone_ids["keyvault"]
  admin_principal_id            = coalesce(var.admin_principal_id, data.azurerm_client_config.current.object_id)
  public_network_access_enabled = var.public_network_access_enabled
  allowed_ip_addresses          = var.allowed_ip_addresses
  log_analytics_workspace_id    = module.monitoring.workspace_id
  tags                          = local.tags
}

# =============================================================================
# Storage Account (Blob) + Private Endpoint
# =============================================================================
module "storage" {
  source = "./modules/storage"

  name                          = "st${substr(local.clean_suffix, 0, 22)}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = local.location
  subnet_id                     = module.vnet.subnet_ids["pep"]
  private_dns_zone_id           = module.private_dns.dns_zone_ids["blob"]
  public_network_access_enabled = var.public_network_access_enabled
  allowed_ip_addresses          = var.allowed_ip_addresses
  log_analytics_workspace_id    = module.monitoring.workspace_id
  tags                          = local.tags
}

# =============================================================================
# Azure Container Registry (ACR)
# =============================================================================
module "acr" {
  source = "./modules/acr"

  name                       = "acr${substr(local.clean_suffix, 0, 47)}"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = local.location
  sku                        = var.acr_sku
  admin_enabled              = var.acr_admin_enabled
  subnet_id                  = module.vnet.subnet_ids["pep"]
  private_dns_zone_id        = module.private_dns.dns_zone_ids["acr"]
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                       = local.tags
}

# =============================================================================
# Service Bus Namespace
# =============================================================================
module "servicebus" {
  source = "./modules/servicebus"

  name                       = "sb-${local.suffix}"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = local.location
  sku                        = var.servicebus_sku
  subnet_id                  = module.vnet.subnet_ids["pep"]
  private_dns_zone_id        = module.private_dns.dns_zone_ids["servicebus"]
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                       = local.tags
}

# =============================================================================
# Azure Database for PostgreSQL Flexible Server
# =============================================================================
module "postgres" {
  source = "./modules/postgres"

  name                       = "psql-${local.suffix}"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = local.location
  delegated_subnet_id        = module.vnet.subnet_ids["psql"]
  private_dns_zone_id        = module.private_dns.dns_zone_ids["postgres"]
  sku_name                   = var.postgres_sku
  pg_version                 = var.postgres_version
  database_name              = var.postgres_db_name
  key_vault_id               = module.keyvault.key_vault_id
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                       = local.tags
}

# =============================================================================
# Container Apps Environment (Internal VNet)
# =============================================================================
module "container_app_env" {
  source = "./modules/container_app_env"

  name                           = "cae-${local.suffix}"
  resource_group_name            = data.azurerm_resource_group.rg.name
  location                       = local.location
  infrastructure_subnet_id       = module.vnet.subnet_ids["aca"]
  log_analytics_workspace_id     = module.monitoring.workspace_id
  internal_load_balancer_enabled = true
  tags                           = local.tags
}
