# Required variables
variable "project_id" {
  description = "The project ID where the cluster will be created"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "location" {
  description = "The location (region or zone) where the cluster will be created"
  type        = string
}

# Network configuration
variable "network" {
  description = "The VPC network where the cluster will be created"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork where the cluster will be created"
  type        = string
  default     = null
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for cluster pods"
  type        = string
  default     = null
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range for services"
  type        = string
  default     = null
}

# Private cluster configuration
variable "enable_private_nodes" {
  description = "Enable private nodes"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the Kubernetes master"
  type        = string
  default     = "172.16.0.0/28"
}

# Master authorized networks
variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

# Authentication
variable "issue_client_certificate" {
  description = "Issue client certificate"
  type        = bool
  default     = false
}

# Workload Identity
variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

# Network policy
variable "network_policy_enabled" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

# Add-ons
variable "horizontal_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling"
  type        = bool
  default     = true
}

variable "http_load_balancing" {
  description = "Enable HTTP load balancing"
  type        = bool
  default     = true
}

# Maintenance
variable "maintenance_start_time" {
  description = "Time window for maintenance operations format HH:MM"
  type        = string
  default     = "03:00"
}

# Release channel
variable "release_channel" {
  description = "The release channel of this cluster"
  type        = string
  default     = "STABLE"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE", "UNSPECIFIED"], var.release_channel)
    error_message = "Release channel must be one of RAPID, REGULAR, STABLE, or UNSPECIFIED."
  }
}

# Logging and monitoring
variable "logging_service" {
  description = "The logging service that the cluster should write logs to"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "The monitoring service that the cluster should write metrics to"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

# Resource labels
variable "resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  type        = map(string)
  default     = {}
}

# Timeouts
variable "cluster_timeout_create" {
  description = "Timeout for creating the cluster"
  type        = string
  default     = "45m"
}

variable "cluster_timeout_update" {
  description = "Timeout for updating the cluster"
  type        = string
  default     = "45m"
}

variable "cluster_timeout_delete" {
  description = "Timeout for deleting the cluster"
  type        = string
  default     = "45m"
}
