#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Building Debug Docker Images${NC}"
echo "=================================="

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

for service in service1 service2 webapp; do
    echo -e "\n${YELLOW}🔨 Building ${service} Debug Image...${NC}"
    cd $service
    if docker build -f Dockerfile.debug -t microservices-demo/${service}:debug .; then
        echo -e "${GREEN}✅ ${service} Debug Image built successfully${NC}"
    else
        echo -e "${RED}❌ Failed to build ${service} Debug Image${NC}"
        exit 1
    fi
    cd ..
done

echo -e "\n${GREEN}🎉 All debug images built successfully!${NC}"
echo -e "${BLUE}📋 Available debug images:${NC}"
echo "  - microservices-demo/service1:debug"
echo "  - microservices-demo/service2:debug"
echo "  - microservices-demo/webapp:debug"
echo -e "\n${YELLOW}💡 Next steps:${NC}"
echo "  1. Run: ./deploy-k8s-debug.sh"
echo "  2. Set up port forwarding for debug ports"
echo "  3. Connect your debugger to localhost:5678 (Service 1), localhost:5679 (Service 2), or localhost:5680 (Webapp)"
