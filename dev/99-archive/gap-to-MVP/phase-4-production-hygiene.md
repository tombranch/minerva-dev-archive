# Phase 4: Production Hygiene (Dev Utils, Dead/Duplicate Code)

Duration: 1 day
Priority: Medium
Dependencies: None

## Overview
Reduce production surface and clean up legacy/duplicate code.

## Implementation Tasks

Task 1: Gate Platform Test-Data Page
- Path: app/platform/test-data/page.tsx
- Add NEXT_PUBLIC_ENABLE_TEST_DATA flag; keep platform admin guard.
- Acceptance: Page hidden by default in production; short unit test for gating.

Task 2: Remove Empty/Legacy Directories
- Remove or populate app/ai-management (currently empty).
- Acceptance: Directory removed or repurposed; update references if any.

Task 3: Consolidate Helpers
- Identify duplicate supabase helper imports; standardize on lib/supabase-server.ts and lib/supabase.ts usage.
- Acceptance: One canonical import path; PR includes rationale.

Task 4: Cleanup Scripts
- Run scripts/maintenance/clean-logs.js and remove obsolete logs/artifacts.
- Acceptance: Repository tidy; CI unaffected.

