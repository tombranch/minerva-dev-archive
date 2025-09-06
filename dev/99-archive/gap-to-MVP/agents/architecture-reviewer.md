# Agent Brief – Architecture Reviewer

Objective
- Ensure a consistent, secure session/org model and eliminate legacy patterns.

Focus Areas
- Auth/org propagation from middleware to handlers and hooks
- Duplication in Supabase clients/helpers
- Empty/legacy directories (e.g., app/ai-management)

Key Refs
- lib/with-auth.ts, lib/server-auth.ts, lib/supabase-server.ts
- app/(protected)/photos/page.tsx (TEMPORARY FIX)
- app/api/ai/analytics/summary/route.ts

Deliverables
- Short architecture note describing the canonical session/org flow
- A cleanup plan for duplicate helpers and empty directories

Acceptance
- A documented single source-of-truth for org context
- Identified and removed/reconciled duplicate helper modules
- Empty app/ai-management resolved (removed or populated)

