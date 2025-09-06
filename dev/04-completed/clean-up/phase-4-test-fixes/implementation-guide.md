# Phase 4: Test Fixes - Implementation Guide

**Objective**: Fix broken test files and ensure all tests pass  
**Priority**: HIGH - Essential for code quality assurance  
**Estimated Time**: 4-6 hours  
**Dependencies**: Phase 3 completed (all `any` types eliminated)

## Overview
Phase 4 addresses the remaining test-related issues after type safety improvements. This includes updating mock configurations, fixing test utilities, and ensuring all tests compile and execute successfully.

## Pre-Phase Checklist
- [ ] Phase 3 completed (zero `any` types remain)
- [ ] Project builds successfully with proper types
- [ ] Current test failure count recorded
- [ ] Test-related TypeScript errors identified

## Git Strategy - Commit Frequently
```bash
# Start of phase
git add . && git commit --no-verify -m "Phase 4 start: Before test fixes"

# After fixing each test suite
git add tests/[suite-name]/ && git commit --no-verify -m "Phase 4: Fix [suite-name] test suite"

# After major mock updates
git add . && git commit --no-verify -m "Phase 4: Update mock configurations for [component]"

# Progress checkpoints every 1-2 hours  
git add . && git commit --no-verify -m "Phase 4 checkpoint: [describe progress]"
```

## Test Error Categories

### Category 1: Mock Configuration Mismatches
**Issue**: Mocks don't match updated type signatures from Phase 3
```typescript
// ❌ Before - Mock doesn't match new typed API
const mockProcessAnalytics = vi.fn().mockResolvedValue({
  success: true,
  data: { accuracy: 95 } // Missing required properties
});

// ✅ After - Mock matches new AnalyticsResult interface  
const mockProcessAnalytics = vi.fn().mockResolvedValue({
  success: true,
  data: {
    accuracy: {
      overall: 95,
      byProvider: { 'openai': 96, 'anthropic': 94 },
      trend: 'improving'
    },
    performance: {
      totalJobs: 1000,
      successRate: 0.98,
      averageLatency: 1500,
      errorRate: 0.02,
      throughput: 45.5
    },
    costs: {
      total: 123.45,
      perJob: 0.12,
      byProvider: { 'openai': 80.00, 'anthropic': 43.45 }
    }
  }
} as AnalyticsResult);
```

### Category 2: Test Utility Updates
**Issue**: Test utilities using old interfaces
```typescript
// ❌ Before
function createMockAIJob(overrides: any = {}): any {
  return {
    id: 'test-123',
    status: 'completed',
    ...overrides
  };
}

// ✅ After
import { AIJobResult } from '@/lib/types/ai';

function createMockAIJob(overrides: Partial<AIJobResult> = {}): AIJobResult {
  return {
    jobId: 'test-123',
    status: 'completed',
    result: {
      tags: ['safety-equipment', 'hard-hat'],
      confidence: 0.95,
      processingTime: 1200,
      model: 'vision-v1',
      provider: 'openai'
    },
    metadata: {
      startedAt: '2024-01-01T10:00:00Z',
      completedAt: '2024-01-01T10:00:01Z',
      retryCount: 0
    },
    ...overrides
  };
}
```

### Category 3: Test Assertions Updates
**Issue**: Assertions expecting old data structures
```typescript
// ❌ Before
expect(result.data.accuracy).toBe(95);

// ✅ After - Match new interface structure
expect(result.data.accuracy.overall).toBe(95);
expect(result.data.accuracy.trend).toBe('improving');
expect(result.data.performance.successRate).toBe(0.98);
```

## Implementation Steps by Test Directory

### Step 1: Update Mock Factories
```bash
cd C:\Users\Tom\dev\minerva

# Identify test factory files
find . -name "*factory*" -o -name "*mock*" -type f | grep -E "\.(ts|js)$"

# Common locations:
# tests/factories/
# tests/mocks/
# __tests__/utils/
# tests/test-utilities.ts
```

#### Factory Update Process
```typescript
// File: tests/factories/ai-job-factory.ts
// Before: Using any types
export const createMockAIJob = (overrides: any = {}) => ({
  id: faker.datatype.uuid(),
  status: 'completed',
  result: { tags: ['test'] },
  ...overrides
});

// After: Using proper types from Phase 3
import { AIJobResult } from '@/lib/types/ai';

export const createMockAIJob = (overrides: Partial<AIJobResult> = {}): AIJobResult => ({
  jobId: faker.datatype.uuid(),
  status: 'completed',
  result: {
    tags: ['safety-equipment'],
    confidence: 0.95,
    processingTime: 1200,
    model: 'vision-v1',
    provider: 'openai'
  },
  metadata: {
    startedAt: faker.date.past().toISOString(),
    completedAt: faker.date.recent().toISOString(), 
    retryCount: 0
  },
  ...overrides
});

# Commit after each factory file
git add tests/factories/ai-job-factory.ts
git commit --no-verify -m "Phase 4: Update AI job factory with proper types"
```

### Step 2: Fix Supabase Mock Configurations
```typescript
// File: tests/mocks/supabase.ts
// Before: Generic any mocks
export const mockSupabase = {
  from: vi.fn(() => ({
    select: vi.fn().mockResolvedValue({ data: [], error: null }),
    insert: vi.fn().mockResolvedValue({ data: {}, error: null }),
    update: vi.fn().mockResolvedValue({ data: {}, error: null })
  }))
};

// After: Typed mocks matching database schema
import { Database } from '@/lib/database.types';

type AIJob = Database['public']['Tables']['ai_processing_jobs']['Row'];

export const mockSupabase = {
  from: vi.fn((table: string) => {
    const mockData: Record<string, unknown[]> = {
      'ai_processing_jobs': [
        {
          id: 'job-123',
          status: 'completed',
          photo_id: 'photo-456',
          provider: 'openai',
          model: 'vision-v1',
          tags: ['hard-hat', 'safety-vest'],
          confidence: 0.95,
          processing_time_ms: 1200,
          created_at: '2024-01-01T10:00:00Z',
          completed_at: '2024-01-01T10:00:01Z'
        } as AIJob
      ]
    };

    return {
      select: vi.fn().mockResolvedValue({ 
        data: mockData[table] || [], 
        error: null 
      }),
      insert: vi.fn().mockResolvedValue({ 
        data: mockData[table]?.[0] || {}, 
        error: null 
      }),
      update: vi.fn().mockResolvedValue({ 
        data: mockData[table]?.[0] || {}, 
        error: null 
      }),
      eq: vi.fn().mockReturnThis(),
      single: vi.fn().mockResolvedValue({ 
        data: mockData[table]?.[0] || null, 
        error: null 
      })
    };
  })
};
```

### Step 3: Update API Route Tests
```bash
# Find API route test files
find . -path "*/api/*" -name "*.test.ts" | head -10

# Common issues and fixes:
```

```typescript
// File: tests/api/ai/analytics/accuracy-trends.test.ts
// Before: Testing with old response format
it('should return accuracy trends', async () => {
  const response = await GET(mockRequest);
  const data = await response.json();
  
  expect(data.accuracy).toBe(95); // Old flat structure
});

// After: Testing with new typed response format
it('should return accuracy trends', async () => {
  const response = await GET(mockRequest);
  const data = await response.json();
  
  expect(data.success).toBe(true);
  expect(data.data.accuracy.overall).toBe(95);
  expect(data.data.accuracy.byProvider).toEqual({
    'openai': 96,
    'anthropic': 94
  });
  expect(data.data.accuracy.trend).toBe('improving');
});

# Commit after each API test file
git add tests/api/ai/analytics/accuracy-trends.test.ts
git commit --no-verify -m "Phase 4: Update accuracy trends API tests"
```

### Step 4: Fix Component Tests
```bash
# Find component test files that might be affected
find . -name "*.test.tsx" | grep -v node_modules
```

```typescript
// File: tests/components/analytics/metrics-dashboard.test.tsx
// Before: Component tests with old prop types
const mockMetrics: any = {
  accuracy: 95,
  processingTime: 1200
};

// After: Component tests with proper types
const mockMetrics: AnalyticsResult = {
  accuracy: {
    overall: 95,
    byProvider: { 'openai': 96 },
    trend: 'improving'
  },
  performance: {
    totalJobs: 1000,
    successRate: 0.98,
    averageLatency: 1200,
    errorRate: 0.02,
    throughput: 45.5
  },
  costs: {
    total: 123.45,
    perJob: 0.12,
    byProvider: { 'openai': 123.45 }
  }
};
```

## Test Execution Validation

### Step-by-Step Test Running
```bash
# 1. First, check that tests compile
npx tsc --noEmit tests/**/*.ts __tests__/**/*.ts

# 2. Run tests by category to isolate issues
npm run test:unit -- --testPathPattern=ai/analytics
npm run test:unit -- --testPathPattern=platform
npm run test:unit -- --testPathPattern=components

# 3. Run all tests
npm run test

# 4. Check coverage if available
npm run test:coverage
```

### Fix Test Failures Systematically
```bash
# For each failing test file:

# 1. Run specific test file
npm run test -- analytics/accuracy-trends.test.ts

# 2. Fix issues found
# 3. Commit fix
git add tests/api/ai/analytics/accuracy-trends.test.ts
git commit --no-verify -m "Phase 4: Fix accuracy trends test failures"

# 4. Re-run to confirm
npm run test -- analytics/accuracy-trends.test.ts
```

## Common Test Issues and Solutions

### Issue 1: Mock Return Type Mismatches
```typescript
// Problem: Mock returns don't match new function signatures
const mockFunction = vi.fn().mockResolvedValue({ data: [] });

// Solution: Match exact return type
const mockFunction = vi.fn().mockResolvedValue({
  success: true,
  data: [],
  metadata: { count: 0 }
} as ApiResponse<YourType[]>);
```

### Issue 2: Test Helper Functions
```typescript
// Problem: Test helpers need type updates
const createTestData = (count: number): any[] => { };

// Solution: Properly type test helpers
const createTestData = (count: number): AIJobResult[] => {
  return Array.from({ length: count }, (_, i) => createMockAIJob({
    jobId: `test-job-${i}`,
    status: 'completed'
  }));
};
```

### Issue 3: Assertion Updates
```typescript
// Problem: Assertions checking old structure
expect(result.data).toHaveLength(5);
expect(result.data[0].accuracy).toBe(95);

// Solution: Update to match new structure
expect(result.data).toHaveLength(5);
expect(result.data[0].accuracy.overall).toBe(95);
expect(result.data[0].accuracy.trend).toBe('improving');
```

## Progress Tracking

### Test Suite Completion Checklist
For each test suite:
- [ ] All mocks updated with proper types
- [ ] Test assertions match new data structures
- [ ] Test utilities use correct interfaces
- [ ] All tests in suite pass
- [ ] Changes committed

### Major Test Categories
- [ ] API Route Tests (`tests/api/`)
- [ ] Component Tests (`tests/components/`) 
- [ ] Service Tests (`tests/services/`)
- [ ] Integration Tests (`tests/integration/`)
- [ ] E2E Tests (if affected by API changes)

### Validation Commands
```bash
# All tests must pass
npm run test

# Type checking must succeed
npx tsc --noEmit tests/**/*.ts __tests__/**/*.ts

# Coverage should not significantly decrease
npm run test:coverage
```

## Success Criteria

### Phase 4 Complete When:
- [ ] All test files compile without TypeScript errors
- [ ] All unit tests pass: `npm run test`
- [ ] Integration tests pass (if applicable)
- [ ] Test coverage maintained or improved
- [ ] Mock configurations match new type signatures
- [ ] Test utilities properly typed

### Quality Metrics
- **Test Pass Rate**: 100% of tests passing
- **Type Safety**: All test code properly typed
- **Mock Accuracy**: Mocks match actual API signatures
- **Maintainability**: Test code follows same type safety standards

## Final Validation
```bash
# Complete test suite validation
npm run test:all

# Type safety check
npx tsc --noEmit --skipLibCheck

# Build verification (should still work)
npm run build

# Commit completion
git add .
git commit --no-verify -m "Phase 4 COMPLETE: All tests fixed and passing"
```

**Phase 4 Complete When**: All tests pass, proper type safety maintained throughout test code, and no test-related TypeScript errors remain.