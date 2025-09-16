# Kubernetes Production Deployment Guide

This guide will help you deploy your NestJS application to production using Kubernetes with CI/CD.

## 🚀 Prerequisites

1. **Kubernetes Cluster** (DigitalOcean Kubernetes, GKE, EKS, or local)
2. **DigitalOcean Container Registry** (or any container registry)
3. **GitHub Repository** with your code
4. **Domain Name** (optional, for ingress)

## 📋 Step-by-Step Setup

### Step 1: Create Kubernetes Cluster

#### DigitalOcean Kubernetes (Recommended)
1. Go to [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
2. Navigate to **Kubernetes**
3. Click **"Create Cluster"**
4. Choose:
   - **Region**: Choose closest to your users
   - **Version**: Latest stable
   - **Node Pool**: 3 nodes minimum
   - **Size**: s-2vcpu-4gb or larger
5. Click **"Create Cluster"**

#### Other Options
- **Google GKE**: `gcloud container clusters create`
- **AWS EKS**: `eksctl create cluster`
- **Local**: `minikube start` or `kind create cluster`

### Step 2: Install Required Tools

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install doctl (for DigitalOcean)
snap install doctl
doctl auth init
```

### Step 3: Configure kubectl

```bash
# DigitalOcean
doctl kubernetes cluster kubeconfig save your-cluster-name

# Google GKE
gcloud container clusters get-credentials your-cluster-name --zone your-zone

# AWS EKS
aws eks update-kubeconfig --region your-region --name your-cluster-name
```

### Step 4: Install Ingress Controller

```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Install cert-manager for SSL
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

### Step 5: Configure GitHub Secrets

Add these secrets to your GitHub repository:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `DO_REGISTRY_USERNAME` | Your DO username | DigitalOcean username |
| `DO_REGISTRY_TOKEN` | `dop_v1_...` | Container Registry token |
| `K8S_CLUSTER_NAME` | `your-cluster-name` | Kubernetes cluster name |
| `K8S_NAMESPACE` | `nestjs-prod` | Kubernetes namespace |

### Step 6: Update Configuration

1. **Update domain name** in `k8s/ingress.yaml`:
   ```yaml
   - host: your-domain.com
   ```

2. **Update registry name** in `k8s/deployment.yaml`:
   ```yaml
   image: registry.digitalocean.com/your-registry/nestjs-app-prod:latest
   ```

3. **Update secrets** in `k8s/secrets.yaml`:
   ```bash
   echo -n "postgres" | base64  # for username
   echo -n "your-password" | base64  # for password
   ```

### Step 7: Deploy

```bash
# Push to main branch to trigger deployment
git add .
git commit -m "Deploy to production Kubernetes"
git push origin main
```

## 🔧 Manual Deployment

If you want to deploy manually:

```bash
# Create namespace
kubectl create namespace nestjs-prod

# Apply secrets
kubectl apply -f k8s/secrets.yaml -n nestjs-prod

# Apply all manifests
kubectl apply -f k8s/ -n nestjs-prod

# Check deployment status
kubectl get pods -n nestjs-prod
kubectl get services -n nestjs-prod
kubectl get ingress -n nestjs-prod
```

## 📊 Monitoring and Management

### Check Application Status
```bash
# View pods
kubectl get pods -n nestjs-prod

# View logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod

# View service
kubectl get svc -n nestjs-prod

# View ingress
kubectl get ingress -n nestjs-prod
```

### Scale Application
```bash
# Scale up
kubectl scale deployment nestjs-app --replicas=5 -n nestjs-prod

# Auto-scaling (if HPA is configured)
kubectl autoscale deployment nestjs-app --cpu-percent=70 --min=3 --max=10 -n nestjs-prod
```

### Update Application
```bash
# Update image
kubectl set image deployment/nestjs-app nestjs-app=registry.digitalocean.com/your-registry/nestjs-app-prod:new-tag -n nestjs-prod

# Check rollout status
kubectl rollout status deployment/nestjs-app -n nestjs-prod
```

## 🔒 Security Considerations

1. **Use secrets** for sensitive data (passwords, API keys)
2. **Enable RBAC** for proper access control
3. **Use Network Policies** to restrict traffic
4. **Regular security updates** for base images
5. **Scan images** for vulnerabilities

## 📈 Production Optimizations

### Resource Limits
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Auto-scaling
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nestjs-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nestjs-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🚨 Troubleshooting

### Common Issues

1. **Pod not starting**:
   ```bash
   kubectl describe pod pod-name -n nestjs-prod
   kubectl logs pod-name -n nestjs-prod
   ```

2. **Service not accessible**:
   ```bash
   kubectl get svc -n nestjs-prod
   kubectl describe svc service-name -n nestjs-prod
   ```

3. **Ingress not working**:
   ```bash
   kubectl get ingress -n nestjs-prod
   kubectl describe ingress ingress-name -n nestjs-prod
   ```

4. **Image pull errors**:
   ```bash
   kubectl get events -n nestjs-prod
   kubectl describe pod pod-name -n nestjs-prod
   ```

### Useful Commands

```bash
# Get all resources
kubectl get all -n nestjs-prod

# Port forward for testing
kubectl port-forward svc/nestjs-app-service 3000:80 -n nestjs-prod

# Execute commands in pod
kubectl exec -it pod-name -n nestjs-prod -- /bin/sh

# View events
kubectl get events -n nestjs-prod --sort-by=.metadata.creationTimestamp
```

## 💰 Cost Optimization

1. **Right-size resources** based on actual usage
2. **Use spot instances** for non-critical workloads
3. **Implement auto-scaling** to scale down during low usage
4. **Monitor resource usage** regularly
5. **Clean up unused resources**

## 🎯 Next Steps

1. **Set up monitoring** (Prometheus, Grafana)
2. **Implement logging** (ELK stack, Fluentd)
3. **Add backup strategy** for databases
4. **Set up alerting** for critical issues
5. **Implement blue-green deployments**
6. **Add security scanning** to CI/CD pipeline

Your production Kubernetes deployment is now ready! 🚀
