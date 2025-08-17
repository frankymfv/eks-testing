#!/bin/bash

# Deploy with Network Policies Script
# This script builds, deploys all services and applies network policies

set -e

echo "🚀 Deploying with Network Policies..."
echo "====================================="

# Check if kind cluster exists
if ! kind get clusters | grep -q "eks-testing"; then
    echo "❌ Kind cluster 'eks-testing' not found. Please create it first:"
    echo "   kind create cluster --name eks-testing --config kind-config.yaml"
    exit 1
fi

# Set kubectl context
kubectl cluster-info --context kind-eks-testing

# Build all images
echo "🔨 Building Docker images..."
make build-all

# Load images into kind cluster
echo "📦 Loading images into Kind cluster..."
kind load docker-image hbc08/k8s-auth-app:latest --name eks-testing
kind load docker-image hbc08/k8s-user-app:latest --name eks-testing
kind load docker-image hbc08/k8s-helloworld:latest --name eks-testing

# Deploy all services
echo "📋 Deploying services..."
kubectl apply -f k8s/auth-deployment.yaml
kubectl apply -f k8s/auth-service.yaml
kubectl apply -f k8s/user-deployment.yaml
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/hello-deployment.yaml
kubectl apply -f k8s/hello-service.yaml
kubectl apply -f k8s/hello-ingress.yaml

# Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=auth-app-pod --timeout=60s
kubectl wait --for=condition=ready pod -l app=user-app-pod --timeout=60s
kubectl wait --for=condition=ready pod -l app=helloworld-app-pod --timeout=60s

# Apply network policies
echo "🔒 Applying network policies..."
kubectl apply -f k8s/user-app-network-policy.yaml
kubectl apply -f k8s/auth-app-network-policy.yaml
kubectl apply -f k8s/helloworld-network-policy.yaml

# Wait a moment for policies to take effect
echo "⏳ Waiting for network policies to take effect..."
sleep 10

# Show deployment status
echo "📊 Deployment Status:"
echo "====================="
kubectl get pods
echo ""
kubectl get services
echo ""
kubectl get networkpolicies
echo ""

# Test the deployment
echo "🧪 Testing deployment..."
./test-network-policies.sh

echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "📝 Next steps:"
echo "   - Run './test-network-policies.sh' to test network policies"
echo "   - Use 'kubectl port-forward' to access services"
echo "   - Check logs with 'kubectl logs <pod-name>'"
echo ""
echo "🔗 Service URLs:"
echo "   - Hello World: kubectl port-forward service/helloworld-app-service 8080:8889"
echo "   - User App: kubectl port-forward service/user-app-service 8081:80"
echo "   - Auth App: kubectl port-forward service/auth-app-service 8082:8124"
