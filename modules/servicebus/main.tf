resource "azurerm_servicebus_namespace" "sb" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  tags = var.tags
}

resource "azurerm_private_endpoint" "pep_sb" {
  count               = var.enable_private_endpoint && var.sku == "Premium" && var.subnet_id != null ? 1 : 0
  name                = "pep-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_servicebus_namespace.sb.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = var.tags
}
