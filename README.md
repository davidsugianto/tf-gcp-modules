# GCP GKE Terraform Modules

This repository contains reusable Terraform modules for creating Google Kubernetes Engine (GKE) clusters and node pools on Google Cloud Platform.

## Modules

### 1. container-cluster
Creates a GKE cluster with comprehensive configuration options including:
- Private cluster configuration
- Workload Identity
- Network policies
- Master authorized networks
- Maintenance windows
- Add-ons configuration

### 2. container-node-pools
Creates and manages GKE node pools with features like:
- Autoscaling
- Multiple machine types and disk configurations
- Spot and preemptible instances
- GPU support
- Taints and labels
- Security configurations

## Quick Start

```hcl
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

## Directory Structure

```
.
├── container-cluster/          # GKE cluster module
│   ├── main.tf                # Main cluster resource
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   └── provider.tf            # Provider requirements
├── container-node-pools/      # Node pools module
│   ├── main.tf                # Node pool resources
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   └── provider.tf            # Provider requirements
└── examples/                  # Usage examples
    ├── main.tf                # Example configuration
    ├── variables.tf           # Example variables
    ├── outputs.tf             # Example outputs
    ├── terraform.tfvars.example # Sample values
    └── README.md              # Example documentation
```

## Features

### Security Features
- **Private Nodes**: Nodes have no external IP addresses
- **Workload Identity**: Secure access to GCP services from pods
- **Network Policies**: Control traffic between pods
- **Shielded Nodes**: Enhanced security with secure boot and integrity monitoring
- **Master Authorized Networks**: Control access to the cluster master

### Reliability Features
- **Auto-repair**: Automatically repair unhealthy nodes
- **Auto-upgrade**: Automatically upgrade nodes to latest version
- **Multi-zone**: Deploy across multiple zones for high availability
- **Maintenance Windows**: Control when cluster maintenance occurs

### Cost Optimization
- **Spot Instances**: Use spot instances for fault-tolerant workloads
- **Preemptible Nodes**: Alternative cost-saving option
- **Autoscaling**: Automatically scale node pools based on demand
- **Multiple Machine Types**: Choose appropriate instance sizes

### Advanced Features
- **GPU Support**: Add GPUs to node pools for ML/AI workloads
- **Local SSDs**: High-performance local storage
- **Taints and Tolerations**: Control pod scheduling
- **Custom Service Accounts**: Use specific service accounts for nodes

## Requirements

- **Terraform**: >= 1.0
- **Google Cloud Provider**: ~> 5.0
- **GCP APIs**: The following APIs must be enabled:
  - Kubernetes Engine API
  - Compute Engine API
  - IAM API

## Getting Started

1. **Clone the repository**
2. **Configure GCP authentication** using `gcloud auth application-default login`
3. **See the examples/ directory** for detailed usage examples
4. **Customize the modules** for your specific needs

## Authentication

Configure authentication using one of:
1. `gcloud auth application-default login`
2. Service account key file
3. Workload Identity (when running in GKE)

## Usage Examples

See the `examples/` directory for comprehensive usage examples including:
- Basic cluster setup
- Private cluster with custom networking
- Multiple node pools with different configurations
- Cost-optimized setups with spot instances
