# Project Sub-module
# This module handles the basic creation and configuration of GCP projects

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
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7"
    }
  }
}

# Wait for project creation to stabilize
resource "time_sleep" "project_creation_delay" {
  create_duration = "10s"
}

# Create projects
resource "google_project" "projects" {
  for_each = var.projects

  project_id      = each.value.project_id
  name           = coalesce(each.value.project_name, each.key)
  billing_account = var.billing_account
  folder_id      = coalesce(each.value.folder_id, var.default_folder_id)
  org_id         = var.organization_id

  # Auto create default network
  auto_create_network = each.value.auto_create_network

  # Labels
  labels = merge(var.labels, each.value.labels, {
    created_by = "project-factory"
    managed_by = "terraform"
  })

  # Lifecycle management
  lifecycle {
    prevent_destroy = false
  }

  depends_on = [time_sleep.project_creation_delay]
}

# Project liens to prevent accidental deletion
resource "google_project_lien" "project_liens" {
  for_each = {
    for name, config in var.projects : name => config
    if config.lien
  }

  parent       = google_project.projects[each.key].id
  restrictions = ["resourcemanager.projects.delete"]
  origin      = "terraform-project-factory"
  reason      = "Project managed by Terraform Project Factory"

  depends_on = [google_project.projects]
}

# Enable default compute service if auto_create_network is disabled
# This ensures the project can be used even without the default network
resource "google_project_service" "compute_service" {
  for_each = {
    for name, config in var.projects : name => config
    if !config.auto_create_network
  }

  project = google_project.projects[each.key].project_id
  service = "compute.googleapis.com"

  disable_on_destroy         = false
  disable_dependent_services = false

  depends_on = [google_project.projects]
}

# Default service account management
resource "google_project_default_service_accounts" "default_sa" {
  for_each = {
    for name, config in var.projects : name => config
    if var.default_service_account_action != "keep"
  }

  project = google_project.projects[each.key].project_id
  action  = var.default_service_account_action

  # Restore the default service account if action changes
  restore_policy = var.default_service_account_action == "delete" ? "REVERT_AND_IGNORE_FAILURE" : "REVERT"

  depends_on = [google_project.projects]
}

# Project metadata for tracking
resource "google_project_metadata" "project_metadata" {
  for_each = var.projects

  project = google_project.projects[each.key].project_id

  metadata = {
    terraform_managed      = "true"
    project_factory_module = "v1.0.0"
    created_date          = timestamp()
    environment           = lookup(each.value.labels, "environment", "unknown")
    team                  = lookup(each.value.labels, "team", "unknown")
    cost_center          = lookup(each.value.labels, "cost_center", "unknown")
  }

  depends_on = [google_project.projects]
}

# Project usage export (for billing analysis)
resource "google_project_usage_export_bucket" "usage_export" {
  for_each = {
    for name, config in var.projects : name => config
    if var.enable_usage_export && lookup(config, "usage_export_bucket", null) != null
  }

  project     = google_project.projects[each.key].project_id
  bucket_name = each.value.usage_export_bucket
  prefix      = lookup(each.value, "usage_export_prefix", "usage-")

  depends_on = [google_project.projects]
}

# Essential contacts configuration
resource "google_essential_contacts_contact" "essential_contacts" {
  for_each = var.essential_contacts

  parent                              = "projects/${google_project.projects[each.value.project_name].project_id}"
  email                              = each.value.email
  language_tag                       = each.value.language_tag
  notification_category_subscriptions = each.value.notification_categories

  depends_on = [google_project.projects]
}

# Project access approval settings (optional)
resource "google_project_access_approval_settings" "access_approval" {
  for_each = {
    for name, config in var.projects : name => config
    if var.enable_access_approval
  }

  project_id = google_project.projects[each.key].project_id

  enrolled_services {
    cloud_product = "all"
  }

  # Notification emails for access approval requests
  dynamic "notification_emails" {
    for_each = var.access_approval_notification_emails
    content {
      notification_emails.value
    }
  }

  depends_on = [google_project.projects]
}

# Security Command Center findings (if enabled)
resource "google_project_iam_binding" "security_center_admin" {
  for_each = var.enable_security_center ? 
    { for name, project in google_project.projects : name => project } : 
    {}

  project = each.value.project_id
  role    = "roles/securitycenter.adminEditor"
  members = var.security_center_admins

  depends_on = [google_project.projects]
}
