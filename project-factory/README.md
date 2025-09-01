# Project Factory Module

A comprehensive Terraform module for creating and managing Google Cloud Platform (GCP) projects at scale with enterprise-grade features including IAM management, budget controls, service enablement, and organizational policies.

## Features

### 🏗️ Core Project Management
- **Project Creation**: Automated project creation with configurable settings
- **Random Project ID Suffix**: Optional random suffix generation for unique project IDs
- **Folder Organization**: Organize projects within organizational folders
- **Project Liens**: Prevent accidental project deletion
- **Metadata Management**: Automatic project metadata and labeling

### 🔐 Identity & Access Management
- **IAM Bindings**: Comprehensive project-level IAM management
- **Service Accounts**: Automated service account creation and role assignment
- **Custom Roles**: Create and manage custom IAM roles
- **Default Service Account Management**: Control default service account behavior

### 🔧 Service Management
- **API Enablement**: Automated enabling of Google Cloud APIs
- **Service Configuration**: Advanced service-specific configurations
- **Quota Management**: Service usage quota overrides
- **Service Dependencies**: Proper service dependency management

### 💰 Cost Management
- **Budget Creation**: Automated budget setup with configurable thresholds
- **Budget Alerts**: Multi-threshold alerting system
- **Cost Attribution**: Proper labeling for cost tracking
- **Usage Export**: Project usage export configuration

### 🛡️ Security & Compliance
- **Organization Policies**: Apply and manage organization policies
- **Audit Logging**: Comprehensive audit log configuration
- **Access Approval**: Enterprise access approval settings
- **Essential Contacts**: Configure essential contact notifications

### 🏢 Enterprise Features
- **Shared VPC Integration**: Service project attachment to Shared VPC
- **Multi-Environment Support**: Standardized multi-environment project setup
- **Organizational Structure**: Folder-based project organization
- **Batch Operations**: Create multiple projects efficiently

## Architecture

This module is organized into specialized sub-modules:

```
project-factory/
├── main.tf              # Main orchestrator
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── provider.tf         # Provider requirements
├── README.md           # This documentation
├── project/            # Project creation sub-module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── services/           # API/service management sub-module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── iam/               # IAM management sub-module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── budget/            # Budget management sub-module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
└── examples/          # Usage examples
    ├── basic-project.tf
    ├── multi-environment.tf
    └── organization-setup.tf
```

## Quick Start

### Basic Project Creation

```hcl
module "basic_project" {
  source = "path/to/project-factory"

  billing_account = "ABCDEF-012345-6789AB"
  organization_id = "123456789012"

  projects = {
    "my-app-project" = {
      project_id   = "my-app-dev"
      project_name = "My Application Development"
      
      services = [
        "compute.googleapis.com",
        "storage.googleapis.com",
        "monitoring.googleapis.com"
      ]
      
      iam_bindings = {
        "developers" = {
          role = "roles/editor"
          members = ["group:developers@example.com"]
        }
      }
      
      labels = {
        environment = "development"
        team       = "platform"
      }
    }
  }
}
```

### Multi-Environment Setup

```hcl
module "multi_env" {
  source = "path/to/project-factory"

  billing_account = "ABCDEF-012345-6789AB"
  organization_id = "123456789012"

  projects = {
    "myapp-dev" = {
      project_id          = "myapp-dev"
      auto_generate_suffix = true
      folder_id           = "folders/development"
      
      budget = {
        amount = {
          specified_amount = {
            units = "500"
          }
        }
      }
      
      labels = { environment = "development" }
    }
    
    "myapp-prod" = {
      project_id = "myapp-production"
      folder_id  = "folders/production"
      lien      = true  # Prevent deletion
      
      budget = {
        amount = {
          specified_amount = {
            units = "5000"
          }
        }
      }
      
      labels = { environment = "production" }
    }
  }

  # Organization policies
  project_organization_policies = {
    "disable-external-ip-prod" = {
      project_name = "myapp-prod"
      constraint   = "compute.vmExternalIpAccess"
      list_policy = {
        deny = { all = true }
      }
    }
  }
}
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `billing_account` | `string` | Billing account ID to associate with projects |

### Project Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `projects` | `map(object)` | `{}` | Map of project configurations |
| `organization_id` | `string` | `null` | Organization ID for project creation |
| `default_folder_id` | `string` | `null` | Default folder ID for projects |

### Service Management

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `default_services` | `list(string)` | See variables.tf | Default services to enable |
| `disable_services_on_destroy` | `bool` | `false` | Disable services on destroy |
| `enable_apis_on_boot` | `bool` | `true` | Enable APIs immediately |

### IAM Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `default_service_account_action` | `string` | `"keep"` | Action for default service account |
| `create_service_accounts` | `bool` | `true` | Create defined service accounts |

### Budget Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `currency_code` | `string` | `"USD"` | Currency for budgets |
| `default_budget_amount` | `object` | `1000 USD` | Default budget amount |

## Outputs

### Primary Outputs

| Output | Description |
|--------|-------------|
| `projects` | Complete project information |
| `project_ids` | Map of project names to IDs |
| `project_numbers` | Map of project names to numbers |
| `enabled_services` | Services enabled per project |
| `service_accounts` | Created service accounts |
| `budgets` | Budget configurations |

### Summary Outputs

| Output | Description |
|--------|-------------|
| `project_summary` | Summary of each project |
| `billing_summary` | Billing and cost overview |
| `security_summary` | Security configuration overview |
| `operational_info` | Operational metadata |

## Examples

### 1. Basic Project (`examples/basic-project.tf`)
Simple project creation with essential services and IAM.

**Features:**
- Single project with common services
- Basic IAM configuration
- Budget setup with alerts
- Service account creation

**Usage:**
```bash
cd examples/
terraform init
terraform apply \
  -var="billing_account=YOUR-BILLING-ACCOUNT" \
  -var="organization_id=YOUR-ORG-ID"
```

### 2. Multi-Environment (`examples/multi-environment.tf`)
Enterprise setup with development, staging, and production projects.

**Features:**
- Three-environment project structure
- Environment-specific configurations
- Organization policies
- Custom roles and service accounts
- Progressive security controls

### 3. Organization Setup (`examples/organization-setup.tf`)
Large-scale organizational project factory.

**Features:**
- Folder-based organization
- Shared VPC integration
- Enterprise security policies
- Cost center attribution
- Compliance configurations

## Project Configuration Schema

Each project in the `projects` map supports the following configuration:

```hcl
{
  # Basic Settings
  project_id              = string           # Required
  project_name           = optional(string)
  folder_id              = optional(string)
  auto_generate_suffix   = optional(bool)
  auto_create_network    = optional(bool)
  lien                  = optional(bool)
  
  # Services
  services = optional(list(string))
  
  # IAM Configuration
  iam_bindings = optional(map(object({
    role    = string
    members = list(string)
  })))
  
  service_accounts = optional(map(object({
    display_name = optional(string)
    description  = optional(string)
    roles       = optional(list(string))
  })))
  
  custom_roles = optional(map(object({
    title       = string
    description = string
    permissions = list(string)
  })))
  
  # Budget Configuration
  budget = optional(object({
    amount = object({
      specified_amount = object({
        units = string
        nanos = optional(number)
      })
    })
    threshold_rules = optional(list(object({
      threshold_percent = number
      spend_basis      = optional(string)
    })))
  }))
  
  # Labels
  labels = optional(map(string))
}
```

## Best Practices

### Project Organization
1. **Use consistent naming**: Follow org naming conventions
2. **Environment separation**: Use separate projects for dev/staging/prod
3. **Folder structure**: Organize projects in logical folders
4. **Random suffixes**: Use for non-production environments

### Security
1. **Principle of least privilege**: Grant minimal necessary permissions
2. **Custom roles**: Create specific roles instead of predefined broad roles
3. **Service account keys**: Avoid creating and downloading SA keys
4. **Organization policies**: Implement security guardrails

### Cost Management
1. **Budget alerts**: Set up multiple threshold alerts
2. **Resource labeling**: Consistent labeling for cost attribution
3. **Usage monitoring**: Enable usage export for analysis
4. **Regular reviews**: Monitor and adjust budgets regularly

### Operational Excellence
1. **Infrastructure as Code**: Manage all changes through Terraform
2. **Documentation**: Document project purpose and configurations
3. **Monitoring**: Set up proper monitoring and alerting
4. **Backup strategies**: Implement appropriate backup/restore procedures

## Requirements

### Terraform Version
- Terraform >= 1.0

### Provider Requirements
- google >= 4.0
- google-beta >= 4.0
- random >= 3.0
- time >= 0.7

### GCP APIs
The module automatically enables required APIs:
- Cloud Resource Manager API
- Cloud Billing API
- Identity and Access Management (IAM) API
- Service Usage API

### Permissions

Your service account needs these roles:
- `roles/resourcemanager.projectCreator`
- `roles/billing.projectManager`
- `roles/iam.serviceAccountAdmin`
- `roles/serviceusage.serviceUsageAdmin`
- `roles/orgpolicy.policyAdmin` (for org policies)

## Migration and Import

### Importing Existing Projects

```bash
# Import existing project
terraform import module.project_factory.module.projects.google_project.projects[\"project-name\"] your-project-id

# Import project IAM bindings
terraform import module.project_factory.module.iam.google_project_iam_member.bindings[\"project-name-role\"] "your-project-id roles/viewer user:user@example.com"
```

### Migration from Other Solutions

1. **Inventory existing projects**: Document current configurations
2. **Map to module schema**: Convert existing configs to module format  
3. **Import resources**: Use terraform import for existing resources
4. **Validate configuration**: Ensure no unintended changes
5. **Apply incrementally**: Deploy changes in stages

## Advanced Configuration

### Shared VPC Integration

```hcl
module "project_factory" {
  source = "path/to/project-factory"
  
  # Shared VPC configuration
  shared_vpc_host_project = "shared-vpc-host-project"
  
  shared_vpc_service_projects = {
    "my-service-project" = {
      host_project = "shared-vpc-host-project"
    }
  }
  
  projects = {
    "my-service-project" = {
      # Project configuration
    }
  }
}
```

### Custom Organization Policies

```hcl
# Folder-level policies
folder_organization_policies = {
  "restrict-external-ips" = {
    folder_name = "production"
    constraint  = "compute.vmExternalIpAccess"
    list_policy = {
      deny = { all = true }
    }
  }
}

# Project-level policies  
project_organization_policies = {
  "require-ssl-only" = {
    project_name = "web-app-prod"
    constraint   = "storage.uniformBucketLevelAccess"
    boolean_policy = {
      enforced = true
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Project ID conflicts**: Use auto_generate_suffix for uniqueness
2. **Billing permissions**: Ensure billing account access
3. **API quotas**: Check for API enablement limits
4. **Organization policies**: Verify policy inheritance

### Debug Commands

```bash
# Validate configuration
terraform validate

# Check planned changes
terraform plan -out=project.plan

# Apply with detailed logging
TF_LOG=DEBUG terraform apply
```

## Contributing

When contributing to this module:

1. **Follow patterns**: Use established code patterns
2. **Add examples**: Include usage examples for new features
3. **Update docs**: Keep documentation current
4. **Test thoroughly**: Validate in multiple scenarios

## Security Considerations

### Access Control
- Use service account impersonation instead of keys
- Apply principle of least privilege
- Regular access reviews and cleanup
- Monitor unusual access patterns

### Network Security
- Disable auto-create networks in production
- Use private Google access
- Implement VPC firewall rules
- Consider Shared VPC for network isolation

### Data Protection
- Enable audit logging
- Configure essential contacts
- Implement access approval for sensitive projects
- Use Cloud KMS for encryption key management

## License

This module is provided under the Apache 2.0 License. See LICENSE file for details.

## Support

For issues and questions:

1. **Check examples**: Review example configurations
2. **Documentation**: Consult GCP project documentation
3. **Issues**: Report bugs through your organization's support channels
