# Main Compute Network Module
# This module orchestrates the creation of VPC networks, subnets, routes, and firewall rules

# Create VPC networks
module "vpc" {
  source = "./vpc"

  project_id = var.project_id
  vpcs       = var.vpcs
  
  # Optional configurations
  shared_vpc_host_project = var.shared_vpc_host_project
  enable_flow_logs        = var.enable_flow_logs
}

# Create subnets
module "subnets" {
  source = "./subnets"

  project_id = var.project_id
  subnets    = var.subnets
  
  # Dependencies
  depends_on = [module.vpc]
}

# Create custom routes
module "routes" {
  source = "./routes"

  project_id = var.project_id
  routes     = var.routes
  
  # Dependencies
  depends_on = [module.vpc]
}

# Create firewall rules
module "firewall_rules" {
  source = "./firewall-rules"

  project_id     = var.project_id
  firewall_rules = var.firewall_rules
  
  # Dependencies
  depends_on = [module.vpc]
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset(var.required_apis)

  project = var.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = var.disable_on_destroy
}

# Global network peering (optional)
resource "google_compute_network_peering" "peering" {
  for_each = var.network_peerings

  name         = each.key
  network      = each.value.network
  peer_network = each.value.peer_network

  auto_create_routes                = lookup(each.value, "auto_create_routes", true)
  import_custom_routes              = lookup(each.value, "import_custom_routes", false)
  export_custom_routes              = lookup(each.value, "export_custom_routes", false)
  import_subnet_routes_with_public_ip = lookup(each.value, "import_subnet_routes_with_public_ip", false)
  export_subnet_routes_with_public_ip = lookup(each.value, "export_subnet_routes_with_public_ip", false)

  depends_on = [module.vpc]
}

# Cloud NAT (optional)
resource "google_compute_router" "nat_router" {
  for_each = var.cloud_nats

  project = var.project_id
  name    = "${each.key}-router"
  region  = each.value.region
  network = each.value.network

  depends_on = [module.vpc]
}

resource "google_compute_router_nat" "nat" {
  for_each = var.cloud_nats

  project = var.project_id
  name    = each.key
  router  = google_compute_router.nat_router[each.key].name
  region  = each.value.region

  nat_ip_allocate_option             = lookup(each.value, "nat_ip_allocate_option", "AUTO_ONLY")
  source_subnetwork_ip_ranges_to_nat = lookup(each.value, "source_subnetwork_ip_ranges_to_nat", "ALL_SUBNETWORKS_ALL_IP_RANGES")

  # Static NAT IPs (optional)
  dynamic "nat_ips" {
    for_each = lookup(each.value, "nat_ips", [])
    content {
      name = nat_ips.value
    }
  }

  # Subnetwork configuration (optional)
  dynamic "subnetwork" {
    for_each = lookup(each.value, "subnetworks", [])
    content {
      name                    = subnetwork.value.name
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat
      
      dynamic "secondary_ip_range_names" {
        for_each = lookup(subnetwork.value, "secondary_ip_range_names", [])
        content {
          name = secondary_ip_range_names.value
        }
      }
    }
  }

  log_config {
    enable = lookup(each.value, "enable_logging", false)
    filter = lookup(each.value, "log_filter", "ERRORS_ONLY")
  }

  depends_on = [google_compute_router.nat_router]
}

# Private Service Connect (optional)
resource "google_compute_global_address" "private_service_connect" {
  for_each = var.private_service_connects

  project      = var.project_id
  name         = each.key
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = each.value.network
  address_type = "INTERNAL"

  depends_on = [module.vpc]
}

resource "google_compute_global_forwarding_rule" "private_service_connect" {
  for_each = var.private_service_connects

  project               = var.project_id
  name                  = each.key
  target                = each.value.target
  port_range            = lookup(each.value, "port_range", null)
  ip_address            = google_compute_global_address.private_service_connect[each.key].address
  network               = each.value.network
  load_balancing_scheme = "INTERNAL"

  depends_on = [google_compute_global_address.private_service_connect]
}
