variable "name" {
  description = "Storage account name (3-24 alphanumeric lowercase)"
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

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint (snet-pep)"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for blob"
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the storage account. Disabled for private network isolation."
  type        = bool
  default     = false
}

variable "allowed_ip_addresses" {
  description = "Optional list of IPv4 addresses allowed through the firewall"
  type        = list(string)
  default     = []
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
