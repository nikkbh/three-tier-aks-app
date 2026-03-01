variable "tf_state_rg_name" {
  type        = string
  description = "The name of the resource group in which the Terraform state storage account will be created."
}

variable "location" {
  type        = string
  description = "The location where the resources will be created."
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default = {
    Project = "3-tier-aks-backend"
  }
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
}

variable "account_replication_type" {
  type        = string
  description = "The Replication Type to use for this storage account"
  default     = "GRS"
}

variable "account_tier" {
  type        = string
  description = "The Tier to use for this storage account"
  default     = "Standard"
}

variable "container_name" {
  type        = string
  description = "The name of the storage container"
  default     = "tfstate"
}
