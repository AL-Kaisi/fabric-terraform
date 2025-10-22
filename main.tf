# ========================================
# Resource Group
# ========================================

resource "azurerm_resource_group" "fabric_rg" {
  name     = "${var.resource_prefix}-${var.environment}-rg"
  location = var.location

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "Fabric Lakehouse and Spark"
    }
  )
}

# ========================================
# Fabric Capacity (Azure Resource)
# ========================================

resource "azurerm_fabric_capacity" "capacity" {
  name                = var.capacity_name
  resource_group_name = azurerm_resource_group.fabric_rg.name
  location            = var.location

  administration {
    members = [var.fabric_admin_email]
  }

  sku {
    name = var.capacity_sku
    tier = "Fabric"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ========================================
# Fabric Capacity Data Source
# ========================================

# Wait for capacity to be created and retrieve its Fabric ID
data "fabric_capacity" "capacity" {
  display_name = azurerm_fabric_capacity.capacity.name

  depends_on = [azurerm_fabric_capacity.capacity]
}

# ========================================
# Fabric Workspace
# ========================================

resource "fabric_workspace" "workspace" {
  display_name = var.workspace_name
  description  = "Workspace for ${var.environment} environment - Lakehouse and Spark ETL"
  capacity_id  = data.fabric_capacity.capacity.id

  depends_on = [data.fabric_capacity.capacity]
}

# ========================================
# Lakehouse
# ========================================

resource "fabric_lakehouse" "lakehouse" {
  display_name = var.lakehouse_name
  description  = var.lakehouse_description
  workspace_id = fabric_workspace.workspace.id

  depends_on = [fabric_workspace.workspace]
}

# ========================================
# Spark Custom Pool
# ========================================

resource "fabric_spark_custom_pool" "custom_pool" {
  workspace_id = fabric_workspace.workspace.id
  display_name = var.spark_pool_name
  type         = "Workspace"

  node_family = var.spark_pool_node_family
  node_size   = var.spark_pool_node_size

  auto_scale {
    enabled        = var.spark_pool_autoscale_enabled
    min_node_count = var.spark_pool_autoscale_min_nodes
    max_node_count = var.spark_pool_autoscale_max_nodes
  }

  dynamic_executor_allocation {
    enabled       = var.spark_pool_dynamic_executor_enabled
    min_executors = var.spark_pool_dynamic_executor_min
    max_executors = var.spark_pool_dynamic_executor_max
  }

  depends_on = [fabric_workspace.workspace]
}

# ========================================
# Spark Workspace Settings
# ========================================

resource "fabric_spark_workspace_settings" "workspace_spark_settings" {
  workspace_id = fabric_workspace.workspace.id

  automatic_log {
    enabled = true
  }

  high_concurrency {
    notebook_interactive_run_enabled = true
  }

  environment {
    name    = "Default"
    runtime = "1.3"
  }

  pool {
    default_pool {
      type = "Workspace"
      name = fabric_spark_custom_pool.custom_pool.display_name
    }

    starter_pool {
      max_executors    = 1
      max_node_count   = 1
    }
  }

  depends_on = [
    fabric_workspace.workspace,
    fabric_spark_custom_pool.custom_pool
  ]
}

# ========================================
# Spark Environment (for custom libraries/wheels)
# ========================================

resource "fabric_environment" "spark_environment" {
  display_name = var.spark_environment_name
  description  = "Environment for custom Spark libraries and wheel files - ${var.environment}"
  workspace_id = fabric_workspace.workspace.id

  depends_on = [fabric_workspace.workspace]
}

# Note: To upload wheel files to the environment, you'll need to use the Fabric UI or API
# The Terraform provider doesn't currently support uploading files directly
# See README.md for instructions on uploading wheel files
