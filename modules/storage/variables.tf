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

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
