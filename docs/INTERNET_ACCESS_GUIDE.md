# Internet Access Configuration Guide

This guide explains how to configure internet access for your Kubernetes services, specifically the user service.

## Current Network Policy Setup

Your current network policies are restrictive and only allow:
- DNS resolution (port 53)
- Internal service communication
- Access to kube-dns service

## Internet Access Options

### Option 1: Restricted Internet Access (Recommended)
Allows only common internet protocols (HTTP/HTTPS):

```bash
make apply-user-restricted-internet
```

This allows:
- HTTP (port 80)
- HTTPS (port 443)
- Common web ports (8080, 8443)

### Option 2: Full Internet Access
Allows all outbound traffic to external destinations:

```bash
make apply-user-internet-access
```

This allows:
- All protocols and ports to external destinations
- Maximum flexibility but less secure

## Testing Internet Access

### Test Basic Connectivity
```bash
make test-user-internet-access
```

This will test:
- DNS resolution
- HTTPS connectivity to external sites
- IP address detection

### Manual Testing
You can also test manually:

```bash
# Test DNS resolution
kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- nslookup google.com

# Test HTTP connectivity
kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s https://httpbin.org/ip

# Test specific external API
kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s https://api.github.com/users/octocat
```

## Network Policy Details

### Restricted Internet Access Policy
```yaml
# Allow internet access (HTTP/HTTPS)
- to: []
  ports:
  - protocol: TCP
    port: 80
  - protocol: TCP
    port: 443
  - protocol: TCP
    port: 8080
  - protocol: TCP
    port: 8443
```

### Full Internet Access Policy
```yaml
# Allow all outbound traffic to external destinations
- to: []
  # This allows all protocols and ports
```

## Security Considerations

### Restricted Access (Recommended)
- ✅ Allows common web protocols
- ✅ Blocks unnecessary protocols
- ✅ Better security posture
- ❌ May block some specialized services

### Full Access
- ✅ Maximum flexibility
- ✅ Works with any external service
- ❌ Less secure
- ❌ Allows potentially dangerous protocols

## Common Use Cases

### Web APIs
```bash
# Your user service can now call external APIs
curl https://api.external-service.com/data
```

### External Databases
```bash
# Connect to external databases (if needed)
# Note: Consider using Kubernetes secrets for credentials
```

### Third-party Services
```bash
# Integrate with external services
curl https://webhook.site/your-endpoint
```

## Troubleshooting

### Check Network Policy Status
```bash
make network-policies-status
```

### Verify Pod Connectivity
```bash
# Check if user service pods can reach external sites
kubectl exec -it deployment/user-app-deployment -- curl -s https://httpbin.org/ip
```

### Common Issues

1. **DNS Resolution Fails**
   - Ensure DNS policy allows port 53
   - Check if kube-dns is working

2. **HTTPS Connection Fails**
   - Verify network policy allows port 443
   - Check if external site is accessible

3. **Specific Port Blocked**
   - Add the required port to network policy
   - Or use full internet access policy

## Best Practices

1. **Start with Restricted Access**: Use the restricted policy first
2. **Add Ports as Needed**: Only open ports you actually need
3. **Monitor Traffic**: Use network monitoring tools
4. **Regular Reviews**: Periodically review network policies
5. **Document Changes**: Keep track of why ports were opened

## Example: Adding Custom Port

If you need to access a service on a specific port (e.g., 5432 for PostgreSQL):

```yaml
# Add to your network policy
- to: []
  ports:
  - protocol: TCP
    port: 5432
```

## Rollback

To revert to the original restrictive policy:

```bash
# Remove internet access
kubectl delete networkpolicy user-app-network-policy-internet
kubectl apply -f k8s/user-app-network-policy.yaml
```

## Next Steps

1. Choose your internet access level
2. Apply the appropriate network policy
3. Test connectivity
4. Monitor for any issues
5. Adjust as needed for your specific use case
