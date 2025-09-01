# Project Sub-module Variables

# Required variables
variable "projects" {
  description = "Map of projects to create"
  type = map(object({
    project_id            = string
    project_name         = optional(string, null)
    folder_id            = optional(string, null)
    auto_create_network  = optional(bool, false)
    lien                = optional(bool, false)
    labels              = optional(map(string), {})
    usage_export_bucket = optional(string, null)
    usage_export_prefix = optional(string, "usage-")
  }))
}

variable "billing_account" {
  description = "The billing account ID to associate with projects"
  type        = string
}

# Organization settings
variable "organization_id" {
  description = "The organization ID where projects will be created"
  type        = string
  default     = null
}

variable "default_folder_id" {
  description = "Default folder ID for projects"
  type        = string
  default     = null
}

# Service account management
variable "default_service_account_action" {
  description = "Action to take on the default service account (keep, delete, disable, deprivilege)"
  type        = string
  default     = "keep"
  
  validation {
    condition = contains(["keep", "delete", "disable", "deprivilege"], var.default_service_account_action)
    error_message = "The default_service_account_action must be one of: keep, delete, disable, deprivilege."
  }
}

# Project settings
variable "skip_gcloud_download" {
  description = "Skip downloading gcloud during project creation"
  type        = bool
  default     = false
}

# Usage export settings
variable "enable_usage_export" {
  description = "Enable usage export to Cloud Storage"
  type        = bool
  default     = false
}

# Essential contacts
variable "essential_contacts" {
  description = "Map of essential contacts for projects"
  type = map(object({
    project_name           = string
    email                 = string
    language_tag          = string
    notification_categories = list(string)
  }))
  default = {}
}

# Access approval settings
variable "enable_access_approval" {
  description = "Enable Access Approval for projects"
  type        = bool
  default     = false
}

variable "access_approval_notification_emails" {
  description = "List of emails to notify for access approval requests"
  type        = list(string)
  default     = []
}

# Security settings
variable "enable_security_center" {
  description = "Enable Security Command Center for projects"
  type        = bool
  default     = false
}

variable "security_center_admins" {
  description = "List of members to grant Security Center admin role"
  type        = list(string)
  default     = []
}

# Labels and naming
variable "labels" {
  description = "Labels to apply to all projects"
  type        = map(string)
  default = {
    managed_by = "terraform"
    module     = "project-factory"
  }
}

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
