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
