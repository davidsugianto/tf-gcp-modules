# Services Sub-module Variables

# Required variables
variable "projects" {
  description = "Map of projects with their service configurations"
  type = map(object({
    project_id = string
    services   = list(string)
  }))
}

# Service configuration
variable "disable_on_destroy" {
  description = "Whether to disable services when the project is destroyed"
  type        = bool
  default     = false
}

variable "disable_dependent_services" {
  description = "Whether to disable dependent services when disabling a service"
  type        = bool
  default     = false
}

variable "enable_apis_on_boot" {
  description = "Whether to enable APIs immediately after project creation"
  type        = bool
  default     = true
}

variable "service_enablement_delay" {
  description = "Delay before enabling services"
  type        = string
  default     = "30s"
}

# Service account impersonation
variable "service_account_impersonation" {
  description = "Service account to impersonate for API calls"
  type        = string
  default     = null
}

variable "impersonation_roles" {
  description = "List of roles to grant to impersonation service accounts"
  type        = list(string)
  default = [
    "roles/editor",
    "roles/serviceusage.serviceUsageAdmin"
  ]
}

# Quota management
variable "quota_overrides" {
  description = "Map of quota overrides for services"
  type = map(object({
    project_id     = string
    service        = string
    metric         = string
    limit          = string
    override_value = string
    force          = optional(bool, false)
  }))
  default = {}
}

# Advanced service configurations
variable "api_gateway_configs" {
  description = "Map of API Gateway configurations"
  type = map(object({
    project_id   = string
    api_id       = string
    display_name = string
  }))
  default = {}
}

variable "endpoints_configs" {
  description = "Map of Cloud Endpoints configurations"
  type = map(object({
    project_id     = string
    service_name   = string
    openapi_config = string
  }))
  default = {}
}

variable "service_networking_connections" {
  description = "Map of service networking connections"
  type = map(object({
    network                 = string
    service                = string
    reserved_peering_ranges = list(string)
  }))
  default = {}
}

variable "cloud_functions" {
  description = "Map of Cloud Functions configurations"
  type = map(object({
    project_id    = string
    name         = string
    location     = string
    runtime      = string
    entry_point  = string
    source_bucket = string
    source_object = string
    max_instances = optional(number, 100)
    memory       = optional(string, "256Mi")
    timeout      = optional(number, 60)
  }))
  default = {}
}

variable "monitoring_notification_channels" {
  description = "Map of monitoring notification channel configurations"
  type = map(object({
    project_id   = string
    display_name = string
    type        = string
    labels      = map(string)
    description = optional(string, "")
  }))
  default = {}
}

variable "cloud_run_services" {
  description = "Map of Cloud Run service configurations"
  type = map(object({
    project_id           = string
    name                = string
    location            = string
    image               = string
    environment_variables = optional(map(string), {})
    resource_limits     = optional(map(string), {})
    concurrency         = optional(number, 100)
    timeout             = optional(number, 300)
    max_scale           = optional(number, 100)
    min_scale           = optional(number, 0)
    annotations         = optional(map(string), {})
  }))
  default = {}
}

# Labels and naming
variable "names_prefix" {
  description = "Prefix to add to all resource names"
  type        = string
  default     = ""
}

variable "names_suffix" {
  description = "Suffix to add to all resource names"  
  type        = string
  default     = ""
}
