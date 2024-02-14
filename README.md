# Terraform xCloud: AWS Azure S2S VPN
> This module uses multiple providers - provider is named as xops. xops is a pseudo provider used for using multiple providers

Terraform Module for setting up a High Availability Site2Site VPN Tunnelbetween AWS and Azure

Detailed Tutorial from Azure [here](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-aws-bgp)

## Architecture of the S2S Tunnel
![arch](https://assets.xops.sh/github/terraform-xops-modules/terraform-aws-azure-vpn/xcloud-aws-azure.svg)

## Usage
Basic usage

```
resource "azurerm_resource_group" "azure_vpn" {
  location = var.azure_location
  name     = "azure-vpn-rg"
}

module "s2s_vpn" {
  source                  = "./modules/terraform-aws-azure-vpn"
  aws_vpc_id              = var.aws_vpc_id
  aws_vpn_gateway_id      = var.aws_vgw_id
  azure_rsg_name          = azurerm_resource_group.azure_vpn.name
  azure_vnet_name         = var.azure_vnet_name
  azure_location          = var.azure_location
  azure_gateway_subnet_id = var.azure_gateway_subnet
}
```

For detailed usage, including provisioning AWS VPC and Azure VNet, refere to examples folder

## Inputs

| Name                       | Type         | Default            | Required | Description                                                                                 |
|----------------------------|--------------|--------------------|----------|:-------------------------------------------------------------------------------------------:|
|`tags`                      |`map(string)` | `{}`               | no       | Tags to apply to both AWS and Azure Resources.                                              |
| AWS Specific Variables                                                                                                                                                  |
|`aws_name`                  |`string`      | `azure-vpn`        | no       | Name to use on AWS Resources. Using `azure` to indicate the connection is to Azure Cloud.   |
|`aws_vpc_id`                |`string`      |                    | yes      | AWS VPC id                                                                                  |
|`aws_vpn_gateway_id`        |`string`      |                    | yes      | AWS VPN Gateway id. See [examples](./examples/main.tf) for provisioning it using vpc module.|
|`aws_bgp_asn`               |`number`      | `65000`            | no       | AWS BGP ASN.                                                                           |
|`aws_vpn_inside_ipv4_cidrs` |`map(string)` | Refer Table below  | no       | AWS VPN Inside IPv4 CIDRs for both Tunnels. Refer to table below for further details.       |
|`aws_tags`                  |`map(string)` | `{}`               | no       | Tags to apply only to AWS Resources.                                                        |
| Azure Specific Variables                                                                                                  |
|`azure_name`                |`string`      | `aws-vpn`          | no       | Name to use on Azure Resources. Using `aws` to indicate the connection is to AWS Cloud.     |
|`azure_rsg_name`            |`string`      |                    | yes      | Azure Resource Group Name.                                                                  |
|`azure_location`            |`string`      |                    | yes      | Azure location to create the resources.                                                     |
|`azure_vnet_name`           |`string`      |                    | yes      | Azure VNet name.                                                                            |
|`azure_gateway_subnet_id`   |`string`      |                    | yes      | Azure Gateway Subnet id. See [examples](./examples/main.tf) for adding this via VNet module.|
|`azure_bgp_asn`             |`number`      | `64512`            | no       | Azure BGP ASN.                                                                               |
|`azure_tags`                |`map(string)` | `{}`               | no       | Tags to apply only to Azure Resources.                                                      |

#### AWS VPN Inside IPv4 CIDRs (`aws_vpn_inside_ipv4_cidrs`).
AWS requires a /30 Inside IPv4 CIDR in the APIPA range of 169.254.0.0/16 for each tunnel. This CIDR must also be in the Azure-reserved APIPA range for VPN, which is from 169.254.21.0 to 169.254.22.255. AWS will use the first IP address of your /30 inside CIDR and Azure will use the second. This means you need to reserve space for two IP addresses in your AWS /30 CIDR.

| Tunnel                                 | Variable                                   | Azure Custom Azure APIPA BGP IP Address | AWS BGP Peer IP Address | AWS Inside IPv4 CIDR |
|:--------------------------------------:|:------------------------------------------:|:---------------------------------------:|:-----------------------:|:--------------------:|
| AWS VPN 1 Tunnel 1 to Azure Instance 0 |`aws_vpn_inside_ipv4_cidrs.aws_vpn1_tunnel1`| 169.254.21.2                            | 169.254.21.1            | 169.254.21.0/30      |
| AWS VPN 1 Tunnel 2 to Azure Instance 0 |`aws_vpn_inside_ipv4_cidrs.aws_vpn1_tunnel2`| 169.254.22.2	                          | 169.254.22.1	          | 169.254.22.0/30      |
| AWS VPN 2 Tunnel 1 to Azure Instance 1 |`aws_vpn_inside_ipv4_cidrs.aws_vpn2_tunnel1`| 169.254.21.6	                          | 169.254.21.5	          | 169.254.21.4/30      |
| AWS VPN 2 Tunnel 2 to Azure Instance 1 |`aws_vpn_inside_ipv4_cidrs.aws_vpn2_tunnel2`| 169.254.22.6	                          | 169.254.22.5	          | 169.254.22.4/30      |

## Outputs
| Name                            | Type     | Description                                   |
|---------------------------------|----------|:---------------------------------------------:|
|`aws_vpn_connection_1`           |`string`  | AWS VPN 1 id                                  |
|`aws_vpn_connection_2`           |`string`  | AWS VPN 2 id                                  |
|`azurerm_virtual_network_gateway`|`string`  | Azure Virtual Network Gateway Resource id     |

## TODO
Add automated linting, testing and release pipelines
