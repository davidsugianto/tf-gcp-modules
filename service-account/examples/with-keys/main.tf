# Service Accounts with Keys Example
# This example creates service accounts with generated keys for external applications

provider "google" {
  project = var.project_id
  region  = var.region
}

module "service_accounts_with_keys" {
  source = "../../"

  project_id = var.project_id

  service_accounts = {
    # Service account for CI/CD pipeline
    "ci-cd" = {
      display_name = "CI/CD Pipeline Service Account"
      description  = "Service account for continuous integration and deployment"
      generate_key = true
      roles = [
        "roles/cloudbuild.builds.editor",
        "roles/storage.objectAdmin",
        "roles/artifactregistry.writer",
        "roles/container.developer"
      ]
    }

    # Service account for external application
    "external-app" = {
      display_name    = "External Application"
      description     = "Service account for external application access"
      generate_key    = true
      key_algorithm   = "KEY_ALG_RSA_2048"
      private_key_type = "TYPE_GOOGLE_CREDENTIALS_FILE"
      roles = [
        "roles/storage.objectViewer",
        "roles/bigquery.dataViewer",
        "roles/monitoring.metricWriter"
      ]
    }

    # Service account with key rotation
    "rotating-key" = {
      display_name      = "Rotating Key Service Account"
      description       = "Service account with rotating keys"
      generate_key      = true
      key_rotation_date = var.key_rotation_date
      roles = [
        "roles/compute.viewer",
        "roles/storage.objectViewer"
      ]
    }

    # Service account for data processing (no key)
    "data-processor" = {
      display_name = "Data Processing Service Account"
      description  = "Service account for data processing workloads"
      generate_key = false
      roles = [
        "roles/bigquery.dataEditor",
        "roles/bigquery.jobUser",
        "roles/storage.objectAdmin",
        "roles/dataflow.developer"
      ]
    }
  }

  # Enable required APIs
  required_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "bigquery.googleapis.com",
    "dataflow.googleapis.com"
  ]
}
