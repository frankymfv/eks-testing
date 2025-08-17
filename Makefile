# =============================================================================
# EKS Testing Project Makefile
# =============================================================================

# =============================================================================
# DOCKER IMAGE BUILDING
# =============================================================================

build-auth-app-image:
	docker build -t hbc08/k8s-auth-app:latest ./auth-app

build-user-app-image:
	docker build -t hbc08/k8s-user-app ./user-app

build-helloworld-image:
	docker build -t hbc08/k8s-helloworld ./helloworld

build-all: build-auth-app-image build-user-app-image build-helloworld-image

# =============================================================================
# DOCKER IMAGE PUSHING
# =============================================================================

push-auth-app-image:
	docker push hbc08/k8s-auth-app:latest

push-user-app-image:
	docker push hbc08/k8s-user-app

push-helloworld-image:
	docker push hbc08/k8s-helloworld

push-all: push-auth-app-image push-user-app-image push-helloworld-image

build-and-push-all: build-all push-auth-app-image push-user-app-image push-helloworld-image

# =============================================================================
# KUBERNETES DEPLOYMENT
# =============================================================================

# Redeploy all applications to Kubernetes
redeploy-all: build-and-push-all
	kubectl apply -k k8s/user/
	kubectl apply -k k8s/hello-world/
	@echo "All applications redeployed successfully!"

# Redeploy only the Kubernetes resources (without rebuilding images)
redeploy-k8s:
	kubectl apply -k k8s/user/
	kubectl apply -k k8s/hello-world/
	@echo "Kubernetes resources redeployed successfully!"

# Deploy specific namespaces
deploy-user-namespace:
	kubectl apply -k k8s/user/
	@echo "User namespace deployed successfully!"

deploy-hello-world-namespace:
	kubectl apply -k k8s/hello-world/
	@echo "Hello World namespace deployed successfully!"

# Force Kubernetes to pull new images by restarting deployments
pull-new-images:
	kubectl rollout restart deployment/auth-app-deployment -n user
	kubectl rollout restart deployment/user-app-deployment -n user
	kubectl rollout restart deployment/helloworld-app-deployment -n user
	kubectl rollout restart deployment/helloworld-app-deployment -n hello-world
	@echo "Deployments restarted to pull new images!"

# Redeploy all with image pull
redeploy-all-with-pull: build-and-push-all pull-new-images
	kubectl apply -k k8s/user/
	kubectl apply -k k8s/hello-world/
	@echo "All applications redeployed with new images!"

# =============================================================================
# NETWORK POLICIES
# =============================================================================

# Apply network policy with restricted internet access (HTTP/HTTPS only)
apply-user-restricted-internet:
	@echo "Applying network policy with restricted internet access for user service..."
	kubectl apply -f k8s/user-app-network-policy.yaml
	@echo "User service has restricted internet access (HTTP/HTTPS only)!"

# Apply network policy with full internet access
apply-user-internet-access:
	@echo "Applying network policy with full internet access for user service..."
	kubectl apply -f k8s/user-app-network-policy.yaml
	@echo "User service now has internet access!"

# Check network policy status
network-policies-status:
	@echo "=== Current Network Policies ==="
	kubectl get networkpolicies
	@echo ""
	@echo "=== Network Policy Details ==="
	kubectl describe networkpolicy user-app-network-policy
	@echo ""
	kubectl describe networkpolicy auth-app-network-policy
	@echo ""
	kubectl describe networkpolicy helloworld-network-policy

# =============================================================================
# SERVICE TESTING
# =============================================================================

# Test service communication with curl commands
test-services:
	@echo "=== Testing Xinchao Service (Hello World Namespace) ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://xinchao-app-service.hello-world:8889/ | jq .
	@echo ""
	@echo "=== Testing Auth Service ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://auth-app-service.user:8124/ | jq .
	@echo ""
	@echo "=== Testing User Service ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://user-app-service.user:80/ | jq .

# Test service-to-service communication
test-service-communication:
	@echo "=== Testing User Service calling Xinchao Service (Cross Namespace) ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -X POST -H "Content-Type: application/json" -d '{"username":"testuser","password":"testpass"}' http://user-app-service.user:80/login | jq .

# Test auth service endpoints
test-auth:
	@echo "=== Testing Auth Service Info ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://auth-app-service.user:8124/ | jq .
	@echo ""
	@echo "=== Testing Auth Service Authentication ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -X POST -H "Content-Type: application/json" -d '{"username":"user1","password":"password1"}' http://auth-app-service.user:8124/authenticate | jq .

# Test user service endpoints
test-user:
	@echo "=== Testing User Service Info ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://user-app-service.user:80/ | jq .
	@echo ""
	@echo "=== Testing User Service - Get Users ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://user-app-service.user:80/users | jq .
	@echo ""
	@echo "=== Testing User Service - Create User ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -X POST -H "Content-Type: application/json" -d '{"username":"newuser","email":"newuser@example.com","password":"newpass"}' http://user-app-service.user:80/create | jq .
	@echo ""
	@echo "=== Testing User Service - Login (calls Xinchao Service) ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -X POST -H "Content-Type: application/json" -d '{"username":"testuser","password":"testpass"}' http://user-app-service.user:80/login | jq .

# Test xinchao service
test-xinchao:
	@echo "=== Testing Xinchao Service (Hello World Namespace) ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://xinchao-app-service.hello-world:8889/ | jq .

# Test all services in sequence
test-all: test-xinchao test-auth test-user

# Test internet access for user service
test-user-internet-access:
	@echo "=== Testing User Service Internet Access ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s https://httpbin.org/ip | jq .
	@echo ""
	@echo "=== Testing User Service DNS Resolution ==="
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s https://google.com --max-time 5 || echo "Connection test completed"

# =============================================================================
# UTILITIES
# =============================================================================

# Legacy command (keeping for compatibility)
build-and-push-auth-app-image:
	docker build -t ./auth_app .
	docker tag auth_app $(DOCKER_USERNAME)/auth_app
	docker push $(DOCKER_USERNAME)/auth_app

# Docker compose
docker-compose-up:
	docker-compose up -d

# =============================================================================
# HELP
# =============================================================================

help:
	@echo "EKS Testing Project - Available Commands"
	@echo ""
	@echo "DOCKER IMAGE BUILDING:"
	@echo "  build-auth-app-image     - Build auth app Docker image"
	@echo "  build-user-app-image     - Build user app Docker image"
	@echo "  build-helloworld-image   - Build hello world Docker image"
	@echo "  build-all                - Build all Docker images"
	@echo ""
	@echo "DOCKER IMAGE PUSHING:"
	@echo "  push-auth-app-image      - Push auth app image to registry"
	@echo "  push-user-app-image      - Push user app image to registry"
	@echo "  push-helloworld-image    - Push hello world image to registry"
	@echo "  push-all                 - Push all images to registry"
	@echo "  build-and-push-all       - Build and push all images"
	@echo ""
	@echo "KUBERNETES DEPLOYMENT:"
	@echo "  redeploy-all             - Build, push, and deploy all namespaces"
	@echo "  redeploy-k8s             - Deploy only Kubernetes resources"
	@echo "  deploy-user-namespace    - Deploy user namespace only"
	@echo "  deploy-hello-world-namespace - Deploy hello-world namespace only"
	@echo "  pull-new-images          - Force Kubernetes to pull new images"
	@echo "  redeploy-all-with-pull   - Build, push, pull, and deploy"
	@echo ""
	@echo "NETWORK POLICIES:"
	@echo "  apply-user-restricted-internet - Apply restricted internet access"
	@echo "  apply-user-internet-access     - Apply full internet access"
	@echo "  network-policies-status        - Check network policy status"
	@echo ""
	@echo "SERVICE TESTING:"
	@echo "  test-services            - Test all services"
	@echo "  test-service-communication - Test service-to-service communication"
	@echo "  test-auth                - Test auth service endpoints"
	@echo "  test-user                - Test user service endpoints"
	@echo "  test-xinchao             - Test xinchao service"
	@echo "  test-all                 - Test all services in sequence"
	@echo "  test-user-internet-access - Test user service internet access"
	@echo ""
	@echo "UTILITIES:"
	@echo "  docker-compose-up        - Start Docker Compose services"
	@echo "  help                     - Show this help message"

.PHONY: help
