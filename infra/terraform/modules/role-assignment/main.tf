resource "azurerm_role_assignment" "role" {
  principal_id         = var.principal_id
  role_definition_name = var.role_name
  scope                = var.scope_id
}
