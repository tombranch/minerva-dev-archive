# Claude Code Execution Prompts for Minerva Project

**Purpose**: Ready-to-use prompts for Claude Code instances to execute each phase
**Location**: `C:\Users\Tom\dev\minerva\dev\03-in-progress\clean-up\20250826\`
**Project**: Minerva Machine Safety Photo Organizer (100% Production Ready Goal)

## 🚀 Quick Reference

**Current State**: ~200 TypeScript errors identified
**Goal**: 0 errors, 0 lint issues, all tests passing, production-ready
**Estimated Total Time**: 10-15 hours across 4 phases

---

## 📋 PHASE 5A: TypeScript Perfection

**Copy this prompt for a new Claude instance:**

```
Execute Phase 5A for Minerva project: Achieve 0 TypeScript errors.

OBJECTIVE: Fix ~200 TypeScript errors to achieve 100% production-ready state.

PLAN LOCATION: Read the detailed plan at:
C:\Users\Tom\dev\minerva\dev\03-in-progress\clean-up\20250826\phase-5a-typescript-perfection.md

FOCUS AREAS:
1. Scripts & Utilities (~70 errors - 35%):
   - scripts/analyze-component-coverage.ts (major null safety violations)
   - scripts/utils/command-executor.ts (string/array type mismatches)
   - scripts/maintenance/validate-environment.ts (undefined handling)

2. Test Files (~100 errors - 50%):
   - tests/ai-management/layout/ai-management-layout.test.tsx
   - tests/platform/tag-management/components/tag-list.test.tsx
   - tests/platform/tag-management/integration/tag-management-integration.test.tsx
   - tests/smart-albums.test.ts

3. Complex Types (~20 errors - 10%):
   - lib/utils/dynamic-imports-config.tsx (React generic constraints)
   - lib/services/real-time-service.ts (Supabase event types)

4. Edge Cases (~10 errors - 5%): Remaining misc issues

EXECUTION:
1. Start with scripts (high impact)
2. Fix test files systematically
3. Address complex type issues
4. Clean up edge cases
5. Validate: npx tsc --noEmit = 0 errors

PRIORITY: CRITICAL
ESTIMATED TIME: 4-6 hours
```

---

## 🔧 PHASE 5B: Lint & Build Perfection

**Copy this prompt for a new Claude instance:**

```
Execute Phase 5B for Minerva project: Achieve 0 lint errors and perfect builds.

OBJECTIVE: Clean code quality and production build optimization.

PREREQUISITES: Phase 5A must be completed (0 TypeScript errors)

PLAN LOCATION: Read the detailed plan at:
C:\Users\Tom\dev\minerva\dev\03-in-progress\clean-up\20250826\phase-5b-lint-build-perfection.md

FOCUS AREAS:
1. ESLint Cleanup:
   - Fix unused imports/variables
   - Add missing return type annotations
   - Implement prefer-const and optional chaining
   - Run: npm run lint -- --fix for auto-fixes

2. Code Formatting:
   - Execute: npm run format
   - Ensure consistent style across all files

3. Build Optimization:
   - Clean production builds: npm run build
   - Optimize bundle sizes
   - Fix build warnings

4. Import Organization:
   - Consistent import ordering
   - Optimize barrel exports
   - Remove unused dependencies

SUCCESS CRITERIA:
- npm run lint = 0 errors/warnings
- npm run build = successful
- npm run format = no changes needed

PRIORITY: HIGH
ESTIMATED TIME: 2-3 hours
```

---

## 🧪 PHASE 5C: Test Suite Completion

**Copy this prompt for a new Claude instance:**

```
Execute Phase 5C for Minerva project: All tests passing with complete coverage.

OBJECTIVE: 100% reliable test suite for production confidence.

PREREQUISITES: Phase 5A & 5B completed (0 TS errors, clean builds)

PLAN LOCATION: Read the detailed plan at:
C:\Users\Tom\dev\minerva\dev\03-in-progress\clean-up\20250826\phase-5c-test-suite-completion.md

FOCUS AREAS:
1. Test Infrastructure:
   - Validate Vitest & Playwright configurations
   - Update test fixtures to match new TypeScript types

2. Unit Test Fixes (Vitest):
   - Fix mock completeness in auth tests
   - Fix DOM query null safety in tag management tests
   - Fix SmartCriteria type completeness
   - Update component prop mocks

3. E2E Test Fixes (Playwright):
   - Fix page load timeouts with proper waits
   - Update element selectors to use data-testid
   - Fix authentication setup in tests

4. Coverage & Quality:
   - Run coverage analysis
   - Address test stability and flaky tests

SUCCESS CRITERIA:
- npm test = all passing
- npm run test:e2e = all passing
- Test coverage meets standards
- No flaky tests

PRIORITY: HIGH
ESTIMATED TIME: 3-4 hours
```

---

## 🚢 PHASE 5D: Production Readiness

**Copy this prompt for a new Claude instance:**

```
Execute Phase 5D for Minerva project: Final production readiness validation.

OBJECTIVE: 100% deployment-ready state with comprehensive validation.

PREREQUISITES: All previous phases completed successfully
- Phase 5A: 0 TypeScript errors
- Phase 5B: Clean lint, successful builds
- Phase 5C: All tests passing

PLAN LOCATION: Read the detailed plan at:
C:\Users\Tom\dev\minerva\dev\03-in-progress\clean-up\20250826\phase-5d-production-readiness.md

Here are the most recent validate all results:
C:\Users\Tom\dev\minerva\logs\latest\validate-all\2025-08-27_07-23-25

FOCUS AREAS:
1. System Integration:
   - Full system health checks
   - Environment configuration validation
   - Database schema verification

2. Security & Performance:
   - Security audit: npm audit --audit-level=moderate
   - Performance validation and bundle analysis
   - Access control verification

3. Deployment Readiness:
   - Production build validation
   - Configuration files verification
   - Documentation currency check

4. Final Production Gates:
   ALL MUST PASS for deployment:
   - npx tsc --noEmit (0 errors)
   - npm run lint (clean)
   - npm run build (successful)
   - npm test (all pass)
   - npm run test:e2e (all pass)
   - npm audit (no high-risk vulnerabilities)
   - No secrets in codebase

SUCCESS CRITERIA: All production gates pass consistently

PRIORITY: CRITICAL
ESTIMATED TIME: 2-3 hours
```

---

## 📊 Progress Tracking Commands

**Use these to check progress after each phase:**

```bash
# Phase 5A Progress
npx tsc --noEmit 2>&1 | grep "error TS" | wc -l

# Phase 5B Progress
npm run lint 2>&1 | grep -c "error\|warning"
npm run build && echo "✅ Build OK" || echo "❌ Build Failed"

# Phase 5C Progress
npm test 2>&1 | grep -c "FAIL\|failed"
npm run test:e2e 2>&1 | grep -c "failed"

# Phase 5D Validation
npm run validate:all || npm run validate:quick
```

---

## 🎯 Success Definition (ALL MUST BE TRUE)

```bash
# Final validation commands - ALL must pass:
npx tsc --noEmit                    # 0 TypeScript errors
npm run lint                        # 0 lint errors
npm run build                       # Successful build
npm test                           # All unit tests pass
npm run test:e2e                   # All E2E tests pass
npm audit --audit-level=moderate   # No critical vulnerabilities
```

---

## 📁 File Locations Summary

- **Phase 5A Plan**: `phase-5a-typescript-perfection.md`
- **Phase 5B Plan**: `phase-5b-lint-build-perfection.md`
- **Phase 5C Plan**: `phase-5c-test-suite-completion.md`
- **Phase 5D Plan**: `phase-5d-production-readiness.md`
- **This Document**: `claude-execution-prompts.md`

**Base Directory**: `C:\Users\Tom\dev\minerva\dev\03-in-progress\clean-up\20250826\`

---

## ⚡ Quick Start Commands

**For immediate execution in order:**

1. **Phase 5A**: `Execute Phase 5A for Minerva: Fix TypeScript errors. Read plan at phase-5a-typescript-perfection.md`

2. **Phase 5B**: `Execute Phase 5B for Minerva: Clean lint and builds. Read plan at phase-5b-lint-build-perfection.md`

3. **Phase 5C**: `Execute Phase 5C for Minerva: Fix all tests. Read plan at phase-5c-test-suite-completion.md`

4. **Phase 5D**: `Execute Phase 5D for Minerva: Production validation. Read plan at phase-5d-production-readiness.md`

**TOTAL ESTIMATED TIME**: 10-15 hours
**SUCCESS RATE**: 95%+ with systematic execution
**COMPLEXITY**: Medium-High but well-documented approach