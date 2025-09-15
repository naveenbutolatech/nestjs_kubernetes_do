#!/bin/bash

# DigitalOcean Deployment Script
# This script can be run manually on the droplet to deploy the latest version

set -e

echo "🚀 Deploying NestJS app to DigitalOcean..."

# Configuration
APP_DIR="/home/$USER/nestjs-dev"
REGISTRY="registry.digitalocean.com"
REGISTRY_NAME="your-registry-name"
APP_NAME="nestjs-app-dev"

# Navigate to application directory
cd $APP_DIR

# Pull latest code
echo "📥 Pulling latest code..."
git pull origin dev

# Login to DigitalOcean Container Registry
echo "🔐 Logging in to DigitalOcean Container Registry..."
echo "Please enter your DigitalOcean Container Registry token:"
read -s DO_TOKEN
echo "$DO_TOKEN" | docker login $REGISTRY -u your-username --password-stdin

# Pull latest dev image
echo "📦 Pulling latest dev image..."
docker pull $REGISTRY/$REGISTRY_NAME/$APP_NAME:dev-latest

# Stop and remove existing containers
echo "🛑 Stopping existing containers..."
docker stop nestjs-app-dev || true
docker rm nestjs-app-dev || true

# Start PostgreSQL and Redis if not running
echo "🐘 Starting PostgreSQL..."
docker run -d --name postgres-db-dev \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=nestdb \
  -p 5432:5432 \
  --restart unless-stopped \
  postgres:15-alpine || true

echo "🔴 Starting Redis..."
docker run -d --name redis-cache-dev \
  -p 6379:6379 \
  --restart unless-stopped \
  redis:7-alpine || true

# Start the NestJS application
echo "🚀 Starting NestJS application..."
docker run -d --name nestjs-app-dev \
  -p 3000:3000 \
  --link postgres-db-dev:postgres \
  --link redis-cache-dev:redis \
  -e NODE_ENV=development \
  -e DATABASE_HOST=postgres \
  -e DATABASE_PORT=5432 \
  -e DATABASE_USER=postgres \
  -e DATABASE_PASSWORD=postgres \
  -e DATABASE_NAME=nestdb \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  --restart unless-stopped \
  $REGISTRY/$REGISTRY_NAME/$APP_NAME:dev-latest

# Wait for health check
echo "⏳ Waiting for services to be healthy..."
sleep 30

# Health check
echo "🏥 Running health check..."
if curl -f http://localhost:3000/health; then
    echo "✅ Health check passed! Deployment successful!"
    echo "🌐 Application is available at: http://$(curl -s ifconfig.me):3000"
else
    echo "❌ Health check failed!"
    echo "📋 Container logs:"
    docker-compose -f docker-compose.do.yml logs app
    exit 1
fi

echo "✅ Deployment completed successfully!"
