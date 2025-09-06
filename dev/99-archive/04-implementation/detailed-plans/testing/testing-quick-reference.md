# Minerva Testing Quick Reference Guide
**Last Updated**: January 30, 2025  
**Target Audience**: Developers, QA Engineers, Contributors

---

## 🚀 Essential Commands

### Development Testing
```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run with coverage report
npm run test:coverage

# Run specific test file
npm test photo-grid.test.tsx

# Run tests matching pattern
npm test -- --grep "PhotoGrid"
```

### E2E Testing
```bash
# Run all E2E tests
npm run test:e2e

# Run E2E with UI (debug mode)
npm run test:e2e:ui

# Run E2E tests headed (visible browser)
npm run test:e2e:headed

# Run specific E2E test
npx playwright test auth.spec.ts
```

### Specialized Test Suites
```bash
# Accessibility tests
npm run test:a11y
npm run test:a11y:watch
npm run test:a11y:coverage

# AI Management tests
npm run test:ai-management
npm run test:ai-management:coverage

# Performance tests
npm run test:performance

# Security tests
npm run test:security

# Component-specific tests
npm run test:components
npm run test:api
```

### Clean Output Testing
```bash
# Clean summary output
npm run test:clean

# Clean output with logging
npm run test:clean:log

# Clean E2E with logging
npm run test:clean:e2e

# Verbose clean output
npm run test:clean:verbose
```

---

## 📊 Coverage Targets & Thresholds

### Current Thresholds (vitest.config.ts)
```typescript
coverage: {
  thresholds: {
    global: {
      statements: 80,
      branches: 80,
      functions: 80,
      lines: 80,
    },
  },
}
```

### Target Coverage Goals
- **Overall**: 90%+
- **API Routes**: 95%+
- **Components**: 90%+
- **Critical Business Logic**: 95%+
- **Utilities**: 85%+

### Coverage Commands
```bash
# Generate coverage report
npm run test:coverage

# Coverage with logging
npm run test:coverage:log

# CI coverage report
npm run test:ci
```

---

## 🏗️ Test File Structure

### Naming Conventions
```
Component Tests:     ComponentName.test.tsx
Hook Tests:          useHookName.test.ts
Utility Tests:       utilityName.test.ts
API Route Tests:     route-name.test.ts
E2E Tests:           feature-name.spec.ts
Integration Tests:   integration-name.test.ts
```

### Directory Structure
```
Testing Architecture:
├── __tests__/           # Unit tests
│   ├── components/      # React component tests
│   ├── api/            # API route tests
│   ├── hooks/          # Custom hook tests
│   ├── lib/            # Utility function tests
│   └── security/       # Security-specific tests
├── tests/              # Integration tests
│   ├── ai-management/  # AI feature test suite
│   ├── accessibility/  # WCAG compliance tests
│   └── api/           # API integration tests
├── e2e/               # End-to-end tests
├── test/              # Test utilities & setup
│   ├── setup.ts       # Global test setup
│   ├── test-utils.tsx # Custom render utilities
│   └── mocks.ts       # Mock data and services
```

---

## 🧪 Test Writing Patterns

### Component Test Template
```typescript
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ComponentName } from '@/components/ComponentName';

describe('ComponentName', () => {
  const defaultProps = {
    prop1: 'value1',
    prop2: 'value2',
  };

  it('renders without errors', () => {
    render(<ComponentName {...defaultProps} />);
    expect(screen.getByRole('button')).toBeInTheDocument();
  });

  it('handles user interactions', async () => {
    const user = userEvent.setup();
    const onClickMock = vi.fn();
    
    render(<ComponentName {...defaultProps} onClick={onClickMock} />);
    
    await user.click(screen.getByRole('button'));
    expect(onClickMock).toHaveBeenCalledTimes(1);
  });

  it('displays loading state', () => {
    render(<ComponentName {...defaultProps} isLoading={true} />);
    expect(screen.getByRole('status')).toBeInTheDocument();
  });
});
```

### API Route Test Template
```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { GET, POST } from '@/app/api/route-name/route';
import { NextRequest } from 'next/server';

describe('/api/route-name', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('GET', () => {
    it('returns data successfully', async () => {
      const request = new NextRequest('http://localhost:3000/api/route-name');
      const response = await GET(request, {});
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(data.success).toBe(true);
      expect(data.data).toBeDefined();
    });

    it('handles validation errors', async () => {
      const request = new NextRequest('http://localhost:3000/api/route-name?invalid=param');
      const response = await GET(request, {});
      const data = await response.json();

      expect(response.status).toBe(400);
      expect(data.success).toBe(false);
      expect(data.error).toBeDefined();
    });
  });
});
```

### E2E Test Template
```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/feature-path');
  });

  test('completes main user flow', async ({ page }) => {
    // Arrange
    await page.waitForLoadState('networkidle');
    
    // Act
    await page.click('[data-testid="action-button"]');
    await page.fill('[data-testid="input-field"]', 'test value');
    await page.click('[data-testid="submit-button"]');
    
    // Assert
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
    await expect(page).toHaveURL(/.*success/);
  });

  test('handles error states', async ({ page }) => {
    // Test error scenarios
    await page.click('[data-testid="error-trigger"]');
    await expect(page.locator('[data-testid="error-message"]')).toBeVisible();
  });
});
```

---

## 🛠️ Test Utilities Reference

### Custom Render Utility
```typescript
// test/test-utils.tsx
import { render, RenderOptions } from '@testing-library/react';
import { ReactElement } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const AllTheProviders = ({ children }: { children: React.ReactNode }) => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
};

const customRender = (
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) => render(ui, { wrapper: AllTheProviders, ...options });

export * from '@testing-library/react';
export { customRender as render };
```

### Mock Data Factories
```typescript
// test/test-data.ts
export const createMockPhoto = (overrides = {}) => ({
  id: 'photo-123',
  original_filename: 'test.jpg',
  storage_path: 'photos/test.jpg',
  file_size: 1024,
  mime_type: 'image/jpeg',
  uploader: { id: 'user-123', first_name: 'Test', last_name: 'User' },
  tags: [],
  ...overrides,
});

export const createMockUser = (overrides = {}) => ({
  id: 'user-123',
  email: 'test@example.com',
  first_name: 'Test',
  last_name: 'User',
  role: 'engineer',
  ...overrides,
});
```

### Accessibility Testing
```typescript
// test/accessibility-utils.ts
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

export const testAccessibility = async (container: HTMLElement) => {
  const results = await axe(container);
  expect(results).toHaveNoViolations();
};

// Usage in tests:
it('has no accessibility violations', async () => {
  const { container } = render(<Component />);
  await testAccessibility(container);
});
```

---

## 🔍 Debugging Test Issues

### Common Test Failures

#### 1. Component Not Rendering
```typescript
// Problem: Component not found
screen.getByRole('button') // throws error

// Solution: Check what's actually rendered
screen.debug(); // Shows current DOM
screen.logTestingPlaygroundURL(); // Opens testing playground
```

#### 2. Async Operations
```typescript
// Problem: Element not found immediately
screen.getByText('Loading...') // might fail

// Solution: Use async queries
await screen.findByText('Loading...') // waits for element
await waitFor(() => expect(screen.getByText('Loaded')).toBeInTheDocument());
```

#### 3. User Interactions
```typescript
// Problem: Click not registering
fireEvent.click(button) // deprecated

// Solution: Use user-event
const user = userEvent.setup();
await user.click(button);
```

### Test Environment Issues

#### Mock Resolution
```typescript
// Problem: Module not mocked correctly
vi.mock('@/lib/service', () => ({
  default: vi.fn(),
}));

// Solution: Check mock is applied
console.log(service); // Should show mock function
```

#### Next.js Specific Issues
```typescript
// Mock Next.js router
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
  }),
  usePathname: () => '/',
}));

// Mock Next.js Image
vi.mock('next/image', () => ({
  default: (props: any) => <img {...props} />,
}));
```

---

## 📈 Performance Testing

### Performance Test Patterns
```typescript
// Component Performance
it('renders large lists efficiently', () => {
  const largeDataSet = Array.from({ length: 1000 }, (_, i) => createMockItem(i));
  
  const startTime = performance.now();
  render(<ItemList items={largeDataSet} />);
  const endTime = performance.now();
  
  expect(endTime - startTime).toBeLessThan(100); // 100ms threshold
});

// API Performance
it('responds within performance threshold', async () => {
  const startTime = Date.now();
  const response = await fetch('/api/photos');
  const endTime = Date.now();
  
  expect(endTime - startTime).toBeLessThan(500); // 500ms threshold
  expect(response.status).toBe(200);
});
```

### E2E Performance Testing
```typescript
// playwright.config.ts performance setup
test('page loads within performance budget', async ({ page }) => {
  const startTime = Date.now();
  await page.goto('/photos');
  await page.waitForLoadState('networkidle');
  const endTime = Date.now();
  
  expect(endTime - startTime).toBeLessThan(3000); // 3s budget
});
```

---

## 🔒 Security Testing Patterns

### Authentication Testing
```typescript
describe('Protected Route', () => {
  it('redirects unauthenticated users', async () => {
    const request = new NextRequest('http://localhost:3000/api/protected');
    const response = await GET(request, {});
    
    expect(response.status).toBe(401);
  });

  it('allows authenticated users', async () => {
    const request = new NextRequest('http://localhost:3000/api/protected', {
      headers: { Authorization: 'Bearer valid-token' },
    });
    const response = await GET(request, {});
    
    expect(response.status).toBe(200);
  });
});
```

### Input Validation Testing
```typescript
describe('Input Validation', () => {
  it('prevents SQL injection', async () => {
    const maliciousInput = "'; DROP TABLE users; --";
    const request = new NextRequest('http://localhost:3000/api/search', {
      method: 'POST',
      body: JSON.stringify({ query: maliciousInput }),
    });
    
    const response = await POST(request, {});
    expect(response.status).toBe(400); // Should reject malicious input
  });
});
```

---

## 📊 CI/CD Integration

### GitHub Actions Commands
```yaml
# .github/workflows/test.yml
- name: Run Tests
  run: |
    npm run test:ci
    npm run test:e2e
    npm run test:a11y:ci

- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

### Pre-commit Hooks
```json
// .husky/pre-commit
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npm run test:changed
npm run test:a11y
npm run lint
```

---

## 🎯 Best Practices Checklist

### ✅ Writing Good Tests
- [ ] Test behavior, not implementation
- [ ] Use descriptive test names
- [ ] Arrange-Act-Assert pattern
- [ ] One assertion per test (when possible)
- [ ] Mock external dependencies
- [ ] Test edge cases and error scenarios

### ✅ Component Testing
- [ ] Test user interactions
- [ ] Test different props combinations
- [ ] Test loading and error states
- [ ] Test accessibility
- [ ] Use semantic queries (getByRole, getByLabelText)

### ✅ API Testing
- [ ] Test success scenarios
- [ ] Test validation errors
- [ ] Test authentication/authorization
- [ ] Test edge cases (empty data, large payloads)
- [ ] Mock external services

### ✅ E2E Testing
- [ ] Test critical user journeys
- [ ] Test across different browsers
- [ ] Test mobile responsiveness
- [ ] Use data-testid for reliable selectors
- [ ] Test error recovery scenarios

---

## 🚨 Common Pitfalls to Avoid

### ❌ Testing Anti-patterns
- **Don't test implementation details** (internal state, private methods)
- **Don't write tests that are too specific** (brittle tests)
- **Don't ignore async operations** (use proper waiting)
- **Don't mock everything** (integration value lost)
- **Don't write tests without assertions** (no verification)

### ❌ Performance Issues
- **Don't render heavy components unnecessarily**
- **Don't forget to cleanup after tests**
- **Don't use real network requests in unit tests**
- **Don't ignore test timeout issues**

### ❌ Accessibility Oversights
- **Don't forget to test keyboard navigation**
- **Don't ignore screen reader compatibility**
- **Don't test only with mouse interactions**
- **Don't forget color contrast testing**

---

## 📚 Additional Resources

### Documentation Links
- [Vitest Documentation](https://vitest.dev/)
- [Playwright Documentation](https://playwright.dev/)
- [Testing Library Guide](https://testing-library.com/docs/)
- [jest-axe Accessibility Testing](https://github.com/nickcolley/jest-axe)

### Internal Resources
- `docs/testing/testing-guide.md` - Comprehensive testing guide
- `tests/accessibility/README.md` - Accessibility testing patterns
- `tests/ai-management/README.md` - AI management test examples
- `test/setup.ts` - Global test configuration

### Team Resources
- **Slack Channel**: #testing-support
- **Code Review Guidelines**: Focus on test coverage in PRs
- **Testing Office Hours**: Fridays 2-3 PM for testing questions

---

*This quick reference should be bookmarked and referenced frequently. Keep it updated as testing patterns evolve.*