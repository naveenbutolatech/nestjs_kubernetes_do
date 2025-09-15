# GitHub Actions Deployment Setup for DigitalOcean

This guide will help you set up automated deployment to DigitalOcean using GitHub Actions.

## 🚀 Prerequisites

1. **DigitalOcean Account** with Container Registry
2. **GitHub Repository** with your code
3. **DigitalOcean Droplet** (Ubuntu 22.04 LTS)
4. **SSH Key** for droplet access

## 📋 Step-by-Step Setup

### Step 1: Create DigitalOcean Container Registry

1. Go to [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
2. Navigate to **Container Registry**
3. Click **"Create Container Registry"**
4. **Registry Name**: `container-regietery--kubernetes` (already configured)
5. **Region**: Choose same region as your droplet
6. Click **"Create"**

### Step 2: Generate Registry Token

1. Go to your Container Registry
2. Click **"Settings"** → **"API"**
3. Click **"Generate New Token"**
4. **Token Name**: `github-actions`
5. **Expiration**: Choose appropriate duration
6. **Copy the token** (starts with `dop_v1_...`)

### Step 3: Set Up DigitalOcean Droplet

1. **Create Droplet**:
   - Image: Ubuntu 22.04 LTS
   - Size: Basic $6/month (1GB RAM) minimum
   - Authentication: SSH Key (recommended)
   - Note the IP address

2. **Connect to Droplet**:
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

3. **Run Setup Script**:
   ```bash
   # Download and run setup
   curl -fsSL https://raw.githubusercontent.com/your-username/nestjs_kubernetes_do/dev/scripts/setup-do-droplet.sh | bash
   
   # Or manually:
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   
   # Install Git
   sudo apt update && sudo apt install git -y
   
   # Create app directory
   mkdir -p /home/$USER/nestjs-dev
   cd /home/$USER/nestjs-dev
   
   # Clone repository
   git clone https://github.com/your-username/nestjs_kubernetes_do.git .
   git checkout dev
   ```

### Step 4: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `DO_REGISTRY_USERNAME` | `your-do-username` | Your DigitalOcean username |
| `DO_REGISTRY_TOKEN` | `dop_v1_...` | Container Registry token |
| `DO_DROPLET_HOST` | `123.456.789.012` | Your droplet IP address |
| `DO_DROPLET_USERNAME` | `root` | Droplet username (usually `root`) |
| `DO_DROPLET_SSH_KEY` | `-----BEGIN OPENSSH PRIVATE KEY-----...` | Private SSH key content |

#### How to get SSH Key:

**If you created the droplet with SSH key:**
```bash
# On your local machine
cat ~/.ssh/id_rsa
# Copy the entire content including -----BEGIN and -----END lines
```

**If you need to create SSH key:**
```bash
# Generate new SSH key
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Copy public key to droplet
ssh-copy-id root@YOUR_DROPLET_IP

# Copy private key content
cat ~/.ssh/id_rsa
```

### Step 5: Test the Setup

1. **Push to dev branch**:
   ```bash
   git add .
   git commit -m "Test DigitalOcean deployment"
   git push origin dev
   ```

2. **Check GitHub Actions**:
   - Go to your repository
   - Click **"Actions"** tab
   - Watch the workflow run

3. **Verify Deployment**:
   - Visit `http://YOUR_DROPLET_IP:3000`
   - Check health endpoint: `http://YOUR_DROPLET_IP:3000/health`

## 🔧 Troubleshooting

### Common Issues

#### 1. Registry Authentication Failed
```bash
# Test registry login manually
echo "YOUR_TOKEN" | docker login registry.digitalocean.com -u YOUR_USERNAME --password-stdin
```

#### 2. SSH Connection Failed
```bash
# Test SSH connection
ssh -i ~/.ssh/id_rsa root@YOUR_DROPLET_IP

# Check SSH key format in GitHub secrets
# Should include -----BEGIN and -----END lines
```

#### 3. Port Not Accessible
```bash
# On droplet, check firewall
sudo ufw status
sudo ufw allow 3000
```

#### 4. Container Fails to Start
```bash
# Check logs on droplet
docker-compose -f docker-compose.do.yml logs app
docker-compose -f docker-compose.do.yml logs postgres
docker-compose -f docker-compose.do.yml logs redis
```

### Debug Commands

**On Droplet:**
```bash
# Check running containers
docker ps -a

# Check images
docker images

# Check logs
docker-compose -f docker-compose.do.yml logs -f

# Restart services
docker-compose -f docker-compose.do.yml down
docker-compose -f docker-compose.do.yml up -d
```

**In GitHub Actions:**
- Check the **Actions** tab for detailed logs
- Look for error messages in each step
- Verify all secrets are set correctly

## 🎯 Workflow Triggers

The deployment will trigger on:
- **Push to `dev` branch** (automatic)
- **Pull Request to `dev` branch** (for testing)
- **Manual trigger** (workflow_dispatch)

## 📊 Monitoring

### Check Deployment Status
1. **GitHub Actions**: Repository → Actions tab
2. **Application**: `http://YOUR_DROPLET_IP:3000`
3. **Health Check**: `http://YOUR_DROPLET_IP:3000/health`

### View Logs
```bash
# On droplet
docker-compose -f docker-compose.do.yml logs -f app
```

## 🚀 Next Steps

1. **Set up domain name** and SSL certificate
2. **Configure monitoring** and alerting
3. **Set up production deployment** workflow
4. **Implement database backups**
5. **Add staging environment**

## 💡 Tips

- **Start small**: Use $6/month droplet for development
- **Monitor costs**: Check DigitalOcean billing regularly
- **Keep secrets secure**: Never commit secrets to code
- **Test locally**: Use `docker-compose.dev.yml` for local testing
- **Backup data**: Regular database backups are important

## 🆘 Support

If you encounter issues:
1. Check GitHub Actions logs
2. Check droplet logs
3. Verify all secrets are correct
4. Test SSH connection manually
5. Test registry login manually

The deployment should work automatically once all secrets are configured correctly!
