variable "name" {
  description = "Name of the Container Apps Environment"
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

variable "infrastructure_subnet_id" {
  description = "Subnet ID delegated to Microsoft.App/environments (snet-aca)"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  type        = string
}

variable "internal_load_balancer_enabled" {
  description = "Whether the environment should only be accessible internally within the VNet"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
