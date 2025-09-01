# Required variables
variable "project_id" {
  description = "The project ID where network resources will be created"
  type        = string
}

# VPC configuration
variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    # Basic VPC settings
    description                     = optional(string, "Managed by Terraform")
    auto_create_subnetworks        = optional(bool, false)
    routing_mode                   = optional(string, "REGIONAL")
    mtu                            = optional(number, 1460)
    enable_ula_internal_ipv6       = optional(bool, false)
    internal_ipv6_range            = optional(string, null)
    network_firewall_policy_enforcement_order = optional(string, "AFTER_CLASSIC_FIREWALL")
    
    # Flow logs
    enable_flow_logs = optional(bool, false)
    
    # Deletion protection
    delete_default_routes_on_create = optional(bool, false)
  }))
  default = {}
}

# Subnet configuration
variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    # Required settings
    network       = string
    ip_cidr_range = string
    region        = string
    
    # Optional settings
    description   = optional(string, "Managed by Terraform")
    purpose       = optional(string, null)
    role          = optional(string, null)
    stack_type    = optional(string, "IPV4_ONLY")
    ipv6_access_type = optional(string, null)
    
    # Private IP Google Access
    private_ip_google_access   = optional(bool, true)
    private_ipv6_google_access = optional(string, null)
    
    # Secondary IP ranges
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
    
    # Flow logs
    enable_flow_logs = optional(bool, false)
    flow_logs_config = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_SEC")
      flow_sampling        = optional(number, 0.5)
      metadata            = optional(string, "INCLUDE_ALL_METADATA")
      metadata_fields     = optional(list(string), [])
      filter_expr         = optional(string, null)
    }), null)
  }))
  default = {}
}

# Routes configuration
variable "routes" {
  description = "Map of custom route configurations"
  type = map(object({
    # Required settings
    dest_range   = string
    network      = string
    priority     = optional(number, 1000)
    description  = optional(string, "Managed by Terraform")
    
    # Route target (one of these must be specified)
    next_hop_gateway    = optional(string, null)
    next_hop_ip         = optional(string, null)
    next_hop_instance   = optional(string, null)
    next_hop_vpn_tunnel = optional(string, null)
    next_hop_ilb        = optional(string, null)
    
    # Tags
    tags = optional(list(string), [])
  }))
  default = {}
}

# Firewall rules configuration
variable "firewall_rules" {
  description = "Map of firewall rule configurations"
  type = map(object({
    # Required settings
    network   = string
    direction = optional(string, "INGRESS")
    priority  = optional(number, 1000)
    
    # Optional settings
    description                 = optional(string, "Managed by Terraform")
    disabled                   = optional(bool, false)
    enable_logging             = optional(bool, false)
    log_config_metadata        = optional(string, "INCLUDE_ALL_METADATA")
    
    # Source/Target configuration
    source_ranges              = optional(list(string), [])
    destination_ranges         = optional(list(string), [])
    source_tags                = optional(list(string), [])
    target_tags                = optional(list(string), [])
    source_service_accounts    = optional(list(string), [])
    target_service_accounts    = optional(list(string), [])
    
    # Rules
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = {}
}

# Network peering configuration
variable "network_peerings" {
  description = "Map of network peering configurations"
  type = map(object({
    network                             = string
    peer_network                        = string
    auto_create_routes                  = optional(bool, true)
    import_custom_routes                = optional(bool, false)
    export_custom_routes                = optional(bool, false)
    import_subnet_routes_with_public_ip = optional(bool, false)
    export_subnet_routes_with_public_ip = optional(bool, false)
  }))
  default = {}
}

# Cloud NAT configuration
variable "cloud_nats" {
  description = "Map of Cloud NAT configurations"
  type = map(object({
    region  = string
    network = string
    
    # NAT configuration
    nat_ip_allocate_option                = optional(string, "AUTO_ONLY")
    source_subnetwork_ip_ranges_to_nat    = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")
    nat_ips                              = optional(list(string), [])
    
    # Subnetwork configuration
    subnetworks = optional(list(object({
      name                    = string
      source_ip_ranges_to_nat = list(string)
      secondary_ip_range_names = optional(list(string), [])
    })), [])
    
    # Logging
    enable_logging = optional(bool, false)
    log_filter     = optional(string, "ERRORS_ONLY")
    
    # Advanced settings
    min_ports_per_vm                 = optional(number, null)
    max_ports_per_vm                 = optional(number, null)
    enable_endpoint_independent_mapping = optional(bool, null)
    udp_idle_timeout_sec            = optional(number, null)
    icmp_idle_timeout_sec           = optional(number, null)
    tcp_established_idle_timeout_sec = optional(number, null)
    tcp_transitory_idle_timeout_sec  = optional(number, null)
    tcp_time_wait_timeout_sec       = optional(number, null)
  }))
  default = {}
}

# Private Service Connect configuration
variable "private_service_connects" {
  description = "Map of Private Service Connect configurations"
  type = map(object({
    network    = string
    target     = string
    port_range = optional(string, null)
  }))
  default = {}
}

# Shared VPC configuration
variable "shared_vpc_host_project" {
  description = "Enable this project as a Shared VPC host project"
  type        = bool
  default     = false
}

# Global settings
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs globally"
  type        = bool
  default     = false
}

variable "disable_on_destroy" {
  description = "Disable services on destroy"
  type        = bool
  default     = false
}

# Required APIs
variable "required_apis" {
  description = "List of APIs to enable"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com"
  ]
}

# Labels
variable "labels" {
  description = "Labels to apply to network resources"
  type        = map(string)
  default     = {}
}

# Naming configuration
variable "names_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = ""
}

variable "names_suffix" {
  description = "Suffix to add to resource names"
  type        = string
  default     = ""
}
