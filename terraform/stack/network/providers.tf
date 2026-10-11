provider "azurerm" {
  features {}

  # subscription_id / tenant_id / client_id are supplied via ARM_* environment
  # variables (see README.md and the GitHub Actions workflow), not hardcoded here.
}
