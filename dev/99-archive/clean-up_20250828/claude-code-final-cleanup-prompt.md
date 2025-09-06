# Claude Code - Final Project Cleanup Prompt

## Context
The Minerva Machine Safety Photo Organizer project has undergone major TypeScript cleanup and is now production-ready. However, we want to achieve 100% code quality with zero warnings, zero test failures, and complete TypeScript safety.

## Current State (Post Major Cleanup)
- ✅ Production build succeeds
- ✅ Core functionality working
- ⚠️ 15 failing tests remain
- ⚠️ 40+ ESLint `any` type warnings
- ⚠️ TypeScript errors in test files
- ⚠️ Some skipped test suites

## Your Mission
Please clean up the project to achieve **PERFECT CODE QUALITY**:
1. **Zero TypeScript errors** (including test files)
2. **Zero ESLint warnings** (eliminate all `@typescript-eslint/no-explicit-any`)
3. **Zero failing tests** (fix all 15 remaining failures)
4. **Zero skipped tests** (re-enable and fix performance tests)
5. **Complete type safety** throughout the codebase

## Approach Instructions
1. **Don't ask questions** - proceed systematically through all issues
2. **Use existing patterns** - follow established code conventions in the project
3. **Fix, don't skip** - repair tests rather than disabling them
4. **Maintain functionality** - ensure no regression in features
5. **Document major changes** - note significant architectural decisions

## Priority Order
1. **Fix remaining 15 test failures** (highest impact)
2. **Eliminate all `any` types** (replace with proper types)
3. **Fix TypeScript errors in test files** (improve test reliability)
4. **Re-enable skipped performance tests** and fix them
5. **Address any remaining lint warnings**

## Expected Outcome
- `npm test` - All tests pass ✅
- `npm run lint` - No warnings ✅
- `npx tsc --noEmit` - No errors ✅
- `npm run build` - Clean build with no warnings ✅

## Resources Available
- Comprehensive cleanup report at `dev/03-in-progress/clean-up/typescript-cleanup-comprehensive-report-2025-01-25.md`
- Lastest validate all results `dev\minerva\logs\latest\validate-all\2025-08-25_15-22-58`
- All MCP servers are active (Context7, Serena, Supabase, GitHub, Sentry, etc.)
- Full project documentation in CLAUDE.md

## Technical Context
- **Next.js 15.3.4** with App Router
- **React 19** with TypeScript strict mode
- **Vitest + Playwright** testing
- **Supabase** remote database
- **Tailwind CSS v4** with shadcn/ui

Please begin with a systematic analysis and proceed to achieve 100% code quality. Work through each category of issues methodically until the project has zero warnings, zero errors, and zero test failures.