# General Variables
variable "tags" {
  type        = map(string)
  description = "Tags to apply for both AWS and Azure Resources"
  default     = {}
}

# AWS Specific Variables
variable "aws_name" {
  default     = "azure-vpn"
  description = "Name tag to add to AWS VPN resources"
}

variable "aws_vpc_id" {
  type        = string
  description = "AWS VPC id to create the s2s vpn tunnel"
}

variable "aws_vpn_gateway_id" {
  type        = string
  description = "New VPN Gateway is created if not passed"
}

variable "aws_bgp_asn" {
  type        = number
  default     = 65000
  description = "AWS Side BGP ASN"
}

variable "aws_vpn_inside_ipv4_cidrs" {
  type        = map(string)
  description = "Inside IPV4 Address for AWS VPN. First IP will be used by AWS and second ip will be used by Azure from the CIDR"
  default = {
    aws_vpn1_tunnel1 = "169.254.21.0/30"
    aws_vpn1_tunnel2 = "169.254.22.0/30"
    aws_vpn2_tunnel1 = "169.254.21.4/30"
    aws_vpn2_tunnel2 = "169.254.22.4/30"
  }
}

variable "aws_tags" {
  type        = map(string)
  description = "Tags to apply for AWS Resources"
  default     = {}
}

# Azure Specific Variables
variable "azure_name" {
  default     = "aws-vpn"
  description = "Name of the azure vpn resources"
}

variable "azure_rsg_name" {
  type        = string
  description = "Resource Group Name for Azure"
}

variable "azure_location" {
  type        = string
  description = "Azure location of the resources"
}

variable "azure_vnet_name" {
  type        = string
  description = "Azure VNET to create the s2s vpn tunnel"
}

variable "azure_gateway_subnet_id" {
  type        = string
  description = "Azure Gateway subnet id"
}

variable "azure_bgp_asn" {
  type        = number
  default     = 64512
  description = "Azure Side BGP ASN"
}

variable "azure_tags" {
  type        = map(string)
  description = "Tags to apply for Azure Resources"
  default     = {}
}
