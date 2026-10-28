# One user-assigned managed identity per service.
# Role assignments are added later once service access requirements are confirmed.
resource "azurerm_user_assigned_identity" "svc" {
  for_each            = toset(var.services)
  name                = "id-${each.key}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
