# Development Environment Configuration

# Environment
environment = "dev"
location    = "eastus"

# Azure Subscription
# IMPORTANT: Replace with your actual subscription ID
subscription_id = "YOUR_SUBSCRIPTION_ID_HERE"

# Fabric Capacity
capacity_name = "fabric-dev-capacity"
capacity_sku  = "F2" # Smallest SKU for development

# Fabric Administrator
# IMPORTANT: Replace with your email address
fabric_admin_email = "YOUR_EMAIL@example.com"

# Resource Naming
resource_prefix = "fabric"

# Workspace
workspace_name = "fabric-dev-workspace"

# Lakehouse
lakehouse_name        = "dev-lakehouse"
lakehouse_description = "Development lakehouse for ETL workflows"

# Spark Pool
spark_pool_name        = "dev-spark-pool"
spark_pool_node_family = "MemoryOptimized"
spark_pool_node_size   = "Small"

# Spark Autoscaling
spark_pool_autoscale_enabled   = true
spark_pool_autoscale_min_nodes = 1
spark_pool_autoscale_max_nodes = 2

# Spark Dynamic Executor Allocation
spark_pool_dynamic_executor_enabled = true
spark_pool_dynamic_executor_min     = 1
spark_pool_dynamic_executor_max     = 2

# Spark Environment
spark_environment_name = "dev-spark-env"

# Tags
tags = {
  Environment = "dev"
  Team        = "Data Engineering"
  CostCenter  = "Engineering"
  ManagedBy   = "Terraform"
}
