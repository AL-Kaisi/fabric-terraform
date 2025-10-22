# Quick Start Guide

Get your Fabric infrastructure running in 5 minutes!

## Prerequisites Check

```bash
# Check Azure CLI
az --version

# Check Terraform
terraform --version

# Check jq (for capacity management)
jq --version
```

Missing something? See [Prerequisites](README.md#prerequisites) in the main README.

## Step-by-Step Setup

### 1. Configure Your Environment

Edit `dev.tfvars` and update these two critical values:

```bash
# Open in your editor
vi dev.tfvars  # or use nano, code, etc.
```

Replace:
- `YOUR_SUBSCRIPTION_ID_HERE` with your Azure subscription ID
- `YOUR_EMAIL@example.com` with your email address

Get your subscription ID:
```bash
az account show --query id -o tsv
```

### 2. Authenticate

```bash
./azure_login.sh
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review What Will Be Created

```bash
terraform plan -var-file=dev.tfvars
```

This will create:
- 1 Resource Group
- 1 Fabric Capacity (F2 SKU - smallest/cheapest)
- 1 Workspace
- 1 Lakehouse
- 1 Custom Spark Pool
- 1 Spark Environment
- Spark Workspace Settings

### 5. Deploy

```bash
terraform apply -var-file=dev.tfvars
```

Type `yes` when prompted.

**Deployment takes about 5-10 minutes.**

### 6. Get Your Outputs

```bash
terraform output
```

You'll see:
- Workspace name and ID
- Lakehouse name and ID
- Spark pool name and ID
- Next steps instructions

## Daily Usage

### Start Your Day

```bash
# Resume capacity
./manage_capacity.sh start fabric-dev-capacity
```

### End Your Day (Save Money!)

```bash
# Pause capacity to stop billing
./manage_capacity.sh stop fabric-dev-capacity
```

### Check Status Anytime

```bash
./manage_capacity.sh status fabric-dev-capacity
```

## Accessing Your Workspace

1. Go to [Microsoft Fabric Portal](https://app.fabric.microsoft.com/)
2. Find your workspace: `fabric-dev-workspace`
3. Click on the lakehouse: `dev-lakehouse`
4. Start creating notebooks and uploading data!

## Uploading Your ETL Wheel File

### Quick Method (Portal)

1. In Fabric Portal, go to your workspace
2. Click on `dev-spark-env` (Spark Environment)
3. Click **Settings** → **Libraries**
4. Click **Upload** and select your `.whl` file
5. Click **Publish All**

### Command Line Method

```bash
# Set your IDs (get from terraform output)
WORKSPACE_ID=$(terraform output -raw workspace_id)
ENVIRONMENT_ID=$(terraform output -raw spark_environment_id)

# Upload wheel
curl -X POST \
  "https://api.fabric.microsoft.com/v1/workspaces/$WORKSPACE_ID/environments/$ENVIRONMENT_ID/staging/libraries" \
  -H "Authorization: Bearer $(az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv)" \
  -F "file=@path/to/your/package.whl"

# Publish
curl -X POST \
  "https://api.fabric.microsoft.com/v1/workspaces/$WORKSPACE_ID/environments/$ENVIRONMENT_ID/staging/publish" \
  -H "Authorization: Bearer $(az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv)"
```

## Common Commands

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan -var-file=dev.tfvars

# Apply changes
terraform apply -var-file=dev.tfvars

# Destroy everything
terraform destroy -var-file=dev.tfvars

# View outputs
terraform output

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate
```

## Deploying Test Environment

```bash
# Edit test configuration
vi test.tfvars

# Update subscription_id and fabric_admin_email

# Deploy test environment
terraform apply -var-file=test.tfvars
```

## Cost Optimization Tips

### Fabric Capacity Costs (24/7 when running)

| SKU | Hourly | Daily  | Monthly |
|-----|--------|--------|---------|
| F2  | $0.36  | $8.64  | $262    |
| F4  | $0.72  | $17.28 | $524    |
| F8  | $1.44  | $34.56 | $1,048  |

**Pause when not in use!**

If you work 8 hours/day, 5 days/week:
- Running 24/7: **$262/month** (F2)
- Paused off-hours: **~$87/month** (67% savings!)

### Automation Script

Create `auto-pause.sh`:

```bash
#!/bin/bash
# Add to cron: 0 18 * * 1-5 /path/to/auto-pause.sh

./manage_capacity.sh stop fabric-dev-capacity
```

Create `auto-resume.sh`:

```bash
#!/bin/bash
# Add to cron: 0 8 * * 1-5 /path/to/auto-resume.sh

./manage_capacity.sh start fabric-dev-capacity
```

## Troubleshooting

### "Error: unable to build authorizer"

```bash
# Re-authenticate
./azure_login.sh
```

### "Capacity is transitioning"

```bash
# Wait a few minutes, then check status
./manage_capacity.sh status fabric-dev-capacity
```

### "Provider not supported for service principal"

You must use user authentication (az login), not service principal. The Fabric APIs don't support service principals yet.

### Terraform state lock errors

```bash
# If state is locked and shouldn't be
terraform force-unlock <lock-id>
```

## Next Steps

1. **Create a Notebook**: In Fabric Portal, create a new Spark notebook
2. **Test Lakehouse**: Upload sample data and query it
3. **Configure Spark**: Verify your custom pool is being used
4. **Upload Libraries**: Deploy your ETL wheel files
5. **Build Pipeline**: Create your data transformation workflows
6. **Set Up CI/CD**: Automate deployments (see main README)

## Getting Help

- Main documentation: [README.md](README.md)
- Terraform issues: Check `terraform validate` and `terraform fmt`
- Fabric issues: [Microsoft Fabric Community](https://community.fabric.microsoft.com/)
- Provider bugs: [GitHub Issues](https://github.com/microsoft/terraform-provider-fabric/issues)

## Quick Reference URLs

- Fabric Portal: https://app.fabric.microsoft.com/
- Terraform Registry: https://registry.terraform.io/providers/microsoft/fabric/latest/docs
- Azure Portal: https://portal.azure.com/
- Fabric Docs: https://learn.microsoft.com/en-us/fabric/

---

**Remember**: Always pause your capacity when not in use to save costs!

```bash
./manage_capacity.sh stop fabric-dev-capacity
```
