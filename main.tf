terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.35.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-westeu-cn" {
  name     = "rg-westeu-cn"
  location = var.location
}

resource "azurerm_network_security_group" "nsg-westeu-cn" {
  name                = "nsg-westeu-cn"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
}

############################
# PUBLIC IPs
############################

resource "azurerm_public_ip" "pip-westeu-cn" {
  name                = "pip-westeu-cn"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pip-westeu-cn-bastion" {
  name                = "pip-westeu-cn-bastion"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pip-westeu-cn-nat" {
  name                = "pip-westeu-cn-nat"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location
  allocation_method   = "Static"
}

############################
# NAT GATEWAY
############################

resource "azurerm_nat_gateway" "ngw-westeu-cn" {
  name                    = "ngw-westeu-cn"
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg-westeu-cn.name
}

resource "azurerm_nat_gateway_public_ip_association" "ngwipa-westeu-cn" {
  nat_gateway_id       = azurerm_nat_gateway.ngw-westeu-cn.id
  public_ip_address_id = azurerm_public_ip.pip-westeu-cn-nat.id
}

############################
# BASTION SERVICE/HOST
############################

resource "azurerm_bastion_host" "bastion-westeu-cn" {
  name                = "bastion-westeu-cn"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.snet-westeu-cn-bastion.id
    public_ip_address_id = azurerm_public_ip.pip-westeu-cn-bastion.id
  }
}

############################
# SUBNETS
############################

resource "azurerm_subnet" "snet-westeu-cn-bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg-westeu-cn.name
  virtual_network_name = azurerm_virtual_network.vnet-westeu-cn.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "snet-westeu-cn-agw" {
  name                 = "snet-westeu-cn-agw"
  resource_group_name  = azurerm_resource_group.rg-westeu-cn.name
  virtual_network_name = azurerm_virtual_network.vnet-westeu-cn.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "snet-westeu-cn-web" {
  name                 = "snet-westeu-cn-web"
  resource_group_name  = azurerm_resource_group.rg-westeu-cn.name
  virtual_network_name = azurerm_virtual_network.vnet-westeu-cn.name
  address_prefixes = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "snet-westeu-cn-app" {
  name                 = "snet-westeu-cn-app"
  resource_group_name  = azurerm_resource_group.rg-westeu-cn.name
  virtual_network_name = azurerm_virtual_network.vnet-westeu-cn.name
  address_prefixes = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "snet-westeu-cn-data" {
  name                 = "snet-westeu-cn-data"
  resource_group_name  = azurerm_resource_group.rg-westeu-cn.name
  virtual_network_name = azurerm_virtual_network.vnet-westeu-cn.name
  address_prefixes = ["10.0.5.0/24"]
}

############################
# SUBNET SEC GROUP ASSOCIATION
############################

resource "azurerm_subnet_network_security_group_association" "sga-westeu-cn-web" {
  subnet_id                 = azurerm_subnet.snet-westeu-cn-web.id
  network_security_group_id = azurerm_network_security_group.nsg-westeu-cn.id
}

resource "azurerm_subnet_network_security_group_association" "sga-westeu-cn-app" {
  subnet_id                 = azurerm_subnet.snet-westeu-cn-app.id
  network_security_group_id = azurerm_network_security_group.nsg-westeu-cn.id
}

resource "azurerm_subnet_network_security_group_association" "sga-westeu-cn-data" {
  subnet_id                 = azurerm_subnet.snet-westeu-cn-data.id
  network_security_group_id = azurerm_network_security_group.nsg-westeu-cn.id
}

############################
# SUBNET NAT GW ASSOCIATION
############################

resource "azurerm_subnet_nat_gateway_association" "ngwa-westeu-cn-web" {
  subnet_id      = azurerm_subnet.snet-westeu-cn-web.id
  nat_gateway_id = azurerm_nat_gateway.ngw-westeu-cn.id
}

resource "azurerm_subnet_nat_gateway_association" "ngwa-westeu-cn-app" {
  subnet_id      = azurerm_subnet.snet-westeu-cn-app.id
  nat_gateway_id = azurerm_nat_gateway.ngw-westeu-cn.id
}

resource "azurerm_subnet_nat_gateway_association" "ngwa-westeu-cn-data" {
  subnet_id      = azurerm_subnet.snet-westeu-cn-data.id
  nat_gateway_id = azurerm_nat_gateway.ngw-westeu-cn.id
}

resource "azurerm_virtual_network" "vnet-westeu-cn" {
  name                = "vnet-westeu-cn"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}


############################
# LINUX VM
############################

resource "azurerm_network_interface" "nic-westeu-cn" {
  name                = "nic-westeu-cn"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-westeu-cn-web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm-westeu-cn-01" {
  name                = "vm-westeu-cn-01"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic-westeu-cn.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/cn-azure-rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}