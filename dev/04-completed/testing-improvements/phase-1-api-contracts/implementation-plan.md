# Phase 1: API Contract Testing Implementation
**Week 1 - Critical Foundation**

*Duration: 5 days*  
*Coverage Target: 100% API routes (222 endpoints)*  
*Execution Time: <30s smoke tests*

---

## Overview

API contract testing provides the foundation for AI agent confidence. With 222 API routes currently having only 36% test coverage, AI agents are making changes blindly. This phase establishes comprehensive contract validation and instant feedback loops.

## Day-by-Day Implementation

### Day 1: Test Infrastructure Setup
**Time: 4 hours**

#### 1. Create Test Structure
```bash
mkdir -p tests/api-contracts/{auth,photos,ai,platform,admin,monitoring,export}
mkdir -p tests/smoke
mkdir -p tests/fixtures/api-responses
```

#### 2. Install Dependencies
```bash
npm install -D zod @anatine/zod-openapi supertest msw @types/supertest
```

#### 3. Create Base Test Utilities
```typescript
// tests/api-contracts/test-utils.ts
import { z } from 'zod';
import request from 'supertest';

export class APIContractTester {
  private baseURL: string;
  
  constructor(baseURL = 'http://localhost:3000') {
    this.baseURL = baseURL;
  }
  
  async testEndpoint(config: {
    method: 'GET' | 'POST' | 'PUT' | 'DELETE';
    path: string;
    auth?: boolean;
    body?: any;
    query?: any;
    expectedStatus: number;
    responseSchema: z.ZodSchema;
    errorCases?: Array<{
      name: string;
      setup: () => any;
      expectedError: string;
    }>;
  }) {
    // Test success case
    const response = await this.makeRequest(config);
    
    // Validate response schema
    const validation = config.responseSchema.safeParse(response.body);
    if (!validation.success) {
      throw new Error(`Schema validation failed: ${validation.error.message}`);
    }
    
    // Test error cases
    if (config.errorCases) {
      for (const errorCase of config.errorCases) {
        await this.testErrorCase(config, errorCase);
      }
    }
    
    return validation.data;
  }
  
  private async makeRequest(config: any) {
    const req = request(this.baseURL)[config.method.toLowerCase()](config.path);
    
    if (config.auth) {
      req.set('Authorization', 'Bearer test-token');
    }
    
    if (config.body) {
      req.send(config.body);
    }
    
    if (config.query) {
      req.query(config.query);
    }
    
    return req.expect(config.expectedStatus);
  }
}
```

### Day 2: Security & Auth Endpoints
**Time: 4 hours**  
**Priority: CRITICAL (Phase 1 MVP requirement)**

#### Target Endpoints (15 total)
```typescript
// tests/api-contracts/auth/auth-contracts.test.ts
import { describe, it, expect } from 'vitest';
import { z } from 'zod';
import { APIContractTester } from '../test-utils';

const tester = new APIContractTester();

// Response Schemas
const SessionSchema = z.object({
  user: z.object({
    id: z.string().uuid(),
    email: z.string().email(),
    role: z.enum(['admin', 'engineer', 'viewer']),
    organization_id: z.string().uuid(),
  }),
  expires_at: z.string().datetime(),
});

const ProfileSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  full_name: z.string().optional(),
  avatar_url: z.string().url().optional(),
  organization: z.object({
    id: z.string().uuid(),
    name: z.string(),
    role: z.string(),
  }),
});

describe('Auth API Contracts', () => {
  describe('POST /api/auth/session/refresh', () => {
    it('should refresh session with valid token', async () => {
      await tester.testEndpoint({
        method: 'POST',
        path: '/api/auth/session/refresh',
        auth: true,
        expectedStatus: 200,
        responseSchema: SessionSchema,
        errorCases: [
          {
            name: 'expired token',
            setup: () => ({ token: 'expired-token' }),
            expectedError: 'Token expired',
          },
          {
            name: 'invalid token',
            setup: () => ({ token: 'invalid' }),
            expectedError: 'Invalid token',
          },
        ],
      });
    });
  });
  
  describe('GET /api/auth/profile', () => {
    it('should return user profile with organization context', async () => {
      await tester.testEndpoint({
        method: 'GET',
        path: '/api/auth/profile',
        auth: true,
        expectedStatus: 200,
        responseSchema: ProfileSchema,
      });
    });
  });
  
  describe('POST /api/auth/session/invalidate', () => {
    it('should invalidate current session', async () => {
      await tester.testEndpoint({
        method: 'POST',
        path: '/api/auth/session/invalidate',
        auth: true,
        expectedStatus: 204,
        responseSchema: z.void(),
      });
    });
  });
});
```

#### Security Validation Tests
```typescript
// tests/api-contracts/auth/security-contracts.test.ts
describe('Security Contract Validation', () => {
  it('should require authentication for protected endpoints', async () => {
    const protectedEndpoints = [
      '/api/photos',
      '/api/admin/users',
      '/api/platform/organizations',
      '/api/ai/process',
    ];
    
    for (const endpoint of protectedEndpoints) {
      const response = await request(baseURL)
        .get(endpoint)
        .expect(401);
      
      expect(response.body).toHaveProperty('error', 'Unauthorized');
    }
  });
  
  it('should validate organization context', async () => {
    // Test that all organization-scoped endpoints validate org context
    const response = await tester.testEndpoint({
      method: 'GET',
      path: '/api/photos',
      auth: true,
      expectedStatus: 200,
      responseSchema: z.object({
        photos: z.array(z.object({
          organization_id: z.string().uuid(),
        })),
      }),
    });
    
    // Verify all photos belong to user's organization
    response.photos.forEach(photo => {
      expect(photo.organization_id).toBe(userOrgId);
    });
  });
});
```

### Day 3: Photo & AI Endpoints
**Time: 5 hours**  
**Target: 80 endpoints**

#### Photo Management Contracts
```typescript
// tests/api-contracts/photos/photo-contracts.test.ts
const PhotoSchema = z.object({
  id: z.string().uuid(),
  url: z.string().url(),
  thumbnail_url: z.string().url().optional(),
  title: z.string(),
  description: z.string().optional(),
  tags: z.array(z.string()),
  ai_tags: z.array(z.object({
    name: z.string(),
    confidence: z.number().min(0).max(1),
    category: z.string(),
  })),
  metadata: z.object({
    width: z.number(),
    height: z.number(),
    size: z.number(),
    mime_type: z.string(),
  }),
  created_at: z.string().datetime(),
  organization_id: z.string().uuid(),
});

describe('Photo API Contracts', () => {
  describe('GET /api/photos', () => {
    it('should return paginated photos with filters', async () => {
      await tester.testEndpoint({
        method: 'GET',
        path: '/api/photos',
        auth: true,
        query: {
          page: 1,
          limit: 20,
          tags: ['safety', 'machine'],
          date_from: '2025-01-01',
        },
        expectedStatus: 200,
        responseSchema: z.object({
          photos: z.array(PhotoSchema),
          pagination: z.object({
            page: z.number(),
            limit: z.number(),
            total: z.number(),
            total_pages: z.number(),
          }),
        }),
      });
    });
  });
  
  describe('POST /api/photos/bulk-download', () => {
    it('should validate bulk download request', async () => {
      await tester.testEndpoint({
        method: 'POST',
        path: '/api/photos/bulk-download',
        auth: true,
        body: {
          photo_ids: ['id1', 'id2', 'id3'],
          format: 'zip',
        },
        expectedStatus: 200,
        responseSchema: z.object({
          download_url: z.string().url(),
          expires_at: z.string().datetime(),
          size_bytes: z.number(),
        }),
      });
    });
  });
});
```

#### AI Processing Contracts
```typescript
// tests/api-contracts/ai/ai-contracts.test.ts
describe('AI API Contracts', () => {
  describe('POST /api/ai/process-dual', () => {
    it('should process photo with dual AI providers', async () => {
      await tester.testEndpoint({
        method: 'POST',
        path: '/api/ai/process-dual',
        auth: true,
        body: {
          photo_url: 'https://example.com/photo.jpg',
          providers: ['openai', 'google-vision'],
        },
        expectedStatus: 200,
        responseSchema: z.object({
          results: z.array(z.object({
            provider: z.string(),
            tags: z.array(z.object({
              name: z.string(),
              confidence: z.number(),
              category: z.string(),
            })),
            processing_time_ms: z.number(),
            cost: z.number(),
          })),
          consensus_tags: z.array(z.string()),
        }),
      });
    });
  });
});
```

### Day 4: Platform & Admin Endpoints
**Time: 4 hours**  
**Target: 70 endpoints**

```typescript
// tests/api-contracts/platform/platform-contracts.test.ts
describe('Platform API Contracts', () => {
  describe('GET /api/platform/ai-management/overview', () => {
    it('should return AI management overview', async () => {
      await tester.testEndpoint({
        method: 'GET',
        path: '/api/platform/ai-management/overview',
        auth: true,
        expectedStatus: 200,
        responseSchema: z.object({
          providers: z.array(z.object({
            id: z.string(),
            name: z.string(),
            status: z.enum(['active', 'inactive', 'error']),
            usage: z.object({
              requests_today: z.number(),
              cost_today: z.number(),
              success_rate: z.number(),
            }),
          })),
          total_cost_mtd: z.number(),
          total_requests_mtd: z.number(),
          active_experiments: z.number(),
        }),
      });
    });
  });
  
  describe('POST /api/platform/tags/bulk', () => {
    it('should handle bulk tag operations', async () => {
      await tester.testEndpoint({
        method: 'POST',
        path: '/api/platform/tags/bulk',
        auth: true,
        body: {
          operation: 'merge',
          source_tags: ['old-tag-1', 'old-tag-2'],
          target_tag: 'new-tag',
        },
        expectedStatus: 200,
        responseSchema: z.object({
          affected_photos: z.number(),
          merged_tags: z.array(z.string()),
        }),
      });
    });
  });
});
```

### Day 5: Smoke Test Suite
**Time: 3 hours**  
**Target: <30 second execution**

```typescript
// tests/smoke/critical-paths.test.ts
import { describe, it, expect, beforeAll } from 'vitest';
import { SmokeTestRunner } from './smoke-test-runner';

const smoke = new SmokeTestRunner();

describe('Smoke Test Suite - Critical Paths', () => {
  beforeAll(async () => {
    await smoke.setup();
  });
  
  it('should complete authentication flow', async () => {
    const start = Date.now();
    
    // Login
    const session = await smoke.login('test@example.com', 'password');
    expect(session).toHaveProperty('token');
    
    // Get profile
    const profile = await smoke.getProfile(session.token);
    expect(profile).toHaveProperty('organization_id');
    
    // Verify org context
    expect(profile.organization_id).toBeTruthy();
    
    expect(Date.now() - start).toBeLessThan(1000); // <1s
  });
  
  it('should complete photo upload workflow', async () => {
    const start = Date.now();
    
    // Upload photo
    const photo = await smoke.uploadPhoto('./test-photo.jpg');
    expect(photo).toHaveProperty('id');
    
    // Trigger AI processing
    const aiResult = await smoke.processWithAI(photo.id);
    expect(aiResult).toHaveProperty('tags');
    
    // Verify tags applied
    const updatedPhoto = await smoke.getPhoto(photo.id);
    expect(updatedPhoto.ai_tags).toHaveLength(aiResult.tags.length);
    
    expect(Date.now() - start).toBeLessThan(5000); // <5s
  });
  
  it('should validate organization isolation', async () => {
    // Login as user from different org
    const otherSession = await smoke.login('other@example.com', 'password');
    
    // Try to access photos from first org
    const response = await smoke.getPhotos(otherSession.token, {
      organization_id: 'first-org-id',
    });
    
    // Should return empty or error
    expect(response.photos).toHaveLength(0);
  });
  
  it('should handle search functionality', async () => {
    const results = await smoke.search('safety equipment');
    expect(results).toHaveProperty('photos');
    expect(results.photos.length).toBeGreaterThan(0);
  });
  
  it('should export Word document', async () => {
    const exportJob = await smoke.exportToWord(['photo1', 'photo2']);
    expect(exportJob).toHaveProperty('download_url');
  });
});
```

## Implementation Checklist

### Infrastructure Setup ✓
- [ ] Create test directory structure
- [ ] Install testing dependencies
- [ ] Set up base test utilities
- [ ] Configure test database

### Contract Tests by Category
- [ ] **Auth & Security** (15 endpoints)
  - [ ] Session management
  - [ ] Profile endpoints
  - [ ] CSRF protection
  - [ ] Organization context validation
  
- [ ] **Photos** (30 endpoints)
  - [ ] CRUD operations
  - [ ] Bulk operations
  - [ ] Download/export
  - [ ] Search & filtering
  
- [ ] **AI Processing** (40 endpoints)
  - [ ] Process endpoints
  - [ ] Provider management
  - [ ] Prompt management
  - [ ] Analytics & monitoring
  
- [ ] **Platform** (50 endpoints)
  - [ ] Tag management
  - [ ] Organization management
  - [ ] User management
  - [ ] Feedback system
  
- [ ] **Admin** (25 endpoints)
  - [ ] User administration
  - [ ] Cost monitoring
  - [ ] Performance metrics
  - [ ] System configuration
  
- [ ] **Export** (12 endpoints)
  - [ ] Word export
  - [ ] ZIP generation
  - [ ] Analytics export
  - [ ] Batch operations
  
- [ ] **Monitoring** (20 endpoints)
  - [ ] Health checks
  - [ ] Performance metrics
  - [ ] Cost tracking
  - [ ] Error reporting
  
- [ ] **Dashboard** (30 endpoints)
  - [ ] Activity feed
  - [ ] Metrics aggregation
  - [ ] Real-time updates
  - [ ] Analytics

### Smoke Test Suite
- [ ] Authentication flow (<1s)
- [ ] Photo upload workflow (<5s)
- [ ] AI processing pipeline (<3s)
- [ ] Search functionality (<2s)
- [ ] Export operations (<5s)
- [ ] Organization switching (<1s)
- [ ] Total execution time <30s

## Test Execution Commands

```bash
# Run all API contract tests
npm run test:api-contracts

# Run specific category
npm run test:api-contracts -- --grep "Auth"

# Run smoke tests only
npm run test:smoke

# Run with coverage report
npm run test:api-contracts -- --coverage

# Watch mode for development
npm run test:api-contracts -- --watch
```

## Integration with AI Agents

### Pre-commit Hook
```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "npm run test:smoke && npm run lint"
    }
  }
}
```

### GitHub Actions
```yaml
# .github/workflows/api-contracts.yml
name: API Contract Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: npm ci
      - run: npm run test:api-contracts
      - run: npm run test:smoke
```

## Success Metrics

### Day 1 Complete
- [ ] Test infrastructure operational
- [ ] Base utilities created
- [ ] Dependencies installed

### Day 2 Complete
- [ ] All auth endpoints tested
- [ ] Security validation active
- [ ] Organization context verified

### Day 3 Complete
- [ ] Photo endpoints covered
- [ ] AI processing validated
- [ ] Error cases tested

### Day 4 Complete
- [ ] Platform APIs tested
- [ ] Admin endpoints covered
- [ ] Export functionality validated

### Day 5 Complete
- [ ] Smoke tests <30s
- [ ] Critical paths automated
- [ ] CI/CD integrated

## Common Patterns & Templates

### Standard Contract Test Template
```typescript
describe('[Category] API Contracts', () => {
  describe('[METHOD] /api/[path]', () => {
    it('should [expected behavior]', async () => {
      await tester.testEndpoint({
        method: 'METHOD',
        path: '/api/path',
        auth: true,
        body: validBody,
        expectedStatus: 200,
        responseSchema: ResponseSchema,
        errorCases: [
          // List error scenarios
        ],
      });
    });
  });
});
```

### Schema Definition Template
```typescript
const EntitySchema = z.object({
  id: z.string().uuid(),
  // Required fields
  name: z.string().min(1).max(255),
  
  // Optional fields
  description: z.string().optional(),
  
  // Nested objects
  metadata: z.object({
    created_by: z.string().uuid(),
    created_at: z.string().datetime(),
  }),
  
  // Arrays
  tags: z.array(z.string()),
  
  // Enums
  status: z.enum(['active', 'inactive', 'pending']),
  
  // Numbers with constraints
  priority: z.number().int().min(0).max(10),
});
```

## Troubleshooting

### Common Issues

1. **Test Timeout**: Increase timeout for slow endpoints
```typescript
it('should process large dataset', async () => {
  await tester.testEndpoint({...});
}, { timeout: 10000 }); // 10s timeout
```

2. **Schema Mismatch**: Update schemas to match actual responses
```typescript
// Use .passthrough() for unknown fields
const FlexibleSchema = BaseSchema.passthrough();
```

3. **Auth Issues**: Ensure test tokens are properly configured
```typescript
beforeAll(async () => {
  process.env.TEST_AUTH_TOKEN = await generateTestToken();
});
```

## Next Steps

After completing Phase 1:
1. Review coverage report: `npm run test:coverage`
2. Address any gaps in critical endpoints
3. Proceed to Phase 2: Component Coverage
4. Maintain <30s smoke test execution time

**Success Criteria**: 100% API contract coverage with <30s smoke tests provides instant feedback for AI agents on every code change.