# Project Factory Outputs

# Project outputs from sub-modules
output "projects" {
  description = "Map of all created projects with their configurations"
  value       = module.projects.projects
}

output "project_ids" {
  description = "Map of project names to project IDs"
  value       = module.projects.project_ids
}

output "project_names" {
  description = "Map of project names to project display names"
  value       = module.projects.project_names
}

output "project_numbers" {
  description = "Map of project names to project numbers"
  value       = module.projects.project_numbers
}

# Service outputs
output "enabled_services" {
  description = "Map of enabled services by project"
  value       = module.services.enabled_services
}

output "service_accounts" {
  description = "Map of created service accounts by project"
  value       = module.iam.service_accounts
}

# IAM outputs
output "iam_bindings" {
  description = "Map of IAM bindings by project"
  value       = module.iam.iam_bindings
}

output "custom_roles" {
  description = "Map of custom roles by project"
  value       = module.iam.custom_roles
}

# Budget outputs
output "budgets" {
  description = "Map of created budgets by project"
  value       = module.budgets.budgets
  sensitive   = false
}

output "budget_alerts" {
  description = "Map of budget alert configurations by project"
  value       = module.budgets.budget_alerts
}

# Folder outputs
output "folders" {
  description = "Map of created organizational folders"
  value = {
    for name, folder in google_folder.folders : name => {
      name         = folder.name
      display_name = folder.display_name
      parent       = folder.parent
      folder_id    = folder.folder_id
      create_time  = folder.create_time
    }
  }
}

# Organization policy outputs
output "folder_organization_policies" {
  description = "Map of folder organization policies"
  value = {
    for name, policy in google_folder_organization_policy.folder_policies : name => {
      folder     = policy.folder
      constraint = policy.constraint
      etag       = policy.etag
      update_time = policy.update_time
    }
  }
}

output "project_organization_policies" {
  description = "Map of project organization policies"
  value = {
    for name, policy in google_project_organization_policy.project_policies : name => {
      project    = policy.project
      constraint = policy.constraint
      etag       = policy.etag
      update_time = policy.update_time
    }
  }
}

# Shared VPC outputs
output "shared_vpc_attachments" {
  description = "Map of Shared VPC service project attachments"
  value = {
    for name, attachment in google_compute_shared_vpc_service_project.shared_vpc_attachment : name => {
      host_project    = attachment.host_project
      service_project = attachment.service_project
    }
  }
}

# Essential contacts outputs
output "essential_contacts_admins" {
  description = "Map of Essential Contacts Admin role assignments"
  value = {
    for name, member in google_project_iam_member.essential_contacts_admin : name => {
      project = member.project
      role    = member.role
      member  = member.member
    }
  }
}

# Audit configuration outputs
output "audit_configs" {
  description = "Map of audit log configurations by project"
  value = {
    for name, config in google_project_iam_audit_config.audit_config : name => {
      project = config.project
      service = config.service
    }
  }
}

# Summary outputs for easy consumption
output "project_summary" {
  description = "Summary of all projects created by the factory"
  value = {
    for name, project in module.projects.projects : name => {
      project_id     = project.project_id
      project_name   = project.project_name
      project_number = project.project_number
      folder_id      = project.folder_id
      
      # Services summary
      enabled_services_count = length(lookup(module.services.enabled_services, name, []))
      
      # IAM summary
      service_accounts_count = length(lookup(module.iam.service_accounts, name, {}))
      iam_bindings_count    = length(lookup(module.iam.iam_bindings, name, {}))
      custom_roles_count    = length(lookup(module.iam.custom_roles, name, {}))
      
      # Budget summary
      has_budget = lookup(module.budgets.budgets, name, null) != null
      
      # Labels
      labels = project.labels
    }
  }
}

# Network information for integration
output "network_integration" {
  description = "Network integration information for projects"
  value = {
    shared_vpc_host_project = var.shared_vpc_host_project
    shared_vpc_service_projects = {
      for name, config in var.shared_vpc_service_projects : name => {
        host_project    = config.host_project
        service_project = module.projects.projects[name].project_id
      }
    }
    auto_create_network = var.auto_create_network
  }
}

# Billing and cost management
output "billing_summary" {
  description = "Billing and cost management summary"
  value = {
    billing_account = var.billing_account
    currency_code   = var.currency_code
    
    projects_with_budgets = [
      for name, project in module.projects.projects : name
      if lookup(module.budgets.budgets, name, null) != null
    ]
    
    total_projects_count = length(module.projects.projects)
    projects_with_budgets_count = length([
      for name, project in module.projects.projects : name
      if lookup(module.budgets.budgets, name, null) != null
    ])
  }
}

# Security and compliance summary
output "security_summary" {
  description = "Security and compliance configuration summary"
  value = {
    audit_logs_enabled = var.enable_audit_logs
    essential_contacts_enabled = var.enable_essential_contacts
    default_service_account_action = var.default_service_account_action
    
    projects_with_liens = [
      for name, project in module.projects.projects : name
      if project.lien == true
    ]
    
    projects_with_custom_roles = [
      for name, roles in module.iam.custom_roles : name
      if length(roles) > 0
    ]
    
    organization_policies_count = length(var.project_organization_policies)
  }
}

# Operational information
output "operational_info" {
  description = "Operational information for managing the project factory"
  value = {
    organization_id = var.organization_id
    default_folder_id = var.default_folder_id
    
    # Creation settings
    auto_create_network = var.auto_create_network
    lien = var.lien
    skip_gcloud_download = var.skip_gcloud_download
    
    # Service settings
    disable_services_on_destroy = var.disable_services_on_destroy
    disable_dependent_services = var.disable_dependent_services
    enable_apis_on_boot = var.enable_apis_on_boot
    
    # Labels
    global_labels = var.labels
    names_prefix = var.names_prefix
    names_suffix = var.names_suffix
  }
}

# Resource counts for monitoring
output "resource_counts" {
  description = "Count of resources created by type"
  value = {
    projects                    = length(module.projects.projects)
    folders                     = length(google_folder.folders)
    service_accounts            = sum([for name, sas in module.iam.service_accounts : length(sas)])
    custom_roles               = sum([for name, roles in module.iam.custom_roles : length(roles)])
    iam_bindings               = sum([for name, bindings in module.iam.iam_bindings : length(bindings)])
    budgets                    = length(module.budgets.budgets)
    folder_organization_policies = length(google_folder_organization_policy.folder_policies)
    project_organization_policies = length(google_project_organization_policy.project_policies)
    shared_vpc_attachments     = length(google_compute_shared_vpc_service_project.shared_vpc_attachment)
  }
}

# For Terraform Cloud/Enterprise workspaces
output "terraform_workspace_outputs" {
  description = "Key outputs for Terraform workspace integration"
  value = {
    project_ids = module.projects.project_ids
    billing_account = var.billing_account
    organization_id = var.organization_id
  }
  sensitive = false
}

# Random suffix mapping for projects with auto-generated suffixes
output "project_id_mapping" {
  description = "Mapping of original project IDs to final project IDs (with suffixes if generated)"
  value = {
    for name, config in var.projects : name => {
      original_project_id = config.project_id
      final_project_id   = module.projects.projects[name].project_id
      suffix_generated   = config.auto_generate_suffix
      random_suffix      = config.auto_generate_suffix ? random_id.project_suffix[name].hex : null
    }
  }
}
