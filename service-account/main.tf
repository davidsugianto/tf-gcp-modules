locals {
  # Generate service account names with optional prefix and suffix
  service_accounts = {
    for name, config in var.service_accounts : name => {
      account_id   = "${var.names_prefix}${name}${var.names_suffix}"
      display_name = lookup(config, "display_name", null) != null ? config.display_name : "${var.names_prefix}${name}${var.names_suffix}"
      description  = lookup(config, "description", "Managed by Terraform")
      disabled     = lookup(config, "disabled", false)
      roles        = lookup(config, "roles", [])
      project_roles = lookup(config, "project_roles", {})
    }
  }
}

# Create service accounts
resource "google_service_account" "service_accounts" {
  for_each = local.service_accounts

  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
  disabled     = each.value.disabled
}

# Create service account keys (optional)
resource "google_service_account_key" "keys" {
  for_each = {
    for name, config in var.service_accounts : name => config
    if lookup(config, "generate_key", false)
  }

  service_account_id = google_service_account.service_accounts[each.key].name
  key_algorithm      = lookup(each.value, "key_algorithm", "KEY_ALG_RSA_2048")
  private_key_type   = lookup(each.value, "private_key_type", "TYPE_GOOGLE_CREDENTIALS_FILE")
  public_key_type    = lookup(each.value, "public_key_type", "TYPE_X509_PEM_FILE")

  # Optional key rotation
  keepers = lookup(each.value, "key_rotation_date", null) != null ? {
    rotation_date = each.value.key_rotation_date
  } : null
}

# Assign project-level IAM roles to service accounts
resource "google_project_iam_member" "project_roles" {
  for_each = merge([
    for sa_name, sa_config in local.service_accounts : {
      for role in sa_config.roles : "${sa_name}-${role}" => {
        service_account = google_service_account.service_accounts[sa_name].email
        role           = role
        project        = var.project_id
      }
    }
  ]...)

  project = each.value.project
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account}"

  condition {
    title       = lookup(var.iam_conditions[each.key], "title", null)
    description = lookup(var.iam_conditions[each.key], "description", null)
    expression  = lookup(var.iam_conditions[each.key], "expression", null)
  }

  depends_on = [google_service_account.service_accounts]
}

# Assign project-specific IAM roles (when service accounts need roles on different projects)
resource "google_project_iam_member" "cross_project_roles" {
  for_each = merge([
    for sa_name, sa_config in local.service_accounts : {
      for project_id, roles in sa_config.project_roles : 
        "${sa_name}-${project_id}-${roles}" => {
          service_account = google_service_account.service_accounts[sa_name].email
          role           = roles
          project        = project_id
        }
      if length(sa_config.project_roles) > 0
    }
  ]...)

  project = each.value.project
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account}"

  depends_on = [google_service_account.service_accounts]
}

# Create custom IAM roles (optional)
resource "google_project_iam_custom_role" "custom_roles" {
  for_each = var.custom_roles

  project     = var.project_id
  role_id     = each.key
  title       = each.value.title
  description = lookup(each.value, "description", "Custom role managed by Terraform")
  permissions = each.value.permissions
  stage       = lookup(each.value, "stage", "GA")
}

# Assign custom roles to service accounts
resource "google_project_iam_member" "custom_role_assignments" {
  for_each = merge([
    for sa_name, sa_config in var.service_accounts : {
      for custom_role in lookup(sa_config, "custom_roles", []) : "${sa_name}-${custom_role}" => {
        service_account = google_service_account.service_accounts[sa_name].email
        role           = "projects/${var.project_id}/roles/${custom_role}"
        project        = var.project_id
      }
    }
  ]...)

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account}"

  depends_on = [
    google_service_account.service_accounts,
    google_project_iam_custom_role.custom_roles
  ]
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset(var.required_apis)

  project = var.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

# Create service account impersonation (optional)
resource "google_service_account_iam_member" "impersonation" {
  for_each = merge([
    for sa_name, sa_config in var.service_accounts : {
      for impersonator in lookup(sa_config, "impersonators", []) : "${sa_name}-${impersonator}" => {
        service_account = google_service_account.service_accounts[sa_name].email
        role           = "roles/iam.serviceAccountTokenCreator"
        member         = impersonator
      }
    }
  ]...)

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.service_account}"
  role              = each.value.role
  member            = each.value.member

  depends_on = [google_service_account.service_accounts]
}

# Workload Identity binding for GKE (optional)
resource "google_service_account_iam_member" "workload_identity" {
  for_each = merge([
    for sa_name, sa_config in var.service_accounts : {
      for k8s_sa in lookup(sa_config, "workload_identity_users", []) : "${sa_name}-${k8s_sa}" => {
        service_account = google_service_account.service_accounts[sa_name].email
        role           = "roles/iam.workloadIdentityUser"
        member         = "serviceAccount:${var.project_id}.svc.id.goog[${k8s_sa}]"
      }
    }
  ]...)

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.service_account}"
  role              = each.value.role
  member            = each.value.member

  depends_on = [google_service_account.service_accounts]
}
