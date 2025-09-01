# Multi-Environment Project Factory Example
# This example demonstrates creating multiple projects for different environments

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
  }
}

# Variables
variable "billing_account" {
  description = "The billing account ID"
  type        = string
}

variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "myapp"
}

# Multi-Environment Project Setup
module "multi_env_projects" {
  source = "../"

  billing_account = var.billing_account
  organization_id = var.organization_id

  # Create folders for environment organization
  folders = {
    "development" = {
      parent_folder = null
    }
    "staging" = {
      parent_folder = null
    }
    "production" = {
      parent_folder = null
    }
  }

  # Project configurations for different environments
  projects = {
    # Development Environment
    "${var.app_name}-dev" = {
      project_id          = "${var.app_name}-dev"
      project_name        = "${title(var.app_name)} Development"
      auto_generate_suffix = true
      folder_id           = null  # Will be set to dev folder after creation
      
      auto_create_network = false
      lien               = false
      
      services = [
        "compute.googleapis.com",
        "storage.googleapis.com",
        "cloudbuild.googleapis.com",
        "container.googleapis.com",
        "pubsub.googleapis.com",
        "monitoring.googleapis.com",
        "logging.googleapis.com",
        "cloudtrace.googleapis.com"
      ]
      
      iam_bindings = {
        "developers" = {
          role = "roles/editor"
          members = [
            "group:${var.app_name}-developers@example.com"
          ]
        }
        "qa-team" = {
          role = "roles/viewer"
          members = [
            "group:qa-team@example.com"
          ]
        }
      }
      
      service_accounts = {
        "app-dev-sa" = {
          display_name = "Development Application SA"
          description  = "Service account for dev environment"
          roles = [
            "roles/storage.objectAdmin",
            "roles/pubsub.editor",
            "roles/monitoring.metricWriter"
          ]
        }
        "ci-cd-sa" = {
          display_name = "CI/CD Service Account"
          description  = "Service account for CI/CD pipeline"
          roles = [
            "roles/cloudbuild.builds.editor",
            "roles/storage.admin"
          ]
        }
      }
      
      budget = {
        amount = {
          specified_amount = {
            units = "500"
            nanos = 0
          }
        }
        threshold_rules = [
          {
            threshold_percent = 0.5
            spend_basis      = "CURRENT_SPEND"
          },
          {
            threshold_percent = 1.0
            spend_basis      = "CURRENT_SPEND"
          }
        ]
      }
      
      labels = {
        environment = "development"
        team        = "engineering"
        application = var.app_name
        cost_center = "development"
      }
    }

    # Staging Environment
    "${var.app_name}-staging" = {
      project_id          = "${var.app_name}-staging"
      project_name        = "${title(var.app_name)} Staging"
      auto_generate_suffix = true
      
      auto_create_network = false
      lien               = true  # Prevent accidental deletion
      
      services = [
        "compute.googleapis.com",
        "storage.googleapis.com",
        "container.googleapis.com",
        "pubsub.googleapis.com",
        "monitoring.googleapis.com",
        "logging.googleapis.com",
        "cloudtrace.googleapis.com",
        "secretmanager.googleapis.com"
      ]
      
      iam_bindings = {
        "staging-admins" = {
          role = "roles/editor"
          members = [
            "group:${var.app_name}-leads@example.com"
          ]
        }
        "developers" = {
          role = "roles/viewer"
          members = [
            "group:${var.app_name}-developers@example.com"
          ]
        }
      }
      
      service_accounts = {
        "app-staging-sa" = {
          display_name = "Staging Application SA"
          description  = "Service account for staging environment"
          roles = [
            "roles/storage.objectAdmin",
            "roles/pubsub.editor",
            "roles/secretmanager.secretAccessor"
          ]
        }
      }
      
      budget = {
        amount = {
          specified_amount = {
            units = "1000"
            nanos = 0
          }
        }
        threshold_rules = [
          {
            threshold_percent = 0.5
            spend_basis      = "CURRENT_SPEND"
          },
          {
            threshold_percent = 0.8
            spend_basis      = "CURRENT_SPEND"
          },
          {
            threshold_percent = 1.0
            spend_basis      = "CURRENT_SPEND"
          }
        ]
      }
      
      labels = {
        environment = "staging"
        team        = "engineering"
        application = var.app_name
        cost_center = "staging"
      }
    }

    # Production Environment
    "${var.app_name}-prod" = {
      project_id          = "${var.app_name}-prod"
      project_name        = "${title(var.app_name)} Production"
      auto_generate_suffix = false  # Keep consistent prod project ID
      
      auto_create_network = false
      lien               = true  # Definitely prevent deletion
      
      services = [
        "compute.googleapis.com",
        "storage.googleapis.com",
        "container.googleapis.com",
        "pubsub.googleapis.com",
        "monitoring.googleapis.com",
        "logging.googleapis.com",
        "cloudtrace.googleapis.com",
        "secretmanager.googleapis.com",
        "cloudkms.googleapis.com",
        "dns.googleapis.com"
      ]
      
      iam_bindings = {
        "prod-admins" = {
          role = "roles/editor"
          members = [
            "group:${var.app_name}-production-admins@example.com"
          ]
        }
        "monitoring-team" = {
          role = "roles/monitoring.viewer"
          members = [
            "group:sre-team@example.com"
          ]
        }
        "security-team" = {
          role = "roles/viewer"
          members = [
            "group:security-team@example.com"
          ]
        }
      }
      
      service_accounts = {
        "app-prod-sa" = {
          display_name = "Production Application SA"
          description  = "Service account for production environment"
          roles = [
            "roles/storage.objectViewer",
            "roles/pubsub.subscriber",
            "roles/secretmanager.secretAccessor",
            "roles/cloudkms.cryptoKeyEncrypterDecrypter"
          ]
        }
        "backup-sa" = {
          display_name = "Backup Service Account"
          description  = "Service account for backup operations"
          roles = [
            "roles/storage.admin"
          ]
        }
      }
      
      custom_roles = {
        "app-limited-editor" = {
          title       = "Application Limited Editor"
          description = "Limited editor role for application team"
          permissions = [
            "compute.instances.start",
            "compute.instances.stop",
            "storage.objects.get",
            "storage.objects.create",
            "pubsub.messages.publish"
          ]
        }
      }
      
      budget = {
        amount = {
          specified_amount = {
            units = "5000"
            nanos = 0
          }
        }
        threshold_rules = [
          {
            threshold_percent = 0.3
            spend_basis      = "CURRENT_SPEND"
          },
          {
            threshold_percent = 0.5
            spend_basis      = "CURRENT_SPEND"
          },
          {
            threshold_percent = 0.8
            spend_basis      = "CURRENT_SPEND"
          },
          {
            threshold_percent = 1.0
            spend_basis      = "CURRENT_SPEND"
          }
        ]
      }
      
      labels = {
        environment = "production"
        team        = "engineering"
        application = var.app_name
        cost_center = "production"
        criticality = "high"
      }
    }
  }

  # Organization policies for compliance
  project_organization_policies = {
    "disable-vm-external-ip-dev" = {
      project_name = "${var.app_name}-dev"
      constraint   = "compute.vmExternalIpAccess"
      list_policy = {
        allow = {
          all = true
        }
      }
    }
    
    "disable-vm-external-ip-staging" = {
      project_name = "${var.app_name}-staging"
      constraint   = "compute.vmExternalIpAccess"
      list_policy = {
        deny = {
          all = true
        }
      }
    }
    
    "disable-vm-external-ip-prod" = {
      project_name = "${var.app_name}-prod"
      constraint   = "compute.vmExternalIpAccess"
      list_policy = {
        deny = {
          all = true
        }
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
  default_service_account_action = "disable"
  create_service_accounts        = true
  
  # Budget settings
  currency_code = "USD"
  
  # Security settings
  enable_audit_logs = true
  
  # Global labels
  labels = {
    managed_by  = "terraform"
    module      = "project-factory"
    example     = "multi-environment"
    application = var.app_name
  }
}

# Outputs
output "environments" {
  description = "Information about all environment projects"
  value = {
    development = {
      project_id   = module.multi_env_projects.project_ids["${var.app_name}-dev"]
      project_name = module.multi_env_projects.project_names["${var.app_name}-dev"]
      budget       = module.multi_env_projects.budgets["${var.app_name}-dev"]
    }
    staging = {
      project_id   = module.multi_env_projects.project_ids["${var.app_name}-staging"]
      project_name = module.multi_env_projects.project_names["${var.app_name}-staging"]
      budget       = module.multi_env_projects.budgets["${var.app_name}-staging"]
    }
    production = {
      project_id   = module.multi_env_projects.project_ids["${var.app_name}-prod"]
      project_name = module.multi_env_projects.project_names["${var.app_name}-prod"]
      budget       = module.multi_env_projects.budgets["${var.app_name}-prod"]
    }
  }
}

output "project_summary" {
  description = "Summary of all created projects"
  value       = module.multi_env_projects.project_summary
}

output "billing_summary" {
  description = "Billing and budget summary"
  value       = module.multi_env_projects.billing_summary
}

output "security_summary" {
  description = "Security configuration summary"
  value       = module.multi_env_projects.security_summary
}
