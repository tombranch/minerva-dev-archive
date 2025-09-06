# Assignments and Concurrency Plan

Run phases with concurrent Claude Code instances as follows:

Phase 00 – Quick Wins (Serial)
- Owner: Instance A

Phase 01 – Unused & Entities (Parallel)
- Instance B: components/ai/console/**
- Instance C: components/ai/features/**
- Instance D: components/ai/monitoring/**
- Instance E: components/ai/experiments/**
- Instance F: components/search/**
- Instance G: components/platform/**
- Instance H: components/ui/**

Phase 02 – Hooks deps (Parallel)
- Reuse the same directory ownership as Phase 01, in the same instances.

Phase 03 – UI any + a11y (Parallel)
- Reuse the same directory ownership. Focus only on components/** any and a11y.

Phase 04 – Finalize (Serial)
- Owner: Instance A

General guidance for all instances
- Keep commits scoped per directory and phase for easy reverts/rollbacks.
- Do not modify lib/** any usages unless inside a component; those are warnings and can be addressed later.
- Avoid broad refactors. Use mechanical fixes.
- After each directory is clean for the current phase, note the files changed in a short summary.

