variable "name" {}
variable "resource_group_name" {}
variable "location" {}
variable "subnet_id" {}
variable "tags" {
  type    = map(string)
  default = {}
}
