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

############################
# VIRTUAL NETWORK & RESOURCE GROUP
############################

resource "azurerm_resource_group" "rg-westeu-cn" {
  name     = "rg-${var.location_code}-${var.team_name}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet-westeu-cn" {
  name                = "vnet-${var.location_code}-${var.team_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  address_space       = ["10.0.0.0/16"]
}

############################
# SECURITY GROUP
############################

resource "azurerm_network_security_group" "nsg-westeu-cn" {
  name                = "nsg-${var.location_code}-${var.team_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
}

############################
# PUBLIC IPs
############################

resource "azurerm_public_ip" "pip-westeu-cn" {
  name                = "pip-${var.location_code}-${var.team_name}"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip-westeu-cn-bastion" {
  name                = "pip-${var.location_code}-${var.team_name}-bastion"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip-westeu-cn-nat" {
  name                = "pip-${var.location_code}-${var.team_name}-nat"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

############################
# NAT GATEWAY
############################

resource "azurerm_nat_gateway" "ngw-westeu-cn" {
  name                    = "ngw-${var.location_code}-${var.team_name}"
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
  name                = "bastion-${var.location_code}-${var.team_name}"
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
  name                 = "snet-${var.location_code}-${var.team_name}-agw"
  resource_group_name  = azurerm_resource_group.rg-westeu-cn.name
  virtual_network_name = azurerm_virtual_network.vnet-westeu-cn.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "snet-westeu-cn-web" {
  name                 = "snet-${var.location_code}-${var.team_name}-web"
  resource_group_name  = azurerm_resource_group.rg-westeu-cn.name
  virtual_network_name = azurerm_virtual_network.vnet-westeu-cn.name
  address_prefixes = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "snet-westeu-cn-app" {
  name                 = "snet-${var.location_code}-${var.team_name}-app"
  resource_group_name  = azurerm_resource_group.rg-westeu-cn.name
  virtual_network_name = azurerm_virtual_network.vnet-westeu-cn.name
  address_prefixes = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "snet-westeu-cn-data" {
  name                 = "snet-${var.location_code}-${var.team_name}-data"
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

############################
# LINUX VM / SCALE SET
############################

resource "azurerm_linux_virtual_machine_scale_set" "vmss-westeu-cn" {
  name                = "vmss-${var.location_code}-${var.team_name}"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location
  sku                 = "Standard_F2"
  instances           = 3
  admin_username      = "adminuser"
  custom_data         = filebase64("resources/web-cloud-init.sh")
  network_interface {
    name	= "nic-${var.location_code}-${var.team_name}"
	primary	= true
	
	ip_configuration {
		name	= "internal"
		primary	= true
		subnet_id = azurerm_subnet.snet-westeu-cn-web.id
		application_gateway_backend_address_pool_ids = [azurerm_application_gateway.agw.backend_address_pool[0].id]
	}
  }

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

resource azurerm_monitor_autoscale_setting "mas-westeu-cn" {
  name = "mas-${var.location_code}-${var.team_name}-web"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location = var.location
  target_resource_id = azurerm_linux_virtual_machine_scale_set.vmss-westeu-cn.id

  profile {
    name = "default"

    capacity {
      default = 3
      minimum = 3
      maximum = 6
    }
  }
}

############################
# DNS ZONE & RECORDS
############################

data azurerm_dns_zone parent {
  name = "azure.msgoat.eu"
}

# create a dedicated DNS zone to manage all DNS records of this solution
resource azurerm_dns_zone dns-zone-westeu-cn {
  name = "${var.team_name}.azure.msgoat.eu"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
}

# add a DNS NS record with the solution nameserver to the parent DNS zone
resource azurerm_dns_ns_record child {
  name = var.team_name
  zone_name = data.azurerm_dns_zone.parent.name
  resource_group_name = data.azurerm_dns_zone.parent.resource_group_name
  ttl = 300
  records = azurerm_dns_zone.dns-zone-westeu-cn.name_servers
}

# create a DNS A record for all incoming "web.*" requests pointing to the loadbalancer / application gateway
resource azurerm_dns_a_record web {
  name = "web"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  zone_name = azurerm_dns_zone.dns-zone-westeu-cn.name
  ttl = 300
  target_resource_id = azurerm_public_ip.pip-westeu-cn.id
}

############################
# APPLICATION GATEWAY
############################
resource "azurerm_application_gateway" "agw" {
  name                = "agw-${var.location_code}-${var.team_name}"
  resource_group_name = azurerm_resource_group.rg-westeu-cn.name
  location            = var.location

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gw-ip-cfg-${var.location_code}-${var.team_name}"
    subnet_id = azurerm_subnet.snet-westeu-cn-agw.id
  }

  frontend_port {
    name = "${azurerm_virtual_network.vnet-westeu-cn.name}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${azurerm_virtual_network.vnet-westeu-cn.name}-feip"
    public_ip_address_id = azurerm_public_ip.pip-westeu-cn.id
  }

  backend_address_pool {
    name = "${azurerm_virtual_network.vnet-westeu-cn.name}-beap"
  }

  backend_http_settings {
    name                  = "${azurerm_virtual_network.vnet-westeu-cn.name}-be-htst"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "${azurerm_virtual_network.vnet-westeu-cn.name}-httplstn"
    frontend_ip_configuration_name = "${azurerm_virtual_network.vnet-westeu-cn.name}-feip"
    frontend_port_name             = "${azurerm_virtual_network.vnet-westeu-cn.name}-feport"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${azurerm_virtual_network.vnet-westeu-cn.name}-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = "${azurerm_virtual_network.vnet-westeu-cn.name}-httplstn"
    backend_address_pool_name  = "${azurerm_virtual_network.vnet-westeu-cn.name}-beap"
    backend_http_settings_name = "${azurerm_virtual_network.vnet-westeu-cn.name}-be-htst"
  }
}