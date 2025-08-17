#!/bin/bash

# Rebuild with Curl Script
# This script rebuilds all containers with curl installed and redeploys them

set -e

echo "🔨 Rebuilding containers with curl installed..."
echo "=============================================="

# Check if kind cluster exists
if ! kind get clusters | grep -q "eks-testing"; then
    echo "❌ Kind cluster 'eks-testing' not found. Please create it first:"
    echo "   kind create cluster --name eks-testing --config kind-config.yaml"
    exit 1
fi

# Build all images with curl
echo "🔨 Building Docker images with curl..."
make build-all

# Load images into kind cluster
echo "📦 Loading images into Kind cluster..."
kind load docker-image hbc08/k8s-auth-app:latest --name eks-testing
kind load docker-image hbc08/k8s-user-app:latest --name eks-testing
kind load docker-image hbc08/k8s-helloworld:latest --name eks-testing

# Restart deployments to use new images
echo "🔄 Restarting deployments..."
kubectl rollout restart deployment auth-app-deployment
kubectl rollout restart deployment user-app-deployment
kubectl rollout restart deployment hello-deployment

# Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=auth-app-pod --timeout=60s
kubectl wait --for=condition=ready pod -l app=user-app-pod --timeout=60s
kubectl wait --for=condition=ready pod -l app=helloworld-app-pod --timeout=60s

# Test curl installation
echo "🧪 Testing curl installation..."
echo ""

# Get pod names
USER_POD=$(kubectl get pods -l app=user-app-pod -o jsonpath='{.items[0].metadata.name}')
HELLO_POD=$(kubectl get pods -l app=helloworld-app-pod -o jsonpath='{.items[0].metadata.name}')
AUTH_POD=$(kubectl get pods -l app=auth-app-pod -o jsonpath='{.items[0].metadata.name}')

echo "📋 Testing curl in each container:"
echo "=================================="

echo "1. Testing curl in user-app pod ($USER_POD):"
if kubectl exec $USER_POD -- curl --version > /dev/null 2>&1; then
    echo "   ✅ curl is installed"
else
    echo "   ❌ curl is not installed"
fi

echo "2. Testing curl in helloworld pod ($HELLO_POD):"
if kubectl exec $HELLO_POD -- curl --version > /dev/null 2>&1; then
    echo "   ✅ curl is installed"
else
    echo "   ❌ curl is not installed"
fi

echo "3. Testing curl in auth-app pod ($AUTH_POD):"
if kubectl exec $AUTH_POD -- curl --version > /dev/null 2>&1; then
    echo "   ✅ curl is installed"
else
    echo "   ❌ curl is not installed"
fi

echo ""
echo "🔍 Testing network connectivity with curl:"
echo "=========================================="

# Test user-app to helloworld (should succeed)
echo "Testing user-app -> helloworld (should succeed):"
if kubectl exec $USER_POD -- curl -s --max-time 5 http://helloworld-app-service:8889 > /dev/null 2>&1; then
    echo "   ✅ Connection successful"
else
    echo "   ❌ Connection failed"
fi

# Test user-app to auth-app (should fail due to network policy)
echo "Testing user-app -> auth-app (should be blocked):"
if kubectl exec $USER_POD -- curl -s --max-time 5 http://auth-app-service:8124 > /dev/null 2>&1; then
    echo "   ❌ Connection successful (unexpected - network policy not working)"
else
    echo "   ✅ Connection blocked (as expected)"
fi

echo ""
echo "✅ Rebuild completed successfully!"
echo ""
echo "📝 Curl is now available in all containers for:"
echo "   - Testing network connectivity"
echo "   - Making HTTP requests between services"
echo "   - Debugging network policies"
echo ""
echo "🧪 Run './test-network-policies.sh' to perform comprehensive testing"
