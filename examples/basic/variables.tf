variable "aws_profile" {
  type        = string
  description = "AWS names profile"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "azure_location" {
  type        = string
  description = "Azure location"
  default     = "East US"
}
