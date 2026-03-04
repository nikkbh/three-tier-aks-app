terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {
    key                  = "prod.terraform.tfstate"
    resource_group_name  = "rg-tfstate-three-tier"
    container_name       = "tfstate"
    storage_account_name = "threetieraksapp"
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks-data.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks-data.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks-data.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks-data.kube_config[0].cluster_ca_certificate)
}
