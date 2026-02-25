output "rg_name" { value = var.resource_group_name }
output "acr_name" { value = var.acr_name }
output "acr_login_server" { value = module.acr.acr_login_server }
output "aks_name" { value = var.aks_name }
output "aks_get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${module.aks.aks_name}"
}
output "key_vault_name" { value = module.keyvault.key_vault_name }
output "key_vault_uri" { value = module.keyvault.key_vault_uri }