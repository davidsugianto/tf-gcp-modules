variable "project_id" {
  description = "The project ID where subnets will be created"
  type        = string
}

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

variable "subnet_iam_bindings" {
  description = "IAM bindings for subnets (useful for Shared VPC)"
  type = map(object({
    subnet_name = string
    role        = string
    members     = list(string)
  }))
  default = {}
}

variable "reserved_addresses" {
  description = "Reserved IP addresses in subnets"
  type = map(object({
    region       = string
    address_type = optional(string, "INTERNAL")
    purpose      = optional(string, null)
    network_tier = optional(string, null)
    subnetwork   = optional(string, null)
    address      = optional(string, null)
  }))
  default = {}
}
