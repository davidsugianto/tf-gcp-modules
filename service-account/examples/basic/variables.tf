variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "names_prefix" {
  description = "Prefix to add to service account names"
  type        = string
  default     = "basic-"
}

variable "names_suffix" {
  description = "Suffix to add to service account names"
  type        = string
  default     = ""
}
