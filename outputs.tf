# ========================================
# Outputs
# ========================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.fabric_rg.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.fabric_rg.id
}

output "capacity_name" {
  description = "Name of the Fabric capacity"
  value       = azurerm_fabric_capacity.capacity.name
}

output "capacity_id" {
  description = "Azure resource ID of the Fabric capacity"
  value       = azurerm_fabric_capacity.capacity.id
}

output "capacity_fabric_id" {
  description = "Fabric ID of the capacity (used by Fabric resources)"
  value       = data.fabric_capacity.capacity.id
}

output "workspace_name" {
  description = "Name of the Fabric workspace"
  value       = fabric_workspace.workspace.display_name
}

output "workspace_id" {
  description = "ID of the Fabric workspace"
  value       = fabric_workspace.workspace.id
}

output "lakehouse_name" {
  description = "Name of the lakehouse"
  value       = fabric_lakehouse.lakehouse.display_name
}

output "lakehouse_id" {
  description = "ID of the lakehouse"
  value       = fabric_lakehouse.lakehouse.id
}

output "spark_custom_pool_name" {
  description = "Name of the custom Spark pool"
  value       = fabric_spark_custom_pool.custom_pool.display_name
}

output "spark_custom_pool_id" {
  description = "ID of the custom Spark pool"
  value       = fabric_spark_custom_pool.custom_pool.id
}

output "spark_environment_name" {
  description = "Name of the Spark environment"
  value       = fabric_environment.spark_environment.display_name
}

output "spark_environment_id" {
  description = "ID of the Spark environment"
  value       = fabric_environment.spark_environment.id
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "location" {
  description = "Azure region"
  value       = var.location
}

# Instructions for next steps
output "next_steps" {
  description = "Instructions for managing the infrastructure"
  value = <<-EOT

  ========================================
  Fabric Infrastructure Deployed Successfully!
  ========================================

  Environment: ${var.environment}
  Workspace: ${fabric_workspace.workspace.display_name}
  Lakehouse: ${fabric_lakehouse.lakehouse.display_name}
  Spark Pool: ${fabric_spark_custom_pool.custom_pool.display_name}

  Next Steps:
  1. Access your workspace in Microsoft Fabric portal
  2. Upload Spark wheel files to environment: ${fabric_environment.spark_environment.display_name}
  3. Configure your ETL notebooks to use the custom Spark pool

  Capacity Management:
  - To pause capacity: ./manage_capacity.sh stop ${azurerm_fabric_capacity.capacity.name}
  - To resume capacity: ./manage_capacity.sh start ${azurerm_fabric_capacity.capacity.name}

  See README.md for detailed instructions.
  ========================================
  EOT
}
