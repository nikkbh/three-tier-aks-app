output "postgres_fqdn" {
  value = module.postgres.fqdn
}

output "postgres_admin_password" {
  value     = module.postgres.admin_password
  sensitive = true
}

output "acr_login_server" {
  value = module.acr.login_server
}
