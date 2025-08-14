# Required variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "example-gke-cluster"
}

variable "location" {
  description = "The location (region or zone) where the cluster will be created"
  type        = string
  default     = "us-central1"
}

# Network configuration
variable "network" {
  description = "The VPC network where the cluster will be created"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork where the cluster will be created"
  type        = string
  default     = null
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for cluster pods"
  type        = string
  default     = null
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range for services"
  type        = string
  default     = null
}

# Private cluster configuration
variable "enable_private_nodes" {
  description = "Enable private nodes"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the Kubernetes master"
  type        = string
  default     = "172.16.0.0/28"
}

# Master authorized networks
variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

# Security and features
variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "network_policy_enabled" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "horizontal_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling"
  type        = bool
  default     = true
}

variable "http_load_balancing" {
  description = "Enable HTTP load balancing"
  type        = bool
  default     = true
}

# Maintenance configuration
variable "maintenance_start_time" {
  description = "Time window for maintenance operations format HH:MM"
  type        = string
  default     = "03:00"
}

variable "release_channel" {
  description = "The release channel of this cluster"
  type        = string
  default     = "STABLE"
}

# Resource labels
variable "resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  type        = map(string)
  default = {
    environment = "example"
    managed_by  = "terraform"
  }
}

# Node pools configuration
variable "node_pools" {
  description = "Map of node pool configurations"
  type = map(object({
    # Basic configuration
    node_count   = optional(number, 1)
    machine_type = optional(string, "e2-medium")
    disk_size_gb = optional(number, 100)
    disk_type    = optional(string, "pd-standard")
    image_type   = optional(string, "COS_CONTAINERD")

    # Autoscaling
    autoscaling = optional(object({
      min_node_count       = optional(number, 1)
      max_node_count       = optional(number, 10)
      location_policy      = optional(string, null)
      total_min_node_count = optional(number, null)
      total_max_node_count = optional(number, null)
    }), null)

    # Service account and OAuth scopes
    service_account = optional(string, "default")
    oauth_scopes = optional(list(string), [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ])

    # Node characteristics
    preemptible       = optional(bool, false)
    spot              = optional(bool, false)
    local_ssd_count   = optional(number, 0)
    boot_disk_kms_key = optional(string, null)

    # Labels, taints, and tags
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    tags     = optional(list(string), [])
    metadata = optional(map(string), {})

    # Security
    enable_shielded_nodes        = optional(bool, false)
    enable_secure_boot           = optional(bool, false)
    enable_integrity_monitoring  = optional(bool, true)
    workload_metadata_config_mode = optional(string, "GKE_METADATA")

    # Node management
    auto_repair  = optional(bool, true)
    auto_upgrade = optional(bool, true)

    # Node version and locations
    node_version   = optional(string, null)
    node_locations = optional(list(string), null)
  }))
  
  default = {
    # Default node pool for general workloads
    "default-pool" = {
      machine_type = "e2-medium"
      disk_size_gb = 100
      disk_type    = "pd-standard"
      autoscaling = {
        min_node_count = 1
        max_node_count = 3
      }
      labels = {
        pool_type = "default"
        workload  = "general"
      }
    }
    
    # High-memory node pool for memory-intensive workloads
    "high-memory-pool" = {
      machine_type = "e2-highmem-2"
      disk_size_gb = 150
      disk_type    = "pd-ssd"
      autoscaling = {
        min_node_count = 0
        max_node_count = 2
      }
      labels = {
        pool_type = "high-memory"
        workload  = "memory-intensive"
      }
      taints = [
        {
          key    = "workload-type"
          value  = "memory-intensive"
          effect = "NO_SCHEDULE"
        }
      ]
    }
    
    # Spot instances pool for cost-effective batch workloads
    "spot-pool" = {
      machine_type = "e2-standard-2"
      disk_size_gb = 100
      spot         = true
      autoscaling = {
        min_node_count = 0
        max_node_count = 5
      }
      labels = {
        pool_type = "spot"
        workload  = "batch"
      }
      taints = [
        {
          key    = "node-type"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
}
