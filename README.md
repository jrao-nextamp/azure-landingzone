# NextAmp Dev: network, identity, monitoring (learning/POC)

Creates: VNet + 4 subnets + NSGs, 5 private DNS zones (linked to VNet),
6 user-assigned managed identities, Log Analytics + Application Insights.
Does NOT create: Container Apps, PostgreSQL, Service Bus, ACR (no Premium SKUs, no big cost).

All CIDRs are placeholders. Use a SEPARATE learning resource group, not the team's Dev RG.

## Run
    az login
    az account set --subscription "<subscription-id>"
    az provider register --namespace Microsoft.Network
    az provider register --namespace Microsoft.OperationalInsights
    az provider register --namespace Microsoft.ManagedIdentity
    cp terraform.tfvars.example terraform.tfvars   # then edit
    terraform init
    terraform fmt
    terraform validate
    terraform plan -out=tfplan      # READ the plan: only "create", no "destroy"
    terraform apply tfplan

## Clean up (learning RG only)
    terraform destroy               # check the list first
