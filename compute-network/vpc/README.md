# VPC Sub-module

This sub-module handles the creation and configuration of Google Cloud VPC networks with advanced features including Shared VPC, private service connections, and default security rules.

## Features

- **VPC Network Creation**: Custom VPC networks with configurable routing modes
- **IPv6 Support**: Enable IPv6 with ULA internal ranges
- **Shared VPC**: Host project configuration for enterprise setups
- **Private Service Connections**: Managed service connectivity
- **Default Security Rules**: Optional default firewall rules
- **Flow Logs Policy**: VPC-level flow logs configuration

## Resources Created

- `google_compute_network`: VPC networks
- `google_compute_shared_vpc_host_project`: Shared VPC host configuration (optional)
- `google_compute_network_firewall_policy`: Flow logs policies (optional)
- `google_compute_route`: Default internet gateway routes (optional)
- `google_compute_firewall`: Default security rules (optional)
- `google_compute_global_address`: Private service IP allocations (optional)
- `google_service_networking_connection`: Private service connections (optional)

## Usage

### Basic VPC

```hcl
module "vpc" {
  source = "./vpc"

  project_id = "your-project-id"

  vpcs = {
    "main-vpc" = {
      description             = "Main application VPC"
      auto_create_subnetworks = false
      routing_mode           = "REGIONAL"
      mtu                    = 1460
    }
  }
}
```

### Shared VPC Host

```hcl
module "shared_vpc" {
  source = "./vpc"

  project_id = "host-project-id"
  shared_vpc_host_project = true

  vpcs = {
    "shared-vpc" = {
      description      = "Organization shared VPC"
      routing_mode    = "GLOBAL"
      enable_flow_logs = true
    }
  }
}
```

### VPC with IPv6

```hcl
module "ipv6_vpc" {
  source = "./vpc"

  project_id = "your-project-id"

  vpcs = {
    "ipv6-vpc" = {
      description              = "IPv6 enabled VPC"
      enable_ula_internal_ipv6 = true
      internal_ipv6_range     = "fd20::/64"
    }
  }
}
```

### VPC with Private Service Connections

```hcl
module "vpc_with_psc" {
  source = "./vpc"

  project_id = "your-project-id"

  vpcs = {
    "psc-vpc" = {
      description = "VPC with private service connections"
    }
  }

  private_service_ranges = {
    "google-apis" = {
      vpc_name      = "psc-vpc"
      prefix_length = 24
      description   = "Range for Google APIs"
    }
  }
}
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `project_id` | `string` | GCP project ID where VPC networks will be created |

### VPC Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vpcs` | `map(object)` | `{}` | Map of VPC configurations |

#### VPC Object Schema

```hcl
{
  description                     = string  # VPC description
  auto_create_subnetworks        = bool     # Auto-create subnetworks
  routing_mode                   = string   # "REGIONAL" or "GLOBAL"
  mtu                            = number   # Maximum transmission unit
  enable_ula_internal_ipv6       = bool     # Enable IPv6
  internal_ipv6_range            = string   # IPv6 range
  network_firewall_policy_enforcement_order = string  # Policy order
  enable_flow_logs               = bool     # Enable flow logs
  delete_default_routes_on_create = bool    # Delete default routes
}
```

### Optional Features

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `shared_vpc_host_project` | `bool` | `false` | Enable Shared VPC host |
| `enable_flow_logs` | `bool` | `false` | Global flow logs setting |
| `enable_default_firewall_rules` | `bool` | `false` | Create default security rules |
| `ssh_source_ranges` | `list(string)` | `["0.0.0.0/0"]` | SSH access IP ranges |
| `icmp_source_ranges` | `list(string)` | `["0.0.0.0/0"]` | ICMP access IP ranges |

### Private Service Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `private_service_ranges` | `map(object)` | `{}` | Private service IP ranges |

#### Private Service Range Schema

```hcl
{
  vpc_name      = string  # VPC name to attach to
  prefix_length = number  # IP range prefix length
  description   = string  # Range description
}
```

### Naming and Labeling

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `names_prefix` | `string` | `""` | Prefix for resource names |
| `names_suffix` | `string` | `""` | Suffix for resource names |
| `labels` | `map(string)` | `{}` | Labels to apply to resources |

## Outputs

### Primary Outputs

| Output | Type | Description |
|--------|------|-------------|
| `vpcs` | `map(object)` | Complete VPC configurations |
| `vpc_names` | `map(string)` | VPC names by key |
| `vpc_self_links` | `map(string)` | VPC self-links |
| `vpc_ids` | `map(string)` | VPC IDs |

### Feature Outputs

| Output | Type | Description |
|--------|------|-------------|
| `shared_vpc_host` | `object` | Shared VPC host configuration |
| `default_routes` | `map(object)` | Default internet gateway routes |
| `flow_logs_policies` | `map(object)` | Flow logs policies |

## Best Practices

### VPC Design

1. **Disable auto-create subnetworks**: Always set `auto_create_subnetworks = false` for production
2. **Use regional routing**: Set `routing_mode = "REGIONAL"` unless global routing is required
3. **Plan MTU**: Use standard 1460 MTU unless jumbo frames are needed
4. **Delete default routes**: Consider `delete_default_routes_on_create = true` for security

### Shared VPC

1. **Host project**: Use dedicated project for Shared VPC host
2. **Service accounts**: Plan service account permissions carefully
3. **Cross-project access**: Configure IAM bindings for service projects
4. **Monitoring**: Enable flow logs for centralized monitoring

### Security

1. **Default rules**: Only enable default firewall rules in development
2. **Private ranges**: Use RFC 1918 private IP ranges
3. **Flow logs**: Enable for security monitoring and compliance
4. **Network policies**: Use hierarchical firewall policies for enterprise

### IPv6

1. **ULA ranges**: Use Unique Local Address ranges for internal IPv6
2. **Dual stack**: Plan for both IPv4 and IPv6 connectivity
3. **Google access**: Configure private IPv6 Google access

## Examples

### Minimal VPC

```hcl
vpcs = {
  "simple-vpc" = {
    description = "Simple VPC for testing"
  }
}
```

### Production VPC

```hcl
vpcs = {
  "prod-vpc" = {
    description                     = "Production VPC"
    auto_create_subnetworks        = false
    routing_mode                   = "REGIONAL"
    mtu                            = 1460
    enable_flow_logs               = true
    delete_default_routes_on_create = true
    network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"
  }
}
```

### IPv6 VPC

```hcl
vpcs = {
  "ipv6-vpc" = {
    description              = "IPv6 enabled VPC"
    enable_ula_internal_ipv6 = true
    internal_ipv6_range     = "fd20::/64"
    routing_mode            = "GLOBAL"
  }
}
```

## Integration

This sub-module is designed to work with:

- **Subnets sub-module**: Subnet creation in VPCs
- **Routes sub-module**: Custom routing configuration
- **Firewall Rules sub-module**: Security rule management
- **Container clusters**: GKE cluster networking
- **Load balancers**: External and internal load balancing

## Troubleshooting

### Common Issues

1. **VPC already exists**: Use `terraform import` to import existing VPCs
2. **Shared VPC conflicts**: Ensure project has necessary permissions
3. **IPv6 not available**: Check region support for IPv6
4. **Default route conflicts**: Set `delete_default_routes_on_create = true`

### Validation

```bash
# Validate VPC configuration
gcloud compute networks describe VPC_NAME --project=PROJECT_ID

# Check Shared VPC status
gcloud compute shared-vpc get-host-project PROJECT_ID

# List private service connections
gcloud services vpc-peerings list --network=VPC_NAME
```

## Dependencies

This sub-module requires:
- GCP Compute Engine API
- Appropriate IAM permissions
- Billing enabled on the project

The sub-module automatically manages dependencies between resources to ensure proper creation order.
