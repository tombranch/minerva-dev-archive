# Production Deployment Guide

**Document Version:** 1.0  
**Created:** July 13, 2025  
**Target Environment:** Production  
**Estimated Deployment Time:** 4-6 hours

---

## 📋 Overview

This guide provides step-by-step instructions for deploying the completed Minerva Machine Safety Photo Organizer to production. The deployment process is designed to minimize downtime and ensure a smooth transition from development to production use.

### Deployment Architecture
- **Frontend**: Vercel (Next.js optimized hosting)
- **Backend**: Supabase (managed PostgreSQL + storage)
- **Monitoring**: Sentry + Custom dashboards
- **CDN**: Automatic via Vercel
- **Domain**: Custom domain with SSL

---

## 🚀 Pre-Deployment Checklist

### Code Quality Verification
- [ ] All 4 chunks completed and tested
- [ ] 100% test coverage on critical paths
- [ ] Zero TypeScript errors
- [ ] Zero ESLint warnings
- [ ] Performance tests passing
- [ ] Security review completed

### Environment Preparation
- [ ] Production Supabase project configured
- [ ] Google Cloud Vision API keys obtained
- [ ] Sentry project created
- [ ] Custom domain DNS configured
- [ ] SSL certificates ready
- [ ] Environment variables documented

### Data Migration Planning
- [ ] Database schema migration plan
- [ ] Test data cleanup strategy
- [ ] Backup procedures verified
- [ ] Rollback plan documented

---

## 🛠️ Environment Setup

### 1. Supabase Production Setup

#### Database Configuration
```sql
-- Production database setup
-- 1. Create organization tables
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Run all migrations in order
\i supabase/migrations/20250701000000_initial_schema.sql
\i supabase/migrations/20250702000000_auth_setup.sql
\i supabase/migrations/20250703000000_photo_schema.sql
\i supabase/migrations/20250704000000_ai_integration.sql
\i supabase/migrations/20250705000000_search_infrastructure.sql
\i supabase/migrations/20250714000000_ai_tables.sql

-- 3. Verify all tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- 4. Verify RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';
```

#### Database Backups (Critical)
Before deploying, ensure data safety is configured in your Supabase production project.
- **Enable Automated Backups**: In the Supabase dashboard, navigate to `Database` -> `Backups` and ensure daily backups are enabled.
- **Enable Point-in-Time Recovery (PITR)**: For the initial launch, it is highly recommended to enable PITR for granular recovery options. This can also be configured in the `Backups` section.

#### Storage Configuration
```javascript
// Supabase storage bucket setup
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// Create photos bucket
await supabase.storage.createBucket('photos', {
  public: false,
  allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
  fileSizeLimit: 10485760, // 10MB
});

// Create temporary upload bucket
await supabase.storage.createBucket('temp-uploads', {
  public: false,
  allowedMimeTypes: ['image/jpeg', 'image/png'],
  fileSizeLimit: 10485760,
  retentionPeriod: 86400, // 24 hours
});
```

### 2. Google Cloud Setup

#### Vision API Configuration
```bash
# Enable Google Cloud Vision API
gcloud services enable vision.googleapis.com

# Create service account
gcloud iam service-accounts create minerva-vision-api \
  --display-name="Minerva Vision API Service Account"

# Grant necessary permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:minerva-vision-api@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/ml.developer"

# Create and download key
gcloud iam service-accounts keys create minerva-vision-key.json \
  --iam-account=minerva-vision-api@PROJECT_ID.iam.gserviceaccount.com
```

#### Cost Management Setup
```bash
# Set up billing alerts
gcloud alpha billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Minerva API Budget" \
  --budget-amount=100USD \
  --threshold-rules=percent=50,basis=CURRENT_SPEND \
  --threshold-rules=percent=90,basis=CURRENT_SPEND \
  --threshold-rules=percent=100,basis=CURRENT_SPEND
```

### 3. Sentry Configuration

#### Project Setup
```javascript
// sentry.client.config.js
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: 'production',
  tracesSampleRate: 0.1,
  debug: false,
  
  beforeSend(event, hint) {
    // Filter out sensitive information
    if (event.user) {
      delete event.user.email;
      delete event.user.ip_address;
    }
    
    // Add custom tags
    event.tags = {
      ...event.tags,
      deployment: 'production',
      version: process.env.NEXT_PUBLIC_APP_VERSION,
    };
    
    return event;
  },
  
  integrations: [
    new Sentry.BrowserTracing({
      tracePropagationTargets: [
        'localhost',
        /^https:\/\/minerva\.example\.com/,
      ],
    }),
  ],
});
```

---

## 🚢 Deployment Process

### Phase 1: Infrastructure Deployment (2 hours)

#### Step 1: Database Migration
```bash
# 1. Backup existing data (if any)
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. Run migrations
npm run db:migrate:prod

# 3. Verify migration success
npm run db:verify

# 4. Seed initial data
npm run db:seed:prod
```

#### Step 2: Environment Configuration
```bash
# Production environment variables
export NEXT_PUBLIC_SUPABASE_URL="https://your-project.supabase.co"
export NEXT_PUBLIC_SUPABASE_ANON_KEY="your-anon-key"
export SUPABASE_SERVICE_KEY="your-service-key"
export GOOGLE_APPLICATION_CREDENTIALS="./minerva-vision-key.json"
export GOOGLE_CLOUD_PROJECT_ID="your-project-id"
export NEXT_PUBLIC_SENTRY_DSN="your-sentry-dsn"
export NEXT_PUBLIC_POSTHOG_KEY="your-posthog-key"
export NEXT_PUBLIC_POSTHOG_HOST="https://app.posthog.com"
export NEXTAUTH_SECRET="your-nextauth-secret"
export NEXTAUTH_URL="https://minerva.example.com"
```

#### Step 3: Vercel Deployment
```bash
# 1. Install Vercel CLI
npm i -g vercel

# 2. Login to Vercel
vercel login

# 3. Configure project
vercel

# 4. Set environment variables
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add SUPABASE_SERVICE_KEY production
# ... (add all environment variables)

# 5. Deploy to production
vercel --prod
```

### Phase 2: Application Deployment (1 hour)

#### Step 1: Build Verification
```bash
# 1. Final build test locally
npm run build
npm run start

# 2. Run production test suite
npm run test:production

# 3. Performance verification
npm run test:performance
```

#### Step 2: Feature Flags (if using)
```typescript
// Enable features progressively
const featureFlags = {
  bulkOperations: true,
  wordExport: true,
  advancedSearch: true,
  adminInterface: false, // Enable after admin training
};
```

### Phase 3: Monitoring Setup (1 hour)

#### Step 1: Sentry Integration
```bash
# 1. Deploy with Sentry
vercel env add NEXT_PUBLIC_SENTRY_DSN production
vercel --prod

# 2. Verify error tracking
curl -X POST https://minerva.example.com/api/test-error

# 3. Check Sentry dashboard
```

#### Step 2: Performance Monitoring
```bash
# 1. Set up Vercel Analytics
vercel analytics enable

# 2. Configure custom metrics
vercel env add ENABLE_ANALYTICS true
```

#### Step 3: Cost Monitoring
```typescript
// Verify cost tracking is active
const costMetrics = await CostTrackingService.getDailyCosts('production-org');
console.log('Cost tracking active:', costMetrics.length > 0);
```

### Phase 4: Domain & SSL (30 minutes)

#### Step 1: Domain Configuration
```bash
# 1. Add custom domain in Vercel
vercel domains add minerva.example.com

# 2. Configure DNS records
# A record: @ -> 76.76.19.61
# CNAME record: www -> cname.vercel-dns.com
```

#### Step 2: SSL Verification
```bash
# Verify SSL certificate
curl -I https://minerva.example.com
```

---

## 🧪 Post-Deployment Verification

### Smoke Tests
```typescript
// Automated post-deployment tests
describe('Production Smoke Tests', () => {
  test('application loads correctly', async () => {
    const response = await fetch('https://minerva.example.com');
    expect(response.status).toBe(200);
  });

  test('authentication works', async () => {
    const response = await fetch('https://minerva.example.com/api/auth/session');
    expect(response.status).toBe(200);
  });

  test('database connection active', async () => {
    const response = await fetch('https://minerva.example.com/api/health');
    const health = await response.json();
    expect(health.database).toBe('healthy');
  });

  test('AI processing available', async () => {
    const response = await fetch('https://minerva.example.com/api/ai/health');
    const health = await response.json();
    expect(health.vision_api).toBe('available');
  });
});
```

### Manual Verification Checklist
- [ ] Home page loads correctly
- [ ] User registration/login works
- [ ] Photo upload functions
- [ ] AI processing triggers
- [ ] Search returns results
- [ ] Bulk operations work
- [ ] Export features function
- [ ] Mobile experience optimal
- [ ] Error tracking active
- [ ] Performance metrics collecting

### Performance Verification
```bash
# Load testing with production data
npx playwright test --config=playwright.prod.config.ts

# Performance monitoring
npm run test:lighthouse:prod
```

---

## 🔍 Monitoring & Alerting

### Critical Alerts Setup

#### Application Health
```typescript
// Health check endpoint
// app/api/health/route.ts
export async function GET() {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    database: 'checking...',
    storage: 'checking...',
    ai_service: 'checking...',
  };

  try {
    // Database health
    const dbResult = await supabase.from('users').select('count').limit(1);
    health.database = dbResult.error ? 'unhealthy' : 'healthy';

    // Storage health
    const storageResult = await supabase.storage.from('photos').list('', { limit: 1 });
    health.storage = storageResult.error ? 'unhealthy' : 'healthy';

    // AI service health
    const visionHealth = await checkGoogleVisionAPI();
    health.ai_service = visionHealth ? 'healthy' : 'unhealthy';

    const overallHealthy = Object.values(health).every(v => v === 'healthy' || v === health.status || v === health.timestamp);
    health.status = overallHealthy ? 'healthy' : 'degraded';

  } catch (error) {
    health.status = 'unhealthy';
  }

  return NextResponse.json(health);
}
```

#### Error Rate Monitoring
```javascript
// Sentry alert rules
const alertRules = [
  {
    name: 'High Error Rate',
    condition: 'event.count > 10',
    timeWindow: '5m',
    severity: 'critical'
  },
  {
    name: 'AI Processing Failures',
    condition: 'event.tags.component = "ai-processing" AND event.level = "error"',
    timeWindow: '10m',
    severity: 'high'
  },
  {
    name: 'Upload Failures',
    condition: 'event.tags.action = "photo-upload" AND event.level = "error"',
    timeWindow: '5m',
    severity: 'medium'
  }
];
```

#### Cost Monitoring
```typescript
// Daily cost report
const costReport = {
  daily_limit: 10.00, // $10 per day
  monthly_limit: 200.00, // $200 per month
  alert_thresholds: [0.5, 0.8, 0.9, 1.0], // 50%, 80%, 90%, 100%
  recipients: ['admin@example.com', 'team@example.com']
};
```

### Dashboard Setup
```typescript
// Admin dashboard widgets
const dashboardWidgets = [
  {
    type: 'metric',
    title: 'Daily Active Users',
    query: 'users.last_seen > now() - interval "24 hours"'
  },
  {
    type: 'metric', 
    title: 'Photos Uploaded Today',
    query: 'photos.created_at > current_date'
  },
  {
    type: 'metric',
    title: 'AI Processing Queue',
    query: 'photos.ai_processing_status = "pending"'
  },
  {
    type: 'chart',
    title: 'Error Rate (24h)',
    query: 'errors grouped by hour'
  },
  {
    type: 'chart',
    title: 'API Costs (30d)',
    query: 'ai_cost_tracking grouped by service'
  }
];
```

---

## 🔄 Rollback Procedures

### Emergency Rollback
```bash
# 1. Immediate rollback to previous version
vercel rollback

# 2. Database rollback (if needed)
pg_restore backup_YYYYMMDD_HHMMSS.sql

# 3. Clear CDN cache
vercel purge-cache

# 4. Notify team
echo "Production rollback completed at $(date)" | mail -s "Minerva Rollback" team@example.com
```

### Partial Rollback (Feature Flags)
```typescript
// Disable problematic features
const emergencyFlags = {
  bulkOperations: false,
  wordExport: false,
  advancedSearch: true,
  adminInterface: true,
};

// Deploy flag changes only
vercel env add FEATURE_FLAGS "$(echo $emergencyFlags | jq -c .)"
vercel --prod
```

---

## 📊 Success Metrics

### Technical Metrics
- **Uptime**: 99.9% target
- **Response Time**: <500ms for 95% of requests
- **Error Rate**: <0.1% of all requests
- **AI Processing Success**: >95% success rate

### Business Metrics
- **User Adoption**: Track daily/weekly active users
- **Feature Usage**: Monitor feature adoption rates
- **Performance**: Photo upload and processing times
- **Cost Efficiency**: API costs per user per month

### Monitoring Dashboard
```typescript
const productionMetrics = {
  technical: {
    uptime: '99.95%',
    avg_response_time: '245ms',
    error_rate: '0.03%',
    ai_success_rate: '97.2%'
  },
  business: {
    daily_active_users: 45,
    photos_uploaded_today: 234,
    reports_generated: 12,
    user_satisfaction: 4.7
  },
  costs: {
    daily_api_cost: '$3.45',
    monthly_projection: '$89.50',
    cost_per_user: '$1.99'
  }
};
```

---

## 📞 Support & Escalation

### Incident Response Team
- **Primary On-Call**: Technical Lead
- **Secondary On-Call**: Full-Stack Developer  
- **Escalation**: Product Manager
- **Critical Issues**: CTO

### Support Contacts
- **Technical Issues**: support@example.com
- **User Training**: training@example.com
- **Billing Questions**: billing@example.com

### Documentation Links
- **User Guide**: https://docs.minerva.example.com
- **API Documentation**: https://api.minerva.example.com/docs
- **Admin Guide**: https://docs.minerva.example.com/admin
- **Troubleshooting**: https://docs.minerva.example.com/troubleshooting

---

## 🎯 Go-Live Checklist

### Final Pre-Launch (T-1 hour)
- [ ] All tests passing in production environment
- [ ] Monitoring and alerting active
- [ ] Support team briefed and ready
- [ ] User documentation updated
- [ ] Backup procedures verified
- [ ] Rollback plan confirmed

### Launch (T-0)
- [ ] Make production URL active
- [ ] Send launch announcement to users
- [ ] Monitor system health dashboard
- [ ] Be available for immediate support
- [ ] Document any issues encountered

### Post-Launch (T+24 hours)
- [ ] Review error logs and metrics
- [ ] Analyze user adoption patterns
- [ ] Gather initial user feedback
- [ ] Plan any immediate improvements
- [ ] Schedule post-launch retrospective

---

**Deployment Complete!** 🚀

The Minerva Machine Safety Photo Organizer is now live in production with comprehensive monitoring, error tracking, and support systems in place.