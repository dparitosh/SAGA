resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.prefix}-psql-server"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "13"
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  zone                   = "1"

  storage_mb   = 32768
  sku_name     = "B_Standard_B1ms"
  
  backup_retention_days  = 7
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "${var.prefix}-db"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_access" {
  name             = "allow_all_ips" # Only for demo purposes
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

output "database_id" {
    value = azurerm_postgresql_flexible_server_database.main.id
}

output "server_fqdn" {
    value = azurerm_postgresql_flexible_server.main.fqdn
}
