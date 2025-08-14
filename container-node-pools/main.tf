resource "google_container_node_pool" "node_pool" {
  for_each = var.node_pools

  project    = var.project_id
  cluster    = var.cluster_name
  location   = var.location
  name       = each.key
  node_count = lookup(each.value, "autoscaling", null) == null ? lookup(each.value, "node_count", 1) : null

  # Autoscaling configuration
  dynamic "autoscaling" {
    for_each = lookup(each.value, "autoscaling", null) != null ? [each.value.autoscaling] : []
    content {
      min_node_count       = lookup(autoscaling.value, "min_node_count", 1)
      max_node_count       = lookup(autoscaling.value, "max_node_count", 10)
      location_policy      = lookup(autoscaling.value, "location_policy", null)
      total_min_node_count = lookup(autoscaling.value, "total_min_node_count", null)
      total_max_node_count = lookup(autoscaling.value, "total_max_node_count", null)
    }
  }

  # Node configuration
  node_config {
    machine_type = lookup(each.value, "machine_type", "e2-medium")
    disk_size_gb = lookup(each.value, "disk_size_gb", 100)
    disk_type    = lookup(each.value, "disk_type", "pd-standard")
    image_type   = lookup(each.value, "image_type", "COS_CONTAINERD")

    # Service account
    service_account = lookup(each.value, "service_account", "default")
    oauth_scopes = lookup(each.value, "oauth_scopes", [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ])

    # Preemptible nodes
    preemptible  = lookup(each.value, "preemptible", false)
    spot         = lookup(each.value, "spot", false)

    # Local SSD
    local_ssd_count = lookup(each.value, "local_ssd_count", 0)

    # GPU configuration
    dynamic "guest_accelerator" {
      for_each = lookup(each.value, "gpu_config", null) != null ? [each.value.gpu_config] : []
      content {
        type               = guest_accelerator.value.type
        count              = guest_accelerator.value.count
        gpu_partition_size = lookup(guest_accelerator.value, "gpu_partition_size", null)
        
        dynamic "gpu_sharing_config" {
          for_each = lookup(guest_accelerator.value, "gpu_sharing_config", null) != null ? [guest_accelerator.value.gpu_sharing_config] : []
          content {
            gpu_sharing_strategy       = gpu_sharing_config.value.gpu_sharing_strategy
            max_shared_clients_per_gpu = gpu_sharing_config.value.max_shared_clients_per_gpu
          }
        }
        
        dynamic "gpu_driver_installation_config" {
          for_each = lookup(guest_accelerator.value, "gpu_driver_installation_config", null) != null ? [guest_accelerator.value.gpu_driver_installation_config] : []
          content {
            gpu_driver_version = gpu_driver_installation_config.value.gpu_driver_version
          }
        }
      }
    }

    # Node labels
    labels = merge(
      lookup(each.value, "labels", {}),
      {
        "node-pool" = each.key
      }
    )

    # Node taints
    dynamic "taint" {
      for_each = lookup(each.value, "taints", [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Node tags
    tags = lookup(each.value, "tags", [])

    # Metadata
    metadata = merge(
      {
        "disable-legacy-endpoints" = "true"
      },
      lookup(each.value, "metadata", {})
    )

    # Boot disk encryption
    boot_disk_kms_key = lookup(each.value, "boot_disk_kms_key", null)

    # Shielded instance configuration
    dynamic "shielded_instance_config" {
      for_each = lookup(each.value, "enable_shielded_nodes", false) ? [1] : []
      content {
        enable_secure_boot          = lookup(each.value, "enable_secure_boot", false)
        enable_integrity_monitoring = lookup(each.value, "enable_integrity_monitoring", true)
      }
    }

    # Workload metadata configuration
    workload_metadata_config {
      mode = lookup(each.value, "workload_metadata_config_mode", "GKE_METADATA")
    }

    # Sandbox configuration
    dynamic "sandbox_config" {
      for_each = lookup(each.value, "sandbox_type", null) != null ? [1] : []
      content {
        sandbox_type = each.value.sandbox_type
      }
    }

    # Kubelet configuration
    dynamic "kubelet_config" {
      for_each = lookup(each.value, "kubelet_config", null) != null ? [each.value.kubelet_config] : []
      content {
        cpu_manager_policy   = lookup(kubelet_config.value, "cpu_manager_policy", "none")
        cpu_cfs_quota        = lookup(kubelet_config.value, "cpu_cfs_quota", null)
        cpu_cfs_quota_period = lookup(kubelet_config.value, "cpu_cfs_quota_period", null)
        pod_pids_limit       = lookup(kubelet_config.value, "pod_pids_limit", null)
      }
    }

    # Linux node configuration
    dynamic "linux_node_config" {
      for_each = lookup(each.value, "linux_node_config", null) != null ? [each.value.linux_node_config] : []
      content {
        sysctls     = lookup(linux_node_config.value, "sysctls", {})
        cgroup_mode = lookup(linux_node_config.value, "cgroup_mode", "CGROUP_MODE_UNSPECIFIED")
      }
    }

    # Node group configuration
    dynamic "sole_tenant_config" {
      for_each = lookup(each.value, "sole_tenant_config", null) != null ? [each.value.sole_tenant_config] : []
      content {
        dynamic "node_affinity" {
          for_each = sole_tenant_config.value.node_affinities
          content {
            key      = node_affinity.value.key
            operator = node_affinity.value.operator
            values   = node_affinity.value.values
          }
        }
      }
    }

    # Reservation configuration
    dynamic "reservation_affinity" {
      for_each = lookup(each.value, "reservation_affinity", null) != null ? [each.value.reservation_affinity] : []
      content {
        consume_reservation_type = reservation_affinity.value.consume_reservation_type
        key                      = lookup(reservation_affinity.value, "key", null)
        values                   = lookup(reservation_affinity.value, "values", null)
      }
    }
  }

  # Node pool management
  management {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
  }

  # Upgrade settings
  dynamic "upgrade_settings" {
    for_each = lookup(each.value, "upgrade_settings", null) != null ? [each.value.upgrade_settings] : []
    content {
      strategy        = lookup(upgrade_settings.value, "strategy", "SURGE")
      max_surge       = lookup(upgrade_settings.value, "max_surge", 1)
      max_unavailable = lookup(upgrade_settings.value, "max_unavailable", 0)

      dynamic "blue_green_settings" {
        for_each = lookup(upgrade_settings.value, "blue_green_settings", null) != null ? [upgrade_settings.value.blue_green_settings] : []
        content {
          node_pool_soak_duration = lookup(blue_green_settings.value, "node_pool_soak_duration", null)
          
          standard_rollout_policy {
            batch_percentage    = lookup(blue_green_settings.value.standard_rollout_policy, "batch_percentage", null)
            batch_node_count    = lookup(blue_green_settings.value.standard_rollout_policy, "batch_node_count", null)
            batch_soak_duration = lookup(blue_green_settings.value.standard_rollout_policy, "batch_soak_duration", null)
          }
        }
      }
    }
  }

  # Network configuration
  dynamic "network_config" {
    for_each = lookup(each.value, "network_config", null) != null ? [each.value.network_config] : []
    content {
      create_pod_range     = lookup(network_config.value, "create_pod_range", false)
      pod_range            = lookup(network_config.value, "pod_range", null)
      pod_ipv4_cidr_block  = lookup(network_config.value, "pod_ipv4_cidr_block", null)
      enable_private_nodes = lookup(network_config.value, "enable_private_nodes", null)
      
      dynamic "pod_cidr_overprovision_config" {
        for_each = lookup(network_config.value, "pod_cidr_overprovision_config", null) != null ? [network_config.value.pod_cidr_overprovision_config] : []
        content {
          disabled = pod_cidr_overprovision_config.value.disabled
        }
      }
    }
  }

  # Placement policy
  dynamic "placement_policy" {
    for_each = lookup(each.value, "placement_policy", null) != null ? [each.value.placement_policy] : []
    content {
      type         = placement_policy.value.type
      policy_name  = lookup(placement_policy.value, "policy_name", null)
      tpu_topology = lookup(placement_policy.value, "tpu_topology", null)
    }
  }

  # Queue provisioning
  dynamic "queued_provisioning" {
    for_each = lookup(each.value, "queued_provisioning", null) != null ? [1] : []
    content {
      enabled = each.value.queued_provisioning
    }
  }

  # Node version
  version = lookup(each.value, "node_version", null)

  # Node locations
  node_locations = lookup(each.value, "node_locations", null)

  # Timeouts
  timeouts {
    create = var.node_pool_timeout_create
    update = var.node_pool_timeout_update
    delete = var.node_pool_timeout_delete
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config[0].labels,
      node_config[0].taint,
    ]
  }
}
