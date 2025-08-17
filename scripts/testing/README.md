# Testing Scripts

Scripts for testing services, network policies, and connectivity.

## 📁 Scripts

### `test-network-policies.sh`
Comprehensive testing of network policies and service connectivity.

**Usage:**
```bash
./scripts/testing/test-network-policies.sh
```

**What it tests:**
- Service-to-service communication
- Network policy enforcement
- DNS resolution
- External connectivity
- Ingress functionality

### `rebuild-with-curl.sh`
Rebuilds applications and tests them with curl commands.

**Usage:**
```bash
./scripts/testing/rebuild-with-curl.sh
```

**What it does:**
- Builds and pushes Docker images
- Deploys to Kubernetes
- Tests all services with curl
- Validates network policies

## 🧪 Quick Start

```bash
# Make scripts executable
chmod +x scripts/testing/*.sh

# Test network policies
./scripts/testing/test-network-policies.sh

# Rebuild and test
./scripts/testing/rebuild-with-curl.sh
```

## 📋 Testing Scenarios

### Network Policy Testing
- **Auth Service**: Tests ingress from ingress controller
- **User Service**: Tests egress to hello world service
- **Hello World**: Tests ingress from user service
- **DNS Resolution**: Tests kube-dns connectivity
- **External Access**: Tests internet connectivity (if enabled)

### Service Testing
- **Health Checks**: Basic service responsiveness
- **API Endpoints**: Specific endpoint functionality
- **Service Communication**: Inter-service calls
- **Error Handling**: Invalid request handling

## 🔧 Test Configuration

### Environment Variables
```bash
# Set test parameters
export TEST_TIMEOUT=30
export TEST_RETRIES=3
export VERBOSE=true
```

### Custom Test Cases
You can add custom test cases by:
1. Adding new test functions to the script
2. Modifying existing test parameters
3. Creating test-specific network policies

## 📊 Test Results

### Success Indicators
- ✅ All services responding
- ✅ Network policies working correctly
- ✅ Service communication established
- ✅ DNS resolution functional

### Failure Indicators
- ❌ Services not responding
- ❌ Network policies blocking traffic
- ❌ DNS resolution failing
- ❌ External connectivity issues

## 🐛 Troubleshooting

### Common Test Failures
1. **Service not ready**: Wait for deployments to be ready
2. **Network policy blocking**: Check policy configurations
3. **DNS issues**: Verify kube-dns is running
4. **Image pull errors**: Ensure images are available

### Debug Commands
```bash
# Check service status
kubectl get pods
kubectl get services

# Test manual connectivity
kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://auth-app-service:8124/

# Check network policies
kubectl get networkpolicies
kubectl describe networkpolicy user-app-network-policy
```

## 🔗 Related Resources

- [Main Scripts README](../README.md)
- [Testing Guide](../../docs/TESTING_GUIDE.md)
- [Network Policies Guide](../../docs/NETWORK_POLICIES_GUIDE.md)
- [Makefile](../../Makefile) - Alternative testing commands
