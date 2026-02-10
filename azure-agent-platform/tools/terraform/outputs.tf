output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.main.id
}
