# 📊 Application Monitoring Guide for bheji.com

Complete monitoring setup and troubleshooting guide for your NestJS application running on AWS EKS.

## 📋 Monitoring Overview

This guide covers monitoring for:
- **Application Health**: Pod status, logs, and performance
- **Infrastructure**: EKS cluster, ALB, and database
- **Security**: SSL certificates and access logs
- **Costs**: AWS resource usage and billing

## 🚀 **Part 1: Kubernetes Application Monitoring**

### **1.1 Check Application Status**

```bash
# Check all resources in your namespace
kubectl get all -n nestjs-prod

# Check pod status
kubectl get pods -n nestjs-prod

# Check pod details
kubectl describe pods -n nestjs-prod

# Check pod logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod
```

### **1.2 Monitor Pod Health**

```bash
# Check pod health status
kubectl get pods -n nestjs-prod -o wide

# Check pod events
kubectl get events -n nestjs-prod --sort-by='.lastTimestamp'

# Check pod resource usage
kubectl top pods -n nestjs-prod

# Check pod resource limits
kubectl describe pods -n nestjs-prod | grep -A 5 "Limits\|Requests"
```

### **1.3 Monitor Auto-scaling**

```bash
# Check HPA status
kubectl get hpa -n nestjs-prod

# Check HPA details
kubectl describe hpa nestjs-app-hpa -n nestjs-prod

# Check scaling events
kubectl get events -n nestjs-prod --field-selector reason=SuccessfulRescale
```

### **1.4 Monitor Services and Ingress**

```bash
# Check services
kubectl get services -n nestjs-prod

# Check ingress
kubectl get ingress -n nestjs-prod

# Check ingress details
kubectl describe ingress nestjs-app -n nestjs-prod

# Check service endpoints
kubectl get endpoints -n nestjs-prod
```

## 🚀 **Part 2: Application Logs Monitoring**

### **2.1 Real-time Log Monitoring**

```bash
# Follow all pod logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod

# Follow logs from specific pod
kubectl logs -f pod/POD-NAME -n nestjs-prod

# Follow logs with timestamps
kubectl logs -f deployment/nestjs-app -n nestjs-prod --timestamps

# Follow logs from last 10 minutes
kubectl logs -f deployment/nestjs-app -n nestjs-prod --since=10m
```

### **2.2 Log Analysis**

```bash
# Search for errors
kubectl logs deployment/nestjs-app -n nestjs-prod | grep -i error

# Search for specific patterns
kubectl logs deployment/nestjs-app -n nestjs-prod | grep -i "database\|redis\|health"

# Count log entries
kubectl logs deployment/nestjs-app -n nestjs-prod | wc -l

# Get logs from specific time range
kubectl logs deployment/nestjs-app -n nestjs-prod --since=1h | grep -i error
```

### **2.3 Log Export and Analysis**

```bash
# Export logs to file
kubectl logs deployment/nestjs-app -n nestjs-prod > app-logs.txt

# Export logs with timestamps
kubectl logs deployment/nestjs-app -n nestjs-prod --timestamps > app-logs-timestamped.txt

# Export logs from all pods
kubectl logs -l app=nestjs-app -n nestjs-prod --all-containers=true > all-pods-logs.txt
```

## 🚀 **Part 3: AWS CloudWatch Monitoring**

### **3.1 EKS Cluster Monitoring**

```bash
# Check EKS cluster status
aws eks describe-cluster --name nestjs-prod --region ap-south-1

# Check cluster logs
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/nestjs-prod" --region ap-south-1

# Get cluster metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EKS \
  --metric-name ClusterFailedRequestCount \
  --dimensions Name=ClusterName,Value=nestjs-prod \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum \
  --region ap-south-1
```

### **3.2 Application Load Balancer Monitoring**

```bash
# Get ALB details
aws elbv2 describe-load-balancers --region ap-south-1

# Get ALB target health
aws elbv2 describe-target-health \
  --target-group-arn YOUR-TARGET-GROUP-ARN \
  --region ap-south-1

# Get ALB metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=YOUR-ALB-ARN \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum \
  --region ap-south-1
```

### **3.3 Database Monitoring**

```bash
# Check RDS status
aws rds describe-db-instances --region ap-south-1

# Check RDS metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=nestjs-prod-db \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average \
  --region ap-south-1

# Check ElastiCache status
aws elasticache describe-cache-clusters --region ap-south-1
```

## 🚀 **Part 4: Performance Monitoring**

### **4.1 Resource Usage Monitoring**

```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods -n nestjs-prod

# Check resource usage by container
kubectl top pods -n nestjs-prod --containers

# Check resource quotas
kubectl describe quota -n nestjs-prod
```

### **4.2 Network Monitoring**

```bash
# Check network policies
kubectl get networkpolicies -n nestjs-prod

# Check service endpoints
kubectl get endpoints -n nestjs-prod

# Check ingress controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### **4.3 Application Performance Testing**

```bash
# Test application response time
curl -w "@curl-format.txt" -o /dev/null -s https://bheji.com/health

# Create curl format file
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF

# Load testing with Apache Bench
ab -n 1000 -c 10 https://bheji.com/health

# Load testing with wrk
wrk -t12 -c400 -d30s https://bheji.com/health
```

## 🚀 **Part 5: Security Monitoring**

### **5.1 SSL Certificate Monitoring**

```bash
# Check SSL certificate status
aws acm list-certificates --region ap-south-1

# Check certificate expiration
aws acm describe-certificate \
  --certificate-arn "arn:aws:acm:ap-south-1:YOUR-ACCOUNT-ID:certificate/YOUR-CERT-ID" \
  --region ap-south-1

# Test SSL certificate
openssl s_client -connect bheji.com:443 -servername bheji.com

# Check certificate expiration date
echo | openssl s_client -connect bheji.com:443 -servername bheji.com 2>/dev/null | openssl x509 -noout -dates
```

### **5.2 Access Log Monitoring**

```bash
# Check ALB access logs
aws logs describe-log-groups --log-group-name-prefix "/aws/applicationloadbalancer" --region ap-south-1

# Get recent access logs
aws logs filter-log-events \
  --log-group-name "/aws/applicationloadbalancer/your-alb-name" \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --region ap-south-1
```

### **5.3 Security Group Monitoring**

```bash
# Check security groups
aws ec2 describe-security-groups --region ap-south-1

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids sg-xxxxxxxxx \
  --region ap-south-1
```

## 🚀 **Part 6: Cost Monitoring**

### **6.1 AWS Cost Analysis**

```bash
# Get cost and usage report
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --region ap-south-1

# Get service costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region ap-south-1
```

### **6.2 Resource Tagging for Cost Tracking**

```bash
# Tag EKS cluster
aws eks tag-resource \
  --resource-arn "arn:aws:eks:ap-south-1:YOUR-ACCOUNT-ID:cluster/nestjs-prod" \
  --tags Environment=Production,Project=bheji,Owner=DevTeam

# Tag ALB
aws elbv2 add-tags \
  --resource-arns "arn:aws:elasticloadbalancing:ap-south-1:YOUR-ACCOUNT-ID:loadbalancer/app/your-alb-name" \
  --tags Key=Environment,Value=Production Key=Project,Value=bheji
```

## 🚀 **Part 7: Automated Monitoring Scripts**

### **7.1 Health Check Script**

```bash
#!/bin/bash
# health-check.sh

echo "🔍 Checking bheji.com application health..."

# Check DNS resolution
echo "📡 DNS Resolution:"
nslookup bheji.com

# Check HTTPS connectivity
echo "🔒 HTTPS Connectivity:"
curl -I https://bheji.com/health

# Check pod status
echo "🐳 Pod Status:"
kubectl get pods -n nestjs-prod

# Check service status
echo "🌐 Service Status:"
kubectl get services -n nestjs-prod

# Check ingress status
echo "🚪 Ingress Status:"
kubectl get ingress -n nestjs-prod

# Check HPA status
echo "📈 Auto-scaling Status:"
kubectl get hpa -n nestjs-prod

echo "✅ Health check completed!"
```

### **7.2 Performance Monitoring Script**

```bash
#!/bin/bash
# performance-monitor.sh

echo "📊 Performance monitoring for bheji.com..."

# Check resource usage
echo "💻 Resource Usage:"
kubectl top pods -n nestjs-prod

# Check response time
echo "⏱️ Response Time:"
curl -w "Response time: %{time_total}s\n" -o /dev/null -s https://bheji.com/health

# Check SSL certificate
echo "🔐 SSL Certificate:"
echo | openssl s_client -connect bheji.com:443 -servername bheji.com 2>/dev/null | openssl x509 -noout -dates

# Check recent errors
echo "❌ Recent Errors:"
kubectl logs deployment/nestjs-app -n nestjs-prod --since=1h | grep -i error | tail -5

echo "✅ Performance monitoring completed!"
```

### **7.3 Log Analysis Script**

```bash
#!/bin/bash
# log-analysis.sh

echo "📋 Log analysis for bheji.com..."

# Get log summary
echo "📊 Log Summary:"
kubectl logs deployment/nestjs-app -n nestjs-prod --since=24h | wc -l

# Count errors
echo "❌ Error Count:"
kubectl logs deployment/nestjs-app -n nestjs-prod --since=24h | grep -i error | wc -l

# Count warnings
echo "⚠️ Warning Count:"
kubectl logs deployment/nestjs-app -n nestjs-prod --since=24h | grep -i warning | wc -l

# Get top error messages
echo "🔝 Top Error Messages:"
kubectl logs deployment/nestjs-app -n nestjs-prod --since=24h | grep -i error | sort | uniq -c | sort -nr | head -5

echo "✅ Log analysis completed!"
```

## 🚀 **Part 8: CloudWatch Dashboards**

### **8.1 Create Custom Dashboard**

```bash
# Create CloudWatch dashboard
aws cloudwatch put-dashboard \
  --dashboard-name "bheji-app-monitoring" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "your-alb-name"],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "ap-south-1",
          "title": "ALB Metrics",
          "period": 300
        }
      }
    ]
  }' \
  --region ap-south-1
```

## 🚀 **Part 9: Alerting Setup**

### **9.1 Create CloudWatch Alarms**

```bash
# High error rate alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "bheji-high-error-rate" \
  --alarm-description "Alert when error rate is high" \
  --metric-name HTTPCode_Target_5XX_Count \
  --namespace AWS/ApplicationELB \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:ap-south-1:YOUR-ACCOUNT-ID:your-sns-topic \
  --region ap-south-1

# High response time alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "bheji-high-response-time" \
  --alarm-description "Alert when response time is high" \
  --metric-name TargetResponseTime \
  --namespace AWS/ApplicationELB \
  --statistic Average \
  --period 300 \
  --threshold 2 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:ap-south-1:YOUR-ACCOUNT-ID:your-sns-topic \
  --region ap-south-1
```

## 🚀 **Part 10: Monitoring Checklist**

### **Daily Monitoring Tasks:**

- [ ] Check pod status: `kubectl get pods -n nestjs-prod`
- [ ] Check application logs: `kubectl logs -f deployment/nestjs-app -n nestjs-prod`
- [ ] Test application: `curl https://bheji.com/health`
- [ ] Check resource usage: `kubectl top pods -n nestjs-prod`
- [ ] Check auto-scaling: `kubectl get hpa -n nestjs-prod`

### **Weekly Monitoring Tasks:**

- [ ] Review CloudWatch metrics
- [ ] Check SSL certificate status
- [ ] Analyze error logs
- [ ] Review cost reports
- [ ] Check security group rules

### **Monthly Monitoring Tasks:**

- [ ] Review performance trends
- [ ] Update monitoring dashboards
- [ ] Review and update alerts
- [ ] Analyze cost optimization opportunities
- [ ] Review security logs

## 🎯 **Quick Reference Commands**

```bash
# Application status
kubectl get all -n nestjs-prod

# Application logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod

# Resource usage
kubectl top pods -n nestjs-prod

# Health check
curl -I https://bheji.com/health

# SSL certificate
openssl s_client -connect bheji.com:443 -servername bheji.com

# Auto-scaling
kubectl get hpa -n nestjs-prod

# Recent events
kubectl get events -n nestjs-prod --sort-by='.lastTimestamp'
```

## 🚨 **Emergency Response**

### **If Application is Down:**

1. **Check pod status**: `kubectl get pods -n nestjs-prod`
2. **Check logs**: `kubectl logs deployment/nestjs-app -n nestjs-prod`
3. **Check ingress**: `kubectl get ingress -n nestjs-prod`
4. **Check ALB**: `aws elbv2 describe-load-balancers --region ap-south-1`
5. **Restart deployment**: `kubectl rollout restart deployment/nestjs-app -n nestjs-prod`

### **If High Error Rate:**

1. **Check logs for errors**: `kubectl logs deployment/nestjs-app -n nestjs-prod | grep -i error`
2. **Check database connectivity**: Test database connection
3. **Check Redis connectivity**: Test Redis connection
4. **Scale up pods**: `kubectl scale deployment nestjs-app --replicas=5 -n nestjs-prod`

**This comprehensive monitoring guide will help you keep your bheji.com application running smoothly!** 🚀
