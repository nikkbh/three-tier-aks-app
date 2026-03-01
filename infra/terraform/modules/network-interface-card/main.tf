resource "azurerm_public_ip" "pip" {
  name                = "${var.name}-pip"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_network_interface" "nic" {
  name                = var.name
  resource_group_name = var.rg
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
