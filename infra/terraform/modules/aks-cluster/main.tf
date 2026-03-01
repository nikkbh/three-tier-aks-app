resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  kubernetes_version = var.kubernetes_version

  ingress_application_gateway {
    gateway_id = var.appgw_id
  }

  default_node_pool {
    name           = "system"
    node_count     = var.node_count # e.g., 1 for POC
    vm_size        = var.vm_size    # e.g., Standard_B4ms or B2s
    vnet_subnet_id = var.subnet_id
    max_pods       = 30
    type           = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"

    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  tags = var.tags
}
