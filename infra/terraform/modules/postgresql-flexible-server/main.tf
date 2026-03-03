resource "random_password" "admin" {
  length  = 20
  special = true
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "aksapp.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "16"
  delegated_subnet_id           = var.private_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  administrator_login           = "pgadmin"
  administrator_password        = random_password.admin.result
  zone                          = "1"
  public_network_access_enabled = false

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768

  depends_on = [var.private_subnet_delegation]

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_configuration" "allow_extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.this.id

  # Include any other extensions you already use
  value = var.extension_values
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks_link" {
  name                  = "aks-link"
  resource_group_name   = var.dns_zone_rg
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.aks_vnet_id
  registration_enabled  = false
}
