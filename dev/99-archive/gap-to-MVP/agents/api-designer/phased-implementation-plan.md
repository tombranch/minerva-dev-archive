# API Designer – Phased Implementation Plan

Priority: Critical
Duration: ~4–5 days total
Dependencies: withAuth, server session utilities, rate limit utilities, response helpers

## Phase 1: Organization Context Standardization (2 days)
Agent Assignment: API Designer

Overview
Replace ad‑hoc organizationId extraction with the canonical withAuth injection across protected API routes.

Targets
- app/api/ai/analytics/summary/route.ts
- app/api/photos/**
- app/api/platform/**
- app/api/ai/** (sample subset in Phase 1, remainder Phase 2)

Tasks
1) Create audit list of endpoints not using withAuth
   - Output a markdown checklist with paths and current auth method.
2) Refactor endpoint signatures to withAuth(request, user, organizationId)
   - Remove header/query org fallbacks.
   - Use createSuccessResponse/createErrorResponse uniformly.
3) Add/confirm rateLimits on each protected endpoint.

Acceptance
- All Phase 1 endpoints receive organizationId from withAuth only.
- 401 for no session; 403 for unauthorized role or cross‑org access.
- Lint clean; unit tests updated where present.

## Phase 2: AI & Analytics Endpoint Alignment (1–2 days)
Agent Assignment: API Designer

Overview
Standardize authentication and error semantics on AI endpoints and provider/experiments routes.

Targets
- app/api/ai/analytics/* (besides summary)
- app/api/ai/process-photo, process-batch, processing-status
- app/api/ai/providers, prompts, experiments

Tasks
1) Wrap handlers with withAuth and rateLimits where applicable.
2) Ensure org scoping (organizationId) is used on DB queries.
3) Normalize errors: ValidationError 400, ForbiddenError 403, RateLimited 429.

Acceptance
- No AI route reads org from query/header.
- Consistent response envelopes across routes.
- New negative tests for 401/403 on a sample of endpoints.

## Phase 3: Contract & Client Guidance (1 day)
Agent Assignment: API Designer

Overview
Publish a concise API usage note for client hooks.

Tasks
1) Document the expected handler signature and response envelope.
2) Add a short client integration guide for TanStack Query hooks (error shapes, pagination fields).
3) Open follow‑up issues for any client hooks that still pass orgId manually.

Acceptance
- /dev/02-ready/gap-to-MVP/agents/api-designer/notes.md with contract guidance.
- No client code passes orgId manually to protected endpoints.

