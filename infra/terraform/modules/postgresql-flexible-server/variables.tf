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

