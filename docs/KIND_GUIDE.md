# 🐳 Hướng Dẫn Sử Dụng Kind (Kubernetes in Docker)

Tài liệu này hướng dẫn chi tiết cách sử dụng Kind để triển khai và quản lý dự án Kubernetes của bạn.

## 📋 Mục Lục

1. [Giới Thiệu về Kind](#giới-thiệu-về-kind)
2. [Cài Đặt và Thiết Lập](#cài-đặt-và-thiết-lập)
3. [Tạo và Quản Lý Cluster](#tạo-và-quản-lý-cluster)
4. [Triển Khai Ứng Dụng](#triển-khai-ứng-dụng)
5. [Kiểm Tra và Debug](#kiểm-tra-và-debug)
6. [Quản Lý Cluster](#quản-lý-cluster)
7. [Troubleshooting](#troubleshooting)

## 🎯 Giới Thiệu về Kind

**Kind (Kubernetes in Docker)** là một công cụ cho phép bạn chạy Kubernetes cluster cục bộ bằng cách sử dụng Docker containers làm nodes. Điều này rất hữu ích cho:

- Phát triển và testing ứng dụng Kubernetes
- Học tập và thử nghiệm Kubernetes
- CI/CD pipelines
- Demo và presentation

### Ưu Điểm của Kind

- ✅ **Đơn giản**: Chỉ cần Docker, không cần VM hay hypervisor
- ✅ **Nhanh**: Khởi động cluster trong vài giây
- ✅ **Linh hoạt**: Hỗ trợ nhiều phiên bản Kubernetes
- ✅ **Thực tế**: Sử dụng cùng kubelet và components như production
- ✅ **Miễn phí**: Không cần license hay subscription

## 🛠️ Cài Đặt và Thiết Lập

### Yêu Cầu Hệ Thống

- **macOS**: Docker Desktop hoặc OrbStack
- **Linux**: Docker Engine
- **Windows**: Docker Desktop hoặc WSL2 + Docker

### Cài Đặt Kind

**macOS (với Homebrew):**
```bash
brew install kind
```

**Linux:**
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

**Windows:**
```bash
# Với Chocolatey
choco install kind

# Hoặc download trực tiếp
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
```

### Cài Đặt kubectl

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

**Windows:**
```bash
# Với Chocolatey
choco install kubernetes-cli
```

### Kiểm Tra Cài Đặt

```bash
# Kiểm tra Kind
kind version

# Kiểm tra kubectl
kubectl version --client

# Kiểm tra Docker
docker --version
```

## 🚀 Tạo và Quản Lý Cluster

### Tạo Cluster Cơ Bản

```bash
# Tạo cluster với tên mặc định
kind create cluster

# Tạo cluster với tên tùy chỉnh
kind create cluster --name my-cluster
```

### Tạo Cluster với Cấu Hình Tùy Chỉnh

Tạo file `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
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
- role: worker
- role: worker
```

Tạo cluster với cấu hình:

```bash
kind create cluster --name eks-testing --config kind-config.yaml
```

### Quản Lý Cluster

```bash
# Liệt kê tất cả clusters
kind get clusters

# Xóa cluster
kind delete cluster --name my-cluster

# Xóa tất cả clusters
kind delete cluster --all

# Export kubeconfig
kind export kubeconfig --name my-cluster

# Chuyển đổi context
kubectl cluster-info --context kind-my-cluster
```

## 📦 Triển Khai Ứng Dụng

### 1. Cài Đặt Ingress Controller

```bash
# Cài đặt NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Chờ ingress controller sẵn sàng
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

### 2. Build và Load Docker Images

```bash
# Build images
make build-all

# Load images vào Kind cluster
kind load docker-image hbc08/k8s-auth-app:latest --name eks-testing
kind load docker-image hbc08/k8s-user-app:latest --name eks-testing
kind load docker-image hbc08/k8s-helloworld:latest --name eks-testing
```

### 3. Triển Khai Ứng Dụng

```bash
# Triển khai từng service
kubectl apply -f k8s/auth-deployment.yaml
kubectl apply -f k8s/auth-service.yaml
kubectl apply -f k8s/user-deployment.yaml
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/hello-deployment.yaml
kubectl apply -f k8s/hello-service.yaml
kubectl apply -f k8s/hello-ingress.yaml

# Hoặc triển khai tất cả cùng lúc
kubectl apply -f k8s/
```

### 4. Kiểm Tra Triển Khai

```bash
# Kiểm tra pods
kubectl get pods

# Kiểm tra services
kubectl get services

# Kiểm tra ingress
kubectl get ingress

# Chờ tất cả pods sẵn sàng
kubectl wait --for=condition=ready pod --all --timeout=60s
```

## 🔍 Kiểm Tra và Debug

### Kiểm Tra Trạng Thái Cluster

```bash
# Thông tin cluster
kubectl cluster-info

# Nodes
kubectl get nodes

# Namespaces
kubectl get namespaces

# Tất cả resources
kubectl get all
```

### Kiểm Tra Logs

```bash
# Logs của pod cụ thể
kubectl logs <pod-name>

# Logs của tất cả pods trong service
kubectl logs -l app=auth-app-pod

# Follow logs real-time
kubectl logs -f <pod-name>

# Logs với tail
kubectl logs <pod-name> --tail=50
```

### Kiểm Tra Network

```bash
# Kiểm tra service connectivity
kubectl exec -it <pod-name> -- nslookup auth-app-service

# Test HTTP request từ pod
kubectl exec -it <pod-name> -- wget -qO- http://auth-app-service:8124

# Kiểm tra port forwarding
kubectl port-forward service/helloworld-app-service 8080:8889
```

### Kiểm Tra Resources

```bash
# CPU và Memory usage
kubectl top pods
kubectl top nodes

# Chi tiết pod
kubectl describe pod <pod-name>

# Chi tiết service
kubectl describe service <service-name>

# Events
kubectl get events --sort-by='.lastTimestamp'
```

## 🧪 Testing Ứng Dụng

### Sử Dụng Helper Script

```bash
# Test tất cả services
./kind-commands.sh test

# Kiểm tra trạng thái
./kind-commands.sh status

# Xem logs
./kind-commands.sh logs auth-app
```

### Manual Testing

```bash
# Port forward cho Hello World service
kubectl port-forward service/helloworld-app-service 8080:8889 &
curl http://localhost:8080

# Port forward cho Auth service
kubectl port-forward service/auth-app-service 8081:8124 &
curl http://localhost:8081

# Test authentication
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"password1"}' \
  http://localhost:8081/authenticate

# Port forward cho User service
kubectl port-forward service/user-app-service 8082:80 &
curl http://localhost:8082
```

### Load Testing

```bash
# Test multiple requests
for i in {1..5}; do
  curl -s http://localhost:8080 | jq -r '.hostname'
done

# Test concurrent requests
for i in {1..10}; do
  curl -s http://localhost:8080 > /dev/null &
done
wait
```

## 🔧 Quản Lý Cluster

### Scaling Applications

```bash
# Scale deployment
kubectl scale deployment auth-app-deployment --replicas=3

# Auto-scaling (nếu có HPA)
kubectl autoscale deployment auth-app-deployment --cpu-percent=50 --min=2 --max=10
```

### Rolling Updates

```bash
# Restart deployment
kubectl rollout restart deployment auth-app-deployment

# Check rollout status
kubectl rollout status deployment auth-app-deployment

# Rollback nếu cần
kubectl rollout undo deployment auth-app-deployment
```

### Backup và Restore

```bash
# Export resources
kubectl get all -o yaml > backup.yaml

# Backup specific namespace
kubectl get all -n default -o yaml > default-namespace-backup.yaml

# Restore từ backup
kubectl apply -f backup.yaml
```

### Monitoring

```bash
# Cài đặt metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Kiểm tra metrics
kubectl top pods
kubectl top nodes
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Docker không chạy

```bash
# Kiểm tra Docker status
docker ps

# Khởi động Docker (macOS)
open -a Docker

# Khởi động OrbStack
orb start
```

#### 2. Port đã được sử dụng

```bash
# Kiểm tra port đang sử dụng
lsof -i :8080

# Kill process sử dụng port
pkill -f "kubectl port-forward"
```

#### 3. Pod không khởi động được

```bash
# Kiểm tra pod status
kubectl get pods
kubectl describe pod <pod-name>

# Kiểm tra logs
kubectl logs <pod-name>

# Kiểm tra events
kubectl get events --sort-by='.lastTimestamp'
```

#### 4. Service không thể kết nối

```bash
# Kiểm tra service
kubectl get services
kubectl describe service <service-name>

# Test connectivity từ pod
kubectl exec -it <pod-name> -- nslookup <service-name>
kubectl exec -it <pod-name> -- wget -qO- http://<service-name>:<port>
```

#### 5. Image không tìm thấy

```bash
# Kiểm tra images trong cluster
docker exec -it kind-control-plane crictl images

# Load lại image
kind load docker-image <image-name> --name <cluster-name>
```

### Debug Commands

```bash
# Debug pod
kubectl debug <pod-name> -it --image=busybox

# Exec vào pod
kubectl exec -it <pod-name> -- /bin/sh

# Copy file từ/đến pod
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file
```

### Performance Issues

```bash
# Kiểm tra resource usage
kubectl top pods
kubectl top nodes

# Kiểm tra resource limits
kubectl describe pod <pod-name> | grep -A 5 "Limits:"

# Kiểm tra node capacity
kubectl describe node | grep -A 5 "Capacity:"
```

## 📚 Best Practices

### 1. Resource Management

```yaml
# Luôn đặt resource limits
resources:
  limits:
    cpu: "1"
    memory: "512Mi"
  requests:
    cpu: "100m"
    memory: "128Mi"
```

### 2. Health Checks

```yaml
# Thêm liveness và readiness probes
livenessProbe:
  httpGet:
    path: /
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### 3. Security

```yaml
# Sử dụng non-root user
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
```

### 4. Networking

```yaml
# Sử dụng service mesh cho complex networking
# Implement proper ingress rules
# Use network policies
```

## 🔄 Workflow Development

### Development Workflow

1. **Code Changes**
   ```bash
   # Edit code
   vim auth-app/main.go
   ```

2. **Rebuild Images**
   ```bash
   make build-all
   ```

3. **Load vào Cluster**
   ```bash
   kind load docker-image hbc08/k8s-auth-app:latest --name eks-testing
   ```

4. **Redeploy**
   ```bash
   kubectl rollout restart deployment auth-app-deployment
   ```

5. **Test**
   ```bash
   ./kind-commands.sh test
   ```

### CI/CD Integration

```yaml
# GitHub Actions example
name: Test with Kind
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Create Kind cluster
      run: |
        kind create cluster
        kubectl apply -f k8s/
    - name: Run tests
      run: |
        kubectl wait --for=condition=ready pod --all
        ./kind-commands.sh test
```

## 📖 Tài Liệu Tham Khảo

- [Kind Official Documentation](https://kind.sigs.k8s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

## 🆘 Hỗ Trợ

Nếu gặp vấn đề:

1. Kiểm tra logs: `kubectl logs <pod-name>`
2. Kiểm tra events: `kubectl get events`
3. Kiểm tra status: `kubectl get all`
4. Tham khảo troubleshooting section
5. Tạo issue trên GitHub repository

---

**Lưu ý**: Tài liệu này được tạo riêng cho dự án EKS Testing. Điều chỉnh các lệnh và cấu hình cho phù hợp với dự án của bạn.
