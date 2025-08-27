#!/bin/bash

# Kubernetes deployment script for microservices

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MODULES=`grep path .gitmodules | cut -c 9-`
APPLICATIONS="service1-user-management service2-data-processing test-dashboard"


echo -e "${BLUE}🚀 Deploying Microservices to Kubernetes${NC}"
echo "============================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if Kubernetes cluster is accessible
echo -e "\n${YELLOW}🔍 Checking Kubernetes cluster...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    echo -e "${YELLOW}💡 Please ensure you have a Kubernetes cluster running:${NC}"
    echo "   • For local development: minikube start"
    echo "   • For Docker Desktop: Enable Kubernetes in settings"
    echo "   • For cloud clusters: Configure kubectl with your cluster credentials"
    echo -e "\n${BLUE}📚 Quick start options:${NC}"
    echo "   1. Install minikube: https://minikube.sigs.k8s.io/docs/start/"
    echo "   2. Use Docker Desktop Kubernetes"
    echo "   3. Use kind: https://kind.sigs.k8s.io/"
    echo -e "\n${YELLOW}🔄 After starting your cluster, run this script again.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Kubernetes cluster is accessible${NC}"

# Create namespace
echo -e "\n${YELLOW}📁 Creating namespace...${NC}"
if kubectl apply -f k8s/namespace.yaml --validate=false; then
    echo -e "${GREEN}✅ Namespace created${NC}"
else
    echo -e "${YELLOW}⚠️  Namespace creation failed, continuing anyway...${NC}"
fi

# Deploy Services and Dashboard
for service in $MODULES; do
    echo -e "\n${YELLOW}📦 Deploying ${service}...${NC}"
    if kubectl apply -f ${service}/${service}-deployment.yaml --validate=false; then
        echo -e "${GREEN}✅ ${service} deployed${NC}"
    else
        echo -e "${RED}❌ ${service} deployment failed${NC}"
        exit 1
    fi
done

echo -e "\n${GREEN}🎉 All services deployed successfully!${NC}"

# Wait for pods to be ready
echo -e "\n${YELLOW}⏳ Waiting for pods to be ready...${NC}"
for application in $APPLICATIONS; do
    echo -e "\n${YELLOW}📦 Waiting for ${application} pods to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=${application} -n microservices-demo --timeout=300s
done

echo -e "\n${GREEN}✅ All pods are ready!${NC}"
echo -e "\n${YELLOW}📦 Deploying Service 1 (User Management)...${NC}"

echo -e "\n${GREEN}🎉 All services deployed successfully!${NC}"


# Show deployment status
echo -e "\n${BLUE}📋 Deployment Status:${NC}"
kubectl get pods -n microservices-demo

echo -e "\n${BLUE}🌐 Services:${NC}"
kubectl get svc -n microservices-demo

echo -e "\n${YELLOW}🔗 Access Information${NC}"
echo -e "\n${BLUE}📊 Run one of the following commands to access the dashboard or one of the services:${NC}"
echo -e "\n${BLUE}📊 Exit the proxy with Ctrl+C:${NC}"
echo "  • Test Dashboard: kubectl port-forward svc/test-dashboard 8080:80 -n microservices-demo"
echo "  • Service 1 API: kubectl port-forward svc/service1-user-management 8000:8000 -n microservices-demo"
echo "  • Service 2 API: kubectl port-forward svc/service2-data-processing 8001:8001 -n microservices-demo"

echo -e "\n${GREEN}🎯 Dashboard will be available at: http://localhost:8080${NC}"
