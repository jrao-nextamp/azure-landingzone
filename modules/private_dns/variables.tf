variable "private_dns_zones" {
  description = "Map of friendly key to DNS zone FQDN. e.g. { blob = \"privatelink.blob.core.windows.net\" }"
  type        = map(string)
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_id" {
  description = "Resource ID of the VNet to link each DNS zone to"
  type        = string
}

variable "suffix" {
  description = "Resource name suffix (project-env-region-instance)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
