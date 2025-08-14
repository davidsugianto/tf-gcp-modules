# GKE Terraform Modules Example

This example demonstrates how to use the GKE cluster and node pools Terraform modules to create a complete Google Kubernetes Engine setup.

## What This Example Creates

- A GKE cluster with private nodes
- Three different node pools:
  - **Default pool**: General-purpose workloads with autoscaling (1-3 nodes)
  - **High-memory pool**: Memory-intensive workloads with taints (0-2 nodes)
  - **Spot pool**: Cost-effective batch workloads using spot instances (0-5 nodes)

## Prerequisites

1. **GCP Project**: You need a GCP project with the following APIs enabled:
   - Kubernetes Engine API
   - Compute Engine API
   - IAM API

2. **Authentication**: Configure authentication using one of:
   - `gcloud auth application-default login`
   - Service account key file
   - Workload Identity (for GKE)

3. **Terraform**: Install Terraform >= 1.0

## Usage

1. **Copy the example configuration:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`:**
   - Replace `your-gcp-project-id` with your actual GCP project ID
   - Adjust other values as needed (region, cluster name, etc.)

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Connect to your cluster:**
   ```bash
   gcloud container clusters get-credentials my-gke-cluster --location us-central1 --project your-gcp-project-id
   ```

## Configuration Options

### Network Configuration

By default, this example uses the `default` VPC network. For production use, consider:
- Creating a custom VPC network
- Using VPC-native networking with secondary IP ranges
- Configuring firewall rules appropriately

### Private Cluster

The example creates a private cluster with:
- Private nodes (no external IP addresses)
- Public endpoint (can be changed to private)
- Master authorized networks for access control

### Node Pools

The example includes three node pools with different characteristics:

1. **Default Pool** (`e2-medium`):
   - General workloads
   - Auto-scaling 1-3 nodes
   - Standard persistent disk

2. **High-Memory Pool** (`e2-highmem-2`):
   - Memory-intensive workloads
   - Auto-scaling 0-2 nodes
   - SSD persistent disk
   - Tainted for specific workloads

3. **Spot Pool** (`e2-standard-2`):
   - Batch/fault-tolerant workloads
   - Auto-scaling 0-5 nodes
   - Spot instances for cost savings
   - Tainted for spot workloads

## Customization

### Adding More Node Pools

You can add additional node pools by extending the `node_pools` variable:

```hcl
node_pools = {
  # ... existing pools ...
  
  "gpu-pool" = {
    machine_type = "n1-standard-2"
    disk_size_gb = 100
    gpu_config = {
      type  = "nvidia-tesla-t4"
      count = 1
    }
    autoscaling = {
      min_node_count = 0
      max_node_count = 2
    }
    taints = [
      {
        key    = "nvidia.com/gpu"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    ]
  }
}
```

### Modifying Cluster Settings

You can customize various cluster settings:

```hcl
# Enable different features
enable_workload_identity = true
network_policy_enabled   = true
release_channel         = "RAPID"  # or "REGULAR", "STABLE"

# Configure maintenance window
maintenance_start_time = "02:00"  # 2:00 AM

# Add resource labels
resource_labels = {
  environment = "production"
  team        = "platform"
  cost_center = "engineering"
}
```

## Outputs

After successful deployment, you'll get outputs including:
- Cluster name and endpoint
- Node pool information
- kubectl connection command
- Network configuration details

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Security Considerations

1. **Master Authorized Networks**: Configure appropriate CIDR blocks
2. **Private Nodes**: Use private nodes for better security
3. **Workload Identity**: Enable for secure pod-to-GCP-service authentication
4. **Network Policies**: Enable for pod-to-pod traffic control
5. **Node Image**: Use COS (Container-Optimized OS) for security updates

## Cost Optimization

1. **Spot Instances**: Use for fault-tolerant workloads
2. **Autoscaling**: Configure appropriate min/max node counts
3. **Right-sizing**: Choose appropriate machine types
4. **Preemptible Nodes**: Alternative to spot instances for cost savings

## Monitoring and Logging

The cluster is configured with:
- Google Cloud Logging integration
- Google Cloud Monitoring integration
- Cluster and node metrics collection

## Troubleshooting

Common issues and solutions:

1. **API not enabled**: Enable required GCP APIs
2. **Quota exceeded**: Check GCP quotas for compute resources
3. **Network connectivity**: Verify firewall rules and network configuration
4. **Authentication**: Ensure proper GCP credentials are configured
