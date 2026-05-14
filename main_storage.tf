# Dedicated virtual network for the storage account's private endpoint.
# A separate VNet (not the pool VNet) deliberately mirrors a real-world
# topology where storage lives in a different network segment than the
# compute that consumes it. Cross-VNet resolution is enabled by linking
# both VNets to the private DNS zone further down.
resource "azurerm_virtual_network" "storage" {
  name                = var.storage_vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]
}

# Subnet that hosts the private endpoint. `private_endpoint_network_policies = "Disabled"`
# is required for private endpoints to be deployed into the subnet.
resource "azurerm_subnet" "storage" {
  name                              = var.storage_subnet_name
  resource_group_name               = azurerm_resource_group.main.name
  virtual_network_name              = azurerm_virtual_network.storage.name
  address_prefixes                  = ["10.1.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

# Storage account locked to private access only. Public network access is
# disabled, so reaching this account is only possible over the private
# endpoint inside the VNet.
resource "azurerm_storage_account" "main" {
  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  public_network_access_enabled   = false
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

# Private DNS zone for blob endpoints. Azure validates this name — it
# must be exactly "privatelink.blob.core.windows.net" so the CNAME chain
# from "<account>.blob.core.windows.net" resolves into this zone.
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

# Link the pool VNet so pool agent VMs resolve the storage FQDN to the
# private endpoint IP. Without this link the agents would resolve to a
# public Azure IP and hit the public-network-access-disabled wall.
resource "azurerm_private_dns_zone_virtual_network_link" "pool" {
  name                  = var.private_dns_zone_link_pool_name
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# Link the storage VNet so anything else placed in this VNet later can
# resolve the same FQDN the same way.
resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = var.private_dns_zone_link_storage_name
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.storage.id
}

# Private endpoint that gives the storage account a private IP inside
# the storage VNet. The `private_dns_zone_group` block auto-creates the
# matching A record in the zone, so the FQDN resolves correctly from any
# linked VNet without manual DNS upkeep.
resource "azurerm_private_endpoint" "storage_blob" {
  name                = var.private_endpoint_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.storage.id

  private_service_connection {
    name                           = "blob"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

# VNet peering — two resources, one per direction. Linking the private
# DNS zone to both VNets only handles name resolution; without peering
# the pool subnet still has no IP route to the storage subnet, so blob
# traffic would resolve but not connect.
resource "azurerm_virtual_network_peering" "pool_to_storage" {
  name                      = var.peering_pool_to_storage_name
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = azurerm_virtual_network.storage.id
}

resource "azurerm_virtual_network_peering" "storage_to_pool" {
  name                      = var.peering_storage_to_pool_name
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.storage.name
  remote_virtual_network_id = azurerm_virtual_network.main.id
}
