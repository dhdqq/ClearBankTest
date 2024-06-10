variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vm_config" {
  description = "VM configurations for different environments"
  type = map(object({
    resource_group_name = string
    location            = string
    vm_count            = number
    vm_size             = string
    admin_username      = string
    admin_password      = string
  }))
}