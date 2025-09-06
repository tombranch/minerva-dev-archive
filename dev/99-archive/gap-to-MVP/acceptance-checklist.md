# Gap to MVP – Acceptance Checklist

Use this checklist to approve the completion of the "Gap to MVP" initiative.

## Organization & Security
- [ ] Photos page no longer derives orgId from client metadata; uses server session
- [ ] app/api/ai/analytics/summary/route.ts uses withAuth; no header/query orgId
- [ ] All protected app/api routes use withAuth and organization scoping
- [ ] Rate limiting enabled where appropriate on protected APIs

## Quality Gates
- [ ] ESLint passes (no unused or any types in targeted files)
- [ ] Type checks pass in CI (tsc)
- [ ] CI enforces lint/type/test; ignoreDuringBuilds not relied on in CI

## Hygiene
- [ ] app/platform/test-data gated by NEXT_PUBLIC_ENABLE_TEST_DATA and admin check
- [ ] app/ai-management folder addressed (removed or populated)
- [ ] Duplicate/canonical helper imports resolved; repo cleanup committed

## Tests
- [ ] Vitest path aliases aligned with tsconfig
- [ ] Unit/integration suites pass locally and in CI
- [ ] Playwright e2e covers: org CRUD, tag analytics, cost dashboards, provider settings
- [ ] Accessibility tests pass on affected surfaces

## Docs & Ops
- [ ] Deployment Guide updated with final session/org model and feature flags
- [ ] Production Readiness Audit updated for platform admin features
- [ ] New status report saved to dev/05-reports summarizing outcomes

