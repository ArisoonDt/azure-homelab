variable "location" {
  description = "Azure region to deploy into."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group that will hold the AKS cluster and its network."
  type        = string
  default     = "rg-aks-homelab"
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-homelab"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS control plane. Defaults to the cluster name."
  type        = string
  default     = "akshomelab"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster. Leave null to use the current AKS default."
  type        = string
  default     = null
}

variable "node_count" {
  description = "Number of nodes in the default (system) node pool."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for the default node pool."
  type        = string
  default     = "Standard_B2s"
}

variable "sku_tier" {
  description = "AKS control plane SKU tier (Free or Standard)."
  type        = string
  default     = "Free"
}

variable "vnet_address_space" {
  description = "Address space for the AKS virtual network."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the AKS node subnet."
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services (must not overlap the VNet address space)."
  type        = string
  default     = "10.20.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address within service_cidr used for cluster DNS."
  type        = string
  default     = "10.20.0.10"
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs granted cluster-admin via Azure RBAC for Kubernetes. Leave empty to skip binding any group."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    environment = "homelab"
    managed_by  = "terraform"
  }
}
