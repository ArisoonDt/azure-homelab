resource "azurerm_virtual_network" "aks" {
  name                = "vnet-${var.cluster_name}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "aks_nodes" {
  name                 = "snet-${var.cluster_name}-nodes"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = var.subnet_address_prefixes
}
