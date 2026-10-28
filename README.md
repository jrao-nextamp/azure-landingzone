# NextAmp Dev: Infrastructure & Basic Provisioning

Creates:
- **Networking**: VNet + 4 subnets (`aca`, `psql`, `pep`, `mgmt`) + NSGs — `modules/vnet`
- **Private DNS**: 6 private DNS zones linked to VNet (`blob`, `servicebus`, `keyvault`, `acr`, `openai`, `postgres`) — `modules/private_dns`
- **Identity**: 6 user-assigned managed identities (`submission-api`, `core`, `identity`, `intel-api`, `intel-worker`, `audit`) — `modules/identity`
- **Monitoring**: Log Analytics Workspace + Application Insights — `modules/monitoring`
- **Key Vault**: Azure Key Vault with Private Endpoint (`pep`) & RBAC authorization — `modules/keyvault`
- **Storage**: Azure Storage Account (Blob) with Private Endpoint (`pep`) — `modules/storage`
- **ACR**: Azure Container Registry — `modules/acr`
- **Service Bus**: Azure Service Bus Namespace — `modules/servicebus`
- **PostgreSQL**: Azure Database for PostgreSQL Flexible Server in delegated subnet `snet-psql`, credentials stored in Key Vault — `modules/postgres`
- **Container Apps Environment**: Internal VNet Container Apps Environment (`cae`) in delegated subnet `snet-aca` — `modules/container_app_env`

## Prerequisites
Ensure required Azure resource providers are registered:
```bash
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.ManagedIdentity
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.ServiceBus
az provider register --namespace Microsoft.DBforPostgreSQL
az provider register --namespace Microsoft.App
```

## Run
```bash
az login
az account set --subscription "<subscription-id>"
cp terraform.tfvars.example terraform.tfvars   # then edit subscription_id and resource_group_name
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan      # READ the plan
terraform apply tfplan
```

## Clean up
```bash
terraform destroy
```

## Modules

### acr

Azure Container Registry for storing container images.

**Resources:** `azurerm_container_registry.acr`; `azurerm_private_endpoint.pep_acr` — created only when `enable_private_endpoint = true`, `sku = "Premium"`, and `subnet_id` is set. Private endpoints are a Premium-only feature; the module silently skips the endpoint on Basic/Standard rather than failing.

| Input | Description | Type | Default |
|---|---|---|---|
| `name` | ACR name (5-50 alphanumeric characters) | `string` | — |
| `resource_group_name` | Resource group name | `string` | — |
| `location` | Azure region location | `string` | — |
| `sku` | ACR SKU (`Basic`, `Standard`, `Premium`). Private endpoint requires `Premium`. | `string` | `"Standard"` |
| `admin_enabled` | Enable the admin user on ACR | `bool` | `true` |
| `enable_private_endpoint` | Enable Private Endpoint for ACR (requires Premium SKU) | `bool` | `false` |
| `subnet_id` | Subnet ID for the private endpoint (e.g. `snet-pep`) | `string` | `null` |
| `private_dns_zone_id` | Private DNS Zone ID for `privatelink.azurecr.io` | `string` | `null` |
| `tags` | Resource tags | `map(string)` | `{}` |

| Output | Description |
|---|---|
| `acr_id` | Resource ID of the Container Registry |
| `acr_name` | Name of the Container Registry |
| `login_server` | Login server URL for the Container Registry |
| `admin_username` | Admin username for ACR |
| `admin_password` | Admin password for ACR (sensitive) |

### container_app_env

Internal, VNet-integrated Azure Container Apps Environment.

**Resources:** `azurerm_container_app_environment.cae`.

Declares an explicit `workload_profile { name = "Consumption", workload_profile_type = "Consumption" }` block. Azure always attaches a default Consumption workload profile to a Container App Environment and will not let it be removed — if this block is omitted from config, `terraform plan` shows it being deleted, but applying that plan does nothing (Azure ignores/rejects the removal) and leaves permanent drift between state and reality. Keep this block declared so plan/apply stay clean.

`internal_load_balancer_enabled = true` creates a load balancer *inside* `infrastructure_subnet_id`. That subnet must be delegated to `Microsoft.App/environments` and have enough free IPs; the LB's frontend IP config is what makes the subnet "in use" and blocks deletion until the environment itself is deleted first.

| Input | Description | Type | Default |
|---|---|---|---|
| `name` | Name of the Container Apps Environment | `string` | — |
| `resource_group_name` | Resource group name | `string` | — |
| `location` | Azure region location | `string` | — |
| `infrastructure_subnet_id` | Subnet ID delegated to `Microsoft.App/environments` (`snet-aca`) | `string` | — |
| `log_analytics_workspace_id` | Resource ID of the Log Analytics Workspace | `string` | — |
| `internal_load_balancer_enabled` | Whether the environment is only reachable inside the VNet | `bool` | `true` |
| `tags` | Resource tags | `map(string)` | `{}` |

| Output | Description |
|---|---|
| `environment_id` | Resource ID of the Container Apps Environment |
| `environment_name` | Name of the Container Apps Environment |
| `default_domain` | Default domain of the Container Apps Environment |
| `static_ip_address` | Static IP of the internal load balancer |

**Teardown order:** this environment (and its managed load balancer/managed resource group) must finish deleting *before* `snet-aca` can be deleted. `terraform destroy` handles the ordering correctly when the environment is tracked in state; if it was ever created/recreated outside Terraform (manual `az` calls, a failed apply), delete it manually with `az containerapp env delete` first — deletion is asynchronous and can take several minutes (watch `provisioningState` for `ScheduledForDelete` → gone).

### keyvault

Azure Key Vault with a Private Endpoint and RBAC authorization.

**Resources:** `azurerm_key_vault.kv` — RBAC-authorized (`rbac_authorization_enabled`), soft-delete on, purge protection off (so dev vaults can be destroyed and recreated with the same name without a manual purge); `azurerm_private_endpoint.pep` — `vault` subresource connection; `azurerm_role_assignment.admin` — grants `Key Vault Administrator` on the vault to `admin_principal_id`, when set and `enable_rbac_authorization = true`; `time_sleep.rbac_propagation` — 60s wait, `depends_on` the role assignment.

**Why `time_sleep.rbac_propagation` exists:** Azure RBAC role assignments are eventually consistent — the write succeeds immediately, but it can take up to a minute or two before the Key Vault data plane actually honors it. Any resource that reads/writes a secret in this vault right after the admin role assignment is created (e.g. the secrets in `modules/postgres`) can hit a `403 Forbidden` / `ForbiddenByRbac` error even though the role assignment exists, because the permission hasn't propagated yet.

`rbac_ready` is exposed as an output specifically so other modules can force an ordering dependency on it:

```hcl
module "keyvault" {
  source = "./modules/keyvault"
  # ...
}

module "postgres" {
  source = "./modules/postgres"
  key_vault_id         = module.keyvault.key_vault_id
  key_vault_rbac_ready = module.keyvault.rbac_ready   # waits for the role assignment to propagate
}
```

Any new module that writes Key Vault secrets as the deployer identity should take the same `key_vault_rbac_ready`-style input and `depends_on` it on the secret resource(s) — see `modules/postgres/main.tf`.

| Input | Description | Type | Default |
|---|---|---|---|
| `name` | Key Vault name (3-24 alphanumeric and hyphens) | `string` | — |
| `resource_group_name` | Resource group name | `string` | — |
| `location` | Azure region location | `string` | — |
| `tenant_id` | Azure AD tenant ID | `string` | — |
| `sku_name` | SKU for Key Vault (`standard` or `premium`) | `string` | `"standard"` |
| `subnet_id` | Subnet ID for the private endpoint (e.g. `snet-pep`) | `string` | — |
| `private_dns_zone_id` | Private DNS Zone ID for `privatelink.vaultcore.azure.net` | `string` | — |
| `enable_rbac_authorization` | Whether to enable RBAC authorization for Key Vault | `bool` | `true` |
| `admin_principal_id` | Object ID of the deployer/admin to grant `Key Vault Administrator` | `string` | `null` |
| `tags` | Resource tags | `map(string)` | `{}` |

| Output | Description |
|---|---|
| `key_vault_id` | Resource ID of the Key Vault |
| `key_vault_name` | Name of the Key Vault |
| `key_vault_uri` | URI of the Key Vault |
| `private_endpoint_ip` | Private IP address of the Key Vault private endpoint |
| `rbac_ready` | `true`, only once the admin role assignment has had time to propagate — depend on this before writing secrets as the deployer identity |

**Teardown note:** if a Key Vault is ever created/recreated outside Terraform state, deleting it only soft-deletes it by default. With `purge_protection_enabled = false` you can `az keyvault delete` then `az keyvault purge` to fully remove it and free up the name immediately; otherwise it stays in a recoverable, non-reusable state for the retention window.

### postgres

Azure Database for PostgreSQL Flexible Server, VNet-integrated via a delegated subnet, with credentials stored in Key Vault.

**Resources:** `random_password.admin_password` — 24-char generated admin password; `azurerm_postgresql_flexible_server.psql`; `azurerm_postgresql_flexible_server_database.db`; `azurerm_key_vault_secret.psql_password` / `azurerm_key_vault_secret.psql_connection_string` — created only when `store_secrets_in_key_vault = true` (default).

`public_network_access_enabled = false` is set explicitly and is required: when `delegated_subnet_id` is set, Azure rejects the server with `ConflictingPublicNetworkAccessAndVirtualNetworkConfiguration` if public network access isn't also explicitly disabled. VNet integration and public access are mutually exclusive on Flexible Server.

`delegated_subnet_id` must point to a subnet delegated to `Microsoft.DBforPostgreSQL/flexibleServers`, and `private_dns_zone_id` must be a zone of the form `<name>.private.postgres.database.azure.com` linked to the same VNet.

The two `azurerm_key_vault_secret` resources `depends_on = [var.key_vault_rbac_ready]` — pass in the `keyvault` module's `rbac_ready` output so the secret writes don't race the Key Vault Administrator role assignment and fail with a `403`.

| Input | Description | Type | Default |
|---|---|---|---|
| `name` | PostgreSQL Flexible Server name | `string` | — |
| `resource_group_name` | Resource group name | `string` | — |
| `location` | Azure region location | `string` | — |
| `delegated_subnet_id` | Delegated subnet ID for PostgreSQL Flexible Server (e.g. `snet-psql`) | `string` | — |
| `private_dns_zone_id` | Private DNS Zone ID ending with `.postgres.database.azure.com` | `string` | — |
| `administrator_login` | Administrator username | `string` | `"psqladmin"` |
| `sku_name` | SKU name (e.g. `B_Standard_B1ms` for dev) | `string` | `"B_Standard_B1ms"` |
| `storage_mb` | Max storage in MB (min 32768) | `number` | `32768` |
| `pg_version` | PostgreSQL major version | `string` | `"16"` |
| `database_name` | Initial application database name | `string` | `"nextamp_db"` |
| `key_vault_id` | Optional Key Vault ID to store PostgreSQL credentials | `string` | `null` |
| `store_secrets_in_key_vault` | Whether to store credentials in Key Vault | `bool` | `true` |
| `key_vault_rbac_ready` | The `keyvault` module's `rbac_ready` output — ensures secret writes wait for RBAC propagation | `bool` | `true` |
| `tags` | Resource tags | `map(string)` | `{}` |

| Output | Description |
|---|---|
| `server_id` | Resource ID of the PostgreSQL Flexible Server |
| `server_name` | Name of the PostgreSQL Flexible Server |
| `server_fqdn` | FQDN of the PostgreSQL Flexible Server |
| `database_name` | Name of the initial PostgreSQL database |
| `administrator_login` | Administrator login username |
| `administrator_password` | Administrator password (sensitive) |

### servicebus

Azure Service Bus namespace, with an optional Private Endpoint.

**Resources:** `azurerm_servicebus_namespace.sb`; `azurerm_private_endpoint.pep_sb` — created only when `enable_private_endpoint = true`, `sku = "Premium"`, and `subnet_id` is set. Private endpoints are a Premium-only feature; the module silently skips the endpoint on Basic/Standard.

| Input | Description | Type | Default |
|---|---|---|---|
| `name` | Service Bus namespace name | `string` | — |
| `resource_group_name` | Resource group name | `string` | — |
| `location` | Azure region location | `string` | — |
| `sku` | Service Bus SKU (`Basic`, `Standard`, `Premium`). Private endpoint requires `Premium`. | `string` | `"Standard"` |
| `enable_private_endpoint` | Enable Private Endpoint for Service Bus (requires Premium SKU) | `bool` | `false` |
| `subnet_id` | Subnet ID for the private endpoint (e.g. `snet-pep`) | `string` | `null` |
| `private_dns_zone_id` | Private DNS Zone ID for `privatelink.servicebus.windows.net` | `string` | `null` |
| `tags` | Resource tags | `map(string)` | `{}` |

| Output | Description |
|---|---|
| `namespace_id` | Resource ID of the Service Bus Namespace |
| `namespace_name` | Name of the Service Bus Namespace |
| `primary_connection_string` | Connection string for `RootManageSharedAccessKey` (sensitive) |

### storage

Azure Storage Account with a Private Endpoint for the Blob subresource.

**Resources:** `azurerm_storage_account.sa` — `min_tls_version = "TLS1_2"`, `allow_nested_items_to_be_public = false` (anonymous blob access disabled); `azurerm_private_endpoint.pep_blob` — `blob` subresource connection, always created (not conditional, unlike `acr`/`servicebus`).

Unlike the `acr` and `servicebus` modules, the private endpoint here isn't gated by SKU/tier — blob private endpoints work on `Standard` tier, so it's created unconditionally.

Because this private endpoint attaches a NIC to `subnet_id`, that subnet can't be deleted while the endpoint exists. If this resource is ever removed from Terraform state (e.g. a prior failed apply left it orphaned in Azure), `terraform destroy` won't know to clean it up and the subnet delete will fail with `InUseSubnetCannotBeDeleted` — delete the private endpoint manually with `az network private-endpoint delete` first.

| Input | Description | Type | Default |
|---|---|---|---|
| `name` | Storage account name (3-24 alphanumeric lowercase) | `string` | — |
| `resource_group_name` | Resource group name | `string` | — |
| `location` | Azure region location | `string` | — |
| `account_tier` | Storage account tier | `string` | `"Standard"` |
| `account_replication_type` | Storage account replication type | `string` | `"LRS"` |
| `subnet_id` | Subnet ID for the private endpoint (e.g. `snet-pep`) | `string` | — |
| `private_dns_zone_id` | Private DNS Zone ID for blob | `string` | — |
| `tags` | Resource tags | `map(string)` | `{}` |

| Output | Description |
|---|---|
| `storage_account_id` | Resource ID of the Storage Account |
| `storage_account_name` | Name of the Storage Account |
| `primary_blob_endpoint` | Primary blob endpoint URL |
| `private_endpoint_ip` | Private IP address of the Storage Blob private endpoint |
