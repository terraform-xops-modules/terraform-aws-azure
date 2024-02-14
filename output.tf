output "aws_vpn_connection_1" {
  value = aws_vpn_connection.azure_vpn1.id
}

output "aws_vpn_connection_2" {
  value = aws_vpn_connection.azure_vpn2.id
}

output "azurerm_virtual_network_gateway" {
  value = azurerm_virtual_network_gateway.main.id
}
