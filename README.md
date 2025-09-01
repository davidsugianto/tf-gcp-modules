# GCP Terraform Modules Collection

A comprehensive collection of production-ready Terraform modules for Google Cloud Platform (GCP) infrastructure management. This repository provides enterprise-grade modules for container orchestration, networking, project management, and service account administration.

## 📦 Available Modules

### 🚢 Container & Kubernetes Modules

#### [`container-cluster`](./container-cluster/)
Enterprise-ready GKE cluster creation and management.

**Key Features:**
- Private cluster configuration with custom networking
- Workload Identity integration for secure service access
- Network policies and security hardening
- Master authorized networks and private endpoints
- Maintenance windows and upgrade management
- Comprehensive add-ons configuration (Istio, Ingress, etc.)
- Multi-zone and regional cluster support
- Shielded nodes with secure boot

#### [`container-node-pools`](./container-node-pools/)
Flexible and scalable GKE node pool management.

**Key Features:**
- Dynamic autoscaling with custom metrics
- Multiple machine types and disk configurations
- Spot and preemptible instances for cost optimization
- GPU support for ML/AI workloads
- Advanced taints, labels, and scheduling
- Security configurations and custom service accounts
- Local SSD and persistent disk options

### 🌐 Networking Modules

#### [`compute-network`](./compute-network/)
Comprehensive VPC networking infrastructure management.

**Key Features:**
- **VPC Management**: Custom VPC networks with flexible routing
- **Subnet Configuration**: Primary and secondary IP ranges for GKE
- **Custom Routes**: Advanced routing rules and traffic flow control
- **Firewall Rules**: Comprehensive security rule management
- **Cloud NAT**: Managed NAT gateway for private subnets
- **Network Peering**: VPC-to-VPC connectivity
- **Shared VPC**: Enterprise multi-project networking
- **Private Service Connect**: Secure Google services access
- **Flow Logs**: Network traffic monitoring and analysis

**Sub-modules:**
- `vpc/` - VPC network creation and management
- `subnets/` - Subnet configuration with secondary ranges
- `routes/` - Custom routing management
- `firewall-rules/` - Security rules and Cloud Armor policies

### 🏗️ Project & Organization Management

#### [`project-factory`](./project-factory/)
Enterprise-grade project creation and management at scale.

**Key Features:**
- **Project Lifecycle**: Automated project creation with governance
- **IAM Management**: Comprehensive role and service account management
- **Budget Controls**: Automated budget setup with multi-threshold alerts
- **Service Management**: API enablement and configuration
- **Organization Policies**: Compliance and security guardrails
- **Shared VPC Integration**: Service project attachment
- **Multi-Environment**: Standardized dev/staging/prod setups
- **Cost Attribution**: Proper labeling and cost tracking

**Sub-modules:**
- `project/` - Core project creation and configuration
- `services/` - API and service management
- `iam/` - Identity and access management
- `budget/` - Billing and cost management

### 🔐 Identity & Access Management

#### [`service-account`](./service-account/)
Advanced service account management with enterprise features.

**Key Features:**
- Service account creation with custom naming conventions
- Project and cross-project IAM role assignments
- Service account key generation with rotation policies
- Custom IAM role creation and management
- Workload Identity integration for GKE workloads
- Service account impersonation chains
- API enablement and quota management

## Quick Start

```hcl
# Create service accounts
module "service_accounts" {
  source = "./service-account"
  
  project_id = "my-gcp-project"
  
  service_accounts = {
    "gke-workload" = {
      display_name = "GKE Workload Service Account"
      roles = [
        "roles/storage.objectViewer",
        "roles/monitoring.metricWriter"
      ]
      workload_identity_users = ["default/my-app"]
    }
  }
}

# Create a GKE cluster
module "gke_cluster" {
  source = "./container-cluster"
  
  project_id   = "my-gcp-project"
  cluster_name = "my-cluster"
  location     = "us-central1"
}

# Create node pools
module "gke_node_pools" {
  source = "./container-node-pools"
  
  project_id   = "my-gcp-project"
  cluster_name = module.gke_cluster.cluster_name
  location     = "us-central1"
  
  node_pools = {
    "default-pool" = {
      machine_type = "e2-medium"
      autoscaling = {
        min_node_count = 1
        max_node_count = 3
      }
    }
  }
}
```

## 📁 Repository Structure

```
tf-gcp-modules/
├── README.md                   # This file - comprehensive overview
├── validate.sh                # Module validation script
│
├── container-cluster/          # 🚢 GKE cluster module
│   ├── main.tf                # Main cluster configuration
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   └── provider.tf            # Provider requirements
│
├── container-node-pools/      # 🔗 GKE node pools module
│   ├── main.tf                # Node pool resources
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   └── provider.tf            # Provider requirements
│
├── service-account/           # 🔐 Service account module
│   ├── main.tf                # Service account resources
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   ├── provider.tf            # Provider requirements
│   ├── README.md              # Module documentation
│   └── examples/              # Service account examples
│       ├── basic/             # Basic service accounts
│       ├── with-keys/         # Service accounts with keys
│       ├── workload-identity/ # Workload Identity setup
│       ├── custom-roles/      # Custom IAM roles
│       └── README.md          # Examples documentation
│
├── compute-network/           # 🌐 Networking infrastructure module
│   ├── main.tf                # Main orchestrator
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   ├── provider.tf            # Provider requirements
│   ├── README.md              # Module documentation
│   ├── vpc/                   # VPC sub-module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   └── README.md
│   ├── subnets/               # Subnets sub-module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── provider.tf
│   ├── routes/                # Routes sub-module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── provider.tf
│   ├── firewall-rules/        # Firewall rules sub-module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── provider.tf
│   └── examples/              # Networking examples
│       ├── basic-network.tf
│       ├── gke-network.tf
│       ├── shared-vpc.tf
│       └── README.md
│
├── project-factory/           # 🏗️ Project management module
│   ├── main.tf                # Main orchestrator
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   ├── provider.tf            # Provider requirements
│   ├── README.md              # Module documentation
│   ├── project/               # Project creation sub-module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── services/              # API/service management sub-module
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── iam/                   # IAM management sub-module
│   │   └── main.tf
│   ├── budget/                # Budget management sub-module
│   │   └── main.tf
│   └── examples/              # Project factory examples
│       ├── basic-project.tf
│       └── multi-environment.tf
│
└── examples/                  # 📖 Global usage examples
    ├── main.tf                # Complete infrastructure example
    ├── variables.tf           # Example variables
    ├── outputs.tf             # Example outputs
    ├── terraform.tfvars.example # Sample values
    └── README.md              # Examples documentation
```

## 🎯 Complete Infrastructure Examples

### Basic GKE Setup with Networking
```hcl
# Create projects with project factory
module "projects" {
  source = "./project-factory"
  
  billing_account = "ABCDEF-012345-6789AB"
  organization_id = "123456789012"
  
  projects = {
    "gke-project" = {
      project_id = "my-gke-cluster"
      services = [
        "container.googleapis.com",
        "compute.googleapis.com",
        "monitoring.googleapis.com"
      ]
    }
  }
}

# Create VPC network
module "network" {
  source = "./compute-network"
  
  project_id = module.projects.project_ids["gke-project"]
  
  vpcs = {
    "gke-vpc" = {
      description = "VPC for GKE cluster"
    }
  }
  
  subnets = {
    "gke-subnet" = {
      network       = "projects/${module.projects.project_ids["gke-project"]}/global/networks/gke-vpc"
      ip_cidr_range = "10.0.0.0/20"
      region        = "us-central1"
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
    }
  }
}

# Create service accounts
module "service_accounts" {
  source = "./service-account"
  
  project_id = module.projects.project_ids["gke-project"]
  
  service_accounts = {
    "gke-nodes" = {
      display_name = "GKE Node Service Account"
      roles = [
        "roles/monitoring.metricWriter",
        "roles/logging.logWriter",
        "roles/storage.objectViewer"
      ]
    }
  }
}

# Create GKE cluster
module "gke_cluster" {
  source = "./container-cluster"
  
  project_id   = module.projects.project_ids["gke-project"]
  cluster_name = "primary-cluster"
  location     = "us-central1"
  
  network    = module.network.vpc_names["gke-vpc"]
  subnetwork = module.network.subnet_names["gke-subnet"]
  
  secondary_range_name_pods     = "gke-pods"
  secondary_range_name_services = "gke-services"
}

# Create node pools
module "gke_node_pools" {
  source = "./container-node-pools"
  
  project_id   = module.projects.project_ids["gke-project"]
  cluster_name = module.gke_cluster.cluster_name
  location     = "us-central1"
  
  node_pools = {
    "primary-pool" = {
      machine_type   = "e2-standard-4"
      service_account = module.service_accounts.emails["gke-nodes"]
      autoscaling = {
        min_node_count = 1
        max_node_count = 10
      }
    }
  }
}
```

## 🌟 Key Features

### 🔒 Enterprise Security
- **Private Clusters**: No external IP addresses on nodes
- **Workload Identity**: Secure pod-to-GCP service authentication
- **Network Policies**: Microsegmentation and traffic control
- **Shielded Nodes**: Secure boot and integrity monitoring
- **Master Authorized Networks**: Control plane access restriction
- **Organization Policies**: Compliance and governance controls
- **Service Account Management**: Principle of least privilege

### 🚀 High Availability & Reliability
- **Auto-repair & Auto-upgrade**: Self-healing infrastructure
- **Multi-zone Deployment**: Cross-zone redundancy
- **Maintenance Windows**: Controlled update scheduling
- **Health Monitoring**: Comprehensive observability
- **Disaster Recovery**: Backup and restore capabilities

### 💰 Cost Optimization
- **Spot Instances**: Up to 80% cost savings for fault-tolerant workloads
- **Preemptible Nodes**: Alternative cost-saving compute option
- **Cluster Autoscaling**: Dynamic resource allocation
- **Budget Controls**: Automated budget monitoring and alerts
- **Resource Right-sizing**: Optimal instance type selection

### 🔧 Advanced Capabilities
- **GPU Support**: NVIDIA Tesla for ML/AI workloads
- **Local SSDs**: High-performance ephemeral storage
- **Custom Taints & Tolerations**: Advanced workload scheduling
- **Multiple Node Pools**: Heterogeneous compute environments
- **Shared VPC**: Enterprise network architecture

## 📋 Requirements

### Software Requirements
- **Terraform**: `>= 1.0`
- **Google Cloud Provider**: `>= 4.0`
- **Google Beta Provider**: `>= 4.0` (for advanced features)

### GCP APIs (Auto-enabled by modules)
- Cloud Resource Manager API
- Compute Engine API
- Kubernetes Engine API
- Container Registry API
- Cloud Monitoring API
- Cloud Logging API
- Identity and Access Management (IAM) API
- Service Networking API
- Cloud Billing API

### IAM Permissions
Your service account needs:
- `roles/container.clusterAdmin`
- `roles/compute.networkAdmin`
- `roles/iam.serviceAccountAdmin`
- `roles/resourcemanager.projectIamAdmin`
- `roles/billing.projectManager`

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd tf-gcp-modules
```

### 2. Configure Authentication
```bash
# Option 1: User credentials
gcloud auth application-default login

# Option 2: Service account key
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"

# Option 3: Workload Identity (when running in GKE)
# No additional setup required
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Plan and Apply
```bash
# Review the plan
terraform plan -var-file="terraform.tfvars"

# Apply changes
terraform apply -var-file="terraform.tfvars"
```

## 📚 Usage Patterns

### Development Environment
```hcl
module "dev_infrastructure" {
  source = "./project-factory"
  
  projects = {
    "dev-project" = {
      project_id = "my-app-dev"
      auto_generate_suffix = true
      
      budget = {
        amount = { specified_amount = { units = "100" } }
      }
      
      labels = {
        environment = "development"
        team       = "engineering"
      }
    }
  }
}
```

### Production Environment
```hcl
module "prod_infrastructure" {
  source = "./project-factory"
  
  projects = {
    "prod-project" = {
      project_id = "my-app-production"
      lien      = true  # Prevent deletion
      
      budget = {
        amount = { specified_amount = { units = "5000" } }
        threshold_rules = [
          { threshold_percent = 0.5 },
          { threshold_percent = 0.8 },
          { threshold_percent = 1.0 }
        ]
      }
      
      labels = {
        environment = "production"
        criticality = "high"
      }
    }
  }
}
```

### Multi-Region Setup
```hcl
module "global_network" {
  source = "./compute-network"
  
  vpcs = {
    "global-vpc" = {
      routing_mode = "GLOBAL"
      description  = "Global VPC for multi-region deployment"
    }
  }
  
  subnets = {
    "us-central1-subnet" = {
      network       = "projects/${var.project_id}/global/networks/global-vpc"
      ip_cidr_range = "10.1.0.0/20"
      region        = "us-central1"
    }
    "europe-west1-subnet" = {
      network       = "projects/${var.project_id}/global/networks/global-vpc"
      ip_cidr_range = "10.2.0.0/20"
      region        = "europe-west1"
    }
    "asia-southeast1-subnet" = {
      network       = "projects/${var.project_id}/global/networks/global-vpc"
      ip_cidr_range = "10.3.0.0/20"
      region        = "asia-southeast1"
    }
  }
}
```

## 🎯 Use Cases

### 1. **Microservices Platform**
- GKE clusters with Istio service mesh
- Private networking with Cloud NAT
- Workload Identity for service authentication
- Multi-environment project setup

### 2. **Data Processing Pipeline**
- GPU-enabled node pools for ML workloads
- High-memory instances for big data processing
- Spot instances for cost-effective batch jobs
- Integration with Cloud Storage and BigQuery

### 3. **Enterprise Applications**
- Shared VPC for network isolation
- Custom service accounts with minimal permissions
- Organization policies for compliance
- Budget controls and cost attribution

### 4. **Development Workflows**
- Separate environments (dev, staging, prod)
- CI/CD integration with Cloud Build
- Automated testing and deployment
- Cost optimization for development workloads

## 🔧 Advanced Configuration

See individual module READMEs for detailed configuration options:
- [Container Cluster Configuration](./container-cluster/README.md)
- [Node Pools Configuration](./container-node-pools/README.md)
- [Service Account Management](./service-account/README.md)
- [Network Infrastructure](./compute-network/README.md)
- [Project Factory Setup](./project-factory/README.md)

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For questions and support:
1. Check the [examples](./examples/) directory
2. Review individual module documentation
3. Search existing GitHub issues
4. Create a new issue for bugs or feature requests
