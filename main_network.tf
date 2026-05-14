# Dedicated virtual network for the Managed DevOps Pool. Step 2 of this
# example adds private endpoints for blob storage into this same VNet.
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet that pool agent VMs are placed into. The subnet is delegated to
# the Managed DevOps Pools service so it can attach and release VMs
# without the operator needing direct subnet-level permissions. The /24
# range comfortably holds the pool's agents plus the 5 IPs Azure reserves.
resource "azurerm_subnet" "pool" {
  name                 = var.subnet_pool_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "devopsinfrastructure"
    service_delegation {
      name = "Microsoft.DevOpsInfrastructure/pools"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      ]
    }
  }
}
