# Production Database Setup Guide

## 🎯 Current Approach: Docker Containers for Testing
Using Docker containers for database and Redis in production for testing purposes. Will migrate to AWS managed services later.

### Current Production Setup (Docker Containers)
```yaml
# docker-compose.prod.yml
services:
  app:
    image: 213028525650.dkr.ecr.us-east-2.amazonaws.com/nestjs-app-ecr:latest
    environment:
      NODE_ENV: production
      DATABASE_HOST: postgres      # Docker container
      DATABASE_PORT: 5432
      DATABASE_USER: postgres
      DATABASE_PASSWORD: postgres
      DATABASE_NAME: nestdb
      REDIS_HOST: redis            # Docker container
      REDIS_PORT: 6379

  postgres:
    image: postgres:15-alpine      # Docker container database
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: nestdb

  redis:
    image: redis:7-alpine          # Docker container Redis
```

### Deploy Current Setup
```bash
# Build and push to ECR
./deploy-prod.sh

# Or manually:
docker-compose -f docker-compose.prod.yml up -d
```

## 🏗️ Future Production Setup (AWS Managed Services)

### Option 1: AWS RDS (Recommended)
```bash
# Create RDS PostgreSQL instance
aws rds create-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password YourSecurePassword123! \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxxxxxx \
  --db-subnet-group-name your-subnet-group
```

### Option 2: AWS Aurora Serverless
```bash
# Create Aurora Serverless cluster
aws rds create-db-cluster \
  --db-cluster-identifier nestjs-aurora-cluster \
  --engine aurora-postgresql \
  --engine-mode serverless \
  --master-username postgres \
  --master-user-password YourSecurePassword123!
```

## 🔧 Environment Variables for Production

Create a `.env.prod` file with:

```bash
# Production Environment Variables
NODE_ENV=production
PORT=3000

# AWS RDS Database
DATABASE_HOST=your-rds-endpoint.region.rds.amazonaws.com
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=YourSecurePassword123!
DATABASE_NAME=nestdb

# AWS ElastiCache Redis
REDIS_HOST=your-redis-endpoint.cache.amazonaws.com
REDIS_PORT=6379

# Application
LOG_LEVEL=info
```

## 🚀 Production Deployment Commands

### 1. Build and Push to ECR
```bash
./deploy-prod.sh
```

### 2. Deploy with Production Environment
```bash
# Load production environment variables
export $(cat .env.prod | xargs)

# Start production services
docker-compose -f docker-compose.prod.yml up -d
```

## 🔒 Security Best Practices

1. **Use AWS Secrets Manager** for database credentials
2. **Enable SSL/TLS** for database connections
3. **Use VPC** for network isolation
4. **Regular backups** with automated snapshots
5. **Monitor** database performance and logs

## 📊 Database Migration for Production

```bash
# Run migrations in production
docker-compose -f docker-compose.prod.yml exec app npm run migration:run
```

## 🎯 Current vs Recommended

| Environment | Current | Recommended |
|-------------|---------|-------------|
| **Local** | Local PostgreSQL | Local PostgreSQL ✅ |
| **Production** | Local PostgreSQL ❌ | AWS RDS/Aurora ✅ |
| **Redis** | Local Redis | AWS ElastiCache ✅ |
