# Compute Network Module Examples

This directory contains comprehensive examples demonstrating how to use the compute-network module in various scenarios.

## Available Examples

### 1. Basic Network (`basic-network.tf`)

A simple VPC setup with three-tier architecture including web, application, and database subnets.

**Features:**
- Single VPC with custom subnets
- Basic firewall rules (internal, SSH, HTTP/HTTPS)
- Default internet gateway route
- Suitable for simple applications

**Usage:**
```bash
cd examples/
terraform init
terraform plan -var="project_id=your-project-id" -var="region=us-central1"
terraform apply -var="project_id=your-project-id" -var="region=us-central1"
```

### 2. GKE-Optimized Network (`gke-network.tf`)

A VPC specifically designed for Google Kubernetes Engine with secondary IP ranges, Cloud NAT, and security policies.

**Features:**
- VPC with secondary IP ranges for GKE pods and services
- Cloud NAT for private node internet access
- Comprehensive firewall rules for GKE security
- Flow logs enabled for monitoring
- Bastion host subnet for management

**Key Components:**
- Primary subnet: `10.0.0.0/20` (GKE nodes)
- Pods range: `10.4.0.0/14` (GKE pods)
- Services range: `10.0.16.0/20` (GKE services)
- Management subnet: `10.0.32.0/24` (Bastion hosts)

**Usage:**
```bash
cd examples/
terraform init
terraform plan -var="project_id=your-gke-project-id" -var="region=us-central1"
terraform apply -var="project_id=your-gke-project-id" -var="region=us-central1"
```

### 3. Shared VPC (`shared-vpc.tf`)

Enterprise-grade Shared VPC setup with multiple service projects, environment isolation, and centralized network management.

**Features:**
- Shared VPC host project configuration
- Multiple subnets for different environments (prod, dev, staging)
- Service project attachments
- Environment isolation through firewall rules
- Cloud NAT with reserved static IPs
- Private Service Connect for Google APIs
- IAM bindings for service projects

**Architecture:**
- Production subnets: Web (`10.10.1.0/24`), App (`10.10.2.0/24`), DB (`10.10.3.0/24`)
- Development subnet: `10.10.10.0/24`
- Staging subnet: `10.10.20.0/24`
- GKE subnet: `10.10.100.0/24` with secondary ranges

**Usage:**
```bash
cd examples/
terraform init
terraform plan \
  -var="host_project_id=your-host-project-id" \
  -var="service_project_ids=[\"service-project-1\", \"service-project-2\"]" \
  -var="region=us-central1"
terraform apply \
  -var="host_project_id=your-host-project-id" \
  -var="service_project_ids=[\"service-project-1\", \"service-project-2\"]" \
  -var="region=us-central1"
```

## Common Variables

All examples support these common variables:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_id` | GCP Project ID | - | Yes |
| `region` | GCP Region | `us-central1` | No |

## Additional Variables by Example

### Shared VPC Example
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `host_project_id` | Host project for Shared VPC | - | Yes |
| `service_project_ids` | List of service project IDs | `[]` | No |

## Prerequisites

1. **GCP Project**: Ensure you have appropriate GCP projects with billing enabled
2. **APIs**: The following APIs will be automatically enabled:
   - Compute Engine API
   - Service Networking API
   - Container API (for GKE examples)
   - DNS API

3. **Permissions**: Your account or service account needs:
   - `compute.networkAdmin`
   - `compute.securityAdmin` 
   - `iam.serviceAccountAdmin` (for Shared VPC)

## Best Practices Demonstrated

### Security
- **Least privilege firewall rules**: Only necessary ports and protocols are allowed
- **Network segmentation**: Different tiers/environments are isolated
- **Private subnets**: Database and application tiers use private IP ranges
- **Flow logs**: Critical subnets have flow logging enabled

### Scalability
- **Secondary IP ranges**: Properly sized for future growth in GKE examples
- **Modular design**: Resources can be easily extended or modified
- **Regional deployment**: Resources are deployed regionally for high availability

### Operations
- **Comprehensive labeling**: All resources are properly labeled for management
- **Cloud NAT**: Private resources can access internet through managed NAT
- **Monitoring ready**: Flow logs and proper naming for observability

## Customization

Each example can be customized by:

1. **Modifying IP ranges**: Update CIDR blocks to match your network design
2. **Adding subnets**: Include additional subnets for specific workloads  
3. **Firewall rules**: Adjust rules based on your security requirements
4. **Regions**: Deploy across multiple regions by duplicating subnet configurations
5. **Labels**: Add organization-specific labels for cost allocation and management

## Troubleshooting

### Common Issues

1. **Insufficient permissions**: Ensure your account has the required IAM roles
2. **API not enabled**: The module will enable required APIs, but ensure billing is enabled
3. **IP range conflicts**: Check that your chosen CIDR blocks don't conflict with existing networks
4. **Quota limits**: Verify you have sufficient quota for the number of networks and firewall rules

### Cleanup

To destroy the resources:

```bash
terraform destroy -var="project_id=your-project-id" -auto-approve
```

For Shared VPC:
```bash
terraform destroy \
  -var="host_project_id=your-host-project-id" \
  -var="service_project_ids=[\"service-project-1\", \"service-project-2\"]" \
  -auto-approve
```

## Next Steps

After deploying these examples:

1. **Deploy applications**: Use the created subnets for your application workloads
2. **Set up monitoring**: Configure Cloud Monitoring for network metrics
3. **Implement DNS**: Set up Cloud DNS for internal name resolution
4. **Add VPN/Interconnect**: Connect to on-premises networks if needed
5. **Security scanning**: Use Cloud Security Scanner to validate firewall rules

For more complex scenarios, consider combining multiple examples or extending them with additional GCP networking services like Cloud Load Balancing, Cloud CDN, or Network Intelligence Center.
