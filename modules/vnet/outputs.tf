output "vnet_id" {
  description = "Resource ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet key to subnet resource ID"
  value = {
    aca  = azurerm_subnet.aca.id
    psql = azurerm_subnet.psql.id
    pep  = azurerm_subnet.pep.id
    mgmt = azurerm_subnet.mgmt.id
  }
}

output "nsg_ids" {
  description = "Map of subnet key to NSG resource ID"
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}
