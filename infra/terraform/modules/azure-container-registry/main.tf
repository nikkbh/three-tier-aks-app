resource "azurerm_container_registry" "this" {
  name                = "${var.name}${random_id.suffix.hex}"
  location            = var.location
  tags                = var.tags
  resource_group_name = var.rg_name
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
}

resource "random_id" "suffix" { byte_length = 4 }
