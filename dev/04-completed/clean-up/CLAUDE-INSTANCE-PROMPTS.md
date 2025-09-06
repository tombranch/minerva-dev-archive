# Claude Instance Prompts for Minerva Cleanup Phases

## Overview
Each phase should be handled by a separate Claude Code instance with focused instructions. Copy the relevant prompt below and provide it to each instance along with the specified files to read.

---

## Phase 1: Critical TypeScript Fixes

### Prompt for Phase 1 Instance
```
I need to fix critical build-breaking TypeScript errors in the Minerva project. This is Phase 1 of a 5-phase cleanup plan.

**Objective**: Fix TypeScript compilation errors so the project builds successfully
**Target**: Reduce ~2,500 errors to <500 (focus on build-breaking issues)
**Time Estimate**: 2-3 hours

**Key Focus Areas**:
1. Test mock configuration errors (createServerClient → getServerClient)
2. Function signature mismatches (Expected 2 arguments, got 1)
3. Missing exports/imports in API routes
4. Generic type constraint violations

**Files to Read First**:
- `dev/00-in-progress/clean-up/phase-1-critical-fixes/implementation-guide.md`
- `dev/00-in-progress/clean-up/common-patterns.md` (for reference)
- `dev/00-in-progress/clean-up/OVERVIEW.md` (for context)

**Commit Strategy**: Use `git commit --no-verify -m "Phase 1: [description]"` after every file/directory completion

**Success Criteria**: 
- TypeScript compilation succeeds: `npx tsc --noEmit --skipLibCheck`
- Project builds: `npm run build`
- Error count reduced by 80%+

Start by running the baseline error check, then work systematically through test files first (highest impact).
```

### Required Files for Phase 1
- `dev/00-in-progress/clean-up/phase-1-critical-fixes/implementation-guide.md`
- `dev/00-in-progress/clean-up/common-patterns.md`
- `dev/00-in-progress/clean-up/OVERVIEW.md`

---

## Phase 2: ESLint Auto-fixes

### Prompt for Phase 2 Instance
```
I need to auto-fix simple ESLint errors in the Minerva project. This is Phase 2 of cleanup (Phase 1 must be completed first).

**Objective**: Auto-fix unused imports, variables, and formatting issues
**Target**: Reduce ~500-600 errors to ~500-550 (150-200 error reduction)
**Time Estimate**: 1 hour

**Key Actions**:
1. Run `npx eslint . --fix` for auto-fixable issues
2. Handle remaining unused variables manually (prefix with _)
3. Run `npm run format` for consistent formatting
4. Review and commit changes

**Files to Read First**:
- `dev/00-in-progress/clean-up/phase-2-eslint-autofixes/implementation-guide.md`
- `dev/00-in-progress/clean-up/common-patterns.md`

**Prerequisites**: 
- Phase 1 completed (project builds successfully)
- TypeScript compilation works

**Commit Strategy**: Use `git commit --no-verify -m "Phase 2: [description]"` after auto-fixes and manual reviews

**Success Criteria**:
- 150-200 fewer ESLint errors
- No new TypeScript compilation errors
- Project still builds successfully

This is mostly automated fixes with some manual review of unused variables.
```

### Required Files for Phase 2
- `dev/00-in-progress/clean-up/phase-2-eslint-autofixes/implementation-guide.md`
- `dev/00-in-progress/clean-up/common-patterns.md`

---

## Phase 3: Any Type Elimination

### Prompt for Phase 3 Instance
```
I need to eliminate ALL `any` types from the Minerva codebase. This is Phase 3 of cleanup - the most critical phase for type safety.

**Objective**: Replace every `any` type with proper TypeScript interfaces
**Target**: Eliminate ~500 `any` type violations (100% removal)
**Time Estimate**: 8-12 hours

**Strategy**: Work directory by directory in priority order:
1. `app/api/ai/analytics/` (~150 any types) 
2. `app/api/ai/testing/` (~100 any types)
3. `app/api/ai/dashboard/` (~80 any types)
4. `app/api/platform/` (~80 any types)
5. `lib/services/platform/` (~50 any types)

**Files to Read First**:
- `dev/00-in-progress/clean-up/phase-3-any-type-elimination/implementation-guide.md`
- `dev/00-in-progress/clean-up/common-patterns.md` (ESSENTIAL - has 80% of solutions)
- `dev/00-in-progress/clean-up/OVERVIEW.md`

**Prerequisites**: 
- Phases 1 & 2 completed
- ~500 `any` types confirmed with: `npx eslint . | grep -c "any.*Specify"`

**Commit Strategy**: 
- After each file: `git commit --no-verify -m "Phase 3: Fix any types in [filename]"`
- After each directory: `git commit --no-verify -m "Phase 3: COMPLETE - [directory] all any types fixed"`
- Every 2 hours: Progress checkpoint commits

**Success Criteria**:
- Zero any types: `npx eslint . | grep -c "any.*Specify"` returns 0
- Project still builds and tests compile
- Proper type definitions created in `lib/types/`

This is the longest phase - create reusable type definitions as you work.
```

### Required Files for Phase 3
- `dev/00-in-progress/clean-up/phase-3-any-type-elimination/implementation-guide.md`
- `dev/00-in-progress/clean-up/common-patterns.md`
- `dev/00-in-progress/clean-up/OVERVIEW.md`

---

## Phase 4: Test Fixes

### Prompt for Phase 4 Instance
```
I need to fix all broken test files after the type safety improvements. This is Phase 4 of cleanup.

**Objective**: Update test mocks, utilities, and assertions to work with new types
**Target**: Achieve 100% test pass rate
**Time Estimate**: 4-6 hours

**Key Focus Areas**:
1. Update mock factories to match new type signatures
2. Fix Supabase mock configurations
3. Update test assertions to match new data structures
4. Fix component tests with proper prop types

**Files to Read First**:
- `dev/00-in-progress/clean-up/phase-4-test-fixes/implementation-guide.md`
- `dev/00-in-progress/clean-up/common-patterns.md`

**Prerequisites**: 
- Phase 3 completed (zero any types)
- New type definitions exist in `lib/types/`
- Project builds successfully

**Commit Strategy**: 
- After each test suite: `git commit --no-verify -m "Phase 4: Fix [test-suite] tests"`
- After major mock updates: `git commit --no-verify -m "Phase 4: Update [component] mocks"`

**Success Criteria**:
- All tests pass: `npm run test`
- Test files compile: `npx tsc --noEmit tests/**/*.ts`
- No test-related TypeScript errors
- Test coverage maintained

Focus on test factories and mock configurations first - they affect multiple tests.
```

### Required Files for Phase 4
- `dev/00-in-progress/clean-up/phase-4-test-fixes/implementation-guide.md`
- `dev/00-in-progress/clean-up/common-patterns.md`

---

## Phase 5: Final Validation

### Prompt for Phase 5 Instance
```
I need to perform final validation and re-enable quality hooks. This is Phase 5 - the final cleanup phase.

**Objective**: Comprehensive validation and hook restoration
**Target**: <50 total errors, production readiness, hooks re-enabled
**Time Estimate**: 2 hours

**Key Actions**:
1. Comprehensive error count verification
2. Build and test suite validation
3. Type safety confirmation
4. Quality hooks re-enablement
5. Final documentation and metrics

**Files to Read First**:
- `dev/00-in-progress/clean-up/phase-5-final-validation/implementation-guide.md`
- `dev/00-in-progress/clean-up/phase-0-setup/hooks-restore-instructions.md`
- `dev/00-in-progress/clean-up/OVERVIEW.md`

**Prerequisites**: 
- All previous phases completed
- Zero any types confirmed
- All tests passing
- Project builds successfully

**Commit Strategy**: 
- After each validation: `git commit --no-verify -m "Phase 5: [validation-step] completed"`
- Final completion: `git commit --no-verify -m "Phase 5 COMPLETE: All cleanup phases finished"`

**Success Criteria**:
- TypeScript errors: ≤ 5 non-breaking
- ESLint errors: < 50 total
- Any types: 0 remaining
- Tests: ≥ 95% pass rate
- Build: Clean production build
- Hooks: Restored and ready

After completion, restart Claude Code session to activate hooks.
```

### Required Files for Phase 5
- `dev/00-in-progress/clean-up/phase-5-final-validation/implementation-guide.md`
- `dev/00-in-progress/clean-up/phase-0-setup/hooks-restore-instructions.md`
- `dev/00-in-progress/clean-up/OVERVIEW.md`

---

## General Instructions for All Phases

### Before Starting Any Phase
1. **Verify Prerequisites**: Check that previous phases are completed
2. **Read Required Files**: Always read the implementation guide first
3. **Create Baseline**: Run error counts and document starting state
4. **Git Status**: Ensure clean working directory

### During Each Phase
1. **Follow Implementation Guide**: Step-by-step instructions provided
2. **Commit Frequently**: Use `--no-verify` flag as instructed
3. **Validate Progress**: Run verification commands regularly
4. **Document Issues**: Note any unexpected problems

### Communication Between Phases
- Each phase creates progress files and validation results
- Check completion status before starting next phase
- Review previous phase documentation for context

### Emergency Procedures
- If something breaks: `git reset --soft HEAD~1` to undo last commit
- For major issues: Reference `common-patterns.md` for solutions
- If completely stuck: Document issue and current status

## Success Indicators

### Phase Completion Markers
Each phase is complete when:
- All success criteria met
- Validation commands pass
- Changes committed with proper messages
- Ready for next phase

### Overall Project Success
- **Error Reduction**: ~95% reduction from ~700 to <50 errors
- **Type Safety**: 100% (zero any types)
- **Test Health**: All tests passing
- **Production Ready**: Clean builds and deploys
- **Future Protection**: Quality hooks active

---

**Important**: Each Claude instance should focus ONLY on their assigned phase. Don't attempt to fix issues from other phases - just document them for the appropriate phase to handle.