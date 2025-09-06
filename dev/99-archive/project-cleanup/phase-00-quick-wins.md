# Phase 00 – Quick Wins (Serial)

Objective
- Fix the single TypeScript error and the single formatting issue to reduce noise before parallel work.

Tasks
1) Type error in LiveStatus
   - File: components/ai/console/LiveStatus/LiveStatus.tsx
   - Error (from type-check.md): SystemHealth is used with refreshTrigger prop that does not exist in SystemHealthProps.
   - Fix: Remove `refreshTrigger` from <SystemHealth ... /> or add optional prop in SystemHealthProps and pass-through unused. Prefer removal if not needed; LiveStatus already tracks lastUpdated.

2) Format: 1 file failing
   - Run: npm run format:check to see which file
   - If Prettier complains, run npm run format to fix.

Validation
- npx tsc -p tsconfig.production.json --noEmit
- npm run format:check
- npx eslint components/ai/console/LiveStatus --max-warnings=0

Deliverables
- Commit labeled: chore(cleanup): fix LiveStatus type error and formatting

Prompt for Claude Code
```
You are assigned Phase 00 – Quick Wins.
1) Open logs/pre-commit-*/type-check.md and confirm the TS2322 in LiveStatus.
2) Edit components/ai/console/LiveStatus/LiveStatus.tsx to remove the `refreshTrigger` prop from the <SystemHealth ... /> usage (or extend the prop type if explicitly needed). Prefer removal.
3) Run `npm run format:check`; if it fails, run `npm run format`.
4) Validate with `npx tsc -p tsconfig.production.json --noEmit` and lint LiveStatus.
5) Produce a short note of what changed.
```
