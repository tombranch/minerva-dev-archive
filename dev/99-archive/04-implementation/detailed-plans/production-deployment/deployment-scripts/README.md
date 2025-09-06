# Deployment Scripts

This directory contains automation scripts for production deployment tasks.

## Scripts Overview

- **`setup-environments.sh`** - Automated environment setup and validation
- **`migrate-database.sh`** - Database migration helper with safety checks
- **`verify-deployment.sh`** - Post-deployment verification and testing
- **`rollback-deployment.sh`** - Emergency rollback automation
- **`health-check.sh`** - Comprehensive health check script

## Usage

Make scripts executable:
```bash
chmod +x deployment-scripts/*.sh
```

Run with appropriate environment variables set.