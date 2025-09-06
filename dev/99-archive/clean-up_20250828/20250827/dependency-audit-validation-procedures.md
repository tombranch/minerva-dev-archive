# Comprehensive Dependency Audit & Validation Procedures
**Date:** August 27, 2025  
**Scope:** All dependency-related validation across cleanup phases  
**Purpose:** Ensure security, integrity, and compatibility of dependency updates  
**Integration:** Phases 2A, 2.5, 2C, 3, 4, and 5

## Overview

This document provides comprehensive procedures for auditing, validating, and maintaining dependency security throughout the Minerva project cleanup phases. These procedures ensure that all dependency updates maintain security, functionality, and performance standards.

## Pre-Implementation Audit Procedures

### 1. Comprehensive Dependency Security Scan
**Frequency:** Before any dependency changes  
**Duration:** 5-10 minutes  
**Scope:** Identify all security vulnerabilities

```bash
#!/bin/bash
# Script: pre-dependency-audit.sh

echo "🔍 Starting Comprehensive Dependency Security Audit..."

# Step 1: Full security audit
npm audit --json > audit-report.json
npm audit --audit-level=info

# Step 2: Check for critical and high-severity issues
CRITICAL=$(npm audit --audit-level=critical --json | jq '.metadata.vulnerabilities.critical // 0')
HIGH=$(npm audit --audit-level=high --json | jq '.metadata.vulnerabilities.high // 0')

echo "Critical vulnerabilities: $CRITICAL"
echo "High vulnerabilities: $HIGH"

# Step 3: Generate outdated packages report
npm outdated > outdated-packages.txt
cat outdated-packages.txt

# Step 4: Check for deprecated packages
npm ls --depth=0 2>&1 | grep -i deprecated || echo "No deprecated packages found"

# Step 5: Bundle size baseline
npm run build > /dev/null 2>&1
du -sh .next/ 2>/dev/null || echo "Build directory not found"

echo "✅ Pre-audit complete. Review reports before proceeding."
```

### 2. Dependency Inventory & Risk Assessment
**Create:** `dependency-inventory.json`

```json
{
  "auditDate": "2025-08-27",
  "criticalDependencies": {
    "supabase": {
      "current": "2.50.2",
      "latest": "2.56.0",
      "riskLevel": "medium",
      "updateReason": "security patches + features",
      "breakingChanges": false
    },
    "sentry": {
      "current": "9.38.0", 
      "latest": "10.6.0",
      "riskLevel": "high",
      "updateReason": "security hardening + performance",
      "breakingChanges": true
    },
    "jspdf": {
      "current": "≤3.0.1",
      "latest": "3.0.2+",
      "riskLevel": "critical",
      "updateReason": "DoS vulnerability fix",
      "breakingChanges": false
    },
    "google-cloud-vision": {
      "current": "5.2.0",
      "latest": "5.3.3", 
      "riskLevel": "medium",
      "updateReason": "security improvements",
      "breakingChanges": false
    }
  },
  "cleanupCandidates": [
    {
      "package": "clarifai",
      "version": "2.9.1",
      "reason": "potentially unused AI service",
      "action": "audit usage and remove if unused"
    },
    {
      "package": "c8",
      "version": "10.1.3", 
      "reason": "redundant with @vitest/coverage-v8",
      "action": "remove after verification"
    },
    {
      "package": "tw-animate-css",
      "version": "1.3.4",
      "reason": "custom animations usage audit needed",
      "action": "audit usage patterns"
    },
    {
      "package": "kill-port",
      "version": "2.0.1",
      "reason": "native process management available", 
      "action": "remove and replace with native"
    }
  ]
}
```

## Phase-Specific Validation Procedures

### Phase 2A-Security: Immediate Vulnerability Fix

#### Validation Script
```bash
#!/bin/bash
# Script: validate-phase2a-security.sh

echo "🔒 Validating Phase 2A Security Fix..."

# Check jsPDF vulnerability is resolved
JSPDF_VULN=$(npm audit --audit-level=high --json | jq '.vulnerabilities | has("jspdf")')
if [ "$JSPDF_VULN" = "false" ]; then
    echo "✅ jsPDF vulnerability resolved"
else
    echo "❌ jsPDF vulnerability still present"
    exit 1
fi

# Verify build still works
npm run build > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Build successful after security fix"
else
    echo "❌ Build failed after security fix"
    exit 1
fi

# Test PDF functionality (if test available)
npm test -- --grep "pdf" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ PDF functionality tests passing"
else
    echo "⚠️ PDF functionality tests not found or failing"
fi

echo "✅ Phase 2A Security validation complete"
```

### Phase 2.5: Comprehensive Dependency Modernization

#### Pre-Update Validation
```bash
#!/bin/bash
# Script: validate-phase2.5-pre-update.sh

echo "🚀 Pre-Phase 2.5 Validation..."

# Baseline measurements
echo "📊 Recording baseline measurements..."

# Current bundle size
npm run build > /dev/null 2>&1
BASELINE_BUNDLE_SIZE=$(du -sb .next/ 2>/dev/null | cut -f1 || echo "0")
echo "Baseline bundle size: $BASELINE_BUNDLE_SIZE bytes"

# Current dependency count
BASELINE_DEP_COUNT=$(jq '.dependencies | length' package.json)
echo "Baseline dependency count: $BASELINE_DEP_COUNT"

# Current vulnerability count
BASELINE_VULNS=$(npm audit --audit-level=moderate --json 2>/dev/null | jq '.metadata.vulnerabilities.total // 0')
echo "Baseline vulnerabilities: $BASELINE_VULNS"

# Test suite baseline
npm test > test-baseline.log 2>&1
BASELINE_TESTS=$(grep -c "✓\|✅" test-baseline.log || echo "0")
echo "Baseline passing tests: $BASELINE_TESTS"

# Save baseline data
echo "{
  \"date\": \"$(date -Iseconds)\",
  \"bundleSize\": $BASELINE_BUNDLE_SIZE,
  \"dependencyCount\": $BASELINE_DEP_COUNT,
  \"vulnerabilities\": $BASELINE_VULNS,
  \"passingTests\": $BASELINE_TESTS
}" > phase2.5-baseline.json

echo "✅ Baseline recorded for Phase 2.5 comparison"
```

#### Post-Update Validation
```bash
#!/bin/bash  
# Script: validate-phase2.5-post-update.sh

echo "🎯 Post-Phase 2.5 Validation..."

# Load baseline data
if [ ! -f "phase2.5-baseline.json" ]; then
    echo "❌ Baseline data not found. Run pre-update validation first."
    exit 1
fi

BASELINE_BUNDLE_SIZE=$(jq '.bundleSize' phase2.5-baseline.json)
BASELINE_DEP_COUNT=$(jq '.dependencyCount' phase2.5-baseline.json) 
BASELINE_VULNS=$(jq '.vulnerabilities' phase2.5-baseline.json)
BASELINE_TESTS=$(jq '.passingTests' phase2.5-baseline.json)

# Current measurements
npm run build > /dev/null 2>&1
CURRENT_BUNDLE_SIZE=$(du -sb .next/ 2>/dev/null | cut -f1 || echo "0")
CURRENT_DEP_COUNT=$(jq '.dependencies | length' package.json)
CURRENT_VULNS=$(npm audit --audit-level=moderate --json 2>/dev/null | jq '.metadata.vulnerabilities.total // 0')

npm test > test-current.log 2>&1
CURRENT_TESTS=$(grep -c "✓\|✅" test-current.log || echo "0")

# Calculate improvements
BUNDLE_REDUCTION=$((BASELINE_BUNDLE_SIZE - CURRENT_BUNDLE_SIZE))
BUNDLE_PERCENT=$(echo "scale=2; $BUNDLE_REDUCTION * 100 / $BASELINE_BUNDLE_SIZE" | bc -l 2>/dev/null || echo "0")
DEP_REDUCTION=$((BASELINE_DEP_COUNT - CURRENT_DEP_COUNT))
VULN_REDUCTION=$((BASELINE_VULNS - CURRENT_VULNS))

echo "📊 Phase 2.5 Results:"
echo "Bundle size reduction: $BUNDLE_REDUCTION bytes (${BUNDLE_PERCENT}%)"
echo "Dependencies removed: $DEP_REDUCTION"
echo "Vulnerabilities eliminated: $VULN_REDUCTION"
echo "Tests still passing: $CURRENT_TESTS (baseline: $BASELINE_TESTS)"

# Validation gates
if [ "$CURRENT_VULNS" -eq 0 ]; then
    echo "✅ Zero vulnerabilities achieved"
else
    echo "❌ $CURRENT_VULNS vulnerabilities remain"
fi

if [ "$BUNDLE_REDUCTION" -gt 0 ]; then
    echo "✅ Bundle size reduced"
else
    echo "⚠️ Bundle size not reduced (target: 8-15% reduction)"
fi

if [ "$CURRENT_TESTS" -ge "$BASELINE_TESTS" ]; then
    echo "✅ Test suite maintained" 
else
    echo "❌ Test regressions detected"
fi

echo "✅ Phase 2.5 validation complete"
```

### Phase 2C: Console Elimination + Dependency Integration

#### Logging Integration Validation
```bash
#!/bin/bash
# Script: validate-phase2c-logging-integration.sh

echo "📝 Validating Phase 2C Logging Integration..."

# Check Sentry v10 integration
SENTRY_VERSION=$(npm list @sentry/nextjs --depth=0 2>/dev/null | grep @sentry/nextjs | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "not found")
if [[ "$SENTRY_VERSION" =~ ^10\. ]]; then
    echo "✅ Sentry v10 integration confirmed: $SENTRY_VERSION"
else
    echo "⚠️ Sentry v10 not detected. Current: $SENTRY_VERSION"
fi

# Check console statement elimination
CONSOLE_COUNT=$(find . -name "*.ts" -o -name "*.tsx" | grep -v node_modules | xargs grep "console\." | wc -l || echo "0")
if [ "$CONSOLE_COUNT" -eq 0 ]; then
    echo "✅ Console statements eliminated: 0 found"
else
    echo "⚠️ $CONSOLE_COUNT console statements remain"
fi

# Test centralized logger functionality
npm test -- --grep "logger" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Centralized logger tests passing"
else
    echo "⚠️ Logger tests not found or failing"
fi

# Verify performance impact
BUNDLE_SIZE=$(du -sb .next/ 2>/dev/null | cut -f1 || echo "0")
echo "Current bundle size: $BUNDLE_SIZE bytes"

echo "✅ Phase 2C logging integration validation complete"
```

### Phase 3: TypeScript + Dependency Type Safety

#### Type Safety Validation
```bash
#!/bin/bash
# Script: validate-phase3-type-safety.sh

echo "🔧 Validating Phase 3 TypeScript + Dependency Types..."

# TypeScript compilation check
npx tsc --noEmit > ts-errors.log 2>&1
TS_ERRORS=$(wc -l < ts-errors.log || echo "0")

if [ "$TS_ERRORS" -eq 0 ]; then
    echo "✅ Zero TypeScript errors"
else
    echo "❌ $TS_ERRORS TypeScript errors remain"
    head -20 ts-errors.log
fi

# Check dependency type compatibility
SUPABASE_TYPES=$(npm list @supabase/supabase-js --depth=0 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
SENTRY_TYPES=$(npm list @sentry/nextjs --depth=0 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+') 
VISION_TYPES=$(npm list @google-cloud/vision --depth=0 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')

echo "📦 Dependency type versions:"
echo "  Supabase: $SUPABASE_TYPES"
echo "  Sentry: $SENTRY_TYPES"  
echo "  Google Vision: $VISION_TYPES"

# Verify strict mode compliance
STRICT_MODE=$(grep -c "strict.*true" tsconfig.json || echo "0")
if [ "$STRICT_MODE" -gt 0 ]; then
    echo "✅ TypeScript strict mode enabled"
else
    echo "⚠️ TypeScript strict mode not detected"
fi

echo "✅ Phase 3 type safety validation complete"
```

### Phase 4: Test Stabilization + Dependency Testing

#### Dependency Integration Testing
```bash
#!/bin/bash
# Script: validate-phase4-dependency-testing.sh

echo "🧪 Validating Phase 4 Test Stabilization + Dependency Integration..."

# Run full test suite
npm run test:all > test-results.log 2>&1
TEST_EXIT_CODE=$?

PASSING_TESTS=$(grep -c "✓\|✅" test-results.log || echo "0")
FAILING_TESTS=$(grep -c "✗\|❌" test-results.log || echo "0")

echo "🧪 Test Results:"
echo "  Passing: $PASSING_TESTS"
echo "  Failing: $FAILING_TESTS"

if [ "$TEST_EXIT_CODE" -eq 0 ]; then
    echo "✅ All tests passing"
else
    echo "❌ Test failures detected"
    echo "Recent failures:"
    grep -A 5 "✗\|❌" test-results.log | head -20
fi

# Test dependency mocks are working
npm test -- --grep "supabase" > /dev/null 2>&1
SUPABASE_TESTS=$?

npm test -- --grep "sentry" > /dev/null 2>&1  
SENTRY_TESTS=$?

npm test -- --grep "vision" > /dev/null 2>&1
VISION_TESTS=$?

echo "🔌 Dependency mock tests:"
[ "$SUPABASE_TESTS" -eq 0 ] && echo "  ✅ Supabase mocks working" || echo "  ⚠️ Supabase mock issues"
[ "$SENTRY_TESTS" -eq 0 ] && echo "  ✅ Sentry mocks working" || echo "  ⚠️ Sentry mock issues"
[ "$VISION_TESTS" -eq 0 ] && echo "  ✅ Vision API mocks working" || echo "  ⚠️ Vision API mock issues"

echo "✅ Phase 4 dependency testing validation complete"
```

### Phase 5: Production Readiness + Final Dependency Validation

#### Comprehensive Production Validation
```bash
#!/bin/bash
# Script: validate-phase5-production-dependencies.sh

echo "🚀 Final Production Dependency Validation..."

# Security audit - must be zero vulnerabilities
npm audit --audit-level=moderate --json > final-audit.json
FINAL_VULNS=$(jq '.metadata.vulnerabilities.total // 0' final-audit.json)

if [ "$FINAL_VULNS" -eq 0 ]; then
    echo "✅ Zero security vulnerabilities"
else
    echo "❌ $FINAL_VULNS vulnerabilities remain"
    jq '.vulnerabilities' final-audit.json
    exit 1
fi

# Dependency integrity check
npm ci --dry-run > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Dependency integrity validated"
else
    echo "❌ Dependency integrity check failed"
    exit 1
fi

# Bundle analysis
npm run build > /dev/null 2>&1
FINAL_BUNDLE_SIZE=$(du -sh .next/ 2>/dev/null | cut -f1 || echo "unknown")
echo "📦 Final bundle size: $FINAL_BUNDLE_SIZE"

# License compliance check (basic)
npm ls --production --json > dependencies.json
PROD_DEPS=$(jq '.dependencies | length' dependencies.json)
echo "📄 Production dependencies: $PROD_DEPS packages"

# Final comprehensive test
npm run test:all > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Full test suite passing"
else
    echo "❌ Test failures in final validation"
    exit 1
fi

# TypeScript final check
npx tsc --noEmit > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ TypeScript compilation clean"
else
    echo "❌ TypeScript errors in final validation"
    exit 1
fi

echo "🎉 All production dependency validations passed!"
```

## Continuous Monitoring Procedures

### 1. Daily Dependency Health Check
```bash
#!/bin/bash
# Script: daily-dependency-health.sh
# Schedule: Daily via cron or CI/CD

echo "🔍 Daily Dependency Health Check - $(date)"

# Quick security scan
npm audit --audit-level=high --json > daily-audit.json
HIGH_VULNS=$(jq '.metadata.vulnerabilities.high // 0' daily-audit.json)
CRITICAL_VULNS=$(jq '.metadata.vulnerabilities.critical // 0' daily-audit.json)

if [ "$HIGH_VULNS" -gt 0 ] || [ "$CRITICAL_VULNS" -gt 0 ]; then
    echo "🚨 ALERT: High/Critical vulnerabilities detected!"
    echo "Critical: $CRITICAL_VULNS, High: $HIGH_VULNS"
    # Send alert to team
else
    echo "✅ No high/critical vulnerabilities"
fi

# Check for new updates to critical dependencies
npm outdated @supabase/supabase-js @sentry/nextjs @google-cloud/vision > critical-updates.txt
if [ -s critical-updates.txt ]; then
    echo "📦 Critical dependency updates available:"
    cat critical-updates.txt
else
    echo "✅ Critical dependencies up to date"
fi

echo "✅ Daily health check complete"
```

### 2. Weekly Dependency Review
```bash
#!/bin/bash
# Script: weekly-dependency-review.sh
# Schedule: Weekly

echo "📊 Weekly Dependency Review - $(date)"

# Full outdated package review
npm outdated > weekly-outdated.txt
echo "📦 Outdated packages this week:"
cat weekly-outdated.txt

# Bundle size trend
npm run build > /dev/null 2>&1
WEEKLY_BUNDLE_SIZE=$(du -sb .next/ 2>/dev/null | cut -f1 || echo "0")
echo "Bundle size: $WEEKLY_BUNDLE_SIZE bytes"

# Dependency count trend
WEEKLY_DEP_COUNT=$(jq '.dependencies | length' package.json)
echo "Dependency count: $WEEKLY_DEP_COUNT packages"

# License review
npm ls --json > weekly-deps.json
echo "📄 License review required for any new packages"

echo "✅ Weekly review complete"
```

## Error Handling & Recovery Procedures

### 1. Dependency Update Rollback
```bash
#!/bin/bash
# Script: rollback-dependency-update.sh

echo "🔄 Dependency Update Rollback Procedure..."

# Step 1: Identify the problematic commit
git log --oneline -10 | grep -E "(dependency|deps|update|security)"
echo "Identify the commit to rollback to (above list)"

# Step 2: Create rollback branch
git checkout -b rollback-dependency-$(date +%Y%m%d)

# Step 3: Selective rollback (manual - specify commit hash)
read -p "Enter commit hash to rollback to: " COMMIT_HASH
git reset --hard "$COMMIT_HASH"

# Step 4: Verify rollback
npm install
npm audit
npm run build
npm test

echo "✅ Rollback complete. Review and merge if successful."
```

### 2. Dependency Conflict Resolution
```bash  
#!/bin/bash
# Script: resolve-dependency-conflicts.sh

echo "🔧 Dependency Conflict Resolution..."

# Step 1: Clear dependency cache
npm cache clean --force
rm -rf node_modules package-lock.json

# Step 2: Fresh install
npm install

# Step 3: Check for peer dependency issues
npm ls > dependency-tree.log 2>&1
grep -i "peer dep" dependency-tree.log || echo "No peer dependency issues"

# Step 4: Audit after resolution
npm audit
npm run build
npm test

echo "✅ Conflict resolution complete"
```

## Success Criteria & Quality Gates

### Phase-Specific Gates

#### Phase 2A-Security Gates
- ✅ Zero HIGH/CRITICAL vulnerabilities: `npm audit --audit-level=high`
- ✅ Build successful after fix
- ✅ PDF functionality maintained
- ✅ Dependencies locked in package-lock.json

#### Phase 2.5 Gates  
- ✅ 8-15% bundle size reduction achieved
- ✅ 4+ unused packages removed
- ✅ All major dependencies updated (Supabase v2.56+, Sentry v10, Vision v5.3.3)
- ✅ Breaking changes properly resolved
- ✅ Zero moderate+ vulnerabilities

#### Phase 2C Gates
- ✅ Sentry v10 logging integration functional
- ✅ Performance impact <5ms per log operation
- ✅ Bundle size benefits from Phase 2.5 maintained

#### Phase 3 Gates
- ✅ All dependency type definitions updated
- ✅ Strict TypeScript compliance maintained
- ✅ Zero type errors with new dependency versions

#### Phase 4 Gates
- ✅ All dependency mocks updated for new versions
- ✅ Integration tests passing with updated dependencies
- ✅ 10-15% test performance improvement achieved

#### Phase 5 Gates
- ✅ Comprehensive dependency security audit passed
- ✅ Production bundle security validated
- ✅ Dependency licensing compliance confirmed
- ✅ All integration tests passing in production configuration

### Overall Success Criteria
1. **Security:** Zero known vulnerabilities across all dependencies
2. **Performance:** Net bundle size reduction despite enhanced functionality
3. **Stability:** All tests passing with updated dependency stack
4. **Maintainability:** Modern, well-supported dependency versions
5. **Compliance:** All dependencies properly licensed and documented

This comprehensive validation framework ensures that all dependency updates maintain the highest standards of security, performance, and reliability throughout the cleanup process.