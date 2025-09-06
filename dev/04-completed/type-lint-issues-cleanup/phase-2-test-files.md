# Phase 2: Test Files & Mocking

## Objective
Fix all TypeScript errors in test files, especially mock type definitions and test utilities.

## Files to Fix (Priority Order)

### Security Test Files
1. **__tests__/security/rbac-security.test.ts** (20 errors)
   - Lines 129, 138, 221, 266, 274, 381, 406, 432, 599: Fix MockQueryBuilder type conversions
   - Lines 167, 204, 246, 294, 310, 333: Fix generic type arguments
   - Lines 174, 212, 238, 565: Fix RoleType assignments

2. **__tests__/security/rls-security.test.ts**
   - Lines 37, 55, 57, 60, 61, 65: Fix MockQueryBuilder type conversions
   - Line 148: Fix type conversion issues

3. **__tests__/hooks/useAuth.test.ts**
   - Line 478: Add missing 'aud' property to AuthUser type

### Test Utilities and Mock Factories
1. **test/test-utils.tsx** (17 errors)
   - Fix mock provider type definitions
   - Fix render function type issues

2. **test/mock-factories.ts** (10 errors)
   - Fix factory function return types
   - Add proper generic constraints

3. **tests/accessibility/accessibility-test-utils.ts** (15 errors)
   - Fix accessibility testing utility types

### Accessibility Tests
1. **tests/accessibility/search-accessibility.test.tsx** (32 errors)
   - Fix component prop types in tests
   - Fix async test assertions

2. **tests/accessibility/ai-management-accessibility.test.tsx** (31 errors)
   - Fix mock data types
   - Fix component testing types

### AI Management Tests
1. **tests/ai-management/api/console-endpoints.test.ts** (31 errors)
   - Fix API mock response types
   - Fix request/response type assertions

2. **tests/ai-management/api/dashboard-endpoints.test.ts** (25 errors)
   - Fix endpoint mock types
   - Fix data validation types

3. **tests/ai-management/layout/ai-management-layout.test.tsx** (27 errors)
   - Fix layout component prop types
   - Fix navigation mock types

## Common Test File Fixes

### 1. Fix MockQueryBuilder Type
```typescript
// Before
const mockQuery = {
  select: vi.fn()
} as MockQueryBuilder // Type error

// After
const mockQuery = {
  select: vi.fn(),
  eq: vi.fn(),
  single: vi.fn(),
  // Add all required methods
} as unknown as MockQueryBuilder
```

### 2. Fix Generic Type Arguments
```typescript
// Before
const mockFn = vi.fn<string, number>() // Expected 0-1 arguments

// After
const mockFn = vi.fn<[string], number>()
// OR
const mockFn = vi.fn(() => 42)
```

### 3. Fix RoleType Assignments
```typescript
// Before
function checkRole(role: "admin") { ... }
const userRole: RoleType = "engineer"
checkRole(userRole) // Type error

// After
function checkRole(role: RoleType) { ... }
// OR use type narrowing
if (userRole === "admin") {
  checkRole(userRole)
}
```

### 4. Add Missing Properties to Mocks
```typescript
// Before
const mockUser = {
  id: "123",
  email: "test@example.com",
  role: "admin"
} as AuthUser // Missing 'aud' property

// After
const mockUser = {
  id: "123",
  email: "test@example.com",
  role: "admin",
  aud: "authenticated", // Add missing property
  // Add other required properties
} as AuthUser
```

### 5. Fix Test Component Props
```typescript
// Before
render(<Component invalidProp="value" />)

// After
render(<Component validProp="value" />)
// Or use proper test props
const testProps: ComponentProps = {
  // all required props
}
render(<Component {...testProps} />)
```

## Mock Type Definition Template
Create a shared mock types file:
```typescript
// test/mock-types.ts
import type { Mock } from 'vitest'

export interface MockQueryBuilder {
  select: Mock
  eq: Mock
  single: Mock
  insert: Mock
  update: Mock
  delete: Mock
  // Add other Supabase query methods
}

export function createMockQueryBuilder(): MockQueryBuilder {
  return {
    select: vi.fn().mockReturnThis(),
    eq: vi.fn().mockReturnThis(),
    single: vi.fn().mockResolvedValue({ data: null, error: null }),
    // ... implement all methods
  }
}
```

## Validation Commands
After fixing all files in this phase, run:
```bash
npm test -- __tests__/
npm test -- tests/
```

## Success Criteria
- All test files compile without TypeScript errors
- Mock types properly defined and reusable
- Tests pass after type fixes
- No type assertions using `as any`

## Notes for Agent
- Create reusable mock utilities to avoid duplication
- Ensure mock types match actual implementation interfaces
- Use `unknown` with type guards instead of `any`
- Maintain test coverage while fixing types
- Consider creating a central mock factory module