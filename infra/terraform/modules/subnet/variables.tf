variable "rg" {
  type        = string
  description = "resource group name"
}

variable "subnet_name" {
  type        = string
  description = "subnet name"
}


variable "vnet_name" {
  type        = string
  description = "subnet name"
}

variable "delegations" {
  description = "List of delegations for the subnet. Set to null or empty list if none."
  type = list(object({
    name         = string
    service_name = string
  }))
  default = null
}

variable "address_prefixes" {
  type        = list(string)
  description = "Allowed Address prefixes"
}
