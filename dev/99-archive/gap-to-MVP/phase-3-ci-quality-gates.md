# Phase 3: CI Quality Gates and Lint/Type Remediation

Duration: 1–2 days
Priority: High
Dependencies: CI configuration, eslint, tsconfig, vitest

## Overview
Reinstate strict CI gates and fix current lint/type issues to prevent regressions.

## Evidence
- Lint failures in scripts/logs/pre-commit-*/lint-check.md (unused vars, any types in app/api/photos/*)
- next.config.ts has eslint.ignoreDuringBuilds: true (acceptable locally, not for CI)

## Implementation Tasks

Task 1: Fix Current Lint Errors
- Address unused vars and any types reported; prefer precise types.
- Acceptance: npm run lint passes locally.

Task 2: Enforce CI Gates
- Ensure CI runs: lint, tsc, unit/integration tests; optionally e2e on main only.
- Do not rely on ignoreDuringBuilds in CI; fail build on lint/type errors.
- Acceptance: CI green with gates active.

Task 3: Type Safety Sweep
- Review hotspots (types in APIs/hooks) and remove new any occurrences.
- Acceptance: tsc passes; eslint no-explicit-any satisfied in modified files.

## Deliverables
- Clean lint logs, CI configuration updated, green checks.

