# Phase 1: Critical API Routes & Core Services

## Objective
Fix all TypeScript errors in API routes and core services that could affect runtime functionality.

## Files to Fix (Priority Order)

### API Routes with Critical Errors
1. **app/api/photos/bulk-generate-descriptions/route.ts**
   - Lines 118-119, 178: Remove `any` types
   - Line 273: Fix undefined `request` variable (should be `_request`)

2. **app/api/photos/[id]/chat/route.ts**
   - Lines 76-83, 239-246: Remove 12 `any` types
   - Line 109: Fix undefined `request` variable

3. **app/api/ai/providers/[id]/test/route.ts**
   - Lines 156, 242, 326: Fix undefined `data` variable (should be `_data`)

4. **app/api/ai/testing/sample-photos/route.ts**
   - Lines 64, 294: Add missing `createErrorResponse` function

5. **app/api/platform/ai-management/deployments/route.ts**
   - Line 94: Fix type mismatch in map function for RawDeployment

6. **app/api/platform/tags/route.ts**
   - Lines 357-358: Fix undefined `user` variable (should be `_user`)

7. **app/api/platform/change-organization/route.ts**
   - Line 34: Fix undefined `request` variable

8. **app/api/platform/validate-org-change/route.ts**
   - Line 28: Fix undefined `request` variable

9. **app/api/platform/ai-management/prompts/categories/route.ts**
   - Line 38: Fix undefined `request` variable

10. **app/api/platform/tags/duplicates/route.ts**
    - Line 77: Fix string to number conversion

### Core Services with Type Errors
1. **lib/services/ai-metrics-realtime.ts** (50 errors)
   - Fix unknown types and property access issues
   
2. **lib/user-activity-service.ts** (42 errors)
   - Fix type definitions and property access

3. **lib/services/platform/platform-spending-analytics.ts** (14 errors)
   - Fix type definitions for analytics data

4. **lib/services/platform/overview-service.ts** (13 errors)
   - Fix type definitions for overview data

5. **lib/ai/response-schemas.ts** (22 errors)
   - Fix schema type definitions

6. **lib/ai/prompt-variables.ts** (14 errors)
   - Fix variable type definitions

7. **lib/ai/providers/clarifai.ts** (11 errors)
   - Fix provider-specific type issues

## Common Fixes Needed

### 1. Replace `any` types
```typescript
// Before
const handleData = (data: any) => { ... }

// After - use proper types or unknown with type guards
const handleData = (data: PhotoData) => { ... }
// OR
const handleData = (data: unknown) => {
  if (isPhotoData(data)) { ... }
}
```

### 2. Fix undefined variables
```typescript
// Before
const result = request.json() // 'request' is undefined

// After - use the actual parameter name
const result = _request.json()
```

### 3. Fix type conversions
```typescript
// Before
const id: number = params.id // params.id is string

// After
const id = parseInt(params.id, 10)
```

### 4. Add missing function definitions
```typescript
// Add at top of file
function createErrorResponse(message: string, status: number) {
  return NextResponse.json({ error: message }, { status })
}
```

### 5. Fix provider type literals
```typescript
// Before
const provider: string = "google"
validateProvider(provider) // expects literal type

// After
const provider = "google" as const
// OR
const provider: "google" | "clarifai" | "gemini" = "google"
```

## Validation Commands
After fixing all files in this phase, run:
```bash
npm run lint -- app/api/
npm run build
```

## Success Criteria
- No TypeScript errors in API routes
- No ESLint `any` type warnings in API routes
- All undefined variable references fixed
- Build completes successfully for API routes

## Notes for Agent
- Focus on runtime-critical errors first
- Ensure all API responses have proper error handling
- Maintain existing functionality while fixing types
- Use strict typing - no `any` types allowed
- Test each route after fixing if possible