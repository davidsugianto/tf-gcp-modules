variable "project_id" {
  description = "The project ID where routes will be created"
  type        = string
}

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

variable "labels" {
  description = "Labels to apply to route resources"
  type        = map(string)
  default     = {}
}

variable "names_prefix" {
  description = "Prefix to add to route names"
  type        = string
  default     = ""
}

variable "names_suffix" {
  description = "Suffix to add to route names"
  type        = string
  default     = ""
}
