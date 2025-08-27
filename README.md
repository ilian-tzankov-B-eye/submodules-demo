# FastAPI Microservices Example

This project demonstrates two FastAPI services that communicate with each other, plus a web dashboard for testing and monitoring.

The two services and web app can run either locally (all 3 on the same IP address pn different ports), or in 3 separate pods in
K8s. When running in K8s service discovery is used to get the correct pod.

## Services Overview

### Service 1 (User Management Service) - Port 8000
- **Purpose**: Manages user data and provides CRUD operations
- **Features**:
  - Create, read, and delete users
  - Store user information (name, email, age)
  - Automatically sends user data to Service 2 for processing
  - Retrieves processed data from Service 2

### Service 2 (Data Processing Service) - Port 8001
- **Purpose**: Processes user data and provides analytics
- **Features**:
  - Processes user data (calculates name length, email domain, age categories, etc.)
  - Provides analytics and statistics
  - Stores processed user data
  - Cross-service communication testing

### Test Dashboard (Web Application) - Port 8002
- **Purpose**: Web interface for testing and monitoring the microservices
- **Features**:
  - Real-time service health monitoring
  - Interactive test execution
  - Visual results display
  - User data and analytics viewing
  - Modern responsive UI

## API Endpoints

### Service 1 (http://localhost:8000)

- `GET /` - Service status
- `GET /health` - Health check
- `POST /users` - Create a new user
- `GET /users` - Get all users
- `GET /users/{user_id}` - Get specific user
- `GET /users/{user_id}/processed` - Get user with processed data from Service 2
- `DELETE /users/{user_id}` - Delete user

### Service 2 (http://localhost:8001)

- `GET /` - Service status
- `GET /health` - Health check
- `POST /process-user` - Process user data
- `GET /processed-users/{user_id}` - Get processed user data
- `GET /processed-users` - Get all processed users
- `DELETE /processed-users/{user_id}` - Delete processed user data
- `GET /analytics` - Get analytics summary
- `GET /cross-service-test` - Test communication with Service 1
- `POST /batch-process` - Process all users from Service 1

### Test Dashboard (http://localhost:8002)

- `GET /` - Main dashboard page
- `POST /api/run-tests` - Run all tests
- `GET /api/health` - Quick health check
- `GET /api/users` - Get all users from Service 1
- `GET /api/analytics` - Get analytics from Service 2

## Testing the Services

### 1. Create a user (Service 1)
```bash
curl -X POST "http://localhost:8000/users" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "John Doe",
       "email": "john@example.com",
       "age": 30
     }'
```

### 2. Get all users (Service 1)
```bash
curl "http://localhost:8000/users"
```

### 3. Get processed user data (Service 1)
```bash
curl "http://localhost:8000/users/1/processed"
```

### 4. Get analytics (Service 2)
```bash
curl "http://localhost:8001/analytics"
```

### 5. Test cross-service communication (Service 2)
```bash
curl "http://localhost:8001/cross-service-test"
```

## Interactive API Documentation

Once the services are running, you can access the interactive API documentation:

- **Service 1**: http://localhost:8000/docs
- **Service 2**: http://localhost:8001/docs
- **Test Dashboard**: http://localhost:8002 (Web interface)

## Example Workflow

1. Start both services (and optionally the test dashboard)
2. Create a user via Service 1 (automatically triggers processing in Service 2)
3. View the user's processed data via Service 1
4. Check analytics via Service 2
5. Test cross-service communication
6. Use the web dashboard for interactive testing and monitoring

## Architecture

```
┌─────────────────┐    HTTP Requests    ┌───────────────────┐
│   Service 1     │◄───────────────────►│   Service 2       │
│ (Port 8000)     │                     │ (Port 8001)       │
│                 │                     │                   │
│ - User CRUD     │                     │ - Data Processing │
│ - User Storage  │                     │ - Analytics       │
│ - Service2 Sync │                     │ - Cross-service   │
└─────────────────┘                     └───────────────────┘
         ▲                                       ▲
         │                                       │
         │ HTTP Requests                         │
         │                                       │
    ┌─────────────────┐                          │
    │  Test Dashboard │──────────────────────────┘
    │  (Port 8002)    │
    │                 │
    │ - Web Interface │
    │ - Test Runner   │
    │ - Monitoring    │
    └─────────────────┘
```

## Error Handling

Both services include comprehensive error handling:
- HTTP status codes for different error scenarios
- Graceful handling of service communication failures
- Timeout for web service calls
- Input validation using Pydantic models
- Proper error messages and logging

## 🐳 Docker & Kubernetes Deployment

The services can be deployed using Docker and Kubernetes:

### K8s Quick Start
```bash
# Build Docker images
./build-images.sh

# Setup local Kubernetes cluster (if needed)
./setup-k8s.sh

# Deploy to Kubernetes (choose one):
./deploy-k8s.sh          # Standard deployment

# Clean up when done:
./cleanup-k8s.sh         # Interactive cleanup
./cleanup-k8s-quick.sh   # Quick cleanup (no prompts)

# Monitor logs:
./k8s-logs.sh            # View logs from all services
./k8s-logs.sh service1   # View logs from specific service
```

### Troubleshooting Kubernetes Issues

If you get errors like "connection refused" or "failed to download openapi":

1. **No Kubernetes cluster running**:
   ```bash
   ./setup-k8s-local.sh
   ```

2. **Images not found**:
   ```bash
   ./prepare-k8s-images.sh
   ```

3. **Validation errors**:
   ```bash
   kubectl apply -f k8s/ --validate=false
   ```

4. **Use local deployment** (recommended for development):
   ```bash
   ./deploy-k8s-local.sh
   ```

5. **Clean up resources**:
   ```bash
   ./cleanup-k8s.sh         # Interactive cleanup
   ./cleanup-k8s-quick.sh   # Quick cleanup
   ```

6. **Monitor logs**:
   ```bash
   ./k8s-logs.sh            # View logs from all services
   ./k8s-logs.sh service1   # View logs from specific service
   ./k8s-logs.sh -f webapp  # Follow logs in real-time
   ```

### Detailed Instructions
See [KUBERNETES.md](KUBERNETES.md) for complete deployment guide.

### Docker Images
- `microservices-demo/service1:latest` - User Management Service
- `microservices-demo/service2:latest` - Data Processing Service  
- `microservices-demo/webapp:latest`   - Test Dashboard

# Running K8s in a Dev Container
## Initial setup
To be able to run K8s in your Dev Container you need to enable docker-in-docker and Kubernetes features.
Add the following to your devcontainer.json:
```
"features": {
		"ghcr.io/devcontainers/features/docker-in-docker:2": {
			"enableNonRootDocker": "true",
			"moby": "true"
		},

		"ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {
			"version": "latest",
			"helm": "latest",
			"minikube": "latest"
		}
	 }
```
Rebuild the container and use the provided script to validate your setup and prodide instructions on how to
setup your K8s cluster inside the container:
```bash
./setup-k8s-local.sh
```
Follow the provided instructions. Minikube is recommended.

### Note on running as root (VScode vs Cursor)
The Minikube Docker driver does not support running as root. Cursor defaults to connecting to the dev-container
as root. This will not work. Minikube will fail to start. 

VSCode logs into the dev-container as user vscode. And thus is fully compatible. 

To get things going in Cursor. Create a vscode if it does not exist (this command must me started as root):
```bash
grep vscode /etc/passwd || useradd -m vscode && (echo "vscode ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/vscode)
```

Switch to the new user:
```bash
su -l vscode
```

You can also modify your devcontainer.json to change the default user. Uncomment the following line and change the 
user to vscode or whatever you wish:
```
"remoteUser": "root"
```