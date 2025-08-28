#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🛑 Stopping Debug Port Forwarding${NC}"
echo "=================================="

# Function to stop port forwarding
stop_port_forwarding() {
    local service_name=$1
    local pid_file="/tmp/k8s-$service_name.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 $pid 2>/dev/null; then
            echo -e "${YELLOW}🛑 Stopping port forwarding for $service_name (PID: $pid)...${NC}"
            kill $pid
            rm "$pid_file"
            echo -e "${GREEN}✅ Port forwarding stopped for $service_name${NC}"
        else
            echo -e "${YELLOW}⚠️  Port forwarding for $service_name was already stopped${NC}"
            rm "$pid_file"
        fi
    else
        echo -e "${YELLOW}⚠️  No port forwarding found for $service_name${NC}"
    fi
}

# Stop port forwarding for all services
stop_port_forwarding "service1-user-management"
stop_port_forwarding "service2-data-processing"
stop_port_forwarding "test-dashboard"

# Also kill any remaining kubectl port-forward processes
echo -e "\n${YELLOW}🔍 Cleaning up any remaining kubectl port-forward processes...${NC}"
pkill -f "kubectl port-forward.*debug" 2>/dev/null || true

echo -e "\n${GREEN}🎉 Debug port forwarding stopped!${NC}"
