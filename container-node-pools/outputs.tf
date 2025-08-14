# Node pool basic information
output "node_pool_names" {
  description = "List of node pool names"
  value       = [for pool in google_container_node_pool.node_pool : pool.name]
}

output "node_pool_ids" {
  description = "Map of node pool names to their IDs"
  value       = { for k, pool in google_container_node_pool.node_pool : k => pool.id }
}

output "node_pools" {
  description = "Map of node pool configurations"
  value = {
    for k, pool in google_container_node_pool.node_pool : k => {
      id                 = pool.id
      name               = pool.name
      location           = pool.location
      cluster            = pool.cluster
      node_count         = pool.node_count
      actual_node_count  = pool.actual_node_count
      instance_group_urls = pool.instance_group_urls
      managed_instance_group_urls = pool.managed_instance_group_urls
      version            = pool.version
    }
  }
}

# Node pool detailed information
output "node_pool_details" {
  description = "Detailed information about each node pool"
  value = {
    for k, pool in google_container_node_pool.node_pool : k => {
      # Basic info
      name         = pool.name
      location     = pool.location
      node_count   = pool.node_count
      version      = pool.version

      # Node configuration
      machine_type = pool.node_config[0].machine_type
      disk_size_gb = pool.node_config[0].disk_size_gb
      disk_type    = pool.node_config[0].disk_type
      image_type   = pool.node_config[0].image_type
      preemptible  = pool.node_config[0].preemptible
      spot         = pool.node_config[0].spot

      # Instance groups
      instance_group_urls         = pool.instance_group_urls
      managed_instance_group_urls = pool.managed_instance_group_urls

      # Autoscaling info
      autoscaling = length(pool.autoscaling) > 0 ? {
        enabled                = true
        min_node_count         = pool.autoscaling[0].min_node_count
        max_node_count         = pool.autoscaling[0].max_node_count
        location_policy        = pool.autoscaling[0].location_policy
        total_min_node_count   = pool.autoscaling[0].total_min_node_count
        total_max_node_count   = pool.autoscaling[0].total_max_node_count
      } : {
        enabled = false
      }

      # Management settings
      management = {
        auto_repair  = pool.management[0].auto_repair
        auto_upgrade = pool.management[0].auto_upgrade
      }
    }
  }
}

# Instance group URLs for each node pool
output "instance_group_urls" {
  description = "Map of node pool names to their instance group URLs"
  value = {
    for k, pool in google_container_node_pool.node_pool : k => pool.instance_group_urls
  }
}

output "managed_instance_group_urls" {
  description = "Map of node pool names to their managed instance group URLs"
  value = {
    for k, pool in google_container_node_pool.node_pool : k => pool.managed_instance_group_urls
  }
}

# Node pool versions
output "node_pool_versions" {
  description = "Map of node pool names to their current versions"
  value = {
    for k, pool in google_container_node_pool.node_pool : k => pool.version
  }
}

# Autoscaling configurations
output "autoscaling_configs" {
  description = "Map of node pool autoscaling configurations"
  value = {
    for k, pool in google_container_node_pool.node_pool : k => length(pool.autoscaling) > 0 ? {
      enabled                = true
      min_node_count         = pool.autoscaling[0].min_node_count
      max_node_count         = pool.autoscaling[0].max_node_count
      location_policy        = pool.autoscaling[0].location_policy
      total_min_node_count   = pool.autoscaling[0].total_min_node_count
      total_max_node_count   = pool.autoscaling[0].total_max_node_count
    } : {
      enabled = false
    }
  }
}

# Node configurations
output "node_configs" {
  description = "Map of node pool node configurations"
  value = {
    for k, pool in google_container_node_pool.node_pool : k => {
      machine_type      = pool.node_config[0].machine_type
      disk_size_gb      = pool.node_config[0].disk_size_gb
      disk_type         = pool.node_config[0].disk_type
      image_type        = pool.node_config[0].image_type
      service_account   = pool.node_config[0].service_account
      oauth_scopes      = pool.node_config[0].oauth_scopes
      preemptible       = pool.node_config[0].preemptible
      spot              = pool.node_config[0].spot
      local_ssd_count   = pool.node_config[0].local_ssd_count
      labels            = pool.node_config[0].labels
      tags              = pool.node_config[0].tags
      metadata          = pool.node_config[0].metadata
      boot_disk_kms_key = pool.node_config[0].boot_disk_kms_key
    }
  }
  sensitive = true
}

# Management settings
output "management_configs" {
  description = "Map of node pool management configurations"
  value = {
    for k, pool in google_container_node_pool.node_pool : k => {
      auto_repair  = pool.management[0].auto_repair
      auto_upgrade = pool.management[0].auto_upgrade
    }
  }
}
