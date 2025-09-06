# Testing Strategy - Minerva MVP
**Document Version:** 1.0  
**Date:** July 3, 2025

## Overview

This document outlines the testing strategy for the Minerva Machine Safety Photo Organizer MVP. The approach balances comprehensive coverage of critical functionality with MVP development speed and resource constraints.

## Testing Philosophy for MVP

### 🎯 **MVP Testing Priorities**
1. **Critical User Flows**: Auth, upload, AI tagging, basic search
2. **Data Integrity**: Photo storage, metadata, user data
3. **Core Business Logic**: AI processing, organization features
4. **User Experience**: Key interactions and error states
5. **Performance**: Basic performance regression detection

### 📊 **Coverage Goals**
- **Critical Path**: 90%+ coverage
- **Core Features**: 70%+ coverage  
- **Supporting Features**: 50%+ coverage
- **E2E Happy Paths**: 100% coverage

---

## Testing Stack & Tools

### ✅ **Current Setup (Agent 1)**
```javascript
// jest.config.js - Already configured
- Jest with Next.js integration
- JSDOM test environment
- @testing-library/jest-dom for DOM matchers
- Path mapping (@/ imports)
- Coverage collection setup
```

### 🔧 **Additional Tools to Add**
```bash
# Component Testing
npm install --save-dev @testing-library/react @testing-library/user-event

# API Testing  
npm install --save-dev @testing-library/jest-dom jest-environment-jsdom

# Mock Service Worker for API mocking
npm install --save-dev msw

# Accessibility Testing
npm install --save-dev @axe-core/react jest-axe

# For E2E (if needed)
npm install --save-dev @playwright/test
```

---

## Testing Responsibility by Agent

### **Agent 1: Foundation & Infrastructure** ✅ Complete
**Testing Focus**: Core utilities and setup
```typescript
// Tests to add:
__tests__/
├── lib/
│   ├── utils.test.ts           // cn(), date utils, file formatting
│   ├── env.test.ts             // Environment validation
│   ├── api-response.test.ts    // API response utilities
│   └── error-handler.test.ts   // Error handling utilities
└── components/ui/
    ├── button.test.tsx         // Core UI components
    ├── card.test.tsx
    └── dialog.test.tsx
```

**Priority**: ⭐⭐ (Medium - utilities are stable)

### **Agent 2: Authentication & User Management** ✅ Complete  
**Testing Focus**: Auth flows and session management
```typescript
// Critical tests to add:
__tests__/
├── hooks/
│   ├── useAuth.test.ts         // Auth hook functionality
│   ├── useRequireAuth.test.ts  // Route protection
│   └── useSession.test.ts      // Session management
├── components/auth/
│   ├── auth-form.test.tsx      // Login/signup forms
│   ├── protected-route.test.tsx // Route protection
│   └── user-menu.test.tsx      // User menu interactions
└── integration/
    └── auth-flow.test.tsx      // Complete auth flows
```

**Priority**: ⭐⭐⭐ (High - critical for all functionality)

### **Agent 3: Photo Upload & Storage** ✅ Complete
**Testing Focus**: File handling and upload processes  
```typescript
// Critical tests to add:
__tests__/
├── components/upload/
│   ├── file-drop-zone.test.tsx     // Drag/drop functionality
│   ├── upload-progress.test.tsx    // Progress tracking
│   ├── file-preview.test.tsx       // File preview
│   └── upload-interface.test.tsx   // Complete upload flow
├── lib/
│   ├── file-validation.test.ts     // File validation logic
│   ├── upload-processor.test.ts    // Upload processing
│   └── storage.test.ts             // Storage operations
├── hooks/
│   └── useFileUpload.test.ts       // Upload hook
└── integration/
    └── upload-flow.test.tsx        // End-to-end upload
```

**Priority**: ⭐⭐⭐ (High - core functionality)

### **Agent 4: AI Processing & Tagging** ✅ Complete
**Testing Focus**: AI integration and tagging logic
```typescript
// Critical tests to add:
__tests__/
├── components/ai/
│   ├── tag-selector.test.tsx       // Tag management UI
│   ├── ai-tag-suggestions.test.tsx // AI suggestions
│   └── ai-analytics-dashboard.test.tsx // Analytics
├── lib/
│   ├── ai-processing.test.ts       // AI processing logic
│   └── ai-queue.test.ts            // Processing queue
├── hooks/
│   └── useAI.test.ts               // AI hooks
└── integration/
    └── ai-tagging-flow.test.tsx    // Complete AI workflow
```

**Priority**: ⭐⭐⭐ (High - core business value)

### **Agent 5: UI/UX & Photo Management** ✅ Complete
**Testing Focus**: Photo display and interaction
```typescript
// Critical tests to add:
__tests__/
├── components/photos/
│   ├── photo-grid.test.tsx         // Photo grid display
│   ├── photo-filters.test.tsx      // Filtering functionality
│   ├── photo-toolbar.test.tsx      // Toolbar interactions
│   └── photo-detail-modal.test.tsx // Photo detail view
├── hooks/
│   ├── use-touch-gestures.test.ts  // Touch interactions
│   └── use-keyboard-shortcuts.test.ts // Keyboard navigation
├── stores/
│   └── photo-management-store.test.ts // State management
└── integration/
    └── photo-management-flow.test.tsx // Complete photo management
```

**Priority**: ⭐⭐⭐ (High - primary user interface)

### **Agent 6: Organization & Export Features** ✅ Complete
**Testing Focus**: Organization and export functionality
```typescript
// Critical tests to add:
__tests__/
├── components/organization/
│   ├── site-manager.test.tsx       // Site management
│   ├── project-manager.test.tsx    // Project management
│   ├── album-manager.test.tsx      // Album functionality
│   ├── bulk-assignment.test.tsx    // Bulk operations
│   └── export-wizard.test.tsx      // Export functionality
├── lib/
│   ├── organization-operations.test.ts // Organization logic
│   └── export-generator.test.ts    // Export generation
└── integration/
    └── organization-flow.test.tsx  // Complete organization workflow
```

**Priority**: ⭐⭐ (Medium-High - important but not critical path)

### **Agent 7: Feedback & Analytics** 🔜 Next
**Testing Focus**: Analytics tracking and feedback collection
```typescript
// Critical tests to add:
__tests__/
├── components/feedback/
│   ├── feedback-widget.test.tsx    // Feedback collection
│   └── analytics-dashboard.test.tsx // Analytics display
├── lib/
│   ├── posthog-analytics.test.ts   // PostHog integration
│   ├── custom-analytics.test.ts    // Custom analytics
│   └── feedback-operations.test.ts // Feedback operations
└── integration/
    └── analytics-tracking.test.tsx // Analytics integration
```

**Priority**: ⭐⭐ (Medium - important for product improvement)

### **Agent 8: Testing & Mobile Optimization** 🔜 Final
**Testing Focus**: Mobile optimization, performance, and comprehensive testing
```typescript
// Comprehensive testing and optimization:
__tests__/
├── mobile/
│   ├── touch-interactions.test.tsx // Touch gestures
│   ├── responsive-layout.test.tsx  // Responsive design
│   └── offline-functionality.test.tsx // Offline features
├── performance/
│   ├── image-optimization.test.ts  // Image loading performance
│   ├── virtual-scrolling.test.tsx  // Virtual scrolling
│   └── memory-management.test.ts   // Memory optimization
├── e2e/
│   ├── critical-user-flows.spec.ts // End-to-end flows
│   ├── mobile-experience.spec.ts   // Mobile e2e
│   └── performance-regression.spec.ts // Performance tests
└── accessibility/
    └── a11y-compliance.test.tsx    // Accessibility testing
```

**Priority**: ⭐⭐⭐ (High - ensures overall quality)

---

## E2E Testing Strategy for MVP

### 🤔 **Playwright vs Simpler Approach**

For MVP, I recommend a **phased approach**:

#### **Phase 1: MVP (Current)** - Jest + React Testing Library
```typescript
// Focus on integration tests that cover user flows
__tests__/integration/
├── auth-to-upload-flow.test.tsx     // Login → Upload photos
├── upload-to-tagging-flow.test.tsx  // Upload → AI tagging
├── search-and-filter-flow.test.tsx  // Photo discovery
└── organization-flow.test.tsx       // Photo organization
```

**Benefits**: 
- ✅ Faster to implement
- ✅ Lower maintenance overhead  
- ✅ Good coverage of critical paths
- ✅ Runs in CI/CD easily

#### **Phase 2: Post-MVP** - Add Playwright
```typescript
// Add Playwright for true e2e testing
e2e/
├── critical-user-journeys.spec.ts   // Complete user journeys
├── cross-browser-testing.spec.ts    // Browser compatibility
├── mobile-testing.spec.ts           // Mobile-specific e2e
└── performance-testing.spec.ts      // Performance regression
```

**When to add Playwright**:
- ❌ Complex user flows that span multiple pages
- ❌ Browser-specific behavior testing needed
- ❌ Visual regression testing required
- ❌ Performance monitoring needed

### **Recommendation for MVP**: Skip Playwright initially, focus on comprehensive Jest + RTL integration tests.

---

## Testing Implementation Plan

### **Immediate Actions (Week 1)**
```bash
# 1. Install additional testing dependencies
npm install --save-dev @testing-library/react @testing-library/user-event msw @axe-core/react jest-axe

# 2. Update jest.setup.js with additional matchers
# 3. Create testing utilities and mocks
# 4. Set up MSW for API mocking
```

### **Enhanced Jest Setup**
```typescript
// jest.setup.js - Enhanced version
import '@testing-library/jest-dom';
import 'jest-axe/extend-expect';
import { server } from './src/__tests__/__mocks__/server';

// Mock Next.js router
jest.mock('next/router', () => ({
  useRouter: () => ({
    push: jest.fn(),
    pathname: '/',
    route: '/',
    asPath: '/',
    query: {},
  }),
}));

// Mock Supabase
jest.mock('@/lib/supabase', () => ({
  supabase: () => ({
    auth: {
      getUser: jest.fn(),
      signInWithPassword: jest.fn(),
      signUp: jest.fn(),
      signOut: jest.fn(),
    },
    from: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      delete: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      single: jest.fn(),
    })),
  }),
}));

// Mock PostHog
jest.mock('posthog-js', () => ({
  capture: jest.fn(),
  identify: jest.fn(),
  init: jest.fn(),
}));

// Setup MSW
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### **Testing Utilities**
```typescript
// __tests__/utils/test-utils.tsx
import { render } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from '@/components/providers/theme-provider';

export function renderWithProviders(ui: React.ReactElement) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  return render(
    <QueryClientProvider client={queryClient}>
      <ThemeProvider attribute="class" defaultTheme="light">
        {ui}
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export * from '@testing-library/react';
export { renderWithProviders as render };
```

### **Mock Service Worker Setup**
```typescript
// __tests__/__mocks__/handlers.ts
import { rest } from 'msw';

export const handlers = [
  // Auth handlers
  rest.post('/api/auth/login', (req, res, ctx) => {
    return res(
      ctx.json({
        user: { id: '1', email: 'test@example.com' },
        session: { access_token: 'fake-token' }
      })
    );
  }),

  // Photo handlers
  rest.get('/api/photos', (req, res, ctx) => {
    return res(
      ctx.json([
        {
          id: '1',
          original_filename: 'test-photo.jpg',
          ai_description: 'Test photo description',
          created_at: '2025-01-01T00:00:00Z'
        }
      ])
    );
  }),

  // AI processing handlers
  rest.post('/api/ai/process-photo', (req, res, ctx) => {
    return res(
      ctx.json({
        tags: [{ name: 'safety_equipment', confidence: 0.9 }],
        description: 'AI generated description'
      })
    );
  }),
];

// __tests__/__mocks__/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

---

## Testing Commands & Scripts

### **Update package.json scripts**
```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:ci": "jest --ci --coverage --watchAll=false",
    "test:debug": "node --inspect-brk node_modules/.bin/jest --runInBand",
    "test:a11y": "jest --testNamePattern=accessibility",
    "test:integration": "jest __tests__/integration",
    "test:unit": "jest --testPathIgnorePatterns=integration",
    "lint:test": "eslint __tests__/**/*.{ts,tsx}"
  }
}
```

### **CI/CD Integration**
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - run: npm ci
      - run: npm run lint
      - run: npm run test:ci
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

## Testing Guidelines & Best Practices

### **Writing Tests**
```typescript
// Example: Component test structure
describe('PhotoGrid', () => {
  it('should render photos in grid layout', () => {
    // Arrange
    const photos = [mockPhoto1, mockPhoto2];
    
    // Act
    render(<PhotoGrid photos={photos} />);
    
    // Assert
    expect(screen.getByTestId('photo-grid')).toBeInTheDocument();
    expect(screen.getAllByRole('img')).toHaveLength(2);
  });

  it('should handle photo selection', async () => {
    const onSelect = jest.fn();
    render(<PhotoGrid photos={[mockPhoto1]} onPhotoSelect={onSelect} />);
    
    await user.click(screen.getByRole('img'));
    
    expect(onSelect).toHaveBeenCalledWith(mockPhoto1);
  });

  it('should be accessible', async () => {
    const { container } = render(<PhotoGrid photos={[mockPhoto1]} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

### **Test Organization**
```
__tests__/
├── components/           # Component tests
├── hooks/               # Hook tests  
├── lib/                 # Utility tests
├── integration/         # Integration tests
├── __mocks__/           # Mock data and handlers
├── utils/               # Test utilities
└── setup/               # Test setup files
```

### **Testing Priorities**
1. **🔴 Critical**: Auth, upload, AI tagging, basic search
2. **🟡 Important**: Organization, export, feedback
3. **🟢 Nice-to-have**: Advanced features, edge cases

---

## Success Metrics

### **Coverage Targets**
- **Statements**: 80%
- **Branches**: 75%
- **Functions**: 85%  
- **Lines**: 80%

### **Quality Gates**
- ✅ All critical user flows covered
- ✅ No accessibility violations
- ✅ API error states handled
- ✅ Loading states tested
- ✅ Mobile interactions covered

### **Performance**
- ⏱️ Test suite runs in <2 minutes
- 🚀 Individual tests complete in <1 second
- 📊 Coverage generation in <30 seconds

---

## Implementation Timeline

### **Week 1: Foundation**
- Install testing dependencies
- Set up enhanced Jest configuration
- Create testing utilities and mocks
- Agent 2 & 3: Add critical auth and upload tests

### **Week 2: Core Features**  
- Agent 4: AI processing tests
- Agent 5: Photo management tests
- Integration tests for critical flows

### **Week 3: Organization & Analytics**
- Agent 6: Organization feature tests
- Agent 7: Analytics and feedback tests

### **Week 4: Optimization & Mobile**
- Agent 8: Mobile interaction tests
- Performance testing
- Accessibility compliance
- E2E integration tests

### **Post-MVP: Enhancement**
- Add Playwright for true e2e testing
- Visual regression testing
- Cross-browser testing
- Performance monitoring

---

This testing strategy balances comprehensive coverage with MVP development speed, ensuring critical functionality is well-tested while maintaining development velocity.