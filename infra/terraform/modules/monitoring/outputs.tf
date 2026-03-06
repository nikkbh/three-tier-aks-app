output "grafana_url" {
  value = azurerm_monitor_grafana_workspace.aks_grafana.endpoint
}

output "workspace_id" {
  value = azurerm_monitor_managed_prometheus_workspace.aks_monitoring.id
}
