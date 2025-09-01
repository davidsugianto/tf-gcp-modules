# Project Factory Module
# This module orchestrates the creation and configuration of GCP projects with all necessary components

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

# Generate random suffix for project IDs if auto_generate_suffix is enabled
resource "random_id" "project_suffix" {
  for_each = {
    for name, config in var.projects : name => config
    if config.auto_generate_suffix
  }
  
  byte_length = 4
}

# Create projects using the project sub-module
module "projects" {
  source = "./project"

  # Pass through the projects configuration with generated suffixes
  projects = {
    for name, config in var.projects : name => merge(config, {
      project_id = config.auto_generate_suffix ? 
        "${config.project_id}-${random_id.project_suffix[name].hex}" : 
        config.project_id
    })
  }

  # Organization and folder settings
  organization_id     = var.organization_id
  default_folder_id   = var.default_folder_id
  billing_account     = var.billing_account
  skip_gcloud_download = var.skip_gcloud_download
  
  # Project creation settings
  auto_create_network = var.auto_create_network
  lien               = var.lien
  
  # Labels and naming
  labels         = var.labels
  names_prefix   = var.names_prefix
  names_suffix   = var.names_suffix
}

# Configure services using the services sub-module
module "services" {
  source = "./services"

  # Use the actual project IDs from the project module
  projects = {
    for name, project in module.projects.projects : name => {
      project_id = project.project_id
      services   = lookup(var.projects[name], "services", var.default_services)
    }
  }

  # Service configuration
  disable_on_destroy                = var.disable_services_on_destroy
  disable_dependent_services        = var.disable_dependent_services
  enable_apis_on_boot              = var.enable_apis_on_boot
  service_account_impersonation    = var.service_account_impersonation

  depends_on = [module.projects]
}

# Configure IAM using the iam sub-module
module "iam" {
  source = "./iam"

  # Use the actual project IDs from the project module
  projects = {
    for name, project in module.projects.projects : name => merge(
      {
        project_id = project.project_id
      },
      {
        for key, value in var.projects[name] : key => value
        if contains(["iam_bindings", "service_accounts", "custom_roles"], key)
      }
    )
  }

  # IAM configuration
  default_service_account_action = var.default_service_account_action
  create_service_accounts        = var.create_service_accounts
  
  # Shared VPC settings
  shared_vpc_host_project     = var.shared_vpc_host_project
  shared_vpc_service_projects = var.shared_vpc_service_projects
  
  # Labels and naming
  labels         = var.labels
  names_prefix   = var.names_prefix
  names_suffix   = var.names_suffix

  depends_on = [module.projects, module.services]
}

# Configure budgets using the budget sub-module
module "budgets" {
  source = "./budget"

  # Only create budgets for projects that have budget configuration
  projects = {
    for name, project in module.projects.projects : name => merge(
      {
        project_id = project.project_id
      },
      {
        for key, value in var.projects[name] : key => value
        if contains(["budget", "budget_alerts"], key)
      }
    )
    if lookup(var.projects[name], "budget", null) != null
  }

  # Budget configuration
  billing_account = var.billing_account
  currency_code  = var.currency_code
  
  # Default budget settings
  default_budget_amount           = var.default_budget_amount
  default_budget_alert_thresholds = var.default_budget_alert_thresholds
  
  # Labels and naming
  labels         = var.labels
  names_prefix   = var.names_prefix
  names_suffix   = var.names_suffix

  depends_on = [module.projects]
}

# Create organizational folders if specified
resource "google_folder" "folders" {
  for_each = var.folders

  display_name = each.key
  parent      = each.value.parent_folder != null ? 
    "folders/${each.value.parent_folder}" : 
    "organizations/${var.organization_id}"
}

# Create organizational policies if specified
resource "google_folder_organization_policy" "folder_policies" {
  for_each = var.folder_organization_policies

  folder     = google_folder.folders[each.value.folder_name].name
  constraint = each.value.constraint

  dynamic "boolean_policy" {
    for_each = each.value.boolean_policy != null ? [each.value.boolean_policy] : []
    content {
      enforced = boolean_policy.value.enforced
    }
  }

  dynamic "list_policy" {
    for_each = each.value.list_policy != null ? [each.value.list_policy] : []
    content {
      inherit_from_parent = list_policy.value.inherit_from_parent
      suggested_value     = list_policy.value.suggested_value

      dynamic "allow" {
        for_each = list_policy.value.allow != null ? [list_policy.value.allow] : []
        content {
          all    = allow.value.all
          values = allow.value.values
        }
      }

      dynamic "deny" {
        for_each = list_policy.value.deny != null ? [list_policy.value.deny] : []
        content {
          all    = deny.value.all
          values = deny.value.values
        }
      }
    }
  }

  dynamic "restore_policy" {
    for_each = each.value.restore_policy ? [1] : []
    content {
      default = true
    }
  }
}

# Project organization policies
resource "google_project_organization_policy" "project_policies" {
  for_each = var.project_organization_policies

  project    = module.projects.projects[each.value.project_name].project_id
  constraint = each.value.constraint

  dynamic "boolean_policy" {
    for_each = each.value.boolean_policy != null ? [each.value.boolean_policy] : []
    content {
      enforced = boolean_policy.value.enforced
    }
  }

  dynamic "list_policy" {
    for_each = each.value.list_policy != null ? [each.value.list_policy] : []
    content {
      inherit_from_parent = list_policy.value.inherit_from_parent
      suggested_value     = list_policy.value.suggested_value

      dynamic "allow" {
        for_each = list_policy.value.allow != null ? [list_policy.value.allow] : []
        content {
          all    = allow.value.all
          values = allow.value.values
        }
      }

      dynamic "deny" {
        for_each = list_policy.value.deny != null ? [list_policy.value.deny] : []
        content {
          all    = deny.value.all
          values = deny.value.values
        }
      }
    }
  }

  dynamic "restore_policy" {
    for_each = each.value.restore_policy ? [1] : []
    content {
      default = true
    }
  }

  depends_on = [module.projects]
}

# Create shared VPC attachments if specified
resource "google_compute_shared_vpc_service_project" "shared_vpc_attachment" {
  for_each = var.shared_vpc_service_projects

  host_project    = each.value.host_project
  service_project = module.projects.projects[each.key].project_id

  depends_on = [module.projects, module.services]
}

# Essential IAM bindings for project factory operation
resource "google_project_iam_member" "essential_contacts_admin" {
  for_each = var.enable_essential_contacts ? 
    { for name, project in module.projects.projects : name => project } : 
    {}

  project = each.value.project_id
  role    = "roles/essentialcontacts.admin"
  member  = var.essential_contacts_admin_member

  depends_on = [module.projects]
}

# Security settings
resource "google_project_iam_audit_config" "audit_config" {
  for_each = var.enable_audit_logs ?
    { for name, project in module.projects.projects : name => project } :
    {}

  project = each.value.project_id

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }

  depends_on = [module.projects]
}
