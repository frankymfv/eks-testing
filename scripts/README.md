# Scripts

This directory contains organized scripts for different aspects of the EKS Testing Project.

## 📁 Script Categories

### 🚀 Deployment Scripts (`deployment/`)
Scripts for deploying applications and managing Kubernetes resources.

### 🧪 Testing Scripts (`testing/`)
Scripts for testing services, network policies, and connectivity.

### 🏗️ Cluster Scripts (`cluster/`)
Scripts for managing Kubernetes clusters (Kind, EKS, etc.).

### 🛠️ Utility Scripts (`utils/`)
General utility scripts for project maintenance and automation.

## 📋 Quick Reference

### Common Script Usage
```bash
# Deploy with network policies
./scripts/deployment/deploy-with-network-policies.sh

# Test network policies
./scripts/testing/test-network-policies.sh

# Rebuild and test with curl
./scripts/testing/rebuild-with-curl.sh

# Kind cluster commands
./scripts/cluster/kind-commands.sh
```

### Script Permissions
Make scripts executable:
```bash
chmod +x scripts/**/*.sh
```

## 🔗 Related Resources

- [Main README](../README.md) - Project overview
- [Makefile](../Makefile) - Build and deployment commands
- [Documentation](../docs/) - Comprehensive guides

## 📝 Adding New Scripts

When adding new scripts:

1. **Choose the appropriate category**:
   - `deployment/` - For deployment and Kubernetes management
   - `testing/` - For testing and validation
   - `cluster/` - For cluster setup and management
   - `utils/` - For general utilities

2. **Update the category README** with script description

3. **Make the script executable**:
   ```bash
   chmod +x scripts/category/your-script.sh
   ```

4. **Update this README** if adding a new category

## 🎯 Script Guidelines

- **Descriptive names**: Use clear, descriptive filenames
- **Documentation**: Include comments and usage examples
- **Error handling**: Include proper error checking
- **Portability**: Ensure scripts work across different environments
- **Permissions**: Make scripts executable
