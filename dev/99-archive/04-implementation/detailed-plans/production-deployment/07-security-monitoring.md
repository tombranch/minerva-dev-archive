# Security and Monitoring Setup Guide

## Overview

This guide covers comprehensive security hardening and monitoring setup for the Minerva production deployment. Security and monitoring are critical for maintaining a reliable, secure application.

## Security Configuration

### 1. Application Security Headers

#### Configure Security Headers in Vercel

Add to `vercel.json`:

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
        },
        {
          "key": "Permissions-Policy",
          "value": "camera=(), microphone=(), geolocation=(self)"
        },
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=31536000; includeSubDomains"
        }
      ]
    }
  ]
}
```

#### Content Security Policy (CSP)

Implement CSP in middleware:

```typescript
// middleware.ts
const cspHeader = `
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'unsafe-eval' https://vercel.live https://*.posthog.com;
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https://*.supabase.co https://vercel.com;
  font-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'none';
  upgrade-insecure-requests;
`
```

### 2. Authentication Security

#### Session Management
- Session timeout: 24 hours (configurable)
- Secure session cookies
- CSRF protection enabled
- Multi-factor authentication (optional)

#### Password Policies
- Minimum 8 characters
- Require complexity
- Password history (prevent reuse)
- Account lockout after failed attempts

### 3. API Security

#### Rate Limiting Configuration

```typescript
// lib/rate-limit.ts
export const rateLimitConfig = {
  anonymous: {
    requests: 100,
    window: '15m'
  },
  authenticated: {
    requests: 1000,
    window: '15m'
  },
  upload: {
    requests: 50,
    window: '1h',
    maxFileSize: '10MB'
  }
}
```

#### API Key Management
- Rotate keys every 90 days
- Use different keys per environment
- Implement key versioning
- Audit key usage

### 4. Database Security

#### Row Level Security (RLS)
All tables must have RLS enabled:

```sql
-- Verify RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = false;
```

#### Connection Security
- Use SSL connections only
- Connection pooling with PgBouncer
- Prepared statement caching
- Query timeout limits

#### Backup Encryption
- Encrypt backups at rest
- Secure backup storage location
- Test restore procedures monthly

### 5. File Upload Security

#### Upload Restrictions
```typescript
const uploadConfig = {
  allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
  maxFileSize: 10 * 1024 * 1024, // 10MB
  maxFilesPerUpload: 20,
  scanForMalware: true
}
```

#### Storage Security
- Private buckets by default
- Signed URLs for access
- Expiring URLs (1 hour)
- Virus scanning integration

### 6. Secret Management

#### Environment Variables
- Never commit secrets to git
- Use Vercel's encrypted env vars
- Rotate secrets regularly
- Audit access logs

#### Secret Rotation Schedule
| Secret Type | Rotation Frequency |
|-------------|-------------------|
| API Keys | 90 days |
| Database Passwords | 180 days |
| Service Account Keys | 365 days |
| JWT Secrets | 90 days |

## Monitoring Setup

### 1. Application Performance Monitoring (APM)

#### Vercel Analytics
Already integrated with:
```javascript
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/next';
```

Track:
- Page load times
- Core Web Vitals
- User interactions
- API response times

#### Custom Metrics
```typescript
// lib/monitoring/metrics.ts
export const trackMetric = (name: string, value: number, tags?: Record<string, string>) => {
  // Send to PostHog
  posthog.capture('metric', {
    metric_name: name,
    value,
    ...tags
  });
};

// Usage
trackMetric('photo_upload_duration', duration, { size: 'large' });
```

### 2. Error Tracking

#### Sentry Configuration

```typescript
// sentry.client.config.ts
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  beforeSend(event) {
    // Filter out sensitive data
    if (event.request?.cookies) {
      delete event.request.cookies;
    }
    return event;
  }
});
```

#### Error Alerting Rules
- Critical: Database connection failures
- High: Payment processing errors
- Medium: AI processing failures
- Low: 404 errors

### 3. Infrastructure Monitoring

#### Database Monitoring
Monitor via Supabase Dashboard:
- Query performance
- Connection pool usage
- Storage growth
- Replication lag

Key Metrics:
- Queries per second
- Average query time
- Connection count
- Cache hit ratio

#### API Monitoring
Track in Vercel Dashboard:
- Request volume
- Error rates
- Response times
- Geographic distribution

### 4. Security Monitoring

#### Audit Logging
Log security events:
```typescript
// lib/audit-log.ts
export const auditLog = async (event: {
  action: string;
  userId?: string;
  resource?: string;
  result: 'success' | 'failure';
  metadata?: Record<string, any>;
}) => {
  await supabase.from('audit_logs').insert({
    ...event,
    timestamp: new Date().toISOString(),
    ip_address: getClientIP()
  });
};
```

#### Security Alerts
Set up alerts for:
- Multiple failed login attempts
- Unusual data access patterns
- API rate limit violations
- Unauthorized access attempts

### 5. Uptime Monitoring

#### Health Check Endpoints

```typescript
// app/api/health/route.ts
export async function GET() {
  return NextResponse.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version
  });
}

// app/api/health/deep/route.ts
export async function GET() {
  const checks = await Promise.all([
    checkDatabase(),
    checkStorage(),
    checkAIService(),
    checkCache()
  ]);
  
  const allHealthy = checks.every(c => c.healthy);
  
  return NextResponse.json({
    status: allHealthy ? 'healthy' : 'degraded',
    checks,
    timestamp: new Date().toISOString()
  }, {
    status: allHealthy ? 200 : 503
  });
}
```

#### External Monitoring
- Use Vercel's built-in monitoring
- Configure Pingdom or UptimeRobot
- Set up status page

### 6. Log Management

#### Structured Logging

```typescript
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  redact: ['password', 'token', 'key', 'secret']
});

// Usage
logger.info({ userId, action: 'photo_upload' }, 'User uploaded photo');
```

#### Log Aggregation
- Vercel Logs for application logs
- Supabase Logs for database
- Centralize with log drain

### 7. Alerting Configuration

#### Alert Channels
1. **Email**: Critical alerts
2. **Slack**: Team notifications
3. **PagerDuty**: On-call escalation
4. **SMS**: Critical production issues

#### Alert Rules

| Metric | Threshold | Severity | Action |
|--------|-----------|----------|--------|
| Error Rate | >5% | Critical | Page on-call |
| Response Time | >3s | High | Slack notification |
| Database Connections | >80% | High | Email team |
| Storage Usage | >90% | Medium | Email warning |
| API Rate Limit | >95% | Low | Log only |

### 8. Dashboard Setup

#### Key Metrics Dashboard
Create dashboard showing:
- Active users (real-time)
- Upload success rate
- AI processing queue
- Error rate
- Response times
- Database performance

#### Business Metrics
- Daily active users
- Photos uploaded
- AI tags generated
- Storage usage trend
- Cost per user

## Security Checklist

### Pre-Production
- [ ] All security headers configured
- [ ] Rate limiting enabled
- [ ] HTTPS enforced everywhere
- [ ] Secrets rotated from development
- [ ] Security scan completed
- [ ] Penetration test (optional)

### Production
- [ ] Monitor security alerts
- [ ] Review audit logs weekly
- [ ] Update dependencies monthly
- [ ] Rotate secrets quarterly
- [ ] Security training annually

## Incident Response

### Incident Response Plan

1. **Detection**
   - Automated alerts
   - User reports
   - Monitoring dashboards

2. **Triage**
   - Assess severity
   - Notify stakeholders
   - Start incident channel

3. **Mitigation**
   - Implement immediate fix
   - Rollback if needed
   - Communicate status

4. **Resolution**
   - Verify fix works
   - Monitor closely
   - Update documentation

5. **Post-Mortem**
   - Root cause analysis
   - Lessons learned
   - Process improvements

### Emergency Contacts

Create and maintain list:
- On-call engineer
- Team lead
- Security officer
- Platform support

## Compliance Considerations

### Data Privacy
- GDPR compliance ready
- Data retention policies
- User data export
- Right to deletion

### Security Standards
- OWASP Top 10 addressed
- Regular security updates
- Vulnerability scanning
- Security headers A+ rating

## Maintenance Schedule

### Daily
- Review error logs
- Check monitoring alerts
- Verify backups completed

### Weekly
- Review security alerts
- Analyze performance trends
- Update dependencies

### Monthly
- Security patches
- Performance optimization
- Cost analysis
- Access audit

### Quarterly
- Secret rotation
- Security review
- Load testing
- Disaster recovery test

## Tools and Resources

### Recommended Tools
- **Sentry**: Error tracking
- **PostHog**: Analytics and metrics
- **Datadog**: APM (alternative)
- **PagerDuty**: Incident management
- **1Password**: Secret management

### Security Resources
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/)
- [Next.js Security](https://nextjs.org/docs/advanced-features/security-headers)
- [Vercel Security](https://vercel.com/docs/security)
- [Supabase Security](https://supabase.com/docs/guides/platform/security)