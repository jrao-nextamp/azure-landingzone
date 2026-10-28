output "dns_zone_ids" {
  description = "Map of friendly key to Private DNS Zone resource ID"
  value       = { for k, v in azurerm_private_dns_zone.zone : k => v.id }
}

output "dns_zone_names" {
  description = "Map of friendly key to Private DNS Zone FQDN"
  value       = { for k, v in azurerm_private_dns_zone.zone : k => v.name }
}

output "vnet_link_ids" {
  description = "Map of friendly key to VNet Link resource ID"
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.link : k => v.id }
}
