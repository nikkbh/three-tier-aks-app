variable "resource_group_location" {
  description = "The location of the resource group in which the resources will be created."
}

variable "resource_group_id" {
  description = "The ID of the resource group in which the resources will be created."
}

variable "client_id" {
  description = "Azure Client ID for OIDC authentication"
  type        = string
  default     = ""
}

variable "tenant_id" {
  description = "Azure Tenant ID for OIDC authentication"
  type        = string
  default     = ""
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "azure_object_id" {
  description = "Azure Object ID for OIDC authentication"
  type        = string
}
