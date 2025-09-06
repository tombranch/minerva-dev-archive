# Phase 02 – React Hooks dependency corrections (Parallel per directory)

Objective
- Fix react-hooks/exhaustive-deps warnings across components.

Guidelines
- Prefer stable callbacks via useCallback/useMemo over disabling rules.
- For custom hooks returning objects with stable method references, include the hook object itself in deps rather than method references to avoid stale closures.
- If a function is declared inline in a component and used in useEffect/useCallback, wrap it in useCallback and include it as a dep.
- Avoid adding primitive values that are derived in the same scope when they can be included as source variables instead.

Steps per directory
1) Run `npx eslint <DIR> --max-warnings=0`.
2) For each react-hooks/exhaustive-deps warning:
   - Add missing dependencies OR stabilize the function with useCallback/useMemo.
   - Re-run ESLint.
3) If a hook is safe to run only on mount and intentionally ignores deps, add a comment with a short rationale and disable the rule for that line only.

Validation
- npx eslint <DIR> --max-warnings=0

Deliverables
- Commit per directory: chore(cleanup): fix hooks dependency warnings in <dir>

Prompt for Claude Code
```
You are assigned Phase 02 – Hooks deps for <DIR>.
1) Run `npx eslint <DIR> --max-warnings=0`.
2) Address react-hooks/exhaustive-deps warnings by adding deps or stabilizing callbacks with useCallback/useMemo. Prefer real fixes over disables.
3) Re-run ESLint until no hooks warnings remain.
4) Provide a list of changes made (function names or effects updated).
```
