# Routes Sub-module

# Create custom routes
resource "google_compute_route" "routes" {
  for_each = var.routes

  project      = var.project_id
  name         = each.key
  description  = each.value.description
  dest_range   = each.value.dest_range
  network      = each.value.network
  priority     = each.value.priority
  tags         = each.value.tags

  # Next hop configuration (only one should be specified)
  next_hop_gateway    = each.value.next_hop_gateway
  next_hop_ip         = each.value.next_hop_ip
  next_hop_instance   = each.value.next_hop_instance
  next_hop_vpn_tunnel = each.value.next_hop_vpn_tunnel
  next_hop_ilb        = each.value.next_hop_ilb

  # Lifecycle management
  lifecycle {
    # Prevent destruction of critical routes
    prevent_destroy = false
  }
}
