# Gap to MVP – Status & Tracking

Status: Not started
Owner: Tom Branch
Date: 2025-08-09

## Checklist (Acceptance-Level)

- [ ] All org context from validated server session; no header/query org fallbacks
- [ ] All protected endpoints wrapped with withAuth and scoped by organization
- [ ] Lint and type checks pass in CI; no ignoreDuringBuilds reliance
- [ ] Test-data page gated by env flag or removed in production
- [ ] Empty/legacy directories removed or populated; duplicates consolidated
- [ ] Vitest path aliases aligned; unit/integration stable
- [ ] New e2e for platform admin flows pass locally and in CI
- [ ] Deployment docs updated; production readiness checklist updated

## Workstream Kanban

A) Org Context Hardening
- Tasks: Replace TEMPORARY FIX in Photos; audit APIs
- Blockers: None known

B) AI/Analytics Security
- Tasks: Fix analytics summary; standardize across ai/*
- Blockers: None known

C) CI Quality Gates
- Tasks: Fix lint errors; enable type checks in CI
- Blockers: Ensure CI has correct Node version and memory limits

D) Hygiene
- Tasks: Gate/remove test-data page; remove empty app/ai-management; consolidate helpers
- Blockers: None known

E) Tests & E2E
- Tasks: Align aliases; add platform admin e2e
- Blockers: Supabase envs or mocks for CI

F) Docs & Ops
- Tasks: Update deployment guide; expand production audit
- Blockers: None

## Links
- PRD: dev/02-ready/gap-to-MVP/prd.md
- Plan: dev/02-ready/gap-to-MVP/plan.md
- Source review: dev/05-reports/comprehensive-project-review-2025-08-09.md
- Audit: PRODUCTION_READINESS_AUDIT_REPORT.md

