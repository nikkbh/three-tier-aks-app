locals {
  suffix = random_id.this.hex
}

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




