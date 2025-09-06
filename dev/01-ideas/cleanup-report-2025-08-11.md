# Minerva Codebase Cleanup Report (2025-08-11)

## Summary
This report captures the current state of code quality issues, what we’ve fixed so far, and a concrete plan to finish the cleanup and prevent regressions. You confirmed commits can go straight to main (non-production) and asked for hooks best practices—this plan reflects that.

## Key Findings
- Lint and TypeScript issues clustered in a few areas:
  - React hooks: missing/excess deps for `useEffect`/`useCallback`; functions defined in body but not stabilized.
  - Unused imports/variables: especially icon imports in console/analytics components and some UI primitives.
  - Type looseness: frequent `any` casts and ad-hoc JSON access patterns (e.g., `as any`), particularly in debug pages and analytics/testing pages.
  - Minor JSX text escapes: unescaped quotes/apostrophes flagged by `react/no-unescaped-entities`.
  - Formatting drift: Prettier differences in a handful of files.
- Query typing: React Query usages sometimes mismatch the fetcher generics, returning `unknown` or `any` shape and forcing downstream casts.
- Occasional leftover legacy/commented blocks embedded in components causing parser/type-check noise when edited.

## Fixes Implemented So Far (selected)
- Replaced many `any` casts with `unknown` or `Record<string, unknown>`; removed several unused imports and variables across debug screens.
- Escaped JSX quotes in affected pages.
- Refactored several hook usages to best practices:
  - Wrapped async loader functions in `useCallback` and referenced them in `useEffect` dep arrays.
  - Converted some onClick handlers to `() => void fn()` to avoid implicit promise handling warnings.
- Tightened React Query generics in AI Management Testing page to align fetcher and consumer types.
- Fixed parse errors caused by partially edited legacy blocks.

## Remaining Work to Go Green (Phase 1)
1) Hooks best practices (project-wide)
   - Pattern: define async loader with `useCallback`; `useEffect(() => { void load(); }, [load])`.
   - Where needed, pass stable state/props into callbacks via deps; avoid including stable identifiers (like `organizationId`) if guaranteed static for component’s lifecycle; otherwise include them.
   - For complex deps, prefer extracting sub-hooks.

2) Unused imports/vars cleanup
   - Remove or underscore-prefix; prefer removal when the symbol truly isn’t used.
   - Icons and UI components are the most common offenders in console/* modules.

3) Type tightening
   - Replace `any` with:
     - concrete domain types where known,
     - `unknown` plus safe narrowing where not,
     - `Record<string, unknown>` for loose config blobs.
   - Normalize React Query: `useQuery<ApiResponse<T>>` and fetchers returning `ApiResponse<T>`.

4) Formatting
   - Prettier `--write` repo-wide until checks pass.

## Prevention (Phase 2 and beyond)
- Typed API helper
  - Add `fetchJson<T>(url, init?): Promise<ApiResponse<T>>` that validates `response.ok` and parses JSON.
  - Centralize error handling and uniform ApiResponse.

- React Query wrapper
  - `useApiQuery<T>({ key, url, ...opts })` that calls `fetchJson<T>`; standardizes typing and error states.

- ESLint & tooling
  - Keep `@typescript-eslint/no-explicit-any` (encourages better narrowing).
  - Consider `eslint-plugin-unused-imports` to auto-remove unused imports in `lint-staged`.
  - Maintain `react-hooks/exhaustive-deps`; standardize callback pattern above.
  - Optionally add `eslint-plugin-simple-import-sort` for consistency.

- Editor/CI hygiene
  - VSCode: enable Format on Save and ESLint code actions on save.
  - Keep pre-commit running Prettier, ESLint, and `tsc`.
  - Add CI job that mirrors pre-commit checks for PRs.

- Dead code checks (optional but recommended)
  - Run `knip` or `ts-prune` periodically to discover unused exports/modules.

- Documentation & codebase patterns
  - Add short “Frontend Patterns” doc with: hook usage recipe, query conventions, API helper usage, icon import patterns (import only used icons).
  - Encourage domain model types and DTOs for API responses.

## Concrete Implementation Plan
- Phase 1 (Get Green) — target: today
  1) Finish hook refactors in analytics/configuration/console modules (useCallback + effect deps).
  2) Remove remaining unused imports/vars flagged by ESLint (focus on icons/UI components).
  3) Replace lingering `any` with `unknown` or domain types; normalize React Query generics.
  4) Run `npm run format` and `npm run pre-commit` iteratively until clean.

- Phase 2 (Small Structural Wins) — target: next
  1) Introduce `fetchJson<T>()` and `useApiQuery<T>()` helpers.
  2) Update 2–3 representative pages to the new pattern; verify reduced boilerplate and better types.

- Phase 3 (Sustainability)
  1) Add `eslint-plugin-unused-imports` to `lint-staged` (optional), or keep manual fixes.
  2) Add “Frontend Patterns” doc under `dev/` and link in README.
  3) Consider `knip` in CI weekly/adhoc.

## Hook Best-Practices Cheat Sheet
- Define loaders: `const load = useCallback(async () => { ... }, [deps])`.
- Side effects that call loaders: `useEffect(() => { void load(); }, [load])`.
- Event handlers: `const onClick = useCallback(() => { void doAsync(); }, [doAsync])`.
- Avoid `any`; prefer domain types or `unknown` with narrowers.
- Keep dependency arrays accurate; prefer stable memoized values.

## Status
- Several critical issues already addressed; a few modules still need the hook refactor and unused import cleanup.
- After Phase 1 is complete and checks pass, we’ll commit to main per your instruction and proceed with Phase 2.

## Notes
- This report will be updated if you want a living doc. Otherwise, I’ll create a short “Frontend Patterns” doc after Phase 2.

