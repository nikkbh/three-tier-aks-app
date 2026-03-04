variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "dns_prefix" {}
variable "kubernetes_version" { default = "1.29.0" } # or what Azure supports now
variable "node_count" {
  type    = number
  default = 1
}
variable "vm_size" { default = "Standard_B2ms" } # adjust if you want cheaper
variable "subnet_id" {}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "service_cidr" { default = "10.10.0.0/16" }
variable "dns_service_ip" { default = "10.10.0.10" }
variable "appgw_id" {
  description = "Resource ID of the Application Gateway for AGIC"
}

variable "akv_name" {}
variable "tenant_id" {}
variable "subscription_id" {}
