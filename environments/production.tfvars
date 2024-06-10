environment = "production"

vm_config = {
  production = {
    resource_group_name = "production-rg"
    location            = "East US"
    vm_count            = 2
    vm_size             = "Standard_B1s"
    admin_username      = "prodadmin"
    admin_password      = "P@ssw0rd123!"
  }
}