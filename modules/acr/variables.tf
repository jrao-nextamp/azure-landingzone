variable "name" {
  description = "ACR name (5-50 alphanumeric characters)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "sku" {
  description = "ACR SKU (Basic, Standard, Premium). Note: Private endpoint requires Premium."
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Enable admin user on ACR. Disabled by default to enforce Managed Identity authentication."
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable Private Endpoint for ACR (requires Premium SKU)"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint (snet-pep)"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for privatelink.azurecr.io"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
