# 🔒 Network Policies Guide

This guide explains the network policies implemented to restrict service communication in your Kubernetes cluster.

## 📋 Overview

The network policies ensure that:
- **user-app** can only communicate with **helloworld-app**
- **user-app** is blocked from accessing **auth-app**
- All services can perform DNS resolution
- Ingress traffic is properly allowed

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  user-app   │    │ helloworld  │    │  auth-app   │
│             │    │    app      │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   │                   │
       └─────── ALLOWED ───┘                   │
                           │                   │
                           └─── BLOCKED ───────┘
```

## 📄 Network Policy Files

### 1. `k8s/user-app-network-policy.yaml`
**Purpose**: Restricts user-app outbound traffic

**Key Rules**:
- ✅ Allows DNS resolution (UDP port 53)
- ✅ Allows access to helloworld-app-pod (TCP port 8888)
- ✅ Allows access to kube-dns service
- ❌ **Implicitly blocks all other traffic** (including auth-app)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: user-app-network-policy
spec:
  podSelector:
    matchLabels:
      app: user-app-pod
  policyTypes:
  - Egress
  egress:
  # Allow DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # Allow access to helloworld service
  - to:
    - podSelector:
        matchLabels:
          app: helloworld-app-pod
    ports:
    - protocol: TCP
      port: 8888
```

### 2. `k8s/helloworld-network-policy.yaml`
**Purpose**: Controls incoming traffic to helloworld-app

**Key Rules**:
- ✅ Allows traffic from user-app-pod
- ✅ Allows traffic from ingress-nginx
- ✅ Allows traffic from kube-system (health checks)
- ✅ Allows DNS resolution

### 3. `k8s/auth-app-network-policy.yaml`
**Purpose**: Isolates auth-app from user-app

**Key Rules**:
- ✅ Allows traffic from ingress-nginx
- ✅ Allows traffic from kube-system (health checks)
- ❌ **Blocks traffic from user-app-pod**
- ✅ Allows DNS resolution

## 🔧 Implementation Details

### Container Tools Installation

All containers now include `curl` and `wget` for network testing and debugging:

```dockerfile
# Install curl and other useful tools
RUN apk add --no-cache curl wget
```

This allows you to:
- Test network connectivity between services
- Debug network policy issues
- Make HTTP requests from within containers
- Verify service endpoints

### Service Configuration Changes

1. **user-app Environment Variables**:
   ```yaml
   env:
   - name: HELLO_WORLD_SERVICE_URL
     value: "http://helloworld-app-service.default.svc.cluster.local:8889"
   ```

2. **user-app Code Changes**:
   - Modified `/login` endpoint to call helloworld service instead of auth service
   - Updated environment configuration to use `HELLO_WORLD_SERVICE_URL`

### Network Policy Behavior

**Default Deny**: Kubernetes network policies follow a "default deny" approach:
- If no egress rule matches, traffic is blocked
- If no ingress rule matches, traffic is blocked

**Explicit Allow**: Only explicitly defined rules allow traffic:
- DNS resolution is explicitly allowed
- Specific pod-to-pod communication is explicitly allowed
- Service-to-service communication follows pod selector rules

## 🧪 Testing Network Policies

### Manual Testing

1. **Test user-app → helloworld (should succeed)**:
   ```bash
   kubectl exec <user-pod> -- curl -s http://helloworld-app-service:8889
   ```

2. **Test user-app → auth-app (should fail)**:
   ```bash
   kubectl exec <user-pod> -- curl -s http://auth-app-service:8124
   ```

3. **Test user-app /login endpoint**:
   ```bash
   kubectl port-forward service/user-app-service 8080:80
   curl -X POST -H "Content-Type: application/json" \
     -d '{"username":"test","password":"test"}' \
     http://localhost:8080/login
   ```

### Automated Testing

Run the test script:
```bash
./test-network-policies.sh
```

This script will:
- Test all connectivity scenarios
- Verify network policies are working
- Show detailed results

## 🚀 Deployment

### Quick Deployment

Use the automated deployment script:
```bash
./deploy-with-network-policies.sh
```

### Manual Deployment

1. **Deploy services**:
   ```bash
   kubectl apply -f k8s/
   ```

2. **Apply network policies**:
   ```bash
   kubectl apply -f k8s/user-app-network-policy.yaml
   kubectl apply -f k8s/auth-app-network-policy.yaml
   kubectl apply -f k8s/helloworld-network-policy.yaml
   ```

3. **Test policies**:
   ```bash
   ./test-network-policies.sh
   ```

## 🔍 Monitoring and Debugging

### Check Network Policies

```bash
# List all network policies
kubectl get networkpolicies

# Describe specific policy
kubectl describe networkpolicy user-app-network-policy
```

### Check Pod Connectivity

```bash
# Test from user-app pod
kubectl exec -it <user-pod> -- curl -s http://helloworld-app-service:8889

# Test DNS resolution
kubectl exec -it <user-pod> -- nslookup helloworld-app-service

# Test curl installation
kubectl exec -it <user-pod> -- curl --version
```

### View Logs

```bash
# User app logs
kubectl logs -l app=user-app-pod

# Hello world logs
kubectl logs -l app=helloworld-app-pod

# Auth app logs
kubectl logs -l app=auth-app-pod
```

## 🐛 Troubleshooting

### Common Issues

1. **DNS Resolution Fails**:
   - Ensure kube-dns service is running
   - Check that DNS port 53 is allowed in network policies

2. **Service Discovery Issues**:
   - Verify service names and ports
   - Check that services are in the same namespace

3. **Network Policy Not Applied**:
   - Ensure CNI supports network policies (Calico, Weave, etc.)
   - Check policy syntax and labels

4. **Pod Labels Mismatch**:
   - Verify pod selector labels match actual pod labels
   - Check deployment labels

### Debug Commands

```bash
# Check if network policies are supported
kubectl get pods -n kube-system | grep -E "(calico|weave|flannel)"

# Test network connectivity
kubectl exec -it <pod> -- ping <service-name>

# Check iptables rules (if using Calico)
kubectl exec -it <pod> -- iptables -L
```

## 📚 Best Practices

1. **Principle of Least Privilege**: Only allow necessary traffic
2. **Explicit Rules**: Always define explicit allow rules
3. **DNS Access**: Always allow DNS resolution
4. **Health Checks**: Allow kube-system traffic for health checks
5. **Testing**: Always test network policies after deployment
6. **Documentation**: Document all network policy rules

## 🔄 Updating Network Policies

To modify network policies:

1. **Edit the policy file**:
   ```bash
   vim k8s/user-app-network-policy.yaml
   ```

2. **Apply the changes**:
   ```bash
   kubectl apply -f k8s/user-app-network-policy.yaml
   ```

3. **Test the changes**:
   ```bash
   ./test-network-policies.sh
   ```

## 📖 References

- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network Policy Examples](https://github.com/ahmetb/kubernetes-network-policy-recipes)
- [Calico Network Policy](https://docs.projectcalico.org/security/network-policy)

---

**Note**: This setup ensures secure communication between services while maintaining the required restrictions. Always test thoroughly after making changes to network policies.
