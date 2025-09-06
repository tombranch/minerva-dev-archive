# Agent Brief – API Designer

Objective
- Standardize org-scoped, authenticated API access and remove header/query org fallbacks.

Key Refs
- withAuth: lib/with-auth.ts
- Server session validation: lib/server-auth.ts, lib/supabase-server.ts
- AI analytics summary: app/api/ai/analytics/summary/route.ts
- Photos/API examples: app/api/photos/**/*, app/api/platform/**/*, app/api/ai/**/*

Scope
1) Replace ad hoc `organizationId` extraction with withAuth injection across protected routes.
2) Define a minimal API contract for org context propagation and error semantics.
3) Add/confirm rate limits on protected endpoints.

Deliverables
- Updated handlers using withAuth signature (request, user, organizationId)
- Error spec: 401/403/429 patterns applied consistently
- Brief usage notes for consumers (client hooks)

Acceptance
- No protected route uses header/query for orgId.
- Rate limits applied where appropriate.
- Unit tests updated for 401/403 and cross-org access denial.

Suggested Steps
1) Audit app/api/** and list endpoints not using withAuth.
2) Update analytics/summary to use withAuth; remove getOrganizationId helper.
3) Align response shape via createSuccessResponse/createErrorResponse.
4) Add tests for chosen sample endpoints.

