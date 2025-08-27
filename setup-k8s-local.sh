#!/bin/bash

# Setup script for local Kubernetes cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up Local Kubernetes Cluster${NC}"
echo "============================================="

# Check if Docker is running
echo -e "\n${YELLOW}🔍 Checking Docker...${NC}"
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running${NC}"
    echo -e "${YELLOW}💡 Please start Docker Desktop or Docker daemon${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is running${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check for different Kubernetes options
echo -e "\n${YELLOW}🔍 Checking Kubernetes options...${NC}"

# Option 1: Docker Desktop Kubernetes
if command_exists docker && docker context ls | grep -q "desktop-linux"; then
    echo -e "${GREEN}✅ Docker Desktop detected${NC}"
    echo -e "${YELLOW}💡 To enable Kubernetes in Docker Desktop:${NC}"
    echo "   1. Open Docker Desktop"
    echo "   2. Go to Settings > Kubernetes"
    echo "   3. Check 'Enable Kubernetes'"
    echo "   4. Click 'Apply & Restart'"
    echo -e "\n${BLUE}🔄 After enabling Kubernetes, run:${NC}"
    echo "   ./deploy-k8s.sh"
    exit 0
fi

# Option 2: Minikube
if command_exists minikube; then
    echo -e "${GREEN}✅ Minikube detected${NC}"
    echo -e "\n${YELLOW}🚀 Starting Minikube cluster...${NC}"
    if minikube start; then
        echo -e "${GREEN}✅ Minikube cluster started successfully${NC}"
        echo -e "\n${BLUE}🔄 Now you can deploy the services:${NC}"
        echo "   ./deploy-k8s.sh"
        exit 0
    else
        echo -e "${RED}❌ Failed to start Minikube cluster${NC}"
        exit 1
    fi
fi

# Option 3: Kind
if command_exists kind; then
    echo -e "${GREEN}✅ Kind detected${NC}"
    echo -e "\n${YELLOW}🚀 Creating Kind cluster...${NC}"
    if kind create cluster --name microservices-demo; then
        echo -e "${GREEN}✅ Kind cluster created successfully${NC}"
        echo -e "\n${BLUE}🔄 Now you can deploy the services:${NC}"
        echo "   ./deploy-k8s.sh"
        exit 0
    else
        echo -e "${RED}❌ Failed to create Kind cluster${NC}"
        exit 1
    fi
fi

# Option 4: No Kubernetes tools found
echo -e "${YELLOW}⚠️  No local Kubernetes tools found${NC}"
echo -e "\n${BLUE}📚 Please install one of the following:${NC}"
echo -e "\n${GREEN}1. Docker Desktop (Recommended for beginners):${NC}"
echo "   • Download from: https://www.docker.com/products/docker-desktop"
echo "   • Enable Kubernetes in Settings > Kubernetes"
echo -e "\n${GREEN}2. Minikube:${NC}"
echo "   • Install: curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
echo "   • sudo install minikube-linux-amd64 /usr/local/bin/minikube"
echo -e "\n${GREEN}3. Kind:${NC}"
echo "   • Install: curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64"
echo "   • chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind"
echo -e "\n${YELLOW}🔄 After installing, run this script again.${NC}"

