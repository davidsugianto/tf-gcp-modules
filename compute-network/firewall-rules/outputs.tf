output "firewall_rules" {
  description = "Map of firewall rule configurations"
  value = {
    for name, rule in google_compute_firewall.firewall_rules : name => {
      id                      = rule.id
      name                    = rule.name
      description            = rule.description
      self_link              = rule.self_link
      network                = rule.network
      direction              = rule.direction
      priority               = rule.priority
      disabled               = rule.disabled
      source_ranges          = rule.source_ranges
      destination_ranges     = rule.destination_ranges
      source_tags            = rule.source_tags
      target_tags            = rule.target_tags
      source_service_accounts = rule.source_service_accounts
      target_service_accounts = rule.target_service_accounts
      allow                  = rule.allow
      deny                   = rule.deny
      creation_timestamp     = rule.creation_timestamp
    }
  }
}

output "firewall_rule_names" {
  description = "Map of firewall rule names"
  value = {
    for name, rule in google_compute_firewall.firewall_rules : name => rule.name
  }
}

output "firewall_rule_self_links" {
  description = "Map of firewall rule self links"
  value = {
    for name, rule in google_compute_firewall.firewall_rules : name => rule.self_link
  }
}

output "firewall_rule_ids" {
  description = "Map of firewall rule IDs"
  value = {
    for name, rule in google_compute_firewall.firewall_rules : name => rule.id
  }
}

# Security policies outputs
output "security_policies" {
  description = "Map of security policy configurations"
  value = {
    for name, policy in google_compute_security_policy.security_policies : name => {
      id            = policy.id
      name          = policy.name
      description   = policy.description
      self_link     = policy.self_link
      fingerprint   = policy.fingerprint
    }
  }
}

output "security_policy_names" {
  description = "Map of security policy names"
  value = {
    for name, policy in google_compute_security_policy.security_policies : name => policy.name
  }
}

output "security_policy_self_links" {
  description = "Map of security policy self links"
  value = {
    for name, policy in google_compute_security_policy.security_policies : name => policy.self_link
  }
}

# Network endpoint groups outputs
output "network_endpoint_groups" {
  description = "Map of network endpoint group configurations"
  value = {
    for name, neg in google_compute_network_endpoint_group.neg : name => {
      id                    = neg.id
      name                  = neg.name
      description          = neg.description
      self_link            = neg.self_link
      network              = neg.network
      subnetwork           = neg.subnetwork
      zone                 = neg.zone
      network_endpoint_type = neg.network_endpoint_type
      size                 = neg.size
      default_port         = neg.default_port
    }
  }
}

# Backend services outputs
output "backend_services_with_security_policies" {
  description = "Map of backend services with security policies"
  value = {
    for name, backend in google_compute_backend_service.backend_with_security_policy : name => {
      id              = backend.id
      name            = backend.name
      description     = backend.description
      self_link       = backend.self_link
      protocol        = backend.protocol
      port_name       = backend.port_name
      timeout_sec     = backend.timeout_sec
      enable_cdn      = backend.enable_cdn
      security_policy = backend.security_policy
    }
  }
}

# Grouped outputs for easier consumption
output "firewall_rules_by_network" {
  description = "Firewall rules grouped by network"
  value = {
    for network in distinct([for rule in google_compute_firewall.firewall_rules : rule.network]) : network => {
      for name, rule in google_compute_firewall.firewall_rules : name => rule
      if rule.network == network
    }
  }
}

output "firewall_rules_by_direction" {
  description = "Firewall rules grouped by direction"
  value = {
    for direction in distinct([for rule in google_compute_firewall.firewall_rules : rule.direction]) : direction => {
      for name, rule in google_compute_firewall.firewall_rules : name => rule
      if rule.direction == direction
    }
  }
}

output "firewall_rules_by_priority" {
  description = "Firewall rules grouped by priority"
  value = {
    for priority in distinct([for rule in google_compute_firewall.firewall_rules : tostring(rule.priority)]) : priority => {
      for name, rule in google_compute_firewall.firewall_rules : name => rule
      if tostring(rule.priority) == priority
    }
  }
}

output "allow_firewall_rules" {
  description = "Firewall rules with allow actions"
  value = {
    for name, rule in google_compute_firewall.firewall_rules : name => rule
    if length(rule.allow) > 0
  }
}

output "deny_firewall_rules" {
  description = "Firewall rules with deny actions"
  value = {
    for name, rule in google_compute_firewall.firewall_rules : name => rule
    if length(rule.deny) > 0
  }
}

output "enabled_firewall_rules" {
  description = "Enabled firewall rules"
  value = {
    for name, rule in google_compute_firewall.firewall_rules : name => rule
    if !rule.disabled
  }
}

output "disabled_firewall_rules" {
  description = "Disabled firewall rules"
  value = {
    for name, rule in google_compute_firewall.firewall_rules : name => rule
    if rule.disabled
  }
}
