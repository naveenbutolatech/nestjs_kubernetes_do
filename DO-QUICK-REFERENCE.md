# DigitalOcean Deployment - Quick Reference

## 🚀 Quick Start

1. **Create DigitalOcean droplet** (Ubuntu 22.04 LTS)
2. **Set up Container Registry** in DigitalOcean
3. **Configure GitHub secrets** (see below)
4. **Run setup script** on droplet
5. **Push to dev branch** to deploy

## 🔐 Required GitHub Secrets

| Secret | Value |
|--------|-------|
| `DO_REGISTRY_USERNAME` | Your DO username |
| `DO_REGISTRY_TOKEN` | Container Registry token |
| `DO_DROPLET_HOST` | Droplet IP address |
| `DO_DROPLET_USERNAME` | `root` or `ubuntu` |
| `DO_DROPLET_SSH_KEY` | Private SSH key |

## 📁 Files Created

- `.github/workflows/deploy-do-dev.yml` - GitHub Actions workflow
- `docker-compose.do.yml` - DigitalOcean Docker Compose config
- `scripts/setup-do-droplet.sh` - Droplet setup script
- `scripts/deploy-do.sh` - Manual deployment script
- `DIGITALOCEAN-DEPLOYMENT.md` - Complete setup guide

## 🛠️ Common Commands

### On Droplet

```bash
# Check app status
sudo systemctl status nestjs-dev

# View logs
docker-compose -f docker-compose.do.yml logs -f

# Restart app
sudo systemctl restart nestjs-dev

# Manual deploy
./scripts/deploy-do.sh
```

### Local Development

```bash
# Start local development
docker-compose -f docker-compose.dev.yml up -d

# Stop local development
docker-compose -f docker-compose.dev.yml down
```

## 🔧 Configuration Updates Needed

1. **Update registry name** in:
   - `.github/workflows/deploy-do-dev.yml` (line 11)
   - `docker-compose.do.yml` (line 2)

2. **Update repository URL** in:
   - `scripts/setup-do-droplet.sh` (line 45)

## 🌐 Access Points

- **Application**: `http://YOUR_DROPLET_IP:3000`
- **Health Check**: `http://YOUR_DROPLET_IP:3000/health`
- **PostgreSQL**: `YOUR_DROPLET_IP:5432`
- **Redis**: `YOUR_DROPLET_IP:6379`

## 🚨 Troubleshooting

### Port not accessible
```bash
sudo ufw allow 3000
sudo ufw status
```

### Container issues
```bash
docker ps -a
docker logs container_name
```

### Registry login issues
```bash
echo $DO_TOKEN | docker login registry.digitalocean.com -u $USERNAME --password-stdin
```

## 📋 Deployment Flow

1. **Code Push** → GitHub Actions triggered
2. **Build Image** → Push to DO Container Registry
3. **SSH to Droplet** → Pull latest image
4. **Restart Containers** → Health check
5. **Notify Status** → Success/Failure

## 💡 Tips

- Start with smallest droplet size ($6/month)
- Use SSH keys for security
- Monitor resource usage
- Clean up old Docker images regularly
- Set up domain name and SSL for production
