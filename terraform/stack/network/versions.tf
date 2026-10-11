terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-demo-sea-tf-sdbx-01"
    storage_account_name = "stdemoseatfsdbx01"
    container_name       = "tfstate"
    key                  = "network.tfstate"
  }
}
