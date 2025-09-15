# 🚀 AWS EKS Production Deployment Guide

## 📋 Prerequisites

- AWS CLI configured with appropriate permissions
- kubectl installed
- Helm 3.x installed
- eksctl installed
- Docker installed

## 🏗️ Phase 1: Infrastructure Setup

### Step 1: Create EKS Cluster

```bash
# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Create EKS cluster
eksctl create cluster \
  --name nestjs-prod \
  --region us-east-2 \
  --version 1.28 \
  --nodegroup-name workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 5 \
  --managed \
  --with-oidc \
  --ssh-access \
  --ssh-public-key your-key-name
```

### Step 2: Set up Managed Databases (Recommended)

```bash
# Create RDS PostgreSQL
aws rds create-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password YourSecurePassword123 \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxxxxxx

# Create ElastiCache Redis
aws elasticache create-cache-cluster \
  --cache-cluster-id nestjs-prod-redis \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1
```

### Step 3: Install Required Tools

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Configure kubectl for EKS
aws eks update-kubeconfig --region us-east-2 --name nestjs-prod
```

## 🚀 Phase 2: Application Deployment

### Step 4: Deploy Database Services (if not using managed)

```bash
# Add Bitnami Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Deploy PostgreSQL
helm install postgres bitnami/postgresql \
  --namespace nestjs-prod \
  --create-namespace \
  --set auth.postgresPassword=postgres \
  --set auth.database=nestdb

# Deploy Redis
helm install redis bitnami/redis \
  --namespace nestjs-prod \
  --create-namespace \
  --set auth.enabled=false
```

### Step 5: Deploy Your NestJS Application

```bash
# Deploy using Helm chart
helm install nestjs-app ./helm-chart \
  --namespace nestjs-prod \
  --create-namespace \
  --set image.repository=your-ecr-registry-url/nestjs-app-ecr \
  --set image.tag=latest
```

### Step 6: Verify Deployment

```bash
# Check pods
kubectl get pods -n nestjs-prod

# Check services
kubectl get services -n nestjs-prod

# Check ingress
kubectl get ingress -n nestjs-prod

# Check logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod
```

## 🔧 Phase 3: Configuration

### Step 7: Update Helm Values

Edit `helm-chart/values.yaml`:

```yaml
# Update these values
image:
  repository: your-actual-ecr-registry-url/nestjs-app-ecr
  tag: "latest"

ingress:
  hosts:
    - host: your-domain.com  # Replace with your domain
      paths:
        - path: /
          pathType: Prefix

# Update secrets (base64 encoded)
secrets:
  DATABASE_USER: "cG9zdGdyZXM="  # postgres
  DATABASE_PASSWORD: "your-actual-password-base64"
  JWT_SECRET: "your-actual-jwt-secret-base64"
```

### Step 8: Set up GitHub Secrets

Add these secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `EC2_HOST` (for dev deployment)
- `EC2_SSH_KEY` (for dev deployment)

## 📊 Phase 4: Monitoring & Scaling

### Step 9: Enable Auto-scaling

The Helm chart includes HPA (Horizontal Pod Autoscaler) configuration:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

### Step 10: Monitor Your Application

```bash
# Check HPA status
kubectl get hpa -n nestjs-prod

# Check resource usage
kubectl top pods -n nestjs-prod

# Check events
kubectl get events -n nestjs-prod --sort-by='.lastTimestamp'
```

## 🔄 Phase 5: CI/CD Pipeline

### Step 11: Deploy via GitHub Actions

1. Push to `main` branch
2. GitHub Actions will automatically:
   - Build Docker image
   - Push to ECR
   - Deploy to EKS
   - Run health checks

### Step 12: Manual Deployment

```bash
# Update image tag
helm upgrade nestjs-app ./helm-chart \
  --namespace nestjs-prod \
  --set image.tag=your-new-tag

# Rollback if needed
helm rollback nestjs-app 1 --namespace nestjs-prod
```

## 🛠️ Troubleshooting

### Common Issues:

1. **Pods not starting**: Check logs with `kubectl logs -f pod-name -n nestjs-prod`
2. **Service not accessible**: Check ingress configuration
3. **Database connection issues**: Verify database credentials and network policies
4. **Image pull errors**: Check ECR permissions and image tags

### Useful Commands:

```bash
# Get pod details
kubectl describe pod pod-name -n nestjs-prod

# Port forward for testing
kubectl port-forward service/nestjs-app 3000:80 -n nestjs-prod

# Check ingress status
kubectl describe ingress nestjs-app -n nestjs-prod

# View all resources
kubectl get all -n nestjs-prod
```

## 🎯 Best Practices

1. **Use managed databases** (RDS + ElastiCache) for production
2. **Set resource limits** to prevent resource exhaustion
3. **Enable monitoring** with AWS CloudWatch or Prometheus
4. **Use secrets management** (AWS Secrets Manager or Kubernetes secrets)
5. **Implement proper logging** and monitoring
6. **Set up backup strategies** for your data
7. **Use network policies** for security
8. **Regular security updates** and vulnerability scanning

## 📈 Scaling Considerations

- **Horizontal scaling**: HPA automatically scales based on CPU/memory
- **Vertical scaling**: Adjust resource requests/limits in values.yaml
- **Database scaling**: Use read replicas for read-heavy workloads
- **Cache scaling**: ElastiCache supports clustering for high availability

## 🔐 Security Considerations

1. **Network policies**: Restrict pod-to-pod communication
2. **RBAC**: Set up proper role-based access control
3. **Secrets management**: Use AWS Secrets Manager
4. **Image scanning**: Enable ECR image scanning
5. **WAF**: Use AWS WAF for application protection
6. **SSL/TLS**: Configure proper certificates for HTTPS

This setup provides a production-ready, scalable, and maintainable deployment of your NestJS application on AWS EKS! 🚀
