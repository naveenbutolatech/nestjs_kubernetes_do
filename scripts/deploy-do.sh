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

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.do.yml down || true

# Start new containers
echo "🚀 Starting new containers..."
docker-compose -f docker-compose.do.yml up -d

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
