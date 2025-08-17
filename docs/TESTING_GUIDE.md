# 🧪 Application Testing Guide

This guide shows you how to test all the applications running in your Kind Kubernetes cluster.

## 📋 Prerequisites

- Kind cluster running (`eks-testing`)
- All services deployed and running
- `jq` installed for JSON formatting (optional but recommended)

## 🚀 Quick Testing

Use the helper script for quick testing:

```bash
# Test all services at once
./kind-commands.sh test

# Check cluster status
./kind-commands.sh status

# View logs for debugging
./kind-commands.sh logs auth-app
./kind-commands.sh logs user-app
./kind-commands.sh logs helloworld
```

## 🔍 Detailed Testing

### 1. Hello World Service

**Port Forward:**
```bash
kubectl port-forward service/helloworld-app-service 8080:8889
```

**Test Info Endpoint:**
```bash
curl -s http://localhost:8080 | jq .
```

**Expected Response:**
```json
{
  "client_ip": "127.0.0.1",
  "hostname": "helloworld-app-deployment-xxx",
  "os": "Unknown",
  "api_version": "3.3",
  "service_name": "Hello World"
}
```

### 2. Authentication Service

**Port Forward:**
```bash
kubectl port-forward service/auth-app-service 8081:8124
```

**Test Info Endpoint:**
```bash
curl -s http://localhost:8081 | jq .
```

**Test Authentication:**
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"password1"}' \
  http://localhost:8081/authenticate | jq .
```

**Expected Response:**
```json
{
  "message": "Authentication successful",
  "token": "token_for_user1_auth-app-deployment-xxx_3.0"
}
```

### 3. User Service

**Port Forward:**
```bash
kubectl port-forward service/user-app-service 8082:80
```

**Test Info Endpoint:**
```bash
curl -s http://localhost:8082 | jq .
```

**Create a New User:**
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"testpass"}' \
  http://localhost:8082/create | jq .
```

**List All Users:**
```bash
curl -s http://localhost:8082/users | jq .
```

**Login (uses Auth Service):**
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"password1"}' \
  http://localhost:8082/login | jq .
```

## 🔗 Service Communication Testing

### Test User Service → Auth Service Communication

The User Service communicates with the Auth Service for authentication. You can verify this by:

1. **Check User Service logs:**
```bash
kubectl logs -l app=user-app-pod --tail=20
```

2. **Test login flow:**
```bash
# Start port-forward for both services
kubectl port-forward service/user-app-service 8082:80 &
kubectl port-forward service/auth-app-service 8081:8124 &

# Test login (this will trigger communication between services)
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"password1"}' \
  http://localhost:8082/login | jq .
```

## 🌐 Ingress Testing

Test the Hello World service through the ingress:

```bash
curl -H "Host: hello-world.example" http://localhost
```

## 📊 Load Testing

### Test Multiple Requests

**Hello World Service:**
```bash
for i in {1..5}; do
  curl -s http://localhost:8080 | jq -r '.hostname'
done
```

**Auth Service:**
```bash
for i in {1..3}; do
  curl -X POST -H "Content-Type: application/json" \
    -d '{"username":"user1","password":"password1"}' \
    http://localhost:8081/authenticate | jq -r '.token'
done
```

## 🐛 Debugging

### Check Pod Status
```bash
kubectl get pods
kubectl describe pod <pod-name>
```

### Check Service Status
```bash
kubectl get services
kubectl describe service <service-name>
```

### Check Logs
```bash
# All pods for a service
kubectl logs -l app=auth-app-pod --tail=50

# Specific pod
kubectl logs <pod-name> --tail=50

# Follow logs in real-time
kubectl logs -f <pod-name>
```

### Check Network Connectivity
```bash
# Test service-to-service communication
kubectl exec -it <user-pod-name> -- wget -qO- http://auth-app-service:8124
```

## 🧹 Cleanup

**Stop port-forwarding:**
```bash
pkill -f "kubectl port-forward"
```

**Or use the helper script:**
```bash
./kind-commands.sh cleanup
```

## 📝 Test Scenarios

### Scenario 1: Complete User Registration Flow
1. Create a new user via User Service
2. Verify user appears in user list
3. Login with the new user (should fail as auth service has hardcoded users)
4. Login with existing user (user1/password1)

### Scenario 2: Service Discovery
1. Check that User Service can communicate with Auth Service
2. Verify load balancing across multiple pods
3. Test service resilience by scaling deployments

### Scenario 3: Ingress Functionality
1. Test Hello World service through ingress
2. Verify proper host header handling
3. Test with different paths

## 🔧 Troubleshooting

### Common Issues:

1. **Port already in use:**
   ```bash
   lsof -i :8080  # Check what's using the port
   pkill -f "kubectl port-forward"  # Kill existing port-forwards
   ```

2. **Service not responding:**
   ```bash
   kubectl get pods  # Check if pods are running
   kubectl logs <pod-name>  # Check for errors
   ```

3. **Network connectivity issues:**
   ```bash
   kubectl exec -it <pod-name> -- nslookup auth-app-service
   kubectl exec -it <pod-name> -- wget -qO- http://auth-app-service:8124
   ```

### Performance Testing:

```bash
# Test response times
time curl -s http://localhost:8080 > /dev/null

# Concurrent requests
for i in {1..10}; do
  curl -s http://localhost:8080 > /dev/null &
done
wait
```

This testing guide covers all the functionality of your applications. Use the helper script for quick tests and the detailed commands for thorough testing and debugging.
