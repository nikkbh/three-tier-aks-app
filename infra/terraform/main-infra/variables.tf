variable "rg" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "The location where the resources will be created."
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet"
}

variable "private_subnet_name" {
  type        = string
  description = "Name of the private subnet"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virutal network"
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default = {
    Project = "3-tier-aks-backend"
  }
}

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
}

variable "admin_enabled" {
  description = "Enable admin user for the Azure Container Registry"
  type        = bool
  default     = false
}

variable "sku" {
  description = "The SKU of the Azure Container Registry"
  type        = string
  default     = "Standard"
}

variable "uami_name" {
  description = "UAMI name"
  type        = string
}

variable "postgres_name" { default = "psqlthreetieraks" }

variable "jenkins_vm_name" { default = "jenkins-controller" }
variable "ssh_public_key" {}
variable "allowed_ips" {
  type    = list(string)
  default = ["*"]
} # ["YOUR_IP/32"]

variable "aks_name" { default = "aks-three-tier" }
variable "aks_node_count" {
  type    = number
  default = 1
}
variable "aks_vm_size" { default = "Standard_B2s" } # or "Standard_B2s" for cheaper POC
variable "aks_version" { default = "1.32.0" }

variable "appgw_name" { default = "appgw-three-tier" }
