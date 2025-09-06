# Human Actions Checklist for Production Deployment

## Overview

This checklist contains all manual tasks that require human intervention for the production deployment. These tasks cannot be automated and must be completed by a human with appropriate access levels.

## Pre-Deployment Requirements

### 1. Account Creation and Access

#### Supabase Accounts
- [ ] **Create Staging Supabase Project**
  - Go to: https://supabase.com/dashboard
  - Click "New project"
  - Name: `minerva-staging`
  - Generate and save strong password
  - Select appropriate region
  - **Save all credentials immediately**

- [ ] **Create Production Supabase Project**
  - Go to: https://supabase.com/dashboard
  - Click "New project"
  - Name: `minerva-production`
  - Generate and save strong password
  - Select appropriate region
  - Consider Pro plan ($25/month)
  - **Save all credentials immediately**

#### Google Cloud Setup
- [ ] **Create Google Cloud Projects**
  - Staging project: `minerva-staging`
  - Production project: `minerva-production`
  - Enable Vision API for both projects
  - Create service accounts for each environment

- [ ] **Generate Service Account Keys**
  - Download JSON key files
  - Store securely (never commit to git)
  - Add to environment variables

#### PostHog Analytics
- [ ] **Create PostHog Projects**
  - Sign up at: https://posthog.com
  - Create staging project
  - Create production project
  - Copy API keys for each

#### Domain Registration
- [ ] **Register/Configure Domain**
  - Register domain if not already owned
  - Access DNS management panel
  - Prepare for DNS configuration

### 2. Environment Configuration

#### Local Environment Files
- [ ] **Backup Current .env.local**
  ```bash
  ./scripts/backup-env.bat
  ```

- [ ] **Create .env.staging.local**
  - Copy from .env.example
  - Fill in staging Supabase credentials
  - Add staging Google Cloud credentials
  - Configure staging PostHog key

- [ ] **Create .env.production.local**
  - Copy from .env.example
  - Fill in production Supabase credentials
  - Add production Google Cloud credentials
  - Configure production PostHog key
  - Set production-specific limits

### 3. Vercel Configuration

- [ ] **Link Project to Vercel**
  ```bash
  vercel link
  ```
  - Choose your Vercel account
  - Set project name: `minerva-production`

- [ ] **Add Environment Variables in Vercel Dashboard**
  
  Go to: https://vercel.com/[your-account]/minerva-production/settings/environment-variables

  For **Production Environment**, add:
  - [ ] NEXT_PUBLIC_SUPABASE_URL
  - [ ] NEXT_PUBLIC_SUPABASE_ANON_KEY
  - [ ] SUPABASE_SERVICE_ROLE_KEY
  - [ ] GOOGLE_CLOUD_PROJECT_ID
  - [ ] GOOGLE_CLOUD_CLIENT_EMAIL
  - [ ] GOOGLE_CLOUD_PRIVATE_KEY
  - [ ] NEXT_PUBLIC_APP_URL
  - [ ] NEXT_PUBLIC_POSTHOG_KEY
  - [ ] NEXT_PUBLIC_POSTHOG_HOST
  - [ ] NEXT_PUBLIC_GOOGLE_MAPS_API_KEY
  - [ ] NODE_ENV=production

  For **Preview Environment** (Staging), add same variables with staging values

### 4. GitHub Repository Setup

- [ ] **Add Repository Secrets**
  
  Go to: Settings → Secrets and variables → Actions

  Add these secrets:
  - [ ] VERCEL_TOKEN (get from Vercel account settings)
  - [ ] STAGING_SUPABASE_PROJECT_ID
  - [ ] STAGING_SUPABASE_DB_PASSWORD
  - [ ] PRODUCTION_SUPABASE_PROJECT_ID
  - [ ] PRODUCTION_SUPABASE_DB_PASSWORD
  - [ ] SLACK_WEBHOOK (optional)

- [ ] **Configure Branch Protection**
  
  Go to: Settings → Branches
  
  For `main` branch:
  - [ ] Require pull request reviews
  - [ ] Require status checks to pass
  - [ ] Include administrators

- [ ] **Create GitHub Environments**
  
  Go to: Settings → Environments
  
  Create `staging` environment:
  - [ ] Add environment secrets
  - [ ] No required reviewers
  
  Create `production` environment:
  - [ ] Add environment secrets
  - [ ] Add required reviewers (1-2 people)

### 5. Database Setup

#### Staging Database
- [ ] **Apply Migrations to Staging**
  ```bash
  # Set staging password
  set SUPABASE_DB_PASSWORD=[staging-password]
  
  # Link to staging
  npx supabase link --project-ref [staging-project-id]
  
  # Apply migrations
  npx supabase db push --linked --password %SUPABASE_DB_PASSWORD%
  ```

- [ ] **Configure Staging Storage Buckets**
  - Go to Supabase Dashboard → Storage
  - Create buckets: `photos`, `exports`, `temp`
  - Set all to private

- [ ] **Verify Staging RLS Policies**
  - Check all tables have RLS enabled
  - Test authentication flow

#### Production Database
- [ ] **Apply Migrations to Production**
  ```bash
  # ⚠️ CAREFUL - PRODUCTION!
  set SUPABASE_DB_PASSWORD=[production-password]
  
  # Link to production
  npx supabase link --project-ref [production-project-id]
  
  # Dry run first!
  npx supabase db push --linked --password %SUPABASE_DB_PASSWORD% --dry-run
  
  # Apply if dry run succeeds
  npx supabase db push --linked --password %SUPABASE_DB_PASSWORD%
  ```

- [ ] **Configure Production Storage**
  - Same as staging but with production project
  - Enable CDN if available

- [ ] **Set Up Database Backups**
  - Enable Point-in-Time Recovery
  - Configure daily backups
  - Test restore procedure

### 6. Domain and DNS Configuration

- [ ] **Configure Production Domain**
  - Add A record: `@ → 76.76.21.21`
  - Add CNAME: `www → cname.vercel-dns.com`
  - Wait for propagation (up to 48 hours)

- [ ] **Configure Staging Subdomain**
  - Add CNAME: `staging → cname.vercel-dns.com`
  - Verify in Vercel dashboard

- [ ] **Verify SSL Certificates**
  - Check https://minerva.yourdomain.com
  - Check https://staging.minerva.yourdomain.com

### 7. Monitoring and Analytics

- [ ] **Set Up Error Tracking**
  - Create Sentry account (optional)
  - Create projects for staging/production
  - Add DSN to environment variables

- [ ] **Configure Uptime Monitoring**
  - Use Vercel monitoring or third-party
  - Set up alerts for downtime
  - Configure response time alerts

- [ ] **Set Up Log Aggregation**
  - Configure Vercel log draining (optional)
  - Set up log retention policies

### 8. Security Configuration

- [ ] **Review API Keys and Secrets**
  - Ensure different keys for each environment
  - Document key rotation schedule
  - Set up calendar reminders

- [ ] **Configure CORS and Security Headers**
  - Review vercel.json security headers
  - Test CORS configuration
  - Verify CSP headers if used

- [ ] **Set Up 2FA**
  - Enable on Vercel account
  - Enable on Supabase account
  - Enable on GitHub account
  - Enable on domain registrar

### 9. Testing and Validation

- [ ] **Test Staging Deployment**
  ```bash
  git checkout staging
  git push origin staging
  ```
  - Verify deployment succeeds
  - Test all major features
  - Check error tracking

- [ ] **Load Testing** (Optional but recommended)
  - Run basic load tests on staging
  - Verify performance metrics
  - Check rate limiting

- [ ] **Security Scan**
  - Run security headers test
  - Check for exposed secrets
  - Verify SSL configuration

### 10. Documentation and Team Preparation

- [ ] **Document Access Credentials**
  - Create secure password vault
  - Share with authorized team members
  - Document who has access to what

- [ ] **Create Runbooks**
  - Deployment procedure
  - Rollback procedure
  - Incident response plan

- [ ] **Team Training**
  - Review deployment process with team
  - Ensure everyone knows rollback procedure
  - Clarify on-call responsibilities

## Launch Day Checklist

### Morning of Launch

- [ ] **Final Staging Test**
  - Deploy latest code to staging
  - Run smoke tests
  - Check all integrations

- [ ] **Team Communication**
  - Notify team of deployment window
  - Ensure key people are available
  - Have rollback plan ready

### During Deployment

- [ ] **Deploy to Production**
  ```bash
  git checkout main
  git merge staging
  git push origin main
  ```

- [ ] **Monitor Deployment**
  - Watch Vercel deployment logs
  - Check for build errors
  - Verify deployment completes

### Post-Deployment

- [ ] **Smoke Tests**
  - Test login flow
  - Upload test photo
  - Verify AI processing works
  - Check search functionality

- [ ] **Monitor Metrics**
  - Check error rates in logs
  - Monitor response times
  - Watch for 500 errors

- [ ] **User Communication**
  - Send launch announcement
  - Update status page
  - Monitor support channels

## Post-Launch Tasks

### First 24 Hours

- [ ] **Active Monitoring**
  - Check error logs every few hours
  - Monitor performance metrics
  - Watch database connections

- [ ] **Gather Feedback**
  - Monitor user feedback channels
  - Document any issues
  - Prioritize critical fixes

### First Week

- [ ] **Performance Review**
  - Analyze usage patterns
  - Review error trends
  - Optimize slow queries

- [ ] **Security Audit**
  - Review access logs
  - Check for suspicious activity
  - Verify all auth flows

### First Month

- [ ] **Cost Analysis**
  - Review Vercel usage
  - Check Supabase metrics
  - Optimize if needed

- [ ] **Process Improvement**
  - Document lessons learned
  - Update deployment procedures
  - Plan next improvements

## Emergency Contacts

Document these for your team:

- **Vercel Support**: [support URL/email]
- **Supabase Support**: [support URL/email]
- **Domain Registrar**: [support contact]
- **Team Lead**: [phone/email]
- **On-call Engineer**: [phone/email]

## Rollback Information

Quick rollback procedure:

1. **Vercel Rollback**:
   ```bash
   vercel rollback [previous-deployment-url]
   ```

2. **Database Rollback**:
   - Use Supabase point-in-time recovery
   - Or restore from backup

3. **Communication**:
   - Notify team immediately
   - Update status page
   - Investigate root cause

---

**Remember**: Take your time with each step. It's better to delay launch than to rush and make mistakes. Good luck! 🚀