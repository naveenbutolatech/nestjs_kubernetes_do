#!/bin/bash

echo "🔍 AWS Free Tier Usage Monitor"
echo "================================"

# Check EC2 usage
echo "📊 EC2 Usage:"
aws ec2 describe-instances \
  --region us-east-2 \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]' \
  --output table

# Check RDS usage
echo "📊 RDS Usage:"
aws rds describe-db-instances \
  --region us-east-2 \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus]' \
  --output table

# Check ElastiCache usage
echo "📊 ElastiCache Usage:"
aws elasticache describe-cache-clusters \
  --region us-east-2 \
  --query 'CacheClusters[*].[CacheClusterId,CacheNodeType,CacheClusterStatus]' \
  --output table

# Check ECR usage
echo "📊 ECR Usage:"
aws ecr describe-repositories \
  --region us-east-2 \
  --query 'repositories[*].[repositoryName,repositoryUri]' \
  --output table

echo "✅ Usage check complete!"
