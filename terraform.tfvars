location = "westeurope"

resource_group_name         = "rg-managed-pools-blog"
user_assigned_identity_name = "id-managed-pools-blog"
vnet_name                   = "vnet-managed-pools-blog"
subnet_pool_name            = "DevOpsInfrastructure"
nat_gateway_name            = "ng-managed-pools-blog"
public_ip_name              = "pip-managed-pools-blog"
dev_center_name             = "dc-managed-pools-blog"
dev_center_project_name     = "dcp-managed-pools-blog"
pool_name                   = "pool-managed-pools-blog"

# Replace with the URL of your Azure DevOps organization. The organization must
# be in the same Microsoft Entra tenant as the subscription you deploy into.
azure_devops_organization_url = "https://dev.azure.com/example-org"

# Empty list grants the pool access to every project in the organization.
# Add project names to restrict it (e.g. ["my-project"]).
azure_devops_projects = []
