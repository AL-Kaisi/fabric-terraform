#!/bin/bash

# Fabric Capacity Management Script
# This script helps you start, stop, and check the status of Fabric capacity
# to manage costs when not in use

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
usage() {
    cat << EOF
Usage: $0 <command> <capacity_name> [resource_group]

Commands:
  start    - Resume (start) the Fabric capacity
  stop     - Suspend (pause) the Fabric capacity
  status   - Check the current status of the capacity
  list     - List all Fabric capacities in subscription

Arguments:
  capacity_name    - Name of the Fabric capacity
  resource_group   - (Optional) Resource group name. If not provided, will search all resource groups

Examples:
  $0 start fabric-dev-capacity
  $0 stop fabric-dev-capacity fabric-dev-rg
  $0 status fabric-test-capacity
  $0 list

EOF
    exit 1
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed."
    echo "Please install it from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run ./azure_login.sh first."
    exit 1
fi

# Parse arguments
COMMAND=$1
CAPACITY_NAME=$2
RESOURCE_GROUP=$3

# List command doesn't require capacity name
if [ "$COMMAND" == "list" ]; then
    print_info "Listing all Fabric capacities in subscription..."
    az fabric capacity list --output table
    exit 0
fi

# Check required arguments
if [ -z "$COMMAND" ] || [ -z "$CAPACITY_NAME" ]; then
    print_error "Missing required arguments"
    usage
fi

# If resource group not provided, find it
if [ -z "$RESOURCE_GROUP" ]; then
    print_info "Resource group not provided. Searching for capacity: $CAPACITY_NAME"

    CAPACITY_INFO=$(az fabric capacity list --query "[?name=='$CAPACITY_NAME']" -o json)

    if [ "$CAPACITY_INFO" == "[]" ]; then
        print_error "Capacity '$CAPACITY_NAME' not found in subscription"
        exit 1
    fi

    RESOURCE_GROUP=$(echo $CAPACITY_INFO | jq -r '.[0].resourceGroup')
    print_info "Found capacity in resource group: $RESOURCE_GROUP"
fi

# Execute command
case $COMMAND in
    start|resume)
        print_info "Resuming capacity: $CAPACITY_NAME"
        az fabric capacity resume --name "$CAPACITY_NAME" --resource-group "$RESOURCE_GROUP"
        print_success "Capacity '$CAPACITY_NAME' is resuming. This may take a few minutes."
        print_info "Check status with: $0 status $CAPACITY_NAME"
        ;;

    stop|suspend|pause)
        print_warning "Suspending capacity: $CAPACITY_NAME"
        print_warning "All workspaces using this capacity will be unavailable until resumed."

        read -p "Are you sure you want to suspend this capacity? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            print_info "Operation cancelled."
            exit 0
        fi

        az fabric capacity suspend --name "$CAPACITY_NAME" --resource-group "$RESOURCE_GROUP"
        print_success "Capacity '$CAPACITY_NAME' is suspending. This may take a few minutes."
        print_info "Resume with: $0 start $CAPACITY_NAME"
        ;;

    status)
        print_info "Checking status of capacity: $CAPACITY_NAME"
        CAPACITY_STATUS=$(az fabric capacity show --name "$CAPACITY_NAME" --resource-group "$RESOURCE_GROUP" --query "{Name:name, State:state, SKU:sku.name, Location:location}" -o table)
        echo "$CAPACITY_STATUS"
        ;;

    *)
        print_error "Unknown command: $COMMAND"
        usage
        ;;
esac
