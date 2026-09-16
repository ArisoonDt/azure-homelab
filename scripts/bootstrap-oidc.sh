#!/usr/bin/env bash
# One-time setup: creates an Azure AD app + service principal that GitHub Actions
# authenticates as via OIDC (no stored client secret), grants it Contributor on
# the target resource group and Storage Blob Data Contributor on the tfstate
# storage account, and registers federated credentials trusting this repo.
#
# Run locally once with `az login` already done.
#
# Usage:
#   ./scripts/bootstrap-oidc.sh <github-org>/<github-repo> <tfstate-storage-account> [aks-resource-group] [app-name]
#
# Example:
#   ./scripts/bootstrap-oidc.sh myorg/azure-homelab tfstateakshomelab1a2b3c rg-aks-homelab gh-actions-aks-homelab

set -euo pipefail

GITHUB_REPO="${1:?Usage: $0 <github-org>/<github-repo> <tfstate-storage-account> [aks-resource-group] [app-name]}"
TFSTATE_SA="${2:?tfstate storage account name is required (from bootstrap-backend.sh output)}"
AKS_RG="${3:-rg-aks-homelab}"
APP_NAME="${4:-gh-actions-aks-homelab}"

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
TENANT_ID="$(az account show --query tenantId -o tsv)"

echo "Creating (or reusing) Azure AD app: $APP_NAME"
APP_ID="$(az ad app list --display-name "$APP_NAME" --query '[0].appId' -o tsv)"
if [[ -z "$APP_ID" ]]; then
  APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
fi

echo "Creating service principal for app $APP_ID"
az ad sp create --id "$APP_ID" --output none 2>/dev/null || true

echo "Ensuring the AKS resource group exists: $AKS_RG"
az group create --name "$AKS_RG" --location "$(az account list-locations --query "[0].name" -o tsv)" --output none 2>/dev/null || true

echo "Granting Contributor on resource group: $AKS_RG"
az role assignment create \
  --assignee "$APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$AKS_RG" \
  --output none

echo "Granting User Access Administrator on resource group (needed for the cluster's Azure RBAC role assignment)"
az role assignment create \
  --assignee "$APP_ID" \
  --role "User Access Administrator" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$AKS_RG" \
  --output none

echo "Granting Storage Blob Data Contributor on tfstate storage account: $TFSTATE_SA"
SA_ID="$(az storage account show --name "$TFSTATE_SA" --query id -o tsv)"
az role assignment create \
  --assignee "$APP_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "$SA_ID" \
  --output none

federated() {
  local name="$1" subject="$2"
  echo "Creating federated credential: $name ($subject)"
  az ad app federated-credential create \
    --id "$APP_ID" \
    --parameters "{\"name\":\"$name\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"$subject\",\"audiences\":[\"api://AzureADTokenExchange\"]}" \
    2>/dev/null || echo "  (already exists, skipping)"
}

federated "pull-requests" "repo:${GITHUB_REPO}:pull_request"
federated "main-branch" "repo:${GITHUB_REPO}:ref:refs/heads/main"
federated "production-environment" "repo:${GITHUB_REPO}:environment:production"

cat <<EOF

OIDC bootstrap complete. Save these as GitHub repo Variables (Settings > Secrets
and variables > Actions > Variables) - they are identifiers, not secrets:

  AZURE_CLIENT_ID       = $APP_ID
  AZURE_TENANT_ID       = $TENANT_ID
  AZURE_SUBSCRIPTION_ID = $SUBSCRIPTION_ID

Also create a GitHub Environment named "production" (Settings > Environments) if
you want manual approval before 'terraform apply' runs against main.
EOF
