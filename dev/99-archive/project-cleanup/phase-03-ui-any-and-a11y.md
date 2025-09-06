# Phase 03 – UI any removals and a11y fixes (Parallel per directory)

Objective
- Remove explicit any in components/** (rule is error) and fix basic accessibility warnings.

Guidelines
- Replace any with precise types where known from context or imported types.
- If complex, use unknown and narrow via typeof/Array.isArray/in operator checks.
- For handlers, use specific event types: React.MouseEvent<HTMLButtonElement>, etc.
- a11y: Add alt="" or meaningful alt to <Image> or migrate <img> to next/image where reasonable. If migration is out of scope, add alt to satisfy rule.

Steps per directory
1) Run `npx eslint <DIR> --max-warnings=0`.
2) For each no-explicit-any error in components/**:
   - Replace any with unknown or specific type.
   - Add necessary type guards.
3) For @next/next/no-img-element or jsx-a11y/alt-text warnings:
   - Prefer next/image with alt, width, height where simple.
   - Otherwise add alt="" for decorative images.

Validation
- npx eslint <DIR> --max-warnings=0

Deliverables
- Commit per directory: chore(cleanup): remove any and fix a11y in <dir>

Prompt for Claude Code
```
You are assigned Phase 03 – UI any + a11y for <DIR>.
1) Run `npx eslint <DIR> --max-warnings=0`.
2) Replace explicit any in components/** with unknown or specific types and add guards.
3) Fix alt text and next/image warnings minimally.
4) Re-run ESLint until clean.
5) Provide before/after type signatures for the most notable changes.
```
