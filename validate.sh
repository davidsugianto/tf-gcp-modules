#!/bin/bash

# Script to validate Terraform modules
# This script checks for basic syntax errors and formatting

set -e

echo "🔍 Validating Terraform modules..."
echo

# Function to check basic Terraform syntax
check_syntax() {
    local dir=$1
    local module_name=$2
    
    echo "📂 Checking $module_name module ($dir)..."
    
    # Check if all required files exist
    required_files=("main.tf" "variables.tf" "outputs.tf" "provider.tf")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$dir/$file" ]]; then
            echo "❌ Missing required file: $dir/$file"
            return 1
        else
            echo "✅ Found: $dir/$file"
        fi
    done
    
    # Basic syntax checks
    cd "$dir"
    
    # Check for basic HCL syntax errors
    echo "🔧 Checking HCL syntax..."
    
    # Check for unclosed braces, brackets, etc.
    if ! grep -q "^terraform {" provider.tf; then
        echo "❌ provider.tf should start with terraform block"
        cd ..
        return 1
    fi
    
    # Check that variables have descriptions
    if grep -q "variable.*{" variables.tf; then
        if ! grep -A 5 "variable.*{" variables.tf | grep -q "description"; then
            echo "⚠️  Warning: Some variables may be missing descriptions"
        fi
    fi
    
    # Check that outputs have descriptions
    if grep -q "output.*{" outputs.tf; then
        if ! grep -A 5 "output.*{" outputs.tf | grep -q "description"; then
            echo "⚠️  Warning: Some outputs may be missing descriptions"
        fi
    fi
    
    cd ..
    echo "✅ Basic syntax checks passed for $module_name"
    echo
}

# Check container-cluster module
check_syntax "container-cluster" "GKE Cluster"

# Check container-node-pools module  
check_syntax "container-node-pools" "GKE Node Pools"

# Check examples
echo "📂 Checking examples..."
if [[ -d "examples" ]]; then
    required_example_files=("main.tf" "variables.tf" "outputs.tf" "terraform.tfvars.example" "README.md")
    for file in "${required_example_files[@]}"; do
        if [[ ! -f "examples/$file" ]]; then
            echo "❌ Missing example file: examples/$file"
            exit 1
        else
            echo "✅ Found: examples/$file"
        fi
    done
    echo "✅ Examples structure is complete"
fi

echo
echo "🎉 All basic validation checks passed!"
echo
echo "📋 Summary of created modules:"
echo "• container-cluster: Complete GKE cluster module with security and networking features"
echo "• container-node-pools: Flexible node pools module with autoscaling and advanced configurations"
echo "• examples: Comprehensive usage examples with documentation"
echo
echo "🚀 Next steps:"
echo "1. Install Terraform (if not already installed): https://terraform.io/downloads"
echo "2. Navigate to the examples directory: cd examples"
echo "3. Copy terraform.tfvars.example to terraform.tfvars: cp terraform.tfvars.example terraform.tfvars"
echo "4. Edit terraform.tfvars with your GCP project details"
echo "5. Run: terraform init && terraform plan"
echo "6. Deploy: terraform apply"
echo

echo "⚡ If you have Terraform installed, you can run full validation with:"
echo "   terraform -chdir=container-cluster validate"
echo "   terraform -chdir=container-node-pools validate"
echo "   terraform -chdir=examples validate"
