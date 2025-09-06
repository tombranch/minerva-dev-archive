# Phase 04 – Finalize & Verify (Serial)

Objective
- Ensure all pre-commit checks pass; consolidate edge cases.

Steps
1) Run Prettier and ESLint across components/*: 
   - `npm run format`
   - `npx eslint components --max-warnings=0`
2) Type check:
   - `npx tsc -p tsconfig.production.json --noEmit`
3) Full pre-commit:
   - `npm run pre-commit`
4) If any failures:
   - Inspect logs in logs/pre-commit-*/
   - Triage back into Phase 01–03 buckets and fix.

Deliverables
- Commit: chore(cleanup): finalize and verify pre-commit
- Short summary in dev/02-ready/project-cleanup/verification-summary.md

Prompt for Claude Code
```
You are assigned Phase 04 – Finalize & Verify.
1) Run `npm run format` and `npx eslint components --max-warnings=0`.
2) Run TypeScript check: `npx tsc -p tsconfig.production.json --noEmit`.
3) Run `npm run pre-commit` and paste the summary table.
4) If anything fails, open the generated logs and fix in-place or re-assign to prior phases.
```
