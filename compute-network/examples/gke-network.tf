# GKE Network Example
# This example shows how to create a VPC optimized for GKE with secondary IP ranges

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

# GKE Network Configuration
module "gke_network" {
  source = "../"

  project_id = var.project_id

  # VPC Configuration
  vpcs = {
    "gke-vpc" = {
      description             = "VPC for GKE cluster"
      auto_create_subnetworks = false
      routing_mode           = "REGIONAL"
      mtu                    = 1460
      enable_flow_logs       = true
    }
  }

  # Subnet Configuration with secondary ranges for GKE
  subnets = {
    "gke-subnet" = {
      network                   = "projects/${var.project_id}/global/networks/gke-vpc"
      ip_cidr_range            = "10.0.0.0/20"
      region                   = var.region
      description              = "Primary subnet for GKE nodes"
      private_ip_google_access = true
      enable_flow_logs         = true
      
      # Secondary IP ranges for GKE pods and services
      secondary_ip_ranges = [
        {
          range_name    = "gke-pods"
          ip_cidr_range = "10.4.0.0/14"
        },
        {
          range_name    = "gke-services"
          ip_cidr_range = "10.0.16.0/20"
        }
      ]
      
      flow_logs_config = {
        aggregation_interval = "INTERVAL_5_SEC"
        flow_sampling       = 0.5
        metadata           = "INCLUDE_ALL_METADATA"
      }
    },
    
    "management-subnet" = {
      network                   = "projects/${var.project_id}/global/networks/gke-vpc"
      ip_cidr_range            = "10.0.32.0/24"
      region                   = var.region
      description              = "Management subnet for bastion hosts"
      private_ip_google_access = true
      enable_flow_logs         = false
    }
  }

  # Custom Routes for private GKE
  routes = {
    "default-internet-route" = {
      network           = "projects/${var.project_id}/global/networks/gke-vpc"
      dest_range       = "0.0.0.0/0"
      next_hop_gateway = "default-internet-gateway"
      priority         = 1000
      description      = "Default route to internet"
      tags             = ["gke-node"]
    }
  }

  # Firewall Rules for GKE
  firewall_rules = {
    "gke-allow-internal" = {
      network       = "projects/${var.project_id}/global/networks/gke-vpc"
      description   = "Allow internal GKE communication"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = [
        "10.0.0.0/20",   # Node subnet
        "10.4.0.0/14",   # Pod subnet
        "10.0.16.0/20"   # Service subnet
      ]
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
    
    "gke-allow-master-webhook" = {
      network       = "projects/${var.project_id}/global/networks/gke-vpc"
      description   = "Allow GKE master to access webhooks on nodes"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["172.16.0.0/28"]  # GKE master range (example)
      target_tags   = ["gke-node"]
      allow = [{
        protocol = "tcp"
        ports    = ["8443", "9443", "15017"]
      }]
    },
    
    "allow-ssh-bastion" = {
      network       = "projects/${var.project_id}/global/networks/gke-vpc"
      description   = "Allow SSH to bastion host"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["bastion"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    
    "allow-ssh-from-bastion" = {
      network       = "projects/${var.project_id}/global/networks/gke-vpc"
      description   = "Allow SSH from bastion to other resources"
      direction     = "INGRESS"
      priority      = 1000
      source_tags   = ["bastion"]
      target_tags   = ["gke-node"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    
    "deny-all-egress" = {
      network         = "projects/${var.project_id}/global/networks/gke-vpc"
      description     = "Deny all egress traffic by default"
      direction       = "EGRESS"
      priority        = 65535
      destination_ranges = ["0.0.0.0/0"]
      deny = [{
        protocol = "all"
        ports    = []
      }]
    },
    
    "allow-egress-internal" = {
      network            = "projects/${var.project_id}/global/networks/gke-vpc"
      description        = "Allow internal egress traffic"
      direction          = "EGRESS"
      priority           = 1000
      destination_ranges = [
        "10.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16"
      ]
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
    
    "allow-egress-google-apis" = {
      network            = "projects/${var.project_id}/global/networks/gke-vpc"
      description        = "Allow egress to Google APIs"
      direction          = "EGRESS"
      priority           = 1000
      destination_ranges = ["199.36.153.8/30"]  # restricted.googleapis.com
      target_tags        = ["gke-node"]
      allow = [{
        protocol = "tcp"
        ports    = ["443"]
      }]
    }
  }

  # Cloud NAT for private nodes
  cloud_nats = {
    "gke-nat" = {
      region  = var.region
      network = "projects/${var.project_id}/global/networks/gke-vpc"
      
      nat_ip_allocate_option                = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat    = "LIST_OF_SUBNETWORKS"
      
      subnetworks = [{
        name                    = "projects/${var.project_id}/regions/${var.region}/subnetworks/gke-subnet"
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
      }]
      
      enable_logging = true
      log_filter     = "ERRORS_ONLY"
    }
  }

  # Enable required APIs
  required_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com"
  ]

  # Global settings
  enable_flow_logs = true
  labels = {
    environment = "production"
    team        = "platform"
    use_case    = "gke"
    example     = "gke-network"
  }
}

# Outputs
output "gke_vpc_info" {
  description = "GKE VPC information"
  value       = module.gke_network.vpcs
}

output "gke_subnet_info" {
  description = "GKE subnet information including secondary ranges"
  value       = module.gke_network.subnets
}

output "secondary_ip_ranges" {
  description = "Secondary IP ranges for GKE"
  value       = module.gke_network.secondary_ip_ranges
}

output "cloud_nat_info" {
  description = "Cloud NAT information"
  value       = module.gke_network.cloud_nats
}

output "gke_network_summary" {
  description = "GKE network summary"
  value       = module.gke_network.network_summary
}

# Additional outputs for GKE cluster creation
output "gke_network_name" {
  description = "Network name for GKE cluster"
  value       = module.gke_network.vpc_names["gke-vpc"]
}

output "gke_subnet_name" {
  description = "Subnet name for GKE cluster"
  value       = module.gke_network.subnet_names["gke-subnet"]
}

output "gke_pods_range_name" {
  description = "Secondary range name for GKE pods"
  value       = "gke-pods"
}

output "gke_services_range_name" {
  description = "Secondary range name for GKE services"
  value       = "gke-services"
}
