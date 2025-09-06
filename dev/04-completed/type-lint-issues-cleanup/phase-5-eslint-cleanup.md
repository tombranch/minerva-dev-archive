# Phase 5: ESLint & Final Cleanup

## Objective
Remove all remaining `any` types, unused variables, and perform final validation to ensure zero errors.

## ESLint Issues to Fix

### Files with `any` Types
1. **app/api/photos/bulk-generate-descriptions/route.ts**
   - Lines 118, 119, 178: Replace `any` with specific types

2. **app/api/photos/[id]/chat/route.ts**
   - Lines 76-83, 239-246: Replace 12 `any` occurrences

### Files with Unused Variables
1. **app/api/photos/[id]/ai-results/route.ts**
   - Line 5: Remove unused `Database` import

2. **app/api/photos/[id]/generate-description/route.ts**
   - Line 6: Remove unused `PhotoWithProject` import

3. **app/api/platform/ai-management/experiments/route.ts**
   - Line 4: Remove unused `logPlatformAdminAction`
   - Line 7: Remove unused `getOrganizationId`

4. **app/api/platform/ai-management/experiments/[id]/results/route.ts**
   - Line 285: Remove unused `variant` variable
   - Line 341: Remove unused `calculateDailyBreakdown` function

5. **app/api/platform/ai-management/export/** (multiple files)
   - Remove unused `organizationId` parameters

6. **app/api/platform/ai-management/features/route.ts**
   - Lines 14, 20, 25: Remove unused destructured variables

7. **app/api/platform/organizations/[id]/** (multiple files)
   - Remove unused `cookies` and `Database` imports

## Remaining TypeScript Errors by Category

### TS2322 - Type Assignment (416 occurrences)
Focus on:
- ReactNode assignments
- Prop type mismatches
- State type assignments

### TS2339 - Property Doesn't Exist (382 occurrences)
Focus on:
- Add missing properties to interfaces
- Fix typos in property names
- Add proper type assertions

### TS18046 - Type Unknown (298 occurrences)
Focus on:
- Add type guards
- Use proper type assertions
- Define response types

### TS2345 - Argument Type Mismatch (214 occurrences)
Focus on:
- Fix function parameter types
- Correct method call arguments
- Update generic constraints

## Final Cleanup Tasks

### 1. Create Type Guard Utilities
```typescript
// lib/utils/type-guards.ts
export function isString(value: unknown): value is string {
  return typeof value === 'string'
}

export function isNumber(value: unknown): value is number {
  return typeof value === 'number' && !isNaN(value)
}

export function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

export function hasProperty<T extends object, K extends PropertyKey>(
  obj: T,
  key: K
): obj is T & Record<K, unknown> {
  return key in obj
}
```

### 2. Replace All `any` Types
```typescript
// Strategy for replacing any
// 1. Try to use specific type
type SpecificType = {
  id: string
  data: DataStructure
}

// 2. Use unknown with type guard
function processData(data: unknown) {
  if (isValidData(data)) {
    // data is now typed
  }
}

// 3. Use generic constraints
function processItem<T extends BaseType>(item: T) {
  // item has at least BaseType properties
}

// 4. For truly dynamic objects
type DynamicObject = Record<string, unknown>
```

### 3. Fix Unused Variables
```typescript
// Before
import { Database } from '@/lib/database.types' // unused

// After - remove if truly unused
// Or prefix with underscore if intentionally unused
import { Database as _Database } from '@/lib/database.types'

// For function parameters
function handler(_req: Request, { params }: { params: Params }) {
  // _req is intentionally unused
}
```

### 4. Add Missing Type Exports
```typescript
// lib/types/index.ts
export * from './auth'
export * from './database'
export * from './api'
export * from './components'
export * from './platform'
```

## Validation Script
Create a validation script to check all issues:
```bash
#!/bin/bash
# scripts/validate-types.sh

echo "Running type validation..."

# Check for any types
echo "Checking for 'any' types..."
npm run lint 2>&1 | grep "no-explicit-any" | wc -l

# Run TypeScript check
echo "Running TypeScript compiler..."
npx tsc --noEmit

# Run ESLint
echo "Running ESLint..."
npm run lint

# Run build
echo "Running build..."
npm run build

echo "Validation complete!"
```

## Final Validation Commands
```bash
# Run all checks
npm run lint:fix
npm run format
npx tsc --noEmit
npm run build
npm test

# Check for any remaining issues
grep -r "any" --include="*.ts" --include="*.tsx" app/ components/ lib/
```

## Success Criteria
- Zero TypeScript errors (`npx tsc --noEmit` passes)
- Zero ESLint errors (`npm run lint` passes)
- No `any` types in codebase
- No unused variables (or properly prefixed with `_`)
- Build completes successfully
- All tests pass

## Priority Order for Cleanup
1. Fix all `any` types (critical for type safety)
2. Remove unused variables (clean code)
3. Fix remaining TS2552 (undefined variables)
4. Fix remaining TS2304 (cannot find name)
5. Fix remaining type assignments
6. Final validation and testing

## Notes for Agent
- Start with automated fixes (`npm run lint:fix`)
- Use search/replace for common patterns
- Create shared type definitions to avoid duplication
- Ensure no functionality is broken
- Run tests after each major change
- Document any breaking changes