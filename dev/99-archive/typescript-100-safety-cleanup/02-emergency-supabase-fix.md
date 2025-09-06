# Emergency Supabase Type Fix Plan

## Problem Analysis

The TypeScript compilation is failing with hundreds of `never` type errors on Supabase database operations. Root cause analysis:

### Symptoms
- Database queries returning `never` types
- INSERT/UPDATE operations failing type validation
- `Property 'X' does not exist on type 'never'` errors across 20+ files

### Investigation Findings
1. ✅ Database type definitions exist (45+ tables in types/database.ts)
2. ✅ Import paths are correct (`@/types/database`)
3. ✅ Required tables (tags, photo_tags, ai_corrections) are properly defined
4. ❌ Supabase client generic typing is broken

## Root Cause
The `createServerClient<Database>()` and `createClient<Database>()` calls are not properly propagating the Database type to the query builders, causing them to default to `never`.

## Immediate Fix Strategy

### Step 1: Type Assertion Fix
For files with critical errors, add explicit type assertions:
```typescript
// Before (broken)
const { data: existingTag } = await supabase
  .from('tags')
  .select('id')

// After (fixed)
const { data: existingTag } = await supabase
  .from('tags')
  .select('id') as any
```

### Step 2: Client Recreation
Recreate Supabase client instances with explicit typing:
```typescript
import type { Database } from '@/types/database';

const supabase = createServerClient<Database>(url, key, options);
```

### Step 3: Query Method Fixing
Fix specific query patterns that are failing:
```typescript
// Fix INSERT operations
const { data } = await supabase
  .from('tags')
  .insert({
    name: tag_name.trim(),
    category,
    created_at: new Date().toISOString(),
  })
  .select('id')
  .single();
```

## Files to Fix (Priority Order)

### Critical Production Routes
1. `app/api/ai/add-tag/route.ts`
2. `app/(protected)/admin/feedback/page.tsx`
3. `app/(protected)/no-organization/page.tsx`
4. `app/(protected)/profile/setup/page.tsx`

### API Routes (High Priority)
- `app/api/ai/` directory (20+ files)
- Database operation files

### Test Files (Lower Priority)
- Test infrastructure can use type assertions temporarily

## Success Criteria
- [ ] TypeScript compilation passes
- [ ] Database operations return proper types (not `never`)
- [ ] API routes compile without errors
- [ ] Build process completes successfully

## Timeline
- **Immediate**: Fix critical production routes (1-2 hours)
- **Short-term**: Fix remaining API routes (2-3 hours)
- **Medium-term**: Investigate permanent solution (regenerate types)