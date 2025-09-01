# VPC outputs
output "vpcs" {
  description = "VPC network information from the vpc sub-module"
  value       = module.vpc.vpcs
}

output "vpc_names" {
  description = "Map of VPC names"
  value       = module.vpc.vpc_names
}

output "vpc_self_links" {
  description = "Map of VPC self links"
  value       = module.vpc.vpc_self_links
}

# Subnet outputs
output "subnets" {
  description = "Subnet information from the subnets sub-module"
  value       = module.subnets.subnets
}

output "subnet_names" {
  description = "Map of subnet names"
  value       = module.subnets.subnet_names
}

output "subnet_self_links" {
  description = "Map of subnet self links"
  value       = module.subnets.subnet_self_links
}

output "subnet_ip_ranges" {
  description = "Map of subnet IP CIDR ranges"
  value       = module.subnets.subnet_ip_ranges
}

output "secondary_ip_ranges" {
  description = "Map of secondary IP ranges by subnet"
  value       = module.subnets.secondary_ip_ranges
}

# Route outputs
output "routes" {
  description = "Route information from the routes sub-module"
  value       = module.routes.routes
}

output "route_names" {
  description = "Map of route names"
  value       = module.routes.route_names
}

# Firewall rule outputs
output "firewall_rules" {
  description = "Firewall rule information from the firewall-rules sub-module"
  value       = module.firewall_rules.firewall_rules
}

output "firewall_rule_names" {
  description = "Map of firewall rule names"
  value       = module.firewall_rules.firewall_rule_names
}

# Network peering outputs
output "network_peerings" {
  description = "Network peering configurations"
  value = {
    for name, peering in google_compute_network_peering.peering : name => {
      name         = peering.name
      network      = peering.network
      peer_network = peering.peer_network
      state        = peering.state
      state_details = peering.state_details
    }
  }
}

# Cloud NAT outputs
output "cloud_nats" {
  description = "Cloud NAT configurations"
  value = {
    for name, nat in google_compute_router_nat.nat : name => {
      name                               = nat.name
      router                            = nat.router
      region                            = nat.region
      nat_ip_allocate_option            = nat.nat_ip_allocate_option
      source_subnetwork_ip_ranges_to_nat = nat.source_subnetwork_ip_ranges_to_nat
    }
  }
}

output "nat_routers" {
  description = "Cloud Router configurations for NAT"
  value = {
    for name, router in google_compute_router.nat_router : name => {
      name    = router.name
      region  = router.region
      network = router.network
    }
  }
}

# Private Service Connect outputs
output "private_service_connects" {
  description = "Private Service Connect configurations"
  value = {
    for name, psc in google_compute_global_forwarding_rule.private_service_connect : name => {
      name                  = psc.name
      ip_address           = psc.ip_address
      target               = psc.target
      network              = psc.network
      load_balancing_scheme = psc.load_balancing_scheme
    }
  }
}

output "private_service_connect_addresses" {
  description = "Private Service Connect addresses"
  value = {
    for name, addr in google_compute_global_address.private_service_connect : name => {
      name         = addr.name
      address      = addr.address
      address_type = addr.address_type
      purpose      = addr.purpose
      network      = addr.network
    }
  }
}

# Summary outputs for easy reference
output "network_summary" {
  description = "Summary of all network resources created"
  value = {
    vpcs_created          = length(module.vpc.vpcs)
    subnets_created       = length(module.subnets.subnets)
    routes_created        = length(module.routes.routes)
    firewall_rules_created = length(module.firewall_rules.firewall_rules)
    peerings_created      = length(google_compute_network_peering.peering)
    cloud_nats_created    = length(google_compute_router_nat.nat)
    psc_created           = length(google_compute_global_forwarding_rule.private_service_connect)
  }
}

# Network topology for visualization
output "network_topology" {
  description = "Network topology information for documentation/visualization"
  value = {
    vpcs = {
      for vpc_name, vpc in module.vpc.vpcs : vpc_name => {
        name         = vpc.name
        self_link    = vpc.self_link
        routing_mode = vpc.routing_mode
        subnets = {
          for subnet_name, subnet in module.subnets.subnets : subnet_name => {
            name            = subnet.name
            region          = subnet.region
            ip_cidr_range   = subnet.ip_cidr_range
            secondary_ranges = lookup(module.subnets.secondary_ip_ranges, subnet_name, [])
          }
          if subnet.network == vpc.self_link
        }
        firewall_rules = [
          for fw_name, fw in module.firewall_rules.firewall_rules : fw_name
          if fw.network == vpc.self_link
        ]
        routes = [
          for route_name, route in module.routes.routes : route_name
          if route.network == vpc.self_link
        ]
      }
    }
  }
}

# Regional information
output "regional_resources" {
  description = "Resources grouped by region"
  value = {
    for region in distinct([for subnet in module.subnets.subnets : subnet.region]) : region => {
      subnets = {
        for subnet_name, subnet in module.subnets.subnets : subnet_name => subnet
        if subnet.region == region
      }
      cloud_nats = {
        for nat_name, nat in google_compute_router_nat.nat : nat_name => nat
        if nat.region == region
      }
    }
  }
}
