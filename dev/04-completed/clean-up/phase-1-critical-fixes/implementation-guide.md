# Phase 1: Critical TypeScript Fixes - Implementation Guide

**Objective**: Fix build-breaking TypeScript errors to ensure the project compiles  
**Priority**: CRITICAL - Must complete before other phases  
**Estimated Time**: 2-3 hours  

## Overview
Phase 1 focuses on TypeScript compilation errors that prevent the project from building. These are primarily in test files and relate to API signature mismatches, missing exports, and outdated mock configurations.

## Pre-Phase Checklist
- [ ] Hooks are disabled (verified in Phase 0)
- [ ] Baseline TypeScript error count recorded: ~2,500 errors
- [ ] Backup created of current state

## Error Categories to Fix

### Category 1: Test Mock Configuration Errors (~2,000 errors)

#### Issue Pattern
```typescript
// Error: Property 'createServerClient' does not exist
mockSupabase.createServerClient.mockReturnValue(mockClient);

// Fix: Use correct method name
mockSupabase.getServerClient.mockReturnValue(mockClient);
```

#### Common Mock Mismatches
1. **Supabase Client Methods**:
   - `createServerClient` → `getServerClient`
   - `requirePlatformAdmin` → `isPlatformAdmin`

2. **Function Signatures**:
   - Expected 2 arguments, got 1
   - Expected 1 argument, got 0 or 3

#### Implementation Steps
1. **Identify affected test files**:
   ```bash
   cd C:\Users\Tom\dev\minerva
   npx tsc --noEmit --skipLibCheck 2>&1 | grep "createServerClient\|requirePlatformAdmin\|Expected.*arguments" > phase1-mock-errors.txt
   ```

2. **Fix Supabase mock methods**:
   - Search: `createServerClient`
   - Replace: `getServerClient`
   - Search: `requirePlatformAdmin`  
   - Replace: `isPlatformAdmin`

3. **Fix function signature mismatches**:
   - Review each "Expected X arguments, got Y" error
   - Update test calls to match current API signatures
   - Check actual function definitions for correct parameters

### Category 2: Missing Exports/Imports (~300 errors)

#### Issue Pattern
```typescript
// Error: Module has no exported member 'PUT'
import { PUT, DELETE } from '@/app/api/platform/ai-management/prompts/route';

// Fix: Check what's actually exported
import { GET, POST } from '@/app/api/platform/ai-management/prompts/route';
```

#### Implementation Steps
1. **Identify missing exports**:
   ```bash
   npx tsc --noEmit --skipLibCheck 2>&1 | grep "has no exported member" > phase1-export-errors.txt
   ```

2. **For each missing export**:
   - Open the target file
   - Check what functions are actually exported
   - Update import statements to match
   - If function should exist, implement it

3. **Common patterns to fix**:
   - API routes missing HTTP method exports
   - Utility functions not exported
   - Type definitions not exported

### Category 3: Generic Type Constraints (~200 errors)

#### Issue Pattern
```typescript
// Error: Type 'T' does not satisfy constraint 'string | number | symbol'
function createFactory<T>(data: T): Record<T, any> { }

// Fix: Add proper constraint
function createFactory<T extends string | number | symbol>(data: T): Record<T, any> { }
```

#### Implementation Steps
1. **Find constraint violations**:
   ```bash
   npx tsc --noEmit --skipLibCheck 2>&1 | grep "does not satisfy the constraint" > phase1-constraint-errors.txt
   ```

2. **Fix each constraint**:
   - Add proper extends clause to generic parameters
   - Use keyof operator where appropriate
   - Narrow types to satisfy constraints

## Step-by-Step Implementation

### Step 1: Setup Error Tracking
```bash
cd C:\Users\Tom\dev\minerva

# Get baseline error count
npx tsc --noEmit --skipLibCheck 2>&1 | wc -l > phase1-baseline-count.txt

# Create detailed error files
npx tsc --noEmit --skipLibCheck 2>&1 > phase1-all-errors.txt
```

### Step 2: Fix Test Mock Errors (Highest Impact)
```bash
# Find all test files with mock errors
grep -r "createServerClient" __tests__/ tests/ --include="*.ts" --include="*.tsx" -l
grep -r "requirePlatformAdmin" __tests__/ tests/ --include="*.ts" --include="*.tsx" -l
```

**For each file**:
1. Replace `createServerClient` with `getServerClient`
2. Replace `requirePlatformAdmin` with `isPlatformAdmin`
3. Check function signature mismatches and fix parameter counts

### Step 3: Fix Missing Exports
```bash
# Find files with export errors
npx tsc --noEmit --skipLibCheck 2>&1 | grep -o "@/[^']*" | sort | uniq
```

**For each file**:
1. Open the source file
2. Check what's actually exported
3. Update import statements
4. Add missing exports if needed

### Step 4: Fix Generic Constraints
```bash
# Find constraint errors
npx tsc --noEmit --skipLibCheck 2>&1 | grep -B2 -A2 "constraint"
```

**For each constraint error**:
1. Identify the generic parameter
2. Add proper extends clause
3. Test that constraint is satisfied

### Step 5: Validate Progress
```bash
# Check new error count
npx tsc --noEmit --skipLibCheck 2>&1 | wc -l

# Compare to baseline
echo "Baseline: $(cat phase1-baseline-count.txt) errors"
echo "Current:  $(npx tsc --noEmit --skipLibCheck 2>&1 | wc -l) errors"
```

**Target**: Reduce from ~2,500 to ~500 errors (build succeeds)

## Common Fixes Reference

### Mock Method Replacements
```typescript
// Before
mockSupabase.createServerClient.mockReturnValue(mockClient);
mockPlatformAuth.requirePlatformAdmin.mockResolvedValue(mockUser);

// After  
mockSupabase.getServerClient.mockReturnValue(mockClient);
mockPlatformAuth.isPlatformAdmin.mockResolvedValue(true);
```

### Function Signature Fixes
```typescript
// Before - Expected 2 arguments, got 1
await POST(request);

// After - Add missing context parameter
await POST(request, { params: {} });
```

### Export Additions
```typescript
// Add missing exports to API routes
export async function PUT(request: NextRequest) { }
export async function DELETE(request: NextRequest) { }
```

### Generic Constraints
```typescript
// Before
function factory<T>(key: T): Record<T, any> { }

// After
function factory<T extends string | number | symbol>(key: T): Record<T, any> { }
```

## Validation Criteria

### Success Metrics
- [ ] TypeScript compilation succeeds (no build-breaking errors)
- [ ] Error count reduced by at least 80% (from ~2,500 to <500)
- [ ] All test files can be imported without errors
- [ ] Core API routes compile successfully

### Verification Commands
```bash
# Must succeed without errors
npx tsc --noEmit --skipLibCheck

# Build should work
npm run build

# Tests should be importable (may still fail execution)
npx tsc --noEmit tests/**/*.ts __tests__/**/*.ts
```

## Common Pitfalls

### 1. Function Signature Research
- Don't guess parameter counts
- Check actual function definitions
- Look at other similar test patterns

### 2. Export Verification  
- Don't assume what should be exported
- Check the actual file contents
- Consider if missing exports need implementation

### 3. Mock Configuration
- Update mocks to match current API
- Check if mock interfaces need updates
- Verify mock return types match expectations

## Next Phase Preparation
After Phase 1 completion:
- [ ] Project builds successfully
- [ ] Core TypeScript errors resolved
- [ ] Ready for ESLint auto-fixes in Phase 2
- [ ] Progress tracked and documented

**Phase 1 Complete When**: `npx tsc --noEmit --skipLibCheck` runs without build-breaking errors