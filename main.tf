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
