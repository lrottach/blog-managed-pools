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
#
# `default_outbound_access_enabled = false` makes the lack of Azure's
# legacy default outbound explicit; outbound traffic flows through the
# NAT gateway below instead.
resource "azurerm_subnet" "pool" {
  name                            = var.subnet_pool_name
  resource_group_name             = azurerm_resource_group.main.name
  virtual_network_name            = azurerm_virtual_network.main.name
  address_prefixes                = ["10.0.1.0/24"]
  default_outbound_access_enabled = false

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

# Outbound path for the pool agents. Azure's legacy "default outbound
# access" for VMs is being retired, so the delegated subnet must have an
# explicit egress path. A NAT gateway with a single static public IP is
# the simplest option for a single-region example.
resource "azurerm_public_ip" "nat" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "pool" {
  name                = var.nat_gateway_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "pool" {
  nat_gateway_id       = azurerm_nat_gateway.pool.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "pool" {
  subnet_id      = azurerm_subnet.pool.id
  nat_gateway_id = azurerm_nat_gateway.pool.id
}
