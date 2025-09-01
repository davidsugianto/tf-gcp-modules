# Shared VPC Example
# This example shows how to create a Shared VPC with service projects

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
variable "host_project_id" {
  description = "The host project ID for Shared VPC"
  type        = string
}

variable "service_project_ids" {
  description = "List of service project IDs"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

# Shared VPC Host Configuration
module "shared_vpc_host" {
  source = "../"

  project_id = var.host_project_id

  # Enable Shared VPC host
  shared_vpc_host_project = true

  # VPC Configuration
  vpcs = {
    "shared-vpc" = {
      description             = "Shared VPC for organization"
      auto_create_subnetworks = false
      routing_mode           = "REGIONAL"
      mtu                    = 1460
      enable_flow_logs       = true
    }
  }

  # Subnet Configuration for different service projects
  subnets = {
    "prod-web-subnet" = {
      network                   = "projects/${var.host_project_id}/global/networks/shared-vpc"
      ip_cidr_range            = "10.10.1.0/24"
      region                   = var.region
      description              = "Production web tier subnet"
      private_ip_google_access = true
      enable_flow_logs         = true
      
      flow_logs_config = {
        aggregation_interval = "INTERVAL_10_MIN"
        flow_sampling       = 0.1
        metadata           = "INCLUDE_ALL_METADATA"
      }
    },
    
    "prod-app-subnet" = {
      network                   = "projects/${var.host_project_id}/global/networks/shared-vpc"
      ip_cidr_range            = "10.10.2.0/24"
      region                   = var.region
      description              = "Production application tier subnet"
      private_ip_google_access = true
      enable_flow_logs         = true
    },
    
    "prod-db-subnet" = {
      network                   = "projects/${var.host_project_id}/global/networks/shared-vpc"
      ip_cidr_range            = "10.10.3.0/24"
      region                   = var.region
      description              = "Production database tier subnet"
      private_ip_google_access = true
      enable_flow_logs         = false
    },
    
    "dev-subnet" = {
      network                   = "projects/${var.host_project_id}/global/networks/shared-vpc"
      ip_cidr_range            = "10.10.10.0/24"
      region                   = var.region
      description              = "Development environment subnet"
      private_ip_google_access = true
      enable_flow_logs         = false
    },
    
    "staging-subnet" = {
      network                   = "projects/${var.host_project_id}/global/networks/shared-vpc"
      ip_cidr_range            = "10.10.20.0/24"
      region                   = var.region
      description              = "Staging environment subnet"
      private_ip_google_access = true
      enable_flow_logs         = false
    },
    
    "gke-subnet" = {
      network                   = "projects/${var.host_project_id}/global/networks/shared-vpc"
      ip_cidr_range            = "10.10.100.0/24"
      region                   = var.region
      description              = "GKE nodes subnet"
      private_ip_google_access = true
      enable_flow_logs         = true
      
      # Secondary ranges for GKE
      secondary_ip_ranges = [
        {
          range_name    = "gke-pods"
          ip_cidr_range = "10.20.0.0/14"
        },
        {
          range_name    = "gke-services"
          ip_cidr_range = "10.10.200.0/24"
        }
      ]
    }
  }

  # IAM bindings for service projects
  subnet_iam_bindings = {
    for i, project_id in var.service_project_ids : "service-project-${i}" => {
      subnet_name = "prod-web-subnet"
      role        = "roles/compute.networkUser"
      members = [
        "serviceAccount:${data.google_project.service_projects[i].number}-compute@developer.gserviceaccount.com",
        "serviceAccount:service-${data.google_project.service_projects[i].number}@container-engine-robot.iam.gserviceaccount.com"
      ]
    }
  }

  # Custom Routes
  routes = {
    "route-to-onprem" = {
      network      = "projects/${var.host_project_id}/global/networks/shared-vpc"
      dest_range   = "192.168.0.0/16"
      next_hop_ip  = "10.10.1.100"  # VPN gateway IP
      priority     = 1000
      description  = "Route to on-premises network"
      tags         = ["vpn-route"]
    }
  }

  # Firewall Rules for Shared VPC
  firewall_rules = {
    "shared-vpc-allow-internal" = {
      network       = "projects/${var.host_project_id}/global/networks/shared-vpc"
      description   = "Allow internal communication within shared VPC"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.10.0.0/16"]
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
    
    "shared-vpc-allow-ssh" = {
      network       = "projects/${var.host_project_id}/global/networks/shared-vpc"
      description   = "Allow SSH from corporate networks"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["203.0.113.0/24"]  # Corporate IP range
      target_tags   = ["ssh"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    
    "shared-vpc-allow-lb-health-check" = {
      network       = "projects/${var.host_project_id}/global/networks/shared-vpc"
      description   = "Allow load balancer health checks"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = [
        "130.211.0.0/22",
        "35.191.0.0/16"
      ]
      target_tags   = ["http-server"]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443", "8080"]
      }]
    },
    
    "shared-vpc-deny-cross-env" = {
      network         = "projects/${var.host_project_id}/global/networks/shared-vpc"
      description     = "Deny traffic between dev and prod environments"
      direction       = "INGRESS"
      priority        = 900
      source_ranges   = ["10.10.10.0/24"]  # Dev subnet
      destination_ranges = [
        "10.10.1.0/24",   # Prod web
        "10.10.2.0/24",   # Prod app
        "10.10.3.0/24"    # Prod db
      ]
      deny = [{
        protocol = "all"
        ports    = []
      }]
    }
  }

  # Cloud NAT for private subnets
  cloud_nats = {
    "shared-vpc-nat" = {
      region  = var.region
      network = "projects/${var.host_project_id}/global/networks/shared-vpc"
      
      nat_ip_allocate_option                = "MANUAL_ONLY"
      source_subnetwork_ip_ranges_to_nat    = "LIST_OF_SUBNETWORKS"
      
      # Reserve static IPs for NAT
      nat_ips = [
        google_compute_address.nat_ip.name
      ]
      
      subnetworks = [
        {
          name                    = "projects/${var.host_project_id}/regions/${var.region}/subnetworks/prod-app-subnet"
          source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
        },
        {
          name                    = "projects/${var.host_project_id}/regions/${var.region}/subnetworks/prod-db-subnet"
          source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
        }
      ]
      
      enable_logging = true
      log_filter     = "ALL"
    }
  }

  # Private Service Connect for Google APIs
  private_service_connects = {
    "googleapis-psc" = {
      network    = "projects/${var.host_project_id}/global/networks/shared-vpc"
      target     = "all-apis"
      port_range = null
    }
  }

  # Global settings
  enable_flow_logs = true
  labels = {
    environment = "shared"
    team        = "platform"
    vpc_type    = "shared"
    example     = "shared-vpc"
  }
}

# Reserved IP for NAT gateway
resource "google_compute_address" "nat_ip" {
  project      = var.host_project_id
  name         = "shared-vpc-nat-ip"
  region       = var.region
  address_type = "EXTERNAL"
  description  = "Static IP for Shared VPC NAT gateway"
}

# Service project data sources
data "google_project" "service_projects" {
  count      = length(var.service_project_ids)
  project_id = var.service_project_ids[count.index]
}

# Attach service projects to shared VPC
resource "google_compute_shared_vpc_service_project" "service_projects" {
  count           = length(var.service_project_ids)
  host_project    = var.host_project_id
  service_project = var.service_project_ids[count.index]
  
  depends_on = [module.shared_vpc_host]
}

# Outputs
output "shared_vpc_info" {
  description = "Shared VPC information"
  value       = module.shared_vpc_host.vpcs
}

output "shared_vpc_subnets" {
  description = "Shared VPC subnets information"
  value       = module.shared_vpc_host.subnets
}

output "service_project_attachments" {
  description = "Service project attachments"
  value = {
    for i, attachment in google_compute_shared_vpc_service_project.service_projects : var.service_project_ids[i] => {
      host_project    = attachment.host_project
      service_project = attachment.service_project
    }
  }
}

output "nat_gateway_ip" {
  description = "NAT gateway IP address"
  value       = google_compute_address.nat_ip.address
}

output "shared_vpc_summary" {
  description = "Shared VPC deployment summary"
  value = {
    host_project_id     = var.host_project_id
    service_projects    = var.service_project_ids
    vpc_created        = length(module.shared_vpc_host.vpcs)
    subnets_created    = length(module.shared_vpc_host.subnets)
    firewall_rules     = length(module.shared_vpc_host.firewall_rules)
    nat_ip             = google_compute_address.nat_ip.address
  }
}
