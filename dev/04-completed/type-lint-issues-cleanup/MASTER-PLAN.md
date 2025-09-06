# Master Plan: TypeScript & ESLint Error Resolution

## Executive Summary
**Total Issues**: 1,114 TypeScript errors + ESLint violations  
**Approach**: 5 concurrent phases using specialized agents  
**Estimated Time**: 2-3 hours with parallel execution

## Error Breakdown
- **TS2322** (Type assignment): 416 errors
- **TS2339** (Property missing): 382 errors  
- **TS18046** (Unknown type): 298 errors
- **TS2345** (Argument mismatch): 214 errors
- **ESLint**: `any` types and unused variables

## Phase Overview

| Phase | Focus Area | Files | Errors | Priority |
|-------|------------|-------|--------|----------|
| Phase 1 | API Routes & Services | 17 | ~200 | Critical |
| Phase 2 | Test Files & Mocks | 12 | ~180 | High |
| Phase 3 | Platform/Debug Pages | 9 | ~120 | Medium |
| Phase 4 | Components | 8 | ~110 | Medium |
| Phase 5 | ESLint & Cleanup | All | ~504 | Final |

## Agent Launch Instructions

### Concurrent Execution Strategy
Launch 4 agents simultaneously for Phases 1-4, then Phase 5 after completion.

### Agent 1: API Routes & Core Services
```bash
# Launch with typescript-safety-validator agent
# Focus: app/api/ and lib/services/
# Documentation: phase-1-api-routes.md
```
**Key Tasks**:
- Fix undefined variable references (`request` → `_request`)
- Remove all `any` types in API routes
- Add missing function definitions
- Fix provider type literals

### Agent 2: Test Files & Mocking
```bash
# Launch with type-safety-enforcer agent
# Focus: __tests__/, tests/, test/
# Documentation: phase-2-test-files.md
```
**Key Tasks**:
- Fix MockQueryBuilder types
- Add missing mock properties
- Fix generic type arguments
- Create reusable mock utilities

### Agent 3: Platform/Debug Pages
```bash
# Launch with typescript-safety-validator agent  
# Focus: app/platform/
# Documentation: phase-3-platform-pages.md
```
**Key Tasks**:
- Fix unknown type property access
- Fix ReactNode assignments
- Add environment data types
- Fix null vs undefined issues

### Agent 4: Component Type Safety
```bash
# Launch with type-safety-enforcer agent
# Focus: components/
# Documentation: phase-4-components.md
```
**Key Tasks**:
- Add component prop interfaces
- Fix event handler types
- Fix state and ref types
- Create shared prop types

### Agent 5: Final Cleanup (After 1-4 Complete)
```bash
# Launch with quality-assurance-specialist agent
# Focus: Entire codebase
# Documentation: phase-5-eslint-cleanup.md
```
**Key Tasks**:
- Remove ALL `any` types
- Fix unused variables
- Final TypeScript validation
- Run full test suite

## Validation Checkpoints

### After Each Phase
```bash
npm run lint -- <phase-directory>
npx tsc --noEmit --skipLibCheck
```

### Final Validation
```bash
npm run lint
npm run format
npm run build
npm test
```

## Common Patterns to Fix

### 1. Undefined Variables
```typescript
// Search for: request, user, data
// Replace with: _request, _user, _data
```

### 2. Any Types
```typescript
// Search for: : any
// Replace with: specific types or unknown with guards
```

### 3. Missing Properties
```typescript
// Add to interfaces or use Partial<T>
```

### 4. Type Assertions
```typescript
// Replace: as any
// With: as unknown as SpecificType
```

## Success Metrics
- [ ] 0 TypeScript errors
- [ ] 0 ESLint errors
- [ ] No `any` types
- [ ] Build passes
- [ ] Tests pass
- [ ] Pre-commit hooks pass

## Risk Mitigation
1. **Create backup branch** before starting
2. **Test incrementally** after each phase
3. **Preserve functionality** - don't change logic
4. **Document breaking changes** if any
5. **Run tests frequently** to catch regressions

## Monitoring Progress
Track in Task Manager:
- Node.js processes should stay under 5
- Memory usage should be stable
- Use `npm run cleanup` if needed

## Rollback Plan
If issues arise:
```bash
git stash
git checkout main
git pull origin main
```

## Communication
- Each agent should report completion status
- Flag any blockers immediately
- Document any decisions made
- Create PR after all phases complete

## Final Deliverables
1. Clean codebase with 0 type errors
2. Passing test suite
3. Successful build
4. Documentation of changes made
5. Pull request ready for review

---
**Start Time**: ___________  
**Target Completion**: ___________  
**Actual Completion**: ___________  
**Total Errors Fixed**: ___________