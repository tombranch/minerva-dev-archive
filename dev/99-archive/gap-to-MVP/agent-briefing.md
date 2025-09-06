# Gap to MVP – Agent Briefing

Audience: AI coding agents (Augment, Claude, Gemini)
Coordinator: Tom Branch
Date: 2025-08-09

## Objective
Close the final 10–15% to reach MVP readiness by hardening org/session security, cleaning up dev/test patterns, enforcing CI quality gates, stabilizing tests, and updating docs.

## Key Refs
- Photos page: app/(protected)/photos/page.tsx
- Analytics summary endpoint: app/api/ai/analytics/summary/route.ts
- Auth helpers: lib/with-auth.ts, lib/server-auth.ts, lib/supabase-server.ts
- Lint logs: scripts/logs/pre-commit-*/lint-check.md
- Vitest config: vitest.config.ts; tsconfig.json
- Docs to update: docs/setup/deployment-guide.md; PRODUCTION_READINESS_AUDIT_REPORT.md
- Review report: dev/05-reports/comprehensive-project-review-2025-08-09.md

## Workstreams & Assignment Hints

A) Org Context Hardening
- Replace TEMPORARY FIX in Photos page; ensure usePhotos filters receive orgId from validated session.
- Audit API routes; ensure withAuth injects organizationId and remove header/query org fallbacks.

B) AI/Analytics Security Standardization
- Update analytics summary route to require withAuth.
- Review related AI endpoints for consistent withAuth + rateLimits + org scoping.

C) CI Quality Gates & Lint/Type
- Fix unused variables and any types in app/api/photos/* routes indicated by lint logs.
- Ensure CI runs lint and type checks; do not rely on ignoreDuringBuilds.

D) Production Hygiene
- Gate app/platform/test-data by NEXT_PUBLIC_ENABLE_TEST_DATA; ensure platform admin guard stays in place.
- Remove empty app/ai-management folder or migrate content if any.
- Run cleanup scripts and ensure no duplicated helpers.

E) Tests & E2E
- Align Vitest path aliases with tsconfig; add missing mocks (e.g., '@/components/ui/use-toast').
- Add Playwright tests for platform admin flows.

F) Docs & Ops
- Update deployment guide and audit report to reflect final auth/org model and feature flags.

## Definition of Done
- All acceptance checklist items in dev/02-ready/gap-to-MVP/acceptance-checklist.md are checked off.
- CI is green with lint/type/test.
- A short final status summary is saved to dev/05-reports.

## Constraints
- Do not introduce breaking schema changes.
- Use provided auth/helpers; avoid custom ad hoc org extraction.
- Keep edits small and PRs focused by workstream.

