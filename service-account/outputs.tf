# Service account basic information
output "service_accounts" {
  description = "Map of service account configurations"
  value = {
    for name, sa in google_service_account.service_accounts : name => {
      name         = sa.name
      email        = sa.email
      account_id   = sa.account_id
      unique_id    = sa.unique_id
      display_name = sa.display_name
      description  = sa.description
      disabled     = sa.disabled
      member       = "serviceAccount:${sa.email}"
    }
  }
}

output "service_account_emails" {
  description = "Map of service account names to their email addresses"
  value = {
    for name, sa in google_service_account.service_accounts : name => sa.email
  }
}

output "service_account_names" {
  description = "Map of service account names to their full resource names"
  value = {
    for name, sa in google_service_account.service_accounts : name => sa.name
  }
}

output "service_account_unique_ids" {
  description = "Map of service account names to their unique IDs"
  value = {
    for name, sa in google_service_account.service_accounts : name => sa.unique_id
  }
}

output "service_account_members" {
  description = "Map of service account names to their IAM member strings"
  value = {
    for name, sa in google_service_account.service_accounts : name => "serviceAccount:${sa.email}"
  }
}

# Service account keys (sensitive)
output "service_account_keys" {
  description = "Map of service account keys (base64 encoded)"
  value = {
    for name, key in google_service_account_key.keys : name => {
      name         = key.name
      key_id       = key.key_id
      public_key   = key.public_key
      private_key  = key.private_key
      key_algorithm = key.key_algorithm
      private_key_type = key.private_key_type
      public_key_type  = key.public_key_type
      valid_after  = key.valid_after
      valid_before = key.valid_before
    }
  }
  sensitive = true
}

output "service_account_private_keys" {
  description = "Map of service account names to their private keys (base64 encoded)"
  value = {
    for name, key in google_service_account_key.keys : name => key.private_key
  }
  sensitive = true
}

output "service_account_public_keys" {
  description = "Map of service account names to their public keys"
  value = {
    for name, key in google_service_account_key.keys : name => key.public_key
  }
}

output "service_account_key_ids" {
  description = "Map of service account names to their key IDs"
  value = {
    for name, key in google_service_account_key.keys : name => key.key_id
  }
}

# IAM role assignments
output "project_iam_roles" {
  description = "List of project-level IAM role assignments"
  value = [
    for role_assignment in google_project_iam_member.project_roles : {
      project = role_assignment.project
      role    = role_assignment.role
      member  = role_assignment.member
    }
  ]
}

output "cross_project_iam_roles" {
  description = "List of cross-project IAM role assignments"
  value = [
    for role_assignment in google_project_iam_member.cross_project_roles : {
      project = role_assignment.project
      role    = role_assignment.role
      member  = role_assignment.member
    }
  ]
}

# Custom roles
output "custom_roles" {
  description = "Map of created custom roles"
  value = {
    for name, role in google_project_iam_custom_role.custom_roles : name => {
      id          = role.id
      name        = role.name
      title       = role.title
      description = role.description
      permissions = role.permissions
      stage       = role.stage
      deleted     = role.deleted
    }
  }
}

output "custom_role_assignments" {
  description = "List of custom role assignments"
  value = [
    for role_assignment in google_project_iam_member.custom_role_assignments : {
      project = role_assignment.project
      role    = role_assignment.role
      member  = role_assignment.member
    }
  ]
}

# Impersonation and Workload Identity
output "impersonation_bindings" {
  description = "List of service account impersonation bindings"
  value = [
    for binding in google_service_account_iam_member.impersonation : {
      service_account_id = binding.service_account_id
      role              = binding.role
      member            = binding.member
    }
  ]
}

output "workload_identity_bindings" {
  description = "List of Workload Identity bindings"
  value = [
    for binding in google_service_account_iam_member.workload_identity : {
      service_account_id = binding.service_account_id
      role              = binding.role
      member            = binding.member
    }
  ]
}

# For kubectl configuration (Workload Identity)
output "workload_identity_config" {
  description = "Configuration for Workload Identity setup"
  value = {
    for name, sa_config in var.service_accounts : name => {
      service_account_email = google_service_account.service_accounts[name].email
      workload_identity_users = lookup(sa_config, "workload_identity_users", [])
      annotation_commands = [
        for k8s_sa in lookup(sa_config, "workload_identity_users", []) :
        "kubectl annotate serviceaccount ${split("/", k8s_sa)[1]} iam.gke.io/gcp-service-account=${google_service_account.service_accounts[name].email} --namespace=${split("/", k8s_sa)[0]}"
      ]
    }
    if length(lookup(sa_config, "workload_identity_users", [])) > 0
  }
}

# Summary outputs
output "summary" {
  description = "Summary of created resources"
  value = {
    service_accounts_created = length(google_service_account.service_accounts)
    service_account_names   = keys(google_service_account.service_accounts)
    keys_generated          = length(google_service_account_key.keys)
    custom_roles_created    = length(google_project_iam_custom_role.custom_roles)
    project_iam_bindings    = length(google_project_iam_member.project_roles)
    cross_project_bindings  = length(google_project_iam_member.cross_project_roles)
    custom_role_bindings    = length(google_project_iam_member.custom_role_assignments)
    impersonation_bindings  = length(google_service_account_iam_member.impersonation)
    workload_identity_bindings = length(google_service_account_iam_member.workload_identity)
  }
}

# Export for other modules
output "service_account_map" {
  description = "Complete service account information for use by other modules"
  value = {
    for name, sa in google_service_account.service_accounts : name => {
      name         = sa.name
      email        = sa.email
      account_id   = sa.account_id
      unique_id    = sa.unique_id
      display_name = sa.display_name
      member       = "serviceAccount:${sa.email}"
      has_key      = contains(keys(google_service_account_key.keys), name)
      workload_identity_configured = length(lookup(var.service_accounts[name], "workload_identity_users", [])) > 0
    }
  }
}
