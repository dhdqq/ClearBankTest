terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.107.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  env_config = var.vm_config[var.environment]
}

resource "azurerm_resource_group" "rg" {
  count    = local.env_config.vm_count
  name     = "${local.env_config.resource_group_name}-${count.index}"
  location = local.env_config.location

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_virtual_network" "vnet" {
  count               = local.env_config.vm_count
  name                = "vnet-${count.index}"
  address_space       = ["10.0.${count.index}.0/24"]
  location            = azurerm_resource_group.rg[count.index].location
  resource_group_name = azurerm_resource_group.rg[count.index].name
}

resource "azurerm_subnet" "subnet" {
  count                = local.env_config.vm_count
  name                 = "subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.rg[count.index].name
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

resource "azurerm_network_interface" "nic" {
  count               = local.env_config.vm_count
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.rg[count.index].location
  resource_group_name = azurerm_resource_group.rg[count.index].name

  ip_configuration {
    name                          = "ipconfig-${count.index}"
    subnet_id                     = azurerm_subnet.subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "nsg" {
  count               = local.env_config.vm_count
  name                = "nsg-${count.index}"
  location            = azurerm_resource_group.rg[count.index].location
  resource_group_name = azurerm_resource_group.rg[count.index].name

  security_rule {
    name                       = "Allow-SSH-Inbound"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-DNS-HTTP-HTTPS-Outbound"
    priority                   = 1002
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["53", "80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                     = local.env_config.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg[count.index].id
}

resource "azurerm_virtual_machine" "vm" {
  count                 = local.env_config.vm_count
  name                  = "vm-${count.index}"
  location              = azurerm_resource_group.rg[count.index].location
  resource_group_name   = azurerm_resource_group.rg[count.index].name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  vm_size               = local.env_config.vm_size

  storage_os_disk {
    name              = "osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname-${count.index}"
    admin_username = local.env_config.admin_username
    admin_password = local.env_config.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}