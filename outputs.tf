output "vm_ids" {
  value = azurerm_virtual_machine.vm[*].id
}