variable "project_id" {
  description = "The project ID where VPC networks will be created"
  type        = string
}

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

variable "shared_vpc_host_project" {
  description = "Enable this project as a Shared VPC host project"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs globally"
  type        = bool
  default     = false
}

variable "enable_default_firewall_rules" {
  description = "Enable default firewall rules for VPCs"
  type        = bool
  default     = false
}

variable "ssh_source_ranges" {
  description = "Source IP ranges for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "icmp_source_ranges" {
  description = "Source IP ranges for ICMP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "private_service_ranges" {
  description = "Map of private service connection configurations"
  type = map(object({
    vpc_name      = string
    prefix_length = number
    description   = optional(string, "Private service range")
  }))
  default = {}
}

variable "labels" {
  description = "Labels to apply to VPC resources"
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
