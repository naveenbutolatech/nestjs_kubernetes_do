#!/bin/bash

# 🚀 Setup Script for External Database Deployment
# This script helps you configure and deploy with external databases

set -e

CONFIG_FILE="database-config.env"

echo "🚀 NestJS EKS Deployment with External Databases"
echo "================================================"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📝 Creating configuration template..."
    echo "Please edit $CONFIG_FILE with your database details"
    echo ""
    echo "Example configuration:"
    echo "  DATABASE_HOST=your-postgresql-endpoint.amazonaws.com"
    echo "  DATABASE_USER=postgres"
    echo "  DATABASE_PASSWORD=your-secure-password"
    echo "  REDIS_HOST=your-redis-endpoint.amazonaws.com"
    echo "  JWT_SECRET=your-jwt-secret-key"
    echo ""
    echo "After editing the config file, run this script again."
    exit 1
fi

# Load configuration
echo "📋 Loading configuration from $CONFIG_FILE..."
source "$CONFIG_FILE"

# Validate configuration
echo "🔍 Validating configuration..."
MISSING_VARS=()

if [ -z "$DATABASE_HOST" ] || [ "$DATABASE_HOST" = "your-postgresql-endpoint.amazonaws.com" ]; then
    MISSING_VARS+=("DATABASE_HOST")
fi

if [ -z "$DATABASE_USER" ] || [ "$DATABASE_USER" = "postgres" ]; then
    MISSING_VARS+=("DATABASE_USER")
fi

if [ -z "$DATABASE_PASSWORD" ] || [ "$DATABASE_PASSWORD" = "your-secure-password" ]; then
    MISSING_VARS+=("DATABASE_PASSWORD")
fi

if [ -z "$REDIS_HOST" ] || [ "$REDIS_HOST" = "your-redis-endpoint.amazonaws.com" ]; then
    MISSING_VARS+=("REDIS_HOST")
fi

if [ -z "$JWT_SECRET" ] || [ "$JWT_SECRET" = "your-jwt-secret-key-here" ]; then
    MISSING_VARS+=("JWT_SECRET")
fi

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "❌ Missing or invalid configuration:"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    echo ""
    echo "Please edit $CONFIG_FILE with your actual database details."
    exit 1
fi

echo "✅ Configuration validated successfully!"
echo ""

# Display configuration (hide sensitive data)
echo "📋 Current Configuration:"
echo "  Database Host: $DATABASE_HOST"
echo "  Database Port: $DATABASE_PORT"
echo "  Database Name: $DATABASE_NAME"
echo "  Database User: $DATABASE_USER"
echo "  Database Password: [HIDDEN]"
echo "  Redis Host: $REDIS_HOST"
echo "  Redis Port: $REDIS_PORT"
echo "  JWT Secret: [HIDDEN]"
echo "  EKS Cluster: $CLUSTER_NAME"
echo "  Region: $REGION"
echo "  Namespace: $NAMESPACE"
echo "  ECR Registry: $ECR_REGISTRY"
echo "  ECR Repository: $ECR_REPOSITORY"
echo "  Image Tag: $IMAGE_TAG"
echo ""

# Ask for confirmation
read -p "🤔 Do you want to proceed with this configuration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

echo ""
echo "🚀 Starting deployment..."

# Run the deployment script
./deploy-to-eks-external-db.sh
