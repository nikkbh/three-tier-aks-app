resource "azurerm_key_vault" "three_tier" {
  name                = var.akv_name
  location            = var.location
  resource_group_name = var.rg
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = true
}

resource "azurerm_key_vault_secret" "db_username" {
  name         = "db-username"
  value        = var.db_username # or a TF variable, not hard-coded
  key_vault_id = azurerm_key_vault.three_tier.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.three_tier.id
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "db-name"
  value        = "userdb"
  key_vault_id = azurerm_key_vault.three_tier.id
}

resource "azurerm_key_vault_secret" "db_host" {
  name         = "db-host"
  value        = var.fqdn
  key_vault_id = azurerm_key_vault.three_tier.id
}

resource "azurerm_key_vault_secret" "db_port" {
  name         = "db-port"
  value        = "5432"
  key_vault_id = azurerm_key_vault.three_tier.id
}

