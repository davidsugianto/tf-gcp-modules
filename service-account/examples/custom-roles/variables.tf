variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "additional_project_roles" {
  description = "Map of additional project IDs to roles for cross-project access"
  type        = map(string)
  default     = {}
  # Example:
  # {
  #   "project-2" = "roles/viewer"
  #   "project-3" = "roles/storage.objectViewer"
  # }
}

variable "impersonators" {
  description = "List of members who can impersonate service accounts"
  type        = list(string)
  default     = []
  # Example:
  # [
  #   "user:admin@example.com",
  #   "serviceAccount:ci-cd@project.iam.gserviceaccount.com"
  # ]
}
