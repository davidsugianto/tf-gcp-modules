output "service_accounts" {
  description = "Map of created service accounts"
  value       = module.custom_roles_service_accounts.service_accounts
}

output "service_account_emails" {
  description = "Map of service account emails"
  value       = module.custom_roles_service_accounts.service_account_emails
}

output "custom_roles" {
  description = "Map of created custom roles"
  value       = module.custom_roles_service_accounts.custom_roles
}

output "custom_role_assignments" {
  description = "List of custom role assignments"
  value       = module.custom_roles_service_accounts.custom_role_assignments
}

output "impersonation_bindings" {
  description = "List of service account impersonation bindings"
  value       = module.custom_roles_service_accounts.impersonation_bindings
}

output "cross_project_iam_roles" {
  description = "List of cross-project IAM role assignments"
  value       = module.custom_roles_service_accounts.cross_project_iam_roles
}

output "summary" {
  description = "Summary of created resources"
  value       = module.custom_roles_service_accounts.summary
}
