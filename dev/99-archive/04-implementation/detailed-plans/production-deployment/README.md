# Minerva Production Deployment Guide

## Overview

This directory contains comprehensive documentation for deploying the Minerva Machine Safety Photo Organizer to production. The deployment strategy follows a three-environment approach (Development, Staging, Production) with separate infrastructure for each environment.

## Quick Start

1. **Review Requirements**: Start with `05-human-actions-checklist.md` for manual setup tasks
2. **Set Up Environments**: Follow `01-environment-setup.md` for environment configuration
3. **Configure Databases**: Use `02-supabase-setup.md` to create Supabase projects
4. **Deploy to Vercel**: Follow `03-vercel-deployment.md` for deployment setup
5. **Automate Pipeline**: Implement CI/CD with `04-ci-cd-pipeline.md`

## Documentation Structure

### Core Setup Guides
- **[01-environment-setup.md](./01-environment-setup.md)** - Complete environment configuration guide
- **[02-supabase-setup.md](./02-supabase-setup.md)** - Database setup for each environment
- **[03-vercel-deployment.md](./03-vercel-deployment.md)** - Vercel project and deployment configuration
- **[04-ci-cd-pipeline.md](./04-ci-cd-pipeline.md)** - Automated deployment pipeline setup

### Implementation Guides
- **[05-human-actions-checklist.md](./05-human-actions-checklist.md)** - Manual tasks that require human intervention
- **[06-agent-implementation-tasks.md](./06-agent-implementation-tasks.md)** - Automated tasks for coding agents
- **[07-security-monitoring.md](./07-security-monitoring.md)** - Security hardening and monitoring setup
- **[08-troubleshooting-guide.md](./08-troubleshooting-guide.md)** - Common issues and solutions

### Automation Scripts
- **[deployment-scripts/](./deployment-scripts/)** - Ready-to-use deployment automation scripts

## Deployment Strategy

### Environment Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Development   │     │     Staging     │     │   Production    │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ • Local dev     │     │ • Pre-prod test │     │ • Live users    │
│ • Feature work  │     │ • Integration   │     │ • Stable code   │
│ • Experiments   │     │ • UAT testing   │     │ • Monitoring    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Supabase Dev    │     │ Supabase Stage  │     │ Supabase Prod   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Deployment Flow

1. **Development** → Feature branches deploy to Vercel preview environments
2. **Staging** → `staging` branch deploys to staging environment
3. **Production** → `main` branch deploys to production after staging validation

### Key Infrastructure Components

| Component | Development | Staging | Production |
|-----------|-------------|---------|------------|
| **Database** | Existing Supabase | New Supabase Project | New Supabase Project |
| **Hosting** | Vercel Preview | Vercel Staging | Vercel Production |
| **Domain** | localhost:3000 | staging-minerva.vercel.app | minerva.yourdomain.com |
| **API Keys** | Dev credentials | Test credentials | Production credentials |
| **Monitoring** | Basic logging | Full monitoring | Enhanced monitoring + alerts |

## Current Project Status

- **Completion**: ~85% complete with production-ready features
- **Database**: 18 migrations applied, comprehensive schema implemented
- **Features**: All core features operational (upload, AI processing, search, sharing)
- **Testing**: Comprehensive test suite with Vitest and Playwright
- **Security**: RLS policies, authentication, and authorization implemented

## Deployment Timeline

### Phase 1: Infrastructure Setup (2-3 days)
- Create Supabase projects
- Configure Vercel environments
- Set up monitoring services

### Phase 2: Staging Deployment (1-2 days)
- Deploy to staging
- Run comprehensive tests
- Validate all integrations

### Phase 3: Production Launch (1 day)
- Deploy to production
- Configure custom domain
- Monitor initial usage

### Phase 4: Post-Launch (Ongoing)
- Monitor performance
- Address any issues
- Continue development

## Critical Considerations

### Security
- All production secrets must be stored in Vercel environment variables
- Enable rate limiting and CSRF protection
- Implement proper CORS policies
- Regular security audits

### Performance
- Database connection pooling is essential
- CDN configuration for static assets
- Image optimization for photo uploads
- Monitoring response times

### Reliability
- Automated database backups
- Error tracking with Sentry
- Uptime monitoring
- Incident response plan

## Quick Commands Reference

```bash
# Link to Vercel project
vercel link

# Deploy to staging
git push origin staging

# Deploy to production
git push origin main

# Check deployment status
vercel ls

# View environment variables
vercel env ls

# Run database migrations
npm run db:migrate:production
```

## Support and Troubleshooting

- Check `08-troubleshooting-guide.md` for common issues
- Review Vercel deployment logs: `vercel logs`
- Monitor Supabase dashboard for database issues
- Check PostHog for user analytics and errors

## Next Steps

1. Start with `05-human-actions-checklist.md` to understand manual requirements
2. Follow the numbered guides in sequence
3. Use `06-agent-implementation-tasks.md` for automated setup tasks
4. Test thoroughly in staging before production deployment

---

**Important**: Always backup your `.env.local` file before making changes:
```bash
./scripts/backup-env.bat
```