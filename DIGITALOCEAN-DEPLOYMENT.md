# DigitalOcean Deployment Guide

This guide will help you deploy your NestJS application to DigitalOcean using Docker containers and GitHub Actions.

## Prerequisites

1. **DigitalOcean Account**: Sign up at [digitalocean.com](https://digitalocean.com)
2. **GitHub Repository**: Your code should be in a GitHub repository
3. **Droplet**: A DigitalOcean droplet (Ubuntu 22.04 LTS recommended)
4. **Container Registry**: DigitalOcean Container Registry

## Step 1: Create DigitalOcean Resources

### 1.1 Create a Droplet

1. Go to DigitalOcean Control Panel
2. Click "Create" → "Droplets"
3. Choose:
   - **Image**: Ubuntu 22.04 LTS
   - **Size**: Basic plan, $6/month (1GB RAM) or higher
   - **Datacenter**: Choose closest to your users
   - **Authentication**: SSH Key (recommended) or Password
4. Click "Create Droplet"

### 1.2 Create Container Registry

1. Go to Container Registry in DigitalOcean Control Panel
2. Click "Create Container Registry"
3. Choose a name (e.g., `your-registry-name`)
4. Select the same region as your droplet
5. Click "Create"

### 1.3 Generate Registry Token

1. Go to your Container Registry
2. Click "Settings" → "API"
3. Click "Generate New Token"
4. Give it a name (e.g., `github-actions`)
5. Copy the token (you'll need it for GitHub secrets)

## Step 2: Set Up Droplet

### 2.1 Connect to Your Droplet

```bash
ssh root@YOUR_DROPLET_IP
# or
ssh -i your_ssh_key.pem root@YOUR_DROPLET_IP
```

### 2.2 Run Setup Script

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/your-username/nestjs_kubernetes_do/dev/scripts/setup-do-droplet.sh | bash

# Or if you have the files locally
scp scripts/setup-do-droplet.sh root@YOUR_DROPLET_IP:/tmp/
ssh root@YOUR_DROPLET_IP "chmod +x /tmp/setup-do-droplet.sh && /tmp/setup-do-droplet.sh"
```

### 2.3 Manual Setup (Alternative)

If you prefer to set up manually:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo apt install git -y

# Create app directory
mkdir -p /home/$USER/nestjs-dev
cd /home/$USER/nestjs-dev

# Clone your repository
git clone https://github.com/your-username/nestjs_kubernetes_do.git .
git checkout dev
```

## Step 3: Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add these secrets:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `DO_REGISTRY_USERNAME` | Your DigitalOcean username | `your-username` |
| `DO_REGISTRY_TOKEN` | Container Registry token | `dop_v1_...` |
| `DO_DROPLET_HOST` | Your droplet IP address | `123.456.789.012` |
| `DO_DROPLET_USERNAME` | Droplet username | `root` or `ubuntu` |
| `DO_DROPLET_SSH_KEY` | Private SSH key for droplet access | `-----BEGIN OPENSSH PRIVATE KEY-----...` |

## Step 4: Update Configuration Files

### 4.1 Update Registry Name

Edit `.github/workflows/deploy-do-dev.yml` and `docker-compose.do.yml`:

```yaml
# Replace 'your-registry-name' with your actual registry name
DO_REGISTRY_NAME: your-actual-registry-name
```

### 4.2 Update Repository URL

Update the repository URL in `scripts/setup-do-droplet.sh`:

```bash
git clone https://github.com/your-actual-username/nestjs_kubernetes_do.git .
```

## Step 5: Deploy

### 5.1 Automatic Deployment

Push to the `dev` branch to trigger automatic deployment:

```bash
git add .
git commit -m "Deploy to DigitalOcean"
git push origin dev
```

### 5.2 Manual Deployment

SSH into your droplet and run:

```bash
cd /home/$USER/nestjs-dev
./scripts/deploy-do.sh
```

## Step 6: Verify Deployment

1. **Check Application**: Visit `http://YOUR_DROPLET_IP:3000`
2. **Health Check**: Visit `http://YOUR_DROPLET_IP:3000/health`
3. **View Logs**: 
   ```bash
   docker-compose -f docker-compose.do.yml logs -f
   ```

## Management Commands

### Start/Stop Application

```bash
# Start
sudo systemctl start nestjs-dev

# Stop
sudo systemctl stop nestjs-dev

# Restart
sudo systemctl restart nestjs-dev

# Check status
sudo systemctl status nestjs-dev
```

### View Logs

```bash
# All services
docker-compose -f docker-compose.do.yml logs -f

# Specific service
docker-compose -f docker-compose.do.yml logs -f app
docker-compose -f docker-compose.do.yml logs -f postgres
docker-compose -f docker-compose.do.yml logs -f redis
```

### Update Application

```bash
# Pull latest code
git pull origin dev

# Rebuild and restart
docker-compose -f docker-compose.do.yml down
docker-compose -f docker-compose.do.yml up -d --build
```

## Troubleshooting

### Common Issues

1. **Port 3000 not accessible**:
   - Check firewall: `sudo ufw status`
   - Open port: `sudo ufw allow 3000`

2. **Container fails to start**:
   - Check logs: `docker-compose -f docker-compose.do.yml logs app`
   - Check image: `docker images`

3. **Database connection issues**:
   - Check PostgreSQL logs: `docker-compose -f docker-compose.do.yml logs postgres`
   - Verify environment variables

4. **Registry authentication issues**:
   - Re-login: `echo $DO_TOKEN | docker login registry.digitalocean.com -u $USERNAME --password-stdin`

### Useful Commands

```bash
# Check running containers
docker ps

# Check all containers (including stopped)
docker ps -a

# Check system resources
docker stats

# Clean up unused images
docker image prune -a

# View container details
docker inspect container_name
```

## Security Considerations

1. **Firewall**: Only open necessary ports (22, 3000)
2. **SSH Keys**: Use SSH keys instead of passwords
3. **Environment Variables**: Store sensitive data in environment files
4. **Regular Updates**: Keep your droplet and containers updated
5. **Backup**: Regular backups of your database volumes

## Cost Optimization

1. **Droplet Size**: Start with the smallest size and scale up as needed
2. **Container Registry**: Clean up old images regularly
3. **Monitoring**: Use DigitalOcean monitoring to track resource usage

## Next Steps

1. Set up a domain name and SSL certificate
2. Configure load balancing for high availability
3. Set up monitoring and alerting
4. Implement CI/CD for production deployment
5. Set up database backups

## Support

- [DigitalOcean Documentation](https://docs.digitalocean.com/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
