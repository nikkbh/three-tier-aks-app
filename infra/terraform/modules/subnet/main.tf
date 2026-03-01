resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg
  address_prefixes     = var.address_prefixes
  dynamic "delegation" {
    for_each = var.delegations != null ? var.delegations : []
    content {
      name = delegation.value.name
      service_delegation {
        name = delegation.value.service_name
      }
    }
  }
}
