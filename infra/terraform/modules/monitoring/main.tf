# 1. Create Managed Prometheus workspace
resource "azurerm_monitor_managed_prometheus_workspace" "aks_monitoring" {
  name                = "amp-${var.cluster_name}"
  resource_group_name = var.rg
  location            = var.location
}

# 2. Create Managed Grafana workspace
resource "azurerm_monitor_grafana_workspace" "aks_grafana" {
  name                = "grafana-${var.cluster_name}"
  resource_group_name = var.rg
  location            = var.location

  grafana_version = "10.4.7" # or latest
}

# 4. Role assignment for Grafana to query AMP
resource "azurerm_monitoring_prometheus_workspace_access_policy" "grafana_policy" {
  prometheus_workspace_id = azurerm_monitor_managed_prometheus_workspace.aks_monitoring.id
  resource_group_name     = var.rg

  access_mode = "Write"
  identity_id = azurerm_monitor_grafana_workspace.aks_grafana.identity[0].principal_id
}
