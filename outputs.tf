output "hub_resource_group_name" {
  description = "Name of the hub resource group"
  value       = azurerm_resource_group.hub.name
}

output "hub_vnet_id" {
  description = "Hub VNet resource ID"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Hub VNet name"
  value       = azurerm_virtual_network.hub.name
}

output "hub_subnets" {
  description = "Hub subnet names and address prefixes"
  value = {
    firewall = {
      name             = azurerm_subnet.hub_firewall.name
      address_prefix   = azurerm_subnet.hub_firewall.address_prefixes[0]
      id               = azurerm_subnet.hub_firewall.id
    }
    gateway = {
      name             = azurerm_subnet.hub_gateway.name
      address_prefix   = azurerm_subnet.hub_gateway.address_prefixes[0]
      id               = azurerm_subnet.hub_gateway.id
    }
    services = {
      name             = azurerm_subnet.hub_services.name
      address_prefix   = azurerm_subnet.hub_services.address_prefixes[0]
      id               = azurerm_subnet.hub_services.id
    }
  }
}

output "spoke_vnets" {
  description = "Details of all spoke VNets"
  value = {
    for i, vnet in azurerm_virtual_network.spoke : "spoke-${i + 1}" => {
      id              = vnet.id
      name            = vnet.name
      address_space   = vnet.address_space[0]
      resource_group  = azurerm_resource_group.spoke[i].name
    }
  }
}

output "spoke_resource_groups" {
  description = "Spoke resource group names"
  value = [
    for rg in azurerm_resource_group.spoke : rg.name
  ]
}

output "peering_connections" {
  description = "Hub-to-spoke peering connection details"
  value = {
    hub_to_spoke = [
      for peer in azurerm_virtual_network_peering.hub_to_spoke : {
        name         = peer.name
        peer_state   = peer.peering_state
      }
    ]
    spoke_to_hub = [
      for peer in azurerm_virtual_network_peering.spoke_to_hub : {
        name         = peer.name
        peer_state   = peer.peering_state
      }
    ]
  }
}

output "nsgs" {
  description = "Network Security Groups created"
  value = {
    hub_firewall = azurerm_network_security_group.hub_firewall_nsg.id
    hub_services = azurerm_network_security_group.hub_services_nsg.id
    spoke_nsgs   = [for nsg in azurerm_network_security_group.spoke_nsg : nsg.id]
  }
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    hub_vnet_created      = azurerm_virtual_network.hub.name
    spoke_vnets_created   = var.spoke_count
    peering_connections   = var.spoke_count * 2
    subnets_total         = 3 + (var.spoke_count * 2)
    nsgs_created          = 2 + var.spoke_count
  }
}
