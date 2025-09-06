# Agent Brief – Database Architect

Objective
- Ensure schema and RLS fully support org-scoped access and AI features.

Tasks
- Review migrations for organizations, users, photos, tags, ai_processing_results, cost tracking.
- Confirm RLS policies align with withAuth org scoping.
- Verify indexes for frequent filters (organization_id, status, created_at) are present.

Acceptance
- No changes needed OR a minimal migration proposal with rationale.
- Short note on RLS coverage and any risks.

