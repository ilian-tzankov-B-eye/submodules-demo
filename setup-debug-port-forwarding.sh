#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NAMESPACE="microservices-demo"

echo -e "${BLUE}🔌 Setting up Debug Port Forwarding${NC}"
echo "======================================"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if debug services are running
echo -e "${YELLOW}🔍 Checking debug services...${NC}"
if ! kubectl get pods -n "$NAMESPACE" -l "app in (service1-user-management,service2-data-processing,test-dashboard)" &> /dev/null; then
    echo -e "${RED}❌ Debug services not found. Please deploy them first with: ./deploy-k8s.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Debug services found${NC}"

# Function to start port forwarding
start_port_forwarding() {
    local service_name=$1
    local service_port=$2
    local debug_port=$3
    
    echo -e "\n${YELLOW}🔌 Setting up port forwarding for $service_name...${NC}"
    echo -e "${BLUE}📋 Service port: $service_port -> localhost:$service_port${NC}"
    echo -e "${BLUE}🐛 Debug port: $debug_port -> localhost:$debug_port${NC}"
    
    # Start port forwarding in background
    kubectl port-forward -n "$NAMESPACE" "svc/$service_name" "$service_port:$service_port" "$debug_port:$debug_port" &
    local pid=$!
    
    # Wait a moment to check if it started successfully
    sleep 2
    if kill -0 $pid 2>/dev/null; then
        echo -e "${GREEN}✅ Port forwarding started for $service_name (PID: $pid)${NC}"
        echo "$pid" > "/tmp/k8s-$service_name.pid"
    else
        echo -e "${RED}❌ Failed to start port forwarding for $service_name${NC}"
        return 1
    fi
}

# Start port forwarding for both services
echo -e "\n${BLUE}🚀 Starting port forwarding...${NC}"

# Service 1
if start_port_forwarding "service1-user-management" "8000" "5678"; then
    echo -e "${GREEN}✅ Service 1 port forwarding active${NC}"
else
    echo -e "${RED}❌ Failed to start Service 1 port forwarding${NC}"
fi

# Service 2
if start_port_forwarding "service2-data-processing" "8001" "5679"; then
    echo -e "${GREEN}✅ Service 2 port forwarding active${NC}"
else
    echo -e "${RED}❌ Failed to start Service 2 port forwarding${NC}"
fi

# Webapp
if start_port_forwarding "test-dashboard" "8002" "5680"; then
    echo -e "${GREEN}✅ Webapp port forwarding active${NC}"
else
    echo -e "${RED}❌ Failed to start Webapp port forwarding${NC}"
fi

echo -e "\n${GREEN}🎉 Port forwarding setup complete!${NC}"
echo -e "\n${YELLOW}🔧 Debug Connection Information:${NC}"
echo "Service 1 (User Management):"
echo "  - Service URL: http://localhost:8000"
echo "  - Debug Port: localhost:5678"
echo ""
echo "Service 2 (Data Processing):"
echo "  - Service URL: http://localhost:8001"
echo "  - Debug Port: localhost:5679"
echo ""
echo "Webapp (Test Dashboard):"
echo "  - Service URL: http://localhost:8002"
echo "  - Debug Port: localhost:5680"
echo ""
echo "${YELLOW}💡 Next steps:${NC}"
echo "1. Connect your debugger to the debug ports"
echo "2. The services will wait for debugger connection before starting"
echo "3. Set breakpoints in your IDE"
echo "4. Start debugging!"
echo ""
echo "${BLUE}📋 To stop port forwarding:${NC}"
echo "  ./stop-port-forwarding.sh"
