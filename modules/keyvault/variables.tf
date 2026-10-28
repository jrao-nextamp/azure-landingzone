variable "name" {
  description = "Key Vault name (3-24 alphanumeric and hyphens)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "sku_name" {
  description = "SKU for Key Vault (standard or premium)"
  type        = string
  default     = "standard"
}

variable "subnet_id" {
  description = "Subnet ID where Private Endpoint will be created (e.g. snet-pep)"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for privatelink.vaultcore.azure.net"
  type        = string
}

variable "enable_rbac_authorization" {
  description = "Whether to enable RBAC authorization for Key Vault"
  type        = bool
  default     = true
}

variable "admin_principal_id" {
  description = "Object ID of the deployer/admin to grant Key Vault Administrator role"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
