cd ../# Remote Debugging Guide

This guide explains how to set up remote debugging for the microservices running in Kubernetes.

## Overview

The debugging setup includes:
- Debug versions of Docker images with `debugpy` installed
- Kubernetes deployments with debug ports exposed
- Port forwarding scripts for local debugging
- VS Code configuration for seamless debugging

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Your IDE      │    │   Kubernetes    │
│   (VS Code)     │◄──►│   Cluster       │
│                 │    │                 │
│ Debug Port 5678 │    │ Service 1 Debug │
│ Debug Port 5679 │    │ Service 2 Debug │
│ Debug Port 5680 │    │ Webapp Debug    │
└─────────────────┘    └─────────────────┘
```

## Quick Start

### 1. Build Debug Images

```bash
./build-debug-images.sh
```

This creates debug versions of the services with `debugpy` installed.

### 2. Deploy Debug Services

```bash
./deploy-k8s-debug.sh
```

This deploys the debug services to Kubernetes with debug ports exposed.

### 3. Set Up Port Forwarding

```bash
./setup-debug-port-forwarding.sh
```

This sets up port forwarding for both services and debug ports.

### 4. Start Debugging

In VS Code:
1. Open the Debug panel (Ctrl+Shift+D)
2. Select "Debug Service 1" or "Debug Service 2"
3. Press F5 to start debugging

## Detailed Setup

### Debug Images

The debug images are based on the regular images but include:
- `debugpy` Python debugger
- Debug ports exposed (5678 for Service 1, 5679 for Service 2)

**Files:**
- `service1/Dockerfile.debug`
- `service2/Dockerfile.debug`
- `webapp/Dockerfile.debug`

### Kubernetes Debug Deployments

Debug deployments include:
- Debug ports exposed as container ports
- Services with debug port endpoints
- Same health checks and resource limits as production

**Files:**
- `service1/service1-deployment-debug.yaml`
- `service2/service2-deployment-debug.yaml`
- `webapp/webapp-deployment-debug.yaml`

### Port Forwarding

The port forwarding scripts manage:
- Service ports (8000, 8001)
- Debug ports (5678, 5679)
- Background processes with PID tracking

**Files:**
- `setup-debug-port-forwarding.sh`
- `stop-debug-port-forwarding.sh`

## VS Code Configuration

### Launch Configurations

The `.vscode/launch.json` includes:
- **Debug Service 1**: Attach to localhost:5678
- **Debug Service 2**: Attach to localhost:5679
- **Debug Webapp**: Attach to localhost:5680
- **Debug All Services**: Combined configuration

### Tasks

The `.vscode/tasks.json` includes:
- `build-debug-images`: Build debug Docker images
- `deploy-debug-services`: Deploy to Kubernetes
- `start-debug-port-forwarding`: Set up port forwarding
- `stop-debug-port-forwarding`: Clean up port forwarding

## Debug Ports

| Service | Service Port | Debug Port | Description |
|---------|--------------|------------|-------------|
| Service 1 | 8000 | 5678 | User Management Service |
| Service 2 | 8001 | 5679 | Data Processing Service |
| Webapp | 8002 | 5680 | Test Dashboard |

## Usage Examples

### Debugging Service 1

1. **Build and deploy:**
   ```bash
   ./build-debug-images.sh
   ./deploy-k8s-debug.sh
   ```

2. **Set up port forwarding:**
   ```bash
   ./setup-debug-port-forwarding.sh
   ```

3. **In VS Code:**
   - Set breakpoints in `service1.py`
   - Select "Debug Service 1" configuration
   - Press F5

### Debugging Service 2

1. **Set up port forwarding:**
   ```bash
   ./setup-debug-port-forwarding.sh
   ```

2. **In VS Code:**
   - Set breakpoints in `service2.py`
   - Select "Debug Service 2" configuration
   - Press F5

### Debugging Webapp

1. **Set up port forwarding:**
   ```bash
   ./setup-debug-port-forwarding.sh
   ```

2. **In VS Code:**
   - Set breakpoints in `test_web_app.py`
   - Select "Debug Webapp (Test Dashboard)" configuration
   - Press F5

### Debugging All Services

1. **Set up port forwarding:**
   ```bash
   ./setup-debug-port-forwarding.sh
   ```

2. **In VS Code:**
   - Set breakpoints in all services
   - Select "Debug All Services" configuration
   - Press F5

## Troubleshooting

### Common Issues

#### 1. Pods Timeout During Deployment

**Symptoms:** `error: timed out waiting for the condition on pods`

**Cause:** Debug pods with `--wait-for-client` flag wait for debugger connection before starting, so they won't pass readiness probes.

**Solutions:**
- **Option 1**: Use the updated deployment script that handles this scenario
- **Option 2**: Use no-wait debug images: `./build-debug-images-nowait.sh`
- **Option 3**: Check pod status: `kubectl get pods -n microservices-demo -l "app in (service1-user-management,service2-data-processing,test-dashboard)"`

#### 2. Debugger Won't Connect

**Symptoms:** VS Code shows "Connection refused" or timeout

**Solutions:**
- Check if port forwarding is active: `./setup-debug-port-forwarding.sh`
- Verify debug services are running: `kubectl get pods -n microservices-demo`
- Check if ports are in use: `netstat -tlnp | grep :5678`

#### 2. Services Not Starting

**Symptoms:** Pods stuck in "Pending" or "CrashLoopBackOff"

**Solutions:**
- Check pod logs: `kubectl logs -n microservices-demo <pod-name>`
- Verify images exist: `docker images | grep debug`
- Check resource limits: `kubectl describe pod -n microservices-demo <pod-name>`

#### 3. Port Forwarding Fails

**Symptoms:** "Address already in use" or connection refused

**Solutions:**
- Stop existing port forwarding: `./stop-debug-port-forwarding.sh`
- Check for existing processes: `ps aux | grep kubectl`
- Kill any remaining processes: `pkill -f "kubectl port-forward"`

### Debug Commands

#### Check Debug Services Status

```bash
# Check pods
kubectl get pods -n microservices-demo -l "app in (service1-user-management,service2-data-processing,test-dashboard)"

# Check services
kubectl get services -n microservices-demo -l "app in (service1-user-management,service2-data-processing,test-dashboard)"

# Check logs
kubectl logs -n microservices-demo -l app=service1-user-management
kubectl logs -n microservices-demo -l app=service2-data-processing
kubectl logs -n microservices-demo -l app=test-dashboard
```

#### Manual Port Forwarding

```bash
# Service 1
kubectl port-forward -n microservices-demo svc/service1-user-management 8000:8000 5678:5678

# Service 2
kubectl port-forward -n microservices-demo svc/service2-data-processing 8001:8001 5679:5679

# Webapp
kubectl port-forward -n microservices-demo svc/test-dashboard 8002:8002 5680:5680
```

#### Test Debug Connection

```bash
# Test Service 1 debug port
telnet localhost 5678

# Test Service 2 debug port
telnet localhost 5679

# Test Webapp debug port
telnet localhost 5680
```

## Cleanup

### Stop Debugging

1. **Stop port forwarding:**
   ```bash
   ./stop-debug-port-forwarding.sh
   ```

2. **Delete debug deployments (optional):**
   ```bash
   kubectl delete -f service1/service1-deployment-debug.yaml
   kubectl delete -f service2/service2-deployment-debug.yaml
   kubectl delete -f webapp/webapp-deployment-debug.yaml
   ```

### Remove Debug Images

```bash
docker rmi microservices-demo/service1:debug
docker rmi microservices-demo/service2:debug
docker rmi microservices-demo/webapp:debug
```

## Advanced Configuration

### Custom Debug Ports

To use different debug ports, modify:
1. Dockerfiles: Change `EXPOSE` and `--listen` port
2. Kubernetes YAML: Update container and service ports
3. VS Code config: Update `launch.json` port numbers
4. Port forwarding scripts: Update port mappings

### Multiple Debug Sessions

To debug multiple instances:
1. Scale deployments: `kubectl scale deployment service1-user-management --replicas=2`
2. Use different debug ports for each instance
3. Set up separate port forwarding for each pod

## Security Considerations

- Debug ports are only exposed within the cluster
- Port forwarding creates local-only access
- Debug images include additional packages (debugpy)
- Consider using debug images only in development environments

## Performance Impact

- Debug images are larger due to debugpy
cd - Port forwarding adds minimal overhead
- Debugging itself may impact performance

## Best Practices

1. **Use debug images only in development**
2. **Clean up port forwarding when done**
3. **Set appropriate breakpoints to avoid performance issues**
4. **Use conditional breakpoints for production-like scenarios**
5. **Monitor resource usage during debugging sessions**
