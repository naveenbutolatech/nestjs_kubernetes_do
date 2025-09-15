# 🆓 AWS Free Tier Setup Guide for bheji.com

Complete guide to set up your NestJS application using AWS Free Tier to minimize costs while maintaining functionality.

## 📋 Overview

This guide shows how to:
- **Minimize costs** using AWS Free Tier (12 months free)
- **Set up production-ready** infrastructure
- **Monitor usage** to stay within free limits
- **Plan scaling** for future growth

## 💰 **Free Tier Benefits (12 Months)**

| Service | Free Tier Limit | Monthly Cost |
|---------|----------------|--------------|
| **EC2** | 750 hours of t2.micro | $0.00 |
| **RDS** | 750 hours of db.t2.micro | $0.00 |
| **ElastiCache** | 750 hours of cache.t2.micro | $0.00 |
| **EBS** | 30 GB General Purpose SSD | $0.00 |
| **Data Transfer** | 1 GB out to internet | $0.00 |
| **ECR** | 500 MB storage | $0.00 |
| **EKS Control Plane** | ❌ Not free | $0.10/hour |

## 🚀 **Part 1: EKS Cluster Setup (Free Tier)**

### **1.1 Create EKS Cluster with Free Tier Node Group**

```bash
# Create EKS cluster with free tier node group
eksctl create cluster \
  --name nestjs-prod \
  --region us-east-2 \
  --nodegroup-name free-tier-nodes \
  --node-type t2.micro \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 2 \
  --managed \
  --with-oidc \
  --ssh-access \
  --ssh-public-key your-key-name
```

### **1.2 Verify Cluster Creation**

```bash
# Check cluster status
eksctl get cluster --region us-east-2

# Check node group
eksctl get nodegroup --cluster nestjs-prod --region us-east-2

# Get cluster info
aws eks describe-cluster --name nestjs-prod --region us-east-2
```

## 🗄️ **Part 2: Database Setup (Free Tier)**

### **2.1 Create RDS PostgreSQL Instance**

```bash
# Create RDS PostgreSQL instance (free tier)
aws rds create-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --db-instance-class db.t2.micro \
  --engine postgres \
  --engine-version 15.4 \
  --master-username admin \
  --master-user-password YourSecurePassword123! \
  --allocated-storage 20 \
  --storage-type gp2 \
  --backup-retention-period 7 \
  --multi-az \
  --publicly-accessible \
  --region us-east-2
```

### **2.2 Create ElastiCache Redis Cluster**

```bash
# Create ElastiCache Redis cluster (free tier)
aws elasticache create-cache-cluster \
  --cache-cluster-id nestjs-prod-redis \
  --cache-node-type cache.t2.micro \
  --engine redis \
  --engine-version 7.0 \
  --num-cache-nodes 1 \
  --port 6379 \
  --region us-east-2
```

### **2.3 Wait for Database Creation**

```bash
# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier nestjs-prod-db \
  --region us-east-2 \
  --query 'DBInstances[0].DBInstanceStatus'

# Check ElastiCache status
aws elasticache describe-cache-clusters \
  --cache-cluster-id nestjs-prod-redis \
  --region us-east-2 \
  --query 'CacheClusters[0].CacheClusterStatus'
```

## 📦 **Part 3: ECR Setup (Free Tier)**

### **3.1 Create ECR Repository**

```bash
# Create ECR repository
aws ecr create-repository \
  --repository-name nestjs-app-new-ecr \
  --region us-east-2

# Get login token
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 213028525650.dkr.ecr.us-east-2.amazonaws.com
```

### **3.2 Build and Push Docker Image**

```bash
# Build Docker image
docker build -t nestjs-app .

# Tag for ECR
docker tag nestjs-app:latest 213028525650.dkr.ecr.us-east-2.amazonaws.com/nestjs-app-new-ecr:latest

# Push to ECR
docker push 213028525650.dkr.ecr.us-east-2.amazonaws.com/nestjs-app-new-ecr:latest
```

## 🔧 **Part 4: Helm Chart Configuration (Free Tier)**

### **4.1 Update Helm Values for Free Tier**

```yaml
# helm-chart/values.yaml
replicaCount: 1  # Single replica for free tier

resources:
  limits:
    cpu: 500m      # t2.micro has 1 vCPU
    memory: 512Mi  # t2.micro has 1GB RAM
  requests:
    cpu: 250m
    memory: 256Mi

# Database configuration
env:
  DB_HOST: "your-rds-endpoint.us-east-2.rds.amazonaws.com"
  DB_PORT: "5432"
  DB_USERNAME: "admin"
  DB_PASSWORD: "YourSecurePassword123!"
  REDIS_HOST: "your-elasticache-endpoint.cache.amazonaws.com"
  REDIS_PORT: "6379"
```

### **4.2 Deploy Application to EKS**

```bash
# Install Helm chart
helm install nestjs-app ./helm-chart \
  --namespace nestjs-prod \
  --create-namespace \
  --set replicaCount=1 \
  --set resources.limits.cpu=500m \
  --set resources.limits.memory=512Mi
```

## 📊 **Part 5: Cost Monitoring Setup**

### **5.1 Create Cost Budget Alert**

```bash
# Create budget for free tier monitoring
aws budgets create-budget \
  --account-id 213028525650 \
  --budget '{
    "BudgetName": "Free-Tier-Monitoring",
    "BudgetLimit": {
      "Amount": "50.00",
      "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST",
    "CostFilters": {
      "Service": ["Amazon Elastic Compute Cloud", "Amazon Relational Database Service", "Amazon ElastiCache"]
    }
  }' \
  --region us-east-2
```

### **5.2 Set Up CloudWatch Alerts**

```bash
# Create CloudWatch alarm for high costs
aws cloudwatch put-metric-alarm \
  --alarm-name "Free-Tier-Cost-Alert" \
  --alarm-description "Alert when monthly costs exceed $30" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 30.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --region us-east-2
```

## 🔍 **Part 6: Usage Monitoring Scripts**

### **6.1 Create Usage Check Script**

```bash
# Create usage monitoring script
cat > monitor-free-tier.sh << 'EOF'
#!/bin/bash

echo "🔍 AWS Free Tier Usage Monitor"
echo "================================"

# Check EC2 usage
echo "📊 EC2 Usage:"
aws ec2 describe-instances \
  --region us-east-2 \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]' \
  --output table

# Check RDS usage
echo "📊 RDS Usage:"
aws rds describe-db-instances \
  --region us-east-2 \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus]' \
  --output table

# Check ElastiCache usage
echo "📊 ElastiCache Usage:"
aws elasticache describe-cache-clusters \
  --region us-east-2 \
  --query 'CacheClusters[*].[CacheClusterId,CacheNodeType,CacheClusterStatus]' \
  --output table

# Check ECR usage
echo "📊 ECR Usage:"
aws ecr describe-repositories \
  --region us-east-2 \
  --query 'repositories[*].[repositoryName,repositoryUri]' \
  --output table

echo "✅ Usage check complete!"
EOF

chmod +x monitor-free-tier.sh
```

### **6.2 Create Cost Analysis Script**

```bash
# Create cost analysis script
cat > analyze-costs.sh << 'EOF'
#!/bin/bash

echo "💰 AWS Cost Analysis"
echo "===================="

# Get current month costs
CURRENT_MONTH=$(date +%Y-%m)
echo "📅 Analyzing costs for: $CURRENT_MONTH"

# Get cost and usage data
aws ce get-cost-and-usage \
  --time-period Start=$CURRENT_MONTH-01,End=$CURRENT_MONTH-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region us-east-2 \
  --query 'ResultsByTime[0].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
  --output table

echo "✅ Cost analysis complete!"
EOF

chmod +x analyze-costs.sh
```

## ⚠️ **Part 7: Free Tier Limitations & Solutions**

### **7.1 Resource Limitations**

| Resource | Free Tier Limit | Impact | Solution |
|----------|----------------|--------|----------|
| **EC2** | 1 vCPU, 1GB RAM | Limited performance | Optimize app, use caching |
| **RDS** | 1 vCPU, 1GB RAM | Limited database performance | Optimize queries, use indexes |
| **ElastiCache** | 0.5GB RAM | Small cache size | Use efficient caching strategies |
| **EBS** | 30GB storage | Limited storage | Optimize images, use compression |

### **7.2 Performance Optimization Tips**

```bash
# Optimize Docker image size
docker build --no-cache -t nestjs-app .

# Use multi-stage builds
# Optimize Node.js dependencies
# Use Alpine Linux base image
# Enable gzip compression
```

### **7.3 Scaling Strategy**

```bash
# When to upgrade from free tier:
# 1. CPU usage consistently > 80%
# 2. Memory usage consistently > 80%
# 3. Database queries timing out
# 4. Cache hit rate < 70%

# Upgrade path:
# t2.micro → t3.small → t3.medium
# db.t2.micro → db.t3.small → db.t3.medium
# cache.t2.micro → cache.t3.small → cache.t3.medium
```

## 📈 **Part 8: Monthly Cost Projection**

### **8.1 Free Tier Period (0-12 months)**

| Month | EKS Control Plane | Other Services | Total |
|-------|------------------|----------------|-------|
| 1-12 | $12.00 | $0.00 | $12.00 |
| **Annual** | **$144.00** | **$0.00** | **$144.00** |

### **8.2 Post Free Tier (12+ months)**

| Month | EKS Control Plane | Worker Node | RDS | ElastiCache | Total |
|-------|------------------|-------------|-----|-------------|-------|
| 13+ | $12.00 | $4.99 | $2.04 | $0.00 | $19.03 |

## 🎯 **Part 9: Quick Start Commands**

### **9.1 Complete Setup (One Command)**

```bash
# Run complete free tier setup
./setup-free-tier.sh
```

### **9.2 Monitor Usage**

```bash
# Check free tier usage
./monitor-free-tier.sh

# Analyze costs
./analyze-costs.sh
```

### **9.3 Deploy Application**

```bash
# Deploy to EKS
helm install nestjs-app ./helm-chart \
  --namespace nestjs-prod \
  --create-namespace
```

## ✅ **Part 10: Verification Checklist**

- [ ] EKS cluster created with t2.micro nodes
- [ ] RDS PostgreSQL instance created (db.t2.micro)
- [ ] ElastiCache Redis cluster created (cache.t2.micro)
- [ ] ECR repository created
- [ ] Docker image pushed to ECR
- [ ] Helm chart deployed
- [ ] Application accessible via ALB
- [ ] Cost monitoring alerts configured
- [ ] Usage monitoring scripts created

## 🚨 **Important Notes**

1. **Free Tier Expires**: After 12 months, you'll be charged standard rates
2. **Resource Limits**: t2.micro instances have limited performance
3. **Monitoring**: Set up alerts to avoid unexpected charges
4. **Scaling**: Plan for upgrades when you exceed free tier limits
5. **Backup**: Always backup your data before making changes

## 📞 **Support**

If you encounter issues:
1. Check AWS Free Tier usage in the console
2. Review CloudWatch logs
3. Monitor cost alerts
4. Contact AWS support if needed

---

**🎉 Congratulations! You now have a production-ready NestJS application running on AWS Free Tier with minimal costs!**
