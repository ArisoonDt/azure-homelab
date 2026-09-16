terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    # Values supplied via -backend-config at `terraform init` time
    # (see scripts/bootstrap-backend.sh and .github/workflows/terraform-aks.yml).
    # Left empty here so the same config works locally and in CI.
  }
}
