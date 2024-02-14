locals {
  azure_tags = merge(var.tags, var.azure_tags)
}

resource "azurerm_public_ip" "vpn_1" {
  name                = "${var.azure_name}-1"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name
  allocation_method   = "Dynamic"
  tags                = local.azure_tags
}

resource "azurerm_public_ip" "vpn_2" {
  name                = "${var.azure_name}-2"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name
  allocation_method   = "Dynamic"
  tags                = local.azure_tags
}

# Azure Public IP Addresses are not immediately available
resource "time_sleep" "azurerm_public_ips" {
  depends_on      = [azurerm_public_ip.vpn_1, azurerm_public_ip.vpn_2]
  create_duration = "30s"
}

resource "azurerm_virtual_network_gateway" "main" {
  name                = var.azure_name
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name

  # Higher SKU on Azure side is not needed as AWS VPN side is capped at 1.25Gbps bandwith: https://docs.aws.amazon.com/vpn/latest/s2svpn/vpn-limits.html
  type          = "Vpn"
  vpn_type      = "RouteBased"
  active_active = true
  enable_bgp    = true
  sku           = "VpnGw2"
  generation    = "Generation2"

  ip_configuration {
    name                          = "vpnConfig1"
    public_ip_address_id          = azurerm_public_ip.vpn_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.azure_gateway_subnet_id
  }

  ip_configuration {
    name                          = "vpnConfig2"
    public_ip_address_id          = azurerm_public_ip.vpn_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.azure_gateway_subnet_id
  }

  bgp_settings {
    asn = var.aws_bgp_asn
    peering_addresses {
      ip_configuration_name = "vpnConfig1"
      apipa_addresses = [
        cidrhost(var.aws_vpn_inside_ipv4_cidrs.aws_vpn1_tunnel1, 2),
        cidrhost(var.aws_vpn_inside_ipv4_cidrs.aws_vpn1_tunnel2, 2)
      ]
    }
    peering_addresses {
      ip_configuration_name = "vpnConfig2"
      apipa_addresses = [
        cidrhost(var.aws_vpn_inside_ipv4_cidrs.aws_vpn2_tunnel1, 2),
        cidrhost(var.aws_vpn_inside_ipv4_cidrs.aws_vpn2_tunnel2, 2)
      ]
    }
  }
  tags = local.azure_tags
}

resource "azurerm_local_network_gateway" "aws1_tunnel1" {
  name                = "${var.azure_name}-1-tunnel-1"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name
  gateway_address     = aws_vpn_connection.azure_vpn1.tunnel1_address

  bgp_settings {
    asn                 = var.azure_bgp_asn
    bgp_peering_address = cidrhost(var.aws_vpn_inside_ipv4_cidrs.aws_vpn1_tunnel1, 1)
  }

  tags = local.azure_tags
}
resource "azurerm_local_network_gateway" "aws1_tunnel2" {
  name                = "${var.azure_name}-1-tunnel-2"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name
  gateway_address     = aws_vpn_connection.azure_vpn1.tunnel2_address

  bgp_settings {
    asn                 = var.azure_bgp_asn
    bgp_peering_address = cidrhost(var.aws_vpn_inside_ipv4_cidrs.aws_vpn1_tunnel2, 1)
  }

  tags = local.azure_tags
}
resource "azurerm_local_network_gateway" "aws2_tunnel1" {
  name                = "${var.azure_name}-2-tunnel-1"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name

  gateway_address = aws_vpn_connection.azure_vpn2.tunnel1_address
  bgp_settings {
    asn                 = var.azure_bgp_asn
    bgp_peering_address = cidrhost(var.aws_vpn_inside_ipv4_cidrs.aws_vpn2_tunnel1, 1)
  }

  tags = local.azure_tags
}
resource "azurerm_local_network_gateway" "aws2_tunnel2" {
  name                = "${var.azure_name}-2-tunnel-2"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name

  gateway_address = aws_vpn_connection.azure_vpn2.tunnel2_address
  bgp_settings {
    asn                 = var.azure_bgp_asn
    bgp_peering_address = cidrhost(var.aws_vpn_inside_ipv4_cidrs.aws_vpn2_tunnel2, 1)
  }

  tags = local.azure_tags
}

resource "azurerm_virtual_network_gateway_connection" "aws1_tunnel1" {
  name                = "${var.azure_name}-1-tunnel-1"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws1_tunnel1.id
  shared_key                 = aws_vpn_connection.azure_vpn1.tunnel1_preshared_key
  enable_bgp                 = true

  tags = local.azure_tags
}

resource "azurerm_virtual_network_gateway_connection" "aws1_tunnel2" {
  name                = "${var.azure_name}-1-tunnel-2"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws1_tunnel2.id
  shared_key                 = aws_vpn_connection.azure_vpn1.tunnel2_preshared_key
  enable_bgp                 = true

  tags = local.azure_tags
}

resource "azurerm_virtual_network_gateway_connection" "aws2_tunnel1" {
  name                = "${var.azure_name}-2-tunnel-1"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws2_tunnel1.id
  shared_key                 = aws_vpn_connection.azure_vpn2.tunnel1_preshared_key
  enable_bgp                 = true

  tags = local.azure_tags
}

resource "azurerm_virtual_network_gateway_connection" "aws2_tunnel2" {
  name                = "${var.azure_name}-2-tunnel-2"
  location            = var.azure_location
  resource_group_name = var.azure_rsg_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws2_tunnel2.id
  shared_key                 = aws_vpn_connection.azure_vpn2.tunnel2_preshared_key
  enable_bgp                 = true

  tags = local.azure_tags
}
