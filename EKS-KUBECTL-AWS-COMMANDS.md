# 🚀 EKS, kubectl & AWS Commands Reference

Complete reference guide for managing your NestJS application on AWS EKS.

## 📋 Table of Contents

- [EKSCTL Commands](#eksctl-commands)
- [KUBECTL Commands](#kubectl-commands)
- [AWS CLI Commands](#aws-cli-commands)
- [Most Common Commands](#most-common-commands)
- [Troubleshooting Commands](#troubleshooting-commands)
- [Quick Reference](#quick-reference)

---

## 🚀 **EKSCTL Commands**

### **Cluster Management**

```bash
# Create cluster with node group
eksctl create cluster \
  --name nestjs-prod \
  --region us-east-1 \
  --nodegroup-name free-tier-nodes \
  --node-type t2.micro \
  --nodes 1 \
  --managed

# List all clusters
eksctl get cluster --region us-east-1

# Get specific cluster info
eksctl get cluster --name nestjs-prod --region us-east-1

# Delete cluster (and all resources)
eksctl delete cluster --name nestjs-prod --region us-east-1

# Create cluster with specific VPC
eksctl create cluster \
  --name nestjs-prod \
  --region us-east-1 \
  --vpc-private-subnets subnet-12345,subnet-67890 \
  --vpc-public-subnets subnet-abcde,subnet-fghij
```

### **Node Group Management**

```bash
# Create node group
eksctl create nodegroup \
  --cluster nestjs-prod \
  --region us-east-1 \
  --name free-tier-nodes \
  --node-type t2.micro \
  --nodes 1 \
  --managed

# List node groups
eksctl get nodegroup --cluster nestjs-prod --region us-east-1

# Delete node group
eksctl delete nodegroup \
  --cluster nestjs-prod \
  --name free-tier-nodes \
  --region us-east-1

# Scale node group
eksctl scale nodegroup \
  --cluster nestjs-prod \
  --name free-tier-nodes \
  --nodes 2 \
  --region us-east-1

# Update node group
eksctl update nodegroup \
  --cluster nestjs-prod \
  --name free-tier-nodes \
  --region us-east-1
```

### **IAM Management**

```bash
# Create IAM service account
eksctl create iamserviceaccount \
  --cluster nestjs-prod \
  --name my-service-account \
  --namespace default \
  --attach-policy-arn arn:aws:iam::123456789012:policy/MyPolicy

# List IAM service accounts
eksctl get iamserviceaccount --cluster nestjs-prod --region us-east-1

# Delete IAM service account
eksctl delete iamserviceaccount \
  --cluster nestjs-prod \
  --name my-service-account \
  --namespace default
```

---

## 🔧 **KUBECTL Commands**

### **Cluster Access & Configuration**

```bash
# Configure kubectl for EKS
aws eks update-kubeconfig --region us-east-1 --name nestjs-prod

# Check current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context arn:aws:eks:us-east-1:123456789012:cluster/nestjs-prod

# View kubeconfig
kubectl config view
```

### **Node Management**

```bash
# List all nodes
kubectl get nodes

# List nodes with details
kubectl get nodes -o wide

# Describe specific node
kubectl describe node <node-name>

# Check node resources
kubectl top nodes

# Drain node (for maintenance)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### **Pod Management**

```bash
# List all pods
kubectl get pods --all-namespaces

# List pods in specific namespace
kubectl get pods -n nestjs-prod

# List pods with labels
kubectl get pods -l app=nestjs-app -n nestjs-prod

# Describe pod
kubectl describe pod <pod-name> -n nestjs-prod

# Get pod logs
kubectl logs <pod-name> -n nestjs-prod

# Follow logs in real-time
kubectl logs -f <pod-name> -n nestjs-prod

# Get logs from previous container
kubectl logs <pod-name> -n nestjs-prod --previous

# Execute command in pod
kubectl exec -it <pod-name> -n nestjs-prod -- /bin/bash

# Copy files to/from pod
kubectl cp <pod-name>:/path/to/file ./local-file -n nestjs-prod
kubectl cp ./local-file <pod-name>:/path/to/file -n nestjs-prod

# Delete pod
kubectl delete pod <pod-name> -n nestjs-prod
```

### **Service Management**

```bash
# List all services
kubectl get services --all-namespaces

# List services in namespace
kubectl get services -n nestjs-prod

# Describe service
kubectl describe service <service-name> -n nestjs-prod

# Get service endpoints
kubectl get endpoints -n nestjs-prod

# Port forward to service
kubectl port-forward service/<service-name> 8080:80 -n nestjs-prod
```

### **Deployment Management**

```bash
# List deployments
kubectl get deployments --all-namespaces

# List deployments in namespace
kubectl get deployments -n nestjs-prod

# Describe deployment
kubectl describe deployment <deployment-name> -n nestjs-prod

# Scale deployment
kubectl scale deployment <deployment-name> --replicas=3 -n nestjs-prod

# Update deployment image
kubectl set image deployment/<deployment-name> <container-name>=<new-image> -n nestjs-prod

# Rollout deployment
kubectl rollout status deployment/<deployment-name> -n nestjs-prod

# Rollback deployment
kubectl rollout undo deployment/<deployment-name> -n nestjs-prod

# View rollout history
kubectl rollout history deployment/<deployment-name> -n nestjs-prod
```

### **Namespace Management**

```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace nestjs-prod

# Delete namespace
kubectl delete namespace nestjs-prod

# Switch to namespace
kubectl config set-context --current --namespace=nestjs-prod
```

### **ConfigMap & Secret Management**

```bash
# List configmaps
kubectl get configmaps --all-namespaces

# Create configmap from file
kubectl create configmap <config-name> --from-file=config.properties -n nestjs-prod

# Create configmap from literal
kubectl create configmap <config-name> --from-literal=key=value -n nestjs-prod

# Describe configmap
kubectl describe configmap <config-name> -n nestjs-prod

# List secrets
kubectl get secrets --all-namespaces

# Create secret
kubectl create secret generic <secret-name> --from-literal=username=admin --from-literal=password=secret -n nestjs-prod

# Describe secret
kubectl describe secret <secret-name> -n nestjs-prod
```

### **Resource Management**

```bash
# List all resources
kubectl get all --all-namespaces

# List specific resource type
kubectl get <resource-type> --all-namespaces

# Get resource with custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp

# Watch resources
kubectl get pods -w -n nestjs-prod

# Get resource YAML
kubectl get pod <pod-name> -o yaml -n nestjs-prod

# Apply YAML file
kubectl apply -f deployment.yaml

# Delete from YAML file
kubectl delete -f deployment.yaml

# Dry run
kubectl apply -f deployment.yaml --dry-run=client
```

---

## ☁️ **AWS CLI Commands**

### **EKS Management**

```bash
# List EKS clusters
aws eks list-clusters --region us-east-1

# Describe cluster
aws eks describe-cluster --name nestjs-prod --region us-east-1

# Update cluster version
aws eks update-cluster-version --name nestjs-prod --kubernetes-version 1.28 --region us-east-1

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name nestjs-prod

# List node groups
aws eks list-nodegroups --cluster-name nestjs-prod --region us-east-1

# Describe node group
aws eks describe-nodegroup --cluster-name nestjs-prod --nodegroup-name free-tier-nodes --region us-east-1
```

### **EC2 Management**

```bash
# List instances
aws ec2 describe-instances --region us-east-1

# List instances with filters
aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running"

# List VPCs
aws ec2 describe-vpcs --region us-east-1

# List subnets
aws ec2 describe-subnets --region us-east-1

# List security groups
aws ec2 describe-security-groups --region us-east-1

# List route tables
aws ec2 describe-route-tables --region us-east-1

# List key pairs
aws ec2 describe-key-pairs --region us-east-1

# Create key pair
aws ec2 create-key-pair --key-name my-key --region us-east-1

# Delete key pair
aws ec2 delete-key-pair --key-name my-key --region us-east-1
```

### **RDS Management**

```bash
# Create RDS PostgreSQL instance
aws rds create-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --db-instance-class db.t2.micro \
  --engine postgres \
  --engine-version 15.4 \
  --master-username admin \
  --master-user-password YourPassword123! \
  --allocated-storage 20 \
  --storage-type gp2 \
  --backup-retention-period 7 \
  --multi-az \
  --publicly-accessible \
  --region us-east-1

# List RDS instances
aws rds describe-db-instances --region us-east-1

# Describe specific RDS instance
aws rds describe-db-instances --db-instance-identifier nestjs-prod-db --region us-east-1

# Delete RDS instance
aws rds delete-db-instance \
  --db-instance-identifier nestjs-prod-db \
  --skip-final-snapshot \
  --region us-east-1

# Create RDS snapshot
aws rds create-db-snapshot \
  --db-instance-identifier nestjs-prod-db \
  --db-snapshot-identifier nestjs-prod-snapshot-$(date +%Y%m%d) \
  --region us-east-1
```

### **ElastiCache Management**

```bash
# Create Redis cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id nestjs-prod-redis \
  --cache-node-type cache.t2.micro \
  --engine redis \
  --engine-version 7.0 \
  --num-cache-nodes 1 \
  --port 6379 \
  --region us-east-1

# List Redis clusters
aws elasticache describe-cache-clusters --region us-east-1

# Describe specific Redis cluster
aws elasticache describe-cache-clusters \
  --cache-cluster-id nestjs-prod-redis \
  --region us-east-1

# Delete Redis cluster
aws elasticache delete-cache-cluster \
  --cache-cluster-id nestjs-prod-redis \
  --region us-east-1
```

### **ECR Management**

```bash
# Create ECR repository
aws ecr create-repository --repository-name nestjs-app-new-ecr --region us-east-1

# List ECR repositories
aws ecr describe-repositories --region us-east-1

# ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 213028525650.dkr.ecr.us-east-1.amazonaws.com

# List images in repository
aws ecr list-images --repository-name nestjs-app-new-ecr --region us-east-1

# Delete image
aws ecr batch-delete-image \
  --repository-name nestjs-app-new-ecr \
  --image-ids imageTag=latest \
  --region us-east-1

# Delete repository
aws ecr delete-repository \
  --repository-name nestjs-app-new-ecr \
  --force \
  --region us-east-1
```

### **CloudFormation Management**

```bash
# List stacks
aws cloudformation list-stacks --region us-east-1

# Describe stack
aws cloudformation describe-stacks --stack-name eksctl-nestjs-prod-cluster --region us-east-1

# List stack events
aws cloudformation describe-stack-events \
  --stack-name eksctl-nestjs-prod-cluster \
  --region us-east-1

# Delete stack
aws cloudformation delete-stack --stack-name eksctl-nestjs-prod-cluster --region us-east-1

# Wait for stack operation
aws cloudformation wait stack-create-complete \
  --stack-name eksctl-nestjs-prod-cluster \
  --region us-east-1
```

### **Service Quotas & Limits**

```bash
# Check vCPU quota
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-0263D0A3 \
  --region us-east-1

# List all EC2 quotas
aws service-quotas list-service-quotas \
  --service-code ec2 \
  --region us-east-1

# Request quota increase
aws service-quotas request-service-quota-increase \
  --service-code ec2 \
  --quota-code L-0263D0A3 \
  --desired-value 4.0 \
  --region us-east-1
```

### **Cost & Billing**

```bash
# Get cost and usage
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --region us-east-1

# Get cost by service
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region us-east-1
```

---

## 🎯 **Most Common Commands**

### **Daily Operations**

```bash
# Check cluster status
eksctl get cluster --region us-east-1
kubectl get nodes
kubectl get pods --all-namespaces

# Deploy application
helm install nestjs-app ./helm-chart \
  --namespace nestjs-prod \
  --create-namespace

# Check application status
kubectl get pods -n nestjs-prod
kubectl get services -n nestjs-prod
kubectl get ingress -n nestjs-prod

# View application logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod

# Scale application
kubectl scale deployment nestjs-app --replicas=3 -n nestjs-prod
```

### **Monitoring & Debugging**

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n nestjs-prod

# Check events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Check pod status
kubectl describe pod <pod-name> -n nestjs-prod

# Check service endpoints
kubectl get endpoints -n nestjs-prod

# Port forward for testing
kubectl port-forward service/nestjs-app 3000:80 -n nestjs-prod
```

---

## 🔧 **Troubleshooting Commands**

### **Pod Issues**

```bash
# Check pod events
kubectl describe pod <pod-name> -n nestjs-prod

# Check pod logs
kubectl logs <pod-name> -n nestjs-prod --previous

# Execute debug shell
kubectl exec -it <pod-name> -n nestjs-prod -- /bin/bash

# Check resource limits
kubectl describe pod <pod-name> -n nestjs-prod | grep -A 5 "Limits\|Requests"
```

### **Service Issues**

```bash
# Check service endpoints
kubectl get endpoints -n nestjs-prod

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup <service-name>

# Check service DNS
kubectl exec -it <pod-name> -n nestjs-prod -- nslookup <service-name>
```

### **Network Issues**

```bash
# Check network policies
kubectl get networkpolicies --all-namespaces

# Test network connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- <service-url>

# Check DNS resolution
kubectl exec -it <pod-name> -n nestjs-prod -- nslookup kubernetes.default
```

### **Storage Issues**

```bash
# Check persistent volumes
kubectl get pv

# Check persistent volume claims
kubectl get pvc -n nestjs-prod

# Check storage classes
kubectl get storageclass

# Describe storage issues
kubectl describe pvc <pvc-name> -n nestjs-prod
```

---

## 📚 **Quick Reference**

### **Essential Commands**

| Task | Command |
|------|---------|
| **Create EKS cluster** | `eksctl create cluster --name nestjs-prod --region us-east-1 --nodegroup-name free-tier-nodes --node-type t2.micro --nodes 1 --managed` |
| **Configure kubectl** | `aws eks update-kubeconfig --region us-east-1 --name nestjs-prod` |
| **List nodes** | `kubectl get nodes` |
| **List pods** | `kubectl get pods --all-namespaces` |
| **View logs** | `kubectl logs -f deployment/nestjs-app -n nestjs-prod` |
| **Scale deployment** | `kubectl scale deployment nestjs-app --replicas=3 -n nestjs-prod` |
| **Port forward** | `kubectl port-forward service/nestjs-app 3000:80 -n nestjs-prod` |
| **Delete cluster** | `eksctl delete cluster --name nestjs-prod --region us-east-1` |

### **Useful Aliases**

```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kx='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
```

### **Common Shortcuts**

```bash
# Quick pod access
kubectl get pods -n nestjs-prod | grep nestjs-app

# Quick service access
kubectl get services -n nestjs-prod | grep nestjs-app

# Quick logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod

# Quick describe
kubectl describe pod $(kubectl get pods -n nestjs-prod | grep nestjs-app | awk '{print $1}') -n nestjs-prod
```

---

## 🚨 **Emergency Commands**

### **Quick Recovery**

```bash
# Restart deployment
kubectl rollout restart deployment/nestjs-app -n nestjs-prod

# Scale down and up
kubectl scale deployment nestjs-app --replicas=0 -n nestjs-prod
kubectl scale deployment nestjs-app --replicas=1 -n nestjs-prod

# Delete and recreate pod
kubectl delete pod $(kubectl get pods -n nestjs-prod | grep nestjs-app | awk '{print $1}') -n nestjs-prod

# Check cluster health
kubectl get componentstatuses
kubectl get nodes -o wide
```

### **Cleanup Commands**

```bash
# Delete all resources in namespace
kubectl delete all --all -n nestjs-prod

# Delete namespace
kubectl delete namespace nestjs-prod

# Clean up failed pods
kubectl delete pods --field-selector=status.phase=Failed --all-namespaces
```

---

**🎉 This reference covers all the essential commands for managing your NestJS application on AWS EKS!**
