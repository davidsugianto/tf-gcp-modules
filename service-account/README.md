# Google Cloud Service Account Terraform Module

A comprehensive Terraform module for creating and managing Google Cloud Platform service accounts with advanced features including IAM role management, key generation, Workload Identity integration, and custom role creation.

## Features

### Core Functionality
- **Service Account Creation**: Create multiple service accounts with custom naming
- **IAM Role Management**: Assign predefined and custom IAM roles
- **Cross-Project Access**: Grant permissions across multiple projects
- **Service Account Keys**: Generate and manage service account keys with rotation
- **Custom IAM Roles**: Create and assign custom IAM roles
- **API Management**: Automatically enable required APIs

### Advanced Features
- **Workload Identity**: Full integration with GKE Workload Identity
- **Service Account Impersonation**: Configure who can impersonate service accounts
- **Conditional IAM**: Support for IAM condition expressions
- **Key Rotation**: Automated key rotation with configurable schedules
- **Predefined Role Sets**: Common role combinations for typical use cases

### Security & Compliance
- **Least Privilege**: Fine-grained permission control
- **Key Management**: Secure key generation and storage
- **Audit Trail**: Comprehensive logging and monitoring integration
- **Compliance Ready**: Supports organizational security policies

## Quick Start

```hcl
module "service_accounts" {
  source = "./service-account"

  project_id = "my-gcp-project"

  service_accounts = {
    "app-backend" = {
      display_name = "Application Backend"
      description  = "Service account for backend services"
      roles = [
        "roles/cloudsql.client",
        "roles/storage.objectViewer"
      ]
    }
  }
}
```

## Usage Examples

### Basic Service Account
```hcl
module "basic_service_accounts" {
  source = "./service-account"

  project_id = var.project_id

  service_accounts = {
    "compute-worker" = {
      display_name = "Compute Worker"
      roles = [
        "roles/compute.instanceAdmin.v1",
        "roles/storage.objectViewer"
      ]
    }
  }
}
```

### Service Account with Key Generation
```hcl
module "service_accounts_with_keys" {
  source = "./service-account"

  project_id = var.project_id

  service_accounts = {
    "ci-cd" = {
      display_name = "CI/CD Pipeline"
      generate_key = true
      roles = [
        "roles/cloudbuild.builds.editor",
        "roles/storage.objectAdmin"
      ]
    }
  }
}

# Access the private key
output "ci_cd_key" {
  value     = module.service_accounts_with_keys.service_account_private_keys["ci-cd"]
  sensitive = true
}
```

### Workload Identity Setup
```hcl
module "workload_identity_sa" {
  source = "./service-account"

  project_id = var.project_id

  service_accounts = {
    "app-workload" = {
      display_name = "Application Workload"
      roles = [
        "roles/storage.objectViewer",
        "roles/monitoring.metricWriter"
      ]
      workload_identity_users = [
        "default/my-app",
        "production/my-app"
      ]
    }
  }
}

# Get kubectl commands for annotation
output "workload_identity_commands" {
  value = module.workload_identity_sa.workload_identity_config
}
```

### Custom Roles and Cross-Project Access
```hcl
module "advanced_service_accounts" {
  source = "./service-account"

  project_id = var.project_id

  # Define custom roles
  custom_roles = {
    "storage_viewer_limited" = {
      title = "Limited Storage Viewer"
      permissions = [
        "storage.objects.get",
        "storage.objects.list"
      ]
    }
  }

  service_accounts = {
    "multi-project-sa" = {
      display_name = "Multi-Project Service Account"
      custom_roles = ["storage_viewer_limited"]
      roles = ["roles/viewer"]
      project_roles = {
        "another-project-id" = "roles/storage.objectViewer"
      }
    }
  }
}
```

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The project ID where service accounts will be created | `string` | n/a | yes |
| service_accounts | Map of service accounts to create | `map(object)` | `{}` | no |
| custom_roles | Map of custom IAM roles to create | `map(object)` | `{}` | no |
| names_prefix | Prefix to add to service account names | `string` | `""` | no |
| names_suffix | Suffix to add to service account names | `string` | `""` | no |
| required_apis | List of APIs to enable | `list(string)` | `[...]` | no |
| iam_conditions | Map of IAM conditions for role assignments | `map(object)` | `{}` | no |

### Service Account Configuration

Each service account in the `service_accounts` map supports:

```hcl
service_accounts = {
  "service-name" = {
    # Basic configuration
    display_name = "Human readable name"
    description  = "Service account description"
    disabled     = false

    # IAM roles
    roles         = ["roles/storage.viewer"]
    custom_roles  = ["custom-role-id"]
    project_roles = {
      "other-project" = "roles/viewer"
    }

    # Key generation
    generate_key       = true
    key_algorithm      = "KEY_ALG_RSA_2048"
    private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
    key_rotation_date  = "2025-12-31"

    # Workload Identity
    workload_identity_users = [
      "namespace/service-account-name"
    ]

    # Impersonation
    impersonators = [
      "user:admin@example.com"
    ]
  }
}
```

## Module Outputs

| Name | Description |
|------|-------------|
| service_accounts | Complete service account information |
| service_account_emails | Map of service account emails |
| service_account_names | Map of service account resource names |
| service_account_keys | Service account keys (sensitive) |
| service_account_private_keys | Private keys (sensitive) |
| workload_identity_config | Workload Identity configuration |
| custom_roles | Created custom roles |
| summary | Summary of created resources |

## Examples

The module includes comprehensive examples in the `examples/` directory:

- **`basic/`**: Simple service accounts with standard roles
- **`with-keys/`**: Service accounts with generated keys
- **`workload-identity/`**: GKE Workload Identity integration
- **`custom-roles/`**: Custom IAM roles and advanced configurations

## Workload Identity Integration

For GKE clusters with Workload Identity enabled:

1. **Create service accounts** with `workload_identity_users`
2. **Apply module** to create bindings
3. **Annotate Kubernetes service accounts**:

```bash
# Get annotation commands from output
terraform output workload_identity_config

# Apply annotations
kubectl annotate serviceaccount my-app \
  iam.gke.io/gcp-service-account=my-sa@project.iam.gserviceaccount.com \
  --namespace=default
```

## Security Best Practices

### Service Account Keys
- **Avoid keys when possible** - Use Workload Identity for GKE
- **Rotate keys regularly** - Use `key_rotation_date` parameter
- **Store keys securely** - Never commit to version control
- **Use appropriate key types** - Choose based on use case

### IAM Permissions
- **Principle of least privilege** - Grant minimum necessary permissions
- **Use custom roles** - For fine-grained control
- **Regular audits** - Monitor service account usage
- **Cross-project access** - Document and monitor carefully

### Workload Identity
- **Prefer over keys** - More secure for GKE workloads
- **Namespace isolation** - Use appropriate Kubernetes namespaces
- **Monitor bindings** - Regular audit of identity mappings

## Common Use Cases

### CI/CD Pipeline
```hcl
service_accounts = {
  "ci-cd" = {
    display_name = "CI/CD Pipeline"
    generate_key = true
    roles = [
      "roles/cloudbuild.builds.editor",
      "roles/storage.objectAdmin",
      "roles/artifactregistry.writer"
    ]
  }
}
```

### Application with Database Access
```hcl
service_accounts = {
  "app-backend" = {
    display_name = "Application Backend"
    roles = [
      "roles/cloudsql.client",
      "roles/storage.objectViewer",
      "roles/secretmanager.secretAccessor"
    ]
    workload_identity_users = ["default/backend-app"]
  }
}
```

### Data Processing Pipeline
```hcl
service_accounts = {
  "data-processor" = {
    display_name = "Data Processing Pipeline"
    roles = [
      "roles/bigquery.dataEditor",
      "roles/bigquery.jobUser",
      "roles/storage.objectAdmin",
      "roles/dataflow.developer"
    ]
  }
}
```

### Monitoring and Logging
```hcl
service_accounts = {
  "monitoring" = {
    display_name = "Monitoring Agent"
    roles = [
      "roles/monitoring.metricWriter",
      "roles/logging.logWriter",
      "roles/cloudtrace.agent"
    ]
    workload_identity_users = ["monitoring/prometheus"]
  }
}
```

## Troubleshooting

### Common Issues

**Service Account Creation Fails**
```
Error: Error creating service account
```
- Ensure IAM API is enabled
- Check project permissions
- Verify project ID is correct

**Key Generation Fails**
```
Error: Error creating service account key
```
- Service account must exist first
- Check key creation permissions
- Verify key parameters are valid

**Workload Identity Not Working**
```
Error: pods cannot authenticate to GCP
```
- Ensure GKE cluster has Workload Identity enabled
- Check Kubernetes service account annotations
- Verify namespace and service account names

**Permission Denied Errors**
```
Error: Error setting IAM policy
```
- Check you have `roles/iam.serviceAccountAdmin`
- Verify `roles/iam.securityAdmin` for role assignments
- Ensure API permissions are sufficient

### Debugging Commands

```bash
# List service accounts
gcloud iam service-accounts list

# Describe service account
gcloud iam service-accounts describe SA_EMAIL

# Check IAM policy
gcloud projects get-iam-policy PROJECT_ID

# Test Workload Identity
kubectl run -it --rm debug \
  --image=gcr.io/google.com/cloudsdktool/cloud-sdk:slim \
  --restart=Never -- gcloud auth list
```

## Migration Guide

### From Individual Resources
If migrating from individual `google_service_account` resources:

1. Import existing service accounts
2. Update configuration to use this module
3. Apply changes incrementally

### Key Rotation
To rotate existing keys:

1. Update `key_rotation_date` in configuration
2. Apply Terraform changes
3. Update applications to use new keys
4. Old keys are automatically removed

## Contributing

1. Follow Terraform best practices
2. Add examples for new features
3. Update documentation
4. Test with multiple scenarios

## License

This module is licensed under the MIT License.
