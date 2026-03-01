# Network Interface
resource "azurerm_network_interface" "jenkins" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "jenkins-ip-config"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins.id
  }
}

resource "azurerm_public_ip" "jenkins" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NSG
resource "azurerm_network_security_group" "jenkins" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_ips # Your IP: ["203.0.113.0/24"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins-UI"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins-Agents"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50000"
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "jenkins" {
  network_interface_id      = azurerm_network_interface.jenkins.id
  network_security_group_id = azurerm_network_security_group.jenkins.id
}

# VM with UAMI
resource "azurerm_linux_virtual_machine" "jenkins" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_B1ms"
  admin_username                  = "jenkins"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.jenkins.id,
  ]

  admin_ssh_key {
    username   = "jenkins"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Attach UAMI
  identity {
    type         = "UserAssigned"
    identity_ids = var.uami_ids
  }

  tags = var.tags

  # User data for Jenkins install
  custom_data = base64encode(templatefile("${path.module}/install-jenkins.sh", {
    jenkins_version = "2.466.3" # LTS
  }))
}
