#!/usr/bin/env python3
"""
Test script to verify Kubernetes service URLs are correctly configured
"""

import os
import asyncio
import httpx

def test_environment_variables():
    """Test that environment variables are set correctly"""
    print("🔍 Testing Environment Variables")
    print("=" * 40)
    
    # Test Service 1 configuration
    service2_url = os.getenv("SERVICE2_URL", "http://localhost:8001")
    service2_timeout = os.getenv("SERVICE2_TIMEOUT", "10")
    print(f"Service 1 -> Service 2 URL: {service2_url}")
    print(f"Service 1 -> Service 2 Timeout: {service2_timeout}s")
    
    # Test Service 2 configuration
    service1_url = os.getenv("SERVICE1_URL", "http://localhost:8000")
    service1_timeout = os.getenv("SERVICE1_TIMEOUT", "10")
    print(f"Service 2 -> Service 1 URL: {service1_url}")
    print(f"Service 2 -> Service 1 Timeout: {service1_timeout}s")
    
    # Test Web App configuration
    webapp_service1_url = os.getenv("SERVICE1_URL", "http://localhost:8000")
    webapp_service2_url = os.getenv("SERVICE2_URL", "http://localhost:8001")
    webapp_timeout = os.getenv("SERVICE_TIMEOUT", "10")
    print(f"Web App -> Service 1 URL: {webapp_service1_url}")
    print(f"Web App -> Service 2 URL: {webapp_service2_url}")
    print(f"Web App -> Service Timeout: {webapp_timeout}s")
    
    print()

async def test_service_connectivity():
    """Test service connectivity"""
    print("🌐 Testing Service Connectivity")
    print("=" * 40)
    
    service1_url = os.getenv("SERVICE1_URL", "http://localhost:8000")
    service2_url = os.getenv("SERVICE2_URL", "http://localhost:8001")
    timeout = int(os.getenv("SERVICE_TIMEOUT", "10"))
    
    async with httpx.AsyncClient() as client:
        # Test Service 1 health
        try:
            response = await client.get(f"{service1_url}/health", timeout=timeout)
            if response.status_code == 200:
                print(f"✅ Service 1 health check: {response.json()}")
            else:
                print(f"❌ Service 1 health check failed: {response.status_code}")
        except Exception as e:
            print(f"❌ Service 1 health check error: {e}")
        
        # Test Service 2 health
        try:
            response = await client.get(f"{service2_url}/health", timeout=timeout)
            if response.status_code == 200:
                print(f"✅ Service 2 health check: {response.json()}")
            else:
                print(f"❌ Service 2 health check failed: {response.status_code}")
        except Exception as e:
            print(f"❌ Service 2 health check error: {e}")
    
    print()

def test_kubernetes_urls():
    """Test that URLs are configured for Kubernetes"""
    print("☸️  Testing Kubernetes URL Configuration")
    print("=" * 40)
    
    service1_url = os.getenv("SERVICE1_URL", "http://localhost:8000")
    service2_url = os.getenv("SERVICE2_URL", "http://localhost:8001")
    
    # Check if URLs are using Kubernetes service names
    if "service1-user-management" in service1_url:
        print("✅ Service 1 URL correctly configured for Kubernetes")
    else:
        print("⚠️  Service 1 URL not using Kubernetes service name")
    
    if "service2-data-processing" in service2_url:
        print("✅ Service 2 URL correctly configured for Kubernetes")
    else:
        print("⚠️  Service 2 URL not using Kubernetes service name")
    
    # Expected Kubernetes URLs
    expected_service1_url = "http://service1-user-management:8000"
    expected_service2_url = "http://service2-data-processing:8001"
    
    print(f"\nExpected URLs for Kubernetes:")
    print(f"  Service 1: {expected_service1_url}")
    print(f"  Service 2: {expected_service2_url}")
    print(f"\nCurrent URLs:")
    print(f"  Service 1: {service1_url}")
    print(f"  Service 2: {service2_url}")
    
    print()

def main():
    """Main test function"""
    print("🚀 Kubernetes Service URL Test")
    print("=" * 50)
    print()
    
    test_environment_variables()
    asyncio.run(test_service_connectivity())
    test_kubernetes_urls()
    
    print("🎉 Test completed!")

if __name__ == "__main__":
    main()


