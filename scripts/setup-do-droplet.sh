#!/bin/bash

# DigitalOcean Droplet Setup Script for NestJS App
# Run this script on your DigitalOcean droplet to set up the environment

set -e

echo "🚀 Setting up DigitalOcean droplet for NestJS development..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed successfully"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed successfully"
else
    echo "✅ Docker Compose already installed"
fi

# Install Git
echo "📁 Installing Git..."
sudo apt install git -y

# Install Node.js (for local development if needed)
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /home/$USER/nestjs-dev
cd /home/$USER/nestjs-dev

# Clone repository (you'll need to update this with your actual repo URL)
echo "📥 Cloning repository..."
if [ ! -d ".git" ]; then
    git clone https://github.com/your-username/nestjs_kubernetes_do.git .
    git checkout dev
else
    echo "✅ Repository already exists"
fi

# Create environment file
echo "⚙️ Creating environment file..."
cat > .env << 'EOF'
NODE_ENV=development
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=nestdb
REDIS_HOST=redis
REDIS_PORT=6379
EOF

# Create systemd service for auto-start
echo "🔧 Creating systemd service..."
sudo tee /etc/systemd/system/nestjs-dev.service > /dev/null << EOF
[Unit]
Description=NestJS Development App
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/$USER/nestjs-dev
ExecStart=/usr/local/bin/docker-compose -f docker-compose.do.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.do.yml down
TimeoutStartSec=0
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable nestjs-dev.service

# Install DigitalOcean doctl CLI (optional)
echo "🔧 Installing DigitalOcean CLI..."
if ! command -v doctl &> /dev/null; then
    cd /tmp
    wget https://github.com/digitalocean/doctl/releases/download/v1.94.0/doctl-1.94.0-linux-amd64.tar.gz
    tar xf doctl-1.94.0-linux-amd64.tar.gz
    sudo mv doctl /usr/local/bin
    echo "✅ DigitalOcean CLI installed"
else
    echo "✅ DigitalOcean CLI already installed"
fi

# Set up firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 3000/tcp # NestJS app
sudo ufw allow 5432/tcp # PostgreSQL (if needed externally)
sudo ufw allow 6379/tcp # Redis (if needed externally)
sudo ufw --force enable

echo "✅ DigitalOcean droplet setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Configure your GitHub secrets for DigitalOcean deployment"
echo "2. Set up DigitalOcean Container Registry"
echo "3. Update the registry name in docker-compose.do.yml"
echo "4. Push to dev branch to trigger deployment"
echo ""
echo "🔧 Useful commands:"
echo "  Start app: sudo systemctl start nestjs-dev"
echo "  Stop app:  sudo systemctl stop nestjs-dev"
echo "  View logs: docker-compose -f docker-compose.do.yml logs -f"
echo "  Check status: sudo systemctl status nestjs-dev"
