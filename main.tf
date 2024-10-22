terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.43.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "var.resource_group_name"
    storage_account_name = "terraformcodeforgit"
    container_name       = "tfstatefile"
    key                  = "terraform.tfstate"
  }
}


#terraform {


#terraform {
 # backend "azurerm" {
#    resource_group_name  = "StorageAccount-ResourceGroup"
 #   storage_account_name = "abcd1234"
 #   container_name       = "tfstate"
 #   key                  = "prod.terraform.tfstate"
 # }
#}

provider "azurerm" {
  features {}
}

# Data to get the current Service Principal configuration
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes     = var.allowed_ssh_ip_address
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.prefix}-nic-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip[count.index].id
  }
}

# Public IP
resource "azurerm_public_ip" "pubip" {
  count               = var.vm_count
  name                = "${var.prefix}-public-ip-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Key Vault for managing sensitive information
resource "azurerm_key_vault" "example" {
  name                = "${var.prefix}-keyvault"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = ["get", "create", "list", "delete", "update"]
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "${var.prefix}-vm-${count.index}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = "Standard_B1s"
  admin_username        = var.vm_admin_username
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

output "public_ip_address_generated" {
  value = azurerm_public_ip.pubip
}
