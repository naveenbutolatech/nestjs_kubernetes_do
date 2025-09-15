#!/bin/bash

# 🚀 EKS Deployment Script with External Databases
# This script deploys your NestJS app to AWS EKS using external databases
# You need to provide database connection details

set -e  # Exit on any error

# Configuration
CLUSTER_NAME="nestjs-prod"
REGION="us-east-2"
NAMESPACE="nestjs-prod"
ECR_REGISTRY="213028525650.dkr.ecr.us-east-2.amazonaws.com"
ECR_REPOSITORY="nestjs-app-new-ecr"
IMAGE_TAG="latest"

# Database configuration (YOU NEED TO PROVIDE THESE)
# Replace these with your actual database details
DATABASE_HOST=""           # e.g., your-rds-endpoint.amazonaws.com
DATABASE_PORT="5432"       # e.g., 5432
DATABASE_NAME="nestdb"     # e.g., nestdb
DATABASE_USER=""           # e.g., postgres
DATABASE_PASSWORD=""       # e.g., your-secure-password

# Redis configuration (YOU NEED TO PROVIDE THESE)
REDIS_HOST=""              # e.g., your-redis-endpoint.amazonaws.com
REDIS_PORT="6379"          # e.g., 6379

# JWT Secret (YOU NEED TO PROVIDE THIS)
JWT_SECRET=""              # e.g., your-jwt-secret-key

echo "🚀 Starting EKS deployment with external databases..."

# Step 1: Validate required parameters
echo "🔍 Validating configuration..."
if [ -z "$DATABASE_HOST" ] || [ -z "$DATABASE_USER" ] || [ -z "$DATABASE_PASSWORD" ] || [ -z "$REDIS_HOST" ] || [ -z "$JWT_SECRET" ]; then
    echo "❌ Missing required configuration!"
    echo ""
    echo "Please update the following variables in this script:"
    echo "  DATABASE_HOST: $DATABASE_HOST"
    echo "  DATABASE_USER: $DATABASE_USER"
    echo "  DATABASE_PASSWORD: [HIDDEN]"
    echo "  REDIS_HOST: $REDIS_HOST"
    echo "  JWT_SECRET: [HIDDEN]"
    echo ""
    echo "Or set them as environment variables:"
    echo "  export DATABASE_HOST='your-db-host'"
    echo "  export DATABASE_USER='your-db-user'"
    echo "  export DATABASE_PASSWORD='your-db-password'"
    echo "  export REDIS_HOST='your-redis-host'"
    echo "  export JWT_SECRET='your-jwt-secret'"
    echo ""
    echo "Then run: $0"
    exit 1
fi

# Step 2: Check if EKS cluster exists
echo "📋 Checking EKS cluster..."
if ! eksctl get cluster --name $CLUSTER_NAME --region $REGION >/dev/null 2>&1; then
    echo "❌ EKS cluster '$CLUSTER_NAME' not found!"
    echo "Please create the cluster first using:"
    echo "eksctl create cluster --name $CLUSTER_NAME --region $REGION"
    exit 1
fi

# Step 3: Configure kubectl
echo "🔧 Configuring kubectl..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Step 4: Create namespace
echo "📦 Creating namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Step 5: Create secrets for external databases
echo "🔐 Creating secrets for external databases..."
kubectl create secret generic nestjs-secrets \
  --namespace $NAMESPACE \
  --from-literal=DATABASE_USER="$DATABASE_USER" \
  --from-literal=DATABASE_PASSWORD="$DATABASE_PASSWORD" \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --dry-run=client -o yaml | kubectl apply -f -

# Step 6: Create configmap for external databases
echo "⚙️ Creating configmap for external databases..."
kubectl create configmap nestjs-config \
  --namespace $NAMESPACE \
  --from-literal=NODE_ENV="production" \
  --from-literal=DATABASE_HOST="$DATABASE_HOST" \
  --from-literal=DATABASE_PORT="$DATABASE_PORT" \
  --from-literal=DATABASE_NAME="$DATABASE_NAME" \
  --from-literal=REDIS_HOST="$REDIS_HOST" \
  --from-literal=REDIS_PORT="$REDIS_PORT" \
  --dry-run=client -o yaml | kubectl apply -f -

# Step 7: Deploy NestJS Application
echo "🚀 Deploying NestJS Application..."
helm install nestjs-app ./helm-chart \
  --namespace $NAMESPACE \
  --create-namespace \
  --set image.repository=$ECR_REGISTRY/$ECR_REPOSITORY \
  --set image.tag=$IMAGE_TAG \
  --wait

# Step 8: Verify deployment
echo "✅ Verifying deployment..."
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE
kubectl get ingress -n $NAMESPACE
kubectl get secrets -n $NAMESPACE
kubectl get configmap -n $NAMESPACE

# Step 9: Test database connectivity
echo "🔍 Testing database connectivity..."
echo "Checking if pods can reach external databases..."

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=nestjs-app -n $NAMESPACE --timeout=300s

# Get pod name
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=nestjs-app -o jsonpath='{.items[0].metadata.name}')

if [ -n "$POD_NAME" ]; then
    echo "Testing database connection from pod: $POD_NAME"
    
    # Test PostgreSQL connection
    echo "Testing PostgreSQL connection..."
    kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "
      if command -v nc >/dev/null 2>&1; then
        nc -z $DATABASE_HOST $DATABASE_PORT && echo '✅ PostgreSQL connection successful' || echo '❌ PostgreSQL connection failed'
      else
        echo '⚠️ nc command not available, skipping connection test'
      fi
    "
    
    # Test Redis connection
    echo "Testing Redis connection..."
    kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "
      if command -v nc >/dev/null 2>&1; then
        nc -z $REDIS_HOST $REDIS_PORT && echo '✅ Redis connection successful' || echo '❌ Redis connection failed'
      else
        echo '⚠️ nc command not available, skipping connection test'
      fi
    "
else
    echo "⚠️ No pods found, skipping connection tests"
fi

# Step 10: Get application URL
echo "🌐 Getting application URL..."
EXTERNAL_IP=$(kubectl get ingress nestjs-app -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Not ready yet")

if [ -n "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "Not ready yet" ]; then
    echo "🎉 Deployment successful!"
    echo "🌐 Application available at: http://$EXTERNAL_IP"
    echo "🗄️ PostgreSQL endpoint: $DATABASE_HOST:$DATABASE_PORT"
    echo "🔴 Redis endpoint: $REDIS_HOST:$REDIS_PORT"
else
    echo "⏳ LoadBalancer is still provisioning..."
    echo "Run 'kubectl get ingress -n $NAMESPACE' to check status"
fi

echo ""
echo "📋 Deployment Summary:"
echo "  Cluster: $CLUSTER_NAME"
echo "  Namespace: $NAMESPACE"
echo "  Database: $DATABASE_HOST:$DATABASE_PORT"
echo "  Redis: $REDIS_HOST:$REDIS_PORT"
echo "  Image: $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
echo ""
echo "✅ Deployment with external databases completed!"
