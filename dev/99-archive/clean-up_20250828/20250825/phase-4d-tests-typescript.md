# Phase 4D: Test Files TypeScript Cleanup
## August 25, 2025

### 🎯 Phase Objective
Fix all TypeScript errors in test files, mocks, and test utilities (~300 errors)

### 📊 Target Files & Error Distribution

#### Test Categories
| Category | Estimated Errors | Priority |
|----------|-----------------|----------|
| tests/components/* | ~60 | HIGH |
| tests/api-contracts/* | ~50 | HIGH |
| tests/services/* | ~40 | MEDIUM |
| tests/performance/* | ~40 | MEDIUM |
| tests/accessibility/* | ~30 | LOW |
| tests/platform/* | ~30 | LOW |
| tests/ai-management/* | ~30 | LOW |
| tests/utils & mocks | ~20 | LOW |

#### Common Error Patterns
1. **Mock Type Issues**
   - vi.Mock type mismatches
   - Mock return values
   - Spy type issues

2. **Assertion Types**
   - expect() type inference
   - Custom matchers
   - Async assertions

3. **Test Data Types**
   - Factory functions
   - Test fixtures
   - Sample data

4. **Component Testing**
   - render() return types
   - Query selectors
   - Event simulation

5. **API Testing**
   - Response mocks
   - Request types
   - Error scenarios

## 🔧 Implementation Strategy

### Step 1: Mock Definitions (45 minutes)
```typescript
// Properly type mocks
import { vi, MockedFunction } from 'vitest';

const mockSupabase = {
  from: vi.fn(() => ({
    select: vi.fn(() => ({
      eq: vi.fn(() => ({
        single: vi.fn(() => Promise.resolve({ data: null, error: null }))
      }))
    }))
  }))
} as unknown as SupabaseClient;

// Or use proper mock types
const mockFn: MockedFunction<typeof originalFn> = vi.fn();
```

### Step 2: Test Fixtures (45 minutes)
```typescript
// Type test data factories
function createMockPhoto(overrides?: Partial<Photo>): Photo {
  return {
    id: 'photo-1',
    url: 'https://example.com/photo.jpg',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    originalFilename: 'photo.jpg',
    createdAt: new Date().toISOString(),
    ...overrides
  };
}

// Type test fixtures
const testUser: User = {
  id: 'user-1',
  email: 'test@example.com',
  role: 'user'
};
```

### Step 3: Component Tests (1 hour)
```typescript
// Fix render and query types
import { render, screen, RenderResult } from '@testing-library/react';

describe('PhotoGrid', () => {
  let component: RenderResult;

  beforeEach(() => {
    component = render(<PhotoGrid photos={mockPhotos} />);
  });

  it('displays photos', () => {
    const photos = screen.getAllByTestId('photo-item');
    expect(photos).toHaveLength(mockPhotos.length);
  });
});
```

### Step 4: API Contract Tests (45 minutes)
```typescript
// Type API test helpers
async function testAPIEndpoint<T>(
  endpoint: string,
  options: RequestInit
): Promise<{ status: number; data: T }> {
  const response = await fetch(endpoint, options);
  const data = await response.json();
  return { status: response.status, data };
}
```

## 📋 Common Solutions

### Solution 1: Mock Types
```typescript
// Use vi.mocked for auto-typing
import { vi, Mocked } from 'vitest';
vi.mock('@/lib/supabase-client');

const mockedSupabase = vi.mocked(supabaseClient);
```

### Solution 2: Assertion Helpers
```typescript
// Type custom matchers
expect.extend({
  toBeValidPhoto(received: unknown): { pass: boolean; message: () => string } {
    const isValid = isPhoto(received);
    return {
      pass: isValid,
      message: () => isValid ? 'Valid photo' : 'Invalid photo'
    };
  }
});
```

### Solution 3: Async Testing
```typescript
// Proper async test typing
it('loads data', async () => {
  const data = await fetchData();
  expect(data).toBeDefined();
  expect(data.items).toHaveLength(10);
});
```

### Solution 4: Test Utils
```typescript
// Type test utilities
export async function waitForElement(
  testId: string,
  timeout = 1000
): Promise<HTMLElement> {
  return waitFor(() => screen.getByTestId(testId), { timeout });
}
```

## 🎯 Success Metrics

- **TypeScript Errors**: Reduce by ~300
- **Test Files Fixed**: All test files
- **Mocks Typed**: All properly typed
- **No Test Failures**: Tests still pass

## 📈 Expected Outcome

After Phase 4D:
- All test files fully typed
- Mocks have proper types
- Test utilities typed
- ~50 errors remaining

---

*Phase 4D: Test Files*
*Estimated Duration: 2-3 hours*
*Target Reduction: ~300 TypeScript errors*