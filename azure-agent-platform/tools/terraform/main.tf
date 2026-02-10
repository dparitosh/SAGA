provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = var.prefix
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
}

module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = var.prefix
  subnet_id           = module.network.subnet_id
  ssh_public_key_path = var.ssh_public_key_path
}

# Database Module - Optional / Enable as needed
# module "database" {
#   source              = "./modules/database"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   prefix              = var.prefix
#   admin_password      = var.db_password # Requires handling secure vars
# }
