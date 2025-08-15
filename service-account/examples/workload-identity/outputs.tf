output "service_accounts" {
  description = "Map of created service accounts"
  value       = module.workload_identity_service_accounts.service_accounts
}

output "service_account_emails" {
  description = "Map of service account emails"
  value       = module.workload_identity_service_accounts.service_account_emails
}

output "workload_identity_config" {
  description = "Workload Identity configuration for kubectl"
  value       = module.workload_identity_service_accounts.workload_identity_config
}

output "workload_identity_bindings" {
  description = "List of Workload Identity bindings"
  value       = module.workload_identity_service_accounts.workload_identity_bindings
}

output "kubectl_annotation_commands" {
  description = "Commands to annotate Kubernetes service accounts"
  value = {
    for sa_name, config in module.workload_identity_service_accounts.workload_identity_config : sa_name => {
      service_account_email = config.service_account_email
      commands             = config.annotation_commands
    }
  }
}

output "summary" {
  description = "Summary of created resources"
  value       = module.workload_identity_service_accounts.summary
}
