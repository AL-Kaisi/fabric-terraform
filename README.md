# Microsoft Fabric Terraform Setup

This repository contains Terraform configuration for deploying Microsoft Fabric infrastructure with Lakehouse and Spark capabilities for ETL workloads.

## Overview

This setup provisions:

- **Fabric Capacity**: Azure Fabric capacity with configurable SKU
- **Workspace**: Dedicated workspace for data engineering workloads
- **Lakehouse**: Data lakehouse for storing and processing data
- **Custom Spark Pool**: Optimized Spark pool with autoscaling
- **Spark Environment**: Environment for custom libraries and wheel files
- **Spark Settings**: Workspace-level Spark configurations

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 Azure Subscription                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │          Resource Group (fabric-{env}-rg)         │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │     Fabric Capacity (F2/F4/F8...)           │  │  │
│  │  └─────────────────┬───────────────────────────┘  │  │
│  └────────────────────┼──────────────────────────────┘  │
│                       │                                  │
│  ┌────────────────────┼──────────────────────────────┐  │
│  │     Microsoft Fabric (fabric-{env}-workspace)    │  │
│  │  ┌─────────────────┴────────────────┐             │  │
│  │  │          Workspace               │             │  │
│  │  │  ┌────────────┐  ┌─────────────┐ │             │  │
│  │  │  │ Lakehouse  │  │ Spark Pool  │ │             │  │
│  │  │  │  (Tables,  │  │ (Compute)   │ │             │  │
│  │  │  │   Files)   │  │             │ │             │  │
│  │  │  └────────────┘  └─────────────┘ │             │  │
│  │  │  ┌──────────────────────────────┐ │             │  │
│  │  │  │   Spark Environment          │ │             │  │
│  │  │  │   (Custom Wheels/Libraries)  │ │             │  │
│  │  │  └──────────────────────────────┘ │             │  │
│  │  └────────────────────────────────────┘             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Azure CLI**: Install from [Microsoft Docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform**: Install from [terraform.io](https://www.terraform.io/downloads)
3. **Azure Subscription**: With appropriate permissions to create Fabric capacities
4. **Fabric License**: Required for Microsoft Fabric
5. **jq**: JSON processor (required for capacity management script)
   - macOS: `brew install jq`
   - Linux: `sudo apt-get install jq` or `sudo yum install jq`

## Quick Start

### 1. Clone and Configure

```bash
cd fabric-terraform

# Edit the tfvars file for your environment
# Update subscription_id and fabric_admin_email
vi dev.tfvars  # or test.tfvars
```

### 2. Authenticate to Azure

```bash
./azure_login.sh
```

Follow the prompts to:
- Log in to Azure
- Select your subscription
- Verify your tenant and subscription details

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
# For development environment
terraform plan -var-file=dev.tfvars

# For test environment
terraform plan -var-file=test.tfvars
```

### 5. Deploy Infrastructure

```bash
# For development environment
terraform apply -var-file=dev.tfvars

# For test environment
terraform apply -var-file=test.tfvars
```

### 6. View Outputs

```bash
terraform output
```

## Configuration

### Environment Variables (dev.tfvars / test.tfvars)

Before deploying, update these critical values:

```hcl
# REQUIRED: Your Azure subscription ID
subscription_id = "YOUR_SUBSCRIPTION_ID_HERE"

# REQUIRED: Your email address (Fabric admin)
fabric_admin_email = "YOUR_EMAIL@example.com"

# REQUIRED: Environment name
environment = "dev"  # or "test"
```

### Capacity SKU Sizing

Choose the appropriate SKU based on your workload:

| SKU  | Capacity Units | Use Case                    | Monthly Cost (approx) |
|------|----------------|-----------------------------|-----------------------|
| F2   | 2              | Development, small workloads| $262                  |
| F4   | 4              | Testing, small production   | $524                  |
| F8   | 8              | Small production            | $1,048                |
| F16  | 16             | Production workloads        | $2,096                |
| F32+ | 32+            | Large production            | $4,192+               |

**Note**: Costs can be significantly reduced by suspending capacity when not in use.

### Spark Pool Configuration

Configure Spark pool settings in your tfvars file:

```hcl
# Node configuration
spark_pool_node_family = "MemoryOptimized"  # or "HardwareAccelerated"
spark_pool_node_size   = "Small"             # Small, Medium, Large, XLarge, XXLarge

# Autoscaling
spark_pool_autoscale_enabled   = true
spark_pool_autoscale_min_nodes = 1
spark_pool_autoscale_max_nodes = 3

# Dynamic executor allocation
spark_pool_dynamic_executor_enabled = true
spark_pool_dynamic_executor_min     = 1
spark_pool_dynamic_executor_max     = 2
```

## Managing Fabric Capacity Costs

Fabric capacity incurs costs 24/7 when running. Use the management script to pause capacity when not needed.

### Suspend (Pause) Capacity

```bash
# Stop capacity to save costs
./manage_capacity.sh stop fabric-dev-capacity

# Or with resource group specified
./manage_capacity.sh stop fabric-dev-capacity fabric-dev-rg
```

### Resume (Start) Capacity

```bash
# Start capacity when needed
./manage_capacity.sh start fabric-dev-capacity
```

### Check Capacity Status

```bash
# View current status
./manage_capacity.sh status fabric-dev-capacity

# List all capacities
./manage_capacity.sh list
```

### Automated Capacity Management

Consider these approaches for automated cost management:

1. **Azure Automation Runbook**: Schedule capacity start/stop times
2. **Azure Logic Apps**: Trigger capacity suspension based on inactivity
3. **CI/CD Integration**: Start capacity before deployment, stop after

Example cron job for automated capacity management:

```bash
# Suspend capacity at 6 PM on weekdays
0 18 * * 1-5 /path/to/manage_capacity.sh stop fabric-dev-capacity

# Resume capacity at 8 AM on weekdays
0 8 * * 1-5 /path/to/manage_capacity.sh start fabric-dev-capacity
```

## Uploading Spark Wheel Files

To deploy custom Python packages (wheels) for your Spark ETL jobs:

### Option 1: Using Fabric Portal (Recommended)

1. Navigate to your workspace in [Microsoft Fabric Portal](https://app.fabric.microsoft.com/)
2. Click on your Spark environment (e.g., `dev-spark-env`)
3. Go to **Settings** > **Libraries**
4. Click **Upload** and select your `.whl` file
5. Click **Publish** to make the library available

### Option 2: Using Fabric REST API

```bash
# Set variables
WORKSPACE_ID="your-workspace-id"
ENVIRONMENT_ID="your-environment-id"
WHEEL_FILE="path/to/your/package.whl"

# Upload wheel file
curl -X POST \
  "https://api.fabric.microsoft.com/v1/workspaces/$WORKSPACE_ID/environments/$ENVIRONMENT_ID/staging/libraries" \
  -H "Authorization: Bearer $(az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv)" \
  -F "file=@$WHEEL_FILE"

# Publish the environment
curl -X POST \
  "https://api.fabric.microsoft.com/v1/workspaces/$WORKSPACE_ID/environments/$ENVIRONMENT_ID/staging/publish" \
  -H "Authorization: Bearer $(az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv)"
```

### Option 3: Using Fabric CLI

```bash
# Install Fabric CLI
pip install fabriccli

# Upload and publish
fabric environment upload-library \
  --workspace-id $WORKSPACE_ID \
  --environment-id $ENVIRONMENT_ID \
  --file path/to/your/package.whl
```

### Building and Uploading Your ETL Wheel

Create a Python package structure:

```
my_etl_package/
├── setup.py
├── src/
│   └── my_etl/
│       ├── __init__.py
│       ├── extractors.py
│       ├── transformers.py
│       └── loaders.py
└── requirements.txt
```

Build and upload:

```bash
# Build the wheel
cd my_etl_package
python setup.py bdist_wheel

# Your wheel will be in dist/my_etl_package-0.1.0-py3-none-any.whl
# Upload using one of the methods above
```

## Lakehouse Architecture Setup

### Folder Structure Recommendation

Organize your lakehouse with a medallion architecture:

```
lakehouse/
├── Files/
│   ├── bronze/          # Raw data ingestion
│   │   ├── source1/
│   │   └── source2/
│   ├── silver/          # Cleansed and conformed data
│   │   ├── customers/
│   │   └── transactions/
│   └── gold/            # Business-level aggregates
│       ├── reports/
│       └── analytics/
└── Tables/
    ├── bronze_raw
    ├── silver_clean
    └── gold_aggregated
```

### Creating Lakehouse Tables from Spark

```python
# In your Spark notebook
from pyspark.sql import SparkSession

# Read from bronze
df = spark.read.parquet("Files/bronze/source1/data.parquet")

# Transform
df_transformed = df.filter(df.status == "active")

# Write to silver as Delta table
df_transformed.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("silver_clean")
```

## Workspace Architecture

### Single Workspace vs. Multiple Workspaces

**This setup uses a single workspace per environment** that contains:
- Lakehouse (data storage)
- Spark pools (compute)
- Notebooks (ETL code)
- Environments (libraries)

This is recommended because:
- Simplified management
- Shared compute resources
- Easier collaboration
- Unified governance

**When to use multiple workspaces:**
- Separate teams with different access requirements
- Different data domains (e.g., Finance workspace, Sales workspace)
- Isolation for compliance or security

To create additional workspaces, duplicate the workspace resource in `main.tf`:

```hcl
resource "fabric_workspace" "analytics_workspace" {
  display_name = "${var.environment}-analytics-workspace"
  description  = "Analytics workspace"
  capacity_id  = data.fabric_capacity.capacity.id
}
```

## Terraform State Management

### Local State (Default)

By default, Terraform stores state locally in `terraform.tfstate`. This works for individual development but is not recommended for teams.

### Remote State (Recommended for Teams)

Store Terraform state in Azure Storage for team collaboration:

1. Create a storage account for state:

```bash
# Create storage account (one-time setup)
az storage account create \
  --name fabricterraformstate \
  --resource-group fabric-terraform-state-rg \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name fabricterraformstate
```

2. Add backend configuration to `providers.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "fabric-terraform-state-rg"
    storage_account_name = "fabricterraformstate"
    container_name       = "tfstate"
    key                  = "fabric-dev.tfstate"
  }
}
```

3. Re-initialize Terraform:

```bash
terraform init -reconfigure
```

## Troubleshooting

### Authentication Issues

**Problem**: `Error: unable to build authorizer`

**Solution**:
```bash
# Re-authenticate
./azure_login.sh

# Verify authentication
az account show
```

### Fabric Provider Errors

**Problem**: `Error: Provider not supported for service principal authentication`

**Solution**: Many Fabric APIs require user authentication. Ensure you're logged in with `az login` and not using a service principal.

### Capacity State Issues

**Problem**: `Capacity is in a transitioning state`

**Solution**: Wait for the capacity to finish its current state change. Check with:
```bash
./manage_capacity.sh status your-capacity-name
```

### Resource Already Exists

**Problem**: `Error: A resource with the ID already exists`

**Solution**: Import existing resources into Terraform state:
```bash
terraform import azurerm_fabric_capacity.capacity /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Fabric/capacities/{name}
```

## Multi-Environment Deployment

Deploy multiple environments side-by-side:

```bash
# Development environment
terraform workspace new dev  # Create workspace
terraform apply -var-file=dev.tfvars

# Test environment
terraform workspace new test  # Create workspace
terraform apply -var-file=test.tfvars

# List workspaces
terraform workspace list

# Switch between environments
terraform workspace select dev
```

## Clean Up

To destroy all resources:

```bash
# For development
terraform destroy -var-file=dev.tfvars

# For test
terraform destroy -var-file=test.tfvars
```

**Warning**: This will permanently delete all data in the lakehouse!

## File Structure

```
fabric-terraform/
├── README.md                 # This file
├── .gitignore               # Git ignore rules
├── azure_login.sh           # Azure authentication script
├── manage_capacity.sh       # Capacity management script
├── providers.tf             # Provider configuration
├── variables.tf             # Variable definitions
├── main.tf                  # Main resource definitions
├── outputs.tf               # Output definitions
├── dev.tfvars              # Development environment config
└── test.tfvars             # Test environment config
```

## Security Best Practices

1. **Never commit `.tfvars` files with secrets to Git** (already in `.gitignore`)
2. **Use Azure Key Vault** for sensitive configuration
3. **Enable Azure AD authentication** for Fabric access
4. **Implement RBAC** at workspace and lakehouse levels
5. **Use managed identities** where possible (when API support is available)
6. **Enable audit logging** for compliance
7. **Restrict network access** using Azure Private Link (when available)

## Next Steps

After deployment:

1. **Access Fabric Portal**: Navigate to [app.fabric.microsoft.com](https://app.fabric.microsoft.com/)
2. **Find Your Workspace**: Look for your workspace (e.g., `fabric-dev-workspace`)
3. **Create Notebooks**: Create Spark notebooks for your ETL jobs
4. **Upload Data**: Upload sample data to test lakehouse functionality
5. **Build ETL Pipeline**: Develop your data processing workflows
6. **Deploy Wheel Files**: Upload your custom Python packages
7. **Set Up CI/CD**: Automate deployment with GitHub Actions or Azure DevOps
8. **Configure Monitoring**: Set up alerts for capacity usage and job failures

## Additional Resources

- [Microsoft Fabric Documentation](https://learn.microsoft.com/en-us/fabric/)
- [Terraform Fabric Provider](https://registry.terraform.io/providers/microsoft/fabric/latest/docs)
- [Terraform Fabric Provider GitHub](https://github.com/microsoft/terraform-provider-fabric)
- [Fabric Terraform Quickstart](https://github.com/microsoft/fabric-terraform-quickstart)
- [Fabric Community](https://community.fabric.microsoft.com/)

## Support

For issues with:
- **Terraform configuration**: Open an issue in this repository
- **Fabric provider**: [GitHub Issues](https://github.com/microsoft/terraform-provider-fabric/issues)
- **Microsoft Fabric**: [Microsoft Support](https://support.microsoft.com/)

## License

This configuration is provided as-is under the MIT License.

---

**Note**: The Microsoft Fabric Terraform provider is community-supported and not covered by Microsoft Fabric support policies. Always test thoroughly in development before applying to production environments.
