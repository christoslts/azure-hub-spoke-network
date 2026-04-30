variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(dev|test|prod)$", var.environment))
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"

  validation {
    condition     = can(regex("^[a-z]+$", var.location))
    error_message = "Location must be a valid Azure region."
  }
}

variable "hub_address_space" {
  description = "Address space for Hub VNet (CIDR notation)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_count" {
  description = "Number of spoke VNets to create"
  type        = number
  default     = 2

  validation {
    condition     = var.spoke_count >= 1 && var.spoke_count <= 5
    error_message = "Spoke count must be between 1 and 5."
  }
}

variable "enable_firewall" {
  description = "Enable Azure Firewall in hub subnet"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "hub-spoke-network"
  }
}
