# ========== HUB TO SPOKE PEERING ==========

# Hub initiates peering to each spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  count                        = var.spoke_count
  name                         = "peer-hub-to-spoke-${count.index + 1}"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke[count.index].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  depends_on = [azurerm_virtual_network.hub]
}

# ========== SPOKE TO HUB PEERING ==========

# Each spoke initiates peering back to hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count                        = var.spoke_count
  name                         = "peer-spoke-${count.index + 1}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke[count.index].name
  virtual_network_name         = azurerm_virtual_network.spoke[count.index].name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [azurerm_virtual_network.spoke]
}

# ========== USER-DEFINED ROUTES (Optional: for advanced routing) ==========

# Route table for spoke subnets to route traffic through hub firewall
resource "azurerm_route_table" "spoke_route_table" {
  count               = var.spoke_count
  name                = "rt-spoke-${count.index + 1}-${var.environment}"
  location            = azurerm_resource_group.spoke[count.index].location
  resource_group_name = azurerm_resource_group.spoke[count.index].name

  tags = {
    Environment = var.environment
    SpokeNumber = count.index + 1
  }
}

# Routes for spoke to spoke traffic (force through hub)
# Note: These are example routes. Uncomment when you deploy Azure Firewall with an IP
/*
resource "azurerm_route" "spoke_to_spoke" {
  count                  = var.spoke_count > 1 ? var.spoke_count : 0
  name                   = "route-spoke-${count.index + 1}-to-others"
  resource_group_name    = azurerm_resource_group.spoke[count.index].name
  route_table_name       = azurerm_route_table.spoke_route_table[count.index].name
  address_prefix         = "10.0.0.0/8"  # All Azure internal traffic
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

# Default route to Internet through hub firewall
resource "azurerm_route" "spoke_to_internet" {
  count              = var.spoke_count
  name               = "route-spoke-${count.index + 1}-to-internet"
  resource_group_name    = azurerm_resource_group.spoke[count.index].name
  route_table_name   = azurerm_route_table.spoke_route_table[count.index].name
  address_prefix     = "0.0.0.0/0"
  next_hop_type      = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}
*/

# Associate route tables with spoke subnets (optional)
/*
resource "azurerm_subnet_route_table_association" "spoke_route_assoc_1" {
  count          = var.spoke_count
  subnet_id      = azurerm_subnet.spoke_subnet_1[count.index].id
  route_table_id = azurerm_route_table.spoke_route_table[count.index].id
}

resource "azurerm_subnet_route_table_association" "spoke_route_assoc_2" {
  count          = var.spoke_count
  subnet_id      = azurerm_subnet.spoke_subnet_2[count.index].id
  route_table_id = azurerm_route_table.spoke_route_table[count.index].id
}
*/
