#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Preparing Debug Docker Images for Kubernetes${NC}"
echo "=============================================="

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if images exist
echo -e "${YELLOW}🔍 Checking if debug images exist...${NC}"
if ! docker images | grep -q "service1.*debug\|microservices-demo/service1.*debug"; then
    echo -e "${RED}❌ Debug image for service1 not found${NC}"
    echo -e "${YELLOW}💡 Please run: ./build-debug-images.sh${NC}"
    exit 1
fi

if ! docker images | grep -q "service2.*debug\|microservices-demo/service2.*debug"; then
    echo -e "${RED}❌ Debug image for service2 not found${NC}"
    echo -e "${YELLOW}💡 Please run: ./build-debug-images.sh${NC}"
    exit 1
fi

if ! docker images | grep -q "webapp.*debug\|test-dashboard.*debug\|microservices-demo/webapp.*debug"; then
    echo -e "${RED}❌ Debug image for webapp not found${NC}"
    echo -e "${YELLOW}💡 Please run: ./build-debug-images.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Debug images found${NC}"

# Detect Kubernetes cluster type
echo -e "\n${YELLOW}🔍 Detecting Kubernetes cluster type...${NC}"
if kubectl config current-context | grep -q "minikube"; then
    echo -e "${GREEN}✅ Detected Minikube cluster${NC}"
    CLUSTER_TYPE="minikube"
elif kubectl config current-context | grep -q "kind"; then
    echo -e "${GREEN}✅ Detected Kind cluster${NC}"
    CLUSTER_TYPE="kind"
elif kubectl config current-context | grep -q "docker-desktop"; then
    echo -e "${GREEN}✅ Detected Docker Desktop cluster${NC}"
    CLUSTER_TYPE="docker-desktop"
else
    echo -e "${YELLOW}⚠️  Unknown cluster type, assuming local cluster${NC}"
    CLUSTER_TYPE="local"
fi

# Load images into cluster
echo -e "\n${YELLOW}📦 Loading debug images into Kubernetes...${NC}"

case $CLUSTER_TYPE in
    "minikube")
        echo -e "${BLUE}📦 Loading images into Minikube...${NC}"
        # Load the first available image for each service
        if docker images | grep -q "microservices-demo/service1:debug"; then
            minikube image load microservices-demo/service1:debug
        else
            minikube image load service1-user-management:debug
        fi
        if docker images | grep -q "microservices-demo/service2:debug"; then
            minikube image load microservices-demo/service2:debug
        else
            minikube image load service2-data-processing:debug
        fi
        if docker images | grep -q "microservices-demo/webapp:debug"; then
            minikube image load microservices-demo/webapp:debug
        else
            minikube image load test-dashboard:debug
        fi
        ;;
    "kind")
        echo -e "${BLUE}📦 Loading images into Kind...${NC}"
        # Load the first available image for each service
        if docker images | grep -q "microservices-demo/service1:debug"; then
            kind load docker-image microservices-demo/service1:debug
        else
            kind load docker-image service1-user-management:debug
        fi
        if docker images | grep -q "microservices-demo/service2:debug"; then
            kind load docker-image microservices-demo/service2:debug
        else
            kind load docker-image service2-data-processing:debug
        fi
        if docker images | grep -q "microservices-demo/webapp:debug"; then
            kind load docker-image microservices-demo/webapp:debug
        else
            kind load docker-image test-dashboard:debug
        fi
        ;;
    "docker-desktop"|"local")
        echo -e "${BLUE}📦 Docker Desktop can access local images directly${NC}"
        echo -e "${YELLOW}💡 No image loading required for Docker Desktop${NC}"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Unknown cluster type, skipping image loading${NC}"
        ;;
esac

echo -e "\n${GREEN}🎉 Debug images prepared for Kubernetes!${NC}"
echo -e "${BLUE}📋 Available debug images:${NC}"
echo "  - microservices-demo/service1:debug"
echo "  - microservices-demo/service2:debug"
echo "  - microservices-demo/webapp:debug"
echo -e "\n${YELLOW}💡 Next steps:${NC}"
echo "  1. Run: ./deploy-k8s-debug.sh"
echo "  2. Set up port forwarding: ./setup-debug-port-forwarding.sh"
echo "  3. Connect your debugger to the debug ports"

