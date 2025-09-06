# Phase 3: Platform/Debug Pages

## Objective
Fix all TypeScript errors in platform admin and debug pages, focusing on unknown type handling and React component type safety.

## Files to Fix (Priority Order)

### Debug Pages with Most Errors
1. **app/platform/debug/analytics/page.tsx** (25 errors)
   - Lines 372-409: Fix `environmentData` unknown type access
   - Lines 434-591: Fix ReactNode type assignments
   - Line 540: Fix map function parameter types

2. **app/platform/debug/storage/page.tsx** (23 errors)
   - Fix unknown type property access
   - Fix ReactNode assignments

3. **app/platform/debug/email/page.tsx** (18 errors)
   - Fix configuration type definitions
   - Fix unknown type handling

4. **app/platform/debug/database/page.tsx** (18 errors)
   - Lines 312-345: Fix environment data access
   - Lines 369-399: Fix ReactNode assignments

5. **app/platform/debug/ai/page.tsx** (14 errors)
   - Lines 342-379: Fix environment unknown types
   - Lines 404-502: Fix ReactNode assignments

### Platform AI Management Pages
1. **app/platform/ai-management/spending/page.tsx** (11 errors)
   - Lines 209-528: Fix implicit any parameters
   - Line 602: Fix null assignment to undefined type

2. **app/platform/ai-management/models/page.tsx**
   - Lines 236, 249: Fix object type issues
   - Lines 931, 955: Add parameter types

3. **app/platform/ai-management/prompts/page.tsx**
   - Lines 256, 263: Fix object type issues  
   - Line 565: Fix null vs undefined assignment

4. **app/platform/ai-management/features/page.tsx**
   - Line 485: Add parameter type

## Common Platform Page Fixes

### 1. Fix Unknown Type Property Access
```typescript
// Before
const value = environmentData.environment // Type 'unknown'

// After - Add type definition
interface EnvironmentData {
  environment: string
  config: {
    enabled: boolean
    // other properties
  }
}
const typedData = environmentData as EnvironmentData
const value = typedData.environment

// OR use type guard
function isEnvironmentData(data: unknown): data is EnvironmentData {
  return (
    typeof data === 'object' &&
    data !== null &&
    'environment' in data &&
    typeof (data as any).environment === 'string'
  )
}
```

### 2. Fix ReactNode Assignments
```typescript
// Before
<div>{unknownValue}</div> // Type 'unknown' not assignable to ReactNode

// After
<div>{String(unknownValue)}</div>
// OR
<div>{JSON.stringify(unknownValue)}</div>
// OR with type guard
<div>{isValidReactNode(unknownValue) ? unknownValue : null}</div>
```

### 3. Fix Implicit Any Parameters
```typescript
// Before
array.map((item) => ...) // Parameter 'item' implicitly has 'any' type

// After
array.map((item: ItemType) => ...)
// OR
(array as ItemType[]).map((item) => ...)
```

### 4. Fix Object Property Access
```typescript
// Before
const length = obj.length // Property 'length' does not exist on type '{}'

// After
const items = obj as string[]
const length = items.length
// OR check if array
const length = Array.isArray(obj) ? obj.length : 0
```

### 5. Fix Null vs Undefined
```typescript
// Before
const value: Type | undefined = null // Type error

// After
const value: Type | undefined = undefined
// OR change type
const value: Type | null = null
```

## Type Definition Templates

### Environment Data Types
```typescript
// lib/types/platform/environment.ts
export interface EnvironmentData {
  environment: 'development' | 'staging' | 'production'
  config: {
    enabled: boolean
    features: Record<string, boolean>
    limits: {
      maxRequests: number
      maxStorage: number
    }
  }
  metrics?: {
    requests: number
    errors: number
    latency: number
  }
}
```

### Debug Page Props
```typescript
// lib/types/platform/debug.ts
export interface DebugPageData {
  system: {
    version: string
    uptime: number
    memory: {
      used: number
      total: number
    }
  }
  database: {
    connected: boolean
    poolSize: number
    activeConnections: number
  }
  // Add other sections
}
```

## Validation Commands
After fixing all files in this phase, run:
```bash
npm run build -- --filter="app/platform/**"
npm run lint -- app/platform/
```

## Success Criteria
- All platform pages compile without errors
- Unknown types properly handled with guards or assertions
- ReactNode assignments fixed
- All implicit any types resolved
- Consistent type definitions across debug pages

## Notes for Agent
- Create shared type definitions for environment data
- Use type guards for unknown data from APIs
- Consider creating a debug data fetching service with typed responses
- Ensure UI remains functional after type fixes
- Add proper loading states for async data