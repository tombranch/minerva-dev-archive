# Phase 6: Documentation & Ops Readiness

Duration: 1 day
Priority: Medium
Dependencies: Phases 1–5

## Overview
Bring deployment/runbooks and audits in line with the finalized session/org model and feature flags.

## Implementation Tasks

Task 1: Update Deployment Guide
- Update docs/setup/deployment-guide.md with:
  - Server-validated session and org propagation model
  - CI gates (lint/type/tests)
  - NEXT_PUBLIC_ENABLE_TEST_DATA flag usage
- Acceptance: PR merged; references to old header/query org patterns removed.

Task 2: Update Production Readiness Audit
- Add appendix for platform admin features to PRODUCTION_READINESS_AUDIT_REPORT.md.
- Acceptance: Audit reflects auth/org enforcement and e2e results.

Task 3: Final Report
- Save a short outcomes report under dev/05-reports summarizing closures and any residual risks.
- Acceptance: Report saved and linked from status.md.

