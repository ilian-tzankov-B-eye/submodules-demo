#!/usr/bin/env python3
"""
Startup script to launch all microservices
"""

import subprocess
import sys
import time
import signal
import os
from typing import List

class ServiceManager:
    def __init__(self):
        self.processes: List[subprocess.Popen] = []
        
    def start_service(self, name: str, command: List[str], port: int):
        """Start a service and wait for it to be ready"""
        print(f"🚀 Starting {name} on port {port}...")
        
        try:
            process = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            self.processes.append(process)
            
            # Wait a moment for the service to start
            time.sleep(2)
            
            if process.poll() is None:
                print(f"✅ {name} started successfully (PID: {process.pid})")
            else:
                print(f"❌ Failed to start {name}")
                stdout, stderr = process.communicate()
                print(f"Error: {stderr}")
                
        except Exception as e:
            print(f"❌ Error starting {name}: {e}")
    
    def start_all_services(self):
        """Start all three services"""
        print("🌟 Starting FastAPI Microservices...")
        print("=" * 50)
        
        # Start Service 1 (User Management)
        self.start_service(
            "Service 1 (User Management)",
            [sys.executable, "service1/service1.py"],
            8000
        )
        
        # Start Service 2 (Data Processing)
        self.start_service(
            "Service 2 (Data Processing)", 
            [sys.executable, "service2/service2.py"],
            8001
        )
        
        # Start Test Dashboard
        self.start_service(
            "Test Dashboard",
            [sys.executable, "webapp/test_web_app.py"],
            8002
        )
        
        print("\n" + "=" * 50)
        print("🎉 All services started!")
        print("\n📋 Service URLs:")
        print("   • Service 1 (User Management): http://localhost:8000")
        print("   • Service 2 (Data Processing): http://localhost:8001")
        print("   • Test Dashboard: http://localhost:8002")
        print("\n📚 API Documentation:")
        print("   • Service 1 Docs: http://localhost:8000/docs")
        print("   • Service 2 Docs: http://localhost:8001/docs")
        print("\n⏹️  Press Ctrl+C to stop all services")
        
    def stop_all_services(self):
        """Stop all running services"""
        print("\n🛑 Stopping all services...")
        
        for process in self.processes:
            if process.poll() is None:  # Process is still running
                process.terminate()
                try:
                    process.wait(timeout=5)
                    print(f"✅ Stopped process {process.pid}")
                except subprocess.TimeoutExpired:
                    process.kill()
                    print(f"⚠️  Force killed process {process.pid}")
        
        print("👋 All services stopped!")

def signal_handler(signum, frame):
    """Handle Ctrl+C to gracefully stop services"""
    print("\n🛑 Received interrupt signal...")
    service_manager.stop_all_services()
    sys.exit(0)

if __name__ == "__main__":
    # Set up signal handler for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    
    service_manager = ServiceManager()
    
    try:
        service_manager.start_all_services()
        
        # Keep the script running
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        service_manager.stop_all_services()
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        service_manager.stop_all_services()
        sys.exit(1)


