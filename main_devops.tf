# First-party service principal used by Managed DevOps Pools to manage
# infrastructure on behalf of the user. Looked up by its well-known
# Application ID so the example works in any tenant.
data "azuread_service_principal" "devopsinfrastructure" {
  client_id = "0dbb74ee-c69f-4a55-a3e1-7b6ebd13b3a8"
}

# Grants the DevOpsInfrastructure service the network permissions it
# needs to attach pool agent VMs to the delegated subnet.
resource "azurerm_role_assignment" "devopsinfrastructure_network" {
  scope                = azurerm_virtual_network.main.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.devopsinfrastructure.object_id
}

# Managed DevOps Pool registered to an Azure DevOps organization. The
# pool authenticates to Azure DevOps implicitly via the shared Microsoft
# Entra tenant — no PAT or app installation is involved. The principal
# running this apply must have Project Administrator (or Agent Pools
# Administrator/Creator) permissions in each target Azure DevOps project.
resource "azurerm_managed_devops_pool" "pool" {
  name                  = var.pool_name
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  dev_center_project_id = azurerm_dev_center_project.main.id
  maximum_concurrency   = 1

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.pool.id]
  }

  azure_devops_organization {
    organization {
      url         = var.azure_devops_organization_url
      parallelism = 1
      projects    = var.azure_devops_projects
    }
  }

  # Recycle VMs after each job. Switch to a `stateful_agent { ... }` block
  # with `grace_period_time_span` / `maximum_agent_lifetime` to keep them.
  stateless_agent {}

  virtual_machine_scale_set_fabric {
    sku_name  = "Standard_D2ads_v5"
    subnet_id = azurerm_subnet.pool.id

    image {
      well_known_image_name = "ubuntu-22.04"
    }
  }

  depends_on = [azurerm_role_assignment.devopsinfrastructure_network]
}
