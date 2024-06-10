environment = "staging"

vm_config = {
  staging = {
    resource_group_name = "staging-rg"
    location            = "East US"
    vm_count            = 2
    vm_size             = "Standard_B1s"
    admin_username      = "stagingadmin"
    admin_password      = "P@ssw0rd123!"
  }
}