# Supabase Environment Setup Guide

## Overview

This guide walks through creating and configuring separate Supabase projects for staging and production environments. Each environment will have its own isolated database with identical schema and security policies.

## Current Development Setup

### Existing Development Database
- **Project**: Already configured and operational
- **Migrations**: 18 migrations applied (20250702000000 through 20250717000000)
- **Status**: Fully functional with complete schema
- **Action Required**: None - continue using existing project

## Creating New Supabase Projects

### Step 1: Create Staging Project

1. **Navigate to Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Click "New project"

2. **Configure Staging Project**
   ```
   Project name: minerva-staging
   Database Password: [Generate strong password - SAVE THIS!]
   Region: Choose closest to your users
   Pricing Plan: Free tier is fine for staging
   ```

3. **Save Credentials**
   ```bash
   # Add to .env.staging.local
   NEXT_PUBLIC_SUPABASE_URL=https://[staging-project-id].supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=[staging-anon-key]
   SUPABASE_SERVICE_ROLE_KEY=[staging-service-role-key]
   SUPABASE_DB_PASSWORD=[staging-database-password]
   ```

### Step 2: Create Production Project

1. **Create Production Project**
   ```
   Project name: minerva-production
   Database Password: [Generate strong password - SAVE THIS!]
   Region: Choose based on user location
   Pricing Plan: Pro ($25/month recommended)
   ```

2. **Save Credentials**
   ```bash
   # Add to .env.production.local
   NEXT_PUBLIC_SUPABASE_URL=https://[production-project-id].supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=[production-anon-key]
   SUPABASE_SERVICE_ROLE_KEY=[production-service-role-key]
   SUPABASE_DB_PASSWORD=[production-database-password]
   ```

## Database Migration Strategy

### Step 1: Link Supabase Projects

```bash
# Link to staging project
npx supabase link --project-ref [staging-project-id]

# For production (in separate terminal/session)
npx supabase link --project-ref [production-project-id]
```

### Step 2: Apply Migrations to Staging

```bash
# Set staging password
set SUPABASE_DB_PASSWORD=[staging-database-password]

# Dry run first
npx supabase db push --linked --password %SUPABASE_DB_PASSWORD% --dry-run

# Apply all migrations
npx supabase db push --linked --password %SUPABASE_DB_PASSWORD%

# Verify migrations
npx supabase migration list --linked --password %SUPABASE_DB_PASSWORD%
```

### Step 3: Apply Migrations to Production

```bash
# Set production password
set SUPABASE_DB_PASSWORD=[production-database-password]

# Dry run first (ALWAYS!)
npx supabase db push --linked --password %SUPABASE_DB_PASSWORD% --dry-run

# Apply all migrations
npx supabase db push --linked --password %SUPABASE_DB_PASSWORD%

# Verify migrations
npx supabase migration list --linked --password %SUPABASE_DB_PASSWORD%
```

## Storage Configuration

### Configure Storage Buckets

For each environment (staging and production):

1. **Navigate to Storage in Supabase Dashboard**
2. **Create Required Buckets**:
   ```
   - photos (public: false)
   - exports (public: false)
   - temp (public: false)
   ```

3. **Set Storage Policies**:
   ```sql
   -- Photos bucket policy
   CREATE POLICY "Users can upload their org photos"
   ON storage.objects FOR INSERT
   WITH CHECK (
     bucket_id = 'photos' AND
     auth.uid() IN (
       SELECT user_id FROM project_members
       WHERE project_id = (storage.foldername(name))[1]::uuid
     )
   );

   -- Similar policies for read, update, delete
   ```

## Security Configuration

### 1. Enable Row Level Security (RLS)

RLS should already be enabled via migrations, but verify:

```sql
-- Check RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

### 2. Configure Authentication

1. **Email Templates**:
   - Go to Authentication > Email Templates
   - Customize for your brand
   - Set proper redirect URLs

2. **URL Configuration**:
   ```
   Site URL: https://staging-minerva.vercel.app (for staging)
   Site URL: https://minerva.yourdomain.com (for production)
   
   Redirect URLs:
   - https://staging-minerva.vercel.app/**
   - https://minerva.yourdomain.com/**
   ```

3. **Email Settings**:
   - Enable email confirmations
   - Configure SMTP for production

### 3. API Rate Limiting

For production environment:

1. Go to Settings > API
2. Configure rate limits:
   ```
   - Anon requests: 100/minute
   - Service role: Unlimited
   ```

## Database Performance Optimization

### 1. Connection Pooling (Production)

1. **Enable PgBouncer**:
   - Go to Settings > Database
   - Enable connection pooling
   - Use "Transaction" mode

2. **Update Connection String**:
   ```bash
   # Use pooled connection for Next.js
   DATABASE_URL=postgres://[user]:[password]@[host]:6543/[database]?pgbouncer=true
   ```

### 2. Database Indexes

Verify all indexes were created by migrations:

```sql
-- Check existing indexes
SELECT indexname, tablename 
FROM pg_indexes 
WHERE schemaname = 'public';
```

### 3. Monitoring Setup

1. **Enable Monitoring**:
   - Go to Reports > Database
   - Monitor slow queries
   - Set up alerts

2. **Key Metrics to Track**:
   - Connection count
   - Query performance
   - Storage usage
   - API request rate

## Backup Strategy

### Staging Backups
- Daily automated backups (7-day retention)
- Before major deployments

### Production Backups
1. **Automated Backups**:
   - Enable Point-in-Time Recovery (PITR)
   - Daily backups with 30-day retention

2. **Manual Backup Before Major Changes**:
   ```bash
   # Create manual backup
   npx supabase db dump -f backup-$(date +%Y%m%d).sql
   ```

## Data Seeding (Optional)

### Staging Environment Seed Data

Create `supabase/seed-staging.sql`:

```sql
-- Insert test organization
INSERT INTO organizations (name, created_at) 
VALUES ('Test Organization', NOW())
RETURNING id;

-- Insert test users
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at)
VALUES 
  ('test.user@example.com', crypt('testpassword123', gen_salt('bf')), NOW()),
  ('demo.user@example.com', crypt('demopassword123', gen_salt('bf')), NOW());

-- Add more test data as needed
```

Apply seed data:
```bash
npx supabase db push --linked --password %SUPABASE_DB_PASSWORD% < supabase/seed-staging.sql
```

## Verification Checklist

### For Each Environment:

- [ ] Project created in Supabase dashboard
- [ ] All credentials saved to appropriate .env file
- [ ] Supabase CLI linked to project
- [ ] All 18 migrations applied successfully
- [ ] Storage buckets created with policies
- [ ] RLS enabled on all tables
- [ ] Authentication configured with correct URLs
- [ ] Connection pooling enabled (production)
- [ ] Backups configured
- [ ] Monitoring enabled

## Troubleshooting

### Migration Sync Issues

If migrations show as out of sync:

```bash
# Repair migration history
npx supabase migration repair 20250717000000 --status applied --linked --password %SUPABASE_DB_PASSWORD%
```

### Connection Issues

1. Verify credentials in .env files
2. Check if project is paused (free tier)
3. Verify network connectivity
4. Check service role key permissions

### Performance Issues

1. Check connection pool settings
2. Review slow query logs
3. Verify indexes are created
4. Consider upgrading plan

## Maintenance Scripts

### Create Migration Script
```bash
# scripts/create-migration.sh
#!/bin/bash
echo "Enter migration name:"
read name
npx supabase migration new $name
echo "Migration created: supabase/migrations/[timestamp]_$name.sql"
```

### Apply Migrations Script
```bash
# scripts/apply-migrations.sh
#!/bin/bash
echo "Target environment (staging/production):"
read env

if [ "$env" = "staging" ]; then
  export SUPABASE_DB_PASSWORD=$STAGING_DB_PASSWORD
elif [ "$env" = "production" ]; then
  export SUPABASE_DB_PASSWORD=$PRODUCTION_DB_PASSWORD
  echo "⚠️  PRODUCTION DEPLOYMENT - Are you sure? (yes/no)"
  read confirm
  if [ "$confirm" != "yes" ]; then
    exit 1
  fi
fi

npx supabase db push --linked --password $SUPABASE_DB_PASSWORD
```

## Next Steps

1. Create both Supabase projects following this guide
2. Apply migrations to both environments
3. Configure storage and security settings
4. Test connections from your application
5. Proceed to Vercel deployment setup