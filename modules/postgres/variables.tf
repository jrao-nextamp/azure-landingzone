variable "name" {
  description = "PostgreSQL Flexible Server name"
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

variable "delegated_subnet_id" {
  description = "Delegated subnet ID for PostgreSQL Flexible Server (e.g. snet-psql)"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID ending with .postgres.database.azure.com"
  type        = string
}

variable "administrator_login" {
  description = "Administrator username for PostgreSQL"
  type        = string
  default     = "psqladmin"
}

variable "sku_name" {
  description = "SKU Name for PostgreSQL Flexible Server (e.g. B_Standard_B1ms for Dev)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Max storage allowed for the PostgreSQL Flexible Server in MB (min 32768)"
  type        = number
  default     = 32768
}

variable "pg_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "database_name" {
  description = "Initial application database name to create"
  type        = string
  default     = "nextamp_db"
}

variable "key_vault_id" {
  description = "Optional Key Vault ID to store PostgreSQL credentials"
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
