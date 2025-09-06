# Project Cleanup Plan: Overview

Scope: Accelerate completion of pre-commit checks by parallelizing safe fixes. This plan is designed for Claude Code instances to execute in phases with minimal cross-conflicts.

Source logs
- Logs folder: logs/pre-commit-2025-08-11_14-43-18
- Summary: 3 failures
  - Formatting: 1 issue
  - Linting: 623 errors, 122 warnings
  - Type checking: 1 error

Top issue categories (from lint/type logs)
- TypeScript: 1 error in LiveStatus SystemHealth props
- ESLint in components/*
  - Unused imports/variables
  - react/no-unescaped-entities (quotes/apostrophes in JSX strings)
  - react-hooks/exhaustive-deps
  - Explicit any in components (must be removed; UI is strict)
  - jsx-a11y alt text and a few Next.js <img> usage warnings
- ESLint in lib/*
  - some any usage; currently warnings (non-blocking) due to override

Desired outcomes
- Pre-commit passes all checks (format, lint, type)
- UI components remain strict (no explicit any) and hooks follow best practices
- Mechanical fixes done in parallel by directory to speed up completion

Concurrency strategy
- Phase 00 (quick wins) first; then run Phases 01–04 concurrently per directory group:
  - components/ai/console/**
  - components/ai/features/**
  - components/ai/monitoring/**
  - components/ai/experiments/**
  - components/search/**
  - components/platform/**
  - components/ui/**
- Each group can be assigned to a separate Claude Code instance for Phase 01 (unused + entities). Subsequent phases can follow in staggered waves.

Verification commands (run locally)
- Format: npm run format:check
- Lint (UI strictness preserved): npx eslint components --max-warnings=0
- Type: npx tsc -p tsconfig.production.json --noEmit
- Full pre-commit: npm run pre-commit (writes logs/*)

Notes
- ESLint flat config adjusted: no-explicit-any is error for components/** and warn for lib/** and hooks/**. This keeps UI strict while allowing incremental cleanup of legacy/server code.
- Avoid disabling rules unless absolutely necessary; prefer best-practice fixes (e.g., stable callbacks, proper deps).

