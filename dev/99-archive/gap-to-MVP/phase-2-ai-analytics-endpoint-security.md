# Phase 2: AI & Analytics Endpoint Security Standardization

Duration: 2 days
Priority: High
Dependencies: Phase 1 (withAuth pattern), lib/with-auth.ts, lib/rate-limit.ts, lib/api-response.ts

## Overview
Ensure all AI/analytics endpoints enforce session/org context and consistent error semantics.

## Targets
- app/api/ai/analytics/* (beyond summary)
- app/api/ai/process-photo, process-batch, processing-status
- app/api/ai/providers, prompts, experiments

## Implementation Tasks

Task 1: Wrap Remaining Analytics Endpoints
- Add withAuth and rateLimits.
- Apply organization scoping where DB access happens.
- Acceptance: No org via header/query; 401/403/429 semantics consistent.

Task 2: Normalize Response Shapes
- Use createSuccessResponse/createErrorResponse.
- Include pagination/metadata consistently if applicable.
- Acceptance: Contract consistency verified across 3+ endpoints.

Task 3: Negative Tests for Security
- Add tests for missing session and cross-org attempts on at least 3 endpoints (e.g., provider-status, process-photo, prompts).
- Acceptance: Tests pass; code paths verified.

## Deliverables
- Updated routes with withAuth + rate limits.
- Consistent response envelopes.
- Negative tests added.

