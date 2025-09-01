output "vpcs" {
  description = "Map of VPC network configurations"
  value = {
    for name, vpc in google_compute_network.vpc : name => {
      id                      = vpc.id
      name                    = vpc.name
      description            = vpc.description
      self_link              = vpc.self_link
      routing_mode           = vpc.routing_mode
      mtu                    = vpc.mtu
      gateway_ipv4           = vpc.gateway_ipv4
      enable_ula_internal_ipv6 = vpc.enable_ula_internal_ipv6
      internal_ipv6_range    = vpc.internal_ipv6_range
      auto_create_subnetworks = vpc.auto_create_subnetworks
      delete_default_routes_on_create = vpc.delete_default_routes_on_create
      network_firewall_policy_enforcement_order = vpc.network_firewall_policy_enforcement_order
    }
  }
}

output "vpc_names" {
  description = "Map of VPC names"
  value = {
    for name, vpc in google_compute_network.vpc : name => vpc.name
  }
}

output "vpc_self_links" {
  description = "Map of VPC self links"
  value = {
    for name, vpc in google_compute_network.vpc : name => vpc.self_link
  }
}

output "vpc_ids" {
  description = "Map of VPC IDs"
  value = {
    for name, vpc in google_compute_network.vpc : name => vpc.id
  }
}

output "shared_vpc_host" {
  description = "Shared VPC host project configuration"
  value = length(google_compute_shared_vpc_host_project.host) > 0 ? {
    project = google_compute_shared_vpc_host_project.host[0].project
  } : null
}

output "default_routes" {
  description = "Default internet gateway routes"
  value = {
    for name, route in google_compute_route.default_internet_gateway : name => {
      name         = route.name
      dest_range   = route.dest_range
      network      = route.network
      priority     = route.priority
      description  = route.description
    }
  }
}

output "flow_logs_policies" {
  description = "VPC Flow Logs policies"
  value = {
    for name, policy in google_compute_network_firewall_policy.flow_logs_policy : name => {
      name        = policy.name
      description = policy.description
    }
  }
}
