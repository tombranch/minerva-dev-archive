# Jest to Vitest Migration Checklist
*Complete migration guide for removing Jest ecosystem*

**Priority**: Critical  
**Estimated Time**: 4-6 hours  
**Affected Files**: 87+ files  
**Risk Level**: Medium (thorough testing required)

## 🎯 Migration Overview

### Current Problem
- Jest and Vitest coexisting causing TypeScript conflicts
- Type definition clashes between jest-axe and vitest-axe  
- Configuration pointing to wrong paths
- Mixed import statements across test files

### Target State
- Complete Jest ecosystem removal
- All tests running on Vitest
- Clean TypeScript compilation
- Consistent import statements

## 📋 Pre-Migration Checklist

### Before Starting
- [ ] Create feature branch: `git checkout -b jest-to-vitest-migration`
- [ ] Backup current state: `git commit -am "Backup before Jest migration"`
- [ ] Run current tests: `npm test` (document current state)
- [ ] Run validation: `npm run validate:quick` (document current failures)

### Environment Verification
- [ ] Node.js version: `node --version` (ensure >= 18.17.0)
- [ ] NPM version: `npm --version` (ensure >= 9.0.0)
- [ ] Current package count: `npm ls | wc -l`
- [ ] Disk space: Ensure sufficient space for dependency changes

## 🔧 Step 1: Package Dependency Updates

### Remove Jest Dependencies
```bash
npm uninstall @testing-library/jest-dom
npm uninstall @types/jest  
npm uninstall @types/jest-axe
npm uninstall jest
npm uninstall jest-axe
npm uninstall jest-environment-jsdom
npm uninstall ts-jest
```

**Verification Commands:**
```bash
# Verify Jest packages removed
npm ls jest 2>/dev/null && echo "❌ Jest still present" || echo "✅ Jest removed"
npm ls @types/jest 2>/dev/null && echo "❌ Jest types still present" || echo "✅ Jest types removed"
npm ls jest-axe 2>/dev/null && echo "❌ Jest-axe still present" || echo "✅ Jest-axe removed"
```

### Add Vitest Replacements
```bash
npm install -D vitest-axe
```

**Verification:**
```bash
npm ls vitest-axe && echo "✅ vitest-axe installed" || echo "❌ vitest-axe missing"
```

**Checklist:**
- [ ] All Jest packages removed
- [ ] vitest-axe installed
- [ ] package.json updated
- [ ] package-lock.json regenerated

## 🔧 Step 2: Configuration File Updates

### Update vitest.config.ts
```typescript
// Current (incorrect):
setupFiles: ['./test/setup.ts'],

// Fixed:
setupFiles: ['./tests/setup.ts'],
```

**File Location**: `vitest.config.ts`
**Change**: Line ~7, setupFiles path

**Verification:**
```bash
grep -n "setupFiles" vitest.config.ts
# Should show: setupFiles: ['./tests/setup.ts']
```

### Update tsconfig.json
```json
// Remove from "types" array:
"@testing-library/jest-dom",
"jest-axe",

// Keep in "types" array:
"vitest/globals",
// Add if not present:
"vitest-axe"
```

**File Location**: `tsconfig.json`
**Lines**: ~18 in types array

**Verification:**
```bash
grep -A5 -B5 '"types"' tsconfig.json
# Should not contain jest-related types
```

### Update tests/tsconfig.json
```json
// Update "types" array:
"types": ["vitest/globals", "vitest-axe"],
```

**File Location**: `tests/tsconfig.json`
**Line**: ~18

**Checklist:**
- [ ] vitest.config.ts path fixed
- [ ] tsconfig.json types updated
- [ ] tests/tsconfig.json types updated
- [ ] No Jest references in configuration

## 🔧 Step 3: Test Setup File Updates

### Update test/setup.ts
```typescript
// Remove:
import '@testing-library/jest-dom';

// Add Vitest setup (content may vary based on needs)
import { expect } from 'vitest'
```

**File Location**: `test/setup.ts`

### Update tests/setup.ts  
```typescript
// Remove:
import '@testing-library/jest-dom';

// Replace with Vitest-appropriate setup
import { expect } from 'vitest'
```

**File Location**: `tests/setup.ts`

### Update test/accessibility-utils.ts
```typescript
// Remove:
import '@testing-library/jest-dom';
import { axe, toHaveNoViolations } from 'jest-axe';

// Replace with:
import { axe, toHaveNoViolations } from 'vitest-axe';
```

**File Location**: `test/accessibility-utils.ts`
**Lines**: Multiple import statements

**Checklist:**
- [ ] test/setup.ts updated
- [ ] tests/setup.ts updated  
- [ ] test/accessibility-utils.ts updated
- [ ] No jest-dom imports remaining

## 🔧 Step 4: Type Definition Updates

### Replace types/jest.d.ts
```typescript
// Remove entire file: types/jest.d.ts
// Create: types/vitest.d.ts

// New content:
import type { TestingLibraryMatchers } from '@testing-library/jest-dom/matchers';

declare global {
  namespace Vi {
    interface JestAssertion<T = any>
      extends jest.Matchers<void, T>,
        TestingLibraryMatchers<T, void> {}
  }
}
```

**Actions:**
- [ ] Delete `types/jest.d.ts`
- [ ] Create `types/vitest.d.ts`
- [ ] Update content appropriately

### Update test/vitest.d.ts
```typescript
// Update imports:
import type { TestingLibraryMatchers } from '@testing-library/jest-dom/matchers';

// Update interface:
interface Vi {
  // Updated interface content
}
```

**File Location**: `test/vitest.d.ts`

**Checklist:**
- [ ] types/jest.d.ts removed
- [ ] types/vitest.d.ts created
- [ ] test/vitest.d.ts updated
- [ ] TypeScript compilation succeeds

## 🔧 Step 5: Test File Updates (87+ files)

### Accessibility Test Files (26 files)
**Pattern**: `tests/accessibility/*.test.tsx`

**Required Changes:**
```typescript
// Remove:
import '@testing-library/jest-dom';
import { axe, toHaveNoViolations } from 'jest-axe';

// Replace with:
import { axe, toHaveNoViolations } from 'vitest-axe';
```

**Files to Update:**
- `tests/accessibility/accessibility-framework.ts`
- `tests/accessibility/accessibility-test-utils.ts`
- `tests/accessibility/ai-management-accessibility.test.tsx`
- `tests/accessibility/bulk-operations-accessibility.test.tsx`
- `tests/accessibility/search-accessibility.test.tsx`
- Plus 21 more accessibility test files

### Component Test Files (40+ files)
**Pattern**: `tests/components/**/*.test.tsx`

**Required Changes:**
```typescript
// Remove:
import { axe, toHaveNoViolations } from 'jest-axe';

// Replace with:
import { axe, toHaveNoViolations } from 'vitest-axe';

// Update mock syntax:
// jest.fn() → vi.fn()
// jest.mock() → vi.mock()
// jest.clearAllMocks() → vi.clearAllMocks()
```

**Major Files:**
- `tests/components/admin/*.test.tsx` (8 files)
- `tests/components/ai/*.test.tsx` (6 files)  
- `tests/components/organization/*.test.tsx` (7 files)
- `tests/components/platform/*.test.tsx` (9 files)
- `tests/components/ui/*.test.tsx` (5 files)

### Documentation Files
**Files containing Jest references:**
- `docs/` directory (multiple files)
- `dev/` directory (planning documents)
- Update references from Jest to Vitest

### Script Files
**Files to Update:**
- `scripts/maintenance/validate-all.js` (remove Jest fallback)
- `scripts/test/verify-test-config.js` (update dependency check)

**Batch Update Commands:**
```bash
# Find all test files with jest-axe imports
find tests/ -name "*.ts" -o -name "*.tsx" | xargs grep -l "jest-axe"

# Find all files with jest-dom imports  
find . -name "*.ts" -o -name "*.tsx" | xargs grep -l "@testing-library/jest-dom"

# Find all files with jest.fn() calls
find tests/ -name "*.ts" -o -name "*.tsx" | xargs grep -l "jest\.fn()"
```

**Manual Review Required:**
- Each test file needs individual attention
- Mock implementations may need updates
- Test syntax differences between Jest and Vitest

**Checklist:**
- [ ] All accessibility test files updated
- [ ] All component test files updated
- [ ] All documentation updated
- [ ] All script files updated
- [ ] Batch find commands return no results

## 🔧 Step 6: Validation Script Updates

### Update validate-quick.js
**File**: `scripts/maintenance/validate-quick.js`

**Changes:**
```javascript
// Remove Jest fallback in test execution:
// Line ~531: Remove jest.config.js check
} else if (fs.existsSync('jest.config.js')) {
  // Remove this entire block
}
```

### Update validate-all.js  
**File**: `scripts/maintenance/validate-all.js`

**Changes:**
```javascript
// Remove Jest fallback in test execution:
// Similar changes to validate-quick.js
```

### Update verify-test-config.js
**File**: `scripts/test/verify-test-config.js`

**Changes:**
```javascript
// Update dependency check:
// Line ~49: Remove jest check
jest: dependencies['jest'], // Remove this line

// Line ~59: Update coexistence check
if (dependencies['jest'] && dependencies['vitest']) {
  // Remove this check or update appropriately
}
```

**Checklist:**
- [ ] validate-quick.js updated
- [ ] validate-all.js updated
- [ ] verify-test-config.js updated
- [ ] No Jest references in validation scripts

## ✅ Verification & Testing

### Phase 1: Basic Compilation
```bash
# TypeScript compilation
npx tsc --noEmit
# Should complete without errors

# Vitest configuration check
npx vitest --run --reporter=verbose tests/setup.ts
# Should not error on setup
```

### Phase 2: Test Execution
```bash
# Run specific test file
npx vitest tests/components/ui/button.test.tsx

# Run accessibility tests
npm run test:a11y

# Run all tests
npm test
```

### Phase 3: Full Validation
```bash
# Quick validation
npm run validate:quick

# Full validation (if quick passes)
npm run validate:all

# Build verification
npm run build
```

### Phase 4: Verification Commands
```bash
# Verify no Jest packages
npm ls 2>/dev/null | grep -i jest && echo "❌ Jest packages found" || echo "✅ No Jest packages"

# Verify no Jest imports
find . -name "*.ts" -o -name "*.tsx" | xargs grep -l "from 'jest" | head -5

# Verify no jest-axe imports  
find . -name "*.ts" -o -name "*.tsx" | xargs grep -l "jest-axe" | head -5

# Check TypeScript errors
npx tsc --noEmit 2>&1 | grep -c "error" || echo "0 TypeScript errors"
```

**Success Criteria:**
- [ ] Zero TypeScript compilation errors
- [ ] All tests pass with Vitest
- [ ] No Jest packages in node_modules  
- [ ] No Jest imports in codebase
- [ ] `validate:quick` passes
- [ ] Build completes successfully

## 🚨 Troubleshooting Guide

### Common Issues & Solutions

#### Issue: TypeScript errors about jest-axe types
**Symptoms:** `Module '"jest-axe"' has no exported member 'AxeOptions'`
**Solution:** 
1. Verify vitest-axe is installed
2. Update import statements
3. Check tsconfig.json types array

#### Issue: Tests fail with "vi is not defined"
**Symptoms:** `ReferenceError: vi is not defined`
**Solution:**
1. Add `import { vi } from 'vitest'` to test files
2. Update vitest.config.ts with `globals: true`
3. Verify vitest setup in tsconfig

#### Issue: Accessibility tests fail
**Symptoms:** `toHaveNoViolations is not a function`
**Solution:**
1. Verify vitest-axe import: `import { toHaveNoViolations } from 'vitest-axe'`
2. Check test setup file includes vitest-axe configuration
3. Verify vitest-axe package installed correctly

#### Issue: Build fails after migration
**Symptoms:** Next.js build errors
**Solution:**
1. Clear build cache: `rm -rf .next`
2. Reinstall dependencies: `npm ci`
3. Check for remaining Jest references

### Rollback Procedure
If migration fails:
```bash
# Restore packages
git checkout package.json package-lock.json
npm install

# Restore configuration
git checkout vitest.config.ts tsconfig.json

# Restore test files (if needed)
git checkout tests/ test/

# Verify rollback
npm test
npm run validate:quick
```

## 📊 Progress Tracking

### File Update Progress
Track your progress through the major file categories:

**Configuration Files (4 files):**
- [ ] vitest.config.ts
- [ ] tsconfig.json  
- [ ] tests/tsconfig.json
- [ ] package.json

**Setup Files (3 files):**
- [ ] test/setup.ts
- [ ] tests/setup.ts
- [ ] test/accessibility-utils.ts

**Type Files (2 files):**
- [ ] types/jest.d.ts → types/vitest.d.ts
- [ ] test/vitest.d.ts

**Test Files (87+ files):**
- [ ] Accessibility tests (26 files)
- [ ] Component tests (40+ files)
- [ ] Other test files (21+ files)

**Script Files (3 files):**
- [ ] scripts/maintenance/validate-quick.js
- [ ] scripts/maintenance/validate-all.js  
- [ ] scripts/test/verify-test-config.js

### Time Tracking
- **Start Time**: ___________
- **Configuration Complete**: ___________
- **Setup Files Complete**: ___________
- **Test Files Complete**: ___________
- **Validation Passing**: ___________
- **Total Time**: ___________

### Issue Log
Document any issues encountered:

| Issue | File | Solution | Time Lost |
|-------|------|----------|-----------|
|       |      |          |           |
|       |      |          |           |
|       |      |          |           |

## 🎯 Post-Migration Tasks

### Immediate (Same Day)
- [ ] Full test suite passing
- [ ] Documentation updated
- [ ] Team notification sent
- [ ] Migration branch merged

### This Week  
- [ ] Monitor for any missed Jest references
- [ ] Performance comparison (Jest vs Vitest)
- [ ] Developer workflow documentation updated
- [ ] CI/CD pipeline verified

### Future Considerations
- [ ] Evaluate vitest-axe vs alternatives
- [ ] Consider additional Vitest features (workspace, etc.)
- [ ] Performance optimizations
- [ ] Test coverage improvements

---

**Migration Lead**: Development Team  
**Start Date**: _____________  
**Target Completion**: Same day as start  
**Status**: Not Started | In Progress | Complete  
**Success Rate**: ___% files updated successfully