locals {
  suffix       = "${var.project}-${var.environment}-${var.region_code}-${var.instance}"
  clean_suffix = lower(replace("${var.project}${var.environment}${var.region_code}${var.instance}", "-", ""))
  location     = data.azurerm_resource_group.rg.location
  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }

  # Private DNS zones for private endpoints and internal resolution.
  # Keys are used as friendly references throughout the codebase.
  private_dns_zones = {
    blob       = "privatelink.blob.core.windows.net"
    servicebus = "privatelink.servicebus.windows.net"
    keyvault   = "privatelink.vaultcore.azure.net"
    acr        = "privatelink.azurecr.io"
    openai     = "privatelink.openai.azure.com"
    postgres   = "${var.project}-${var.environment}.private.postgres.database.azure.com"
  }
}
