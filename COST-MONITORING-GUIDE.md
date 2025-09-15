# 💰 AWS Cost Monitoring Guide for bheji.com

Complete guide to monitor and optimize costs for your NestJS application running on AWS.

## 📋 Overview

This guide covers:
- **Real-time cost monitoring** for all AWS services
- **Budget alerts** to prevent unexpected charges
- **Usage optimization** strategies
- **Cost analysis** tools and scripts

## 💵 **Cost Breakdown Analysis**

### **Current Setup Costs (5 Days)**

| Service | Instance Type | Hours/Day | Cost/Hour | Daily Cost | 5-Day Cost |
|---------|---------------|-----------|-----------|------------|------------|
| **EKS Control Plane** | N/A | 24 | $0.10 | $2.40 | $12.00 |
| **Worker Node** | t2.micro | 24 | $0.00 (Free) | $0.00 | $0.00 |
| **RDS PostgreSQL** | db.t2.micro | 24 | $0.00 (Free) | $0.00 | $0.00 |
| **ElastiCache Redis** | cache.t2.micro | 24 | $0.00 (Free) | $0.00 | $0.00 |
| **ECR Storage** | 500MB | 24 | $0.00 (Free) | $0.00 | $0.00 |
| **Data Transfer** | 1GB/month | 24 | $0.00 (Free) | $0.00 | $0.00 |
| **TOTAL** | | | | **$2.40** | **$12.00** |

### **Monthly Cost Projection**

| Period | EKS Control Plane | Other Services | Total/Month | Total/Year |
|--------|------------------|----------------|-------------|------------|
| **Free Tier (0-12 months)** | $72.00 | $0.00 | $72.00 | $864.00 |
| **Post Free Tier (12+ months)** | $72.00 | $6.03 | $78.03 | $936.36 |

## 📊 **Part 1: Real-Time Cost Monitoring**

### **1.1 AWS Cost Explorer Setup**

```bash
# Enable Cost Explorer
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --region us-east-2
```

### **1.2 Create Cost Dashboard**

```bash
# Create CloudWatch dashboard for cost monitoring
aws cloudwatch put-dashboard \
  --dashboard-name "Cost-Monitoring-Dashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
          ],
          "period": 86400,
          "stat": "Maximum",
          "region": "us-east-2",
          "title": "Daily AWS Costs"
        }
      }
    ]
  }' \
  --region us-east-2
```

## 🚨 **Part 2: Budget Alerts Setup**

### **2.1 Create Monthly Budget Alert**

```bash
# Create budget for monthly monitoring
aws budgets create-budget \
  --account-id 213028525650 \
  --budget '{
    "BudgetName": "Monthly-Budget-Alert",
    "BudgetLimit": {
      "Amount": "100.00",
      "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST",
    "CostFilters": {
      "Service": [
        "Amazon Elastic Compute Cloud",
        "Amazon Relational Database Service",
        "Amazon ElastiCache",
        "Amazon Elastic Container Registry"
      ]
    },
    "NotificationsWithSubscribers": [
      {
        "Notification": {
          "NotificationType": "ACTUAL",
          "ComparisonOperator": "GREATER_THAN",
          "Threshold": 80,
          "ThresholdType": "PERCENTAGE"
        },
        "Subscribers": [
          {
            "SubscriptionType": "EMAIL",
            "Address": "your-email@example.com"
          }
        ]
      }
    ]
  }' \
  --region us-east-2
```

### **2.2 Create Daily Cost Alert**

```bash
# Create daily cost alert
aws cloudwatch put-metric-alarm \
  --alarm-name "Daily-Cost-Alert" \
  --alarm-description "Alert when daily costs exceed $5" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 5.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-2:213028525650:cost-alerts \
  --region us-east-2
```

## 🔍 **Part 3: Usage Monitoring Scripts**

### **3.1 Daily Cost Check Script**

```bash
#!/bin/bash
# daily-cost-check.sh

echo "💰 Daily Cost Check - $(date)"
echo "================================"

# Get yesterday's costs
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
TODAY=$(date +%Y-%m-%d)

echo "📅 Checking costs for: $YESTERDAY to $TODAY"

# Get cost data
aws ce get-cost-and-usage \
  --time-period Start=$YESTERDAY,End=$TODAY \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region us-east-2 \
  --query 'ResultsByTime[*].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
  --output table

echo "✅ Daily cost check complete!"
```

### **3.2 Resource Usage Analysis Script**

```bash
#!/bin/bash
# resource-usage-analysis.sh

echo "📊 Resource Usage Analysis"
echo "=========================="

# Check EKS cluster costs
echo "🔍 EKS Cluster Costs:"
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --filter '{
    "Dimensions": {
      "Key": "SERVICE",
      "Values": ["Amazon Elastic Compute Cloud"]
    }
  }' \
  --region us-east-2 \
  --query 'ResultsByTime[0].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
  --output table

# Check RDS costs
echo "🔍 RDS Costs:"
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --filter '{
    "Dimensions": {
      "Key": "SERVICE",
      "Values": ["Amazon Relational Database Service"]
    }
  }' \
  --region us-east-2 \
  --query 'ResultsByTime[0].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
  --output table

echo "✅ Resource usage analysis complete!"
```

## 📈 **Part 4: Cost Optimization Strategies**

### **4.1 EKS Cost Optimization**

```bash
# Use Spot Instances for worker nodes (up to 90% savings)
eksctl create nodegroup \
  --cluster nestjs-prod \
  --name spot-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --spot \
  --region us-east-2

# Enable cluster autoscaler
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

### **4.2 RDS Cost Optimization**

```bash
# Use Reserved Instances for long-term usage
aws rds describe-reserved-db-instances \
  --region us-east-2

# Enable automated backups
aws rds modify-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --backup-retention-period 7 \
  --region us-east-2
```

### **4.3 ElastiCache Cost Optimization**

```bash
# Use smaller instance types
aws elasticache modify-cache-cluster \
  --cache-cluster-id nestjs-prod-redis \
  --cache-node-type cache.t2.micro \
  --region us-east-2
```

## 📊 **Part 5: Cost Analysis Reports**

### **5.1 Weekly Cost Report Script**

```bash
#!/bin/bash
# weekly-cost-report.sh

echo "📊 Weekly Cost Report"
echo "===================="

# Get last 7 days costs
END_DATE=$(date +%Y-%m-%d)
START_DATE=$(date -d "7 days ago" +%Y-%m-%d)

echo "📅 Period: $START_DATE to $END_DATE"

# Generate cost report
aws ce get-cost-and-usage \
  --time-period Start=$START_DATE,End=$END_DATE \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region us-east-2 \
  --query 'ResultsByTime[*].[TimePeriod.Start,TimePeriod.End,Groups[*].[Keys[0],Metrics.BlendedCost.Amount]]' \
  --output table

echo "✅ Weekly cost report complete!"
```

### **5.2 Monthly Cost Summary Script**

```bash
#!/bin/bash
# monthly-cost-summary.sh

echo "📊 Monthly Cost Summary"
echo "======================"

# Get current month costs
CURRENT_MONTH=$(date +%Y-%m)
echo "📅 Month: $CURRENT_MONTH"

# Generate monthly summary
aws ce get-cost-and-usage \
  --time-period Start=$CURRENT_MONTH-01,End=$CURRENT_MONTH-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region us-east-2 \
  --query 'ResultsByTime[0].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
  --output table

echo "✅ Monthly cost summary complete!"
```

## 🎯 **Part 6: Cost Monitoring Dashboard**

### **6.1 Create CloudWatch Dashboard**

```bash
# Create comprehensive cost monitoring dashboard
aws cloudwatch put-dashboard \
  --dashboard-name "bheji-com-cost-dashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
          ],
          "period": 86400,
          "stat": "Maximum",
          "region": "us-east-2",
          "title": "Daily AWS Costs"
        }
      },
      {
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/EKS", "ClusterNodeCount", "ClusterName", "nestjs-prod"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-2",
          "title": "EKS Node Count"
        }
      }
    ]
  }' \
  --region us-east-2
```

## 📱 **Part 7: Mobile Cost Monitoring**

### **7.1 AWS Mobile App Setup**

1. **Download AWS Console Mobile App**
2. **Enable Cost Explorer** in the app
3. **Set up push notifications** for budget alerts
4. **Monitor costs** on the go

### **7.2 Email Notifications Setup**

```bash
# Create SNS topic for cost alerts
aws sns create-topic \
  --name cost-alerts \
  --region us-east-2

# Subscribe to email notifications
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-2:213028525650:cost-alerts \
  --protocol email \
  --notification-endpoint your-email@example.com \
  --region us-east-2
```

## 🚨 **Part 8: Emergency Cost Controls**

### **8.1 Auto-Stop Resources Script**

```bash
#!/bin/bash
# emergency-cost-control.sh

echo "🚨 Emergency Cost Control Activated"
echo "=================================="

# Stop EKS worker nodes
kubectl scale deployment nestjs-app --replicas=0 -n nestjs-prod

# Stop RDS instance (if needed)
aws rds stop-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --region us-east-2

echo "✅ Emergency cost control complete!"
```

### **8.2 Cost Threshold Alerts**

```bash
# Create multiple threshold alerts
aws cloudwatch put-metric-alarm \
  --alarm-name "Cost-Threshold-50" \
  --alarm-description "Alert when monthly costs exceed $50" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 50.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --region us-east-2

aws cloudwatch put-metric-alarm \
  --alarm-name "Cost-Threshold-100" \
  --alarm-description "Alert when monthly costs exceed $100" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 100.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --region us-east-2
```

## 📋 **Part 9: Cost Monitoring Checklist**

### **Daily Tasks:**
- [ ] Check daily cost alerts
- [ ] Review resource usage
- [ ] Monitor free tier usage
- [ ] Check for unexpected charges

### **Weekly Tasks:**
- [ ] Generate weekly cost report
- [ ] Review budget vs actual costs
- [ ] Analyze cost trends
- [ ] Optimize resource usage

### **Monthly Tasks:**
- [ ] Generate monthly cost summary
- [ ] Review and adjust budgets
- [ ] Plan for next month's costs
- [ ] Update cost optimization strategies

## 🎯 **Part 10: Quick Cost Commands**

### **10.1 Check Current Costs**

```bash
# Check today's costs
./daily-cost-check.sh

# Check this month's costs
./monthly-cost-summary.sh

# Check resource usage
./monitor-free-tier.sh
```

### **10.2 Set Up Monitoring**

```bash
# Make scripts executable
chmod +x *.sh

# Set up daily monitoring
crontab -e
# Add: 0 9 * * * /path/to/daily-cost-check.sh

# Set up weekly monitoring
# Add: 0 9 * * 1 /path/to/weekly-cost-report.sh
```

## ✅ **Summary**

With this cost monitoring setup, you can:
- **Track costs** in real-time
- **Set up alerts** to prevent overruns
- **Optimize resources** for better efficiency
- **Plan budgets** for future growth
- **Monitor free tier** usage effectively

**🎉 Your AWS costs are now fully monitored and optimized!**
