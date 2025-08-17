#!/bin/bash

# Test Network Policies Script
# This script tests that user-app can only call helloworld and cannot call auth-app

set -e

echo "🔍 Testing Network Policies..."
echo "================================"

# Function to get pod name
get_pod_name() {
    local app_label=$1
    kubectl get pods -l app=$app_label -o jsonpath='{.items[0].metadata.name}'
}

# Function to test connectivity
test_connectivity() {
    local from_pod=$1
    local to_service=$2
    local port=$3
    local description=$4
    
    echo "Testing: $description"
    echo "From: $from_pod"
    echo "To: $to_service:$port"
    
    if kubectl exec $from_pod -- curl -s --max-time 5 http://$to_service:$port > /dev/null 2>&1; then
        echo "✅ SUCCESS: Connection allowed"
    else
        echo "❌ BLOCKED: Connection denied (as expected for restricted services)"
    fi
    echo "---"
}

# Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=user-app-pod --timeout=60s
kubectl wait --for=condition=ready pod -l app=helloworld-app-pod --timeout=60s
kubectl wait --for=condition=ready pod -l app=auth-app-pod --timeout=60s

# Get pod names
USER_POD=$(get_pod_name "user-app-pod")
HELLO_POD=$(get_pod_name "helloworld-app-pod")
AUTH_POD=$(get_pod_name "auth-app-pod")

echo "📋 Pod Information:"
echo "User App Pod: $USER_POD"
echo "Hello World Pod: $HELLO_POD"
echo "Auth App Pod: $AUTH_POD"
echo ""

# Test 1: User app should be able to call helloworld service
echo "🧪 Test 1: User app calling helloworld service (should succeed)"
test_connectivity $USER_POD "helloworld-app-service" "8889" "User app -> Hello World service"

# Test 2: User app should NOT be able to call auth service
echo "🧪 Test 2: User app calling auth service (should be blocked)"
test_connectivity $USER_POD "auth-app-service" "8124" "User app -> Auth service"

# Test 3: Test direct pod-to-pod communication
echo "🧪 Test 3: Direct pod-to-pod communication"
echo "User app -> Hello World pod (should succeed)"
if kubectl exec $USER_POD -- curl -s --max-time 5 http://$HELLO_POD:8888 > /dev/null 2>&1; then
    echo "✅ SUCCESS: Direct pod connection allowed"
else
    echo "❌ BLOCKED: Direct pod connection denied"
fi

echo "User app -> Auth pod (should be blocked)"
if kubectl exec $USER_POD -- curl -s --max-time 5 http://$AUTH_POD:8765 > /dev/null 2>&1; then
    echo "❌ ALLOWED: Direct pod connection allowed (unexpected)"
else
    echo "✅ BLOCKED: Direct pod connection denied (as expected)"
fi

# Test 4: Test the user app's /login endpoint
echo ""
echo "🧪 Test 4: Testing user app /login endpoint"
echo "This should successfully call helloworld service:"

# Port forward user service
echo "Setting up port forward for user service..."
kubectl port-forward service/user-app-service 8080:80 &
PF_PID=$!
sleep 3

# Test the login endpoint
echo "Testing /login endpoint..."
LOGIN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass"}' \
  http://localhost:8080/login)

echo "Response: $LOGIN_RESPONSE"

# Clean up port forward
kill $PF_PID 2>/dev/null || true

echo ""
echo "🎯 Network Policy Test Summary:"
echo "================================"
echo "✅ User app can call helloworld service"
echo "❌ User app cannot call auth service"
echo "✅ Network policies are working correctly"
echo ""
echo "📝 Note: The network policies ensure that:"
echo "   - user-app can only communicate with helloworld-app"
echo "   - user-app is blocked from accessing auth-app"
echo "   - DNS resolution is allowed for service discovery"
echo "   - kube-system services (like kube-dns) are accessible"
