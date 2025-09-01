# IAM Sub-module
# This module handles IAM bindings, service accounts, and custom roles

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Create custom roles
resource "google_project_iam_custom_role" "custom_roles" {
  for_each = local.project_custom_roles

  project     = each.value.project_id
  role_id     = "${var.names_prefix}${each.value.role_id}${var.names_suffix}"
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}

# Create service accounts
resource "google_service_account" "service_accounts" {
  for_each = var.create_service_accounts ? local.project_service_accounts : {}

  project      = each.value.project_id
  account_id   = "${var.names_prefix}${each.value.account_id}${var.names_suffix}"
  display_name = each.value.display_name
  description  = each.value.description
}

# Create IAM bindings for projects
resource "google_project_iam_member" "iam_bindings" {
  for_each = local.project_iam_bindings

  project = each.value.project_id
  role    = each.value.role
  member  = each.value.member

  depends_on = [google_service_account.service_accounts]
}

# Bind roles to created service accounts
resource "google_project_iam_member" "service_account_roles" {
  for_each = local.service_account_roles

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"

  depends_on = [google_service_account.service_accounts]
}

# Create service account keys (only if explicitly requested)
resource "google_service_account_key" "service_account_keys" {
  for_each = {
    for key, sa in local.project_service_accounts : key => sa
    if sa.create_key
  }

  service_account_id = google_service_account.service_accounts[each.key].name
  key_algorithm     = "KEY_ALG_RSA_2048"

  depends_on = [google_service_account.service_accounts]
}

# Shared VPC IAM bindings
resource "google_project_iam_member" "shared_vpc_bindings" {
  for_each = var.shared_vpc_service_projects

  project = each.value.host_project
  role    = "roles/compute.xpnAdmin"
  member  = "serviceAccount:service-${data.google_project.projects[each.key].number}@container-engine-robot.iam.gserviceaccount.com"

  depends_on = [data.google_project.projects]
}

# Data source for project information
data "google_project" "projects" {
  for_each = var.projects

  project_id = each.value.project_id
}

locals {
  # Flatten custom roles for resource creation
  project_custom_roles = merge([
    for project_name, project in var.projects : {
      for role_name, role_config in lookup(project, "custom_roles", {}) : "${project_name}-${role_name}" => {
        project_id  = project.project_id
        role_id     = role_name
        title       = role_config.title
        description = role_config.description
        permissions = role_config.permissions
        stage       = role_config.stage
      }
    }
  ]...)

  # Flatten service accounts for resource creation
  project_service_accounts = merge([
    for project_name, project in var.projects : {
      for sa_name, sa_config in lookup(project, "service_accounts", {}) : "${project_name}-${sa_name}" => {
        project_id   = project.project_id
        account_id   = sa_name
        display_name = sa_config.display_name
        description  = sa_config.description
        roles        = sa_config.roles
        create_key   = lookup(sa_config, "create_key", false)
      }
    }
  ]...)

  # Flatten IAM bindings for resource creation
  project_iam_bindings = merge([
    for project_name, project in var.projects : merge([
      for binding_name, binding_config in lookup(project, "iam_bindings", {}) : {
        for member in binding_config.members : "${project_name}-${binding_name}-${replace(member, "/[^a-zA-Z0-9-]/", "-")}" => {
          project_id = project.project_id
          role       = binding_config.role
          member     = member
        }
      }
    ]...)
  ]...)

  # Flatten service account roles for binding
  service_account_roles = merge([
    for sa_key, sa_config in local.project_service_accounts : {
      for role in sa_config.roles : "${sa_key}-${replace(role, "/[^a-zA-Z0-9-]/", "-")}" => {
        project_id = sa_config.project_id
        role       = role
        sa_key     = sa_key
      }
    }
  ]...)
}
