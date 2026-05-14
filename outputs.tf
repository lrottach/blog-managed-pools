output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group."
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "ID of the virtual network. Consumed by step 2 to attach private endpoints."
  value       = azurerm_virtual_network.main.id
}

output "subnet_pool_id" {
  description = "ID of the delegated pool subnet."
  value       = azurerm_subnet.pool.id
}

output "dev_center_id" {
  description = "ID of the DevCenter."
  value       = azurerm_dev_center.main.id
}

output "dev_center_project_id" {
  description = "ID of the DevCenter Project."
  value       = azurerm_dev_center_project.main.id
}

output "pool_id" {
  description = "Resource ID of the Managed DevOps Pool."
  value       = azurerm_managed_devops_pool.pool.id
}

output "pool_name" {
  description = "Name of the Managed DevOps Pool."
  value       = azurerm_managed_devops_pool.pool.name
}

output "user_assigned_identity_id" {
  description = "ID of the user-assigned identity attached to the pool."
  value       = azurerm_user_assigned_identity.pool.id
}

output "user_assigned_identity_principal_id" {
  description = "Principal (object) ID of the pool's user-assigned identity. Used by step 2 for storage role assignments."
  value       = azurerm_user_assigned_identity.pool.principal_id
}
