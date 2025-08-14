# Cluster outputs
output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke_cluster.cluster_name
}

output "cluster_id" {
  description = "The unique identifier of the GKE cluster"
  value       = module.gke_cluster.cluster_id
}

output "cluster_location" {
  description = "The location of the GKE cluster"
  value       = module.gke_cluster.cluster_location
}

output "cluster_endpoint" {
  description = "The IP address of the cluster master"
  value       = module.gke_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster"
  value       = module.gke_cluster.cluster_ca_certificate
  sensitive   = true
}

output "master_version" {
  description = "The current version of the master in the cluster"
  value       = module.gke_cluster.master_version
}

# Network outputs
output "network" {
  description = "The network the cluster is connected to"
  value       = module.gke_cluster.network
}

output "subnetwork" {
  description = "The subnetwork the cluster is connected to"
  value       = module.gke_cluster.subnetwork
}

output "services_ipv4_cidr" {
  description = "The IP address range of the services in this cluster"
  value       = module.gke_cluster.services_ipv4_cidr
}

output "cluster_ipv4_cidr" {
  description = "The IP address range of the pods in this cluster"
  value       = module.gke_cluster.cluster_ipv4_cidr
}

# Private cluster information
output "private_cluster_config" {
  description = "The private cluster configuration"
  value       = module.gke_cluster.private_cluster_config
}

# Node pool outputs
output "node_pool_names" {
  description = "List of node pool names"
  value       = module.gke_node_pools.node_pool_names
}

output "node_pool_details" {
  description = "Detailed information about each node pool"
  value       = module.gke_node_pools.node_pool_details
}

output "instance_group_urls" {
  description = "Map of node pool names to their instance group URLs"
  value       = module.gke_node_pools.instance_group_urls
}

output "autoscaling_configs" {
  description = "Map of node pool autoscaling configurations"
  value       = module.gke_node_pools.autoscaling_configs
}

# kubectl connection command
output "kubectl_connection_command" {
  description = "Command to configure kubectl to connect to the cluster"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --location ${module.gke_cluster.cluster_location} --project ${var.project_id}"
}
