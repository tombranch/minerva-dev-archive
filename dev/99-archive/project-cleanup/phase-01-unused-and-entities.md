# Phase 01 – Unused imports/vars and JSX entities (Parallel per directory)

Objective
- Resolve the bulk of ESLint errors: unused imports/variables and react/no-unescaped-entities.

Directories (can run concurrently)
- components/ai/console/**
- components/ai/features/**
- components/ai/monitoring/**
- components/ai/experiments/**
- components/search/**
- components/platform/**
- components/ui/**

Guidelines
- Remove unused imports and variables. If placeholder code is intentionally kept, prefix identifiers with `_`.
- For JSX strings containing quotes:
  - Replace ' with &apos; or &#39; inside JSX literals when necessary.
  - Replace " with &quot; where flagged by react/no-unescaped-entities.
  - Prefer string templates or wrapping with {"..."} only if it quiets the rule and preserves readability.
- Do not change runtime behavior; keep it mechanical.

Steps per directory
1) Run ESLint on directory: `npx eslint <dir> --max-warnings=0`.
2) For each reported file:
   - Remove unused imports/vars.
   - Fix JSX entities per rule suggestions.
3) Re-run ESLint until clean.

Validation
- npx eslint <dir> --max-warnings=0

Deliverables
- Commit per directory: chore(cleanup): remove unused imports/vars and fix JSX entities in <dir>

Prompt for Claude Code
```
You are assigned Phase 01 – Unused & Entities for <DIR>.
1) Run `npx eslint <DIR> --max-warnings=0`.
2) Fix all @typescript-eslint/no-unused-vars and react/no-unescaped-entities errors mechanically.
3) Re-run ESLint until clean for this directory.
4) Do not modify logic; only unused identifiers and entity escapes.
5) Provide a bullet list of files touched.
```
