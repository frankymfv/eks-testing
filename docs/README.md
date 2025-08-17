# Documentation

This directory contains comprehensive documentation for the EKS Testing Project.

## 📚 Guides

### 🚀 Getting Started
- **[KIND_GUIDE.md](KIND_GUIDE.md)** - Complete guide for setting up and using Kind cluster
  - Cluster creation and configuration
  - Ingress controller setup
  - Application deployment
  - Troubleshooting

### 🌐 Networking
- **[NETWORK_POLICIES_GUIDE.md](NETWORK_POLICIES_GUIDE.md)** - Network policy configuration and management
  - Understanding network policies
  - Policy creation and application
  - Testing connectivity
  - Security best practices

- **[INTERNET_ACCESS_GUIDE.md](INTERNET_ACCESS_GUIDE.md)** - Configuring internet access for services
  - Internet access options
  - Security considerations
  - Testing connectivity
  - Troubleshooting

- **[KUBERNETES_SERVICE_COMMUNICATION_GUIDE.md](KUBERNETES_SERVICE_COMMUNICATION_GUIDE.md)** - Service-to-service communication
  - How outbound traffic works
  - Service discovery
  - Network policy behavior
  - Practical examples

### 🧪 Testing
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Comprehensive testing strategies
  - Service testing
  - Network policy testing
  - Integration testing
  - Performance testing

## 📋 Quick Reference

### Common Commands
```bash
# Build and deploy
make redeploy-all

# Test services
make test-all

# Configure internet access
make apply-user-internet-access

# Check network policies
make network-policies-status
```

### Service Endpoints
- **Auth Service**: `http://auth-app-service:8124/`
- **User Service**: `http://user-app-service:80/`
- **Hello World**: `http://helloworld-app-service:8889/`

### Network Policy Types
- **Restricted**: HTTP/HTTPS only (ports 80, 443, 8080, 8443)
- **Full**: All outbound traffic allowed

## 🔗 Related Resources

- [Main README](../README.md) - Project overview and quick start
- [Makefile](../Makefile) - All available commands
- [Kubernetes Manifests](../k8s/) - Deployment configurations
- [Scripts](../scripts/) - Organized automation scripts

## 📝 Contributing to Documentation

When adding new documentation:

1. Create a new `.md` file in this directory
2. Add a link to it in this README
3. Update the main [README.md](../README.md) if needed
4. Follow the existing documentation style

## 🎯 Documentation Goals

- **Clarity**: Easy to understand and follow
- **Completeness**: Cover all aspects of the project
- **Practicality**: Include real examples and commands
- **Maintainability**: Keep documentation up to date
