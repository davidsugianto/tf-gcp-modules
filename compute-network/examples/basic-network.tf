# Basic Network Example
# This example shows how to create a basic VPC with subnets, routes, and firewall rules

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

# Basic Network Configuration
module "basic_network" {
  source = "../"

  project_id = var.project_id

  # VPC Configuration
  vpcs = {
    "main-vpc" = {
      description             = "Main VPC for basic example"
      auto_create_subnetworks = false
      routing_mode           = "REGIONAL"
      mtu                    = 1460
    }
  }

  # Subnet Configuration
  subnets = {
    "web-subnet" = {
      network                    = "projects/${var.project_id}/global/networks/main-vpc"
      ip_cidr_range             = "10.0.1.0/24"
      region                    = var.region
      description               = "Subnet for web servers"
      private_ip_google_access  = true
      enable_flow_logs          = false
    },
    
    "app-subnet" = {
      network                    = "projects/${var.project_id}/global/networks/main-vpc"
      ip_cidr_range             = "10.0.2.0/24"
      region                    = var.region
      description               = "Subnet for application servers"
      private_ip_google_access  = true
      enable_flow_logs          = false
    },
    
    "db-subnet" = {
      network                    = "projects/${var.project_id}/global/networks/main-vpc"
      ip_cidr_range             = "10.0.3.0/24"
      region                    = var.region
      description               = "Subnet for database servers"
      private_ip_google_access  = true
      enable_flow_logs          = false
    }
  }

  # Custom Routes
  routes = {
    "default-internet-gateway" = {
      network           = "projects/${var.project_id}/global/networks/main-vpc"
      dest_range       = "0.0.0.0/0"
      next_hop_gateway = "default-internet-gateway"
      priority         = 1000
      description      = "Default route to internet"
    }
  }

  # Firewall Rules
  firewall_rules = {
    "allow-internal" = {
      network       = "projects/${var.project_id}/global/networks/main-vpc"
      description   = "Allow internal communication"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.0.0.0/16"]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }, {
        protocol = "udp"
        ports    = ["0-65535"]
      }, {
        protocol = "icmp"
        ports    = []
      }]
    },
    
    "allow-ssh" = {
      network       = "projects/${var.project_id}/global/networks/main-vpc"
      description   = "Allow SSH access"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["ssh"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    
    "allow-http-https" = {
      network       = "projects/${var.project_id}/global/networks/main-vpc"
      description   = "Allow HTTP and HTTPS"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["web"]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
    }
  }

  # Global settings
  enable_flow_logs = false
  labels = {
    environment = "example"
    team        = "infrastructure"
    example     = "basic-network"
  }
}

# Outputs
output "vpc_info" {
  description = "VPC information"
  value       = module.basic_network.vpcs
}

output "subnet_info" {
  description = "Subnet information"
  value       = module.basic_network.subnets
}

output "firewall_rules_info" {
  description = "Firewall rules information"
  value       = module.basic_network.firewall_rules
}

output "network_summary" {
  description = "Network summary"
  value       = module.basic_network.network_summary
}
