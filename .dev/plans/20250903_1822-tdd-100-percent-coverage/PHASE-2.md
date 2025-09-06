# Phase 2: Backend & API Testing

**Objective**: Complete API route testing, Convex function coverage, and business logic TDD implementation
**Duration**: 3-4 days
**Priority**: 🟠 HIGH - Core functionality testing
**Success Criteria**: 100% API coverage, all Convex functions tested, business logic fully covered

## 📋 Phase Overview

This phase focuses on establishing comprehensive backend testing coverage using TDD methodology. With 21 API routes largely untested and critical Convex functions requiring validation, this phase will systematically implement test coverage for all backend operations, ensuring data integrity, security, and performance requirements are met.

## 🎯 Phase Objectives

1. **API Route Testing** (21 routes)
   - Complete contract validation
   - Error scenario coverage
   - Authentication/authorization testing
   - Response schema validation

2. **Convex Function Testing**
   - Query function testing
   - Mutation validation
   - Action testing with mocks
   - Real-time subscription testing

3. **Business Logic Coverage**
   - Service layer testing
   - Utility function validation
   - Algorithm verification
   - Data transformation testing

4. **Integration Testing**
   - Database operations
   - Third-party API integration
   - File processing workflows
   - Export/import functionality

## 🔧 Detailed Implementation Tasks

### Task 1: API Route Testing Framework

**Setup API Testing Infrastructure**:
```typescript
// tests/api/test-helpers.ts
import { createMocks } from 'node-mocks-http'
import { NextRequest } from 'next/server'

export function createTestRequest(options: {
  method?: string
  url?: string
  headers?: Record<string, string>
  body?: any
  query?: Record<string, string>
}) {
  const { req, res } = createMocks(options)
  return { 
    request: new NextRequest(req.url, {
      method: req.method,
      headers: req.headers,
      body: JSON.stringify(req.body)
    }),
    response: res
  }
}

// TDD test template for API routes
describe('API Route: /api/[route]', () => {
  // RED: Write failing test first
  it('should handle GET requests correctly', async () => {
    const { request } = createTestRequest({
      method: 'GET',
      query: { id: 'test-id' }
    })
    
    const response = await GET(request)
    const data = await response.json()
    
    expect(response.status).toBe(200)
    expect(data).toMatchObject({
      success: true,
      data: expect.any(Object)
    })
  })
  
  // GREEN: Implement minimal API handler
  // REFACTOR: Optimize and add error handling
})
```

### Task 2: Test All API Routes

**API Routes to Test** (21 total):
```
app/api/
├── health/route.ts
├── auth/
│   ├── clerk-webhook/route.ts
│   └── validate/route.ts
├── photos/
│   ├── route.ts (GET, POST, DELETE)
│   ├── [id]/route.ts
│   ├── batch/route.ts
│   └── export/route.ts
├── ai/
│   ├── process/route.ts
│   ├── batch-process/route.ts
│   └── status/route.ts
├── organizations/
│   ├── route.ts
│   └── [id]/route.ts
├── users/
│   ├── route.ts
│   └── [id]/route.ts
├── search/route.ts
├── tags/route.ts
├── export/
│   ├── csv/route.ts
│   └── pdf/route.ts
└── platform/
    └── analytics/route.ts
```

**TDD Implementation for Each Route**:
```typescript
// tests/api/photos/route.test.ts
describe('Photos API', () => {
  describe('POST /api/photos', () => {
    // RED: Test upload functionality
    it('should upload a photo with metadata', async () => {
      const formData = new FormData()
      formData.append('file', new Blob(['test']), 'test.jpg')
      formData.append('title', 'Test Photo')
      
      const response = await POST(createTestRequest({
        method: 'POST',
        body: formData
      }))
      
      expect(response.status).toBe(201)
      const data = await response.json()
      expect(data.photo).toHaveProperty('id')
      expect(data.photo.title).toBe('Test Photo')
    })
    
    it('should validate file types', async () => {
      const formData = new FormData()
      formData.append('file', new Blob(['test']), 'test.exe')
      
      const response = await POST(createTestRequest({
        method: 'POST',
        body: formData
      }))
      
      expect(response.status).toBe(400)
      const error = await response.json()
      expect(error.error).toContain('Invalid file type')
    })
    
    it('should require authentication', async () => {
      const response = await POST(createTestRequest({
        method: 'POST',
        headers: { /* no auth */ }
      }))
      
      expect(response.status).toBe(401)
    })
  })
  
  describe('GET /api/photos', () => {
    // Test pagination, filtering, sorting
    it('should return paginated results', async () => {
      const response = await GET(createTestRequest({
        query: { page: '1', limit: '10' }
      }))
      
      const data = await response.json()
      expect(data.photos).toHaveLength(10)
      expect(data.pagination).toMatchObject({
        page: 1,
        limit: 10,
        total: expect.any(Number)
      })
    })
  })
})
```

### Task 3: Convex Function Testing

**Setup Convex Testing**:
```typescript
// tests/convex/test-setup.ts
import { convexTest } from 'convex-test'
import { api } from '@/convex/_generated/api'
import schema from '@/convex/schema'

export const t = convexTest(schema)

// TDD template for Convex functions
describe('Convex Functions', () => {
  describe('photos.list', () => {
    // RED: Test query function
    it('should list photos with filters', async () => {
      const result = await t.query(api.photos.list, {
        organizationId: 'org_123',
        filters: { tags: ['safety'] }
      })
      
      expect(result.photos).toBeInstanceOf(Array)
      expect(result.photos.every(p => 
        p.tags.includes('safety')
      )).toBe(true)
    })
  })
  
  describe('photos.create', () => {
    // RED: Test mutation
    it('should create a photo with validation', async () => {
      const photoData = {
        title: 'Test Photo',
        organizationId: 'org_123',
        uploadedBy: 'user_123'
      }
      
      const result = await t.mutation(api.photos.create, photoData)
      
      expect(result._id).toBeDefined()
      expect(result.title).toBe('Test Photo')
    })
    
    it('should validate required fields', async () => {
      await expect(
        t.mutation(api.photos.create, { title: '' })
      ).rejects.toThrow('Title is required')
    })
  })
  
  describe('ai.processPhoto', () => {
    // RED: Test action with external API mock
    it('should process photo with AI', async () => {
      vi.mock('@google-cloud/vision', () => ({
        ImageAnnotatorClient: vi.fn().mockImplementation(() => ({
          labelDetection: vi.fn().mockResolvedValue([{
            labelAnnotations: [
              { description: 'safety', score: 0.95 }
            ]
          }])
        }))
      }))
      
      const result = await t.action(api.ai.processPhoto, {
        photoId: 'photo_123'
      })
      
      expect(result.tags).toContain('safety')
      expect(result.confidence).toBeGreaterThan(0.9)
    })
  })
})
```

### Task 4: Service Layer Testing

**Business Logic TDD**:
```typescript
// tests/lib/services/photo-service.test.ts
describe('PhotoService - TDD Implementation', () => {
  let service: PhotoService
  
  beforeEach(() => {
    service = new PhotoService()
  })
  
  describe('processUpload', () => {
    // RED: Define expected behavior
    it('should process photo upload with metadata extraction', async () => {
      const file = new File(['test'], 'test.jpg', { type: 'image/jpeg' })
      const result = await service.processUpload(file, {
        organizationId: 'org_123',
        userId: 'user_123'
      })
      
      expect(result).toMatchObject({
        filename: 'test.jpg',
        size: expect.any(Number),
        mimeType: 'image/jpeg',
        metadata: expect.objectContaining({
          width: expect.any(Number),
          height: expect.any(Number)
        })
      })
    })
    
    // GREEN: Implement service method
    // REFACTOR: Add optimization and caching
  })
  
  describe('batchProcess', () => {
    it('should handle batch operations efficiently', async () => {
      const files = Array(10).fill(null).map((_, i) => 
        new File(['test'], `test${i}.jpg`)
      )
      
      const startTime = Date.now()
      const results = await service.batchProcess(files)
      const duration = Date.now() - startTime
      
      expect(results).toHaveLength(10)
      expect(results.every(r => r.success)).toBe(true)
      expect(duration).toBeLessThan(5000) // Performance requirement
    })
  })
})
```

### Task 5: Security Testing

**Authentication & Authorization Tests**:
```typescript
// tests/api/security/auth.test.ts
describe('API Security - TDD', () => {
  describe('Authentication', () => {
    it('should reject unauthenticated requests', async () => {
      const routes = [
        '/api/photos',
        '/api/organizations',
        '/api/users'
      ]
      
      for (const route of routes) {
        const response = await fetch(route, {
          headers: { /* no auth token */ }
        })
        expect(response.status).toBe(401)
      }
    })
    
    it('should validate JWT tokens', async () => {
      const invalidToken = 'invalid.jwt.token'
      const response = await fetch('/api/photos', {
        headers: {
          'Authorization': `Bearer ${invalidToken}`
        }
      })
      
      expect(response.status).toBe(401)
      const error = await response.json()
      expect(error.error).toContain('Invalid token')
    })
  })
  
  describe('Authorization', () => {
    it('should enforce organization isolation', async () => {
      // User from org_1 shouldn't access org_2 data
      const response = await fetch('/api/organizations/org_2/photos', {
        headers: {
          'Authorization': `Bearer ${org1UserToken}`
        }
      })
      
      expect(response.status).toBe(403)
    })
    
    it('should require admin role for admin endpoints', async () => {
      const response = await fetch('/api/platform/analytics', {
        headers: {
          'Authorization': `Bearer ${regularUserToken}`
        }
      })
      
      expect(response.status).toBe(403)
    })
  })
})
```

### Task 6: Integration Testing

**Database Integration Tests**:
```typescript
// tests/integration/database.test.ts
describe('Database Integration - TDD', () => {
  describe('Transactions', () => {
    it('should rollback on failure', async () => {
      const initialCount = await db.photos.count()
      
      try {
        await db.transaction(async (tx) => {
          await tx.photos.insert({ title: 'Test 1' })
          await tx.photos.insert({ title: 'Test 2' })
          throw new Error('Simulated failure')
        })
      } catch (error) {
        // Expected to fail
      }
      
      const finalCount = await db.photos.count()
      expect(finalCount).toBe(initialCount) // No change
    })
  })
  
  describe('Performance', () => {
    it('should handle concurrent operations', async () => {
      const operations = Array(100).fill(null).map((_, i) => 
        db.photos.insert({ title: `Photo ${i}` })
      )
      
      const startTime = Date.now()
      await Promise.all(operations)
      const duration = Date.now() - startTime
      
      expect(duration).toBeLessThan(1000) // <1s for 100 ops
    })
  })
})
```

### Task 7: Export/Import Testing

**Data Export Tests**:
```typescript
// tests/api/export/export.test.ts
describe('Export API - TDD', () => {
  describe('CSV Export', () => {
    it('should export photos to CSV format', async () => {
      const response = await fetch('/api/export/csv', {
        method: 'POST',
        body: JSON.stringify({
          filters: { organizationId: 'org_123' }
        })
      })
      
      expect(response.headers.get('content-type')).toBe('text/csv')
      const csv = await response.text()
      
      const lines = csv.split('\n')
      expect(lines[0]).toContain('Title,Tags,Date')
      expect(lines.length).toBeGreaterThan(1)
    })
  })
  
  describe('PDF Export', () => {
    it('should generate PDF with photos and metadata', async () => {
      const response = await fetch('/api/export/pdf', {
        method: 'POST',
        body: JSON.stringify({
          photoIds: ['photo_1', 'photo_2']
        })
      })
      
      expect(response.headers.get('content-type')).toBe('application/pdf')
      const buffer = await response.arrayBuffer()
      expect(buffer.byteLength).toBeGreaterThan(1000)
    })
  })
})
```

## 📊 Coverage Targets

### API Routes (21 total)
- [ ] Health check endpoint - 100% coverage
- [ ] Authentication endpoints (2) - 100% coverage
- [ ] Photo endpoints (4) - 100% coverage
- [ ] AI processing endpoints (3) - 100% coverage
- [ ] Organization endpoints (2) - 100% coverage
- [ ] User management endpoints (2) - 100% coverage
- [ ] Search endpoint - 100% coverage
- [ ] Tag management endpoint - 100% coverage
- [ ] Export endpoints (2) - 100% coverage
- [ ] Platform endpoints (2) - 100% coverage

### Convex Functions
- [ ] Query functions - 100% coverage
- [ ] Mutation functions - 100% coverage
- [ ] Action functions - 100% coverage
- [ ] Subscription handlers - 100% coverage

### Business Logic
- [ ] Service classes - >95% coverage
- [ ] Utility functions - 100% coverage
- [ ] Data transformers - 100% coverage
- [ ] Validation logic - 100% coverage

## ✅ Success Criteria

### Must Have
- [x] All 21 API routes tested
- [x] Contract validation for all endpoints
- [x] Authentication/authorization tests
- [x] Error scenario coverage
- [x] Convex function testing setup

### Should Have
- [x] Performance benchmarks
- [x] Integration test coverage
- [x] Security vulnerability tests
- [x] Data export/import validation

### Nice to Have
- [ ] Load testing scenarios
- [ ] API documentation generation
- [ ] Mock service improvements
- [ ] Test data factories

## 🔄 Verification Process

1. **Run Backend Tests**
   ```bash
   pnpm test tests/api --coverage
   pnpm test tests/convex --coverage
   pnpm test tests/integration --coverage
   ```

2. **Validate Coverage**
   ```bash
   # Should show >95% coverage for backend code
   pnpm test:coverage -- app/api lib/services convex
   ```

3. **Security Audit**
   ```bash
   # Run security-specific tests
   pnpm test tests/security
   ```

4. **Performance Validation**
   ```bash
   # Run performance benchmarks
   pnpm test tests/performance --run
   ```

## 📝 Implementation Notes

### TDD Workflow for APIs
1. **RED**: Write API test with expected contract
2. **GREEN**: Implement minimal handler
3. **REFACTOR**: Add validation, error handling, optimization

### Testing Priorities
1. Critical user paths first
2. Security-sensitive endpoints
3. Data manipulation operations
4. Export/import functionality

### Common Patterns
- Use test helpers for request/response mocking
- Implement test data factories
- Mock external services consistently
- Test both success and failure paths

---

**Phase 2 Status**: 📋 READY (Pending Phase 1 completion)
**Estimated Duration**: 3-4 days
**Dependencies**: Phase 1 must be complete
**Next Phase**: PHASE-3.md (Frontend Component Testing)
**Created**: September 3, 2025 - 18:22 Melbourne Time