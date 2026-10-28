variable "name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet (list of CIDR blocks)"
  type        = list(string)
}

variable "subnet_cidrs" {
  description = "Map of subnet name to CIDR. Keys: aca, psql, pep, mgmt"
  type        = map(string)
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
