# Phase 1: Organization Context Hardening

Duration: 2–3 days
Priority: Critical
Dependencies: lib/with-auth.ts, lib/server-auth.ts, lib/supabase-server.ts

## Overview
Unify and secure the way organizationId is determined and propagated. Remove ad‑hoc client metadata usage and header/query fallbacks.

## Current Gaps (Evidence)
- Photos page uses TEMPORARY FIX: derives org from user metadata
  - Path: app/(protected)/photos/page.tsx
- AI analytics summary reads orgId from header/query
  - Path: app/api/ai/analytics/summary/route.ts

## Implementation Tasks

Task 1: Standardize Photos Page Org Context
- Replace client metadata org usage with a server-validated session org.
- Ensure usePhotos() receives orgId from session-aware source, not user metadata.
- Acceptance: No references to user_metadata.organization_id remain; page works unchanged.

Task 2: Refactor Analytics Summary Endpoint
- Wrap in withAuth and remove getOrganizationId helper.
- Enforce organization scoping via injected organizationId.
- Acceptance: 401 without session, 403 for unauthorized; no header/query org fallback.

Task 3: Audit & Wrap Key API Routes
- Audit app/api/photos/** and app/api/platform/** for withAuth usage.
- Wrap missing routes with withAuth and add rateLimits.
- Acceptance: Checklist produced and completed; routes return consistent envelopes.

Task 4: Add Unit Tests for Auth Paths
- Add/extend tests to assert 401/403 and cross‑org denial for at least 3 representative endpoints.
- Acceptance: New tests pass.

## Deliverables
- Updated Photos page and analytics summary route.
- Markdown checklist of wrapped endpoints.
- Passing unit tests for negative cases.

## Risks & Mitigations
- Risk: Access regressions – Mitigate with tests and incremental PRs.
- Risk: Performance impact – Keep logic at handler boundary; reuse helpers.

