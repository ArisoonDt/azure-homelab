#!/usr/bin/env bash
# One-time setup: creates the resource group + storage account + container that
# hold Terraform remote state. Run locally once with `az login` already done.
#
# Usage: ./scripts/bootstrap-backend.sh [resource-group] [location] [storage-account-name]

set -euo pipefail

RG_NAME="${1:-rg-tfstate-aks-homelab}"
LOCATION="${2:-eastus}"
# Storage account names must be globally unique, 3-24 lowercase alphanumeric chars.
SA_NAME="${3:-tfstateakshomelab$(openssl rand -hex 3)}"
CONTAINER_NAME="tfstate"

echo "Creating resource group: $RG_NAME ($LOCATION)"
az group create --name "$RG_NAME" --location "$LOCATION" --output none

echo "Creating storage account: $SA_NAME"
az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none

echo "Creating blob container: $CONTAINER_NAME"
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$SA_NAME" \
  --auth-mode login \
  --output none

cat <<EOF

Backend bootstrap complete. Save these as GitHub repo Variables (Settings > Secrets
and variables > Actions > Variables), and use them for local 'terraform init':

  TF_BACKEND_RESOURCE_GROUP  = $RG_NAME
  TF_BACKEND_STORAGE_ACCOUNT = $SA_NAME
  TF_BACKEND_CONTAINER       = $CONTAINER_NAME
  TF_BACKEND_KEY             = aks.tfstate

Local init example:
  terraform -chdir=terraform init \\
    -backend-config="resource_group_name=$RG_NAME" \\
    -backend-config="storage_account_name=$SA_NAME" \\
    -backend-config="container_name=$CONTAINER_NAME" \\
    -backend-config="key=aks.tfstate"
EOF
