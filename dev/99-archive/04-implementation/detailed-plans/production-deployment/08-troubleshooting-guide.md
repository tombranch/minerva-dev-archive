# Production Deployment Troubleshooting Guide

## Overview

This guide covers common issues that may arise during production deployment and their solutions. Keep this handy during deployment day and for ongoing maintenance.

## Deployment Issues

### Vercel Deployment Failures

#### Build Timeout
**Symptoms:**
- Build fails with timeout error
- Build takes longer than 15 minutes

**Solutions:**
```bash
# Increase Node.js memory
# Add to vercel.json
{
  "build": {
    "env": {
      "NODE_OPTIONS": "--max-old-space-size=4096"
    }
  }
}

# Clear build cache
vercel --force

# Check for memory leaks in build
npm run build --verbose
```

#### TypeScript Errors in Production
**Symptoms:**
- Local build works, Vercel build fails
- TypeScript errors only in CI

**Solutions:**
```bash
# Check TypeScript version consistency
npm ls typescript

# Ensure same Node version
echo "v18.17.0" > .nvmrc

# Add to vercel.json
{
  "build": {
    "env": {
      "SKIP_ENV_VALIDATION": "true"
    }
  }
}
```

#### Environment Variable Issues
**Symptoms:**
- App works locally but fails in production
- Missing environment variables

**Solutions:**
```bash
# Verify environment variables are set
vercel env ls

# Check if variables are available
vercel logs --tail

# Pull environment variables
vercel env pull .env.vercel.local
```

### Database Connection Issues

#### Migration Failures
**Symptoms:**
- Supabase migrations fail to apply
- "relation already exists" errors

**Solutions:**
```bash
# Check migration status
npx supabase migration list --linked --password $SUPABASE_DB_PASSWORD

# Repair migration history
npx supabase migration repair 20250717000000 --status applied --linked --password $SUPABASE_DB_PASSWORD

# Manual SQL fix
npx supabase db push --linked --password $SUPABASE_DB_PASSWORD --dry-run
```

#### Connection Pool Exhaustion
**Symptoms:**
- "too many connections" error
- Intermittent database failures

**Solutions:**
```bash
# Enable connection pooling in Supabase
# Settings → Database → Enable PgBouncer

# Update connection string
DATABASE_URL=postgres://user:pass@host:6543/db?pgbouncer=true

# Reduce connection limits in code
const supabase = createClient(url, key, {
  db: {
    schema: 'public',
  },
  auth: {
    persistSession: false
  }
});
```

### Authentication Problems

#### Session Issues
**Symptoms:**
- Users logged out unexpectedly
- Session not persisting

**Solutions:**
```typescript
// Check session configuration
const supabase = createBrowserClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  {
    cookies: {
      get(name: string) {
        return getCookie(name)
      },
      set(name: string, value: string, options: CookieOptions) {
        setCookie(name, value, options)
      },
      remove(name: string, options: CookieOptions) {
        deleteCookie(name, options)
      },
    },
  }
)
```

#### RLS Policy Errors
**Symptoms:**
- 403 errors on data access
- "row-level security policy" errors

**Solutions:**
```sql
-- Check RLS policies
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Test policy with specific user
SET role postgres;
SELECT * FROM photos WHERE user_id = 'test-user-id';

-- Debug policy
SELECT * FROM pg_policies WHERE tablename = 'photos';
```

### API Route Issues

#### CORS Errors
**Symptoms:**
- Cross-origin request blocked
- CORS preflight failures

**Solutions:**
```typescript
// Add CORS headers in middleware
export function middleware(request: NextRequest) {
  const response = NextResponse.next();
  
  response.headers.set('Access-Control-Allow-Origin', process.env.NEXT_PUBLIC_APP_URL!);
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  return response;
}
```

#### Rate Limiting Issues
**Symptoms:**
- 429 Too Many Requests
- Legitimate users blocked

**Solutions:**
```typescript
// Adjust rate limits
const rateLimiter = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(1000, "1 h"), // Increase limit
  analytics: true,
});

// Add IP whitelist
const whitelist = ['192.168.1.1', '10.0.0.1'];
if (whitelist.includes(ip)) {
  return NextResponse.next();
}
```

### File Upload Problems

#### Upload Timeouts
**Symptoms:**
- Large files fail to upload
- Timeout errors during upload

**Solutions:**
```typescript
// Increase timeout in Vercel config
{
  "functions": {
    "app/api/photos/upload/route.ts": {
      "maxDuration": 60
    }
  }
}

// Implement chunked upload
const uploadInChunks = async (file: File) => {
  const chunkSize = 1024 * 1024; // 1MB chunks
  // Implementation here
};
```

#### Storage Permission Errors
**Symptoms:**
- "Insufficient permissions" on upload
- 403 errors accessing files

**Solutions:**
```sql
-- Check storage policies
SELECT * FROM storage.policies WHERE bucket_id = 'photos';

-- Add missing policy
CREATE POLICY "Users can upload photos" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'photos' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### Performance Issues

#### Slow Page Load Times
**Symptoms:**
- Pages take >3 seconds to load
- Poor Core Web Vitals scores

**Solutions:**
```typescript
// Add static generation where possible
export const dynamic = 'force-static';

// Optimize images
import Image from 'next/image';

<Image
  src={photoUrl}
  alt="Photo"
  width={300}
  height={200}
  priority={index < 4}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,..."
/>

// Implement pagination
const PHOTOS_PER_PAGE = 20;
```

#### Database Query Performance
**Symptoms:**
- Slow API responses
- High database CPU usage

**Solutions:**
```sql
-- Check slow queries
SELECT query, mean_exec_time, calls 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 10;

-- Add missing indexes
CREATE INDEX CONCURRENTLY idx_photos_user_id_created_at 
ON photos(user_id, created_at DESC);

-- Optimize queries
-- Use select specific columns instead of *
SELECT id, name, created_at FROM photos 
WHERE user_id = $1 
ORDER BY created_at DESC 
LIMIT 20;
```

### Monitoring and Alerts

#### Missing Alerts
**Symptoms:**
- Issues not detected quickly
- No notifications received

**Solutions:**
```typescript
// Test alert endpoints
const testAlert = async () => {
  await fetch('/api/health', { method: 'GET' });
  
  // Should trigger alert if down
  throw new Error('Test alert');
};

// Verify webhook URLs
curl -X POST $SLACK_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d '{"text": "Test alert"}'
```

#### Log Analysis Issues
**Symptoms:**
- Can't find relevant logs
- Logs missing context

**Solutions:**
```bash
# Filter Vercel logs
vercel logs --filter="ERROR"
vercel logs --since=1h
vercel logs --until=30m

# Add structured logging
logger.error({
  userId,
  action: 'photo_upload',
  error: error.message,
  stack: error.stack
}, 'Photo upload failed');
```

### Third-Party Service Issues

#### Google Cloud Vision API Errors
**Symptoms:**
- AI processing fails
- "Quota exceeded" errors

**Solutions:**
```typescript
// Implement retry logic
const processWithRetry = async (imageBuffer: Buffer, retries = 3) => {
  try {
    return await visionClient.textDetection(imageBuffer);
  } catch (error) {
    if (retries > 0 && error.code === 'QUOTA_EXCEEDED') {
      await new Promise(resolve => setTimeout(resolve, 1000));
      return processWithRetry(imageBuffer, retries - 1);
    }
    throw error;
  }
};

// Check quota usage
// Google Cloud Console → IAM & Admin → Quotas
```

#### PostHog Analytics Issues
**Symptoms:**
- Events not appearing
- Analytics dashboard empty

**Solutions:**
```typescript
// Verify PostHog initialization
if (typeof window !== 'undefined') {
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    debug: process.env.NODE_ENV === 'development'
  });
}

// Check events are firing
posthog.capture('test_event', { timestamp: Date.now() });
```

## Emergency Procedures

### Complete Application Down

1. **Immediate Actions:**
   ```bash
   # Check Vercel status
   vercel ls
   
   # Check deployment logs
   vercel logs --tail
   
   # Rollback if needed
   vercel rollback [previous-deployment-url]
   ```

2. **Communication:**
   - Update status page
   - Post in team Slack
   - Email key stakeholders

3. **Investigation:**
   - Check error monitoring (Sentry)
   - Review recent deployments
   - Check external service status

### Database Issues

1. **Connection Failures:**
   ```bash
   # Check Supabase status
   curl https://[project-id].supabase.co/rest/v1/health
   
   # Restart connection pool
   # Supabase Dashboard → Settings → Database
   ```

2. **High Load:**
   ```sql
   -- Kill long-running queries
   SELECT pg_terminate_backend(pid) 
   FROM pg_stat_activity 
   WHERE query_start < NOW() - INTERVAL '5 minutes';
   ```

### Security Incidents

1. **Suspected Breach:**
   - Immediately rotate all API keys
   - Review access logs
   - Contact security team
   - Document timeline

2. **DDoS Attack:**
   - Enable Vercel DDoS protection
   - Implement stricter rate limiting
   - Contact Vercel support

## Debugging Tools

### Log Analysis Commands

```bash
# Vercel logs
vercel logs --filter="ERROR" --since=1h
vercel logs --function="api/photos/upload"

# Database logs (Supabase Dashboard)
# Settings → Logs → Query logs

# Check API responses
curl -v https://your-domain.com/api/health
```

### Performance Debugging

```bash
# Lighthouse CI
npm install -g @lhci/cli
lhci autorun --collect.url=https://your-domain.com

# Bundle analyzer
npm run build
npm run analyze
```

### Database Debugging

```sql
-- Connection stats
SELECT state, count(*) 
FROM pg_stat_activity 
GROUP BY state;

-- Slow queries
SELECT query, mean_exec_time 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 5;

-- Table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## Recovery Procedures

### Rollback Checklist

1. **Code Rollback:**
   ```bash
   vercel rollback [deployment-url]
   ```

2. **Database Rollback:**
   - Use Supabase point-in-time recovery
   - Or restore from backup

3. **Verification:**
   - Test critical user paths
   - Check error rates
   - Monitor for 15 minutes

4. **Communication:**
   - Notify team rollback complete
   - Update incident status
   - Schedule post-mortem

### Data Recovery

1. **Accidental Data Deletion:**
   ```sql
   -- Restore from backup
   -- Use Supabase Dashboard → Database → Backups
   ```

2. **Corruption Issues:**
   - Contact Supabase support
   - Use point-in-time recovery
   - Validate data integrity

## Contact Information

### Emergency Contacts
- **On-call Engineer**: [Phone/Slack]
- **Team Lead**: [Phone/Email]
- **DevOps Lead**: [Phone/Slack]

### Support Channels
- **Vercel Support**: https://vercel.com/help
- **Supabase Support**: https://supabase.com/support
- **Internal Slack**: #minerva-alerts

### Escalation Process
1. Try self-service solutions (this guide)
2. Contact on-call engineer
3. Escalate to team lead if not resolved in 30 minutes
4. Contact vendor support for platform issues

---

**Remember**: In a production emergency, it's better to roll back quickly and investigate later than to spend time debugging while users are affected.