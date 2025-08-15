# Custom Roles Example
# This example creates service accounts with custom IAM roles

provider "google" {
  project = var.project_id
  region  = var.region
}

module "custom_roles_service_accounts" {
  source = "../../"

  project_id = var.project_id

  # Define custom IAM roles
  custom_roles = {
    "storage_viewer_limited" = {
      title = "Storage Viewer Limited"
      description = "Custom role for limited storage access"
      permissions = [
        "storage.objects.get",
        "storage.objects.list",
        "storage.buckets.get"
      ]
      stage = "GA"
    }

    "compute_operator" = {
      title = "Compute Operator"
      description = "Custom role for compute operations"
      permissions = [
        "compute.instances.get",
        "compute.instances.list",
        "compute.instances.start",
        "compute.instances.stop",
        "compute.instances.reset",
        "compute.zones.get",
        "compute.zones.list"
      ]
    }

    "bigquery_limited_editor" = {
      title = "BigQuery Limited Editor"
      description = "Custom role for limited BigQuery operations"
      permissions = [
        "bigquery.datasets.get",
        "bigquery.tables.get",
        "bigquery.tables.getData",
        "bigquery.tables.list",
        "bigquery.jobs.create",
        "bigquery.jobs.get"
      ]
    }

    "monitoring_custom" = {
      title = "Custom Monitoring Role"
      description = "Custom role for monitoring with specific permissions"
      permissions = [
        "monitoring.timeSeries.create",
        "monitoring.metricDescriptors.create",
        "logging.logEntries.create",
        "logging.logEntries.route"
      ]
    }
  }

  service_accounts = {
    # Service account using custom storage role
    "storage-reader" = {
      display_name = "Storage Reader Service Account"
      description  = "Service account with custom storage viewing permissions"
      custom_roles = ["storage_viewer_limited"]
      roles = [
        "roles/logging.logWriter"
      ]
    }

    # Service account for compute operations
    "compute-operator" = {
      display_name = "Compute Operator Service Account"
      description  = "Service account for compute instance management"
      custom_roles = ["compute_operator"]
      roles = [
        "roles/compute.viewer"  # Additional predefined role
      ]
    }

    # Service account for data analysis
    "data-analyst" = {
      display_name = "Data Analyst Service Account"
      description  = "Service account for data analysis with limited BigQuery access"
      custom_roles = ["bigquery_limited_editor", "storage_viewer_limited"]
      roles = [
        "roles/monitoring.viewer"
      ]
    }

    # Service account with monitoring permissions
    "custom-monitoring" = {
      display_name = "Custom Monitoring Service Account"
      description  = "Service account with custom monitoring permissions"
      custom_roles = ["monitoring_custom"]
      roles = [
        "roles/errorreporting.writer"
      ]
    }

    # Service account with multiple custom roles and cross-project access
    "multi-project" = {
      display_name = "Multi-Project Service Account"
      description  = "Service account with access to multiple projects"
      custom_roles = ["storage_viewer_limited", "compute_operator"]
      roles = [
        "roles/viewer"
      ]
      project_roles = var.additional_project_roles
    }

    # Service account with impersonation capabilities
    "impersonation-target" = {
      display_name = "Impersonation Target"
      description  = "Service account that can be impersonated"
      custom_roles = ["bigquery_limited_editor"]
      impersonators = var.impersonators
    }
  }

  # Enable required APIs
  required_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}
