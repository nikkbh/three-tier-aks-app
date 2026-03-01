terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
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
