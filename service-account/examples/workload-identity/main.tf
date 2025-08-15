# Workload Identity Example
# This example creates service accounts configured for GKE Workload Identity

provider "google" {
  project = var.project_id
  region  = var.region
}

module "workload_identity_service_accounts" {
  source = "../../"

  project_id = var.project_id

  service_accounts = {
    # Service account for frontend application
    "frontend-app" = {
      display_name = "Frontend Application Service Account"
      description  = "Service account for frontend application in GKE"
      roles = [
        "roles/storage.objectViewer",
        "roles/monitoring.metricWriter",
        "roles/logging.logWriter"
      ]
      workload_identity_users = [
        "default/frontend-app",
        "production/frontend-app"
      ]
    }

    # Service account for backend API
    "backend-api" = {
      display_name = "Backend API Service Account"
      description  = "Service account for backend API services"
      roles = [
        "roles/cloudsql.client",
        "roles/storage.objectAdmin",
        "roles/bigquery.dataEditor",
        "roles/secretmanager.secretAccessor"
      ]
      workload_identity_users = [
        "default/backend-api",
        "staging/backend-api",
        "production/backend-api"
      ]
    }

    # Service account for batch jobs
    "batch-jobs" = {
      display_name = "Batch Jobs Service Account"
      description  = "Service account for batch processing jobs"
      roles = [
        "roles/bigquery.dataEditor",
        "roles/bigquery.jobUser",
        "roles/storage.objectAdmin",
        "roles/dataflow.developer"
      ]
      workload_identity_users = [
        "jobs/batch-processor",
        "jobs/data-importer"
      ]
    }

    # Service account for monitoring
    "monitoring-agent" = {
      display_name = "Monitoring Agent Service Account"
      description  = "Service account for monitoring and observability"
      roles = [
        "roles/monitoring.metricWriter",
        "roles/logging.logWriter",
        "roles/cloudtrace.agent",
        "roles/errorreporting.writer"
      ]
      workload_identity_users = [
        "kube-system/monitoring-agent",
        "observability/prometheus",
        "observability/grafana"
      ]
    }
  }

  # Enable required APIs
  required_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "cloudsql.googleapis.com",
    "secretmanager.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}
