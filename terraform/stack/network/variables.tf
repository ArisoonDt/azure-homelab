variable "location" {
  description = "Azure region to deploy into."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that holds the network resources."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Subnets to create in the virtual network, keyed by subnet name."
  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
