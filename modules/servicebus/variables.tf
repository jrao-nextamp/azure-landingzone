variable "name" {
  description = "Service Bus namespace name"
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
  description = "Service Bus SKU (Basic, Standard, Premium). Note: Private endpoint requires Premium."
  type        = string
  default     = "Standard"
}

variable "enable_private_endpoint" {
  description = "Enable Private Endpoint for Service Bus (requires Premium SKU)"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint (snet-pep)"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for privatelink.servicebus.windows.net"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
