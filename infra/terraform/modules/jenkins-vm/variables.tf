variable "vm_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "public_subnet_id" {}
variable "uami_ids" {
  type        = list(string)
  description = "List of UAMI IDs"
}
variable "ssh_public_key" {}
variable "allowed_ssh_ips" {
  type    = list(string)
  default = ["*"]
} # Restrict!
variable "tags" { default = {} }
