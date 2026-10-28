variable "subscription_id" {
  description = "Azure subscription ID (az account show --query id -o tsv)"
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group (created manually). Terraform only reads it."
  type        = string
}

variable "project" {
  type    = string
  default = "nextamp"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region_code" {
  description = "Short region code used in names, e.g. wus2"
  type        = string
  default     = "wus2"
}

variable "instance" {
  type    = string
  default = "001"
}

# PLACEHOLDER CIDRs. Raju approves the real plan (see tab 2 of the workbook).
variable "vnet_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_cidrs" {
  description = "Placeholder subnet ranges. Verify minimum sizes in current Azure docs before real use."
  type        = map(string)
  default = {
    aca  = "10.10.0.0/23" # Container Apps
    psql = "10.10.2.0/28" # PostgreSQL delegated (docs: minimum /28)
    pep  = "10.10.3.0/27" # Private endpoints
    mgmt = "10.10.4.0/27" # Optional: admin / future use
  }
}

variable "services" {
  description = "Microservice names. Mayur confirms the final list (5 or 6)."
  type        = list(string)
  default     = ["submission-api", "core", "identity", "intel-api", "intel-worker", "audit"]
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "log_daily_quota_gb" {
  description = "Daily ingestion cap in GB (-1 = no cap). Cost control for Dev."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Basic Provisioning SKU Variables
# -----------------------------------------------------------------------------
variable "acr_sku" {
  description = "ACR SKU: Basic, Standard, or Premium. Note: Private endpoints require Premium."
  type        = string
  default     = "Standard"
}

variable "acr_admin_enabled" {
  description = "Enable admin user on ACR. False by default to enforce Managed Identity auth."
  type        = bool
  default     = false
}

variable "servicebus_sku" {
  description = "Service Bus SKU: Basic, Standard, or Premium. Note: Private endpoints require Premium."
  type        = string
  default     = "Standard"
}

variable "postgres_sku" {
  description = "PostgreSQL Flexible Server SKU (e.g. B_Standard_B1ms for Dev)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "postgres_db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "nextamp_db"
}

variable "keyvault_sku" {
  description = "Key Vault SKU: standard or premium"
  type        = string
  default     = "standard"
}

variable "admin_principal_id" {
  description = "Optional object ID of the user or SP to grant Key Vault Administrator role (defaults to deployer if unset)"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Network Security & Access Control
# -----------------------------------------------------------------------------
variable "public_network_access_enabled" {
  description = "Whether public network access is allowed on Key Vault and Storage. Set to false for strict private connectivity."
  type        = bool
  default     = false
}

variable "allowed_ip_addresses" {
  description = "Optional list of public IPv4 addresses allowed through firewall if public access is needed during deploy"
  type        = list(string)
  default     = []
}
