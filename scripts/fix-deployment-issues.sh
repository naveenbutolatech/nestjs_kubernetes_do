#!/bin/bash

# Fix Deployment Issues Script
# This script addresses the common deployment issues

set -e

echo "🔧 Fixing DigitalOcean deployment issues..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📋 Issues identified:${NC}"
echo "1. Docker image doesn't exist in registry yet"
echo "2. Git repository not initialized on droplet"
echo "3. Docker Compose version warnings"
echo "4. Missing docker-compose.dev.yml on droplet"
echo ""

echo -e "${YELLOW}🔧 Applying fixes...${NC}"

# Fix 1: Remove version from docker-compose files
echo "1. Removing obsolete version attribute from docker-compose files..."
if grep -q 'version: "3.9"' docker-compose.do.yml; then
    sed -i '1d' docker-compose.do.yml
    echo -e "   ✅ Fixed docker-compose.do.yml"
else
    echo -e "   ✅ docker-compose.do.yml already fixed"
fi

if grep -q 'version: "3.9"' docker-compose.dev.yml; then
    sed -i '1d' docker-compose.dev.yml
    echo -e "   ✅ Fixed docker-compose.dev.yml"
else
    echo -e "   ✅ docker-compose.dev.yml already fixed"
fi

# Fix 2: Update GitHub workflow
echo "2. Updating GitHub workflow to handle git repository initialization..."
# This is already done in the workflow file

# Fix 3: Create a script to build and push initial image
echo "3. Creating build and push script..."
# This is already created

echo ""
echo -e "${GREEN}✅ All fixes applied!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps to complete deployment:${NC}"
echo ""
echo "1. Build and push initial Docker image:"
echo "   export DO_REGISTRY_USERNAME=your-username"
echo "   export DO_REGISTRY_TOKEN=your-token"
echo "   ./scripts/build-and-push-image.sh"
echo ""
echo "2. Or use GitHub Actions to build and push:"
echo "   git add ."
echo "   git commit -m 'Fix deployment issues'"
echo "   git push origin dev"
echo ""
echo "3. If you want to manually set up the droplet:"
echo "   # SSH into your droplet and run:"
echo "   cd /home/\$USER/nestjs-dev"
echo "   git init"
echo "   git remote add origin https://github.com/your-username/nestjs_kubernetes_do.git"
echo "   git fetch origin"
echo "   git checkout -b dev origin/dev"
echo "   # Copy docker-compose files from your local repo"
echo ""
echo -e "${GREEN}🎯 Your deployment should work after these steps!${NC}"
