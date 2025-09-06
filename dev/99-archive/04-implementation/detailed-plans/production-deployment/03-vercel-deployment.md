# Vercel Deployment Configuration Guide

## Overview

This guide covers setting up Vercel for the three-environment deployment strategy, including project configuration, environment variables, custom domains, and deployment automation.

## Prerequisites

- Vercel CLI installed (`npm i -g vercel@latest`)
- GitHub repository connected
- Vercel account (Pro recommended for team features)
- Domain name ready (optional but recommended)

## Initial Project Setup

### Step 1: Link Your Project

```bash
# Navigate to project root
cd C:\Users\Tom\dev\minerva

# Login to Vercel (if not already)
vercel login

# Link the project
vercel link

# When prompted:
# - Set up and deploy: Y
# - Which scope: [Select your account]
# - Link to existing project? N
# - Project name: minerva-production
# - Directory: ./
# - Build Command: npm run build (default)
# - Output Directory: .next (default)
# - Development Command: npm run dev
```

### Step 2: Configure Build Settings

Update `vercel.json` for production optimizations:

```json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "installCommand": "npm ci --legacy-peer-deps",
  "build": {
    "env": {
      "NODE_OPTIONS": "--max-old-space-size=4096",
      "NEXT_TELEMETRY_DISABLED": "1"
    }
  },
  "functions": {
    "app/api/photos/process/route.ts": {
      "maxDuration": 30
    },
    "app/api/export/*/route.ts": {
      "maxDuration": 60
    }
  },
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "no-store, max-age=0"
        }
      ]
    },
    {
      "source": "/photos/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
```

## Environment Configuration

### Step 1: Set Up Production Environment Variables

```bash
# Add production environment variables
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add SUPABASE_SERVICE_ROLE_KEY production
vercel env add GOOGLE_CLOUD_PROJECT_ID production
vercel env add GOOGLE_CLOUD_CLIENT_EMAIL production
vercel env add GOOGLE_CLOUD_PRIVATE_KEY production
vercel env add NEXT_PUBLIC_APP_URL production
vercel env add NEXT_PUBLIC_POSTHOG_KEY production
vercel env add NEXT_PUBLIC_POSTHOG_HOST production
vercel env add NEXT_PUBLIC_GOOGLE_MAPS_API_KEY production
```

### Step 2: Set Up Preview (Staging) Environment Variables

```bash
# Add staging environment variables
vercel env add NEXT_PUBLIC_SUPABASE_URL preview
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY preview
# ... repeat for all variables with staging values
```

### Step 3: Set Up Development Environment Variables

```bash
# Add development environment variables
vercel env add NEXT_PUBLIC_SUPABASE_URL development
# ... repeat for all variables with development values
```

### Step 4: Verify Environment Variables

```bash
# List all environment variables
vercel env ls

# Pull environment variables locally
vercel env pull .env.vercel.local
```

## Branch Deployment Configuration

### Configure Git Integration

1. **Go to Vercel Dashboard** → Your Project → Settings → Git

2. **Configure Branch Deployments**:
   ```
   Production Branch: main
   Preview Branches: All non-main branches
   ```

3. **Create Staging Branch Rule**:
   - Branch: `staging`
   - Domain: `staging-minerva.vercel.app`
   - Environment: Preview

### Set Up Deployment Protection

1. **Enable Deployment Protection** (Pro feature):
   - Require approval for production deployments
   - Set up deployment protection bypass for CI

2. **Configure Protection Rules**:
   ```
   - main branch → Requires approval
   - staging branch → Auto-deploy
   - feature/* → Auto-deploy to preview
   ```

## Custom Domain Configuration

### Step 1: Add Production Domain

```bash
# Add custom domain
vercel domains add minerva.yourdomain.com

# Or via dashboard:
# Project Settings → Domains → Add Domain
```

### Step 2: Configure DNS

Add the following records to your DNS provider:

```
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

### Step 3: Add Staging Subdomain

```bash
# Add staging subdomain
vercel domains add staging.minerva.yourdomain.com

# Assign to staging branch
vercel alias staging-minerva-[hash].vercel.app staging.minerva.yourdomain.com
```

### Step 4: SSL Configuration

Vercel automatically provisions SSL certificates. Verify:
- Production: https://minerva.yourdomain.com
- Staging: https://staging.minerva.yourdomain.com

## Performance Optimization

### Enable Analytics

1. **Vercel Analytics**:
   ```bash
   # Already installed in package.json
   # @vercel/analytics
   ```

2. **Speed Insights**:
   ```bash
   # Already installed in package.json
   # @vercel/speed-insights
   ```

3. **Configure in Dashboard**:
   - Enable Web Analytics
   - Enable Speed Insights
   - Set up Real User Monitoring

### Image Optimization

Configure Next.js image optimization in `next.config.js`:

```javascript
module.exports = {
  images: {
    domains: ['your-supabase-url.supabase.co'],
    formats: ['image/avif', 'image/webp'],
    minimumCacheTTL: 31536000,
  },
}
```

### Edge Functions

For better performance, consider edge functions for:
- Authentication checks
- Geolocation-based routing
- A/B testing

## Deployment Workflows

### Manual Deployment

```bash
# Deploy to production
vercel --prod

# Deploy to preview (staging)
vercel

# Deploy specific branch
git checkout staging
vercel
```

### Automatic Deployment

Automatic deployments occur on:
- Push to `main` → Production
- Push to `staging` → Staging environment
- Push to any other branch → Preview deployment

### Deployment Commands

```bash
# Check deployment status
vercel ls

# View deployment logs
vercel logs [deployment-url]

# Rollback deployment
vercel rollback [deployment-url]

# Promote preview to production
vercel promote [deployment-url]
```

## Monitoring and Logs

### Access Logs

```bash
# View function logs
vercel logs

# View build logs
vercel logs --build

# Filter by function
vercel logs --filter api/photos/process
```

### Set Up Alerts

1. Go to Project Settings → Integrations
2. Add monitoring integrations:
   - PagerDuty for critical alerts
   - Slack for deployment notifications
   - Email alerts for errors

### Error Tracking

Configure Sentry integration:

1. Add Sentry environment variable:
   ```bash
   vercel env add NEXT_PUBLIC_SENTRY_DSN production
   ```

2. Configure source maps upload in build

## Security Configuration

### Headers and Security

Add security headers in `vercel.json`:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        }
      ]
    }
  ]
}
```

### Environment Variable Security

1. **Never expose sensitive variables**:
   - Use `NEXT_PUBLIC_` only for client-safe values
   - Keep service keys server-side only

2. **Rotate keys regularly**:
   - Set up key rotation schedule
   - Use Vercel's environment variable history

## Deployment Checklist

### Pre-Deployment

- [ ] All environment variables configured
- [ ] Custom domains added and verified
- [ ] SSL certificates active
- [ ] Build optimization configured
- [ ] Security headers added
- [ ] Monitoring integrations set up

### Post-Deployment

- [ ] Verify all pages load correctly
- [ ] Test API endpoints
- [ ] Check image optimization
- [ ] Verify analytics tracking
- [ ] Test error reporting
- [ ] Monitor performance metrics

## Troubleshooting

### Build Failures

```bash
# Check build logs
vercel logs --build

# Common fixes:
# 1. Clear cache
vercel --force

# 2. Check Node version
# Add to package.json:
"engines": {
  "node": ">=18.17.0"
}
```

### Environment Variable Issues

```bash
# Verify variables are set
vercel env ls

# Re-pull variables
vercel env pull

# Check specific environment
vercel env ls production
```

### Domain Issues

```bash
# Check domain status
vercel domains ls

# Verify DNS propagation
nslookup minerva.yourdomain.com

# Remove and re-add domain
vercel domains rm minerva.yourdomain.com
vercel domains add minerva.yourdomain.com
```

## Advanced Configuration

### Cron Jobs

Add to `vercel.json` for scheduled tasks:

```json
{
  "crons": [
    {
      "path": "/api/cleanup",
      "schedule": "0 2 * * *"
    }
  ]
}
```

### Redirects and Rewrites

```json
{
  "redirects": [
    {
      "source": "/old-path",
      "destination": "/new-path",
      "permanent": true
    }
  ],
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "/api/:path*"
    }
  ]
}
```

## Next Steps

1. Complete Vercel project linking
2. Configure all environment variables
3. Set up custom domains
4. Test preview deployments
5. Configure monitoring and alerts
6. Deploy to staging for testing
7. Prepare for production launch