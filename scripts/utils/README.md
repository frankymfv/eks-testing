# Utility Scripts

General utility scripts for project maintenance and automation.

## 📁 Scripts

Currently, this directory is empty but ready for utility scripts.

## 🛠️ Suggested Utilities

### Potential Scripts to Add

#### `cleanup.sh`
Clean up resources and temporary files.

**Potential features:**
- Remove old Docker images
- Clean up Kubernetes resources
- Remove temporary files
- Reset cluster state

#### `backup.sh`
Backup important configurations and data.

**Potential features:**
- Backup Kubernetes manifests
- Export cluster configurations
- Save network policy settings
- Create deployment snapshots

#### `monitor.sh`
Monitor cluster and service health.

**Potential features:**
- Check pod status
- Monitor resource usage
- Test service connectivity
- Generate health reports

#### `setup-env.sh`
Set up development environment.

**Potential features:**
- Install required tools
- Configure kubectl
- Set up Docker
- Initialize project structure

## 🚀 Adding New Utilities

### Script Template
```bash
#!/bin/bash

# Script Name: your-script.sh
# Description: Brief description of what the script does
# Usage: ./scripts/utils/your-script.sh [options]

set -e  # Exit on error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Functions
function log_info() {
    echo "[INFO] $1"
}

function log_error() {
    echo "[ERROR] $1" >&2
}

function cleanup() {
    log_info "Cleaning up..."
    # Add cleanup logic here
}

# Main execution
function main() {
    log_info "Starting script execution..."
    
    # Add your script logic here
    
    log_info "Script completed successfully!"
}

# Trap cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"
```

### Making Scripts Executable
```bash
chmod +x scripts/utils/your-script.sh
```

## 📋 Utility Guidelines

### Best Practices
- **Error handling**: Include proper error checking
- **Logging**: Use consistent logging format
- **Documentation**: Include usage and examples
- **Portability**: Ensure cross-platform compatibility
- **Safety**: Include confirmation prompts for destructive operations

### Script Structure
1. **Header**: Script name, description, usage
2. **Configuration**: Variables and settings
3. **Functions**: Modular code organization
4. **Main execution**: Primary logic
5. **Cleanup**: Resource cleanup on exit

### Environment Variables
```bash
# Common environment variables
export PROJECT_ROOT="$(pwd)"
export KUBECONFIG="${HOME}/.kube/config"
export DOCKER_REGISTRY="hbc08"
export CLUSTER_NAME="eks-testing"
```

## 🔗 Related Resources

- [Main Scripts README](../README.md)
- [Makefile](../../Makefile) - Alternative utility commands
- [Documentation](../../docs/) - Project guides

## 📝 Contributing

When adding utility scripts:

1. **Follow the template** structure
2. **Include documentation** in the script header
3. **Add error handling** and logging
4. **Test thoroughly** before committing
5. **Update this README** with script description
