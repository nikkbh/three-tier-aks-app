variable "prefix" {
  description = "Prefix name for VM"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group for VM"
  type        = string
}

variable "location" {
  description = "Location for VM"
  type        = string
}

variable "nic_id" {
  description = "NIC ID to be attached to this VM"
  type        = string
}

variable "ssh_key" {
  description = "Public SSH Key to be set to the VM"
  type        = string
}

variable "uami_ids" {
  type        = list(string)
  description = "List of UAMI IDs"
}
