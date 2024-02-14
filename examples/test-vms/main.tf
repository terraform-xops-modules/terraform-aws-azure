module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "aws"
  cidr = "10.0.0.0/16"

  enable_nat_gateway                 = false
  enable_vpn_gateway                 = true
  propagate_private_route_tables_vgw = true
  propagate_public_route_tables_vgw  = true

  azs = ["us-east-1a"]
  #private_subnets = ["10.0.1.0/24"]
  public_subnets = ["10.0.0.0/24"]

  tags = {
    terraform   = "true"
    environment = "dev"
    costcenter  = "it"
  }
}

resource "azurerm_resource_group" "azure_vpc" {
  location = var.azure_location
  name     = "azure-network-rg"
}

module "azure_vpc" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = "azure"
  resource_group_name = azurerm_resource_group.azure_vpc.name
  use_for_each        = true
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.0.0/24", "10.1.255.0/24"]
  subnet_names        = ["subnet1", "GatewaySubnet"]
  vnet_location       = var.azure_location

  tags = {
    terraform   = "true"
    environment = "dev"
    costcenter  = "it"
  }
}

module "s2s_vpn" {
  source                  = "terraform-xops-modules/aws-azure-vpn/xops"
  aws_vpc_id              = module.aws_vpc.vpc_id
  aws_vpn_gateway_id      = module.aws_vpc.vgw_id
  azure_rsg_name          = azurerm_resource_group.azure_vpc.name
  azure_vnet_name         = module.azure_vpc.vnet_name
  azure_location          = azurerm_resource_group.azure_vpc.location
  azure_gateway_subnet_id = module.azure_vpc.vnet_subnets_name_id.GatewaySubnet
}

output "s2s" {
  value = module.s2s_vpn
}
