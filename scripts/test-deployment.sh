#!/bin/bash

# Test DigitalOcean Deployment Script
# Run this script to test your deployment setup

set -e

echo "🧪 Testing DigitalOcean Deployment Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REGISTRY="registry.digitalocean.com"
REGISTRY_NAME="container-regietery--kubernetes"
APP_NAME="nestjs-app-dev"

echo -e "${YELLOW}📋 Testing Configuration...${NC}"

# Test 1: Check if registry name is set correctly
echo "1. Checking registry configuration..."
if grep -q "container-regietery--kubernetes" .github/workflows/deploy-do-dev.yml; then
    echo -e "   ✅ Registry name configured correctly"
else
    echo -e "   ❌ Registry name not found in workflow"
fi

if grep -q "container-regietery--kubernetes" docker-compose.do.yml; then
    echo -e "   ✅ Registry name configured in docker-compose"
else
    echo -e "   ❌ Registry name not found in docker-compose"
fi

# Test 2: Check if required files exist
echo "2. Checking required files..."
files=(
    ".github/workflows/deploy-do-dev.yml"
    "docker-compose.do.yml"
    "Dockerfile"
    "package.json"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "   ✅ $file exists"
    else
        echo -e "   ❌ $file missing"
    fi
done

# Test 3: Check Dockerfile
echo "3. Checking Dockerfile..."
if grep -q "FROM node:20-alpine" Dockerfile; then
    echo -e "   ✅ Dockerfile uses correct Node.js version"
else
    echo -e "   ⚠️  Dockerfile might need Node.js version check"
fi

if grep -q "EXPOSE 3000" Dockerfile; then
    echo -e "   ✅ Dockerfile exposes port 3000"
else
    echo -e "   ❌ Dockerfile doesn't expose port 3000"
fi

# Test 4: Check package.json
echo "4. Checking package.json..."
if grep -q "start:prod" package.json; then
    echo -e "   ✅ package.json has production start script"
else
    echo -e "   ❌ package.json missing production start script"
fi

# Test 5: Check GitHub workflow
echo "5. Checking GitHub workflow..."
if grep -q "DO_REGISTRY_USERNAME" .github/workflows/deploy-do-dev.yml; then
    echo -e "   ✅ Workflow references DO_REGISTRY_USERNAME secret"
else
    echo -e "   ❌ Workflow missing DO_REGISTRY_USERNAME secret"
fi

if grep -q "DO_DROPLET_HOST" .github/workflows/deploy-do-dev.yml; then
    echo -e "   ✅ Workflow references DO_DROPLET_HOST secret"
else
    echo -e "   ❌ Workflow missing DO_DROPLET_HOST secret"
fi

# Test 6: Check docker-compose configuration
echo "6. Checking docker-compose configuration..."
if grep -q "healthcheck" docker-compose.do.yml; then
    echo -e "   ✅ Docker Compose has health checks"
else
    echo -e "   ❌ Docker Compose missing health checks"
fi

if grep -q "depends_on" docker-compose.do.yml; then
    echo -e "   ✅ Docker Compose has service dependencies"
else
    echo -e "   ❌ Docker Compose missing service dependencies"
fi

echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Create DigitalOcean Container Registry"
echo "2. Set up DigitalOcean Droplet"
echo "3. Configure GitHub Secrets:"
echo "   - DO_REGISTRY_USERNAME"
echo "   - DO_REGISTRY_TOKEN"
echo "   - DO_DROPLET_HOST"
echo "   - DO_DROPLET_USERNAME"
echo "   - DO_DROPLET_SSH_KEY"
echo "4. Push to dev branch to trigger deployment"
echo ""
echo -e "${GREEN}🎯 Your GitHub Actions workflow is ready!${NC}"
echo "   Workflow file: .github/workflows/deploy-do-dev.yml"
echo "   Registry: $REGISTRY/$REGISTRY_NAME/$APP_NAME"
echo ""
echo -e "${YELLOW}💡 To test deployment:${NC}"
echo "   git add ."
echo "   git commit -m 'Test DigitalOcean deployment'"
echo "   git push origin dev"
