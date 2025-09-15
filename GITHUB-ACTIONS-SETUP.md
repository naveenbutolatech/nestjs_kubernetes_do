# GitHub Actions CI/CD Setup Guide

- ✅ **Automated deployments** on code push
- ✅ **Consistent builds** across environments
- ✅ **Rollback capabilities** if deployment fails
- ✅ **Environment separation** (dev vs prod)
- ✅ **Security** with encrypted secrets
- ✅ **Audit trail** of all deployments

### **1. Development Workflow (`.github/workflows/deploy-dev.yml`)**
- **Triggers:** Push to `dev` branch
- **Actions:** Build → Push to ECR → Deploy to EC2
- **Environment:** Development server
