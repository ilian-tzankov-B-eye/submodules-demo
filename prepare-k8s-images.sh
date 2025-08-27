#!/bin/bash

# Script to prepare Docker images for Kubernetes deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Preparing Docker Images for Kubernetes${NC}"
echo "============================================="

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

# Check if images exist
echo -e "\n${YELLOW}🔍 Checking if images exist...${NC}"
if ! docker images | grep -q "microservices-demo/service1"; then
    echo -e "${YELLOW}⚠️  Images not found. Building them first...${NC}"
    ./build-images.sh
fi

echo -e "${GREEN}✅ Images found${NC}"

# Function to load images into different Kubernetes environments
load_images() {
    local cluster_type=$1
    
    case $cluster_type in
        "minikube")
            echo -e "\n${YELLOW}📦 Loading images into Minikube...${NC}"
            minikube image load microservices-demo/service1:latest
            minikube image load microservices-demo/service2:latest
            minikube image load microservices-demo/webapp:latest
            echo -e "${GREEN}✅ Images loaded into Minikube${NC}"
            ;;
        "kind")
            echo -e "\n${YELLOW}📦 Loading images into Kind...${NC}"
            kind load docker-image microservices-demo/service1:latest
            kind load docker-image microservices-demo/service2:latest
            kind load docker-image microservices-demo/webapp:latest
            echo -e "${GREEN}✅ Images loaded into Kind${NC}"
            ;;
        "docker-desktop")
            echo -e "\n${YELLOW}📦 Docker Desktop Kubernetes can access local images${NC}"
            echo -e "${GREEN}✅ No additional loading needed${NC}"
            ;;
        *)
            echo -e "\n${YELLOW}📦 Attempting to load images...${NC}"
            # Try to detect the cluster type
            if command_exists minikube && minikube status &> /dev/null; then
                load_images "minikube"
            elif command_exists kind && kind get clusters &> /dev/null; then
                load_images "kind"
            else
                echo -e "${YELLOW}⚠️  Could not detect cluster type. Images may need to be pushed to a registry.${NC}"
                echo -e "${BLUE}💡 For local development, consider using:${NC}"
                echo "   • Docker Desktop Kubernetes"
                echo "   • Minikube"
                echo "   • Kind"
            fi
            ;;
    esac
}

# Detect Kubernetes cluster type
echo -e "\n${YELLOW}🔍 Detecting Kubernetes cluster type...${NC}"

if command_exists minikube && minikube status &> /dev/null; then
    echo -e "${GREEN}✅ Detected Minikube cluster${NC}"
    load_images "minikube"
elif command_exists kind && kind get clusters &> /dev/null; then
    echo -e "${GREEN}✅ Detected Kind cluster${NC}"
    load_images "kind"
elif kubectl config current-context | grep -q "docker-desktop"; then
    echo -e "${GREEN}✅ Detected Docker Desktop Kubernetes${NC}"
    load_images "docker-desktop"
else
    echo -e "${YELLOW}⚠️  Could not detect cluster type${NC}"
    load_images "unknown"
fi

echo -e "\n${GREEN}🎉 Image preparation completed!${NC}"
echo -e "\n${BLUE}🔄 Now you can deploy the services:${NC}"
echo "   ./deploy-k8s.sh"

