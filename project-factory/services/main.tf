# Services Sub-module
# This module handles enabling and configuring Google Cloud APIs and services

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

# Wait before enabling services to ensure project is ready
resource "time_sleep" "service_enablement_delay" {
  create_duration = var.service_enablement_delay

  triggers = {
    projects = jsonencode(keys(var.projects))
  }
}

# Enable services for each project
resource "google_project_service" "services" {
  for_each = local.project_services

  project = each.value.project_id
  service = each.value.service

  # Service configuration
  disable_on_destroy         = var.disable_on_destroy
  disable_dependent_services = var.disable_dependent_services

  # Lifecycle management
  lifecycle {
    prevent_destroy = false
  }

  depends_on = [time_sleep.service_enablement_delay]
}

# Service usage consumer quota override (for high-usage projects)
resource "google_service_usage_consumer_quota_override" "quota_overrides" {
  for_each = var.quota_overrides

  project        = each.value.project_id
  service        = each.value.service
  metric         = each.value.metric
  limit          = each.value.limit
  override_value = each.value.override_value
  force          = lookup(each.value, "force", false)

  depends_on = [google_project_service.services]
}

# Service account impersonation setup (if specified)
resource "google_service_account" "impersonation_account" {
  for_each = var.service_account_impersonation != null ? var.projects : {}

  project      = each.value.project_id
  account_id   = "${var.names_prefix}terraform-sa${var.names_suffix}"
  display_name = "Terraform Service Account for ${each.key}"
  description  = "Service account for Terraform operations in project ${each.key}"

  depends_on = [google_project_service.services]
}

# Grant necessary permissions to impersonation service accounts
resource "google_project_iam_member" "impersonation_permissions" {
  for_each = var.service_account_impersonation != null ? 
    merge([
      for project_name, project in var.projects : {
        for role in var.impersonation_roles : "${project_name}-${role}" => {
          project = project.project_id
          role    = role
          member  = "serviceAccount:${google_service_account.impersonation_account[project_name].email}"
        }
      }
    ]...) : {}

  project = each.value.project
  role    = each.value.role
  member  = each.value.member

  depends_on = [google_service_account.impersonation_account]
}

# API Gateway configuration (if enabled)
resource "google_api_gateway_api" "apis" {
  for_each = var.api_gateway_configs

  project     = each.value.project_id
  api_id      = each.value.api_id
  display_name = each.value.display_name

  depends_on = [google_project_service.services]
}

# Endpoints service configuration (if enabled)
resource "google_endpoints_service" "endpoints" {
  for_each = var.endpoints_configs

  project      = each.value.project_id
  service_name = each.value.service_name

  # OpenAPI configuration
  openapi_config = each.value.openapi_config

  depends_on = [google_project_service.services]
}

# Service networking connections (for private services)
resource "google_service_networking_connection" "private_vpc_connection" {
  for_each = var.service_networking_connections

  network                 = each.value.network
  service                 = each.value.service
  reserved_peering_ranges = each.value.reserved_peering_ranges

  depends_on = [google_project_service.services]
}

# Cloud Functions configuration (if enabled)
resource "google_cloudfunctions2_function" "functions" {
  for_each = var.cloud_functions

  project  = each.value.project_id
  name     = each.value.name
  location = each.value.location

  build_config {
    runtime     = each.value.runtime
    entry_point = each.value.entry_point

    source {
      storage_source {
        bucket = each.value.source_bucket
        object = each.value.source_object
      }
    }
  }

  service_config {
    max_instance_count = each.value.max_instances
    available_memory   = each.value.memory
    timeout_seconds    = each.value.timeout
  }

  depends_on = [google_project_service.services]
}

# Monitoring notification channels (if monitoring is enabled)
resource "google_monitoring_notification_channel" "notification_channels" {
  for_each = var.monitoring_notification_channels

  project      = each.value.project_id
  display_name = each.value.display_name
  type         = each.value.type
  labels       = each.value.labels
  description  = each.value.description

  depends_on = [google_project_service.services]
}

# Cloud Run services configuration (if enabled)
resource "google_cloud_run_service" "services" {
  for_each = var.cloud_run_services

  project  = each.value.project_id
  name     = each.value.name
  location = each.value.location

  template {
    spec {
      containers {
        image = each.value.image
        
        dynamic "env" {
          for_each = each.value.environment_variables
          content {
            name  = env.key
            value = env.value
          }
        }
        
        resources {
          limits = each.value.resource_limits
        }
      }
      
      container_concurrency = each.value.concurrency
      timeout_seconds      = each.value.timeout
    }

    metadata {
      annotations = merge(
        each.value.annotations,
        {
          "autoscaling.knative.dev/maxScale" = tostring(each.value.max_scale)
          "autoscaling.knative.dev/minScale" = tostring(each.value.min_scale)
        }
      )
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.services]
}

locals {
  # Flatten project services for resource creation
  project_services = merge([
    for project_name, project in var.projects : {
      for service in project.services : "${project_name}-${service}" => {
        project_id = project.project_id
        service    = service
      }
    }
  ]...)
}
