# Deployment Scripts

Scripts for deploying applications and managing Kubernetes resources.

## 📁 Scripts

### `deploy-with-network-policies.sh`
Deploys all applications with network policies applied.

**Usage:**
```bash
./scripts/deployment/deploy-with-network-policies.sh
```

**What it does:**
- Deploys auth, user, and hello world services
- Applies network policies for security
- Sets up ingress controller
- Configures service communication

**Prerequisites:**
- Kubernetes cluster running
- kubectl configured
- Docker images built and pushed

## 🚀 Quick Start

```bash
# Make script executable
chmod +x scripts/deployment/deploy-with-network-policies.sh

# Run deployment
./scripts/deployment/deploy-with-network-policies.sh
```

## 🔧 Customization

You can modify the deployment script to:
- Change image tags
- Adjust resource limits
- Modify network policy rules
- Add additional services

## 📋 Deployment Order

The script deploys resources in this order:
1. Deployments (auth, user, hello world)
2. Services
3. Ingress
4. Network policies

## 🐛 Troubleshooting

### Common Issues
1. **Images not found**: Ensure images are built and pushed
2. **Network policies blocking traffic**: Check policy configurations
3. **Services not responding**: Verify deployments are ready

### Debug Commands
```bash
# Check deployment status
kubectl get deployments

# Check service endpoints
kubectl get endpoints

# Check network policies
kubectl get networkpolicies

# View deployment logs
kubectl logs deployment/auth-app-deployment
```

## 🔗 Related Resources

- [Main Scripts README](../README.md)
- [Network Policies Guide](../../docs/NETWORK_POLICIES_GUIDE.md)
- [Makefile](../../Makefile) - Alternative deployment commands
