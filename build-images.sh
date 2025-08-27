#!/bin/bash

# Build script for microservices Docker images

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Building Microservices Docker Images${NC}"
echo "=========================================="

# Build Service 1 (User Management)
echo -e "\n${YELLOW}📦 Building Service 1 (User Management)...${NC}"
docker build -f Dockerfile.service1 -t microservices-demo/service1:latest .
echo -e "${GREEN}✅ Service 1 image built successfully${NC}"

# Build Service 2 (Data Processing)
echo -e "\n${YELLOW}📦 Building Service 2 (Data Processing)...${NC}"
docker build -f Dockerfile.service2 -t microservices-demo/service2:latest .
echo -e "${GREEN}✅ Service 2 image built successfully${NC}"

# Build Web Dashboard
echo -e "\n${YELLOW}📦 Building Test Dashboard...${NC}"
docker build -f Dockerfile.webapp -t microservices-demo/webapp:latest .
echo -e "${GREEN}✅ Test Dashboard image built successfully${NC}"

echo -e "\n${GREEN}🎉 All images built successfully!${NC}"
echo -e "\n${BLUE}📋 Built Images:${NC}"
echo "  • microservices-demo/service1:latest"
echo "  • microservices-demo/service2:latest"
echo "  • microservices-demo/webapp:latest"

echo -e "\n${YELLOW}🚀 Next steps:${NC}"
echo "  1. Deploy to Kubernetes:"
echo "     kubectl apply -f k8s/"
echo "  2. Check deployment status:"
echo "     kubectl get pods -n microservices-demo"
echo "  3. Access the dashboard:"
echo "     kubectl get svc -n microservices-demo"


