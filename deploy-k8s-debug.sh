#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NAMESPACE="microservices-demo"
MODULES=`grep path .gitmodules | cut -c 9-`

echo -e "${BLUE}🚀 Deploying Debug Services to Kubernetes${NC}"
echo "=============================================="

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

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo -e "${YELLOW}📦 Creating namespace: $NAMESPACE${NC}"
    kubectl create namespace "$NAMESPACE"
fi

# Prepare images for Kubernetes (load into cluster if needed)
echo -e "${YELLOW}📦 Preparing debug images for Kubernetes...${NC}"
./prepare-k8s-images-debug.sh

# Deploy debug services
echo -e "\n${YELLOW}🚀 Deploying debug services...${NC}"

for module in $MODULES; do
    echo -e "${BLUE}📋 Deploying ${module} Debug...${NC}"
    cd $module
    if kubectl apply -f ${module}-deployment-debug.yaml --validate=false; then
        echo -e "${GREEN}✅ ${module} Debug deployed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to deploy ${module} Debug${NC}"
        exit 1
    fi
    cd ..
done

# Wait for pods to be running (not ready, since they wait for debugger)
echo -e "\n${YELLOW}⏳ Waiting for debug pods to be running...${NC}"
kubectl wait --for=condition=ready pod -l app=service1-user-management -n "$NAMESPACE" --timeout=60s || {
    echo -e "${YELLOW}⚠️  Service 1 pod is waiting for debugger connection${NC}"
    kubectl wait --for=condition=podScheduled pod -l app=service1-user-management -n "$NAMESPACE" --timeout=60s
}
kubectl wait --for=condition=ready pod -l app=service2-data-processing -n "$NAMESPACE" --timeout=60s || {
    echo -e "${YELLOW}⚠️  Service 2 pod is waiting for debugger connection${NC}"
    kubectl wait --for=condition=podScheduled pod -l app=service2-data-processing -n "$NAMESPACE" --timeout=60s
}
kubectl wait --for=condition=ready pod -l app=test-dashboard-debug -n "$NAMESPACE" --timeout=60s || {
    echo -e "${YELLOW}⚠️  Webapp pod is waiting for debugger connection${NC}"
    kubectl wait --for=condition=podScheduled pod -l app=test-dashboard -n "$NAMESPACE" --timeout=60s
}

# Show deployment status
echo -e "\n${BLUE}📊 Debug Deployment Status:${NC}"
kubectl get pods -n "$NAMESPACE" -l "app in (service1-user-management,service2-data-processing,test-dashboard)"

# Show services
echo -e "\n${BLUE}🔌 Debug Services:${NC}"
kubectl get services -n "$NAMESPACE" -l "app in (service1-user-management,service2-data-processing,test-dashboard)"

echo -e "\n${GREEN}🎉 Debug services deployed successfully!${NC}"
echo -e "\n${YELLOW}🔧 Debug Setup Instructions:${NC}"
echo "1. Set up port forwarding for debug ports:"
echo "   kubectl port-forward -n $NAMESPACE svc/service1-user-management 8000:8000 5678:5678"
echo "   kubectl port-forward -n $NAMESPACE svc/service2-data-processing 8001:8001 5679:5679"
echo "   kubectl port-forward -n $NAMESPACE svc/test-dashboard 8002:8002 5680:5680"
echo ""
echo "2. Connect your debugger to:"
echo "   - Service 1: localhost:5678"
echo "   - Service 2: localhost:5679"
echo "   - Webapp: localhost:5680"
echo ""
echo "3. The services will wait for debugger connection before starting"
echo "   (This is why pods may show as 'Not Ready' until debugger connects)"
echo ""
echo "4. To access the services:"
echo "   - Service 1: http://localhost:8000"
echo "   - Service 2: http://localhost:8001"
echo "   - Webapp: http://localhost:8002"
