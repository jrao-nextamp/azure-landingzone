# NextAmp Dev: Infrastructure & Basic Provisioning

Creates:
- **Networking**: VNet + 4 subnets (`aca`, `psql`, `pep`, `mgmt`) + NSGs
- **Private DNS**: 6 private DNS zones linked to VNet (`blob`, `servicebus`, `keyvault`, `acr`, `openai`, `postgres`)
- **Identity & Least-Privilege RBAC**:
  - 6 user-assigned managed identities (`submission-api`, `core`, `identity`, `intel-api`, `intel-worker`, `audit`)
  - `AcrPull` on ACR for all 6 microservices
  - `Key Vault Secrets User` on Key Vault for all 6 microservices
  - `Storage Blob Data Contributor` for `submission-api` and `intel-worker`
  - `Azure Service Bus Data Sender` for `submission-api`, `core`, `intel-api`
  - `Azure Service Bus Data Receiver` for `intel-worker` and `audit`
- **Security & Data Isolation**:
  - Key Vault: Public network access disabled (`default_action = Deny`), private endpoint in `snet-pep`
  - Storage Account: Public network access disabled (`default_action = Deny`), blob private endpoint in `snet-pep`
  - ACR: Admin password disabled (`admin_enabled = false`), authenticates strictly via Managed Identities
  - PostgreSQL: Flexible Server in delegated subnet `snet-psql` with private DNS; admin credentials and connection string auto-saved to Key Vault
- **Unified Observability**:
  - Log Analytics Workspace + Application Insights
  - Diagnostic settings configured for Key Vault, Storage, PostgreSQL, Service Bus, and ACR streaming all logs & metrics to Log Analytics
- **Container Apps Environment**: Internal VNet Container Apps Environment (`cae`) in delegated subnet `snet-aca`

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
