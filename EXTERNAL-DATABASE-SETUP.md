# 🗄️ External Database Setup Guide

This guide helps you deploy your NestJS application to EKS using external databases that you provision separately.

## 📋 Prerequisites

1. **EKS Cluster** - Already created and running
2. **PostgreSQL Database** - RDS, external server, or any PostgreSQL instance
3. **Redis Cache** - ElastiCache, external server, or any Redis instance
4. **ECR Repository** - Your Docker images pushed to ECR

## 🚀 Quick Start

### Step 1: Configure Database Details

```bash
# Copy the template
cp database-config.env.example database-config.env

# Edit with your details
nano database-config.env
```

### Step 2: Fill in Your Database Details

```bash
# Example database-config.env
export DATABASE_HOST="your-postgresql-endpoint.amazonaws.com"
export DATABASE_PORT="5432"
export DATABASE_NAME="nestdb"
export DATABASE_USER="postgres"
export DATABASE_PASSWORD="your-secure-password"

export REDIS_HOST="your-redis-endpoint.amazonaws.com"
export REDIS_PORT="6379"

export JWT_SECRET="your-jwt-secret-key-here"

export ECR_REGISTRY="your-ecr-registry-url"
export ECR_REPOSITORY="nestjs-app-ecr"
export IMAGE_TAG="latest"
```

### Step 3: Deploy

```bash
# Run the setup script
./setup-external-db.sh
```

## 🔧 Manual Deployment

If you prefer to run commands manually:

```bash
# Set environment variables
export DATABASE_HOST="your-postgresql-endpoint.amazonaws.com"
export DATABASE_USER="postgres"
export DATABASE_PASSWORD="your-secure-password"
export REDIS_HOST="your-redis-endpoint.amazonaws.com"
export JWT_SECRET="your-jwt-secret-key"

# Run deployment
./deploy-to-eks-external-db.sh
```

## 🗄️ Database Setup Options

### Option 1: AWS RDS PostgreSQL

```bash
# Create RDS PostgreSQL instance
aws rds create-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password YourSecurePassword123 \
  --allocated-storage 20 \
  --region us-east-2

# Get endpoint
aws rds describe-db-instances \
  --db-instance-identifier nestjs-prod-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

### Option 2: AWS ElastiCache Redis

```bash
# Create ElastiCache Redis cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id nestjs-prod-redis \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1 \
  --region us-east-2

# Get endpoint
aws elasticache describe-cache-clusters \
  --cache-cluster-id nestjs-prod-redis \
  --query 'CacheClusters[0].RedisEndpoint.Address' \
  --output text
```

### Option 3: External Servers

If you have external PostgreSQL and Redis servers:

```bash
# Just use their IP addresses or hostnames
export DATABASE_HOST="your-server-ip"
export REDIS_HOST="your-redis-server-ip"
```

## 🔍 What the Script Does

1. **Validates** your database configuration
2. **Creates** Kubernetes namespace
3. **Creates** secrets for database credentials
4. **Creates** configmap for database connection details
5. **Deploys** your NestJS application using Helm
6. **Tests** database connectivity
7. **Shows** deployment status and URLs

## 📊 Verification

After deployment, check:

```bash
# Check pods
kubectl get pods -n nestjs-prod

# Check services
kubectl get services -n nestjs-prod

# Check secrets
kubectl get secrets -n nestjs-prod

# Check logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod

# Test database connection
kubectl exec -it deployment/nestjs-app -n nestjs-prod -- sh
# Inside pod: nc -z $DATABASE_HOST $DATABASE_PORT
```

## 🔧 Troubleshooting

### Database Connection Issues

```bash
# Check if databases are accessible from EKS
kubectl run test-pod --image=busybox -it --rm -- sh
# Inside pod: nc -z your-db-host 5432
```

### Security Group Issues

Make sure your database security groups allow connections from EKS:

```bash
# EKS security group
eksctl get cluster --name nestjs-prod --region us-east-2

# Update RDS security group to allow EKS security group
aws rds modify-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --vpc-security-group-ids sg-xxxxxxxxx
```

### Network Connectivity

```bash
# Check if EKS can reach external databases
kubectl exec -it deployment/nestjs-app -n nestjs-prod -- sh
# Inside pod: ping your-db-host
```

## 🎯 Benefits of External Databases

- ✅ **Managed Services**: AWS handles backups, scaling, monitoring
- ✅ **High Availability**: Multi-AZ deployments
- ✅ **Security**: VPC isolation, encryption at rest
- ✅ **Performance**: Optimized for database workloads
- ✅ **Cost Effective**: Pay only for what you use
- ✅ **Easy Management**: No database administration needed

## 📈 Next Steps

1. **Monitor** your application and databases
2. **Set up** CloudWatch alarms
3. **Configure** backup retention policies
4. **Implement** database connection pooling
5. **Set up** read replicas for scaling

This approach gives you full control over your database setup while keeping your application deployment simple! 🚀
