# Test Environment Configuration

# Environment
environment = "test"
location    = "eastus"

# Azure Subscription
# IMPORTANT: Replace with your actual subscription ID
subscription_id = "YOUR_SUBSCRIPTION_ID_HERE"

# Fabric Capacity
capacity_name = "fabric-test-capacity"
capacity_sku  = "F4" # Slightly larger for testing workloads

# Fabric Administrator
# IMPORTANT: Replace with your email address
fabric_admin_email = "YOUR_EMAIL@example.com"

# Resource Naming
resource_prefix = "fabric"

# Workspace
workspace_name = "fabric-test-workspace"

# Lakehouse
lakehouse_name        = "test-lakehouse"
lakehouse_description = "Test lakehouse for ETL validation and testing"

# Spark Pool
spark_pool_name        = "test-spark-pool"
spark_pool_node_family = "MemoryOptimized"
spark_pool_node_size   = "Medium"

# Spark Autoscaling
spark_pool_autoscale_enabled   = true
spark_pool_autoscale_min_nodes = 1
spark_pool_autoscale_max_nodes = 3

# Spark Dynamic Executor Allocation
spark_pool_dynamic_executor_enabled = true
spark_pool_dynamic_executor_min     = 1
spark_pool_dynamic_executor_max     = 3

# Spark Environment
spark_environment_name = "test-spark-env"

# Tags
tags = {
  Environment = "test"
  Team        = "Data Engineering"
  CostCenter  = "Engineering"
  ManagedBy   = "Terraform"
}
