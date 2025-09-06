# Agent Implementation Tasks for Production Deployment

## Overview

This document contains specific implementation tasks that can be automated by Claude Code or other coding agents. Each task includes clear requirements, expected outputs, and validation criteria.

## Task 1: Environment Configuration Files

### Objective
Create environment-specific configuration files and validation scripts.

### Implementation Requirements

1. **Create Environment Variable Validation Script**
   - File: `scripts/validate-env.js`
   - Validate all required environment variables are present
   - Check format of URLs and keys
   - Different validation rules for dev/staging/production
   - Exit with error code if validation fails

2. **Create Environment Switcher Script**
   - File: `scripts/switch-env.js`
   - Allow switching between dev/staging/production configs
   - Backup current .env.local before switching
   - Restore from backup functionality

3. **Update Build Scripts**
   - Modify `package.json` to include environment-specific builds
   - Add: `build:staging` and `build:production` scripts
   - Include environment variable validation before build

### Expected Output
```javascript
// scripts/validate-env.js
const requiredVars = {
  common: [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
    'SUPABASE_SERVICE_ROLE_KEY',
    'GOOGLE_CLOUD_PROJECT_ID'
  ],
  production: [
    'NEXT_PUBLIC_SENTRY_DSN',
    'RATE_LIMIT_MAX'
  ]
};

// Validation logic here
```

## Task 2: GitHub Actions Workflows

### Objective
Implement all CI/CD workflows for automated testing and deployment.

### Implementation Requirements

1. **Create CI Workflow**
   - File: `.github/workflows/ci.yml`
   - Run on all PRs and pushes to main/staging
   - Include: lint, typecheck, unit tests, e2e tests
   - Generate and upload test coverage reports
   - Fail fast on errors

2. **Create Deployment Workflows**
   - Files: `.github/workflows/staging-deploy.yml`, `.github/workflows/production-deploy.yml`
   - Staging: Auto-deploy on push to staging branch
   - Production: Manual approval required
   - Include post-deployment health checks

3. **Create Database Migration Workflow**
   - File: `.github/workflows/database-migrate.yml`
   - Manual trigger with environment selection
   - Dry-run option
   - Backup before migration option

### Validation Criteria
- All workflows must pass yamllint
- Use latest versions of actions
- Include proper error handling
- Use GitHub secrets for sensitive data

## Task 3: Security Hardening

### Objective
Implement security enhancements for production deployment.

### Implementation Requirements

1. **Create Security Headers Middleware**
   - File: `middleware.ts`
   - Implement CSP, HSTS, X-Frame-Options
   - Different policies for dev/production
   - Log security violations

2. **Implement Rate Limiting**
   - File: `lib/rate-limit.ts`
   - Use environment variables for limits
   - Redis-based for production (Upstash)
   - Memory-based for development

3. **Add API Key Rotation Script**
   - File: `scripts/rotate-keys.js`
   - Rotate Supabase service role keys
   - Update Vercel environment variables via API
   - Notification system for team

### Expected Implementation
```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  const response = NextResponse.next();
  
  // Security headers
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-Content-Type-Options', 'nosniff');
  
  // Add more based on environment
  return response;
}
```

## Task 4: Monitoring Integration

### Objective
Integrate comprehensive monitoring and alerting systems.

### Implementation Requirements

1. **Sentry Error Tracking Setup**
   - File: `lib/monitoring/sentry.ts`
   - Initialize Sentry with environment config
   - Custom error boundaries for React
   - Source map upload configuration
   - User context without PII

2. **Custom Metrics Tracking**
   - File: `lib/monitoring/metrics.ts`
   - Track: API response times, upload success rate, AI processing time
   - Integration with PostHog
   - Custom dashboards configuration

3. **Health Check Endpoints**
   - Files: `app/api/health/route.ts`, `app/api/health/deep/route.ts`
   - Basic health: Simple alive check
   - Deep health: Database, storage, external services
   - Return appropriate status codes

### Expected Output
```typescript
// app/api/health/deep/route.ts
export async function GET() {
  const checks = {
    database: await checkDatabase(),
    storage: await checkStorage(),
    ai: await checkAIService(),
    timestamp: new Date().toISOString()
  };
  
  const healthy = Object.values(checks).every(c => c === true);
  return NextResponse.json(checks, { status: healthy ? 200 : 503 });
}
```

## Task 5: Performance Optimization

### Objective
Implement performance optimizations for production.

### Implementation Requirements

1. **Image Optimization Configuration**
   - Update `next.config.js` for production image settings
   - Implement lazy loading for photo galleries
   - Add blur placeholders for images
   - Configure CDN for Supabase storage

2. **API Route Optimization**
   - Add caching headers to appropriate routes
   - Implement response compression
   - Add request deduplication
   - Configure API route segments

3. **Database Query Optimization**
   - File: `lib/db/optimized-queries.ts`
   - Add database connection pooling
   - Implement query result caching
   - Add indexes verification script

## Task 6: Deployment Automation Scripts

### Objective
Create scripts to automate common deployment tasks.

### Implementation Requirements

1. **Pre-deployment Checklist Script**
   - File: `scripts/pre-deploy-check.js`
   - Check: no console.logs, no commented code, no TODOs
   - Verify all tests pass
   - Check bundle size limits
   - Validate environment configuration

2. **Post-deployment Verification**
   - File: `scripts/verify-deployment.js`
   - Test all critical user paths
   - Verify external integrations
   - Check performance metrics
   - Generate deployment report

3. **Rollback Automation**
   - File: `scripts/emergency-rollback.js`
   - One-command rollback process
   - Automatic health checks
   - Notification system
   - Incident report generation

### Script Structure
```javascript
// scripts/pre-deploy-check.js
const checks = [
  checkConsoleStatements,
  checkTodoComments,
  runTests,
  checkBundleSize,
  validateEnvironment
];

async function runChecks() {
  for (const check of checks) {
    const result = await check();
    if (!result.success) {
      console.error(`❌ ${result.message}`);
      process.exit(1);
    }
  }
  console.log('✅ All checks passed!');
}
```

## Task 7: Documentation Generation

### Objective
Auto-generate deployment documentation from code.

### Implementation Requirements

1. **API Documentation Generator**
   - File: `scripts/generate-api-docs.js`
   - Parse all API routes
   - Generate OpenAPI specification
   - Include example requests/responses
   - Markdown output for docs

2. **Environment Variable Documentation**
   - File: `scripts/document-env-vars.js`
   - Parse .env.example
   - Generate table with descriptions
   - Flag required vs optional
   - Show which environments need each variable

3. **Deployment Guide Generator**
   - File: `scripts/generate-deploy-guide.js`
   - Extract version from package.json
   - List all changes since last deployment
   - Generate rollback instructions
   - Include known issues

## Task 8: Testing Enhancements

### Objective
Enhance testing suite for production readiness.

### Implementation Requirements

1. **Smoke Test Suite**
   - File: `tests/smoke/index.test.ts`
   - Critical path testing only
   - Run after each deployment
   - 2-minute maximum runtime
   - Clear pass/fail reporting

2. **Load Testing Script**
   - File: `scripts/load-test.js`
   - Simulate concurrent users
   - Test file upload limits
   - Monitor response times
   - Generate performance report

3. **Visual Regression Tests**
   - Setup Playwright for visual testing
   - Capture screenshots of key pages
   - Compare against baselines
   - Flag visual changes

## Implementation Priority

1. **High Priority** (Complete First)
   - Environment validation scripts
   - CI/CD workflows
   - Health check endpoints
   - Pre-deployment checks

2. **Medium Priority** (Complete Second)
   - Security hardening
   - Monitoring integration
   - Deployment scripts
   - Smoke tests

3. **Lower Priority** (Nice to Have)
   - Documentation generation
   - Visual regression tests
   - Load testing
   - Advanced metrics

## Validation Checklist

After implementing each task:

- [ ] Code passes all linting rules
- [ ] TypeScript has no errors
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] Scripts are executable and tested
- [ ] No hardcoded values (use env vars)
- [ ] Error handling is comprehensive
- [ ] Logging is appropriate for environment

## Agent Instructions

When implementing these tasks:

1. Follow existing code patterns in the repository
2. Use TypeScript with strict type checking
3. Include comprehensive error handling
4. Add logging for debugging (environment-aware)
5. Write tests for new functionality
6. Update relevant documentation
7. Use existing dependencies where possible
8. Follow the project's ESLint configuration

Each task should be implemented in a separate commit with a clear message describing what was added.