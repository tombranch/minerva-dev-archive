# Agent Brief – Type Safety Enforcer

Objective
- Eliminate `any` and fix type drift in targeted files.

Tasks
- Address issues indicated by scripts/logs/pre-commit-*/lint-check.md (e.g., app/api/photos/*).
- Align shared types in types/ and lib/types to ensure consistent API responses.

Acceptance
- ESLint no-explicit-any satisfied; type-checks pass.

