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

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m" # example; adjust as needed
  }

  tags = var.tags
}


resource "kubernetes_manifest" "backend_akv_spc" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "backend-akv"
      namespace = "prod"
    }
    spec = {
      provider = "azure"
      parameters = {
        usePodIdentity       = "false"
        useVMManagedIdentity = "true"
        clientID             = "1fa01411-a04c-4cec-9c0f-a290fc559d27"
        keyvaultName         = var.akv_name
        tenantId             = var.tenant_id
        subscriptionId       = var.subscription_id
        resourceGroup        = var.resource_group_name
        cloudName            = "" # Azure public

        objects = <<-EOT
          array:
            - |
              objectName: db-username
              objectType: secret
            - |
              objectName: db-password
              objectType: secret
            - |
              objectName: db-name
              objectType: secret
            - |
              objectName: db-host
              objectType: secret
            - |
              objectName: db-port
              objectType: secret
        EOT
      }

      # This block tells CSI driver to also create a K8s Secret from AKV objects
      secretObjects = [
        {
          secretName = "backend-db-secrets"
          type       = "Opaque"
          data = [
            {
              objectName = "db-username"
              key        = "DB_USERNAME"
            },
            {
              objectName = "db-password"
              key        = "DB_PASSWORD"
            },
            {
              objectName = "db-name"
              key        = "DB_NAME"
            },
            {
              objectName = "db-host"
              key        = "DB_HOST"
            },
            {
              objectName = "db-port"
              key        = "DB_PORT"
            },
          ]
        }
      ]
    }
  }

}

