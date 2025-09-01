# Subnets Sub-module

# Create subnets
resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnets

  project       = var.project_id
  name          = each.key
  network       = each.value.network
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  description   = each.value.description

  # Purpose and role (for special subnets like PSA)
  purpose      = each.value.purpose
  role         = each.value.role
  stack_type   = each.value.stack_type
  ipv6_access_type = each.value.ipv6_access_type

  # Private IP Google access
  private_ip_google_access   = each.value.private_ip_google_access
  private_ipv6_google_access = each.value.private_ipv6_google_access

  # Secondary IP ranges (for GKE pod and service ranges)
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  # Flow logs configuration
  dynamic "log_config" {
    for_each = each.value.enable_flow_logs && each.value.flow_logs_config != null ? [each.value.flow_logs_config] : []
    content {
      aggregation_interval = log_config.value.aggregation_interval
      flow_sampling        = log_config.value.flow_sampling
      metadata            = log_config.value.metadata
      metadata_fields     = log_config.value.metadata_fields
      filter_expr         = log_config.value.filter_expr
    }
  }

  # Enable basic flow logs if requested but no detailed config provided
  dynamic "log_config" {
    for_each = each.value.enable_flow_logs && each.value.flow_logs_config == null ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata            = "INCLUDE_ALL_METADATA"
    }
  }

  lifecycle {
    # Prevent destruction of critical subnets
    prevent_destroy = false
  }
}

# IAM bindings for subnets (for Shared VPC service projects)
resource "google_compute_subnetwork_iam_binding" "subnet_users" {
  for_each = var.subnet_iam_bindings

  project    = var.project_id
  region     = google_compute_subnetwork.subnet[each.value.subnet_name].region
  subnetwork = google_compute_subnetwork.subnet[each.value.subnet_name].name
  role       = each.value.role
  members    = each.value.members
}

# Regional addresses for subnet reservations
resource "google_compute_address" "subnet_addresses" {
  for_each = var.reserved_addresses

  project      = var.project_id
  name         = each.key
  region       = each.value.region
  address_type = each.value.address_type
  purpose      = lookup(each.value, "purpose", null)
  network_tier = lookup(each.value, "network_tier", null)
  subnetwork   = lookup(each.value, "subnetwork", null)
  address      = lookup(each.value, "address", null)
  
  # For subnet-specific addresses
  depends_on = [google_compute_subnetwork.subnet]
}
