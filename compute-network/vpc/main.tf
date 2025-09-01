# VPC Networks Sub-module

# Create VPC networks
resource "google_compute_network" "vpc" {
  for_each = var.vpcs

  project                 = var.project_id
  name                    = each.key
  description            = each.value.description
  auto_create_subnetworks = each.value.auto_create_subnetworks
  routing_mode           = each.value.routing_mode
  mtu                    = each.value.mtu

  # IPv6 configuration
  enable_ula_internal_ipv6 = each.value.enable_ula_internal_ipv6
  internal_ipv6_range     = each.value.internal_ipv6_range

  # Firewall policy enforcement order
  network_firewall_policy_enforcement_order = each.value.network_firewall_policy_enforcement_order

  # Route management
  delete_default_routes_on_create = each.value.delete_default_routes_on_create

  # Prevent destruction of critical network
  lifecycle {
    prevent_destroy = false
  }
}

# Enable Shared VPC host project (if specified)
resource "google_compute_shared_vpc_host_project" "host" {
  count = var.shared_vpc_host_project ? 1 : 0

  project = var.project_id

  depends_on = [google_compute_network.vpc]
}

# VPC Flow Logs configuration (if enabled globally)
resource "google_compute_network_firewall_policy" "flow_logs_policy" {
  for_each = var.enable_flow_logs ? var.vpcs : {}

  project     = var.project_id
  name        = "${each.key}-flow-logs-policy"
  description = "Flow logs policy for VPC ${each.key}"
}

# Default internet gateway route (if not deleted)
resource "google_compute_route" "default_internet_gateway" {
  for_each = {
    for vpc_name, vpc_config in var.vpcs : vpc_name => vpc_config
    if !vpc_config.delete_default_routes_on_create
  }

  project          = var.project_id
  name             = "${each.key}-default-internet-gateway"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc[each.key].name
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  description      = "Default route to the Internet"

  depends_on = [google_compute_network.vpc]
}
