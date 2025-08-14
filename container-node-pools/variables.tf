# Required variables
variable "project_id" {
  description = "The project ID where the node pools will be created"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "location" {
  description = "The location (region or zone) where the node pools will be created"
  type        = string
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

    # GPU configuration
    gpu_config = optional(object({
      type               = string
      count              = number
      gpu_partition_size = optional(string, null)
      gpu_sharing_config = optional(object({
        gpu_sharing_strategy       = string
        max_shared_clients_per_gpu = number
      }), null)
      gpu_driver_installation_config = optional(object({
        gpu_driver_version = string
      }), null)
    }), null)

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
    sandbox_type                 = optional(string, null)

    # Node management
    auto_repair  = optional(bool, true)
    auto_upgrade = optional(bool, true)

    # Advanced configuration
    kubelet_config = optional(object({
      cpu_manager_policy   = optional(string, "none")
      cpu_cfs_quota        = optional(bool, null)
      cpu_cfs_quota_period = optional(string, null)
      pod_pids_limit       = optional(number, null)
    }), null)

    linux_node_config = optional(object({
      sysctls     = optional(map(string), {})
      cgroup_mode = optional(string, "CGROUP_MODE_UNSPECIFIED")
    }), null)

    # Upgrade settings
    upgrade_settings = optional(object({
      strategy        = optional(string, "SURGE")
      max_surge       = optional(number, 1)
      max_unavailable = optional(number, 0)
      blue_green_settings = optional(object({
        node_pool_soak_duration = optional(string, null)
        standard_rollout_policy = object({
          batch_percentage    = optional(number, null)
          batch_node_count    = optional(number, null)
          batch_soak_duration = optional(string, null)
        })
      }), null)
    }), null)

    # Network configuration
    network_config = optional(object({
      create_pod_range     = optional(bool, false)
      pod_range            = optional(string, null)
      pod_ipv4_cidr_block  = optional(string, null)
      enable_private_nodes = optional(bool, null)
      pod_cidr_overprovision_config = optional(object({
        disabled = bool
      }), null)
    }), null)

    # Placement policy
    placement_policy = optional(object({
      type         = string
      policy_name  = optional(string, null)
      tpu_topology = optional(string, null)
    }), null)

    # Sole tenant configuration
    sole_tenant_config = optional(object({
      node_affinities = list(object({
        key      = string
        operator = string
        values   = list(string)
      }))
    }), null)

    # Reservation affinity
    reservation_affinity = optional(object({
      consume_reservation_type = string
      key                      = optional(string, null)
      values                   = optional(list(string), null)
    }), null)

    # Node version and locations
    node_version   = optional(string, null)
    node_locations = optional(list(string), null)

    # Queue provisioning
    queued_provisioning = optional(bool, null)
  }))
  default = {}
}

# Timeouts
variable "node_pool_timeout_create" {
  description = "Timeout for creating node pools"
  type        = string
  default     = "30m"
}

variable "node_pool_timeout_update" {
  description = "Timeout for updating node pools"
  type        = string
  default     = "30m"
}

variable "node_pool_timeout_delete" {
  description = "Timeout for deleting node pools"
  type        = string
  default     = "30m"
}
