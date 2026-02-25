data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization = false

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "Set", "List"]
  }

  tags = {
    Environment = "production"
  }
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each     = toset(var.secret_names)
  name         = each.value
  value        = each.value == "db-password" ? "changeme-prod-password" : "changeme-redis-pass"
  key_vault_id = azurerm_key_vault.kv.id
}
