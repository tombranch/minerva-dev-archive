Instance 1: API Routes & Core Services

  Please read the TypeScript cleanup plan at C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\MASTER-PLAN.md and
  C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\phase-1-api-routes.md

  Your task is to fix all TypeScript and ESLint errors in Phase 1 (API Routes & Core Services). Use the
  typescript-safety-validator agent to systematically fix all issues in the listed files.

  Focus on:
  - Fixing undefined variables (request → _request, user → _user, data → _data)
  - Removing ALL any types
  - Adding missing function definitions like createErrorResponse
  - Fixing provider type literals

  Start immediately and report completion when done. The build should pass for all API routes after your fixes.

  Instance 2: Test Files & Mocking

  Please read the TypeScript cleanup plan at C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\MASTER-PLAN.md and
  C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\phase-2-test-files.md

  Your task is to fix all TypeScript errors in Phase 2 (Test Files & Mocking). Use the type-safety-enforcer agent
  to systematically fix all test-related type errors.

  Focus on:
  - Fixing MockQueryBuilder type conversions
  - Adding missing properties to mock objects (like 'aud' property)
  - Fixing generic type arguments
  - Creating reusable mock utilities

  Start immediately and ensure all tests compile and pass after your fixes.

  Instance 3: Platform/Debug Pages

  Please read the TypeScript cleanup plan at C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\MASTER-PLAN.md and
  C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\phase-3-platform-pages.md

  Your task is to fix all TypeScript errors in Phase 3 (Platform/Debug Pages). Use the typescript-safety-validator
  agent to fix all platform page type errors.

  Focus on:
  - Fixing unknown type property access with proper type guards
  - Fixing ReactNode assignments
  - Creating proper environment data type definitions
  - Fixing null vs undefined type mismatches

  Start immediately and ensure all platform pages compile without errors.

  Instance 4: Components

  type-lint-issues-cleanup\

  Please read the TypeScript cleanup plan at C:\Users\Tom\dev\minerva\dev\type-lint-issues-cleanup\02-ready\MASTER-PLAN.md and
  C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\phase-4-components.md

  Your task is to fix all TypeScript errors in Phase 4 (Component Type Safety). Use the type-safety-enforcer agent
  to fix all component type errors.

  Focus on:
  - Adding proper component prop interfaces
  - Fixing event handler types (onClick, onChange, onSubmit)
  - Fixing state and ref types
  - Creating shared prop type definitions

  Start immediately and ensure all components have proper TypeScript definitions.

  Instance 5: Final Cleanup (Start this AFTER the others)

  WAIT until the other 4 instances complete their work, then:

  Please read the TypeScript cleanup plan at C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\MASTER-PLAN.md and
  C:\Users\Tom\dev\minerva\dev\02-ready\type-lint-issues-cleanup\phase-5-eslint-cleanup.md

  Your task is Phase 5 (Final Cleanup). Use the quality-assurance-specialist agent to:
  1. Remove ALL remaining any types in the entire codebase
  2. Fix all unused variables (prefix with _ or remove)
  3. Fix any remaining TypeScript errors
  4. Run final validation

  Run these commands to verify success:
  - npm run lint (should pass with 0 errors)
  - npx tsc --noEmit (should pass with 0 errors)
  - npm run build (should complete successfully)
  - npm test (all tests should pass)

  Report the final counts of errors fixed and confirm the build is clean.

  Important Notes:

  - Instances 1-4 can are runing simultaneously
  - Each instance should use the specified agent type
  - Each instance should focus only on their assigned files
  - Monitor Task Manager - use npm run cleanup if node processes build up

  This parallel approach should complete all fixes in 2-3 hours!