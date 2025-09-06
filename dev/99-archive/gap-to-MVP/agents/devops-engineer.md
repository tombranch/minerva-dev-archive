# Agent Brief – DevOps Engineer

Objective
- Enforce CI quality gates and protect production surface.

Tasks
- Ensure CI runs: lint, type-check (tsc), unit/integration tests, e2e (optional on main).
- Remove reliance on next.config.ts eslint.ignoreDuringBuilds in CI.
- Add env flag handling for NEXT_PUBLIC_ENABLE_TEST_DATA and set to false in prod.
- Verify Vercel/CI env vars for Supabase and AI keys are configured safely.

Acceptance
- CI green with lint/type enforced.
- Test-data page disabled in prod by default.
- Documented CI steps in docs/deployment.

