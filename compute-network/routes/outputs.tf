output "routes" {
  description = "Map of route configurations"
  value = {
    for name, route in google_compute_route.routes : name => {
      id                  = route.id
      name                = route.name
      description         = route.description
      self_link           = route.self_link
      dest_range          = route.dest_range
      network             = route.network
      priority            = route.priority
      tags                = route.tags
      next_hop_gateway    = route.next_hop_gateway
      next_hop_ip         = route.next_hop_ip
      next_hop_instance   = route.next_hop_instance
      next_hop_vpn_tunnel = route.next_hop_vpn_tunnel
      next_hop_ilb        = route.next_hop_ilb
      next_hop_network    = route.next_hop_network
    }
  }
}

output "route_names" {
  description = "Map of route names"
  value = {
    for name, route in google_compute_route.routes : name => route.name
  }
}

output "route_self_links" {
  description = "Map of route self links"
  value = {
    for name, route in google_compute_route.routes : name => route.self_link
  }
}

output "route_ids" {
  description = "Map of route IDs"
  value = {
    for name, route in google_compute_route.routes : name => route.id
  }
}

# Grouped outputs for easier consumption
output "routes_by_network" {
  description = "Routes grouped by network"
  value = {
    for network in distinct([for route in google_compute_route.routes : route.network]) : network => {
      for name, route in google_compute_route.routes : name => route
      if route.network == network
    }
  }
}

output "routes_by_priority" {
  description = "Routes grouped by priority"
  value = {
    for priority in distinct([for route in google_compute_route.routes : tostring(route.priority)]) : priority => {
      for name, route in google_compute_route.routes : name => route
      if tostring(route.priority) == priority
    }
  }
}

output "default_routes" {
  description = "Default routes (0.0.0.0/0)"
  value = {
    for name, route in google_compute_route.routes : name => route
    if route.dest_range == "0.0.0.0/0"
  }
}

output "custom_routes" {
  description = "Custom routes (non-default)"
  value = {
    for name, route in google_compute_route.routes : name => route
    if route.dest_range != "0.0.0.0/0"
  }
}
