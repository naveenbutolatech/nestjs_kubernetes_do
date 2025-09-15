#!/bin/bash

# Build and Push Docker Image to DigitalOcean Container Registry
# This script builds the initial image and pushes it to your registry

set -e

# Configuration
REGISTRY="registry.digitalocean.com"
REGISTRY_NAME="container-regietery--kubernetes"
APP_NAME="nestjs-app-dev"
IMAGE_TAG="dev-latest"

echo "🐳 Building and pushing Docker image to DigitalOcean Container Registry..."

# Check if required environment variables are set
if [ -z "$DO_REGISTRY_USERNAME" ] || [ -z "$DO_REGISTRY_TOKEN" ]; then
    echo "❌ Error: DO_REGISTRY_USERNAME and DO_REGISTRY_TOKEN environment variables must be set"
    echo "   Example:"
    echo "   export DO_REGISTRY_USERNAME=your-username"
    echo "   export DO_REGISTRY_TOKEN=dop_v1_..."
    exit 1
fi

# Login to DigitalOcean Container Registry
echo "🔐 Logging in to DigitalOcean Container Registry..."
echo "$DO_REGISTRY_TOKEN" | docker login $REGISTRY -u $DO_REGISTRY_USERNAME --password-stdin

# Build the Docker image
echo "🔨 Building Docker image..."
docker build -t $REGISTRY/$REGISTRY_NAME/$APP_NAME:$IMAGE_TAG .

# Also tag with commit SHA if available
if [ ! -z "$GITHUB_SHA" ]; then
    docker tag $REGISTRY/$REGISTRY_NAME/$APP_NAME:$IMAGE_TAG $REGISTRY/$REGISTRY_NAME/$APP_NAME:dev-$GITHUB_SHA
fi

# Push the image
echo "📤 Pushing image to registry..."
docker push $REGISTRY/$REGISTRY_NAME/$APP_NAME:$IMAGE_TAG

if [ ! -z "$GITHUB_SHA" ]; then
    docker push $REGISTRY/$REGISTRY_NAME/$APP_NAME:dev-$GITHUB_SHA
fi

echo "✅ Successfully built and pushed image!"
echo "   Image: $REGISTRY/$REGISTRY_NAME/$APP_NAME:$IMAGE_TAG"
echo ""
echo "🚀 You can now deploy using GitHub Actions or manually on your droplet"
