output "public_ip" { value = azurerm_public_ip.jenkins.ip_address }
output "ssh_command" { value = "ssh -i ~/.ssh/id_rsa jenkins@${azurerm_public_ip.jenkins.ip_address}" }
