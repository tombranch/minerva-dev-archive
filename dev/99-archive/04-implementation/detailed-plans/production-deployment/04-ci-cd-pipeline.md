# CI/CD Pipeline Configuration Guide

## Overview

This guide covers setting up automated continuous integration and deployment pipelines using GitHub Actions and Vercel. The pipeline ensures code quality, runs tests, and automates deployments across all environments.

## Pipeline Architecture

```
Feature Branch → PR → Tests → Preview Deploy → Review
      ↓
Staging Branch → Tests → Staging Deploy → UAT
      ↓
Main Branch → Tests → Approval → Production Deploy
```

## GitHub Actions Setup

### Directory Structure

```
.github/
└── workflows/
    ├── ci.yml              # Continuous Integration
    ├── staging-deploy.yml  # Staging deployment
    ├── production-deploy.yml # Production deployment
    └── database-migrate.yml # Database migrations
```

### Continuous Integration Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  pull_request:
    branches: [main, staging]
  push:
    branches: [main, staging]

env:
  NODE_VERSION: '18.17.0'

jobs:
  lint-and-typecheck:
    name: Lint and Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci --legacy-peer-deps
      
      - name: Run ESLint
        run: npm run lint
      
      - name: TypeScript type check
        run: npx tsc --noEmit

  unit-tests:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci --legacy-peer-deps
      
      - name: Run unit tests
        run: npm run test:ci
        env:
          CI: true
      
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/

  e2e-tests:
    name: E2E Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci --legacy-peer-deps
      
      - name: Install Playwright
        run: npx playwright install --with-deps
      
      - name: Run E2E tests
        run: npm run test:e2e
        env:
          PLAYWRIGHT_BASE_URL: ${{ secrets.STAGING_URL }}
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.STAGING_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.STAGING_SUPABASE_ANON_KEY }}
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/

  build:
    name: Build Application
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci --legacy-peer-deps
      
      - name: Build application
        run: npm run build
        env:
          NODE_OPTIONS: '--max-old-space-size=4096'
          NEXT_TELEMETRY_DISABLED: 1
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: .next/
```

### Staging Deployment Workflow

Create `.github/workflows/staging-deploy.yml`:

```yaml
name: Deploy to Staging

on:
  push:
    branches: [staging]

jobs:
  deploy:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18.17.0'
          cache: 'npm'
      
      - name: Install Vercel CLI
        run: npm i -g vercel@latest
      
      - name: Pull Vercel Environment
        run: vercel pull --yes --environment=preview --token=${{ secrets.VERCEL_TOKEN }}
      
      - name: Build Project
        run: vercel build --token=${{ secrets.VERCEL_TOKEN }}
      
      - name: Deploy to Staging
        run: |
          DEPLOYMENT_URL=$(vercel deploy --prebuilt --token=${{ secrets.VERCEL_TOKEN }})
          vercel alias $DEPLOYMENT_URL staging-minerva.vercel.app --token=${{ secrets.VERCEL_TOKEN }}
      
      - name: Run smoke tests
        run: |
          npm run test:smoke
        env:
          BASE_URL: https://staging-minerva.vercel.app

  migrate-database:
    name: Run Database Migrations
    needs: deploy
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
      
      - name: Run migrations
        run: |
          supabase link --project-ref ${{ secrets.STAGING_SUPABASE_PROJECT_ID }}
          supabase db push --password ${{ secrets.STAGING_SUPABASE_DB_PASSWORD }}
```

### Production Deployment Workflow

Create `.github/workflows/production-deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]
  workflow_dispatch: # Allow manual trigger

jobs:
  pre-deployment-checks:
    name: Pre-deployment Checks
    runs-on: ubuntu-latest
    outputs:
      should-deploy: ${{ steps.check.outputs.should-deploy }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Check deployment criteria
        id: check
        run: |
          # Check if staging deployment exists and passed tests
          # Check if there are any critical issues
          echo "should-deploy=true" >> $GITHUB_OUTPUT
      
      - name: Notify team
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          custom_payload: |
            {
              text: "Production deployment initiated for commit ${{ github.sha }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

  deploy:
    name: Deploy to Production
    needs: pre-deployment-checks
    if: needs.pre-deployment-checks.outputs.should-deploy == 'true'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18.17.0'
          cache: 'npm'
      
      - name: Install Vercel CLI
        run: npm i -g vercel@latest
      
      - name: Deploy to Production
        run: |
          vercel deploy --prod --token=${{ secrets.VERCEL_TOKEN }}
      
      - name: Tag release
        run: |
          git tag v$(node -p "require('./package.json').version")
          git push --tags

  post-deployment:
    name: Post-deployment Tasks
    needs: deploy
    runs-on: ubuntu-latest
    steps:
      - name: Run production smoke tests
        run: |
          npm run test:smoke
        env:
          BASE_URL: https://minerva.yourdomain.com
      
      - name: Notify team
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          custom_payload: |
            {
              text: "Production deployment completed successfully!"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Database Migration Workflow

Create `.github/workflows/database-migrate.yml`:

```yaml
name: Database Migration

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - staging
          - production
      dry-run:
        description: 'Dry run only'
        required: false
        type: boolean
        default: true

jobs:
  migrate:
    name: Run Database Migration
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
      
      - name: Run migration
        run: |
          if [[ "${{ github.event.inputs.environment }}" == "production" ]]; then
            PROJECT_ID=${{ secrets.PRODUCTION_SUPABASE_PROJECT_ID }}
            DB_PASSWORD=${{ secrets.PRODUCTION_SUPABASE_DB_PASSWORD }}
          else
            PROJECT_ID=${{ secrets.STAGING_SUPABASE_PROJECT_ID }}
            DB_PASSWORD=${{ secrets.STAGING_SUPABASE_DB_PASSWORD }}
          fi
          
          supabase link --project-ref $PROJECT_ID
          
          if [[ "${{ github.event.inputs.dry-run }}" == "true" ]]; then
            supabase db push --password $DB_PASSWORD --dry-run
          else
            supabase db push --password $DB_PASSWORD
          fi
```

## GitHub Repository Settings

### Secrets Configuration

Add the following secrets to your GitHub repository:

```bash
# Vercel
VERCEL_TOKEN
VERCEL_ORG_ID
VERCEL_PROJECT_ID

# Staging Environment
STAGING_URL
STAGING_SUPABASE_URL
STAGING_SUPABASE_ANON_KEY
STAGING_SUPABASE_SERVICE_ROLE_KEY
STAGING_SUPABASE_PROJECT_ID
STAGING_SUPABASE_DB_PASSWORD

# Production Environment
PRODUCTION_URL
PRODUCTION_SUPABASE_URL
PRODUCTION_SUPABASE_ANON_KEY
PRODUCTION_SUPABASE_SERVICE_ROLE_KEY
PRODUCTION_SUPABASE_PROJECT_ID
PRODUCTION_SUPABASE_DB_PASSWORD

# Google Cloud
GOOGLE_CLOUD_PROJECT_ID
GOOGLE_CLOUD_CLIENT_EMAIL
GOOGLE_CLOUD_PRIVATE_KEY

# Monitoring
SLACK_WEBHOOK
SENTRY_AUTH_TOKEN
```

### Branch Protection Rules

Configure for `main` branch:
- Require pull request reviews (1 approval minimum)
- Dismiss stale PR approvals on new commits
- Require status checks to pass:
  - CI / Lint and Type Check
  - CI / Unit Tests
  - CI / E2E Tests
  - CI / Build Application
- Require branches to be up to date
- Include administrators

Configure for `staging` branch:
- Require status checks to pass
- No approval required (faster iteration)

### Environments

Create GitHub environments:

1. **staging**:
   - No required reviewers
   - Environment secrets for staging

2. **production**:
   - Required reviewers (1-2 team members)
   - Deployment protection rules
   - Environment secrets for production

## Local Development Integration

### Pre-commit Hooks

Update `.husky/pre-push`:

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Run tests before push
npm run test:unit

# Check for console.logs in production code
if git diff --cached --name-only | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -l 'console\.log' | grep -v test; then
  echo "❌ console.log found in production code"
  exit 1
fi
```

### VS Code Integration

Add to `.vscode/settings.json`:

```json
{
  "typescript.tsdk": "node_modules/typescript/lib",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "testing.automaticallyOpenPeekView": "never",
  "jest.autoRun": "off"
}
```

## Monitoring and Notifications

### Slack Integration

Set up notifications for:
- Deployment starts/completions
- Test failures
- Build errors
- Production alerts

### GitHub Status Checks

Monitor deployment status:
- https://github.com/[your-org]/minerva/actions
- Vercel dashboard
- GitHub deployment history

## Rollback Procedures

### Automatic Rollback

Add rollback conditions to production workflow:

```yaml
- name: Check deployment health
  run: |
    # Wait for deployment to stabilize
    sleep 60
    
    # Check error rate
    ERROR_RATE=$(curl -s https://api.posthog.com/error-rate)
    if [[ $ERROR_RATE -gt 5 ]]; then
      echo "High error rate detected, rolling back"
      vercel rollback --token=${{ secrets.VERCEL_TOKEN }}
      exit 1
    fi
```

### Manual Rollback

```bash
# List recent deployments
vercel ls

# Rollback to specific deployment
vercel rollback [deployment-url]

# Or promote previous deployment
vercel promote [previous-deployment-url]
```

## Performance Monitoring

### Build Time Optimization

Track and optimize:
- Bundle size changes
- Build duration
- Test execution time

### Deployment Metrics

Monitor:
- Deployment frequency
- Lead time for changes
- Mean time to recovery
- Change failure rate

## Security Considerations

### Secret Rotation

Implement automatic secret rotation:
1. Use GitHub Actions to rotate keys monthly
2. Update secrets in GitHub and Vercel
3. Notify team of rotations

### Dependency Updates

Add `.github/workflows/dependency-update.yml`:

```yaml
name: Dependency Updates

on:
  schedule:
    - cron: '0 9 * * 1' # Weekly on Mondays

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Update dependencies
        run: |
          npx npm-check-updates -u
          npm install
          npm audit fix
      
      - name: Create PR
        uses: peter-evans/create-pull-request@v5
        with:
          title: 'chore: update dependencies'
          branch: 'deps/update'
          commit-message: 'chore: update dependencies'
```

## Next Steps

1. Create GitHub Actions workflow files
2. Configure repository secrets
3. Set up branch protection rules
4. Create GitHub environments
5. Test CI pipeline with a PR
6. Deploy to staging
7. Validate production deployment process