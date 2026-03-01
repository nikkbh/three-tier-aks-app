module "tf-resource-group" {
  source   = "../modules/resource-group"
  name     = var.tf_state_rg_name
  location = var.location
  tags     = var.tags
}

module "tf-state-storage" {
  source                   = "../modules/tfstate-storage"
  storage_account_name     = var.storage_account_name
  resource_group_name      = module.tf-resource-group.name
  location                 = var.location
  tags                     = var.tags
  account_replication_type = var.account_replication_type
  account_tier             = var.account_tier
  container_name           = var.container_name
}
