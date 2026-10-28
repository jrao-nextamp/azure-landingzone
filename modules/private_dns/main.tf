# --------------------------------------------------------------------------
# Private DNS Zones
# --------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "zone" {
  for_each            = var.private_dns_zones
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# --------------------------------------------------------------------------
# VNet Links — attach every DNS zone to the shared VNet
# --------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each              = var.private_dns_zones
  name                  = "link-${each.key}-${var.suffix}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zone[each.key].name
  virtual_network_id    = var.virtual_network_id
}
