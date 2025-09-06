  🎯 OBJECTIVE

  Achieve 100% production-ready state: 0 TypeScript errors, 0 lint errors, successful builds, and complete test coverage.        

  📊 CURRENT STATE

  - TypeScript Errors: ~330 remaining (from 350+)
  - Core Business Logic: ✅ Clean (Phase 4E completed critical fixes)
  - Infrastructure: ✅ Solid foundation established
  - Remaining Issues: Test files, scripts, and edge cases

  🚀 HIGH-LEVEL EXECUTION PHASES

  PHASE 5A: TypeScript Perfection ⚡

  Target: 0 TypeScript errors
  Duration: 4-6 hours
  Priority: CRITICAL

  Focus Areas:
  1. Test Files Cleanup (~150 errors)
    - Fix null safety in DOM queries
    - Add missing optional properties in mocks
    - Standardize test data structures
  2. Scripts & Utilities (~154 errors)
    - Fix analyze-component-coverage.ts null safety
    - Resolve command-executor.ts string/array types
    - Fix readonly array assignments
  3. Complex Type Issues (~15 errors)
    - Dynamic imports React generic constraints
    - Supabase real-time event types
    - Smart Album criteria completeness
  4. Final Edge Cases (~11 remaining)
    - Image component prop compatibility
    - Form validation type safety
    - API route type consistency

  PHASE 5B: Lint & Build Perfection ✨

  Target: 0 lint errors, perfect builds
  Duration: 2-3 hours
  Priority: HIGH

  Tasks:
  1. Run npm run lint and fix all ESLint errors
  2. Run npm run format for code consistency
  3. Ensure npm run build completes successfully
  4. Fix any build-time warnings or issues
  5. Validate all import paths and dependencies

  PHASE 5C: Test Suite Completion 🧪

  Target: All tests passing, 100% reliability
  Duration: 3-4 hours
  Priority: HIGH

  Tasks:
  1. Fix failing unit tests (Vitest)
  2. Fix failing e2e tests (Playwright)
  3. Ensure test coverage meets standards
  4. Validate all test mocks and fixtures
  5. Run full test suite validation

  PHASE 5D: Production Readiness Validation 🚢

  Target: 100% deployment ready
  Duration: 2-3 hours
  Priority: CRITICAL

  Final Checklist:
  1. ✅ npx tsc --noEmit = 0 errors
  2. ✅ npm run lint = 0 errors
  3. ✅ npm run build = successful
  4. ✅ npm test = all passing
  5. ✅ npm run test:e2e = all passing
  6. ✅ Environment validation complete
  7. ✅ Security audit clean
  8. ✅ Performance benchmarks met

  📋 EXECUTION COMMANDS FOR NEW CLAUDE INSTANCE

  # Phase 5A: TypeScript Zero
  Execute Phase 5A: Achieve 0 TypeScript errors for Minerva project.
  Focus: Test files (~150 errors), Scripts (~154 errors), Complex types (~15 errors).
  Run initial assessment, create detailed plan, execute systematically.
  Validate with: npx tsc --noEmit

  # Phase 5B: Lint & Build Zero  
  Execute Phase 5B: Achieve 0 lint errors and perfect builds.
  Run: npm run lint, npm run format, npm run build
  Fix all issues, ensure clean compilation.

  # Phase 5C: Test Suite Perfect
  Execute Phase 5C: All tests passing, complete coverage.
  Fix: Vitest unit tests, Playwright e2e tests, test infrastructure.
  Validate: npm test && npm run test:e2e

  # Phase 5D: Production Ready
  Execute Phase 5D: Final production readiness validation.
  Complete all checks, ensure 100% deployment ready state.

  🎯 SUCCESS CRITERIA

  Definition of DONE:
  - 0 TypeScript errors (npx tsc --noEmit)
  - 0 lint errors (npm run lint)
  - Successful build (npm run build)
  - All tests passing (npm test + npm run test:e2e)
  - Clean security audit (no critical vulnerabilities)
  - Performance validated (build times, bundle sizes)
  - Documentation current (README, API docs up-to-date)

  📁 KEY FILES REQUIRING ATTENTION

  - tests/**/*.test.tsx (null safety, mock completeness)
  - scripts/analyze-component-coverage.ts (major null safety issues)
  - scripts/utils/command-executor.ts (type mismatches)
  - lib/utils/dynamic-imports-config.tsx (React generic constraints)
  - lib/services/real-time-service.ts (Supabase event types)

  🚨 CRITICAL SUCCESS FACTORS

  1. Systematic Approach: Address errors by category, not randomly
  2. Test First: Fix test infrastructure before business logic
  3. Validate Frequently: Run checks after each major fix batch
  4. No Shortcuts: Proper types, not any casts
  5. Document Changes: Track what was fixed and why

  ESTIMATED TOTAL TIME: 10-15 hours across 4 phases
  COMPLEXITY: Medium-High (extensive but systematic)
  RISK: Low (foundation already solid from Phase 4E)

Your task is to create all the implemation plans to deliver these phases. Also create a prompt document - this will be a high level short prompt i can give to the claude code instance, with which phase it will implemnet and the link to the relevant file. save all docs here => C:\Users\Tom\dev\minerva\dev\03-in-progress\clean-up\20250826