terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group for Hub
resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "hub-spoke-network"
    ManagedBy   = "Terraform"
  }
}

# ========== HUB VNET ==========

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}"
  address_space       = var.hub_address_space
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  tags = {
    Environment = var.environment
    Role        = "Hub"
  }
}

# Hub Subnet 1: Azure Firewall (required name)
resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Hub Subnet 2: VPN/ExpressRoute Gateway
resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Hub Subnet 3: Shared Services (DNS, management)
resource "azurerm_subnet" "hub_services" {
  name                 = "Services"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}

# ========== SPOKE VNETS ==========

# Create resource groups for spokes
resource "azurerm_resource_group" "spoke" {
  count    = var.spoke_count
  name     = "rg-spoke-${count.index + 1}-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "hub-spoke-network"
    SpokeNumber = count.index + 1
  }
}

# Create spoke VNets
resource "azurerm_virtual_network" "spoke" {
  count               = var.spoke_count
  name                = "vnet-spoke-${count.index + 1}-${var.environment}"
  address_space       = ["10.${count.index + 1}.0.0/16"]
  location            = azurerm_resource_group.spoke[count.index].location
  resource_group_name = azurerm_resource_group.spoke[count.index].name

  tags = {
    Environment = var.environment
    Role        = "Spoke"
    SpokeNumber = count.index + 1
  }
}

# Create subnets for each spoke
resource "azurerm_subnet" "spoke_subnet_1" {
  count                = var.spoke_count
  name                 = "Subnet-A"
  resource_group_name  = azurerm_resource_group.spoke[count.index].name
  virtual_network_name = azurerm_virtual_network.spoke[count.index].name
  address_prefixes     = ["10.${count.index + 1}.1.0/24"]
}

resource "azurerm_subnet" "spoke_subnet_2" {
  count                = var.spoke_count
  name                 = "Subnet-B"
  resource_group_name  = azurerm_resource_group.spoke[count.index].name
  virtual_network_name = azurerm_virtual_network.spoke[count.index].name
  address_prefixes     = ["10.${count.index + 1}.2.0/24"]
}

# ========== NETWORK SECURITY GROUPS ==========

# NSG for Hub Firewall Subnet
resource "azurerm_network_security_group" "hub_firewall_nsg" {
  name                = "nsg-hub-firewall-${var.environment}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
  }
}

# NSG for Hub Services Subnet
resource "azurerm_network_security_group" "hub_services_nsg" {
  name                = "nsg-hub-services-${var.environment}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  security_rule {
    name                       = "AllowFromVNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyInternet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
  }
}

# NSGs for Spoke Subnets
resource "azurerm_network_security_group" "spoke_nsg" {
  count               = var.spoke_count
  name                = "nsg-spoke-${count.index + 1}-${var.environment}"
  location            = azurerm_resource_group.spoke[count.index].location
  resource_group_name = azurerm_resource_group.spoke[count.index].name

  security_rule {
    name                       = "AllowFromVNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowHttps"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    SpokeNumber = count.index + 1
  }
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "hub_firewall" {
  subnet_id                 = azurerm_subnet.hub_firewall.id
  network_security_group_id = azurerm_network_security_group.hub_firewall_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "hub_services" {
  subnet_id                 = azurerm_subnet.hub_services.id
  network_security_group_id = azurerm_network_security_group.hub_services_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_subnet_1" {
  count                     = var.spoke_count
  subnet_id                 = azurerm_subnet.spoke_subnet_1[count.index].id
  network_security_group_id = azurerm_network_security_group.spoke_nsg[count.index].id
}

resource "azurerm_subnet_network_security_group_association" "spoke_subnet_2" {
  count                     = var.spoke_count
  subnet_id                 = azurerm_subnet.spoke_subnet_2[count.index].id
  network_security_group_id = azurerm_network_security_group.spoke_nsg[count.index].id
}
