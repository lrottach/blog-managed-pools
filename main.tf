# Resource group that holds all infrastructure for this example.
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# User-assigned identity attached to the pool. Not required to register
# the pool against Azure DevOps, but step 2 of this example uses it to
# grant the pool agents private access to a blob storage account.
resource "azurerm_user_assigned_identity" "pool" {
  name                = var.user_assigned_identity_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
