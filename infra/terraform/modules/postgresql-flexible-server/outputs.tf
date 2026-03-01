output "fqdn" { value = azurerm_postgresql_flexible_server.this.fqdn }
output "admin_password" {
  value     = random_password.admin.result
  sensitive = true
}
output "id" { value = azurerm_postgresql_flexible_server.this.id }
