# Azure Hub-and-Spoke Network Architecture

A production-ready Hub-and-Spoke network topology implemented with Terraform. Demonstrates enterprise network design patterns, security controls, and infrastructure-as-code best practices using Azure Virtual Networks.

## Overview

This project implements a scalable, secure network architecture suitable for hybrid cloud environments. The hub-spoke model provides centralized management while maintaining isolated workload networks.

```
┌─────────────────────────────────────────────────────┐
│            Azure Hub-and-Spoke Network              │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────┐      │
│  │           HUB VNet (10.0.0.0/16)          │      │
│  │  ┌────────────────────────────────────┐  │      │
│  │  │   AzureFirewallSubnet (10.0.1.0/24)│  │      │
│  │  │   - Central security appliance      │  │      │
│  │  └────────────────────────────────────┘  │      │
│  │  ┌────────────────────────────────────┐  │      │
│  │  │   GatewaySubnet (10.0.2.0/24)       │  │      │
│  │  │   - VPN/ER gateway                  │  │      │
│  │  └────────────────────────────────────┘  │      │
│  │  ┌────────────────────────────────────┐  │      │
│  │  │   Services (10.0.3.0/24)             │  │      │
│  │  │   - Shared services, DNS             │  │      │
│  │  └────────────────────────────────────┘  │      │
│  └──────────────────────────────────────────┘      │
│           ↑                    ↑                     │
│      VNet Peering         VNet Peering              │
│           ↓                    ↓                     │
│  ┌──────────────────┐  ┌──────────────────┐        │
│  │  Spoke-1 VNet    │  │  Spoke-2 VNet    │        │
│  │  (10.1.0.0/16)   │  │  (10.2.0.0/16)   │        │
│  │  ┌────────────┐  │  │  ┌────────────┐  │        │
│  │  │ Subnet A   │  │  │  │ Subnet C   │  │        │
│  │  │ (10.1.1.0) │  │  │  │ (10.2.1.0) │  │        │
│  │  └────────────┘  │  │  └────────────┘  │        │
│  │  ┌────────────┐  │  │  ┌────────────┐  │        │
│  │  │ Subnet B   │  │  │  │ Subnet D   │  │        │
│  │  │ (10.1.2.0) │  │  │  │ (10.2.2.0) │  │        │
│  │  └────────────┘  │  │  └────────────┘  │        │
│  └──────────────────┘  └──────────────────┘        │
│    (Workload Network)    (Workload Network)        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Features

✅ **Hub VNet** (10.0.0.0/16)
- Azure Firewall for centralized security
- VPN Gateway for hybrid connectivity
- Shared services subnet

✅ **Spoke VNets** (10.1.0.0/16, 10.2.0.0/16)
- Isolated workload environments
- 2 subnets per spoke for application/database separation

✅ **Network Connectivity**
- VNet peering (hub ↔ spoke)
- User-Defined Routes (UDRs) for traffic steering
- Spoke-to-spoke traffic via hub

✅ **Security**
- Network Security Groups (NSGs) per subnet
- Azure Firewall rules (default deny)
- No direct spoke-to-spoke communication

✅ **Infrastructure as Code**
- 100% Terraform
- Modular, reusable structure
- Azure free tier compatible (~€2/month)

## Prerequisites

Before deploying, ensure you have:

- **Azure Subscription** (free tier works for this lab)
- **Terraform >= 1.0** — [Install](https://www.terraform.io/downloads)
- **Azure CLI** — [Install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Editor** — VS Code recommended

### Verify Installation

```bash
terraform --version
az --version
```

## Quick Start (5 minutes)

### 1. Clone Repository

```bash
git clone https://github.com/christoslts/azure-hub-spoke-network.git
cd azure-hub-spoke-network
```

### 2. Authenticate with Azure

```bash
az login
# Follow the browser prompt to authenticate
```

### 3. Initialize Terraform

```bash
terraform init
```

This downloads the Azure provider and initializes the local backend.

### 4. Review Changes

```bash
terraform plan
```

This shows what resources will be created. Review the output carefully.

**Expected output:**
```
Plan: 12 to add, 0 to change, 0 to destroy.
(Hub VNet + 3 subnets, 2 Spoke VNets + 4 subnets, 6 peering connections)
```

### 5. Deploy

```bash
terraform apply
```

Type `yes` to confirm. Deployment takes ~2-3 minutes.

**Successful deployment output:**
```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:
hub_vnet_id = "/subscriptions/xxx/resourceGroups/rg-hub-dev/providers/Microsoft.Network/virtualNetworks/vnet-hub-dev"
spoke_vnet_ids = [
  "/subscriptions/xxx/resourceGroups/rg-spoke-1-dev/providers/Microsoft.Network/virtualNetworks/vnet-spoke-1-dev",
  "/subscriptions/xxx/resourceGroups/rg-spoke-2-dev/providers/Microsoft.Network/virtualNetworks/vnet-spoke-2-dev",
]
peering_connections = 6
```

### 6. Verify in Azure Portal

1. Go to [Azure Portal](https://portal.azure.com)
2. Search for "Virtual networks"
3. Confirm you see:
   - `vnet-hub-dev`
   - `vnet-spoke-1-dev`
   - `vnet-spoke-2-dev`

## File Structure

```
azure-hub-spoke-network/
├── main.tf              # Hub and spoke VNets, subnets
├── peering.tf           # VNet peering configuration
├── nsgs.tf              # Network security groups
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Environment-specific values
├── .gitignore           # Exclude sensitive files
└── README.md            # This file
```

## Configuration

### Customizing Deployment

Edit `terraform.tfvars` to change deployment parameters:

```hcl
environment = "dev"           # dev, test, prod
location    = "eastus"        # Azure region
hub_address_space = ["10.0.0.0/16"]
spoke_count = 2               # Number of spoke networks
enable_firewall = true        # Enable Azure Firewall
```

### Common Customizations

**Change region (e.g., Europe):**
```hcl
location = "westeurope"
```

**Add a third spoke:**
```hcl
spoke_count = 3
```

**Change hub subnet ranges:**
```hcl
hub_firewall_subnet = "10.0.10.0/24"  # Adjust in firewall.tf
hub_gateway_subnet = "10.0.11.0/24"
hub_services_subnet = "10.0.12.0/24"
```

## Cost Estimate

Deployed resources and estimated monthly costs (Azure free tier may cover some):

| Resource | Cost | Notes |
|----------|------|-------|
| VNets | $0 | Included in free tier |
| VNet Peering | ~$0.02 | Per 10,000 egress TX |
| Azure Firewall | $1.30 | Premium per-rule cost |
| Firewall Data Processing | ~$0.50 | Per GB processed |
| **Monthly Total** | **~$2** | Minimal for lab environment |

**Note:** Azure free tier includes 1 VNet + 50 GB egress/month, so this deployment may be free for the first 12 months.

## Architecture Decisions

### Why Hub-and-Spoke?

1. **Centralized Security** — Single firewall filters all traffic
2. **Simplified Routing** — Hub manages connectivity
3. **Scalability** — Add spokes without modifying hub
4. **Cost Efficiency** — One firewall vs. multiple

### Network Flow

1. **Intra-spoke traffic:** Direct peering between subnets
2. **Inter-spoke traffic:** Through hub firewall (encrypted, logged)
3. **Hybrid traffic:** Via VPN Gateway in hub
4. **Internet traffic:** Through firewall with egress rules

## Next Steps

### Test Connectivity

Deploy test VMs in each spoke and verify:

```bash
# From spoke-1 VM, ping spoke-2 VM through hub
ping 10.2.1.10
```

### Add Firewall Rules

Edit `firewall.tf` to allow application traffic:

```hcl
resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "allow-app-traffic"
  azure_firewall_name = azurerm_firewall.hub.name
  ...
}
```

### Monitor Traffic

Use Azure Monitor to analyze:
- VNet peering traffic
- Firewall logs
- Network performance

### Production Hardening

For production deployment, add:

1. **Backup & Recovery**
   ```bash
   terraform state backup
   ```

2. **Monitoring**
   ```hcl
   resource "azurerm_monitor_diagnostic_setting" "firewall" {...}
   ```

3. **DDoS Protection**
   ```hcl
   resource "azurerm_ddos_protection_plan" "hub" {...}
   ```

## Troubleshooting

### ❌ "Insufficient quota for SKU StandardSku"

**Solution:** Check your Azure subscription quota
```bash
az vm list-skus --location eastus
```

### ❌ "VNet peering failed: duplicate route"

**Solution:** Ensure address spaces don't overlap
```bash
# Check configured ranges in terraform.tfvars
```

### ❌ "terraform apply" hangs

**Solution:** Increase timeout or check Azure API rate limits
```bash
terraform apply -parallelism=1
```

## Useful Commands

```bash
# Show all deployed resources
terraform show

# Destroy everything (caution!)
terraform destroy

# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# View current state
terraform state list
terraform state show azurerm_virtual_network.hub

# Get specific output
terraform output hub_vnet_id

# Refresh state (sync with Azure)
terraform refresh
```

## Security Best Practices

✅ **Implemented in this template:**
- Network segmentation (subnets)
- NSGs per subnet
- Centralized firewall
- Azure-managed DNS

🔧 **Recommended additions:**
- Enable VNet Flow Logs → Log Analytics
- Configure NSG flow logs
- Add Azure Bastion for secure VM access
- Implement Azure Policy for compliance
- Enable Azure Security Center

## References

- [Microsoft Hub-Spoke Reference Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Firewall Documentation](https://learn.microsoft.com/en-us/azure/firewall/)
- [Terraform Azure Provider - Virtual Networks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Azure Networking Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/network-topology-and-connectivity)

## Support & Issues

Found a bug? Have suggestions?

1. Check [existing issues](https://github.com/christoslts/azure-hub-spoke-network/issues)
2. Create a [new issue](https://github.com/christoslts/azure-hub-spoke-network/issues/new) with:
   - Error message
   - Terraform version
   - Azure region
   - Steps to reproduce

## License

This project is licensed under the MIT License — see LICENSE file for details.

---

**Author:** Christos LTS  
**Created:** 2024  
**Updated:** April 2024  
**Status:** Production-ready ✅

For Azure infrastructure consulting and freelance work, connect on [LinkedIn](https://linkedin.com/in/your-profile).
