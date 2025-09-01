output "subnets" {
  description = "Map of subnet configurations"
  value = {
    for name, subnet in google_compute_subnetwork.subnet : name => {
      id                     = subnet.id
      name                   = subnet.name
      description           = subnet.description
      network               = subnet.network
      self_link             = subnet.self_link
      ip_cidr_range         = subnet.ip_cidr_range
      gateway_address       = subnet.gateway_address
      region                = subnet.region
      purpose               = subnet.purpose
      role                  = subnet.role
      stack_type            = subnet.stack_type
      ipv6_access_type      = subnet.ipv6_access_type
      ipv6_cidr_range       = subnet.ipv6_cidr_range
      internal_ipv6_prefix  = subnet.internal_ipv6_prefix
      external_ipv6_prefix  = subnet.external_ipv6_prefix
      private_ip_google_access   = subnet.private_ip_google_access
      private_ipv6_google_access = subnet.private_ipv6_google_access
      creation_timestamp    = subnet.creation_timestamp
      fingerprint          = subnet.fingerprint
      secondary_ip_ranges  = subnet.secondary_ip_range
    }
  }
}

output "subnet_names" {
  description = "Map of subnet names"
  value = {
    for name, subnet in google_compute_subnetwork.subnet : name => subnet.name
  }
}

output "subnet_self_links" {
  description = "Map of subnet self links"
  value = {
    for name, subnet in google_compute_subnetwork.subnet : name => subnet.self_link
  }
}

output "subnet_ip_ranges" {
  description = "Map of subnet IP CIDR ranges"
  value = {
    for name, subnet in google_compute_subnetwork.subnet : name => subnet.ip_cidr_range
  }
}

output "subnet_gateway_addresses" {
  description = "Map of subnet gateway addresses"
  value = {
    for name, subnet in google_compute_subnetwork.subnet : name => subnet.gateway_address
  }
}

output "secondary_ip_ranges" {
  description = "Map of secondary IP ranges by subnet"
  value = {
    for name, subnet in google_compute_subnetwork.subnet : name => [
      for range in subnet.secondary_ip_range : {
        range_name    = range.range_name
        ip_cidr_range = range.ip_cidr_range
      }
    ]
  }
}

output "subnet_iam_bindings" {
  description = "IAM bindings for subnets"
  value = {
    for name, binding in google_compute_subnetwork_iam_binding.subnet_users : name => {
      role       = binding.role
      members    = binding.members
      subnetwork = binding.subnetwork
      region     = binding.region
    }
  }
}

output "reserved_addresses" {
  description = "Reserved addresses in subnets"
  value = {
    for name, addr in google_compute_address.subnet_addresses : name => {
      name         = addr.name
      address      = addr.address
      address_type = addr.address_type
      region       = addr.region
      self_link    = addr.self_link
      status       = addr.status
      purpose      = addr.purpose
      network_tier = addr.network_tier
      subnetwork   = addr.subnetwork
    }
  }
}

# Grouped outputs for easier consumption
output "subnets_by_region" {
  description = "Subnets grouped by region"
  value = {
    for region in distinct([for subnet in google_compute_subnetwork.subnet : subnet.region]) : region => {
      for name, subnet in google_compute_subnetwork.subnet : name => subnet
      if subnet.region == region
    }
  }
}

output "subnets_by_network" {
  description = "Subnets grouped by network"
  value = {
    for network in distinct([for subnet in google_compute_subnetwork.subnet : subnet.network]) : network => {
      for name, subnet in google_compute_subnetwork.subnet : name => subnet
      if subnet.network == network
    }
  }
}

# Special purpose subnets
output "gke_subnets" {
  description = "Subnets with secondary ranges (typically used for GKE)"
  value = {
    for name, subnet in google_compute_subnetwork.subnet : name => subnet
    if length(subnet.secondary_ip_range) > 0
  }
}
