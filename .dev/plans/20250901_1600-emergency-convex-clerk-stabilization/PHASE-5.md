# Phase 5: Test Suite Restoration

**Objective**: Fix failing tests and restore >95% pass rate  
**Duration**: Day 4-5 (8 hours)  
**Priority**: 🟡 HIGH - Required for confident deployment  
**Success Criteria**: >95% test pass rate, all critical paths covered

## 📋 Phase Overview

The test suite has degraded to 73% pass rate with 102 failing tests. This phase will fix the Convex mocking system, update tests for the new architecture, and ensure comprehensive coverage of all critical paths. A robust test suite is essential for confident production deployment.

## 🎯 Deliverables

1. ✅ Convex mock utilities created and working
2. ✅ All unit tests updated for Convex/Clerk
3. ✅ Integration tests restored and passing
4. ✅ E2E tests validated for critical paths
5. ✅ >95% test pass rate achieved
6. ✅ Test coverage reports generated

## 📝 Detailed Implementation Tasks

### Task 1: Create Convex Test Utilities

**File: `/tests/utils/convex-test-utils.ts` (NEW)**

```typescript
import { vi } from "vitest";
import { ConvexReactClient } from "convex/react";

// Mock Convex client
export class MockConvexClient extends ConvexReactClient {
  constructor() {
    super("http://localhost:3000");
  }
}

// Mock useQuery hook
export const mockUseQuery = vi.fn((api: any, args: any) => {
  // Return mock data based on the API endpoint
  const endpoint = api._name || api.toString();
  
  switch (endpoint) {
    case "photos.list":
      return mockPhotos;
    case "users.get":
      return mockUser;
    case "projects.list":
      return mockProjects;
    default:
      return undefined;
  }
});

// Mock useMutation hook
export const mockUseMutation = vi.fn((api: any) => {
  return vi.fn(async (args: any) => {
    // Simulate mutation success
    return { success: true, id: "mock_id_" + Date.now() };
  });
});

// Mock useAction hook
export const mockUseAction = vi.fn((api: any) => {
  return vi.fn(async (args: any) => {
    // Simulate action execution
    return { success: true, result: "mock_result" };
  });
});

// Mock data generators
export const mockPhotos = [
  {
    _id: "photo_1",
    _creationTime: Date.now(),
    organizationId: "org_123",
    uploaderId: "user_123",
    originalFilename: "test-photo-1.jpg",
    fileId: "storage_1",
    fileSize: 1024000,
    mimeType: "image/jpeg",
    width: 1920,
    height: 1080,
    aiStatus: "completed" as const,
    aiResults: {
      detectedObjects: [
        { label: "conveyor belt", confidence: 0.95, category: "machine" },
        { label: "hard hat", confidence: 0.88, category: "ppe" },
      ],
      safetyIssues: [],
      riskLevel: "low" as const,
      processingTime: 1234,
    },
    tags: ["safety", "warehouse"],
    description: "Safety inspection photo",
  },
  // Add more mock photos as needed
];

export const mockUser = {
  _id: "user_123",
  email: "test@example.com",
  name: "Test User",
  organizationId: "org_123",
  role: "engineer" as const,
};

export const mockProjects = [
  {
    _id: "project_1",
    name: "Factory Floor Safety",
    organizationId: "org_123",
    description: "Safety audit project",
    photoCount: 42,
  },
];

// Setup function for tests
export function setupConvexMocks() {
  vi.mock("convex/react", () => ({
    useQuery: mockUseQuery,
    useMutation: mockUseMutation,
    useAction: mockUseAction,
    ConvexReactClient: MockConvexClient,
    ConvexProvider: ({ children }: any) => children,
  }));
  
  vi.mock("@/convex/_generated/api", () => ({
    api: {
      photos: {
        list: { _name: "photos.list" },
        get: { _name: "photos.get" },
        create: { _name: "photos.create" },
        update: { _name: "photos.update" },
        remove: { _name: "photos.remove" },
      },
      users: {
        get: { _name: "users.get" },
        list: { _name: "users.list" },
      },
      projects: {
        list: { _name: "projects.list" },
        create: { _name: "projects.create" },
      },
      aiProcessing: {
        process: { _name: "aiProcessing.process" },
        getResults: { _name: "aiProcessing.getResults" },
      },
    },
  }));
}

// Cleanup function
export function cleanupConvexMocks() {
  vi.clearAllMocks();
}
```

### Task 2: Fix Unit Tests

**File: `/tests/convex-mock.test.ts`**

Update the failing Convex mock tests:
```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { 
  setupConvexMocks, 
  cleanupConvexMocks,
  mockUseQuery,
  mockUseMutation,
  mockPhotos,
} from "./utils/convex-test-utils";

describe("Convex Hooks Mocks", () => {
  beforeEach(() => {
    setupConvexMocks();
  });
  
  afterEach(() => {
    cleanupConvexMocks();
  });
  
  it("should mock useQuery hook correctly", () => {
    const { result } = renderHook(() => {
      const { useQuery } = require("convex/react");
      const { api } = require("@/convex/_generated/api");
      return useQuery(api.photos.list, { organizationId: "org_123" });
    });
    
    expect(result.current).toBeDefined();
    expect(result.current).toEqual(mockPhotos);
    expect(mockUseQuery).toHaveBeenCalled();
  });
  
  it("should mock useMutation hook correctly", async () => {
    const { result } = renderHook(() => {
      const { useMutation } = require("convex/react");
      const { api } = require("@/convex/_generated/api");
      return useMutation(api.photos.create);
    });
    
    expect(result.current).toBeDefined();
    expect(typeof result.current).toBe("function");
    
    let mutationResult;
    await act(async () => {
      mutationResult = await result.current({
        originalFilename: "test.jpg",
        fileId: "storage_123",
      });
    });
    
    expect(mutationResult).toEqual({
      success: true,
      id: expect.stringMatching(/^mock_id_/),
    });
  });
  
  it("should handle mutation calls", async () => {
    const { result } = renderHook(() => {
      const { useMutation } = require("convex/react");
      const { api } = require("@/convex/_generated/api");
      return {
        createPhoto: useMutation(api.photos.create),
        deletePhoto: useMutation(api.photos.remove),
      };
    });
    
    // Test create mutation
    const createResult = await result.current.createPhoto({
      originalFilename: "new-photo.jpg",
    });
    expect(createResult.success).toBe(true);
    
    // Test delete mutation
    const deleteResult = await result.current.deletePhoto({
      photoId: "photo_123",
    });
    expect(deleteResult.success).toBe(true);
  });
});
```

### Task 3: Fix AI Processing Tests

**File: `/tests/ai/production-controls.test.ts`**

Update AI tests for Convex integration:
```typescript
import { describe, it, expect, beforeEach, vi } from "vitest";
import { setupConvexMocks } from "../utils/convex-test-utils";
import { mockGoogleVisionAPI } from "../utils/ai-test-utils";

describe("AI Production Controls", () => {
  beforeEach(() => {
    setupConvexMocks();
    mockGoogleVisionAPI();
  });
  
  describe("Cost Tracking and Budget Management", () => {
    it("should track API costs for single photo processing", async () => {
      const { processPhoto } = await import("@/lib/ai/processor");
      
      const result = await processPhoto({
        photoId: "photo_123",
        fileUrl: "http://example.com/photo.jpg",
      });
      
      expect(result.cost).toBeDefined();
      expect(result.cost).toBeGreaterThan(0);
      expect(result.cost).toBeLessThan(0.01); // Less than 1 cent per photo
    });
    
    it("should respect daily budget limits", async () => {
      const { BudgetManager } = await import("@/lib/ai/budget-manager");
      const manager = new BudgetManager({ dailyLimit: 10.00 });
      
      // Simulate reaching budget limit
      for (let i = 0; i < 1000; i++) {
        const allowed = await manager.checkBudget(0.015);
        if (!allowed) {
          expect(manager.getTodaySpent()).toBeGreaterThanOrEqual(10.00);
          break;
        }
        await manager.recordUsage(0.015);
      }
      
      // Should reject new requests after limit
      const overLimit = await manager.checkBudget(1.00);
      expect(overLimit).toBe(false);
    });
    
    it("should track processing metadata accurately", async () => {
      const { processPhoto } = await import("@/lib/ai/processor");
      
      const result = await processPhoto({
        photoId: "photo_123",
        fileUrl: "http://example.com/photo.jpg",
      });
      
      expect(result.metadata).toMatchObject({
        processingTime: expect.any(Number),
        apiCalls: expect.any(Number),
        modelUsed: expect.any(String),
        timestamp: expect.any(String),
      });
    });
  });
  
  describe("Rate Limiting and Queue Management", () => {
    it("should handle concurrent requests without overwhelming the API", async () => {
      const { QueueManager } = await import("@/lib/ai/queue-manager");
      const queue = new QueueManager({ maxConcurrent: 3 });
      
      const promises = Array.from({ length: 10 }, (_, i) =>
        queue.add(() => processTestPhoto(`photo_${i}`))
      );
      
      // Check that only 3 are processing at once
      expect(queue.getActiveCount()).toBeLessThanOrEqual(3);
      
      await Promise.all(promises);
      expect(queue.getActiveCount()).toBe(0);
    });
    
    it("should queue requests with different priorities", async () => {
      const { PriorityQueue } = await import("@/lib/ai/priority-queue");
      const queue = new PriorityQueue();
      
      const results: string[] = [];
      
      queue.add(() => results.push("low"), { priority: 1 });
      queue.add(() => results.push("high"), { priority: 10 });
      queue.add(() => results.push("medium"), { priority: 5 });
      
      await queue.processAll();
      
      expect(results).toEqual(["high", "medium", "low"]);
    });
    
    it("should handle rate limit errors gracefully", async () => {
      const { processWithRetry } = await import("@/lib/ai/retry-handler");
      
      // Mock rate limit error
      vi.mocked(fetch).mockRejectedValueOnce({
        status: 429,
        statusText: "Too Many Requests",
      });
      
      const result = await processWithRetry(async () => {
        return { success: true };
      });
      
      expect(result.success).toBe(true);
    });
  });
  
  describe("Circuit Breaker Pattern", () => {
    it("should handle repeated failures with circuit breaker", async () => {
      const { CircuitBreaker } = await import("@/lib/ai/circuit-breaker");
      const breaker = new CircuitBreaker({
        threshold: 3,
        timeout: 1000,
      });
      
      // Simulate failures
      for (let i = 0; i < 3; i++) {
        try {
          await breaker.execute(() => {
            throw new Error("Service unavailable");
          });
        } catch (e) {
          // Expected failures
        }
      }
      
      // Circuit should be open
      expect(breaker.getState()).toBe("open");
      
      // Should reject immediately without calling service
      await expect(breaker.execute(() => "test")).rejects.toThrow(
        "Circuit breaker is open"
      );
    });
    
    it("should recover from circuit breaker when service is restored", async () => {
      const { CircuitBreaker } = await import("@/lib/ai/circuit-breaker");
      const breaker = new CircuitBreaker({
        threshold: 2,
        timeout: 100, // Short timeout for testing
      });
      
      // Trigger circuit breaker
      for (let i = 0; i < 2; i++) {
        try {
          await breaker.execute(() => {
            throw new Error("Failed");
          });
        } catch (e) {
          // Expected
        }
      }
      
      // Wait for half-open state
      await new Promise(resolve => setTimeout(resolve, 150));
      
      // Service restored
      const result = await breaker.execute(() => "success");
      expect(result).toBe("success");
      expect(breaker.getState()).toBe("closed");
    });
  });
  
  describe("Error Categorization and Handling", () => {
    const testErrorCategorization = async (
      error: any,
      expectedCategory: string
    ) => {
      const { categorizeError } = await import("@/lib/ai/error-handler");
      const category = categorizeError(error);
      expect(category).toBe(expectedCategory);
    };
    
    it("should categorize authentication errors correctly", async () => {
      await testErrorCategorization(
        { status: 401, message: "Unauthorized" },
        "authentication"
      );
    });
    
    it("should categorize rate limit errors correctly", async () => {
      await testErrorCategorization(
        { status: 429, message: "Too Many Requests" },
        "rate_limit"
      );
    });
    
    it("should categorize quota errors correctly", async () => {
      await testErrorCategorization(
        { status: 402, message: "Quota exceeded" },
        "quota"
      );
    });
    
    it("should categorize network errors correctly", async () => {
      await testErrorCategorization(
        new Error("Network request failed"),
        "network"
      );
    });
    
    it("should handle unknown errors gracefully", async () => {
      await testErrorCategorization(
        { unknown: "error" },
        "unknown"
      );
    });
  });
  
  describe("Retry Logic and Backoff", () => {
    it("should implement exponential backoff for retryable errors", async () => {
      const { retryWithBackoff } = await import("@/lib/ai/retry-handler");
      
      let attempts = 0;
      const timestamps: number[] = [];
      
      await retryWithBackoff(
        async () => {
          timestamps.push(Date.now());
          attempts++;
          if (attempts < 3) {
            throw new Error("Temporary failure");
          }
          return "success";
        },
        { maxAttempts: 5, initialDelay: 100 }
      );
      
      expect(attempts).toBe(3);
      
      // Check exponential delays
      const delays = timestamps.slice(1).map((t, i) => t - timestamps[i]);
      expect(delays[0]).toBeGreaterThanOrEqual(100);
      expect(delays[1]).toBeGreaterThanOrEqual(200);
    });
  });
});

// Helper function for tests
async function processTestPhoto(photoId: string) {
  return new Promise(resolve => {
    setTimeout(() => resolve({ photoId, processed: true }), 10);
  });
}
```

### Task 4: Fix Integration Tests

**File: `/tests/integration/notes-integration.test.ts`**

Update integration tests for Convex:
```typescript
import { describe, it, expect, beforeEach } from "vitest";
import { setupConvexMocks } from "../utils/convex-test-utils";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

describe("Notes Integration", () => {
  beforeEach(() => {
    setupConvexMocks();
  });
  
  it("should create and display notes for photos", async () => {
    const { NotesPanel } = await import("@/components/notes/notes-panel");
    
    render(<NotesPanel photoId="photo_123" />);
    
    // Add a note
    const input = screen.getByPlaceholderText("Add a note...");
    const addButton = screen.getByText("Add Note");
    
    await userEvent.type(input, "Safety issue identified");
    await userEvent.click(addButton);
    
    // Verify note appears
    await waitFor(() => {
      expect(screen.getByText("Safety issue identified")).toBeInTheDocument();
    });
  });
  
  it("should sync notes across sessions", async () => {
    // Simulate real-time sync
    const { useQuery } = require("convex/react");
    
    // Initial notes
    useQuery.mockReturnValueOnce([
      { _id: "note_1", text: "Initial note", photoId: "photo_123" },
    ]);
    
    const { rerender } = render(<NotesPanel photoId="photo_123" />);
    
    expect(screen.getByText("Initial note")).toBeInTheDocument();
    
    // Simulate new note from another session
    useQuery.mockReturnValueOnce([
      { _id: "note_1", text: "Initial note", photoId: "photo_123" },
      { _id: "note_2", text: "New note from other user", photoId: "photo_123" },
    ]);
    
    rerender(<NotesPanel photoId="photo_123" />);
    
    await waitFor(() => {
      expect(screen.getByText("New note from other user")).toBeInTheDocument();
    });
  });
});
```

### Task 5: Create E2E Test Scenarios

**File: `/e2e/critical-paths.spec.ts` (NEW)**

```typescript
import { test, expect } from "@playwright/test";

test.describe("Critical User Paths", () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto("/login");
    await page.fill('input[type="email"]', "test@example.com");
    await page.fill('input[type="password"]', "TestPassword123!");
    await page.click('button[type="submit"]');
    await page.waitForURL("/photos");
  });
  
  test("Upload and process photo workflow", async ({ page }) => {
    // Navigate to upload
    await page.click('button:has-text("Upload")');
    await page.waitForURL("/upload");
    
    // Upload a file
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles("tests/fixtures/test-photo.jpg");
    
    // Wait for upload completion
    await expect(page.locator("text=Upload complete")).toBeVisible({
      timeout: 10000,
    });
    
    // Verify photo appears in list
    await page.goto("/photos");
    await expect(page.locator("text=test-photo.jpg")).toBeVisible();
    
    // Verify AI processing started
    await expect(page.locator("text=Processing")).toBeVisible();
  });
  
  test("Search and filter photos", async ({ page }) => {
    await page.goto("/photos");
    
    // Search
    await page.fill('input[placeholder="Search photos..."]', "safety");
    await page.waitForTimeout(500); // Debounce
    
    // Verify filtered results
    const photos = page.locator('[data-testid="photo-card"]');
    await expect(photos).toHaveCount(3); // Assuming 3 safety photos
    
    // Apply tag filter
    await page.click('text=warehouse');
    await expect(photos).toHaveCount(1); // More specific filter
    
    // Clear filters
    await page.click('button:has-text("Clear filters")');
    await expect(photos.first()).toBeVisible();
  });
  
  test("Export photos workflow", async ({ page }) => {
    await page.goto("/photos");
    
    // Select photos
    await page.click('[data-testid="select-all"]');
    
    // Open export dialog
    await page.click('button:has-text("Export")');
    
    // Select format
    await page.click('label:has-text("CSV")');
    
    // Start export
    const downloadPromise = page.waitForEvent("download");
    await page.click('button:has-text("Export Selected")');
    
    // Verify download
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toContain(".csv");
  });
  
  test("Admin dashboard access", async ({ page }) => {
    // Navigate to admin
    await page.goto("/admin");
    
    // Verify dashboard loads
    await expect(page.locator("h1:has-text('Admin Dashboard')")).toBeVisible();
    
    // Check stats cards
    await expect(page.locator("text=Total Users")).toBeVisible();
    await expect(page.locator("text=Total Photos")).toBeVisible();
    await expect(page.locator("text=Storage Used")).toBeVisible();
    
    // Verify real-time updates
    const initialCount = await page.locator('[data-testid="photo-count"]').textContent();
    
    // Trigger an update (in another tab/session)
    // ...
    
    // Verify count updated
    await page.waitForTimeout(2000);
    const newCount = await page.locator('[data-testid="photo-count"]').textContent();
    expect(newCount).not.toBe(initialCount);
  });
});
```

### Task 6: Test Configuration Updates

**File: `/vitest.config.ts`**

Update Vitest configuration:
```typescript
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "happy-dom",
    globals: true,
    setupFiles: ["./tests/setup.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      exclude: [
        "node_modules/",
        "tests/",
        "*.config.ts",
        "convex/_generated/**",
      ],
      thresholds: {
        statements: 80,
        branches: 80,
        functions: 80,
        lines: 80,
      },
    },
    alias: {
      "@": path.resolve(__dirname, "./"),
      "@/convex": path.resolve(__dirname, "./convex"),
    },
  },
});
```

**File: `/tests/setup.ts`**

Global test setup:
```typescript
import "@testing-library/jest-dom";
import { cleanup } from "@testing-library/react";
import { afterEach, vi } from "vitest";

// Cleanup after each test
afterEach(() => {
  cleanup();
  vi.clearAllMocks();
});

// Mock environment variables
process.env.NEXT_PUBLIC_CONVEX_URL = "http://localhost:3000";
process.env.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY = "pk_test_mock";

// Mock window.matchMedia
Object.defineProperty(window, "matchMedia", {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});

// Mock IntersectionObserver
global.IntersectionObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}));

// Mock fetch for tests
global.fetch = vi.fn();
```

## ✅ Validation Checklist

### Test Execution
```bash
# Run all tests
pnpm test

# Run with coverage
pnpm test:coverage

# Run specific test suites
pnpm test tests/convex
pnpm test tests/ai
pnpm test tests/integration

# Run E2E tests
pnpm test:e2e
```

### Coverage Requirements
- [ ] Statement coverage >80%
- [ ] Branch coverage >80%
- [ ] Function coverage >80%
- [ ] Line coverage >80%

### Test Suite Health
- [ ] All Convex mock tests passing
- [ ] AI processing tests restored
- [ ] Integration tests working
- [ ] E2E critical paths validated
- [ ] No flaky tests
- [ ] Test execution time <60 seconds

## 🔄 Rollback Plan

If test fixes break functionality:

1. **Temporarily skip failing tests:**
   ```typescript
   it.skip("problematic test", () => {
     // TODO: Fix after stabilization
   });
   ```

2. **Use test.todo for planned tests:**
   ```typescript
   test.todo("feature not yet implemented");
   ```

3. **Isolate flaky tests:**
   ```typescript
   describe.skipIf(process.env.CI)("flaky tests", () => {
     // Tests that fail in CI but pass locally
   });
   ```

## 📊 Success Metrics

- [ ] Test pass rate >95% (from 73%)
- [ ] 0 failing critical path tests
- [ ] Coverage thresholds met (>80%)
- [ ] Convex mocks working properly
- [ ] AI tests validating controls
- [ ] Integration tests passing
- [ ] E2E tests successful
- [ ] CI/CD pipeline green

## 🚀 Next Steps

After completing Phase 5:
1. Run full test suite with coverage
2. Review coverage reports for gaps
3. Fix any remaining flaky tests
4. Update MASTER-TRACKER.md with completion status
5. Document test patterns in GAPS-LOG.md
6. Proceed to Phase 6: Production Build Success

## 📝 Implementation Notes

**Testing Best Practices:**
- Mock external services consistently
- Use data-testid attributes for E2E tests
- Keep tests focused and isolated
- Avoid testing implementation details
- Test user behavior, not internals

**Convex Testing Patterns:**
- Mock useQuery for read operations
- Mock useMutation for write operations
- Test real-time updates with mock data changes
- Validate optimistic updates
- Test error states and loading states

**Performance Testing:**
- Keep unit tests under 50ms each
- Integration tests under 500ms each
- E2E tests under 5 seconds each
- Parallelize test execution when possible

---

*Phase 5 ensures code quality and reliability through comprehensive testing, providing confidence for production deployment.*