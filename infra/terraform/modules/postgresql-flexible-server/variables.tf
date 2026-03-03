variable "name" {
  type        = string
  description = "Name of the PostgreSQL Server"
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the PostgreSQL Server will be created"
}
variable "location" {
  type        = string
  description = "Location where the PostgreSQL Server resource will be hosted"
}
variable "private_subnet_id" {
  type        = string
  description = "Private Subnet ID where the resource will be created"
}
variable "private_subnet_delegation" { default = null }
variable "tags" {
  description = "A mapping of tags to assign to the resource group."
  type        = map(string)
}

variable "extension_values" {
  type        = string
  description = "Comma seperated extension values to be added to PostgreSQL's allow-lsit extensions via azure.extensions."
}

variable "aks_vnet_id" {
  type        = string
  description = "VNET ID used for AKS"
}

variable "dns_zone_name" {
  type        = string
  description = "Private DNS Zone name"
}

variable "dns_zone_rg" {
  type        = string
  description = "Private DNS Zone resource group name"
}

