# All values are supplied via terraform.tfvars. Resource-specific tuning (VM
# SKU, image, address ranges, concurrency) is hardcoded in the resources
# themselves to keep this blog example easy to read.

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that holds all example resources."
  type        = string
}

variable "user_assigned_identity_name" {
  description = "Name of the user-assigned managed identity attached to the pool."
  type        = string
}

variable "vnet_name" {
  description = "Name of the dedicated virtual network for the pool."
  type        = string
}

variable "subnet_pool_name" {
  description = "Name of the subnet delegated to Microsoft.DevOpsInfrastructure/pools."
  type        = string
}

variable "nat_gateway_name" {
  description = "Name of the NAT gateway providing outbound internet access to the pool subnet."
  type        = string
}

variable "public_ip_name" {
  description = "Name of the public IP attached to the NAT gateway."
  type        = string
}

variable "storage_vnet_name" {
  description = "Name of the dedicated virtual network that hosts the storage account's private endpoint."
  type        = string
}

variable "storage_subnet_name" {
  description = "Name of the subnet inside the storage VNet that hosts the private endpoint."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the blob storage account. Must be globally unique, 3-24 chars, lowercase alphanumeric only."
  type        = string
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint to the storage account's blob sub-resource."
  type        = string
}

variable "private_dns_zone_link_pool_name" {
  description = "Name of the private DNS zone virtual network link for the pool VNet."
  type        = string
}

variable "private_dns_zone_link_storage_name" {
  description = "Name of the private DNS zone virtual network link for the storage VNet."
  type        = string
}

variable "peering_pool_to_storage_name" {
  description = "Name of the VNet peering from the pool VNet to the storage VNet."
  type        = string
}

variable "peering_storage_to_pool_name" {
  description = "Name of the VNet peering from the storage VNet to the pool VNet."
  type        = string
}

variable "dev_center_name" {
  description = "Name of the DevCenter that hosts the pool's parent project."
  type        = string
}

variable "dev_center_project_name" {
  description = "Name of the DevCenter Project the pool is registered against."
  type        = string
}

variable "pool_name" {
  description = "Name of the Managed DevOps Pool."
  type        = string
}

variable "azure_devops_organization_url" {
  description = "URL of the Azure DevOps organization (e.g. https://dev.azure.com/my-org)."
  type        = string
}

variable "azure_devops_projects" {
  description = "Projects in the organization the pool is made available to. Empty list grants access to all projects."
  type        = list(string)
  default     = []
}
