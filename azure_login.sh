#!/bin/bash

# Azure Login Script for Microsoft Fabric Terraform Setup
# This script handles authentication to Azure for both AzureRM and Fabric providers

set -e

echo "=========================================="
echo "Azure Authentication for Fabric Terraform"
echo "=========================================="

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed."
    echo "Please install it from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if already logged in
if az account show &> /dev/null; then
    echo "Already logged in to Azure."
    CURRENT_ACCOUNT=$(az account show --query name -o tsv)
    echo "Current subscription: $CURRENT_ACCOUNT"

    read -p "Do you want to continue with this subscription? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Logging out..."
        az logout
    else
        echo "Using existing Azure session."
        az account show --output table
        exit 0
    fi
fi

# Perform Azure login
echo "Logging in to Azure..."
az login

# List available subscriptions
echo ""
echo "Available subscriptions:"
az account list --output table

# Prompt for subscription selection
read -p "Enter the subscription ID to use (or press Enter to use default): " SUBSCRIPTION_ID

if [ ! -z "$SUBSCRIPTION_ID" ]; then
    echo "Setting active subscription to: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

# Verify the active subscription
echo ""
echo "Active subscription:"
az account show --output table

# Get tenant ID and subscription ID for Terraform
TENANT_ID=$(az account show --query tenantId -o tsv)
SUB_ID=$(az account show --query id -o tsv)

echo ""
echo "=========================================="
echo "Authentication successful!"
echo "=========================================="
echo "Tenant ID: $TENANT_ID"
echo "Subscription ID: $SUB_ID"
echo ""
echo "You can now run Terraform commands."
echo "Note: The Fabric provider will use your Azure CLI credentials."
echo ""
echo "IMPORTANT: Many Fabric APIs require user authentication"
echo "and do not support service principals yet."
echo "=========================================="
