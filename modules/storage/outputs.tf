output "storage_account_id" {
  description = "Resource ID of the Storage Account"
  value       = azurerm_storage_account.sa.id
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.sa.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint URL"
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "private_endpoint_ip" {
  description = "Private IP address of the Storage Blob private endpoint"
  value       = azurerm_private_endpoint.pep_blob.private_service_connection[0].private_ip_address
}
