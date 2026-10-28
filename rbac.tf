# =============================================================================
# Least-Privilege RBAC Role Assignments for Microservice Managed Identities
# =============================================================================

# 1. ACR: All 6 microservices can pull container images using their Managed Identity
resource "azurerm_role_assignment" "acr_pull" {
  for_each             = module.identity.principal_ids
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}

# 2. Key Vault: All microservices can read secrets/connection strings (least-privilege read-only)
resource "azurerm_role_assignment" "kv_secrets_user" {
  for_each             = module.identity.principal_ids
  scope                = module.keyvault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

# 3. Storage Account: submission-api uploads documents, intel-worker reads/processes them
resource "azurerm_role_assignment" "storage_blob_contributor" {
  for_each             = toset(["submission-api", "intel-worker"])
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.identity.principal_ids[each.key]
}

# 4. Service Bus Senders: submission-api, core, and intel-api publish messages/jobs
resource "azurerm_role_assignment" "sb_sender" {
  for_each             = toset(["submission-api", "core", "intel-api"])
  scope                = module.servicebus.namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.identity.principal_ids[each.key]
}

# 5. Service Bus Receivers: intel-worker and audit consume messages/events
resource "azurerm_role_assignment" "sb_receiver" {
  for_each             = toset(["intel-worker", "audit"])
  scope                = module.servicebus.namespace_id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = module.identity.principal_ids[each.key]
}
