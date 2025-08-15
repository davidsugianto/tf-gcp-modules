# Required variables
variable "project_id" {
  description = "The project ID where service accounts will be created"
  type        = string
}

# Service accounts configuration
variable "service_accounts" {
  description = "Map of service accounts to create"
  type = map(object({
    # Basic configuration
    display_name = optional(string, null)
    description  = optional(string, "Managed by Terraform")
    disabled     = optional(bool, false)

    # IAM roles (project-level)
    roles = optional(list(string), [])
    
    # Cross-project roles (map of project_id -> role)
    project_roles = optional(map(string), {})
    
    # Custom roles to assign
    custom_roles = optional(list(string), [])

    # Service account key generation
    generate_key       = optional(bool, false)
    key_algorithm      = optional(string, "KEY_ALG_RSA_2048")
    private_key_type   = optional(string, "TYPE_GOOGLE_CREDENTIALS_FILE")
    public_key_type    = optional(string, "TYPE_X509_PEM_FILE")
    key_rotation_date  = optional(string, null)

    # Service account impersonation
    impersonators = optional(list(string), [])

    # Workload Identity (for GKE)
    workload_identity_users = optional(list(string), [])
  }))
  default = {}
}

# Naming configuration
variable "names_prefix" {
  description = "Prefix to add to service account names"
  type        = string
  default     = ""
}

variable "names_suffix" {
  description = "Suffix to add to service account names"
  type        = string
  default     = ""
}

# Custom IAM roles
variable "custom_roles" {
  description = "Map of custom IAM roles to create"
  type = map(object({
    title       = string
    description = optional(string, "Custom role managed by Terraform")
    permissions = list(string)
    stage       = optional(string, "GA")
  }))
  default = {}
}

# IAM conditions for role assignments
variable "iam_conditions" {
  description = "Map of IAM conditions for role assignments"
  type = map(object({
    title       = optional(string, null)
    description = optional(string, null)
    expression  = optional(string, null)
  }))
  default = {}
}

# Required APIs
variable "required_apis" {
  description = "List of APIs to enable for service accounts"
  type        = list(string)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

# Labels
variable "labels" {
  description = "Labels to apply to service accounts"
  type        = map(string)
  default     = {}
}

# Organization and folder settings
variable "organization_id" {
  description = "Organization ID for organization-level service accounts"
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Folder ID for folder-level service accounts"
  type        = string
  default     = null
}

# Service account key storage
variable "key_storage_location" {
  description = "Location to store service account keys (if generated)"
  type        = string
  default     = null
}

# Billing account settings
variable "billing_account_id" {
  description = "Billing account ID for billing-related permissions"
  type        = string
  default     = null
}

# Regional settings
variable "region" {
  description = "Default region for regional resources"
  type        = string
  default     = "us-central1"
}

# Common role sets for convenience
variable "predefined_roles" {
  description = "Map of predefined role sets that can be referenced"
  type = map(list(string))
  default = {
    # Common role combinations
    compute_admin = [
      "roles/compute.admin",
      "roles/iam.serviceAccountUser"
    ]
    
    storage_admin = [
      "roles/storage.admin",
      "roles/storage.objectAdmin"
    ]
    
    kubernetes_developer = [
      "roles/container.developer",
      "roles/storage.objectViewer",
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter"
    ]
    
    ci_cd = [
      "roles/cloudbuild.builds.editor",
      "roles/storage.objectAdmin",
      "roles/artifactregistry.writer",
      "roles/container.developer"
    ]
    
    monitoring = [
      "roles/monitoring.viewer",
      "roles/logging.viewer",
      "roles/cloudtrace.user"
    ]
    
    data_engineer = [
      "roles/bigquery.dataEditor",
      "roles/bigquery.jobUser",
      "roles/storage.objectAdmin",
      "roles/dataflow.developer"
    ]
    
    security_admin = [
      "roles/iam.securityAdmin",
      "roles/cloudkms.admin",
      "roles/secretmanager.admin"
    ]
  }
}

# Service account token settings
variable "token_creation_policy" {
  description = "Policy for service account token creation"
  type = object({
    allow_service_account_token_creation = optional(bool, true)
    allowed_locations                   = optional(list(string), [])
  })
  default = {
    allow_service_account_token_creation = true
    allowed_locations                   = []
  }
}
