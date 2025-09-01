# Firewall Rules Sub-module
# This module handles firewall rule creation and management

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Create firewall rules
resource "google_compute_firewall" "firewall_rules" {
  for_each = var.firewall_rules

  project   = var.project_id
  name      = "${var.names_prefix}${each.key}${var.names_suffix}"
  network   = each.value.network
  direction = each.value.direction
  priority  = each.value.priority

  # Optional settings
  description = each.value.description
  disabled    = each.value.disabled

  # Source/Target configuration
  source_ranges              = each.value.source_ranges
  destination_ranges         = each.value.destination_ranges
  source_tags                = each.value.source_tags
  target_tags                = each.value.target_tags
  source_service_accounts    = each.value.source_service_accounts
  target_service_accounts    = each.value.target_service_accounts

  # Allow rules
  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  # Deny rules
  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  # Logging configuration
  dynamic "log_config" {
    for_each = each.value.enable_logging ? [1] : []
    content {
      metadata = each.value.log_config_metadata
    }
  }

  # Lifecycle management
  lifecycle {
    prevent_destroy = false
  }
}

# Security policies (optional)
resource "google_compute_security_policy" "security_policies" {
  for_each = var.security_policies

  project     = var.project_id
  name        = "${var.names_prefix}${each.key}${var.names_suffix}"
  description = each.value.description

  # Default rule
  rule {
    action   = each.value.default_rule_action
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule"
  }

  # Custom rules
  dynamic "rule" {
    for_each = each.value.rules
    content {
      action   = rule.value.action
      priority = rule.value.priority
      
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value.src_ip_ranges
        }
      }
      
      description = rule.value.description
      
      dynamic "rate_limit_options" {
        for_each = rule.value.rate_limit_options != null ? [rule.value.rate_limit_options] : []
        content {
          conform_action      = rate_limit_options.value.conform_action
          exceed_action       = rate_limit_options.value.exceed_action
          enforce_on_key      = rate_limit_options.value.enforce_on_key
          enforce_on_key_name = rate_limit_options.value.enforce_on_key_name

          rate_limit_threshold {
            count        = rate_limit_options.value.rate_limit_threshold.count
            interval_sec = rate_limit_options.value.rate_limit_threshold.interval_sec
          }
        }
      }
    }
  }

  # Adaptive protection
  dynamic "adaptive_protection_config" {
    for_each = each.value.enable_adaptive_protection ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable          = true
        rule_visibility = each.value.adaptive_protection_rule_visibility
      }
    }
  }
}

# Network endpoint groups for security policies (optional)
resource "google_compute_network_endpoint_group" "neg" {
  for_each = var.network_endpoint_groups

  project      = var.project_id
  name         = "${var.names_prefix}${each.key}${var.names_suffix}"
  network      = each.value.network
  subnetwork   = each.value.subnetwork
  zone         = each.value.zone
  description  = each.value.description

  # Network endpoint group type
  network_endpoint_type = each.value.network_endpoint_type
  default_port         = each.value.default_port
}

# Backend security policies attachment (optional)
resource "google_compute_backend_service" "backend_with_security_policy" {
  for_each = var.backend_services_with_security_policies

  project         = var.project_id
  name            = "${var.names_prefix}${each.key}${var.names_suffix}"
  description     = each.value.description
  protocol        = each.value.protocol
  port_name       = each.value.port_name
  timeout_sec     = each.value.timeout_sec
  enable_cdn      = each.value.enable_cdn
  security_policy = google_compute_security_policy.security_policies[each.value.security_policy_name].id

  # Health check
  dynamic "health_checks" {
    for_each = each.value.health_checks
    content {
      health_checks = health_checks.value
    }
  }

  # Backend configuration
  dynamic "backend" {
    for_each = each.value.backends
    content {
      group           = backend.value.group
      balancing_mode  = backend.value.balancing_mode
      capacity_scaler = backend.value.capacity_scaler
      description     = backend.value.description
      max_connections = backend.value.max_connections
      max_rate        = backend.value.max_rate
      max_utilization = backend.value.max_utilization
    }
  }

  depends_on = [google_compute_security_policy.security_policies]
}
