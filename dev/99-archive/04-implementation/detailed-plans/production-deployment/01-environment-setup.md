# Environment Configuration Guide

## Overview

This guide details the three-environment architecture for Minerva and how to configure each environment properly. Following this approach ensures safe development, thorough testing, and reliable production deployments.

## Environment Architecture

### Development Environment
- **Purpose**: Active feature development and local testing
- **Database**: Current remote Supabase project (already configured)
- **Deployment**: Local development server and Vercel preview deployments
- **Branch**: Feature branches
- **URL**: `http://localhost:3000` or `https://minerva-*.vercel.app`

### Staging Environment
- **Purpose**: Pre-production testing and user acceptance testing
- **Database**: Dedicated Supabase project (to be created)
- **Deployment**: Dedicated Vercel staging environment
- **Branch**: `staging`
- **URL**: `https://staging-minerva.vercel.app`

### Production Environment
- **Purpose**: Live application for end users
- **Database**: Dedicated Supabase project (to be created)
- **Deployment**: Vercel production environment
- **Branch**: `main`
- **URL**: `https://minerva.yourdomain.com` or `https://minerva.vercel.app`

## Environment Variables Structure

### Core Variables Required for All Environments

```bash
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
SUPABASE_DB_PASSWORD=

# Google Cloud Vision API
GOOGLE_CLOUD_PROJECT_ID=
GOOGLE_CLOUD_CLIENT_EMAIL=
GOOGLE_CLOUD_PRIVATE_KEY=

# Application Configuration
NEXT_PUBLIC_APP_URL=
NODE_ENV=

# Analytics
NEXT_PUBLIC_POSTHOG_KEY=
NEXT_PUBLIC_POSTHOG_HOST=

# Google Maps (for location features)
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=
```

### Environment-Specific Configurations

#### Development (.env.local)
```bash
# Development-specific settings
NODE_ENV=development
NEXT_PUBLIC_APP_URL=http://localhost:3000
MINERVA_DEV_MODE=true

# Development Supabase (existing project)
NEXT_PUBLIC_SUPABASE_URL=https://vyjgfysepbkaquganpdi.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_dev_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_dev_service_role_key

# Development PostHog (optional)
NEXT_PUBLIC_POSTHOG_KEY=phc_development_key
```

#### Staging (.env.staging.local)
```bash
# Staging-specific settings
NODE_ENV=production
NEXT_PUBLIC_APP_URL=https://staging-minerva.vercel.app
MINERVA_DEV_MODE=false

# Staging Supabase (new project)
NEXT_PUBLIC_SUPABASE_URL=https://staging-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_staging_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_staging_service_role_key

# Staging PostHog
NEXT_PUBLIC_POSTHOG_KEY=phc_staging_key

# Staging-specific limits
RATE_LIMIT_MAX=200
MAX_FILE_SIZE_MB=10
```

#### Production (.env.production.local)
```bash
# Production-specific settings
NODE_ENV=production
NEXT_PUBLIC_APP_URL=https://minerva.yourdomain.com
MINERVA_DEV_MODE=false

# Production Supabase (new project)
NEXT_PUBLIC_SUPABASE_URL=https://production-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_production_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_production_service_role_key

# Production PostHog
NEXT_PUBLIC_POSTHOG_KEY=phc_production_key

# Production security settings
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW_MS=900000
SESSION_TIMEOUT_MINUTES=1440
CSRF_ENABLED=true

# Production monitoring
NEXT_PUBLIC_SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
LOG_LEVEL=error

# Production limits
MAX_FILE_SIZE_MB=10
MAX_USERS_PER_ORG=100
DEFAULT_AI_COST_LIMIT_DAILY=10.00
DEFAULT_AI_COST_LIMIT_MONTHLY=300.00
```

## File Organization

### Local Environment Files
```
minerva/
├── .env.local                 # Development environment (git ignored)
├── .env.staging.local         # Staging environment (git ignored)
├── .env.production.local      # Production environment (git ignored)
├── .env.example               # Template with all variables (in git)
```

### Vercel Environment Variables
- Store all production and staging variables in Vercel dashboard
- Never commit actual environment files to git
- Use Vercel CLI to manage: `vercel env add`

## Setting Up Each Environment

### Step 1: Development Environment (Already Complete)
Your current `.env.local` file is already configured for development.

### Step 2: Create Staging Environment File
```bash
# Copy template
cp .env.example .env.staging.local

# Edit with staging values
# Update all URLs and keys for staging
```

### Step 3: Create Production Environment File
```bash
# Copy template
cp .env.example .env.production.local

# Edit with production values
# Use production-grade credentials
```

### Step 4: Backup Environment Files
```bash
# Always backup before changes
./scripts/backup-env.bat

# Creates timestamped backups in:
# C:\Users\Tom\Documents\Minerva-Backups\
```

## Security Best Practices

### 1. Credential Management
- Use different API keys for each environment
- Rotate production keys regularly
- Never share service role keys
- Use least-privilege principle

### 2. Environment Isolation
- Separate Google Cloud projects for staging/production
- Separate Supabase projects (never share databases)
- Different PostHog projects for analytics
- Isolated error tracking environments

### 3. Access Control
- Limit production access to essential personnel
- Use Vercel's team features for access control
- Enable 2FA on all production accounts
- Audit access regularly

### 4. Secret Storage
- Use Vercel environment variables for deployment
- Keep local files only for development
- Use `NEXT_PUBLIC_` prefix only for client-safe variables
- Store service keys server-side only

## Environment Variable Validation

### Required Variables Checklist
- [ ] All Supabase credentials (URL, anon key, service role key)
- [ ] Google Cloud Vision API credentials
- [ ] Application URL configured correctly
- [ ] PostHog analytics keys
- [ ] Google Maps API key
- [ ] NODE_ENV set appropriately

### Validation Script
Create a validation script to check all required variables:

```javascript
// scripts/validate-env.js
const required = [
  'NEXT_PUBLIC_SUPABASE_URL',
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  'SUPABASE_SERVICE_ROLE_KEY',
  'GOOGLE_CLOUD_PROJECT_ID',
  'NEXT_PUBLIC_APP_URL'
];

const missing = required.filter(key => !process.env[key]);
if (missing.length > 0) {
  console.error('Missing required environment variables:', missing);
  process.exit(1);
}
```

## Switching Between Environments

### Local Development
```bash
# Default uses .env.local
npm run dev:safe
```

### Testing with Staging Config
```bash
# Temporarily use staging config locally
cp .env.staging.local .env.local
npm run dev:safe
# Remember to restore development config after
```

### Building for Production
```bash
# Build with production optimizations
NODE_ENV=production npm run build
```

## Common Issues and Solutions

### Issue: Environment variables not loading
- Ensure file is named correctly (`.env.local`)
- Restart development server after changes
- Check for typos in variable names

### Issue: Wrong environment in deployment
- Verify branch deployment settings in Vercel
- Check NODE_ENV is set correctly
- Ensure Vercel has correct environment variables

### Issue: Secrets exposed in client
- Only use `NEXT_PUBLIC_` for client-safe values
- Keep service keys server-side only
- Audit with: `grep -r "NEXT_PUBLIC_" .`

## Next Steps

1. Create staging and production environment files
2. Set up Supabase projects (see `02-supabase-setup.md`)
3. Configure Vercel deployments (see `03-vercel-deployment.md`)
4. Test environment switching locally
5. Validate all configurations before deployment