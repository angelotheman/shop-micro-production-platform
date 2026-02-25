# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Get current client config for tenant info
data "azurerm_client_config" "current" {}

# ACR module
module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  acr_name            = var.acr_name
}

# AKS module
module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  aks_name            = var.aks_name
  dns_prefix          = var.dns_prefix
  node_count          = var.node_count
  node_size           = var.node_size
  acr_id              = module.acr.acr_id
  node_pool           = var.node_pool
  environment_name    = var.environment_name
}

# Key Vault module
module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  keyvault_name       = var.keyvault_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = module.aks.kubelet_object_id
}

# Grant AKS managed identity permission to pull from ACR
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = module.aks.kubelet_object_id
  role_definition_name = "AcrPull"
  scope                = module.acr.acr_id
}

# Grant AKS managed identity access to Key Vault
resource "azurerm_role_assignment" "keyvault_access" {
  principal_id         = module.aks.kubelet_object_id
  role_definition_name = "Key Vault Secrets User"
  scope                = module.keyvault.key_vault_id
}
