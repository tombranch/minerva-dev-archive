# Phase 2: API Infrastructure Consolidation Implementation Plan

**Duration:** 2 weeks  
**Priority:** Critical  
**Agent Assignment:** Backend API Specialist  
**Dependencies:** Phase 1 (Authentication Service)  

## Overview

Consolidate scattered API handling patterns into a unified, maintainable system. This phase addresses duplication in API routes, response formatting, error handling, and middleware patterns.

## Current State Analysis

### Files to Consolidate
- `lib/api-response.ts` (174 lines) - Response utilities
- `app/api/*/route.ts` (20+ files) - API route handlers
- `lib/with-auth.ts` (70 lines) - Auth wrapper
- `lib/rate-limit.ts` (128 lines) - Rate limiting
- `lib/rate-limiter.ts` (200+ lines) - Advanced rate limiting
- `middleware.ts` (partial) - Request processing

### Duplication Issues
1. Error response formatting repeated in every API route
2. Success response patterns duplicated 15+ times
3. Authentication checks implemented differently across routes
4. Rate limiting applied inconsistently
5. Validation patterns scattered across routes

## Implementation Tasks

### Task 1: Create Unified API Handler Framework
**File:** `lib/api/unified-handler.ts`
**Estimated Time:** 4 days

```typescript
// Comprehensive API handler framework
export interface APIHandlerConfig {
  auth?: {
    required: boolean
    roles?: UserRole[]
    requireOrg?: boolean
  }
  rateLimit?: {
    windowMs: number
    max: number
    skipSuccessfulRequests?: boolean
  }
  validation?: {
    query?: ZodSchema
    body?: ZodSchema
    params?: ZodSchema
  }
  cache?: {
    ttl: number
    key?: (req: NextRequest) => string
  }
}

export function createAPIHandler<TQuery = any, TBody = any, TParams = any>(
  config: APIHandlerConfig,
  handler: (context: APIContext<TQuery, TBody, TParams>) => Promise<NextResponse>
) {
  return async (request: NextRequest, routeParams?: any): Promise<NextResponse> => {
    try {
      // 1. Rate limiting
      if (config.rateLimit) {
        const rateLimitResult = await checkRateLimit(request, config.rateLimit)
        if (!rateLimitResult.allowed) {
          return createRateLimitResponse(rateLimitResult)
        }
      }

      // 2. Authentication
      let user: AuthUser | null = null
      if (config.auth?.required) {
        const authResult = await validateAuthentication(request)
        if (!authResult.success) {
          return createAuthErrorResponse(authResult.error)
        }
        user = authResult.user

        // Role checking
        if (config.auth.roles && !checkUserRole(user, config.auth.roles)) {
          return createForbiddenResponse('Insufficient permissions')
        }

        // Organization requirement
        if (config.auth.requireOrg && !user.organizationId) {
          return createForbiddenResponse('Organization context required')
        }
      }

      // 3. Request validation
      const validatedData = await validateRequest(request, routeParams, config.validation)
      if (!validatedData.success) {
        return createValidationErrorResponse(validatedData.errors)
      }

      // 4. Cache check
      if (config.cache && request.method === 'GET') {
        const cachedResponse = await getCachedResponse(request, config.cache)
        if (cachedResponse) {
          return cachedResponse
        }
      }

      // 5. Execute handler
      const context: APIContext<TQuery, TBody, TParams> = {
        request,
        user,
        query: validatedData.query,
        body: validatedData.body,
        params: validatedData.params,
        organizationId: user?.organizationId || null
      }

      const response = await handler(context)

      // 6. Cache response
      if (config.cache && request.method === 'GET' && response.ok) {
        await cacheResponse(request, response, config.cache)
      }

      return response

    } catch (error) {
      return createErrorResponse(error)
    }
  }
}
```

**Implementation Steps:**
1. Create base APIHandler framework
2. Implement rate limiting integration
3. Add authentication integration (using Phase 1 AuthService)
4. Implement request validation
5. Add caching layer
6. Create comprehensive error handling
7. Write unit tests for all functionality

### Task 2: Standardize Response Formatting
**File:** `lib/api/response-formatter.ts`
**Estimated Time:** 2 days

```typescript
// Unified response formatting
export interface StandardAPIResponse<T = unknown> {
  success: boolean
  data?: T
  error?: {
    type: string
    message: string
    code?: string | number
    details?: Record<string, unknown>
    timestamp: string
  }
  metadata?: {
    total?: number
    page?: number
    limit?: number
    hasMore?: boolean
    requestId?: string
  }
}

export class ResponseFormatter {
  static success<T>(
    data: T,
    metadata?: StandardAPIResponse<T>['metadata']
  ): NextResponse<StandardAPIResponse<T>>

  static error(
    error: unknown,
    statusCode: number = 500
  ): NextResponse<StandardAPIResponse>

  static validation(
    errors: ValidationError[]
  ): NextResponse<StandardAPIResponse>

  static paginated<T>(
    data: T[],
    total: number,
    page: number,
    limit: number
  ): NextResponse<StandardAPIResponse<T[]>>

  static notFound(
    resource: string
  ): NextResponse<StandardAPIResponse>

  static unauthorized(
    message?: string
  ): NextResponse<StandardAPIResponse>

  static forbidden(
    message?: string
  ): NextResponse<StandardAPIResponse>

  static rateLimit(
    retryAfter: number
  ): NextResponse<StandardAPIResponse>
}
```

**Implementation Steps:**
1. Create ResponseFormatter class
2. Implement all standard response types
3. Add request ID tracking
4. Implement error categorization
5. Add response headers management
6. Test all response formats

### Task 3: Create Validation Middleware
**File:** `lib/api/validation-middleware.ts`
**Estimated Time:** 2 days

```typescript
// Request validation utilities
export interface ValidationConfig {
  query?: ZodSchema
  body?: ZodSchema
  params?: ZodSchema
  files?: FileValidationConfig
}

export interface ValidationResult<TQuery, TBody, TParams> {
  success: boolean
  query?: TQuery
  body?: TBody
  params?: TParams
  errors?: ValidationError[]
}

export class RequestValidator {
  static async validate<TQuery, TBody, TParams>(
    request: NextRequest,
    routeParams: any,
    config: ValidationConfig
  ): Promise<ValidationResult<TQuery, TBody, TParams>>

  static validateQuery<T>(
    searchParams: URLSearchParams,
    schema: ZodSchema<T>
  ): ValidationResult<T, never, never>

  static async validateBody<T>(
    request: NextRequest,
    schema: ZodSchema<T>
  ): Promise<ValidationResult<never, T, never>>

  static validateParams<T>(
    params: any,
    schema: ZodSchema<T>
  ): ValidationResult<never, never, T>

  static validateFiles(
    request: NextRequest,
    config: FileValidationConfig
  ): Promise<FileValidationResult>
}
```

**Implementation Steps:**
1. Create RequestValidator class
2. Implement query parameter validation
3. Add request body validation
4. Implement route parameter validation
5. Add file upload validation
6. Create comprehensive error messages

### Task 4: Enhance Rate Limiting System
**File:** `lib/api/rate-limiting.ts`
**Estimated Time:** 2 days

```typescript
// Unified rate limiting system
export interface RateLimitConfig {
  windowMs: number
  max: number
  skipSuccessfulRequests?: boolean
  skipFailedRequests?: boolean
  keyGenerator?: (request: NextRequest) => string
  onLimitReached?: (request: NextRequest) => void
}

export interface RateLimitResult {
  allowed: boolean
  remaining: number
  resetTime: number
  totalHits: number
}

export class RateLimiter {
  static async checkLimit(
    request: NextRequest,
    config: RateLimitConfig
  ): Promise<RateLimitResult>

  static async recordRequest(
    key: string,
    config: RateLimitConfig
  ): Promise<void>

  static generateKey(
    request: NextRequest,
    config: RateLimitConfig
  ): string

  static createLimitHeaders(
    result: RateLimitResult
  ): Record<string, string>
}

// Predefined rate limit configurations
export const RateLimitPresets = {
  public: { windowMs: 15 * 60 * 1000, max: 50 },
  authenticated: { windowMs: 15 * 60 * 1000, max: 500 },
  ai: { windowMs: 60 * 60 * 1000, max: 100 },
  auth: { windowMs: 15 * 60 * 1000, max: 10 },
  heavy: { windowMs: 60 * 60 * 1000, max: 20 }
}
```

**Implementation Steps:**
1. Consolidate existing rate limiting logic
2. Create unified RateLimiter class
3. Implement preset configurations
4. Add custom key generation
5. Implement rate limit headers
6. Test with various scenarios

### Task 5: Create API Route Templates
**File:** `lib/api/route-templates.ts`
**Estimated Time:** 2 days

```typescript
// Standard route templates
export const createCRUDRoutes = <T>(config: CRUDConfig<T>) => ({
  GET: createAPIHandler({
    auth: { required: true },
    rateLimit: RateLimitPresets.authenticated,
    validation: { query: config.listSchema }
  }, async (context) => {
    const items = await config.service.list(context.query, context.organizationId)
    return ResponseFormatter.paginated(items.data, items.total, items.page, items.limit)
  }),

  POST: createAPIHandler({
    auth: { required: true, roles: config.createRoles },
    rateLimit: RateLimitPresets.authenticated,
    validation: { body: config.createSchema }
  }, async (context) => {
    const item = await config.service.create(context.body, context.user.id, context.organizationId)
    return ResponseFormatter.success(item, { requestId: context.request.headers.get('x-request-id') })
  }),

  PUT: createAPIHandler({
    auth: { required: true, roles: config.updateRoles },
    validation: { 
      params: z.object({ id: z.string() }),
      body: config.updateSchema 
    }
  }, async (context) => {
    const item = await config.service.update(context.params.id, context.body, context.user.id)
    return ResponseFormatter.success(item)
  }),

  DELETE: createAPIHandler({
    auth: { required: true, roles: config.deleteRoles },
    validation: { params: z.object({ id: z.string() }) }
  }, async (context) => {
    await config.service.delete(context.params.id, context.user.id)
    return ResponseFormatter.success({ deleted: true })
  })
})
```

**Implementation Steps:**
1. Create CRUD route templates
2. Implement search route templates
3. Add bulk operation templates
4. Create export/import templates
5. Add file upload templates
6. Test all templates

### Task 6: Migrate Existing API Routes
**Files:** All `app/api/*/route.ts` files
**Estimated Time:** 3 days

**Implementation Steps:**
1. **Priority 1:** Migrate authentication routes
2. **Priority 2:** Migrate photo management routes
3. **Priority 3:** Migrate AI management routes
4. **Priority 4:** Migrate admin routes
5. **Priority 5:** Migrate remaining routes

**Migration Pattern:**
```typescript
// Before
export async function GET(request: NextRequest) {
  try {
    // Auth check
    const { user, error } = await validateSession()
    if (error) return NextResponse.json({ error }, { status: 401 })
    
    // Rate limiting
    const rateLimitResult = await rateLimitCheck(request, rateLimits.authenticated)
    if (!rateLimitResult.allowed) return NextResponse.json({ error: 'Rate limited' }, { status: 429 })
    
    // Validation
    const { searchParams } = new URL(request.url)
    const query = photoListQuerySchema.parse(Object.fromEntries(searchParams.entries()))
    
    // Business logic
    const photos = await photoService.listPhotos(query)
    
    return NextResponse.json({ success: true, data: photos })
  } catch (error) {
    return NextResponse.json({ error: 'Internal error' }, { status: 500 })
  }
}

// After
export const GET = createAPIHandler({
  auth: { required: true },
  rateLimit: RateLimitPresets.authenticated,
  validation: { query: photoListQuerySchema }
}, async (context) => {
  const photos = await photoService.listPhotos(context.query, context.organizationId)
  return ResponseFormatter.success(photos)
})
```

## Testing Requirements

### Unit Tests
- APIHandler framework (100% coverage)
- ResponseFormatter methods
- RequestValidator functionality
- RateLimiter behavior

### Integration Tests
- Complete API request/response cycles
- Authentication integration
- Rate limiting behavior
- Error handling scenarios

### Performance Tests
- Response time benchmarks
- Rate limiting accuracy
- Memory usage optimization
- Concurrent request handling

## Migration Strategy

### Week 1: Core Framework
1. **Days 1-2:** Create APIHandler framework and ResponseFormatter
2. **Days 3-4:** Implement validation and rate limiting
3. **Day 5:** Create route templates and initial testing

### Week 2: Migration & Testing
1. **Days 1-2:** Migrate critical API routes (auth, photos)
2. **Days 3-4:** Migrate remaining routes and comprehensive testing
3. **Day 5:** Performance testing and optimization

## Success Criteria

### Code Quality
- [ ] All API routes use unified handler framework
- [ ] Consistent response formatting across all endpoints
- [ ] No duplicated authentication or validation logic
- [ ] Standardized error handling

### Functionality
- [ ] All existing API functionality preserved
- [ ] Improved error messages and consistency
- [ ] Better rate limiting coverage
- [ ] Enhanced request validation

### Performance
- [ ] No regression in API response times
- [ ] Improved memory usage through reduced duplication
- [ ] Better caching implementation
- [ ] Optimized middleware execution

## Deliverables

1. **Unified API Framework** - Complete handler system
2. **Response Formatter** - Standardized response formatting
3. **Validation System** - Request validation middleware
4. **Rate Limiting** - Enhanced rate limiting system
5. **Route Templates** - Reusable route patterns
6. **Migrated Routes** - All routes using new framework
7. **Comprehensive Tests** - Full test coverage
8. **Performance Report** - Before/after analysis

---

**Phase Owner:** Backend API Specialist Agent  
**Review Required:** Senior Developer + Performance Review  
**Next Phase:** Phase 3 - Form System Consolidation
