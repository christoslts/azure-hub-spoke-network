# Azure Hub-and-Spoke Network - Terraform Variables
# Customize these values for your deployment

environment = "dev"
location    = "eastus"
spoke_count = 2

# Hub VNet address space
hub_address_space = ["10.0.0.0/16"]

# Enable Azure Firewall (adds ~€1.30/month cost)
enable_firewall = false

# Additional resource tags
tags = {
  ManagedBy   = "Terraform"
  Project     = "hub-spoke-network"
  CreatedBy   = "Christos"
  CostCenter  = "Infrastructure"
}
