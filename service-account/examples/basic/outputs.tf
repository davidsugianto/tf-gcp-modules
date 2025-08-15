output "service_accounts" {
  description = "Map of created service accounts"
  value       = module.basic_service_accounts.service_accounts
}

output "service_account_emails" {
  description = "Map of service account emails"
  value       = module.basic_service_accounts.service_account_emails
}

output "summary" {
  description = "Summary of created resources"
  value       = module.basic_service_accounts.summary
}
