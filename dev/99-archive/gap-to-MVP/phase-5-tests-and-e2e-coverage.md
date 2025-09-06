# Phase 5: Tests & E2E Coverage (Platform Admin)

Duration: 2–3 days
Priority: High
Dependencies: Phase 1–2 completed (auth/org model stable)

## Overview
Stabilize tests and add e2e coverage for platform admin critical flows.

## Implementation Tasks

Task 1: Align Vitest Aliases & Mocks
- Ensure vitest.config.ts aliases reflect tsconfig.json.
- Add missing component mocks (e.g., '@/components/ui/use-toast') to test-utils.
- Acceptance: Unit/integration suites pass locally and in CI.

Task 2: E2E Specs for Platform Admin
- Add Playwright specs for:
  - Organizations CRUD (list/create/update)
  - Tag analytics page loads and renders data
  - Cost dashboard shows metrics for an org
  - Provider settings view loads
- Acceptance: e2e suite green locally; “main” CI job runs these.

Task 3: Negative/Security Paths
- Add tests for 401/403 on platform admin pages when not platform_admin.
- Acceptance: Tests pass and catch improper access.

