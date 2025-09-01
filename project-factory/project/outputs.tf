# Project Sub-module Outputs

# Primary project outputs
output "projects" {
  description = "Map of all created projects with complete information"
  value = {
    for name, project in google_project.projects : name => {
      project_id      = project.project_id
      project_name    = project.name
      project_number  = project.number
      billing_account = project.billing_account
      folder_id       = project.folder_id
      org_id         = project.org_id
      labels         = project.labels
      auto_create_network = project.auto_create_network
      lien           = lookup(var.projects[name], "lien", false)
      
      # Computed attributes
      lifecycle_state = project.lifecycle_state
      create_time    = project.create_time
    }
  }
}

output "project_ids" {
  description = "Map of project names to project IDs"
  value = {
    for name, project in google_project.projects : name => project.project_id
  }
}

output "project_names" {
  description = "Map of project names to project display names"
  value = {
    for name, project in google_project.projects : name => project.name
  }
}

output "project_numbers" {
  description = "Map of project names to project numbers"
  value = {
    for name, project in google_project.projects : name => project.number
  }
}

# Project liens information
output "project_liens" {
  description = "Map of project liens information"
  value = {
    for name, lien in google_project_lien.project_liens : name => {
      name         = lien.name
      parent       = lien.parent
      origin       = lien.origin
      reason       = lien.reason
      restrictions = lien.restrictions
    }
  }
}

# Default service account information
output "default_service_accounts" {
  description = "Map of default service account management information"
  value = {
    for name, sa in google_project_default_service_accounts.default_sa : name => {
      project        = sa.project
      action         = sa.action
      restore_policy = sa.restore_policy
    }
  }
}

# Project metadata
output "project_metadata" {
  description = "Map of project metadata"
  value = {
    for name, metadata in google_project_metadata.project_metadata : name => {
      project  = metadata.project
      metadata = metadata.metadata
    }
  }
}

# Usage export information
output "usage_exports" {
  description = "Map of usage export configurations"
  value = {
    for name, export in google_project_usage_export_bucket.usage_export : name => {
      project     = export.project
      bucket_name = export.bucket_name
      prefix      = export.prefix
    }
  }
}

# Essential contacts
output "essential_contacts" {
  description = "Map of essential contacts"
  value = {
    for name, contact in google_essential_contacts_contact.essential_contacts : name => {
      name                              = contact.name
      email                            = contact.email
      language_tag                     = contact.language_tag
      notification_category_subscriptions = contact.notification_category_subscriptions
    }
  }
}

# Access approval settings
output "access_approval_settings" {
  description = "Map of access approval settings"
  value = {
    for name, settings in google_project_access_approval_settings.access_approval : name => {
      name                   = settings.name
      project_id            = settings.project_id
      enrolled_ancestor     = settings.enrolled_ancestor
      enrolled_services     = settings.enrolled_services
    }
  }
}

# Security center IAM bindings
output "security_center_bindings" {
  description = "Map of Security Center admin IAM bindings"
  value = {
    for name, binding in google_project_iam_binding.security_center_admin : name => {
      project = binding.project
      role    = binding.role
      members = binding.members
    }
  }
}

# Grouped outputs for easier consumption
output "projects_by_folder" {
  description = "Projects grouped by folder ID"
  value = {
    for folder_id in distinct([for project in google_project.projects : project.folder_id if project.folder_id != null]) : folder_id => {
      for name, project in google_project.projects : name => project
      if project.folder_id == folder_id
    }
  }
}

output "projects_by_billing_account" {
  description = "Projects grouped by billing account"
  value = {
    for billing_account in distinct([for project in google_project.projects : project.billing_account]) : billing_account => {
      for name, project in google_project.projects : name => project
      if project.billing_account == billing_account
    }
  }
}

output "projects_with_liens" {
  description = "List of projects with deletion liens"
  value = [
    for name, project in google_project.projects : name
    if contains(keys(google_project_lien.project_liens), name)
  ]
}

output "projects_with_auto_network" {
  description = "List of projects with auto-created networks"
  value = [
    for name, project in google_project.projects : name
    if project.auto_create_network == true
  ]
}

# Summary information
output "project_creation_summary" {
  description = "Summary of project creation"
  value = {
    total_projects_created = length(google_project.projects)
    projects_with_liens   = length(google_project_lien.project_liens)
    projects_with_usage_export = length(google_project_usage_export_bucket.usage_export)
    essential_contacts_configured = length(google_essential_contacts_contact.essential_contacts)
    access_approval_enabled = length(google_project_access_approval_settings.access_approval)
    
    billing_accounts_used = distinct([
      for project in google_project.projects : project.billing_account
    ])
    
    folders_used = compact(distinct([
      for project in google_project.projects : project.folder_id
    ]))
    
    environments = distinct([
      for project in google_project.projects : lookup(project.labels, "environment", "unknown")
    ])
  }
}
