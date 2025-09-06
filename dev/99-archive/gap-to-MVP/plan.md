# Gap to MVP – Implementation Plan

Owner: Tom Branch
Date: 2025-08-09
Status: Draft (Ready for agent pick-up)

## Workstreams

A) Organization Context Hardening
B) AI/Analytics API Security Standardization
C) CI Quality Gates and Lint/Type Fixes
D) Production Hygiene (Dev Utils, Dead/Duplicate code)
E) Test Suite Consolidation and E2E Coverage
F) Documentation & Ops Readiness Updates

## Milestones
- M1: Org context hardening complete (A) – 2–3 days
- M2: Security standardization in AI/analytics (B) – 2 days
- M3: CI gates enforced, lint/type green (C) – 1–2 days
- M4: Hygiene complete (D) – 1 day
- M5: Test suite stabilized; new e2e added (E) – 2–3 days
- M6: Docs/runbooks updated (F) – 1 day

## Detailed Tasks (Agent-Ready)

A) Organization Context Hardening
1. Replace client org derivation in Photos page
   - Path: app/(protected)/photos/page.tsx
   - Replace TEMPORARY FIX with a hook/server-provided org ID (e.g., inject via useAuth/useSession pulling from validated server session). Ensure API calls do not rely on user metadata.
   - Acceptance: No references to user.user_metadata.organization_id remain; all filters/org scoping sourced from validated session.
2. Audit and refactor API routes to rely on withAuth
   - Paths: app/api/** (focus: photos, ai, platform)
   - Ensure handlers receive (user, organizationId) from withAuth; remove header/query org fallbacks.
   - Acceptance: All protected routes wrapped in withAuth; unit tests added for 401/403 cases and cross-org access.

B) AI/Analytics API Security Standardization
3. Fix analytics summary route
   - Path: app/api/ai/analytics/summary/route.ts
   - Replace getOrganizationId helper with withAuth; require org-scoped access.
   - Acceptance: Endpoint rejects requests without valid session; no header/query orgId usage.
4. Review remaining AI endpoints for consistent auth
   - Paths: app/api/ai/**/*
   - Add withAuth + rateLimits where appropriate; confirm organization scoping for reads/writes.
   - Acceptance: Spot check 5 endpoints; add tests for at least provider-status, process-photo, prompts, experiments.

C) CI Quality Gates and Lint/Type Fixes
5. Resolve current lint errors
   - Review logs in scripts/logs/pre-commit-*/lint-check.md and fix unused/any types (e.g., routes under app/api/photos/*).
   - Acceptance: npm run lint passes locally; CI job enforces lint.
6. Enforce type checks
   - Ensure npm run build (tsc) runs in CI; fix type gaps found.
   - Acceptance: Type checks green in CI; no ignoreDuringBuilds reliance in CI.

D) Production Hygiene
7. Gate or remove test-data page in prod
   - Path: app/platform/test-data/page.tsx
   - Add env-based feature flag (e.g., NEXT_PUBLIC_ENABLE_TEST_DATA) and ensure platform admin guard; document flag.
   - Acceptance: Page hidden in production envs by default; covered by a small test.
8. Remove empty/legacy dirs and duplicates
   - Remove or populate app/ai-management (empty); search for duplicate supabase helper imports and consolidate.
   - Acceptance: Repo cleanup commit; scripts/maintenance/clean-logs.js run.

E) Test Suite Consolidation & E2E
9. Align Vitest aliases with tsconfig
   - Verify vitest.config.ts path aliases match tsconfig.json; fix failing imports (e.g., '@/components/ui/use-toast').
   - Acceptance: Unit/integration suites pass; mocked modules configured in test-utils.
10. Add e2e for platform admin flows
   - Add Playwright specs for: organizations CRUD, tag analytics, cost dashboard visibility, AI provider settings read.
   - Acceptance: e2e suite passes locally and in CI.

F) Documentation & Ops
11. Update Deployment & Runbooks
   - Docs to update: docs/setup/deployment-guide.md, PRODUCTION_READINESS_AUDIT_REPORT.md (appendix for platform admin), dev/05-reports (new status update).
   - Acceptance: Docs merged; reflect final org/session model and feature flag usage.

## Risk Management
- Add feature flags to roll out changes safely.
- Maintain a short-lived "compat" branch in case of unforeseen auth regressions.

## Validation Plan
- Unit tests for updated endpoints.
- E2E smoke on core flows (auth → upload → AI → search → bulk → export).
- Accessibility checks on updated pages (AI/admin nav unaffected).

## Rollback Plan
- Revert feature flag to disable newly gated surfaces.
- Maintain prior build on Vercel for one-click rollback.

