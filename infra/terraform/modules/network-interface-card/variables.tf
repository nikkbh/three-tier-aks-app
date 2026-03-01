variable "name" {
  type        = string
  description = "Name of the network interface card"
}

variable "location" {
  type        = string
  description = "Location of the network interface card"
}

variable "rg" {
  type        = string
  description = "Resource Group of the network interface card"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID of the subnet to associate to the NIC"
}
