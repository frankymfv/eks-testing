# Cluster Scripts

Scripts for managing Kubernetes clusters (Kind, EKS, etc.).

## 📁 Scripts

### `kind-commands.sh`
Collection of useful commands for managing Kind clusters.

**Usage:**
```bash
./scripts/cluster/kind-commands.sh
```

**What it provides:**
- Kind cluster creation and deletion
- Ingress controller setup
- Cluster status checking
- Resource cleanup
- Troubleshooting commands

### `kind-config.yaml`
Kind cluster configuration file.

**Usage:**
```bash
kind create cluster --config scripts/cluster/kind-config.yaml
```

**Configuration includes:**
- Cluster name and version
- Node configuration
- Port mappings
- Resource limits

## 🏗️ Quick Start

```bash
# Make scripts executable
chmod +x scripts/cluster/*.sh

# Create Kind cluster
kind create cluster --config scripts/cluster/kind-config.yaml

# Run cluster commands
./scripts/cluster/kind-commands.sh
```

## 📋 Cluster Management

### Creating Clusters
```bash
# Create Kind cluster
kind create cluster --config scripts/cluster/kind-config.yaml

# Create with custom name
kind create cluster --name my-cluster --config scripts/cluster/kind-config.yaml
```

### Managing Clusters
```bash
# List clusters
kind get clusters

# Switch context
kubectl cluster-info --context kind-my-cluster

# Delete cluster
kind delete cluster --name my-cluster
```

### Ingress Setup
```bash
# Install ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress to be ready
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
```

## 🔧 Configuration

### Kind Configuration Options
```yaml
# Basic configuration
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: eks-testing

# Node configuration
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
```

### Customization Options
- **Node count**: Add more worker nodes
- **Port mappings**: Map additional ports
- **Resource limits**: Adjust CPU/memory limits
- **Storage**: Configure persistent volumes

## 🐛 Troubleshooting

### Common Issues
1. **Port conflicts**: Check if ports 80/443 are in use
2. **Resource limits**: Ensure sufficient system resources
3. **Docker issues**: Verify Docker is running
4. **Network problems**: Check firewall settings

### Debug Commands
```bash
# Check cluster status
kind get clusters
kubectl cluster-info

# Check node status
kubectl get nodes
kubectl describe nodes

# Check system resources
docker system df
docker stats
```

### Reset Cluster
```bash
# Delete and recreate
kind delete cluster
kind create cluster --config scripts/cluster/kind-config.yaml

# Reset kubectl context
kubectl config use-context kind-kind
```

## 🔗 Related Resources

- [Main Scripts README](../README.md)
- [Kind Guide](../../docs/KIND_GUIDE.md)
- [Makefile](../../Makefile) - Alternative cluster commands
- [Official Kind Documentation](https://kind.sigs.k8s.io/)
