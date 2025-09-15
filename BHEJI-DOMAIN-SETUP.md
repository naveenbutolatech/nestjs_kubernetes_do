# 🌐 BHEJI.COM Domain Setup Guide

Complete step-by-step guide to configure your `bheji.com` domain with AWS EKS and GoDaddy DNS.

## 📋 Prerequisites

- ✅ Domain: `bheji.com` (registered with GoDaddy)
- ✅ AWS EKS cluster running
- ✅ NestJS application deployed
- ✅ AWS CLI configured
- ✅ kubectl configured

## 🚀 **Step 1: Create SSL Certificate for bheji.com**

### **Request SSL Certificate (Free from AWS)**

```bash
# Create SSL certificate for bheji.com
aws acm request-certificate \
  --domain-name bheji.com \
  --subject-alternative-names "*.bheji.com" \
  --validation-method DNS \
  --region ap-south-1
```

**Expected Output:**
```
{
    "CertificateArn": "arn:aws:acm:ap-south-1:YOUR-ACCOUNT-ID:certificate/YOUR-CERT-ID"
}
```

### **Get Certificate ARN**

```bash
# List all certificates to get the ARN
aws acm list-certificates --region ap-south-1
```

**Save this ARN for later use:**
```
arn:aws:acm:ap-south-1:YOUR-ACCOUNT-ID:certificate/YOUR-CERT-ID
```

### **Validate Certificate (if needed)**

```bash
# Get certificate details and validation records
aws acm describe-certificate \
  --certificate-arn "arn:aws:acm:ap-south-1:YOUR-ACCOUNT-ID:certificate/YOUR-CERT-ID" \
  --region ap-south-1
```

## 🚀 **Step 2: Update Helm Configuration**

### **Update values.yaml for bheji.com**

```yaml
# helm-chart/values.yaml
ingress:
  enabled: true
  className: "alb"
  annotations:
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /health
    alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:ap-south-1:YOUR-ACCOUNT-ID:certificate/YOUR-CERT-ID"
    alb.ingress.kubernetes.io/ssl-redirect: "443"
  hosts:
    - host: bheji.com
      paths:
        - path: /
          pathType: Prefix
```

## 🚀 **Step 3: Deploy Application with Domain**

### **Deploy with bheji.com domain**

```bash
# Deploy with bheji.com domain
helm upgrade nestjs-app ./helm-chart \
  --namespace nestjs-prod \
  --set ingress.hosts[0].host=bheji.com \
  --set ingress.annotations."alb\.ingress\.kubernetes\.io/certificate-arn"="arn:aws:acm:ap-south-1:YOUR-ACCOUNT-ID:certificate/YOUR-CERT-ID"
```

### **Verify Deployment**

```bash
# Check if ingress is created
kubectl get ingress -n nestjs-prod

# Check ingress details
kubectl describe ingress nestjs-app -n nestjs-prod
```

## 🚀 **Step 4: Get ALB DNS Name**

### **Get the Load Balancer DNS Name**

```bash
# Get ALB DNS name
kubectl get ingress nestjs-app -n nestjs-prod -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Expected Output:**
```
a1b2c3d4e5f6g7h8-1234567890.ap-south-1.elb.amazonaws.com
```

**Save this DNS name for GoDaddy configuration!**

## 🚀 **Step 5: Configure GoDaddy DNS**

### **Login to GoDaddy**

1. **Go to**: https://godaddy.com
2. **Login** with your GoDaddy account
3. **Go to "My Products"** → **"Domains"**
4. **Find "bheji.com"** and click **"DNS"** or **"Manage DNS"**

### **Add CNAME Record**

1. **Click "Add"** or **"Add Record"**
2. **Select "CNAME"** from the dropdown
3. **Fill in the details:**

```
Type: CNAME
Name: @
Value: a1b2c3d4e5f6g7h8-1234567890.ap-south-1.elb.amazonaws.com
TTL: 600
```

**Replace the Value with your actual ALB DNS name!**

### **Add www Subdomain (Optional)**

If you want `www.bheji.com` to work as well:

```
Type: CNAME
Name: www
Value: a1b2c3d4e5f6g7h8-1234567890.ap-south-1.elb.amazonaws.com
TTL: 600
```

### **Remove Existing A Records (if any)**

- **Delete any existing A records** for `@` and `www`
- **Keep only the CNAME records** you just created

## 🚀 **Step 6: Wait for DNS Propagation**

### **Check DNS Propagation**

```bash
# Check if DNS is propagating
nslookup bheji.com

# Check with different DNS servers
nslookup bheji.com 8.8.8.8
nslookup bheji.com 1.1.1.1
```

**Expected Output:**
```
bheji.com canonical name = a1b2c3d4e5f6g7h8-1234567890.ap-south-1.elb.amazonaws.com
```

### **Timeline**

- **DNS Propagation**: 5-60 minutes
- **Global Propagation**: Up to 24 hours (usually much faster)

## 🚀 **Step 7: Test Your Domain**

### **Test DNS Resolution**

```bash
# Test DNS resolution
nslookup bheji.com
dig bheji.com
```

### **Test HTTPS Connection**

```bash
# Test HTTPS (after DNS propagates)
curl -I https://bheji.com/health

# Test with verbose output
curl -v https://bheji.com/health
```

### **Test in Browser**

1. **Open browser**
2. **Go to**: `https://bheji.com`
3. **Should see**: Your NestJS application
4. **Check SSL**: Green lock icon in address bar

## 🚀 **Step 8: Verify SSL Certificate**

### **Check SSL Certificate Details**

```bash
# Check SSL certificate
openssl s_client -connect bheji.com:443 -servername bheji.com

# Check certificate expiration
echo | openssl s_client -connect bheji.com:443 -servername bheji.com 2>/dev/null | openssl x509 -noout -dates
```

### **Expected SSL Certificate Info**

- **Issuer**: Amazon
- **Subject**: bheji.com
- **Valid**: 13 months from creation
- **Auto-renewal**: ✅ **YES - AWS manages this automatically**
- **Renewal**: Happens 60 days before expiration
- **Cost**: Free (including auto-renewal)

## 🔧 **Complete Commands Summary**

### **All Commands in Order:**

```bash
# 1. Create SSL certificate
aws acm request-certificate \
  --domain-name bheji.com \
  --subject-alternative-names "*.bheji.com" \
  --validation-method DNS \
  --region ap-south-1

# 2. Get certificate ARN
aws acm list-certificates --region ap-south-1

# 3. Deploy with domain
helm upgrade nestjs-app ./helm-chart \
  --namespace nestjs-prod \
  --set ingress.hosts[0].host=bheji.com \
  --set ingress.annotations."alb\.ingress\.kubernetes\.io/certificate-arn"="YOUR-CERT-ARN"

# 4. Get ALB DNS name
kubectl get ingress nestjs-app -n nestjs-prod -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# 5. Test DNS resolution
nslookup bheji.com

# 6. Test HTTPS
curl -I https://bheji.com/health
```

## 🎯 **Expected Results**

### **After Setup:**

- ✅ **Domain**: `https://bheji.com` works
- ✅ **SSL**: Green lock icon in browser
- ✅ **HTTPS Redirect**: HTTP automatically redirects to HTTPS
- ✅ **Health Check**: `https://bheji.com/health` returns 200 OK
- ✅ **Application**: Your NestJS app loads correctly

### **URLs to Test:**

- **Main App**: `https://bheji.com`
- **Health Check**: `https://bheji.com/health`
- **API Endpoints**: `https://bheji.com/api/*`
- **www Subdomain**: `https://www.bheji.com` (if configured)

## 🔄 **SSL Certificate Auto-Renewal**

### **How Auto-Renewal Works:**

1. **AWS monitors** your certificate automatically
2. **60 days before expiration**, AWS starts renewal process
3. **New certificate** is issued and validated
4. **ALB automatically switches** to the new certificate
5. **No downtime** or manual intervention required

### **Check Certificate Status:**

```bash
# Check certificate details and renewal status
aws acm describe-certificate \
  --certificate-arn "arn:aws:acm:ap-south-1:YOUR-ACCOUNT-ID:certificate/YOUR-CERT-ID" \
  --region ap-south-1
```

### **Monitor Certificate Expiration:**

```bash
# Check certificate expiration date
aws acm list-certificates \
  --region ap-south-1 \
  --query 'CertificateSummaryList[?DomainName==`bheji.com`]'
```

### **Set Up CloudWatch Alerts (Optional):**

```bash
# Create CloudWatch alarm for certificate expiration
aws cloudwatch put-metric-alarm \
  --alarm-name "SSL-Certificate-Expiration-bheji.com" \
  --alarm-description "Alert when SSL certificate expires in 30 days" \
  --metric-name DaysToExpiry \
  --namespace AWS/CertificateManager \
  --statistic Minimum \
  --period 86400 \
  --threshold 30 \
  --comparison-operator LessThanThreshold \
  --evaluation-periods 1
```

### **Benefits of AWS ACM:**

- ✅ **Automatic Renewal**: No manual intervention needed
- ✅ **Free Service**: No cost for certificates or renewal
- ✅ **High Availability**: 99.9% uptime SLA
- ✅ **Security**: Industry-standard encryption
- ✅ **Integration**: Works seamlessly with ALB
- ✅ **Monitoring**: CloudWatch integration

## 🔍 **Troubleshooting**

### **Common Issues:**

#### **1. Domain Not Resolving**
```bash
# Check DNS propagation
nslookup bheji.com

# Check if CNAME is correct
dig bheji.com CNAME
```

**Solution**: Wait for DNS propagation or check GoDaddy DNS settings

#### **2. SSL Certificate Error**
```bash
# Check certificate status
aws acm describe-certificate \
  --certificate-arn "YOUR-CERT-ARN" \
  --region ap-south-1
```

**Solution**: Ensure certificate is validated and ARN is correct

#### **3. ALB Not Accessible**
```bash
# Check ingress status
kubectl get ingress nestjs-app -n nestjs-prod

# Check ALB logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

**Solution**: Check security groups and ALB configuration

#### **4. Application Not Loading**
```bash
# Check pod status
kubectl get pods -n nestjs-prod

# Check pod logs
kubectl logs -f deployment/nestjs-app -n nestjs-prod
```

**Solution**: Check application logs and health checks

### **Debug Commands:**

```bash
# Check all resources
kubectl get all -n nestjs-prod

# Check ingress details
kubectl describe ingress nestjs-app -n nestjs-prod

# Check service endpoints
kubectl get endpoints -n nestjs-prod

# Check ALB status
aws elbv2 describe-load-balancers --region ap-south-1
```

## 📊 **Architecture Overview**

```
Internet → bheji.com → GoDaddy DNS → ALB → EKS Ingress → Service → NestJS Pods
```

### **Components:**

1. **GoDaddy DNS**: Routes `bheji.com` to ALB
2. **AWS ALB**: Load balancer with SSL termination
3. **EKS Ingress**: Routes traffic to Kubernetes service
4. **Kubernetes Service**: Load balances between pods
5. **NestJS Pods**: Your application instances

## ⏱️ **Timeline**

- **SSL Certificate**: 5-10 minutes
- **EKS Deployment**: 5-10 minutes
- **GoDaddy DNS Update**: 2-5 minutes
- **DNS Propagation**: 5-60 minutes
- **Total Setup Time**: 15-85 minutes

## 🎉 **Success Checklist**

- [ ] SSL certificate created and validated
- [ ] Helm chart updated with bheji.com
- [ ] Application deployed to EKS
- [ ] ALB DNS name obtained
- [ ] GoDaddy DNS configured with CNAME
- [ ] DNS propagation completed
- [ ] HTTPS working with SSL certificate
- [ ] Application accessible at https://bheji.com
- [ ] Health check endpoint working
- [ ] www subdomain working (if configured)

## 📞 **Support**

If you encounter any issues:

1. **Check the troubleshooting section** above
2. **Verify all commands** were run correctly
3. **Check AWS CloudWatch logs** for ALB
4. **Check Kubernetes logs** for application issues

**Your bheji.com domain will be live and accessible via HTTPS!** 🚀
