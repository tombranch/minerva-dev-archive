# Agent Brief – Code Writer

Objective
- Implement code changes to close MVP gaps with minimal, safe diffs.

Tasks
1) Photos page org context
   - Path: app/(protected)/photos/page.tsx
   - Remove TEMPORARY FIX that uses user metadata; use validated session.
2) Analytics summary auth
   - Path: app/api/ai/analytics/summary/route.ts
   - Replace helper with withAuth; require org scoping.
3) Lint fixes
   - Address unused vars / any types in app/api/photos/** per logs.
4) Test-data gating
   - Path: app/platform/test-data/page.tsx
   - Add env flag NEXT_PUBLIC_ENABLE_TEST_DATA; keep platform admin check.
5) Repo hygiene
   - Remove empty app/ai-management; consolidate duplicate helpers.

Acceptance
- Lint passes locally; unit tests updated as needed.
- All modified APIs use withAuth and return consistent responses.
- Test-data page hidden by default in prod.

