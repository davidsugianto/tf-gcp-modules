# Cluster basic information
output "cluster_id" {
  description = "The unique identifier of the GKE cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "The location of the GKE cluster"
  value       = google_container_cluster.primary.location
}

output "cluster_zone" {
  description = "The zone of the GKE cluster (deprecated in favor of location)"
  value       = google_container_cluster.primary.location
}

output "cluster_region" {
  description = "The region of the GKE cluster"
  value       = google_container_cluster.primary.location
}

# Network information
output "network" {
  description = "The network the cluster is connected to"
  value       = google_container_cluster.primary.network
}

output "subnetwork" {
  description = "The subnetwork the cluster is connected to"
  value       = google_container_cluster.primary.subnetwork
}

# Endpoints
output "endpoint" {
  description = "The IP address of the cluster master"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

# Authentication information
output "client_certificate" {
  description = "The client certificate for authenticating to the cluster endpoint"
  value       = google_container_cluster.primary.master_auth[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "The client key for authenticating to the cluster endpoint"
  value       = google_container_cluster.primary.master_auth[0].client_key
  sensitive   = true
}

# Cluster version information
output "master_version" {
  description = "The current version of the master in the cluster"
  value       = google_container_cluster.primary.master_version
}

output "min_master_version" {
  description = "The minimum version of the master"
  value       = google_container_cluster.primary.min_master_version
}

# Services information
output "services_ipv4_cidr" {
  description = "The IP address range of the services in this cluster"
  value       = google_container_cluster.primary.services_ipv4_cidr
}

output "cluster_ipv4_cidr" {
  description = "The IP address range of the pods in this cluster"
  value       = google_container_cluster.primary.cluster_ipv4_cidr
}

# Private cluster information
output "private_cluster_config" {
  description = "The private cluster configuration"
  value = {
    enable_private_nodes    = google_container_cluster.primary.private_cluster_config[0].enable_private_nodes
    enable_private_endpoint = google_container_cluster.primary.private_cluster_config[0].enable_private_endpoint
    master_ipv4_cidr_block  = google_container_cluster.primary.private_cluster_config[0].master_ipv4_cidr_block
    public_endpoint         = google_container_cluster.primary.private_cluster_config[0].public_endpoint
    private_endpoint        = google_container_cluster.primary.private_cluster_config[0].private_endpoint
  }
}

# Workload Identity
output "workload_identity_config" {
  description = "The workload identity configuration for the cluster"
  value       = google_container_cluster.primary.workload_identity_config
}

# Additional useful outputs
output "self_link" {
  description = "The server-defined URL for the resource"
  value       = google_container_cluster.primary.self_link
}

output "tpu_ipv4_cidr_block" {
  description = "The IP address range of the Cloud TPUs in this cluster"
  value       = google_container_cluster.primary.tpu_ipv4_cidr_block
}

output "operation" {
  description = "The server-defined URL for the operation that created the cluster"
  value       = google_container_cluster.primary.operation
}
