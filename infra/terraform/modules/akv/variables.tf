variable "akv_name" {
  type        = string
  description = "AKV name"
}

variable "rg" {}
variable "location" {}
variable "tenant_id" {}

variable "db_password" {
  description = "The password for the PostgreSQL Felible Server"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "The username for the PostgreSQL Felible Server"
  type        = string
  sensitive   = true
}
variable "fqdn" {
  type        = string
  description = "Fully Qualified Domain Name of the PostgreSQL Server"
}
