location            = "southeastasia"
resource_group_name = "rg-demo-sea-network-sdbx-01"

vnet_name          = "vnet-demo-sea-sdbx-01"
vnet_address_space = ["10.0.0.0/24"]

subnets = {
  "snet-demo-sea-devops-01" = {
    address_prefixes = ["10.0.0.0/27"]
  }
}

tags = {
  environment = "sandbox"
  managed_by  = "terraform"
}
