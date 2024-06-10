environment = "test"

vm_config = {
  test = {
    resource_group_name = "test-rg"
    location            = "East US"
    vm_count            = 2
    vm_size             = "Standard_B1s"
    admin_username      = "testadmin"
    admin_password      = "P@ssw0rd123!"
  }
}