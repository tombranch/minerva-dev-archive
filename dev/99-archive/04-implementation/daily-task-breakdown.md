# Daily Task Breakdown - AI Management Platform Recovery

**Week 1: Technical Cleanup (1,104 → <100 TypeScript Errors)**

---

## 📅 Day 1: API Route Signature Fixes (Target: Fix 400+ errors)

### Morning Session (2-3 hours)
**Focus**: AI Analytics API Tests

#### Task 1.1: Fix Analytics API Tests (20 files, ~150 errors)
```bash
# Files to fix:
__tests__/api/ai/analytics/cost-analysis.test.ts (20 errors)
__tests__/api/ai/dashboard/queue-status-simple.test.ts (7 errors)  
__tests__/api/ai/dashboard/queue-status.test.ts (20 errors)
```

**Pattern to Fix**:
```typescript
// BEFORE (causing errors)
const response = await GET(request);

// AFTER (correct signature)
const mockContext = { params: Promise.resolve({ id: 'test-id' }) };
const response = await GET(request, mockContext);
```

**Specific Changes**:
1. Add context parameter to all API calls
2. Update mock setup for `createServerClient` → `getServerClient`
3. Fix `requirePlatformAdmin` → `isPlatformAdmin` references

#### Task 1.2: Fix Pipeline API Tests (9 files, ~50 errors)
```bash
# Files to fix:
__tests__/api/ai/pipeline/models.test.ts (9 errors)
```

**Issues to Fix**:
1. Missing PUT/DELETE exports in route files
2. API signature mismatches
3. Mock service interface updates

### Afternoon Session (2-3 hours)
**Focus**: Process API Tests

#### Task 1.3: Fix Process API Tests (22 files, ~100 errors)
```bash
# Files to fix:
__tests__/api/ai/process-batch.test.ts (22 errors)
__tests__/api/ai/process-photo-simple.test.ts (6 errors)
```

**Common Fixes**:
1. Add context parameter to POST calls
2. Fix mock data structure mismatches
3. Update error handling expectations

### End of Day 1 Target
- **Errors Fixed**: ~400 (from 1,104 to ~700)
- **Files Updated**: ~30 test files
- **Validation**: Run `npm run type-check` to confirm progress

---

## 📅 Day 2: Platform API & Component Tests (Target: Fix 300+ errors)

### Morning Session (2-3 hours)
**Focus**: Platform AI Management APIs

#### Task 2.1: Fix Platform API Tests (25 files, ~150 errors)
```bash
# Files to fix:
tests/api/platform/ai-management/features-api.test.ts (1 error)
tests/api/platform/ai-management/prompts-api.test.ts (2 errors)
tests/api/photos/bulk-download.test.ts (34 errors)
```

**Key Issues**:
1. Missing PUT/DELETE exports in route files
2. API signature changes (3 parameters instead of 2)
3. AuthUser interface mismatches

#### Task 2.2: Fix Component Tests (25 files, ~100 errors)
```bash
# Files to fix:
__tests__/components/photos/photo-grid.test.tsx (25 errors)
tests/components/photos/bulk-tag-selector.test.tsx (7 errors)
tests/components/photos/project-site-selector.test.tsx (7 errors)
```

**Common Patterns**:
1. Update mock AuthUser objects with required fields
2. Fix component prop type mismatches
3. Update test utility functions

### Afternoon Session (2-3 hours)
**Focus**: AI Management Component Tests

#### Task 2.3: Fix AI Management Tests (46 files, ~200 errors)
```bash
# Files to fix:
tests/ai-management/components/ai-console.test.tsx (46 errors)
tests/ai-management/layout/ai-management-layout.test.tsx (24 errors)
```

**Specific Fixes**:
1. Update useAuth mock return values
2. Fix AuthUser interface compliance
3. Update component prop expectations

### End of Day 2 Target
- **Errors Fixed**: ~300 (from ~700 to ~400)
- **Files Updated**: ~50 test files
- **Validation**: Confirm API tests are passing

---

## 📅 Day 3: Missing Exports & Route Fixes (Target: Fix 200+ errors)

### Morning Session (2-3 hours)
**Focus**: Add Missing API Exports

#### Task 3.1: Fix Missing Route Exports
```bash
# Files to update:
app/api/ai/pipeline/models/route.ts - Add PUT, DELETE exports
app/api/platform/ai-management/features/route.ts - Add PUT export  
app/api/platform/ai-management/prompts/route.ts - Add PUT, DELETE exports
```

**Template for Missing Methods**:
```typescript
export async function PUT(request: NextRequest, context: any) {
  return NextResponse.json({ error: 'Method not implemented' }, { status: 501 });
}

export async function DELETE(request: NextRequest, context: any) {
  return NextResponse.json({ error: 'Method not implemented' }, { status: 501 });
}
```

#### Task 3.2: Fix Import Statements
Update test files to only import existing methods or handle missing ones gracefully.

### Afternoon Session (2-3 hours)
**Focus**: Mock Service Interface Updates

#### Task 3.3: Update Mock Services
```bash
# Files to fix:
test/supabase-mocks.ts
tests/ai-management/mock-services.ts  
test/test-utils.tsx
```

**Key Updates**:
1. `createServerClient` → `getServerClient`
2. `requirePlatformAdmin` → `isPlatformAdmin`
3. Update mock return value structures

### End of Day 3 Target
- **Errors Fixed**: ~200 (from ~400 to ~200)
- **Routes Updated**: All missing exports added
- **Validation**: All imports resolve correctly

---

## 📅 Day 4: Type Safety & Interface Alignment (Target: Fix 150+ errors)

### Morning Session (2-3 hours)
**Focus**: AuthUser Interface Fixes

#### Task 4.1: Fix AuthUser Mismatches (42 errors)
```typescript
// Common fix pattern:
// BEFORE
const mockUser = { id: 'test', email: 'test@example.com' };

// AFTER  
const mockUser: AuthUser = {
  id: 'test',
  email: 'test@example.com',
  organizationId: 'org-123',
  role: 'platform_admin',
  app_metadata: {},
  user_metadata: {},
  aud: 'authenticated',
  created_at: '2025-01-01T00:00:00Z'
};
```

#### Task 4.2: Fix Component Prop Types (25 errors)
Update component props to match current TypeScript interfaces.

### Afternoon Session (2-3 hours)
**Focus**: Test Factory Updates

#### Task 4.3: Fix Test Factories (15 errors)
```bash
# Files to fix:
tests/platform/tag-management/test-factories.ts (2 errors)
tests/smart-albums.test.ts (1 error)
tests/test-utilities.ts (1 error)
```

**Common Issues**:
1. Generic type constraints
2. Property type mismatches
3. Function signature updates

### End of Day 4 Target
- **Errors Fixed**: ~150 (from ~200 to ~50)
- **Type Safety**: All major interface mismatches resolved
- **Validation**: TypeScript strict mode compliance

---

## 📅 Day 5: Final Cleanup & Validation (Target: <50 errors)

### Morning Session (2-3 hours)
**Focus**: Remaining Edge Cases

#### Task 5.1: Fix Remaining Errors
Address any remaining TypeScript errors that don't fit the previous patterns.

#### Task 5.2: Test Suite Validation
```bash
# Run full test suite
npm test

# Run type checking
npm run type-check

# Run linting
npm run lint
```

### Afternoon Session (2-3 hours)
**Focus**: Documentation & Handoff

#### Task 5.3: Update Documentation
- Update implementation status
- Document any remaining known issues
- Create handoff notes for Week 2

#### Task 5.4: Prepare for Week 2
- Review feature completion priorities
- Set up development environment for advanced features
- Plan Week 2 sprint

### End of Day 5 Target
- **Final Error Count**: <50 TypeScript errors
- **Test Pass Rate**: >90%
- **Documentation**: Complete and up-to-date
- **Ready for Week 2**: Feature completion phase

---

## 🛠 Tools & Commands

### Daily Validation Commands
```bash
# Check TypeScript errors
npx tsc --noEmit

# Run specific test files
npm test -- __tests__/api/ai/analytics/

# Check build status
npm run build

# Run linting
npm run lint:fix
```

### Progress Tracking
```bash
# Count remaining errors
npx tsc --noEmit 2>&1 | grep "error TS" | wc -l

# Check test pass rate
npm test -- --reporter=json | jq '.numPassedTests, .numFailedTests'
```

### Emergency Rollback
If any changes break the build:
```bash
# Reset to last working state
git checkout HEAD~1 -- [problematic-file]

# Or reset entire day's work
git reset --hard HEAD~1
```

---

## 📊 Success Metrics

**Daily Targets**:
- Day 1: 1,104 → ~700 errors (400 fixed)
- Day 2: ~700 → ~400 errors (300 fixed)  
- Day 3: ~400 → ~200 errors (200 fixed)
- Day 4: ~200 → ~50 errors (150 fixed)
- Day 5: ~50 → <50 errors (final cleanup)

**Weekly Goal**: <50 TypeScript errors, >90% test pass rate, production-ready codebase.
