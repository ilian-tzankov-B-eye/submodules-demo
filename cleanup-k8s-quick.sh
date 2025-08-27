#!/bin/bash

# Quick Kubernetes cleanup script (no user interaction)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Quick Kubernetes Cleanup${NC}"
echo "============================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Delete namespace (this will delete all resources in the namespace)
echo -e "\n${YELLOW}🗑️  Deleting namespace 'microservices-demo'...${NC}"
if kubectl delete namespace microservices-demo --ignore-not-found=true; then
    echo -e "${GREEN}✅ Namespace deleted${NC}"
else
    echo -e "${YELLOW}⚠️  Namespace not found or already deleted${NC}"
fi

# Wait for namespace deletion to complete
echo -e "\n${YELLOW}⏳ Waiting for cleanup to complete...${NC}"
kubectl wait --for=delete namespace/microservices-demo --timeout=30s 2>/dev/null || true

# Verify cleanup
if kubectl get namespace microservices-demo &> /dev/null; then
    echo -e "${RED}❌ Namespace still exists${NC}"
    echo -e "${YELLOW}💡 Run: kubectl delete namespace microservices-demo --force --grace-period=0${NC}"
else
    echo -e "${GREEN}✅ Cleanup completed successfully${NC}"
fi

echo -e "\n${GREEN}🎉 Quick cleanup completed!${NC}"
