locals {
  aws_tags = merge(var.tags, var.aws_tags)
}

resource "aws_customer_gateway" "azure_1" {
  ip_address = azurerm_public_ip.vpn_1.ip_address
  bgp_asn    = var.aws_bgp_asn
  type       = "ipsec.1"

  tags = merge({
    Name = "${var.aws_name}-1"
  }, local.aws_tags)

  depends_on = [
    time_sleep.azurerm_public_ips
  ]
}

resource "aws_customer_gateway" "azure_2" {
  ip_address = azurerm_public_ip.vpn_2.ip_address
  bgp_asn    = var.aws_bgp_asn
  type       = "ipsec.1"

  tags = merge({
    Name = "${var.aws_name}-2"
  }, local.aws_tags)

  depends_on = [
    time_sleep.azurerm_public_ips
  ]
}

resource "aws_vpn_connection" "azure_vpn1" {
  vpn_gateway_id      = var.aws_vpn_gateway_id
  customer_gateway_id = aws_customer_gateway.azure_1.id
  type                = "ipsec.1"

  tunnel1_inside_cidr = var.aws_vpn_inside_ipv4_cidrs.aws_vpn1_tunnel1
  tunnel2_inside_cidr = var.aws_vpn_inside_ipv4_cidrs.aws_vpn1_tunnel2

  tags = merge({
    Name = "${var.aws_name}-1"
  }, local.aws_tags)
}

resource "aws_vpn_connection" "azure_vpn2" {
  vpn_gateway_id      = var.aws_vpn_gateway_id
  customer_gateway_id = aws_customer_gateway.azure_2.id
  type                = "ipsec.1"

  tunnel1_inside_cidr = var.aws_vpn_inside_ipv4_cidrs.aws_vpn2_tunnel1
  tunnel2_inside_cidr = var.aws_vpn_inside_ipv4_cidrs.aws_vpn2_tunnel2

  tags = merge({
    Name = "${var.aws_name}-2"
  }, local.aws_tags)
}
