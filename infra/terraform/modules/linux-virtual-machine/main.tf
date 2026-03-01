resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_F2"
  network_interface_ids = [var.nic_id]
  admin_username        = "adminuser"

  identity {
    type         = "UserAssigned"
    identity_ids = var.uami_ids
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

}
