#!/bin/bash

# Kubernetes logs script for microservices

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="microservices-demo"
SERVICE=""
FOLLOW=false
TAIL_LINES=100
SINCE=""
PREVIOUS=false

# Function to show usage
show_usage() {
    echo -e "${BLUE}📋 Kubernetes Logs Script${NC}"
    echo "=========================="
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 [OPTIONS] [SERVICE]"
    echo ""
    echo -e "${YELLOW}Services:${NC}"
    echo "  service1    - User Management Service"
    echo "  service2    - Data Processing Service"
    echo "  webapp      - Test Dashboard"
    echo "  all         - All services (default)"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -f, --follow        Follow log output (like tail -f)"
    echo "  -n, --namespace     Kubernetes namespace (default: microservices-demo)"
    echo "  -t, --tail          Number of lines to show (default: 100)"
    echo "  -s, --since         Show logs since timestamp (e.g., '1h', '30m', '2024-01-01T10:00:00Z')"
    echo "  -p, --previous      Show logs from previous container instance"
    echo "  -h, --help          Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0                    # Show logs from all services"
    echo "  $0 service1           # Show logs from service1 only"
    echo "  $0 -f service2        # Follow logs from service2"
    echo "  $0 -t 50 webapp       # Show last 50 lines from webapp"
    echo "  $0 -s 1h service1     # Show service1 logs from last hour"
    echo "  $0 -p service2        # Show previous container logs from service2"
    echo ""
}

# Function to check if namespace exists
check_namespace() {
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        echo -e "${RED}❌ Namespace '$NAMESPACE' not found${NC}"
        echo -e "${YELLOW}💡 Available namespaces:${NC}"
        kubectl get namespaces
        exit 1
    fi
}

# Function to check if service exists
check_service() {
    local service_name=$1
    if ! kubectl get deployment "$service_name" -n "$NAMESPACE" &> /dev/null; then
        echo -e "${RED}❌ Service '$service_name' not found in namespace '$NAMESPACE'${NC}"
        echo -e "${YELLOW}💡 Available services:${NC}"
        kubectl get deployments -n "$NAMESPACE"
        return 0  # Don't return error code to avoid script exit
    fi
    return 0
}

# Function to get logs from a service
get_logs() {
    local service_name=$1
    local pod_name
    
    echo -e "\n${CYAN}📋 Getting logs for $service_name...${NC}"
    echo "=================================="
    
    # Get the pod name
    pod_name=$(kubectl get pods -n "$NAMESPACE" -l app="$service_name" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -z "$pod_name" ]; then
        echo -e "${RED}❌ No pods found for service '$service_name'${NC}"
        return 0  # Don't return error code
    fi
    
    echo -e "${GREEN}✅ Found pod: $pod_name${NC}"
    
    # Build kubectl logs command
    local cmd="kubectl logs $pod_name -n $NAMESPACE"
    
    # Add options
    if [ "$FOLLOW" = true ]; then
        cmd="$cmd -f"
    fi
    
    if [ "$PREVIOUS" = true ]; then
        cmd="$cmd -p"
    fi
    
    if [ -n "$TAIL_LINES" ]; then
        cmd="$cmd --tail=$TAIL_LINES"
    fi
    
    if [ -n "$SINCE" ]; then
        cmd="$cmd --since=$SINCE"
    fi
    
    # Execute the command
    echo -e "${YELLOW}🔍 Executing: $cmd${NC}"
    echo ""
    
    # Temporarily disable exit on error for this command
    set +e
    eval "$cmd"
    local exit_code=$?
    # Don't re-enable set -e here to avoid script exit
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\n${GREEN}✅ Logs retrieved successfully for $service_name${NC}"
        return 0
    else
        echo -e "\n${RED}❌ Failed to get logs for $service_name${NC}"
        return 0  # Don't return error code to avoid script exit
    fi
}

# Function to get logs from all services
get_all_logs() {
    echo -e "${BLUE}📋 Getting logs from all services${NC}"
    echo "================================="
    
    local services=("service1-user-management" "service2-data-processing" "test-dashboard")
    local success_count=0
    
    for service in "${services[@]}"; do
        if check_service "$service"; then
            if get_logs "$service"; then
                ((success_count++))
            fi
        fi
    done
    
    echo -e "\n${GREEN}✅ Successfully retrieved logs from $success_count out of ${#services[@]} services${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -t|--tail)
            TAIL_LINES="$2"
            shift 2
            ;;
        -s|--since)
            SINCE="$2"
            shift 2
            ;;
        -p|--previous)
            PREVIOUS=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        service1|service2|webapp|all)
            SERVICE="$1"
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Set default service if not specified
if [ -z "$SERVICE" ]; then
    SERVICE="all"
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if Kubernetes cluster is accessible
echo -e "${YELLOW}🔍 Checking Kubernetes cluster...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    echo -e "${YELLOW}💡 Please ensure you have a Kubernetes cluster running${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Kubernetes cluster is accessible${NC}"

# Check namespace
check_namespace

# Get logs based on service selection
case $SERVICE in
    service1)
        if check_service "service1-user-management"; then
            get_logs "service1-user-management"
        fi
        ;;
    service2)
        if check_service "service2-data-processing"; then
            get_logs "service2-data-processing"
        fi
        ;;
    webapp)
        if check_service "test-dashboard"; then
            get_logs "test-dashboard"
        fi
        ;;
    all)
        # Temporarily disable exit on error for the all services case
        set +e
        get_all_logs
        all_exit_code=$?
        set -e
        if [ $all_exit_code -ne 0 ]; then
            echo -e "${YELLOW}⚠️  Some services failed to retrieve logs${NC}"
        fi
        ;;
    *)
        echo -e "${RED}❌ Invalid service: $SERVICE${NC}"
        show_usage
        exit 1
        ;;
esac

echo -e "\n${GREEN}🎉 Log retrieval completed!${NC}"
