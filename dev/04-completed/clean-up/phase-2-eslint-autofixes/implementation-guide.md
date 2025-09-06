# Phase 2: ESLint Auto-fixes - Implementation Guide

**Objective**: Auto-fix simple ESLint errors that can be resolved automatically  
**Priority**: HIGH - Quick wins to reduce error count  
**Estimated Time**: 1 hour  
**Dependencies**: Phase 1 must be completed (project builds)

## Overview
Phase 2 focuses on automatically fixable ESLint errors like unused imports, unused variables, and formatting issues. This phase will significantly reduce the error count with minimal manual intervention.

## Pre-Phase Checklist
- [ ] Phase 1 completed (TypeScript builds successfully)
- [ ] Current ESLint error count recorded
- [ ] No active development work in progress

## Auto-fixable Error Categories

### Category 1: Unused Imports (~50 errors)
**Pattern**: `'Database' is defined but never used`
```typescript
// Before
import { Database, User } from '@/lib/types';
// Only User is used

// After (auto-fixed)
import { User } from '@/lib/types';
```

### Category 2: Unused Variables (~30 errors) 
**Pattern**: `'errorRate' is assigned a value but never used`
```typescript
// Before
const errorRate = calculateError();
const result = processData();
return result;

// After (needs manual review)
const _errorRate = calculateError(); // or remove if truly unused
const result = processData();
return result;
```

### Category 3: Unused Parameters (~20 errors)
**Pattern**: `'request' is defined but never used`
```typescript
// Before
export async function GET(request: NextRequest) {
  return Response.json({ status: 'ok' });
}

// After (auto-fixed)
export async function GET(_request: NextRequest) {
  return Response.json({ status: 'ok' });
}
```

### Category 4: Formatting Issues (~30 errors)
- Inconsistent spacing
- Missing semicolons
- Quote style inconsistencies
- Indentation problems

## Implementation Steps

### Step 1: Backup Current State
```bash
cd C:\Users\Tom\dev\minerva

# Record current error count
npx eslint . --format stylish 2>&1 | grep -E "✖.*problems" > phase2-baseline.txt

# Create backup branch (optional but recommended)
git add . && git commit -m "Pre-phase2: Before ESLint auto-fixes"
```

### Step 2: Run ESLint Auto-fix
```bash
# Auto-fix what can be automatically resolved
npx eslint . --fix --ext .ts,.tsx,.js,.jsx

# Alternative: Use npm script
npm run lint:fix

# Check what was fixed
git diff --name-only
```

### Step 3: Review Auto-fixes
```bash
# See detailed changes
git diff

# Review files that were modified
git status
```

**Manual Review Required For**:
- Unused variables that might be needed for debugging
- Parameters that might be used in future
- Complex formatting changes

### Step 4: Handle Remaining Manual Issues

#### Unused Variables Strategy
For variables marked as unused but needed:
```typescript
// Option 1: Prefix with underscore
const _errorRate = calculateError();

// Option 2: Use eslint-disable comment
const errorRate = calculateError(); // eslint-disable-line @typescript-eslint/no-unused-vars

// Option 3: Remove if truly unnecessary
// const errorRate = calculateError(); // Delete this line
```

#### Unused Parameters Strategy
```typescript
// Before
export async function GET(request: NextRequest, context: any) {
  return Response.json({ status: 'ok' });
}

// After - prefix unused params
export async function GET(_request: NextRequest, _context: any) {
  return Response.json({ status: 'ok' });
}
```

### Step 5: Format All Files
```bash
# Ensure consistent formatting
npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,md}"

# Alternative: Use npm script
npm run format
```

### Step 6: Validate Results
```bash
# Check new error count
npx eslint . --format stylish 2>&1 | grep -E "✖.*problems"

# Compare to baseline
echo "Baseline errors: $(cat phase2-baseline.txt)"
echo "Current errors: $(npx eslint . --format stylish 2>&1 | grep -E "✖.*problems")"
```

## Expected Results

### Before Phase 2
```
✖ 700+ problems (700+ errors, 1 warnings)
```

### After Phase 2
```
✖ 500-550 problems (500-550 errors, 0 warnings)
```

**Reduction**: ~150-200 errors automatically fixed

## Common Auto-fixes Applied

### Import Cleanup
```typescript
// Before
import { 
  Database, 
  User, 
  Project, 
  Photo, 
  Tag 
} from '@/lib/types';
import { createClient } from '@supabase/supabase-js';

// Only User and createClient used

// After
import { User } from '@/lib/types';
import { createClient } from '@supabase/supabase-js';
```

### Parameter Prefixing
```typescript
// Before - Multiple unused parameter errors
export async function POST(request: NextRequest, context: any) {
export async function PUT(request: NextRequest, params: any) {
export async function DELETE(request: NextRequest, context: any) {

// After - Auto-prefixed
export async function POST(_request: NextRequest, _context: any) {
export async function PUT(_request: NextRequest, _params: any) {
export async function DELETE(_request: NextRequest, _context: any) {
```

### Formatting Standardization
```typescript
// Before - Inconsistent formatting
const result={data:response,status:'ok'}
const user     =    await getUser()

// After - Consistent formatting
const result = { data: response, status: 'ok' };
const user = await getUser();
```

## Manual Review Checklist

After auto-fixes, review these files for correctness:

### High-Priority Review
- [ ] API route handlers (ensure parameters aren't needed)
- [ ] Error handling functions (verify error variables can be removed)
- [ ] Database query functions (check if unused variables are debugging helpers)
- [ ] Test files (ensure test setup variables aren't removed incorrectly)

### Verification Commands
```bash
# Check that auto-fixes didn't break functionality
npm run build

# Verify tests still run (may have test failures, but should compile)
npx tsc --noEmit tests/**/*.ts __tests__/**/*.ts

# Check for any new TypeScript errors introduced
npx tsc --noEmit --skipLibCheck
```

## Troubleshooting

### If Auto-fix Breaks Something
```bash
# Revert specific file
git checkout -- path/to/file.ts

# Revert all changes if needed
git reset --hard HEAD

# Then re-run with more targeted fixes
npx eslint path/to/specific/file.ts --fix
```

### If Prettier Conflicts with ESLint
```bash
# Run in sequence
npx eslint . --fix
npx prettier --write "**/*.{ts,tsx}"
npx eslint . --fix
```

## Files Most Likely to Change

### Expected High-Impact Files
1. **API Routes**: `/app/api/**/*.ts`
   - Many unused request parameters
   - Unused import statements

2. **Service Functions**: `/lib/services/**/*.ts`
   - Unused utility imports
   - Debugging variables

3. **Test Files**: `/__tests__/**/*.ts`, `/tests/**/*.ts`
   - Unused mock imports
   - Test setup variables

4. **Component Files**: `/components/**/*.tsx`
   - Generally cleaner, fewer changes expected

## Success Criteria

### Must Achieve
- [ ] Error count reduced by at least 150 errors
- [ ] No new TypeScript compilation errors
- [ ] Project still builds successfully
- [ ] All auto-fixes reviewed and approved

### Quality Checks
- [ ] Consistent code formatting across project
- [ ] No unused imports remaining
- [ ] Unused variables properly handled (prefixed or removed)
- [ ] No breaking changes to functionality

## Phase 2 Completion Checklist
- [ ] ESLint auto-fix completed
- [ ] Prettier formatting applied
- [ ] Manual review of changes completed
- [ ] Project builds successfully
- [ ] Error count significantly reduced
- [ ] Changes committed to version control

**Phase 2 Complete When**: ESLint error count reduced to ~500-550 errors with no build-breaking issues

## Prepare for Phase 3
Phase 2 completion should leave primarily:
- `@typescript-eslint/no-explicit-any` errors (~450-500 remaining)
- Complex unused variable cases requiring manual review
- Ready for systematic `any` type elimination