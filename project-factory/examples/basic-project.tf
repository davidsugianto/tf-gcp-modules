# Basic Project Factory Example
# This example demonstrates how to create a simple project with basic configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

# Variables
variable "billing_account" {
  description = "The billing account ID to associate with the project"
  type        = string
}

variable "organization_id" {
  description = "The organization ID where the project will be created"
  type        = string
  default     = null
}

variable "folder_id" {
  description = "The folder ID where the project will be created"
  type        = string
  default     = null
}

# Basic Project Creation
module "basic_project" {
  source = "../"

  # Required settings
  billing_account = var.billing_account
  organization_id = var.organization_id
  default_folder_id = var.folder_id

  # Project configuration
  projects = {
    "my-app-project" = {
      project_id          = "my-app-dev"
      project_name        = "My Application Development"
      auto_generate_suffix = true  # Will append random suffix
      folder_id           = var.folder_id
      
      # Basic settings
      auto_create_network = false
      lien               = false
      
      # Services to enable
      services = [
        "compute.googleapis.com",
        "storage.googleapis.com",
        "cloudbuild.googleapis.com",
        "containerregistry.googleapis.com",
        "monitoring.googleapis.com",
        "logging.googleapis.com"
      ]
      
      # IAM bindings
      iam_bindings = {
        "developers" = {
          role = "roles/editor"
          members = [
            "group:developers@example.com",
            "user:developer1@example.com"
          ]
        }
        "viewers" = {
          role = "roles/viewer"
          members = [
            "group:managers@example.com"
          ]
        }
      }
      
      # Service accounts
      service_accounts = {
        "app-service-account" = {
          display_name = "Application Service Account"
          description  = "Service account for the application"
          roles = [
            "roles/storage.objectViewer",
            "roles/monitoring.metricWriter"
          ]
        }
      }
      
      # Budget configuration
      budget = {
        amount = {
          specified_amount = {
            units = "100"  # $100 USD
            nanos = 0
          }
        }
        threshold_rules = [
          {
            threshold_percent = 0.5  # 50%
            spend_basis      = "CURRENT_SPEND"
          },
          {
            threshold_percent = 0.8  # 80%
            spend_basis      = "CURRENT_SPEND"
          },
          {
            threshold_percent = 1.0  # 100%
            spend_basis      = "CURRENT_SPEND"
          }
        ]
        all_updates_rule = {
          monitoring_notification_channels = []
          pubsub_topic                    = null
          disable_default_iam_recipients  = false
        }
      }
      
      # Labels
      labels = {
        environment    = "development"
        team          = "platform"
        application   = "my-app"
        cost_center   = "engineering"
        owner         = "platform-team"
      }
    }
  }

  # Global settings
  auto_create_network = false
  lien               = false
  
  # Service settings
  disable_services_on_destroy = false
  enable_apis_on_boot         = true
  
  # IAM settings
  default_service_account_action = "keep"
  create_service_accounts        = true
  
  # Budget settings
  currency_code = "USD"
  
  # Security settings
  enable_audit_logs = true
  
  # Labels
  labels = {
    managed_by = "terraform"
    module     = "project-factory"
    example    = "basic-project"
  }
}

# Outputs
output "project_info" {
  description = "Information about the created project"
  value = {
    project_id     = module.basic_project.project_ids["my-app-project"]
    project_name   = module.basic_project.project_names["my-app-project"]
    project_number = module.basic_project.project_numbers["my-app-project"]
  }
}

output "enabled_services" {
  description = "Services enabled on the project"
  value       = module.basic_project.enabled_services["my-app-project"]
}

output "service_accounts" {
  description = "Created service accounts"
  value       = module.basic_project.service_accounts["my-app-project"]
  sensitive   = true
}

output "budget_info" {
  description = "Budget information"
  value       = module.basic_project.budgets["my-app-project"]
}

output "project_summary" {
  description = "Project summary"
  value       = module.basic_project.project_summary["my-app-project"]
}
