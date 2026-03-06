locals {
  suffix = random_id.this.hex
}

data "azurerm_private_dns_zone" "pg-dns-zone" {
  name                = "aksapp.postgres.database.azure.com" # or your exact zone name
  resource_group_name = "rg-three-tier-aks"                  # DNS zone RG
}

data "azurerm_virtual_network" "aks-vnet" {
  name                = "vnet-three-tier-app"
  resource_group_name = "rg-three-tier-aks"
}

data "azurerm_kubernetes_cluster" "aks-data" {
  name                = "aks-three-tier"
  resource_group_name = "rg-three-tier-aks"
}

data "azurerm_client_config" "current" {}

resource "random_id" "this" { byte_length = 4 }

module "rg" {
  source   = "../modules/resource-group"
  name     = var.rg
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source    = "../modules/virtual-network"
  rg        = module.rg.name
  location  = var.location
  vnet_name = var.vnet_name
}

module "public-subnet" {
  source           = "../modules/subnet"
  rg               = module.rg.name
  vnet_name        = module.vnet.vnet_name
  subnet_name      = var.public_subnet_name
  address_prefixes = ["10.0.1.0/24"]
}

module "appgw-subnet" {
  source           = "../modules/subnet"
  rg               = module.rg.name
  vnet_name        = module.vnet.vnet_name
  subnet_name      = "${var.public_subnet_name}-appgw"
  address_prefixes = ["10.0.4.0/24"] # example; ensure non-overlap
}

module "aks-subnet" {
  source           = "../modules/subnet"
  rg               = module.rg.name
  vnet_name        = module.vnet.vnet_name
  subnet_name      = "${var.private_subnet_name}-aks"
  address_prefixes = ["10.0.2.0/24"]
}

module "postgres-subnet" {
  source           = "../modules/subnet"
  rg               = module.rg.name
  vnet_name        = module.vnet.vnet_name
  subnet_name      = "${var.private_subnet_name}-postgres"
  address_prefixes = ["10.0.3.0/24"]

  delegations = [
    {
      name         = "postgres-delegation"
      service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  ]
}

module "uami-jenkins" {
  source   = "../modules/user-assigned-identity"
  name     = var.uami_name
  rg_name  = module.rg.name
  location = var.location
  tags     = var.tags
}

module "acr" {
  source        = "../modules/azure-container-registry"
  name          = var.acr_name
  rg_name       = module.rg.name
  tags          = var.tags
  location      = var.location
  sku           = var.sku
  admin_enabled = var.admin_enabled
}

module "uami-pull-role-assignment" {
  source       = "../modules/role-assignment"
  principal_id = module.uami-jenkins.user_assigned_identity_principal_id
  role_name    = "AcrPull"
  scope_id     = module.acr.acr_id
}

module "uami-push-role-assignment" {
  source       = "../modules/role-assignment"
  principal_id = module.uami-jenkins.user_assigned_identity_principal_id
  role_name    = "AcrPush"
  scope_id     = module.acr.acr_id
}

module "postgres" {
  source              = "../modules/postgresql-flexible-server"
  name                = var.postgres_name
  resource_group_name = module.rg.name
  location            = var.location
  private_subnet_id   = module.postgres-subnet.subnet_id
  tags                = var.tags
  extension_values    = "uuid-ossp"
  aks_vnet_id         = data.azurerm_virtual_network.aks-vnet.id
  dns_zone_name       = data.azurerm_private_dns_zone.pg-dns-zone.name
  dns_zone_rg         = data.azurerm_private_dns_zone.pg-dns-zone.resource_group_name
}

module "jenkins-vm" {
  source              = "../modules/jenkins-vm"
  vm_name             = var.jenkins_vm_name
  resource_group_name = module.rg.name
  location            = var.location
  public_subnet_id    = module.public-subnet.subnet_id
  uami_ids            = [module.uami-jenkins.user_assigned_identity_id]
  ssh_public_key      = var.ssh_public_key
  allowed_ssh_ips     = var.allowed_ips
  tags                = var.tags
}

module "akv" {
  source      = "../modules/akv"
  akv_name    = "kv-three-tier-aks"
  location    = var.location
  rg          = module.rg.name
  tenant_id   = data.azurerm_client_config.current.tenant_id
  db_username = var.db_username
  db_password = var.db_password
  fqdn        = module.postgres.fqdn
}

module "aks" {
  source              = "../modules/aks-cluster"
  name                = var.aks_name
  location            = var.location
  resource_group_name = module.rg.name
  dns_prefix          = "${var.aks_name}-dns"

  subnet_id = module.aks-subnet.subnet_id

  node_count         = var.aks_node_count
  vm_size            = var.aks_vm_size
  kubernetes_version = var.aks_version
  appgw_id           = module.appgw.id
  tags               = var.tags

  akv_name        = module.akv.name
  subscription_id = data.azurerm_client_config.current.subscription_id
  tenant_id       = data.azurerm_client_config.current.tenant_id

  service_cidr   = "10.10.0.0/16"
  dns_service_ip = "10.10.0.10"
}

module "aks-acr-role-assignment" {
  source       = "../modules/role-assignment"
  principal_id = module.aks.identity_principal_id
  role_name    = "AcrPull"
  scope_id     = module.acr.acr_id
}

module "appgw" {
  source              = "../modules/app-gateway"
  name                = var.appgw_name
  resource_group_name = module.rg.name
  location            = var.location
  subnet_id           = module.appgw-subnet.subnet_id
  tags                = var.tags
}

module "aks_acr_pull_role_assignment" {
  source       = "../modules/role-assignment"
  scope_id     = module.acr.acr_id
  role_name    = "AcrPull"
  principal_id = data.azurerm_kubernetes_cluster.aks-data.kubelet_identity[0].object_id
}

module "aks_kv_secrets_user_role_assignment" {
  source       = "../modules/role-assignment"
  role_name    = "Key Vault Secrets User"
  principal_id = data.azurerm_kubernetes_cluster.aks-data.kubelet_identity[0].object_id
  scope_id     = module.akv.id
}

module "aks_kv_identity_secrets_user_role_assignment" {
  source       = "../modules/role-assignment"
  role_name    = "Key Vault Secrets User"
  principal_id = module.aks.pid
  scope_id     = module.akv.id
}

module "uami-github-cicd" {
  source   = "../modules/user-assigned-identity"
  name     = "UAMI_GH_CICD"
  location = var.location
  rg_name  = module.rg.name
  tags     = var.tags
}

module "gh_federated_credential_cicd" {
  source                             = "../modules/federated-identity-credential"
  federated_identity_credential_name = "${var.github_organization_target}-${var.github_repository}"
  rg_name                            = module.rg.name
  user_assigned_identity_id          = module.uami-github-cicd.user_assigned_identity_id
  subject                            = "repo:${var.github_organization_target}/${var.github_repository}:ref:refs/heads/main"
  audience_name                      = local.default_audience_name
  issuer_url                         = local.github_issuer_url
}

module "uami_github_acr_push_user_role_assignment" {
  source       = "../modules/role-assignment"
  role_name    = "AcrPush"
  principal_id = module.uami-github-cicd.user_assigned_identity_principal_id
  scope_id     = module.acr.acr_id
}

module "uami_github_aks_user_role_assignment" {
  source       = "../modules/role-assignment"
  role_name    = "Azure Kubernetes Service Cluster Admin Role"
  principal_id = module.uami-github-cicd.user_assigned_identity_principal_id
  scope_id     = module.aks.id
}

module "uami_github_aks_cluster_user_role_assignment" {
  source       = "../modules/role-assignment"
  role_name    = "Azure Kubernetes Service Cluster User Role"
  principal_id = module.uami-github-cicd.user_assigned_identity_principal_id
  scope_id     = module.aks.id
}








