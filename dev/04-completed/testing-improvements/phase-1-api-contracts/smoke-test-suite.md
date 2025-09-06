# Smoke Test Suite Design
**Sub-30 Second Validation for AI Agent Feedback**

## Overview

The smoke test suite provides rapid validation of critical functionality, giving AI agents instant feedback on code changes. Target execution time: **<30 seconds total**.

## Test Execution Timeline

```
Total Budget: 30 seconds
├── Setup & Teardown: 2s
├── Auth Flow: 3s
├── Photo Upload: 5s
├── AI Processing: 8s
├── Search: 3s
├── Export: 5s
├── Cleanup: 2s
└── Buffer: 2s
```

## Implementation Structure

### Base Smoke Test Runner
```typescript
// tests/smoke/smoke-test-runner.ts
import { test as base } from '@playwright/test';
import type { Page } from '@playwright/test';

export class SmokeTestRunner {
  private baseURL: string;
  private apiClient: APIClient;
  private startTime: number;
  private timeLimit = 30000; // 30 seconds
  
  constructor() {
    this.baseURL = process.env.TEST_URL || 'http://localhost:3000';
    this.apiClient = new APIClient(this.baseURL);
    this.startTime = Date.now();
  }
  
  checkTimeLimit(operation: string) {
    const elapsed = Date.now() - this.startTime;
    if (elapsed > this.timeLimit) {
      throw new Error(`Smoke test timeout: ${operation} exceeded 30s limit`);
    }
    return this.timeLimit - elapsed;
  }
  
  async runParallel<T>(operations: Array<() => Promise<T>>): Promise<T[]> {
    // Run operations in parallel to save time
    return Promise.all(operations.map(op => op()));
  }
}
```

### Critical Path Tests

#### 1. Authentication Flow (3s)
```typescript
// tests/smoke/auth-smoke.test.ts
import { test, expect } from '@playwright/test';
import { SmokeTestRunner } from './smoke-test-runner';

test.describe('Auth Smoke Tests', () => {
  const smoke = new SmokeTestRunner();
  
  test('Complete auth flow in <3s', async () => {
    const startTime = Date.now();
    
    // Parallel operations
    const [session, profile, orgContext] = await smoke.runParallel([
      () => smoke.login('test@minerva.com', 'testpass'),
      () => smoke.getProfile(),
      () => smoke.getOrganizationContext(),
    ]);
    
    // Validations
    expect(session).toHaveProperty('token');
    expect(profile).toHaveProperty('organization_id');
    expect(orgContext).toHaveProperty('role');
    
    // Time check
    expect(Date.now() - startTime).toBeLessThan(3000);
  });
  
  test('Validate organization isolation', async () => {
    // Quick check that users can't access other org data
    const otherOrgData = await smoke.tryAccessOtherOrg();
    expect(otherOrgData).toBeNull();
  });
});
```

#### 2. Photo Upload Pipeline (5s)
```typescript
// tests/smoke/photo-smoke.test.ts
test.describe('Photo Upload Smoke Tests', () => {
  test('Upload and process photo in <5s', async ({ page }) => {
    const startTime = Date.now();
    
    // Use minimal test image (1x1 pixel)
    const testImage = Buffer.from(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      'base64'
    );
    
    // Upload
    const uploadResponse = await smoke.uploadPhoto(testImage, {
      filename: 'test.png',
      skipProcessing: false, // Process immediately
    });
    
    expect(uploadResponse).toHaveProperty('photo_id');
    expect(uploadResponse.status).toBe('processing');
    
    // Poll for completion (max 3s)
    const processed = await smoke.waitForProcessing(
      uploadResponse.photo_id,
      3000
    );
    
    expect(processed.ai_tags).toBeDefined();
    expect(Date.now() - startTime).toBeLessThan(5000);
  });
  
  test('Validate photo in organization context', async () => {
    const photos = await smoke.getPhotos();
    photos.forEach(photo => {
      expect(photo.organization_id).toBe(smoke.currentOrgId);
    });
  });
});
```

#### 3. AI Processing Validation (8s)
```typescript
// tests/smoke/ai-smoke.test.ts
test.describe('AI Processing Smoke Tests', () => {
  test('Process with dual providers in <8s', async () => {
    const startTime = Date.now();
    
    // Use cached test image for speed
    const testPhotoId = 'smoke-test-photo-001';
    
    // Trigger dual processing
    const aiResult = await smoke.processWithAI(testPhotoId, {
      providers: ['openai-gpt4-vision', 'google-vision'],
      priority: 'high',
    });
    
    // Validate both providers returned results
    expect(aiResult.providers).toHaveLength(2);
    expect(aiResult.consensus_tags).toBeDefined();
    
    // Check for expected tag categories
    const tagCategories = new Set(
      aiResult.consensus_tags.map(t => t.category)
    );
    expect(tagCategories).toContain('safety');
    
    expect(Date.now() - startTime).toBeLessThan(8000);
  });
  
  test('Validate AI error handling', async () => {
    // Test with invalid image
    const result = await smoke.processWithAI('invalid-id');
    expect(result.error).toBeDefined();
  });
});
```

#### 4. Search Functionality (3s)
```typescript
// tests/smoke/search-smoke.test.ts
test.describe('Search Smoke Tests', () => {
  test('Search returns results in <3s', async () => {
    const startTime = Date.now();
    
    // Test multiple search types in parallel
    const [textSearch, tagSearch, dateSearch] = await smoke.runParallel([
      () => smoke.search({ query: 'safety equipment' }),
      () => smoke.search({ tags: ['machine', 'hazard'] }),
      () => smoke.search({ dateFrom: '2025-01-01' }),
    ]);
    
    // Validate results
    expect(textSearch.photos).toBeDefined();
    expect(tagSearch.photos.length).toBeGreaterThan(0);
    expect(dateSearch.photos).toBeDefined();
    
    expect(Date.now() - startTime).toBeLessThan(3000);
  });
});
```

#### 5. Export Operations (5s)
```typescript
// tests/smoke/export-smoke.test.ts
test.describe('Export Smoke Tests', () => {
  test('Generate Word export in <5s', async () => {
    const startTime = Date.now();
    
    // Use minimal photo set
    const photoIds = ['test-1', 'test-2'];
    
    // Start export
    const exportJob = await smoke.exportToWord(photoIds, {
      template: 'safety-report',
      includeMetadata: true,
    });
    
    expect(exportJob).toHaveProperty('job_id');
    expect(exportJob.status).toBe('processing');
    
    // Poll for completion
    const completed = await smoke.waitForExport(exportJob.job_id, 4000);
    
    expect(completed.download_url).toBeDefined();
    expect(Date.now() - startTime).toBeLessThan(5000);
  });
});
```

### Optimization Techniques

#### 1. Parallel Execution
```typescript
// Run independent tests in parallel
test.describe.parallel('Smoke Tests', () => {
  test('Auth flow', async () => { /* ... */ });
  test('Search function', async () => { /* ... */ });
  test('Export check', async () => { /* ... */ });
});
```

#### 2. Test Data Caching
```typescript
// Cache frequently used test data
class TestDataCache {
  private static cache = new Map();
  
  static async getTestPhoto(): Promise<Photo> {
    if (!this.cache.has('test-photo')) {
      const photo = await createTestPhoto();
      this.cache.set('test-photo', photo);
    }
    return this.cache.get('test-photo');
  }
  
  static async getTestUser(): Promise<User> {
    if (!this.cache.has('test-user')) {
      const user = await createTestUser();
      this.cache.set('test-user', user);
    }
    return this.cache.get('test-user');
  }
}
```

#### 3. Connection Pooling
```typescript
// Reuse database connections
class DBPool {
  private static pool: Pool;
  
  static getConnection(): PoolClient {
    if (!this.pool) {
      this.pool = new Pool({
        max: 5,
        idleTimeoutMillis: 30000,
      });
    }
    return this.pool.connect();
  }
}
```

#### 4. Minimal Test Data
```typescript
// Use smallest possible test data
const MINIMAL_IMAGE = Buffer.from([
  0x89, 0x50, 0x4E, 0x47, // PNG signature
  // ... minimal valid PNG data (67 bytes total)
]);

const MINIMAL_DOCUMENT = {
  title: 'T',
  content: 'C',
  photos: ['p1'],
};
```

## Configuration

### Test Environment Setup
```typescript
// tests/smoke/setup.ts
import { config } from 'dotenv';

export async function setupSmokeTests() {
  // Load test environment
  config({ path: '.env.test' });
  
  // Set aggressive timeouts
  process.env.TEST_TIMEOUT = '1000'; // 1s default timeout
  process.env.PARALLEL_JOBS = '4';   // Run 4 tests in parallel
  
  // Disable unnecessary features
  process.env.DISABLE_ANALYTICS = 'true';
  process.env.DISABLE_LOGGING = 'true';
  process.env.USE_TEST_CACHE = 'true';
  
  // Use in-memory database for speed
  process.env.DATABASE_URL = 'sqlite::memory:';
}
```

### Package.json Scripts
```json
{
  "scripts": {
    "test:smoke": "playwright test tests/smoke --reporter=line --timeout=30000",
    "test:smoke:ci": "playwright test tests/smoke --reporter=json --timeout=30000",
    "test:smoke:watch": "playwright test tests/smoke --watch --timeout=30000",
    "test:smoke:debug": "playwright test tests/smoke --debug --timeout=60000"
  }
}
```

## Monitoring & Reporting

### Performance Tracking
```typescript
// tests/smoke/performance-reporter.ts
export class PerformanceReporter {
  private metrics: Map<string, number[]> = new Map();
  
  record(testName: string, duration: number) {
    if (!this.metrics.has(testName)) {
      this.metrics.set(testName, []);
    }
    this.metrics.get(testName)!.push(duration);
  }
  
  getReport() {
    const report: any = {};
    for (const [test, durations] of this.metrics) {
      report[test] = {
        avg: average(durations),
        min: Math.min(...durations),
        max: Math.max(...durations),
        p95: percentile(durations, 95),
      };
    }
    return report;
  }
  
  checkThresholds() {
    const failures = [];
    for (const [test, durations] of this.metrics) {
      const avg = average(durations);
      const threshold = THRESHOLDS[test] || 5000;
      if (avg > threshold) {
        failures.push(`${test}: ${avg}ms exceeds ${threshold}ms`);
      }
    }
    return failures;
  }
}

const THRESHOLDS = {
  'auth-flow': 3000,
  'photo-upload': 5000,
  'ai-processing': 8000,
  'search': 3000,
  'export': 5000,
};
```

### CI Integration
```yaml
# .github/workflows/smoke-tests.yml
name: Smoke Tests
on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  smoke:
    runs-on: ubuntu-latest
    timeout-minutes: 2
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci --production
      
      - name: Run smoke tests
        run: npm run test:smoke:ci
        env:
          TEST_TIMEOUT: 30000
          PARALLEL_JOBS: 4
      
      - name: Check performance
        run: |
          node -e "
            const results = require('./test-results.json');
            const totalTime = results.duration;
            if (totalTime > 30000) {
              console.error('Smoke tests exceeded 30s: ' + totalTime + 'ms');
              process.exit(1);
            }
          "
      
      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: smoke-test-results
          path: test-results.json
```

## Failure Handling

### Quick Recovery
```typescript
// Fail fast and provide clear feedback
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== 'passed') {
    // Take screenshot for debugging
    await page.screenshot({ 
      path: `smoke-failures/${testInfo.title}.png`,
      fullPage: false, // Save time
    });
    
    // Log minimal debug info
    console.error(`SMOKE TEST FAILED: ${testInfo.title}`);
    console.error(`Duration: ${testInfo.duration}ms`);
    
    // Skip remaining tests in suite
    test.skip();
  }
});
```

### Retry Strategy
```typescript
// Minimal retries for smoke tests
export const smokeConfig = {
  retries: 1, // One retry only
  timeout: 30000,
  fullyParallel: true,
  workers: 4,
  reporter: [
    ['line'], // Minimal output
    ['json', { outputFile: 'smoke-results.json' }],
  ],
};
```

## Success Metrics

### Target Performance
| Test Suite | Target Time | Actual Time | Status |
|------------|-------------|-------------|--------|
| Auth Flow | <3s | - | ⏳ |
| Photo Upload | <5s | - | ⏳ |
| AI Processing | <8s | - | ⏳ |
| Search | <3s | - | ⏳ |
| Export | <5s | - | ⏳ |
| **Total** | **<30s** | **-** | **⏳** |

### Coverage Goals
- ✅ Critical user paths covered
- ✅ Security validation included
- ✅ Organization context verified
- ✅ Error handling tested
- ✅ Performance monitored

## Maintenance Guidelines

1. **Keep tests focused** - Each test validates one critical path
2. **Optimize aggressively** - Every millisecond counts
3. **Parallelize when possible** - Use workers effectively
4. **Cache test data** - Reuse setup across tests
5. **Monitor trends** - Track performance over time
6. **Fail fast** - Stop on first critical failure

## AI Agent Integration

### Pre-commit Hook
```bash
#!/bin/bash
# .husky/pre-commit

echo "Running smoke tests..."
npm run test:smoke

if [ $? -ne 0 ]; then
  echo "❌ Smoke tests failed - commit blocked"
  echo "Run 'npm run test:smoke:debug' to investigate"
  exit 1
fi

echo "✅ Smoke tests passed in <30s"
```

### VSCode Integration
```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Smoke Tests",
      "type": "npm",
      "script": "test:smoke",
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      },
      "group": {
        "kind": "test",
        "isDefault": true
      }
    }
  ]
}
```

**Success Criteria**: Smoke tests provide <30 second validation of all critical paths, giving AI agents instant feedback on code changes without blocking development flow.