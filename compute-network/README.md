# Compute Network Module

A comprehensive Terraform module for creating and managing Google Cloud Platform (GCP) network infrastructure including VPCs, subnets, routes, firewall rules, and advanced networking features.

## Architecture

This module is organized into sub-modules for better maintainability and reusability:

```
compute-network/
├── main.tf                 # Main orchestrator module
├── variables.tf           # Input variables
├── outputs.tf            # Output values
├── provider.tf           # Provider requirements
├── README.md             # This file
├── vpc/                  # VPC sub-module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── subnets/             # Subnets sub-module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── routes/              # Custom routes sub-module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── firewall-rules/      # Firewall rules sub-module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
└── examples/           # Usage examples
    ├── README.md
    ├── basic-network.tf
    ├── gke-network.tf
    └── shared-vpc.tf
```

## Features

### Core Networking
- **VPC Networks**: Create and manage VPC networks with custom configurations
- **Subnets**: Create subnets with secondary IP ranges for GKE
- **Custom Routes**: Define custom routing rules for traffic flow
- **Firewall Rules**: Comprehensive firewall rule management

### Advanced Features
- **Shared VPC**: Host and service project configuration
- **Cloud NAT**: Managed NAT gateway for private subnets
- **Network Peering**: VPC-to-VPC connectivity
- **Private Service Connect**: Private connectivity to Google services
- **VPC Flow Logs**: Network traffic monitoring and analysis
- **Cloud Armor**: Web application firewall and DDoS protection

### Operational Features
- **API Management**: Automatic enablement of required GCP APIs
- **IAM Integration**: Subnet-level IAM bindings for Shared VPC
- **Labeling**: Consistent resource labeling for management
- **Lifecycle Management**: Proper resource dependencies and lifecycle rules

## Usage

### Basic Usage

```hcl
module "network" {
  source = "path/to/compute-network"

  project_id = "your-project-id"

  # VPC Configuration
  vpcs = {
    "main-vpc" = {
      description             = "Main application VPC"
      auto_create_subnetworks = false
      routing_mode           = "REGIONAL"
    }
  }

  # Subnet Configuration
  subnets = {
    "web-subnet" = {
      network                   = "projects/your-project-id/global/networks/main-vpc"
      ip_cidr_range            = "10.0.1.0/24"
      region                   = "us-central1"
      private_ip_google_access = true
    }
  }

  # Firewall Rules
  firewall_rules = {
    "allow-ssh" = {
      network       = "projects/your-project-id/global/networks/main-vpc"
      direction     = "INGRESS"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["ssh"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
  }
}
```

### GKE-Optimized Network

```hcl
module "gke_network" {
  source = "path/to/compute-network"

  project_id = "your-gke-project"

  vpcs = {
    "gke-vpc" = {
      description      = "GKE cluster VPC"
      routing_mode    = "REGIONAL"
      enable_flow_logs = true
    }
  }

  subnets = {
    "gke-nodes" = {
      network                   = "projects/your-gke-project/global/networks/gke-vpc"
      ip_cidr_range            = "10.0.0.0/20"
      region                   = "us-central1"
      private_ip_google_access = true
      
      # Secondary ranges for GKE
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

  # Cloud NAT for private nodes
  cloud_nats = {
    "gke-nat" = {
      region  = "us-central1"
      network = "projects/your-gke-project/global/networks/gke-vpc"
    }
  }
}
```

### Shared VPC

```hcl
module "shared_vpc" {
  source = "path/to/compute-network"

  project_id = "host-project-id"
  shared_vpc_host_project = true

  vpcs = {
    "shared-vpc" = {
      description      = "Organization shared VPC"
      routing_mode    = "GLOBAL"
      enable_flow_logs = true
    }
  }

  # Multiple environment subnets
  subnets = {
    "prod-subnet" = {
      network                   = "projects/host-project-id/global/networks/shared-vpc"
      ip_cidr_range            = "10.0.1.0/24"
      region                   = "us-central1"
      private_ip_google_access = true
    },
    "dev-subnet" = {
      network                   = "projects/host-project-id/global/networks/shared-vpc"
      ip_cidr_range            = "10.0.10.0/24" 
      region                   = "us-central1"
      private_ip_google_access = true
    }
  }

  # Environment isolation firewall rules
  firewall_rules = {
    "deny-cross-env" = {
      network         = "projects/host-project-id/global/networks/shared-vpc"
      direction       = "INGRESS"
      priority        = 900
      source_ranges   = ["10.0.10.0/24"]  # Dev
      destination_ranges = ["10.0.1.0/24"]   # Prod
      deny = [{
        protocol = "all"
        ports    = []
      }]
    }
  }
}
```

## Sub-modules

### VPC Sub-module (`./vpc`)

Manages VPC network creation and configuration.

**Key Features:**
- VPC network creation with custom settings
- Shared VPC host project enablement
- Default firewall rules (optional)
- Private service connection setup
- IPv6 support

**Key Outputs:**
- `vpcs`: Complete VPC configurations
- `vpc_names`: VPC names for reference
- `vpc_self_links`: VPC self-links for other resources

### Subnets Sub-module (`./subnets`)

Manages subnet creation with advanced features.

**Key Features:**
- Primary and secondary IP ranges
- VPC Flow Logs configuration
- Private Google Access
- Regional address reservations
- IAM bindings for Shared VPC

**Key Outputs:**
- `subnets`: Complete subnet configurations
- `secondary_ip_ranges`: Secondary IP range details
- `subnets_by_region`: Subnets grouped by region

### Routes Sub-module (`./routes`)

Manages custom routing configurations.

**Key Features:**
- Custom route creation
- Multiple next-hop types support
- Priority-based routing
- Tag-based route application

**Key Outputs:**
- `routes`: Complete route configurations
- `routes_by_network`: Routes grouped by network
- `default_routes`: Default route configurations

### Firewall Rules Sub-module (`./firewall-rules`)

Manages firewall rules and security policies.

**Key Features:**
- Allow/deny firewall rules
- Cloud Armor security policies
- Network endpoint groups
- Comprehensive logging
- Priority-based rule application

**Key Outputs:**
- `firewall_rules`: Complete firewall rule configurations
- `security_policies`: Cloud Armor policies
- `firewall_rules_by_network`: Rules grouped by network

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `project_id` | `string` | GCP project ID where resources will be created |

### VPC Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vpcs` | `map(object)` | `{}` | Map of VPC configurations |
| `shared_vpc_host_project` | `bool` | `false` | Enable Shared VPC host project |
| `enable_flow_logs` | `bool` | `false` | Enable VPC Flow Logs globally |

### Subnet Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `subnets` | `map(object)` | `{}` | Map of subnet configurations |

### Network Routing

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `routes` | `map(object)` | `{}` | Map of custom route configurations |

### Security

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `firewall_rules` | `map(object)` | `{}` | Map of firewall rule configurations |

### Advanced Networking

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `network_peerings` | `map(object)` | `{}` | Map of network peering configurations |
| `cloud_nats` | `map(object)` | `{}` | Map of Cloud NAT configurations |
| `private_service_connects` | `map(object)` | `{}` | Map of Private Service Connect configurations |

## Outputs

### Primary Outputs

| Output | Description |
|--------|-------------|
| `vpcs` | Complete VPC network information |
| `subnets` | Complete subnet information |
| `routes` | Complete route information |
| `firewall_rules` | Complete firewall rule information |

### Summary Outputs

| Output | Description |
|--------|-------------|
| `network_summary` | Summary of all created resources |
| `network_topology` | Network topology for visualization |
| `regional_resources` | Resources grouped by region |

## Examples

Comprehensive examples are available in the `examples/` directory:

1. **[Basic Network](./examples/basic-network.tf)**: Simple three-tier VPC setup
2. **[GKE Network](./examples/gke-network.tf)**: GKE-optimized network with secondary ranges
3. **[Shared VPC](./examples/shared-vpc.tf)**: Enterprise Shared VPC with multiple service projects

See [examples/README.md](./examples/README.md) for detailed usage instructions.

## Requirements

### Terraform Version
- Terraform >= 1.0

### Provider Requirements
- google >= 4.0

### GCP APIs
The following APIs will be automatically enabled:
- Compute Engine API (`compute.googleapis.com`)
- Service Networking API (`servicenetworking.googleapis.com`)
- Container API (`container.googleapis.com`)
- DNS API (`dns.googleapis.com`)

### IAM Permissions

Your service account needs the following roles:
- `roles/compute.networkAdmin`
- `roles/compute.securityAdmin`
- `roles/iam.serviceAccountAdmin` (for Shared VPC)
- `roles/serviceusage.serviceUsageAdmin` (for API enablement)

## Best Practices

### Network Design
1. **Use private subnets**: Enable `private_ip_google_access` for private subnets
2. **Plan IP ranges**: Avoid overlapping CIDR blocks across VPCs
3. **Secondary ranges**: Plan secondary IP ranges for GKE upfront
4. **Regional deployment**: Use regional routing mode for better performance

### Security
1. **Principle of least privilege**: Create specific firewall rules rather than broad allow-all rules
2. **Network segmentation**: Use separate subnets for different tiers/environments
3. **Flow logs**: Enable flow logs for critical subnets
4. **Regular audits**: Review firewall rules and routes regularly

### Operations
1. **Consistent labeling**: Use labels for cost allocation and resource management
2. **Monitoring**: Enable flow logs and set up monitoring dashboards
3. **Documentation**: Document network topology and IP allocations
4. **Change management**: Use Terraform for all network changes

## Common Patterns

### Three-Tier Architecture
```hcl
subnets = {
  "web-tier"    = { ip_cidr_range = "10.0.1.0/24", ... }
  "app-tier"    = { ip_cidr_range = "10.0.2.0/24", ... }
  "db-tier"     = { ip_cidr_range = "10.0.3.0/24", ... }
}
```

### Multi-Region Deployment
```hcl
subnets = {
  "web-us-central1"  = { region = "us-central1", ip_cidr_range = "10.0.1.0/24", ... }
  "web-us-west1"     = { region = "us-west1", ip_cidr_range = "10.1.1.0/24", ... }
  "web-europe-west1" = { region = "europe-west1", ip_cidr_range = "10.2.1.0/24", ... }
}
```

### Environment Isolation
```hcl
firewall_rules = {
  "deny-dev-to-prod" = {
    direction          = "INGRESS"
    source_ranges      = ["10.0.10.0/24"]  # Dev subnet
    destination_ranges = ["10.0.1.0/24"]   # Prod subnet
    deny = [{ protocol = "all", ports = [] }]
  }
}
```

## Migration Guide

### From Existing Networks

1. **Import existing resources**:
   ```bash
   terraform import module.network.module.vpc.google_compute_network.vpc[\"vpc-name\"] projects/PROJECT_ID/global/networks/VPC_NAME
   ```

2. **Update configuration** to match existing resources

3. **Plan and apply** to ensure no changes are detected

### From Other Modules

1. **Map variable names** from your existing module to this module's schema
2. **Update resource references** to use new output structure
3. **Test in staging** environment before applying to production

## Troubleshooting

### Common Issues

1. **API not enabled**: Ensure required APIs are enabled and billing is active
2. **Insufficient permissions**: Verify IAM roles are properly assigned
3. **IP range conflicts**: Check for overlapping CIDR blocks
4. **Quota limits**: Verify compute quotas for networks and firewall rules

### Debug Commands

```bash
# Validate Terraform configuration
terraform validate

# Plan with detailed output
terraform plan -out=network.plan

# Show planned changes
terraform show network.plan

# Apply with debug logging
TF_LOG=DEBUG terraform apply
```

### Logging and Monitoring

Enable detailed logging for troubleshooting:

```hcl
# Enable flow logs with full metadata
subnets = {
  "debug-subnet" = {
    enable_flow_logs = true
    flow_logs_config = {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling       = 1.0
      metadata           = "INCLUDE_ALL_METADATA"
    }
  }
}

# Enable firewall rule logging
firewall_rules = {
  "debug-rule" = {
    enable_logging      = true
    log_config_metadata = "INCLUDE_ALL_METADATA"
  }
}
```

## Contributing

When contributing to this module:

1. **Follow conventions**: Use the established naming and structure patterns
2. **Add tests**: Include example configurations for new features
3. **Update documentation**: Update this README and sub-module documentation
4. **Version compatibility**: Ensure backward compatibility or provide migration path

## Security Considerations

### Network Security
- **Default deny**: Implement default-deny firewall policies
- **Micro-segmentation**: Use granular firewall rules
- **Private subnets**: Keep sensitive workloads in private subnets
- **VPN/Interconnect**: Use secure connections for on-premises integration

### Access Control
- **Service accounts**: Use dedicated service accounts with minimal permissions
- **IAM bindings**: Apply subnet-level IAM for fine-grained access control
- **Audit logging**: Enable audit logs for network changes

### Compliance
- **Flow logs**: Enable for compliance and security monitoring
- **Data residency**: Consider regional deployment for data residency requirements
- **Encryption**: All traffic is encrypted in transit by default

## Cost Optimization

### Network Costs
- **Regional traffic**: Keep traffic within regions when possible
- **Private Google Access**: Reduce NAT costs by enabling private access
- **Flow logs sampling**: Use appropriate sampling rates to control costs
- **Reserved IPs**: Release unused reserved IP addresses

### Monitoring Costs
- **Flow logs**: Balance monitoring needs with storage costs
- **Log retention**: Set appropriate retention policies
- **Alerting**: Set up cost alerts for network usage

## License

This module is provided under the Apache 2.0 license. See LICENSE file for details.

## Support

For issues and questions:

1. **Check examples**: Review the examples directory for common patterns
2. **Documentation**: Check GCP networking documentation for resource-specific details
3. **Issues**: Report bugs or feature requests through your organization's channels

## Changelog

### Version History

- **v1.0.0**: Initial release with basic VPC, subnet, route, and firewall functionality
- **v1.1.0**: Added Shared VPC support
- **v1.2.0**: Added Cloud NAT and Private Service Connect
- **v1.3.0**: Added Cloud Armor security policies
- **v1.4.0**: Enhanced labeling and lifecycle management

For detailed changes, see the git commit history.
