#!/bin/bash

# Kind Cluster Management Script for EKS Testing Project

echo "=== EKS Testing Kind Cluster Management ==="
echo ""

case "$1" in
    "status")
        echo "📊 Cluster Status:"
        kubectl get pods,services,ingress
        echo ""
        echo "🌐 Ingress Controller:"
        kubectl get pods -n ingress-nginx
        ;;
    "logs")
        if [ -z "$2" ]; then
            echo "Usage: $0 logs <service-name>"
            echo "Available services: auth-app, user-app, helloworld"
            exit 1
        fi
        case "$2" in
            "auth-app")
                kubectl logs -l app=auth-app-pod --tail=50
                ;;
            "user-app")
                kubectl logs -l app=user-app-pod --tail=50
                ;;
            "helloworld")
                kubectl logs -l app=helloworld-app-pod --tail=50
                ;;
            *)
                echo "Unknown service: $2"
                ;;
        esac
        ;;
    "test")
        echo "🧪 Testing Services:"
        echo ""
        echo "1. Hello World Service:"
        kubectl port-forward service/helloworld-app-service 8080:8889 &
        sleep 2
        curl -s http://localhost:8080 | jq .
        pkill -f "port-forward.*helloworld"
        echo ""
        echo "2. Auth Service:"
        kubectl port-forward service/auth-app-service 8081:8124 &
        sleep 2
        curl -s http://localhost:8081 | jq .
        pkill -f "port-forward.*auth"
        echo ""
        echo "3. User Service:"
        kubectl port-forward service/user-app-service 8082:80 &
        sleep 2
        curl -s http://localhost:8082 | jq .
        pkill -f "port-forward.*user"
        ;;
    "cleanup")
        echo "🧹 Cleaning up port-forward processes..."
        pkill -f "kubectl port-forward" || true
        ;;
    "delete")
        echo "🗑️  Deleting Kind cluster..."
        kind delete cluster --name eks-testing
        ;;
    "rebuild")
        echo "🔨 Rebuilding and redeploying..."
        make build-all
        kind load docker-image hbc08/k8s-auth-app:latest --name eks-testing
        kind load docker-image hbc08/k8s-user-app:latest --name eks-testing
        kind load docker-image hbc08/k8s-helloworld:latest --name eks-testing
        kubectl rollout restart deployment auth-app-deployment
        kubectl rollout restart deployment user-app-deployment
        kubectl rollout restart deployment helloworld-app-deployment
        ;;
    *)
        echo "Usage: $0 {status|logs|test|cleanup|delete|rebuild}"
        echo ""
        echo "Commands:"
        echo "  status   - Show cluster status"
        echo "  logs     - Show logs for a service (auth-app|user-app|helloworld)"
        echo "  test     - Test all services"
        echo "  cleanup  - Clean up port-forward processes"
        echo "  delete   - Delete the Kind cluster"
        echo "  rebuild  - Rebuild images and redeploy"
        echo ""
        echo "Manual port-forward commands:"
        echo "  kubectl port-forward service/helloworld-app-service 8080:8889"
        echo "  kubectl port-forward service/auth-app-service 8081:8124"
        echo "  kubectl port-forward service/user-app-service 8082:80"
        ;;
esac
