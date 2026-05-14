# DevCenter that owns the project the pool is registered against.
resource "azurerm_dev_center" "main" {
  name                = var.dev_center_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# DevCenter Project — the direct parent of the Managed DevOps Pool.
resource "azurerm_dev_center_project" "main" {
  name                = var.dev_center_project_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  dev_center_id       = azurerm_dev_center.main.id
}
