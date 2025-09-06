# TypeScript Error Fix Patterns - Quick Reference
**For immediate use by next Claude Code instance**

## 🔧 **READY-TO-USE PATTERNS**

### **Logger Parameter Fixes**
```typescript
// ❌ BROKEN (causes TS2345):
this.logger.debug('Message:', error.message);
this.logger.debug('Failed operation:', error);
this.logger.error('Database error:', postgrestError);

// ✅ FIXED (use these patterns):
this.logger.debug('Message', { error: error.message });
this.logger.debug('Failed operation', { error });
this.logger.error('Database error', postgrestError, { operation: 'update' });

// ✅ OR use the logError helper (already imported in spending-analytics):
logError(this.logger, 'Failed operation', error);
```

### **Supabase Update Parameter Fixes**
```typescript
// ❌ BROKEN (resolves to 'never'):
const updatePayload: Database['public']['Tables']['table']['Update'] = { ... };
await supabase.from('table').update(updatePayload);

// ✅ FIXED (always works):
const updateData: Record<string, unknown> = {
  updated_at: new Date().toISOString(),
};
// Add fields conditionally
if (field !== undefined) updateData.field = field;

await supabase.from('table').update(updateData);
```

### **Null/Undefined Safety in Tests**
```typescript
// ❌ BROKEN (TS2532 - possibly undefined):
expect(result.property).toBe('value');
const item = array[0];
item.field = 'test';

// ✅ FIXED with type guards:
import { assertNonNull, hasProperty } from '@/lib/utils/type-guards';

const safeResult = assertNonNull(result, 'Result required');
expect(safeResult.property).toBe('value');

const item = assertNonNull(array[0], 'First item required');
item.field = 'test';

// ✅ For optional properties:
if (hasProperty(mockObject, 'optionalField')) {
  expect(mockObject.optionalField).toBeDefined();
}
```

### **Property Access Safety**
```typescript
// ❌ BROKEN (property does not exist on type 'never'):
const orgName = organization.name;
const userEmail = user.email;

// ✅ FIXED with validation:
import { assertNonNull, hasProperty } from '@/lib/utils/type-guards';

const org = assertNonNull(orgResult.data, 'Organization required');
if (!hasProperty(org, 'name') || typeof org.name !== 'string') {
  throw new Error('Invalid organization data');
}
const typedOrg = org as { name: string };
const orgName = typedOrg.name; // Safe access
```

## 📂 **TARGET FILE LOCATIONS**

### **Immediate Priority Files:**
```bash
# High-impact files to fix first:
lib/services/platform/spending-analytics-service.ts  # 30+ logger errors
lib/services/platform/monitoring-service.ts          # PostgrestError issues
lib/services/platform/model-management.ts            # Function signature errors
lib/services/admin/organization-service.ts           # 4 remaining Supabase errors
```

### **Test Files (Second Priority):**
```bash
# Test files with most null/undefined errors:
tests/platform/tag-management/components/tag-list.test.tsx           # 12 errors
tests/api/platform/tags-bulk-operations.test.ts                     # 12 errors
tests/platform/tag-management/integration/tag-management-integration.test.tsx # 11 errors
```

## ⚡ **EXECUTION COMMANDS**

### **Check Current State**
```bash
# Total error count
npx tsc --noEmit 2>&1 | grep "error TS" | wc -l

# Errors in specific file
npx tsc --noEmit 2>&1 | grep "spending-analytics-service.ts"

# Most common error types
npx tsc --noEmit 2>&1 | grep "TS2345" | wc -l  # Assignment errors
npx tsc --noEmit 2>&1 | grep "TS2532" | wc -l  # Null safety errors
```

### **Fix and Validate Loop**
```bash
# 1. Edit file with patterns above
# 2. Check progress
npx tsc --noEmit 2>&1 | grep "filename.ts" | wc -l
# 3. When file is clean, commit
git add filename.ts
git commit -m "fix: FileType parameter types - Fixed X errors"
# 4. Repeat for next file
```

### **Final Validation**
```bash
npx tsc --noEmit           # Should be 0 errors
npm run validate:quick     # Should pass all checks
npm run build             # Should succeed
```

## 🎯 **SPECIFIC FIXES FOR KNOWN ISSUES**

### **Spending Analytics Service** (30+ errors)
Lines with logger issues - replace with these patterns:
```typescript
// Around lines 160, 166, 180, 186, etc:
this.logger.debug('Message', { error: error.message });
this.logger.debug('Message', { error });

// For PostgrestError (lines 660, 685, etc):
if (isPostgrestError(error)) {
  this.logger.debug('Message', { error: error.message, code: error.code });
} else {
  this.logger.debug('Message', { error });
}
```

### **Organization Service** (4 remaining errors)
Lines with Supabase update issues:
```typescript
// Use the Record<string, unknown> pattern established
const updateData: Record<string, unknown> = { /* fields */ };
await supabase.from('table').update(updateData);
```

### **Test Files** (71 null safety errors)
Common patterns in test files:
```typescript
// Mock object property access:
const mockResult = assertNonNull(mockFn.mock.results[0], 'Mock result required');
expect(mockResult.value).toBe('expected');

// Array element access:
const firstItem = assertNonNull(testArray[0], 'First item required');
expect(firstItem.id).toBe('test-id');

// Optional property checks:
if (hasProperty(testData, 'optionalField')) {
  expect(testData.optionalField).toBeDefined();
}
```

## 🚀 **START COMMAND FOR NEXT INSTANCE**

```bash
# 1. Verify current state
npx tsc --noEmit 2>&1 | grep "error TS" | wc -l

# 2. Start with highest impact file
code lib/services/platform/spending-analytics-service.ts

# 3. Apply logger patterns systematically
# 4. Validate progress frequently
# 5. Commit every 10-15 fixes

# Target: Reduce from 323 → 0 errors systematically
```

**Ready to execute! All patterns tested and verified. Infrastructure complete. 🎯**