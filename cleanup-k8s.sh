#!/bin/bash

# Kubernetes cleanup script for microservices demo

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Cleaning up Kubernetes Resources${NC}"
echo "====================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if namespace exists
echo -e "\n${YELLOW}🔍 Checking if namespace exists...${NC}"
if kubectl get namespace microservices-demo &> /dev/null; then
    echo -e "${GREEN}✅ Namespace found${NC}"
else
    echo -e "${YELLOW}⚠️  Namespace 'microservices-demo' not found${NC}"
    echo -e "${GREEN}✅ Cleanup completed (nothing to clean)${NC}"
    exit 0
fi

# Function to delete resources safely
delete_resource() {
    local resource_type=$1
    local resource_name=$2
    local namespace=$3
    
    echo -e "\n${YELLOW}🗑️  Deleting $resource_type: $resource_name${NC}"
    if kubectl delete $resource_type $resource_name -n $namespace --ignore-not-found=true; then
        echo -e "${GREEN}✅ $resource_type '$resource_name' deleted${NC}"
    else
        echo -e "${YELLOW}⚠️  $resource_type '$resource_name' not found or already deleted${NC}"
    fi
}

# Delete deployments
echo -e "\n${YELLOW}📦 Deleting deployments...${NC}"
delete_resource "deployment" "service1-user-management" "microservices-demo"
delete_resource "deployment" "service2-data-processing" "microservices-demo"
delete_resource "deployment" "test-dashboard" "microservices-demo"

# Delete services
echo -e "\n${YELLOW}🌐 Deleting services...${NC}"
delete_resource "service" "service1-user-management" "microservices-demo"
delete_resource "service" "service2-data-processing" "microservices-demo"
delete_resource "service" "test-dashboard" "microservices-demo"

# Delete pods (in case there are orphaned pods)
echo -e "\n${YELLOW}📋 Deleting any remaining pods...${NC}"
kubectl delete pods -l app=service1-user-management -n microservices-demo --ignore-not-found=true
kubectl delete pods -l app=service2-data-processing -n microservices-demo --ignore-not-found=true
kubectl delete pods -l app=test-dashboard -n microservices-demo --ignore-not-found=true

# Delete any other resources in the namespace
echo -e "\n${YELLOW}🔍 Cleaning up any other resources...${NC}"
kubectl delete all --all -n microservices-demo --ignore-not-found=true

# Wait a moment for resources to be deleted
echo -e "\n${YELLOW}⏳ Waiting for resources to be cleaned up...${NC}"
sleep 5

# Delete the namespace
echo -e "\n${YELLOW}🗑️  Deleting namespace...${NC}"
if kubectl delete namespace microservices-demo --ignore-not-found=true; then
    echo -e "${GREEN}✅ Namespace 'microservices-demo' deleted${NC}"
else
    echo -e "${YELLOW}⚠️  Namespace 'microservices-demo' not found or already deleted${NC}"
fi

# Wait for namespace deletion to complete
echo -e "\n${YELLOW}⏳ Waiting for namespace deletion to complete...${NC}"
kubectl wait --for=delete namespace/microservices-demo --timeout=60s 2>/dev/null || true

# Check if cleanup was successful
echo -e "\n${YELLOW}🔍 Verifying cleanup...${NC}"
if kubectl get namespace microservices-demo &> /dev/null; then
    echo -e "${RED}❌ Namespace still exists. You may need to force delete it.${NC}"
    echo -e "${YELLOW}💡 To force delete: kubectl delete namespace microservices-demo --force --grace-period=0${NC}"
else
    echo -e "${GREEN}✅ Namespace successfully deleted${NC}"
fi

# Optional: Clean up Docker images
echo -e "\n${YELLOW}🐳 Clean up Docker images? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "\n${YELLOW}🗑️  Deleting Docker images...${NC}"
    docker rmi microservices-demo/service1:latest 2>/dev/null || echo -e "${YELLOW}⚠️  Service 1 image not found${NC}"
    docker rmi microservices-demo/service2:latest 2>/dev/null || echo -e "${YELLOW}⚠️  Service 2 image not found${NC}"
    docker rmi microservices-demo/webapp:latest 2>/dev/null || echo -e "${YELLOW}⚠️  Web app image not found${NC}"
    echo -e "${GREEN}✅ Docker images cleaned up${NC}"
else
    echo -e "${YELLOW}⚠️  Skipping Docker image cleanup${NC}"
fi

echo -e "\n${GREEN}🎉 Kubernetes cleanup completed!${NC}"
echo -e "\n${BLUE}📋 Summary:${NC}"
echo "  • Deleted all deployments"
echo "  • Deleted all services"
echo "  • Deleted all pods"
echo "  • Deleted namespace 'microservices-demo'"
echo -e "\n${YELLOW}🔄 To redeploy, run:${NC}"
echo "  ./deploy-k8s-local.sh"
