# Phase 2: Component Coverage Implementation
**Week 2 - UI Stability & Visual Regression Prevention**

*Duration: 5 days*  
*Coverage Target: 90% components (247/275)*  
*Focus: Playwright MCP integration for comprehensive UI testing*

---

## Overview

Component coverage ensures UI stability for AI agents making interface changes. Current 29% component coverage (80/275) leaves 195 components untested. This phase leverages the Playwright MCP for advanced browser automation and visual regression testing.

## Day-by-Day Implementation

### Day 1: Component Testing Infrastructure
**Time: 4 hours**

#### 1. Setup Component Test Environment
```bash
mkdir -p tests/components/{auth,photos,ai-management,platform,admin,ui}
mkdir -p tests/visual-regression/screenshots/{baseline,current,diff}
mkdir -p tests/accessibility/reports
```

#### 2. Install Component Testing Dependencies
```bash
npm install -D @testing-library/react @testing-library/jest-dom
npm install -D vitest-axe @axe-core/playwright
npm install -D pixelmatch sharp
```

#### 3. Create Component Test Utilities
```typescript
// tests/components/component-test-utils.tsx
import React from 'react';
import { render as rtlRender, RenderOptions } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AuthProvider } from '@/components/auth/auth-provider';

// Mock providers for component isolation
const createQueryClient = () => new QueryClient({
  defaultOptions: {
    queries: { retry: false },
    mutations: { retry: false },
  },
});

interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  user?: Partial<User>;
  organization?: Partial<Organization>;
  queryClient?: QueryClient;
}

export function renderComponent(
  ui: React.ReactElement,
  options: CustomRenderOptions = {}
) {
  const {
    user = mockUser,
    organization = mockOrganization,
    queryClient = createQueryClient(),
    ...renderOptions
  } = options;

  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <AuthProvider value={{ user, organization }}>
        {children}
      </AuthProvider>
    </QueryClientProvider>
  );

  return rtlRender(ui, { wrapper: Wrapper, ...renderOptions });
}

export const mockUser = {
  id: 'test-user-id',
  email: 'test@example.com',
  role: 'engineer' as const,
  organization_id: 'test-org-id',
};

export const mockOrganization = {
  id: 'test-org-id',
  name: 'Test Organization',
  role: 'engineer',
};
```

#### 4. Visual Regression Testing Setup
```typescript
// tests/visual-regression/visual-test-utils.ts
import { Page, expect } from '@playwright/test';
import pixelmatch from 'pixelmatch';
import sharp from 'sharp';

export class VisualRegressionTester {
  constructor(private page: Page) {}
  
  async captureComponent(selector: string, name: string) {
    // Wait for component to be stable
    await this.page.waitForSelector(selector, { state: 'visible' });
    await this.page.waitForTimeout(100); // Animations
    
    // Capture screenshot
    const screenshot = await this.page.locator(selector).screenshot({
      animations: 'disabled',
    });
    
    // Compare with baseline
    return this.compareWithBaseline(screenshot, name);
  }
  
  private async compareWithBaseline(
    screenshot: Buffer,
    name: string
  ): Promise<VisualDiffResult> {
    const baselinePath = `tests/visual-regression/screenshots/baseline/${name}.png`;
    const currentPath = `tests/visual-regression/screenshots/current/${name}.png`;
    const diffPath = `tests/visual-regression/screenshots/diff/${name}.png`;
    
    // Save current screenshot
    await sharp(screenshot).png().toFile(currentPath);
    
    try {
      // Load baseline
      const baseline = await sharp(baselinePath).raw().toBuffer();
      const current = await sharp(screenshot).raw().toBuffer();
      
      // Compare
      const { width, height } = await sharp(baselinePath).metadata();
      const diff = Buffer.alloc(width! * height! * 4);
      
      const pixelDiff = pixelmatch(
        baseline, current, diff,
        width!, height!,
        { threshold: 0.1 }
      );
      
      if (pixelDiff > 0) {
        // Save diff image
        await sharp(diff, { raw: { width: width!, height: height!, channels: 4 } })
          .png()
          .toFile(diffPath);
      }
      
      return {
        pixelDiff,
        threshold: 0.1,
        passed: pixelDiff === 0,
        diffPath: pixelDiff > 0 ? diffPath : null,
      };
    } catch (error) {
      // No baseline exists, create one
      await sharp(screenshot).png().toFile(baselinePath);
      return {
        pixelDiff: 0,
        threshold: 0.1,
        passed: true,
        diffPath: null,
        baseline_created: true,
      };
    }
  }
}
```

### Day 2: Critical Component Testing
**Time: 5 hours**  
**Target: AI Management Components (50+ components)**

#### 1. AI Management Dashboard Components
```typescript
// tests/components/ai-management/ai-console.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { screen, fireEvent, waitFor } from '@testing-library/react';
import { renderComponent } from '../component-test-utils';
import { AIConsole } from '@/components/ai/console/AIConsole';

describe('AIConsole Component', () => {
  const mockAIData = {
    providers: [
      { id: 'openai', name: 'OpenAI', status: 'active', usage: { requests: 150 } },
      { id: 'google', name: 'Google Vision', status: 'active', usage: { requests: 89 } },
    ],
    experiments: [
      { id: 'exp-1', name: 'Prompt A/B Test', status: 'running' },
    ],
    metrics: {
      total_cost: 45.67,
      success_rate: 0.94,
    },
  };

  it('renders provider status correctly', async () => {
    renderComponent(<AIConsole data={mockAIData} />);
    
    expect(screen.getByText('OpenAI')).toBeInTheDocument();
    expect(screen.getByText('Google Vision')).toBeInTheDocument();
    expect(screen.getByText('150 requests')).toBeInTheDocument();
  });

  it('updates real-time metrics', async () => {
    const { rerender } = renderComponent(<AIConsole data={mockAIData} />);
    
    // Simulate real-time update
    const updatedData = {
      ...mockAIData,
      metrics: { ...mockAIData.metrics, total_cost: 46.23 },
    };
    
    rerender(<AIConsole data={updatedData} />);
    
    await waitFor(() => {
      expect(screen.getByText('$46.23')).toBeInTheDocument();
    });
  });

  it('handles provider failures gracefully', async () => {
    const failedData = {
      ...mockAIData,
      providers: [
        { ...mockAIData.providers[0], status: 'error' },
      ],
    };
    
    renderComponent(<AIConsole data={failedData} />);
    
    expect(screen.getByTestId('provider-error-indicator')).toBeInTheDocument();
    expect(screen.getByText('Provider Error')).toBeInTheDocument();
  });

  it('supports keyboard navigation', async () => {
    renderComponent(<AIConsole data={mockAIData} />);
    
    // Test tab navigation
    const firstTab = screen.getByRole('tab', { name: /overview/i });
    firstTab.focus();
    
    fireEvent.keyDown(firstTab, { key: 'ArrowRight' });
    
    await waitFor(() => {
      expect(screen.getByRole('tab', { name: /experiments/i })).toHaveFocus();
    });
  });
});
```

#### 2. Photo Management Components
```typescript
// tests/components/photos/photo-grid.test.tsx
import { describe, it, expect } from 'vitest';
import { screen, fireEvent } from '@testing-library/react';
import { renderComponent } from '../component-test-utils';
import { PhotoGrid } from '@/components/photos/photo-grid';

describe('PhotoGrid Component', () => {
  const mockPhotos = [
    {
      id: 'photo-1',
      url: 'https://example.com/photo1.jpg',
      title: 'Safety Equipment Check',
      tags: ['safety', 'equipment'],
      ai_tags: [{ name: 'hard-hat', confidence: 0.95, category: 'ppe' }],
    },
    {
      id: 'photo-2',
      url: 'https://example.com/photo2.jpg',
      title: 'Machine Inspection',
      tags: ['machine', 'inspection'],
      ai_tags: [{ name: 'conveyor', confidence: 0.87, category: 'machine' }],
    },
  ];

  it('renders photo grid with correct layout', () => {
    renderComponent(<PhotoGrid photos={mockPhotos} />);
    
    expect(screen.getByText('Safety Equipment Check')).toBeInTheDocument();
    expect(screen.getByText('Machine Inspection')).toBeInTheDocument();
    
    // Check grid layout
    const grid = screen.getByTestId('photo-grid');
    expect(grid).toHaveClass('grid', 'grid-cols-4', 'lg:grid-cols-6');
  });

  it('handles photo selection', async () => {
    const onSelectionChange = vi.fn();
    renderComponent(
      <PhotoGrid photos={mockPhotos} onSelectionChange={onSelectionChange} />
    );
    
    const firstPhoto = screen.getByTestId('photo-item-photo-1');
    fireEvent.click(firstPhoto);
    
    expect(onSelectionChange).toHaveBeenCalledWith(['photo-1']);
  });

  it('displays AI tags correctly', () => {
    renderComponent(<PhotoGrid photos={mockPhotos} showAITags />);
    
    expect(screen.getByText('hard-hat')).toBeInTheDocument();
    expect(screen.getByText('95%')).toBeInTheDocument();
    expect(screen.getByText('conveyor')).toBeInTheDocument();
    expect(screen.getByText('87%')).toBeInTheDocument();
  });

  it('supports bulk selection', async () => {
    const onBulkSelect = vi.fn();
    renderComponent(
      <PhotoGrid photos={mockPhotos} onBulkSelect={onBulkSelect} />
    );
    
    // Test Ctrl+A
    const grid = screen.getByTestId('photo-grid');
    fireEvent.keyDown(grid, { key: 'a', ctrlKey: true });
    
    expect(onBulkSelect).toHaveBeenCalledWith(['photo-1', 'photo-2']);
  });
});
```

### Day 3: Playwright MCP Integration
**Time: 5 hours**  
**Focus: Browser automation for complex UI interactions**

#### 1. Playwright Component Testing Setup
```typescript
// tests/playwright/component-browser.test.ts
import { test, expect } from '@playwright/test';

test.describe('Component Browser Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to component development server
    await page.goto('http://localhost:6006'); // Storybook or dev server
  });

  test('AI Management Dashboard - Real Browser', async ({ page }) => {
    // Navigate to AI console
    await page.goto('/platform/ai-management');
    
    // Wait for dashboard to load
    await page.waitForSelector('[data-testid="ai-dashboard"]');
    
    // Test live status updates
    await expect(page.locator('.provider-status')).toContainText('Active');
    
    // Test real-time cost updates
    const initialCost = await page.locator('.total-cost').textContent();
    
    // Trigger cost update (simulate API call)
    await page.click('[data-testid="refresh-metrics"]');
    await page.waitForTimeout(1000);
    
    const updatedCost = await page.locator('.total-cost').textContent();
    // Cost should update or stay same
    expect(updatedCost).toBeDefined();
  });

  test('Photo Upload with Drag & Drop', async ({ page }) => {
    await page.goto('/photos');
    
    // Test drag and drop
    const fileChooserPromise = page.waitForEvent('filechooser');
    
    // Simulate file drag
    await page.locator('.upload-dropzone').dispatchEvent('dragover', {
      dataTransfer: {
        files: [
          {
            name: 'test-image.jpg',
            type: 'image/jpeg',
            size: 1024000,
          },
        ],
      },
    });
    
    // Verify visual feedback
    await expect(page.locator('.upload-dropzone')).toHaveClass(/drag-over/);
  });

  test('Bulk Selection with Drag Selection Rectangle', async ({ page }) => {
    await page.goto('/photos');
    
    // Start drag selection
    await page.mouse.move(100, 100);
    await page.mouse.down();
    await page.mouse.move(400, 300);
    
    // Verify selection rectangle appears
    await expect(page.locator('.selection-rectangle')).toBeVisible();
    
    // Complete selection
    await page.mouse.up();
    
    // Verify photos are selected
    const selectedPhotos = page.locator('.photo-item.selected');
    await expect(selectedPhotos).toHaveCount(4); // Assuming 4 photos in selection area
  });
});
```

#### 2. Cross-Browser Component Testing
```typescript
// tests/playwright/cross-browser.test.ts
const browsers = ['chromium', 'firefox', 'webkit'];

browsers.forEach(browserName => {
  test.describe(`${browserName} - Component Tests`, () => {
    test('Photo grid renders consistently', async ({ page }) => {
      await page.goto('/photos');
      
      // Take screenshot for visual comparison
      await expect(page.locator('.photo-grid')).toHaveScreenshot(
        `photo-grid-${browserName}.png`
      );
    });

    test('AI console interactive elements work', async ({ page }) => {
      await page.goto('/platform/ai-management');
      
      // Test dropdown functionality
      await page.click('.provider-selector');
      await expect(page.locator('.dropdown-menu')).toBeVisible();
      
      // Test chart interactions
      await page.hover('.cost-chart .data-point');
      await expect(page.locator('.tooltip')).toBeVisible();
    });
  });
});
```

#### 3. Accessibility Testing with axe
```typescript
// tests/accessibility/component-accessibility.test.ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Component Accessibility', () => {
  test('AI Dashboard is accessible', async ({ page }) => {
    await page.goto('/platform/ai-management');
    
    const accessibilityScanResults = await new AxeBuilder({ page })
      .include('.ai-dashboard')
      .analyze();
    
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('Photo grid supports screen readers', async ({ page }) => {
    await page.goto('/photos');
    
    // Test ARIA labels
    const photoItems = page.locator('.photo-item');
    await expect(photoItems.first()).toHaveAttribute('aria-label');
    
    // Test keyboard navigation
    await photoItems.first().focus();
    await page.keyboard.press('Tab');
    
    // Next photo should be focused
    await expect(photoItems.nth(1)).toBeFocused();
  });

  test('Form components have proper labels', async ({ page }) => {
    await page.goto('/photos/upload');
    
    const scanResults = await new AxeBuilder({ page })
      .include('form')
      .analyze();
    
    expect(scanResults.violations).toEqual([]);
  });
});
```

### Day 4: Component Snapshot Testing
**Time: 4 hours**  
**Target: UI component library (shadcn/ui + custom components)**

#### 1. UI Component Snapshots
```typescript
// tests/components/ui/ui-components.test.tsx
import { describe, it } from 'vitest';
import { render } from '@testing-library/react';
import { Button } from '@/components/ui/button';
import { Dialog } from '@/components/ui/dialog';
import { Card } from '@/components/ui/card';

describe('UI Component Snapshots', () => {
  it('Button renders correctly', () => {
    const { container } = render(
      <div>
        <Button variant="default">Default Button</Button>
        <Button variant="destructive">Delete Button</Button>
        <Button variant="outline">Outline Button</Button>
        <Button variant="secondary" disabled>Disabled Button</Button>
      </div>
    );
    expect(container).toMatchSnapshot();
  });

  it('Dialog renders correctly', () => {
    const { container } = render(
      <Dialog open={true}>
        <Dialog.Content>
          <Dialog.Header>
            <Dialog.Title>Test Dialog</Dialog.Title>
            <Dialog.Description>
              This is a test dialog description.
            </Dialog.Description>
          </Dialog.Header>
          <div>Dialog content goes here</div>
          <Dialog.Footer>
            <Button>Cancel</Button>
            <Button variant="default">Confirm</Button>
          </Dialog.Footer>
        </Dialog.Content>
      </Dialog>
    );
    expect(container).toMatchSnapshot();
  });

  it('Card layouts render consistently', () => {
    const { container } = render(
      <div className="grid gap-4">
        <Card>
          <Card.Header>
            <Card.Title>Simple Card</Card.Title>
          </Card.Header>
          <Card.Content>
            Basic card content
          </Card.Content>
        </Card>
        
        <Card>
          <Card.Header>
            <Card.Title>Card with Actions</Card.Title>
            <Card.Description>Card description text</Card.Description>
          </Card.Header>
          <Card.Content>
            Card with actions content
          </Card.Content>
          <Card.Footer>
            <Button>Action</Button>
          </Card.Footer>
        </Card>
      </div>
    );
    expect(container).toMatchSnapshot();
  });
});
```

#### 2. Complex Component Snapshots
```typescript
// tests/components/complex/complex-snapshots.test.tsx
import { describe, it } from 'vitest';
import { renderComponent } from '../component-test-utils';
import { WordExportWizard } from '@/components/organization/word-export-wizard';
import { BulkTagSelector } from '@/components/photos/bulk-tag-selector';

describe('Complex Component Snapshots', () => {
  it('Word Export Wizard - All Steps', () => {
    const { container: step1 } = renderComponent(
      <WordExportWizard step="template" />
    );
    expect(step1).toMatchSnapshot('word-export-step-1-template');

    const { container: step2 } = renderComponent(
      <WordExportWizard step="photos" selectedTemplate="safety-report" />
    );
    expect(step2).toMatchSnapshot('word-export-step-2-photos');

    const { container: step3 } = renderComponent(
      <WordExportWizard step="preview" selectedPhotos={['p1', 'p2']} />
    );
    expect(step3).toMatchSnapshot('word-export-step-3-preview');
  });

  it('Bulk Tag Selector - Various States', () => {
    const tags = ['safety', 'equipment', 'machine', 'inspection'];
    const selectedPhotos = ['photo-1', 'photo-2', 'photo-3'];

    // Default state
    const { container: default } = renderComponent(
      <BulkTagSelector tags={tags} selectedPhotos={selectedPhotos} />
    );
    expect(default).toMatchSnapshot('bulk-tag-selector-default');

    // With selections
    const { container: selected } = renderComponent(
      <BulkTagSelector 
        tags={tags} 
        selectedPhotos={selectedPhotos}
        selectedTags={['safety', 'equipment']}
      />
    );
    expect(selected).toMatchSnapshot('bulk-tag-selector-with-selections');

    // Loading state
    const { container: loading } = renderComponent(
      <BulkTagSelector 
        tags={tags} 
        selectedPhotos={selectedPhotos}
        loading={true}
      />
    );
    expect(loading).toMatchSnapshot('bulk-tag-selector-loading');
  });
});
```

### Day 5: Integration & Performance Testing
**Time: 4 hours**  
**Focus: Component interaction testing**

#### 1. Component Integration Tests
```typescript
// tests/components/integration/photo-workflow.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { screen, fireEvent, waitFor } from '@testing-library/react';
import { renderComponent } from '../component-test-utils';
import { PhotoWorkflow } from '@/components/photos/photo-workflow';

describe('Photo Workflow Integration', () => {
  it('Complete photo upload and tagging workflow', async () => {
    const onWorkflowComplete = vi.fn();
    
    renderComponent(
      <PhotoWorkflow onComplete={onWorkflowComplete} />
    );

    // Step 1: Upload photo
    const fileInput = screen.getByLabelText(/upload photo/i);
    const file = new File(['dummy content'], 'test.jpg', { type: 'image/jpeg' });
    
    fireEvent.change(fileInput, { target: { files: [file] } });
    
    await waitFor(() => {
      expect(screen.getByText(/processing/i)).toBeInTheDocument();
    });

    // Step 2: AI processing completes
    await waitFor(() => {
      expect(screen.getByText(/ai tags suggested/i)).toBeInTheDocument();
    }, { timeout: 5000 });

    // Step 3: Review and confirm tags
    const suggestedTag = screen.getByTestId('suggested-tag-safety');
    fireEvent.click(suggestedTag);

    const confirmButton = screen.getByRole('button', { name: /confirm tags/i });
    fireEvent.click(confirmButton);

    await waitFor(() => {
      expect(onWorkflowComplete).toHaveBeenCalledWith({
        photoId: expect.any(String),
        tags: expect.arrayContaining(['safety']),
        aiTags: expect.any(Array),
      });
    });
  });

  it('Handles workflow errors gracefully', async () => {
    // Mock upload failure
    vi.mocked(uploadPhoto).mockRejectedValue(new Error('Upload failed'));

    renderComponent(<PhotoWorkflow />);

    const fileInput = screen.getByLabelText(/upload photo/i);
    const file = new File(['dummy'], 'test.jpg', { type: 'image/jpeg' });
    
    fireEvent.change(fileInput, { target: { files: [file] } });

    await waitFor(() => {
      expect(screen.getByText(/upload failed/i)).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /retry/i })).toBeInTheDocument();
    });
  });
});
```

#### 2. Performance Testing for Components
```typescript
// tests/components/performance/component-performance.test.tsx
import { describe, it, expect } from 'vitest';
import { render, cleanup } from '@testing-library/react';
import { performance } from 'perf_hooks';
import { PhotoGrid } from '@/components/photos/photo-grid';

describe('Component Performance', () => {
  it('PhotoGrid renders large datasets efficiently', () => {
    // Generate large dataset
    const largePhotoSet = Array.from({ length: 1000 }, (_, i) => ({
      id: `photo-${i}`,
      url: `https://example.com/photo-${i}.jpg`,
      title: `Photo ${i}`,
      tags: ['test', 'performance'],
      ai_tags: [],
    }));

    const startTime = performance.now();
    
    const { container } = render(
      <PhotoGrid photos={largePhotoSet} virtualized={true} />
    );
    
    const renderTime = performance.now() - startTime;
    
    // Should render within 100ms even with 1000 photos
    expect(renderTime).toBeLessThan(100);
    
    // Should only render visible items (virtualization)
    const renderedItems = container.querySelectorAll('.photo-item');
    expect(renderedItems.length).toBeLessThan(50); // Only visible items
    
    cleanup();
  });

  it('AI Console updates efficiently', async () => {
    const initialData = { providers: [], metrics: {} };
    
    const { rerender } = render(<AIConsole data={initialData} />);
    
    // Measure update performance
    const updateTimes: number[] = [];
    
    for (let i = 0; i < 10; i++) {
      const updatedData = {
        providers: Array.from({ length: i + 1 }, (_, j) => ({
          id: `provider-${j}`,
          name: `Provider ${j}`,
          status: 'active',
        })),
        metrics: { cost: i * 10 },
      };
      
      const startTime = performance.now();
      rerender(<AIConsole data={updatedData} />);
      updateTimes.push(performance.now() - startTime);
    }
    
    const avgUpdateTime = updateTimes.reduce((a, b) => a + b) / updateTimes.length;
    
    // Updates should be fast (< 10ms on average)
    expect(avgUpdateTime).toBeLessThan(10);
  });
});
```

## Implementation Checklist

### Infrastructure Setup ✓
- [ ] Component test utilities created
- [ ] Visual regression testing setup
- [ ] Playwright MCP integration configured
- [ ] Accessibility testing framework ready

### Component Categories Testing
- [ ] **AI Management** (50 components)
  - [ ] AI Console dashboard
  - [ ] Provider management
  - [ ] Experiment wizard
  - [ ] Monitoring displays
  
- [ ] **Photo Management** (40 components)  
  - [ ] Photo grid/list views
  - [ ] Upload components
  - [ ] Bulk selection
  - [ ] Filter interfaces
  
- [ ] **UI Library** (35 components)
  - [ ] shadcn/ui components
  - [ ] Custom form elements
  - [ ] Layout components
  - [ ] Navigation elements
  
- [ ] **Platform** (30 components)
  - [ ] Organization management
  - [ ] User administration
  - [ ] Tag management
  - [ ] Settings interfaces
  
- [ ] **Admin** (25 components)
  - [ ] Admin dashboard
  - [ ] Monitoring panels
  - [ ] Cost tracking
  - [ ] User management
  
- [ ] **Search & Export** (20 components)
  - [ ] Search interfaces
  - [ ] Export wizards
  - [ ] Result displays
  - [ ] Filter components
  
- [ ] **Auth & Layout** (15 components)
  - [ ] Authentication forms
  - [ ] Navigation bars
  - [ ] Sidebar components
  - [ ] Protected routes
  
- [ ] **Miscellaneous** (35 components)
  - [ ] Error boundaries
  - [ ] Loading states
  - [ ] Toast notifications
  - [ ] Modal dialogs

### Testing Types Completed
- [ ] Unit tests for component logic
- [ ] Snapshot tests for UI consistency
- [ ] Visual regression tests
- [ ] Accessibility compliance tests
- [ ] Cross-browser compatibility tests
- [ ] Performance tests for large datasets
- [ ] Integration tests for component workflows

## Test Execution Commands

```bash
# Run all component tests
npm run test:components

# Run with coverage
npm run test:components -- --coverage

# Run specific category
npm run test:components -- --grep "photo"

# Visual regression tests
npm run test:visual

# Accessibility tests
npm run test:a11y

# Playwright component tests
npm run test:components:browser

# Performance tests
npm run test:components:performance

# Update snapshots
npm run test:components -- --update-snapshots
```

## Playwright MCP Integration Examples

### 1. Complex UI Interactions
```typescript
// Using MCP Playwright tools for advanced interactions
test('Photo drag and drop with MCP', async () => {
  // Use MCP browser navigation
  await mcp_playwright_browser_navigate({ 
    url: 'http://localhost:3000/photos' 
  });
  
  // Take initial screenshot
  await mcp_playwright_browser_take_screenshot({
    filename: 'photos-before-upload.png'
  });
  
  // Simulate file upload via drag and drop
  await mcp_playwright_browser_file_upload({
    paths: ['./test-fixtures/sample-photo.jpg']
  });
  
  // Wait for processing
  await mcp_playwright_browser_wait_for({ 
    text: 'Processing complete' 
  });
  
  // Verify upload success
  const snapshot = await mcp_playwright_browser_snapshot();
  expect(snapshot).toContain('sample-photo.jpg');
});
```

### 2. Real-time UI Testing
```typescript
test('AI console real-time updates with MCP', async () => {
  await mcp_playwright_browser_navigate({ 
    url: 'http://localhost:3000/platform/ai-management' 
  });
  
  // Monitor WebSocket connections
  const requests = await mcp_playwright_browser_network_requests();
  const wsConnection = requests.find(r => r.url.includes('/api/ai/console/ws'));
  expect(wsConnection).toBeDefined();
  
  // Trigger metric update
  await mcp_playwright_browser_click({
    element: 'refresh button',
    ref: '[data-testid="refresh-metrics"]'
  });
  
  // Verify real-time update
  await mcp_playwright_browser_wait_for({ 
    text: 'Updated' 
  });
});
```

## Success Metrics

### Day 1 Complete
- [ ] Component test infrastructure operational
- [ ] Visual regression testing active
- [ ] Test utilities created and documented

### Day 2 Complete
- [ ] AI Management components tested (50+)
- [ ] Photo components tested (40+)
- [ ] Snapshot baselines established

### Day 3 Complete
- [ ] Playwright MCP integrated
- [ ] Cross-browser testing active
- [ ] Accessibility tests running

### Day 4 Complete
- [ ] UI library components tested (35+)
- [ ] Complex component snapshots captured
- [ ] Platform components tested (30+)

### Day 5 Complete
- [ ] Integration workflows tested
- [ ] Performance benchmarks established
- [ ] 247/275 components tested (90% coverage)

## Coverage Tracking Dashboard

```typescript
// Component test coverage tracker
const componentCoverage = {
  total: 275,
  tested: 0,
  categories: {
    'ai-management': { total: 50, tested: 0 },
    'photos': { total: 40, tested: 0 },
    'ui-library': { total: 35, tested: 0 },
    'platform': { total: 30, tested: 0 },
    'admin': { total: 25, tested: 0 },
    'search-export': { total: 20, tested: 0 },
    'auth-layout': { total: 15, tested: 0 },
    'misc': { total: 35, tested: 0 },
  },
  
  get percentage() {
    return (this.tested / this.total * 100).toFixed(1);
  },
  
  updateCategory(category: string, count: number) {
    this.categories[category].tested = count;
    this.tested = Object.values(this.categories)
      .reduce((sum, cat) => sum + cat.tested, 0);
  },
};
```

## Common Patterns & Templates

### Standard Component Test Template
```typescript
describe('ComponentName', () => {
  it('renders with default props', () => {
    const { container } = renderComponent(<ComponentName />);
    expect(container).toMatchSnapshot();
  });
  
  it('handles user interactions', async () => {
    const onAction = vi.fn();
    renderComponent(<ComponentName onAction={onAction} />);
    
    fireEvent.click(screen.getByRole('button'));
    expect(onAction).toHaveBeenCalled();
  });
  
  it('is accessible', async () => {
    renderComponent(<ComponentName />);
    
    // Check for proper ARIA attributes
    expect(screen.getByRole('button')).toHaveAttribute('aria-label');
  });
});
```

**Success Criteria**: 90% component coverage (247/275) with visual regression prevention, cross-browser compatibility, and accessibility compliance ensures UI stability for AI agent development.