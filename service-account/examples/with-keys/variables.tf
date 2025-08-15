variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "key_rotation_date" {
  description = "Date for key rotation (YYYY-MM-DD format)"
  type        = string
  default     = "2024-12-31"
}
