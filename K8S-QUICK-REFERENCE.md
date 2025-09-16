# Kubernetes Production - Quick Reference

## 🚀 Quick Start

1. **Create Kubernetes cluster** (DigitalOcean, GKE, EKS)
2. **Install kubectl and Helm**
3. **Configure GitHub secrets**
4. **Push to main branch** to deploy

## 📁 Files Created

- `.github/workflows/deploy-prod-k8s.yml` - Production GitHub Actions workflow
- `k8s/` - Kubernetes manifests directory
- `helm-chart/` - Helm chart for advanced deployment
- `Dockerfile.prod` - Production-optimized Dockerfile
- `KUBERNETES-PRODUCTION-DEPLOYMENT.md` - Complete setup guide

## 🔐 Required GitHub Secrets

| Secret | Value |
|--------|-------|
| `DO_REGISTRY_USERNAME` | Your DO username |
| `DO_REGISTRY_TOKEN` | Container Registry token |
| `K8S_CLUSTER_NAME` | Your cluster name |
| `K8S_NAMESPACE` | `nestjs-prod` |

## 🛠️ Common Commands

### Deploy
```bash
# Automatic (via GitHub Actions)
git push origin main

# Manual
kubectl apply -f k8s/ -n nestjs-prod
```

### Check Status
```bash
# View all resources
kubectl get all -n nestjs-prod

# View pods
kubectl get pods -n nestjs-prod

# View logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod
```

### Scale
```bash
# Scale up
kubectl scale deployment nestjs-app --replicas=5 -n nestjs-prod

# Auto-scaling
kubectl autoscale deployment nestjs-app --cpu-percent=70 --min=3 --max=10 -n nestjs-prod
```

### Update
```bash
# Update image
kubectl set image deployment/nestjs-app nestjs-app=registry.digitalocean.com/your-registry/nestjs-app-prod:new-tag -n nestjs-prod

# Check rollout
kubectl rollout status deployment/nestjs-app -n nestjs-prod
```

## 🌐 Access Points

- **Application**: `http://your-domain.com` (via ingress)
- **Direct access**: `kubectl port-forward svc/nestjs-app-service 3000:80 -n nestjs-prod`
- **Health check**: `http://your-domain.com/health`

## 🔧 Configuration Updates

1. **Update domain** in `k8s/ingress.yaml`
2. **Update registry** in `k8s/deployment.yaml`
3. **Update secrets** in `k8s/secrets.yaml`

## 📊 Production Features

- ✅ **High Availability** (3 replicas)
- ✅ **Auto-scaling** (3-10 replicas)
- ✅ **Health checks** (liveness + readiness)
- ✅ **Resource limits** (CPU + memory)
- ✅ **SSL/TLS** (via cert-manager)
- ✅ **Load balancing** (via ingress)
- ✅ **Persistent storage** (PostgreSQL)
- ✅ **Monitoring** (health endpoints)

## 🚨 Troubleshooting

### Pod Issues
```bash
kubectl describe pod pod-name -n nestjs-prod
kubectl logs pod-name -n nestjs-prod
```

### Service Issues
```bash
kubectl get svc -n nestjs-prod
kubectl describe svc service-name -n nestjs-prod
```

### Ingress Issues
```bash
kubectl get ingress -n nestjs-prod
kubectl describe ingress ingress-name -n nestjs-prod
```

## 💡 Tips

- **Start with 3 replicas** for high availability
- **Monitor resource usage** and adjust limits
- **Use persistent volumes** for databases
- **Enable auto-scaling** for cost optimization
- **Set up monitoring** and alerting
- **Regular security updates** for base images

## 🎯 Next Steps

1. Set up domain name and SSL
2. Configure monitoring (Prometheus/Grafana)
3. Implement logging (ELK stack)
4. Add backup strategy
5. Set up alerting
6. Implement blue-green deployments

Your production Kubernetes deployment is ready! 🚀
