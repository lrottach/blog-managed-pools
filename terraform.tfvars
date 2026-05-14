location = "westeurope"

resource_group_name         = "rg-managed-pools-demo-we"
user_assigned_identity_name = "id-managed-pools-demo-we"
vnet_name                   = "vnet-managed-pools-demo-we"
subnet_pool_name            = "DevOpsInfrastructure"
nat_gateway_name            = "ng-managed-pools-demo-we"
public_ip_name              = "pip-managed-pools-demo-we"
dev_center_name             = "dc-managed-pools-demo-we"
dev_center_project_name     = "dcp-managed-pools-demo-we"
pool_name                   = "pool-managed-pools-demo-we"

storage_vnet_name                  = "vnet-storage-demo-we"
storage_subnet_name                = "StorageSubnet"
storage_account_name               = "stmanagedpoolsdemowe"
private_endpoint_name              = "pe-storage-demo-we"
private_dns_zone_link_pool_name    = "vnet-link-pool"
private_dns_zone_link_storage_name = "vnet-link-storage"
peering_pool_to_storage_name       = "peer-pool-to-storage"
peering_storage_to_pool_name       = "peer-storage-to-pool"

# Replace with the URL of your Azure DevOps organization. The organization must
# be in the same Microsoft Entra tenant as the subscription you deploy into.
azure_devops_organization_url = "https://dev.azure.com/dark-contoso-lab"

# Empty list grants the pool access to every project in the organization.
# Add project names to restrict it (e.g. ["my-project"]).
azure_devops_projects = ["Azure Landing Zone"]
