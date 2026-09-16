output "resource_group_name" {
  description = "Resource group containing the AKS cluster."
  value       = azurerm_resource_group.aks.name
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "host" {
  description = "Kubernetes API server endpoint."
  value       = azurerm_kubernetes_cluster.this.kube_config.0.host
  sensitive   = true
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the cluster (use `az aks get-credentials` instead where possible)."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL, used to set up workload identity federated credentials."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kubelet_identity_object_id" {
  description = "Object ID of the cluster's kubelet managed identity."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity.0.object_id
}
