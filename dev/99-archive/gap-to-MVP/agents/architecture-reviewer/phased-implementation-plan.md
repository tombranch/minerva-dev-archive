# Architecture Reviewer – Phased Implementation Plan

Priority: High
Duration: ~3 days
Dependencies: Codebase audit results, withAuth/server-auth docs

## Phase 1: Canonical Session/Org Model (1 day)
Overview
Define and document the single source-of-truth for session and organization context propagation.

Tasks
1) Draft a 1–2 page architecture note describing:
   - How session is validated on server
   - How organizationId is derived and injected (withAuth)
   - How client code should access org (never from metadata directly)
2) Link to helper APIs (lib/with-auth.ts, lib/supabase-server.ts).

Acceptance
- Note saved at: dev/02-ready/gap-to-MVP/agents/architecture-reviewer/architecture-note.md

## Phase 2: Duplication & Legacy Cleanup Plan (1 day)
Overview
Identify duplicates and legacy directories; propose consolidation/removal steps.

Tasks
1) Inventory supabase client helpers; ensure one canonical import path.
2) Flag empty app/ai-management directory; propose removal.
3) Recommend alias updates for tests to match tsconfig.

Acceptance
- Cleanup checklist saved; issues opened per item.

## Phase 3: Review Refactors (1 day)
Overview
Review API designer and code writer PRs.

Tasks
1) Check adherence to architecture note.
2) Confirm no reintroduction of header/query org fallbacks.
3) Sign off on performance considerations.

Acceptance
- Review notes appended to each PR; approvals recorded.

