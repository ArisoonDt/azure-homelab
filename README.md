# azure-homelab

Terraform for a minimal AKS cluster, deployed via GitHub Actions using OIDC
(no stored Azure credentials).

## What gets deployed

- Resource group, VNet + subnet
- AKS cluster (`terraform/`):
  - Single system node pool (default: 1x `Standard_B2s`, no autoscaling)
  - Azure CNI networking with Calico network policy
  - Azure AD RBAC for Kubernetes authorization
  - Workload identity + OIDC issuer enabled (ready for per-pod federated identities)
  - Free-tier control plane

## One-time setup

Requires the [Azure CLI](https://learn.microsoft.com/cli/azure/) and `az login`
with an account that has Owner (or User Access Administrator + Contributor) on
the subscription.

1. **Create the Terraform state backend:**

   ```bash
   ./scripts/bootstrap-backend.sh rg-tfstate-aks-homelab eastus
   ```

   Note the `TF_BACKEND_*` values it prints.

2. **Create the GitHub Actions OIDC app:**

   ```bash
   ./scripts/bootstrap-oidc.sh <your-org>/<your-repo> <tfstate-storage-account> rg-aks-homelab
   ```

   Note the `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` values it prints.

3. **Add repo variables** (Settings → Secrets and variables → Actions → Variables).
   None of these are secret — OIDC means there's no client secret to store:

   | Variable | Value |
   |---|---|
   | `AZURE_CLIENT_ID` | from step 2 |
   | `AZURE_TENANT_ID` | from step 2 |
   | `AZURE_SUBSCRIPTION_ID` | from step 2 |
   | `TF_BACKEND_RESOURCE_GROUP` | from step 1 |
   | `TF_BACKEND_STORAGE_ACCOUNT` | from step 1 |
   | `TF_BACKEND_CONTAINER` | from step 1 (`tfstate`) |
   | `TF_BACKEND_KEY` | `aks.tfstate` |

4. **(Recommended) Create a GitHub Environment** named `production` (Settings →
   Environments) and add required reviewers, so `terraform apply` on `main`
   waits for manual approval.

## Running it

- Open a PR that touches `terraform/**` → the `plan` job runs `terraform plan`
  and comments the diff on the PR.
- Merge to `main` → the `apply` job runs `terraform apply` (gated by the
  `production` environment if you set one up).

## Running locally

```bash
cd terraform
terraform init \
  -backend-config="resource_group_name=<TF_BACKEND_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TF_BACKEND_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TF_BACKEND_CONTAINER>" \
  -backend-config="key=aks.tfstate" \
  -backend-config="use_azuread_auth=true"

cp terraform.tfvars.example terraform.tfvars   # edit as needed
terraform plan
terraform apply
```

Local auth uses your `az login` session (the `azurerm` provider falls back to
Azure CLI auth when `ARM_USE_OIDC` isn't set).

## Connecting to the cluster

```bash
az aks get-credentials --resource-group rg-aks-homelab --name aks-homelab
kubectl get nodes
```

Since Azure RBAC is enabled, you'll need an Azure AD role (e.g. `Azure
Kubernetes Service RBAC Cluster Admin`) on the cluster to run `kubectl`
commands — see `admin_group_object_ids` in `terraform/variables.tf`.
