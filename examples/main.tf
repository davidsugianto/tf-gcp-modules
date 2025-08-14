# Provider configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create the GKE cluster using our module
module "gke_cluster" {
  source = "../container-cluster"

  # Required variables
  project_id   = var.project_id
  cluster_name = var.cluster_name
  location     = var.location

  # Network configuration
  network    = var.network
  subnetwork = var.subnetwork

  # Secondary IP ranges for VPC-native cluster
  cluster_secondary_range_name  = var.cluster_secondary_range_name
  services_secondary_range_name = var.services_secondary_range_name

  # Private cluster configuration
  enable_private_nodes    = var.enable_private_nodes
  enable_private_endpoint = var.enable_private_endpoint
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block

  # Master authorized networks
  master_authorized_networks = var.master_authorized_networks

  # Security and features
  enable_workload_identity     = var.enable_workload_identity
  network_policy_enabled       = var.network_policy_enabled
  horizontal_pod_autoscaling   = var.horizontal_pod_autoscaling
  http_load_balancing          = var.http_load_balancing

  # Maintenance configuration
  maintenance_start_time = var.maintenance_start_time
  release_channel        = var.release_channel

  # Resource labels
  resource_labels = var.resource_labels
}

# Create node pools using our module
module "gke_node_pools" {
  source = "../container-node-pools"

  # Required variables
  project_id   = var.project_id
  cluster_name = module.gke_cluster.cluster_name
  location     = var.location

  # Node pools configuration
  node_pools = var.node_pools

  # This ensures node pools are created after the cluster
  depends_on = [module.gke_cluster]
}
