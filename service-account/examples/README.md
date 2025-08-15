# Service Account Module Examples

This directory contains various examples demonstrating different use cases for the service account module.

## Examples Overview

### 1. Basic Service Accounts (`basic/`)
- **Purpose**: Simple service accounts with standard IAM roles
- **Features**:
  - Basic service account creation
  - Standard predefined IAM roles
  - Service account naming with prefix/suffix
  - API enablement
- **Use Cases**: General-purpose service accounts for common GCP services

### 2. Service Accounts with Keys (`with-keys/`)
- **Purpose**: Service accounts with generated keys for external applications
- **Features**:
  - Service account key generation
  - Key rotation configuration
  - Different key algorithms and types
  - Secure key handling
- **Use Cases**: CI/CD pipelines, external applications, automated systems

### 3. Workload Identity (`workload-identity/`)
- **Purpose**: Service accounts configured for GKE Workload Identity
- **Features**:
  - Workload Identity bindings
  - Kubernetes service account mapping
  - kubectl annotation commands
  - Multi-namespace support
- **Use Cases**: GKE applications, microservices, Kubernetes workloads

### 4. Custom Roles (`custom-roles/`)
- **Purpose**: Service accounts with custom IAM roles and advanced configurations
- **Features**:
  - Custom IAM role creation
  - Cross-project access
  - Service account impersonation
  - Complex permission management
- **Use Cases**: Fine-grained access control, multi-project deployments

## Usage Instructions

### Running an Example

1. **Choose an example directory:**
   ```bash
   cd basic/  # or with-keys/, workload-identity/, custom-roles/
   ```

2. **Set up variables:**
   ```bash
   # Create terraform.tfvars
   echo 'project_id = "your-gcp-project-id"' > terraform.tfvars
   ```

3. **Initialize and deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Clean up:**
   ```bash
   terraform destroy
   ```

### Example-Specific Instructions

#### Basic Example
```bash
cd basic/
echo 'project_id = "your-project-id"' > terraform.tfvars
terraform init && terraform apply
```

#### With Keys Example
```bash
cd with-keys/
cat > terraform.tfvars << EOF
project_id = "your-project-id"
key_rotation_date = "2025-12-31"
EOF
terraform init && terraform apply

# Extract private keys (sensitive operation)
terraform output -json service_account_private_keys
```

#### Workload Identity Example
```bash
cd workload-identity/
echo 'project_id = "your-project-id"' > terraform.tfvars
terraform init && terraform apply

# Get kubectl annotation commands
terraform output kubectl_annotation_commands
```

#### Custom Roles Example
```bash
cd custom-roles/
cat > terraform.tfvars << EOF
project_id = "your-project-id"
additional_project_roles = {
  "another-project" = "roles/viewer"
}
impersonators = [
  "user:admin@example.com"
]
EOF
terraform init && terraform apply
```

## Security Considerations

### Service Account Keys
- **Avoid** generating keys unless absolutely necessary
- Use **Workload Identity** for GKE workloads instead of keys
- **Rotate keys** regularly using the key_rotation_date parameter
- Store keys securely and never commit them to version control

### IAM Best Practices
- Follow the **principle of least privilege**
- Use **custom roles** for fine-grained permissions
- Regular **audit** service account permissions
- Use **impersonation** instead of sharing keys

### Cross-Project Access
- Only grant cross-project access when necessary
- Document cross-project dependencies
- Monitor cross-project usage

## Integration Examples

### With GKE Module
```hcl
module "gke_cluster" {
  source = "../../container-cluster"
  # ... cluster configuration
}

module "service_accounts" {
  source = "../"
  
  service_accounts = {
    "app-sa" = {
      roles = ["roles/storage.objectViewer"]
      workload_identity_users = [
        "default/my-app"
      ]
    }
  }
}
```

### With Cloud Build
```hcl
module "service_accounts" {
  source = "../"
  
  service_accounts = {
    "cloudbuild-sa" = {
      generate_key = true
      roles = [
        "roles/cloudbuild.builds.editor",
        "roles/storage.admin"
      ]
    }
  }
}

# Use in Cloud Build
# steps:
# - name: 'gcr.io/cloud-builders/terraform'
#   env:
#   - 'GOOGLE_APPLICATION_CREDENTIALS=/workspace/sa-key.json'
```

### With Secret Manager
```hcl
# Store service account key in Secret Manager
resource "google_secret_manager_secret" "sa_key" {
  secret_id = "service-account-key"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sa_key" {
  secret = google_secret_manager_secret.sa_key.id
  secret_data = module.service_accounts.service_account_private_keys["my-sa"]
}
```

## Troubleshooting

### Common Issues

1. **API Not Enabled**
   ```
   Error: Error creating service account: googleapi: Error 403
   ```
   **Solution**: Enable the IAM API in your project

2. **Insufficient Permissions**
   ```
   Error: Error setting IAM policy for service account
   ```
   **Solution**: Ensure you have `roles/iam.serviceAccountAdmin` and `roles/iam.securityAdmin`

3. **Workload Identity Not Working**
   ```
   Error: pods cannot authenticate to GCP
   ```
   **Solution**: Check GKE cluster has Workload Identity enabled and annotations are correct

4. **Key Generation Fails**
   ```
   Error: Error creating service account key
   ```
   **Solution**: Verify service account exists and you have key creation permissions

### Debugging Commands

```bash
# Check service account exists
gcloud iam service-accounts describe sa-name@project.iam.gserviceaccount.com

# List IAM roles
gcloud projects get-iam-policy your-project-id

# Test Workload Identity
kubectl run -it --rm debug --image=gcr.io/google.com/cloudsdktool/cloud-sdk:slim --restart=Never -- gcloud auth list

# Validate custom role permissions
gcloud iam roles describe projects/your-project/roles/custom-role-id
```

## Best Practices Summary

1. **Use Workload Identity** instead of service account keys for GKE
2. **Implement least privilege** access patterns
3. **Regularly rotate** service account keys
4. **Monitor and audit** service account usage
5. **Document** service account purposes and permissions
6. **Use naming conventions** for easy identification
7. **Implement proper** key management practices
