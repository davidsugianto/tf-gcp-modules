# Project Factory Variables

# Required variables
variable "organization_id" {
  description = "The organization ID where projects will be created"
  type        = string
  default     = null
}

variable "billing_account" {
  description = "The billing account ID to associate with projects"
  type        = string
}

# Project configuration
variable "projects" {
  description = "Map of projects to create with their configurations"
  type = map(object({
    # Basic project settings
    project_id              = string
    project_name           = optional(string, null)
    folder_id              = optional(string, null)
    auto_generate_suffix   = optional(bool, false)
    
    # Project features
    auto_create_network    = optional(bool, false)
    lien                  = optional(bool, false)
    
    # Services configuration
    services = optional(list(string), [])
    
    # IAM configuration
    iam_bindings = optional(map(object({
      role    = string
      members = list(string)
    })), {})
    
    # Service accounts
    service_accounts = optional(map(object({
      display_name  = optional(string, "")
      description   = optional(string, "Managed by Terraform")
      roles        = optional(list(string), [])
      key_rotation = optional(bool, false)
    })), {})
    
    # Custom roles
    custom_roles = optional(map(object({
      title       = string
      description = string
      permissions = list(string)
      stage       = optional(string, "GA")
    })), {})
    
    # Budget configuration
    budget = optional(object({
      amount = object({
        specified_amount = object({
          units         = string
          nanos         = optional(number, 0)
        })
        last_period_amount = optional(bool, false)
      })
      threshold_rules = optional(list(object({
        threshold_percent   = number
        spend_basis        = optional(string, "CURRENT_SPEND")
        forecast_options   = optional(object({
          forecast_period = object({
            start_date = object({
              year  = number
              month = number
              day   = number
            })
            end_date = object({
              year  = number
              month = number
              day   = number
            })
          })
        }), null)
      })), [])
      all_updates_rule = optional(object({
        monitoring_notification_channels   = optional(list(string), [])
        pubsub_topic                      = optional(string, null)
        schema_version                    = optional(string, "1.0")
        disable_default_iam_recipients    = optional(bool, false)
      }), null)
    }), null)
    
    # Labels
    labels = optional(map(string), {})
  }))
  default = {}
}

# Folder configuration
variable "folders" {
  description = "Map of organizational folders to create"
  type = map(object({
    parent_folder = optional(string, null)
  }))
  default = {}
}

variable "default_folder_id" {
  description = "Default folder ID for projects if not specified individually"
  type        = string
  default     = null
}

# Service configuration
variable "default_services" {
  description = "Default list of services to enable on all projects"
  type        = list(string)
  default = [
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com"
  ]
}

variable "disable_services_on_destroy" {
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

variable "service_account_impersonation" {
  description = "Service account to impersonate for API calls"
  type        = string
  default     = null
}

# IAM configuration
variable "default_service_account_action" {
  description = "Action to take on the default service account (keep, delete, disable, depriviege)"
  type        = string
  default     = "keep"
  
  validation {
    condition = contains(["keep", "delete", "disable", "deprivilege"], var.default_service_account_action)
    error_message = "The default_service_account_action must be one of: keep, delete, disable, deprivilege."
  }
}

variable "create_service_accounts" {
  description = "Whether to create service accounts defined in projects"
  type        = bool
  default     = true
}

# Shared VPC configuration
variable "shared_vpc_host_project" {
  description = "Project ID of the Shared VPC host project"
  type        = string
  default     = null
}

variable "shared_vpc_service_projects" {
  description = "Map of service projects to attach to Shared VPC"
  type = map(object({
    host_project = string
  }))
  default = {}
}

# Budget configuration
variable "currency_code" {
  description = "The 3-letter currency code defined in ISO 4217"
  type        = string
  default     = "USD"
}

variable "default_budget_amount" {
  description = "Default budget amount for projects"
  type = object({
    specified_amount = object({
      units = string
      nanos = optional(number, 0)
    })
    last_period_amount = optional(bool, false)
  })
  default = {
    specified_amount = {
      units = "1000"
      nanos = 0
    }
    last_period_amount = false
  }
}

variable "default_budget_alert_thresholds" {
  description = "Default budget alert thresholds"
  type = list(object({
    threshold_percent = number
    spend_basis      = optional(string, "CURRENT_SPEND")
  }))
  default = [
    {
      threshold_percent = 0.5
      spend_basis      = "CURRENT_SPEND"
    },
    {
      threshold_percent = 0.7
      spend_basis      = "CURRENT_SPEND"
    },
    {
      threshold_percent = 0.9
      spend_basis      = "CURRENT_SPEND"
    },
    {
      threshold_percent = 1.0
      spend_basis      = "CURRENT_SPEND"
    }
  ]
}

# Organization policies
variable "folder_organization_policies" {
  description = "Map of organization policies to apply to folders"
  type = map(object({
    folder_name = string
    constraint  = string
    
    boolean_policy = optional(object({
      enforced = bool
    }), null)
    
    list_policy = optional(object({
      inherit_from_parent = optional(bool, false)
      suggested_value    = optional(string, null)
      
      allow = optional(object({
        all    = optional(bool, false)
        values = optional(list(string), null)
      }), null)
      
      deny = optional(object({
        all    = optional(bool, false)
        values = optional(list(string), null)
      }), null)
    }), null)
    
    restore_policy = optional(bool, false)
  }))
  default = {}
}

variable "project_organization_policies" {
  description = "Map of organization policies to apply to projects"
  type = map(object({
    project_name = string
    constraint   = string
    
    boolean_policy = optional(object({
      enforced = bool
    }), null)
    
    list_policy = optional(object({
      inherit_from_parent = optional(bool, false)
      suggested_value    = optional(string, null)
      
      allow = optional(object({
        all    = optional(bool, false)
        values = optional(list(string), null)
      }), null)
      
      deny = optional(object({
        all    = optional(bool, false)
        values = optional(list(string), null)
      }), null)
    }), null)
    
    restore_policy = optional(bool, false)
  }))
  default = {}
}

# Project creation settings
variable "auto_create_network" {
  description = "Create the default network automatically"
  type        = bool
  default     = false
}

variable "lien" {
  description = "Add a lien on the project to prevent accidental deletion"
  type        = bool
  default     = false
}

variable "skip_gcloud_download" {
  description = "Skip downloading gcloud during project creation"
  type        = bool
  default     = false
}

# Security and compliance
variable "enable_essential_contacts" {
  description = "Enable Essential Contacts API and set admin"
  type        = bool
  default     = false
}

variable "essential_contacts_admin_member" {
  description = "Member to grant Essential Contacts Admin role"
  type        = string
  default     = null
}

variable "enable_audit_logs" {
  description = "Enable audit logs for all projects"
  type        = bool
  default     = true
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

# Validation rules
variable "project_id_validation" {
  description = "Enable project ID validation"
  type        = bool
  default     = true
}

variable "allowed_project_id_pattern" {
  description = "Regex pattern for allowed project IDs"
  type        = string
  default     = "^[a-z][a-z0-9-]{4,28}[a-z0-9]$"
}
