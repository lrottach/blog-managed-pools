# blog-managed-pools

Companion Terraform code for an upcoming blog post about Azure Managed DevOps Pools with private blob storage access via private endpoints.

The post itself will walk through the architecture, the reasoning behind each piece, and what to look for when you run it. This README only covers what you need to know to deploy the example end-to-end.

## What gets deployed

A single resource group containing:

- A pool VNet with a subnet delegated to `Microsoft.DevOpsInfrastructure/pools` and a NAT gateway for outbound egress.
- A Managed DevOps Pool registered to an Azure DevOps organization, with a user-assigned managed identity attached.
- A Dev Center and Dev Center Project (parents of the pool).
- A separate storage VNet with a `StorageSubnet` hosting a private endpoint to a blob storage account.
- The storage account itself (public network access disabled).
- A `privatelink.blob.core.windows.net` private DNS zone, linked to both VNets, with the A record auto-registered through the private endpoint.
- Bidirectional VNet peering between the two VNets so the pool agents can reach the private endpoint they resolve.

A diagnostic Azure Pipelines YAML lives under [`pipeline/`](./pipeline/pool-diagnostics.yml) for verifying the agent runs inside the customer VNet and that the storage FQDN resolves to a private IP.

## Prerequisites

### 1. Azure CLI signed in to the right subscription

```bash
az login
az account set --subscription <subscription-id>
```

The signed-in principal needs `Contributor` on the target resource group (or subscription) and `Directory.Read.All` on Microsoft Graph so Terraform can look up the `DevOpsInfrastructure` first-party service principal by its application ID.

### 2. Register the required resource providers

These are not registered in fresh subscriptions by default. Both are required before the first `terraform apply`:

```bash
az provider register --namespace Microsoft.DevOpsInfrastructure --wait
az provider register --namespace Microsoft.DevCenter --wait
```

You can verify with:

```bash
az provider show --namespace Microsoft.DevOpsInfrastructure --query "registrationState" -o tsv
az provider show --namespace Microsoft.DevCenter --query "registrationState" -o tsv
```

Both must return `Registered`.

### 4. Managed DevOps Pools quota

Managed DevOps Pools has its own per-family vCPU quota, separate from the regular Azure Compute quota. A new subscription typically starts with `0` cores for every VM family on the MDP side, regardless of what your normal Compute quota looks like.

Check the MDP-side limits before applying:

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az rest --method get \
  --url "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/providers/Microsoft.DevOpsInfrastructure/locations/westeurope/usages?api-version=2025-09-20" \
  --query "value[].{family:name.value, current:currentValue, limit:limit}" -o table
```

If the family you want to use shows `limit: 0`, file a quota request through the **Help + Support → New support request → Service and subscription limits (quotas) → Managed DevOps Pools** path in the Azure portal. Typical turnaround is a few hours.

The example defaults to `Standard_B2s_v2`, which lives in `standardBsv2Family`. Update [`main_devops.tf`](./main_devops.tf) if your approved quota is on a different family.

### 5. Azure DevOps prerequisites

- The target Azure DevOps organization must be in the **same Microsoft Entra tenant** as the subscription. This is what makes the pool's connection to Azure DevOps work without a PAT.
- The principal running `terraform apply` needs **Project Administrator** (or Agent Pools Administrator/Creator) permissions in each project listed in `azure_devops_projects` in `terraform.tfvars`.
