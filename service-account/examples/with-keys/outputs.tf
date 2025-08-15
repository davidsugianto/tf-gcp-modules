output "service_accounts" {
  description = "Map of created service accounts"
  value       = module.service_accounts_with_keys.service_accounts
}

output "service_account_emails" {
  description = "Map of service account emails"
  value       = module.service_accounts_with_keys.service_account_emails
}

# Sensitive outputs for service account keys
output "service_account_keys" {
  description = "Map of service account keys (sensitive)"
  value       = module.service_accounts_with_keys.service_account_keys
  sensitive   = true
}

output "service_account_private_keys" {
  description = "Map of service account private keys (base64 encoded, sensitive)"
  value       = module.service_accounts_with_keys.service_account_private_keys
  sensitive   = true
}

output "key_usage_instructions" {
  description = "Instructions for using the generated keys"
  value = {
    for name, sa in module.service_accounts_with_keys.service_accounts : name => {
      email = sa.email
      key_usage = "echo '${lookup(module.service_accounts_with_keys.service_account_private_keys, name, "NO_KEY")}' | base64 -d > ${name}-key.json && export GOOGLE_APPLICATION_CREDENTIALS=${name}-key.json"
    }
    if contains(keys(module.service_accounts_with_keys.service_account_private_keys), name)
  }
  sensitive = true
}

output "summary" {
  description = "Summary of created resources"
  value       = module.service_accounts_with_keys.summary
}
