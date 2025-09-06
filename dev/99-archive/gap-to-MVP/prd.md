# Gap to MVP – Product Requirements Document (PRD)

## Overview
- Project: Minerva – Machine Safety Photo Organizer
- Goal: Close remaining gaps to reach MVP quality and enable confident production rollout.
- Owner: Tom Branch
- Contributors: AI coding agents (Augment/Claude/Gemini), maintainers
- Date: 2025-08-09

## Problem Statement
The application is ~85–90% MVP complete. Core features exist with a real backend. Remaining gaps are primarily around security hardening (organization context), CI quality gates, production hygiene, test suite consolidation, and documentation updates.

## Goals
- Enforce a single, secure source-of-truth for organization context across app and APIs.
- Remove temporary/test-only patterns from production code paths.
- Restore/strengthen CI quality gates (lint/type/test) to prevent regressions.
- Consolidate tests and ensure e2e coverage for critical platform admin flows.
- Update operational docs reflecting the final session/org pattern and go-live procedures.

## Non-Goals
- Rewriting feature functionality beyond MVP scope.
- Large-scale UX redesigns.
- Adding new AI providers beyond those already scaffolded.

## In Scope
1) Org/session hardening across frontend and API routes.
2) AI/analytics route security review and standardization.
3) CI quality gates reinstatement and lint/type fixes.
4) Production hygiene (dev utilities, dead code, duplicates).
5) Test suite/aliases consolidation and additional e2e coverage.
6) Documentation and ops/runbook updates.

## Out of Scope
- New major features beyond MVP list.
- Data migration beyond current schema.

## Users and Use Cases (MVP)
- Engineers/Admins: Upload/search/tag photos; review AI results; manage projects/sites.
- Platform Admin: Manage organizations/users/tags/costs; review analytics.

## Success Metrics
- Security: 100% of API routes that require auth use withAuth and server-validated org context; zero header/query org fallbacks.
- Quality: CI green with lint/type/tests; no ignoreDuringBuilds in prod CI.
- Hygiene: Dev/test-only pages feature-flagged or removed; empty/duplicate dirs cleaned.
- Testing: e2e coverage includes platform admin critical paths; a11y suite passes; unit/integration stable.
- Docs: Deployment and runbooks reflect final auth/org approach; updated production readiness checklist.

## Acceptance Criteria (High-Level)
- All org context is sourced from validated server session; client-side TEMPORARY FIX removed from Photos page.
- AI analytics summary and similar endpoints use withAuth and organization scoping only.
- ESLint warnings fixed for referenced routes; CI enforces lint/type.
- Platform test-data page is gated (admin + feature flag) or removed for prod.
- app/ai-management empty folder removed or populated; duplicate helpers consolidated.
- Vitest aliases and tsconfig align; failing test imports resolved; new e2e tests added.
- Updated docs committed under docs/deployment and dev/05-reports.

## Constraints/Dependencies
- Supabase environment variables available in CI for tests that require mocks or integration stubs.
- Next.js App Router with TypeScript strict mode.
- Existing migrations and RLS policies.

## Risks
- Refactors touching auth/org flow can cause access regressions if not thoroughly tested.
- Tightening CI gates can surface latent issues; schedule time to fix.

## References
- Photos page: app/(protected)/photos/page.tsx (org TEMPORARY FIX)
- AI analytics summary: app/api/ai/analytics/summary/route.ts
- Service clients: lib/supabase-server.ts; withAuth
- Migrations: supabase/migrations/*
- Production audit: PRODUCTION_READINESS_AUDIT_REPORT.md

