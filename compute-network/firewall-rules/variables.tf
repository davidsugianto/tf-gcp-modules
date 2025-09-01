variable "project_id" {
  description = "The project ID where firewall rules will be created"
  type        = string
}

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

variable "security_policies" {
  description = "Map of Cloud Armor security policy configurations"
  type = map(object({
    description               = optional(string, "Managed by Terraform")
    default_rule_action      = optional(string, "deny(403)")
    enable_adaptive_protection = optional(bool, false)
    adaptive_protection_rule_visibility = optional(string, "STANDARD")
    
    # Custom rules
    rules = optional(list(object({
      action        = string
      priority      = number
      description   = optional(string, "")
      src_ip_ranges = list(string)
      
      # Rate limiting
      rate_limit_options = optional(object({
        conform_action      = string
        exceed_action       = string
        enforce_on_key      = optional(string, null)
        enforce_on_key_name = optional(string, null)
        
        rate_limit_threshold = object({
          count        = number
          interval_sec = number
        })
      }), null)
    })), [])
  }))
  default = {}
}

variable "network_endpoint_groups" {
  description = "Map of network endpoint group configurations"
  type = map(object({
    network               = string
    subnetwork           = optional(string, null)
    zone                 = optional(string, null)
    description          = optional(string, "Managed by Terraform")
    network_endpoint_type = optional(string, "GCE_VM_IP_PORT")
    default_port         = optional(number, null)
  }))
  default = {}
}

variable "backend_services_with_security_policies" {
  description = "Map of backend services with attached security policies"
  type = map(object({
    description           = optional(string, "Managed by Terraform")
    protocol             = optional(string, "HTTP")
    port_name           = optional(string, null)
    timeout_sec         = optional(number, 30)
    enable_cdn          = optional(bool, false)
    security_policy_name = string
    
    # Health checks
    health_checks = optional(list(string), [])
    
    # Backends
    backends = optional(list(object({
      group           = string
      balancing_mode  = optional(string, "UTILIZATION")
      capacity_scaler = optional(number, 1.0)
      description     = optional(string, "")
      max_connections = optional(number, null)
      max_rate        = optional(number, null)
      max_utilization = optional(number, 0.8)
    })), [])
  }))
  default = {}
}

variable "labels" {
  description = "Labels to apply to firewall resources"
  type        = map(string)
  default     = {}
}

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
