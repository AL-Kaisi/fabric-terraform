# Environment Configuration
variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  validation {
    condition     = can(regex("^(dev|test|prod)$", var.environment))
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

# Fabric Capacity Configuration
variable "capacity_name" {
  description = "Name of the Fabric capacity"
  type        = string
}

variable "capacity_sku" {
  description = "SKU for Fabric capacity (F2, F4, F8, F16, F32, F64, F128, F256, F512, F1024, F2048)"
  type        = string
  default     = "F2"
  validation {
    condition     = can(regex("^F(2|4|8|16|32|64|128|256|512|1024|2048)$", var.capacity_sku))
    error_message = "Capacity SKU must be a valid Fabric SKU (F2-F2048)."
  }
}

variable "fabric_admin_email" {
  description = "Email address of the Fabric administrator"
  type        = string
}

# Resource Naming
variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "fabric"
}

# Workspace Configuration
variable "workspace_name" {
  description = "Name of the Fabric workspace"
  type        = string
}

# Lakehouse Configuration
variable "lakehouse_name" {
  description = "Name of the lakehouse"
  type        = string
  default     = "lakehouse"
}

variable "lakehouse_description" {
  description = "Description of the lakehouse"
  type        = string
  default     = "Managed with Terraform"
}

# Spark Configuration
variable "spark_pool_name" {
  description = "Name of the custom Spark pool"
  type        = string
  default     = "spark-pool-custom"
}

variable "spark_pool_node_family" {
  description = "Node family for Spark pool (MemoryOptimized or HardwareAccelerated)"
  type        = string
  default     = "MemoryOptimized"
}

variable "spark_pool_node_size" {
  description = "Node size for Spark pool (Small, Medium, Large, XLarge, XXLarge)"
  type        = string
  default     = "Small"
}

variable "spark_pool_autoscale_enabled" {
  description = "Enable autoscaling for Spark pool"
  type        = bool
  default     = true
}

variable "spark_pool_autoscale_min_nodes" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "spark_pool_autoscale_max_nodes" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 3
}

variable "spark_pool_dynamic_executor_enabled" {
  description = "Enable dynamic executor allocation"
  type        = bool
  default     = true
}

variable "spark_pool_dynamic_executor_min" {
  description = "Minimum number of executors"
  type        = number
  default     = 1
}

variable "spark_pool_dynamic_executor_max" {
  description = "Maximum number of executors"
  type        = number
  default     = 2
}

# Environment for Spark Wheel
variable "spark_environment_name" {
  description = "Name of the Spark environment for custom libraries"
  type        = string
  default     = "spark-environment"
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
