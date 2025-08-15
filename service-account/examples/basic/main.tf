# Basic Service Account Example
# This example creates simple service accounts with basic IAM roles

provider "google" {
  project = var.project_id
  region  = var.region
}

module "basic_service_accounts" {
  source = "../../"

  project_id = var.project_id

  # Naming configuration
  names_prefix = var.names_prefix
  names_suffix = var.names_suffix

  service_accounts = {
    # Simple service account for compute operations
    "compute-worker" = {
      display_name = "Compute Worker Service Account"
      description  = "Service account for compute operations"
      roles = [
        "roles/compute.instanceAdmin.v1",
        "roles/storage.objectViewer"
      ]
    }

    # Service account for storage operations
    "storage-admin" = {
      display_name = "Storage Administrator"
      description  = "Service account for storage administration"
      roles = [
        "roles/storage.admin",
        "roles/storage.objectAdmin"
      ]
    }

    # Monitoring service account
    "monitoring" = {
      display_name = "Monitoring Service Account"
      description  = "Service account for monitoring and logging"
      roles = [
        "roles/monitoring.viewer",
        "roles/logging.viewer",
        "roles/cloudtrace.user"
      ]
    }

    # Disabled service account (for demonstration)
    "disabled-example" = {
      display_name = "Disabled Example"
      description  = "Example of a disabled service account"
      disabled     = true
      roles        = []
    }
  }

  # Optional: Enable additional APIs
  required_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}
