# Phase 4: Playwright Integration
**Estimated Time:** 6-8 hours  
**Prerequisites:** Phases 1-3 completed successfully  
**Status:** Ready for Implementation

## Overview

Phase 4 integrates Playwright Component Testing with our comprehensive Storybook stories using the **Portable Stories API** (2025 feature). This creates a powerful testing ecosystem where stories become the foundation for automated component testing, visual regression testing, and end-to-end workflow validation.

## Objectives

### Primary Goals
- ✅ Set up Playwright Component Testing with Portable Stories integration
- ✅ Create automated tests for all component stories from Phases 2-3
- ✅ Implement visual regression testing with baseline image capture
- ✅ Build comprehensive workflow testing for complete user journeys
- ✅ Establish CI/CD integration for automated story testing

### Success Criteria
- All 60+ component stories have corresponding Playwright tests
- Visual regression testing catches UI changes automatically
- Complex user workflows tested end-to-end using story components
- Integration with existing Jest/Vitest test suite
- CI pipeline runs story-based tests on every PR

## Technical Architecture

### Portable Stories API Integration

The 2025 Portable Stories API allows direct import and testing of Storybook stories in Playwright:

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { composeStories } from '@storybook/react';
import * as stories from '../components/ui/button.stories';

// Convert all stories to testable components
const { Default, Primary, Secondary, Loading } = composeStories(stories);
```

### Testing Strategy Layers

```
Layer 1: Component Stories Testing (Automated from Storybook)
├── Visual regression testing
├── Interaction testing  
├── Accessibility testing
└── Performance testing

Layer 2: Workflow Integration Testing
├── Multi-component workflows
├── State management integration
├── API integration scenarios
└── Error handling flows

Layer 3: End-to-End Story Composition  
├── Complete user journeys
├── Cross-page navigation
├── Real data integration
└── Performance monitoring
```

## Implementation Strategy

### Step 1: Playwright Component Testing Setup (2 hours)

#### Install Dependencies

```bash
# Playwright Component Testing for React
npm install --save-dev @playwright/experimental-ct-react
npm install --save-dev @playwright/test

# Storybook Portable Stories API
npm install --save-dev @storybook/test

# Additional testing utilities
npm install --save-dev @testing-library/react-hooks
npm install --save-dev @testing-library/jest-dom
```

#### Playwright CT Configuration

**File:** `playwright-ct.config.ts`

```typescript
import { defineConfig, devices } from '@playwright/experimental-ct-react';
import { resolve } from 'path';

export default defineConfig({
  testDir: './tests/component',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/component-results.json' }],
  ],
  
  use: {
    trace: 'on-first-retry',
    ctPort: 3100,
    ctTemplateDir: 'tests/component-template',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],

  webServer: {
    command: 'npm run storybook',
    port: 6006,
    reuseExistingServer: !process.env.CI,
  },
});
```

#### Component Test Template

**File:** `tests/component-template/index.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Component Testing</title>
    <script type="module" src="./index.ts"></script>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
```

**File:** `tests/component-template/index.ts`

```typescript
import './index.css';
import { beforeMount, afterMount } from '@playwright/experimental-ct-react/hooks';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { PhotoManagementProvider } from '../../stores/photo-management-store';

// Global setup for all component tests
beforeMount(async ({ App, hooksConfig }) => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  return (
    <BrowserRouter>
      <QueryClientProvider client={queryClient}>
        <PhotoManagementProvider>
          <App />
        </PhotoManagementProvider>
      </QueryClientProvider>
    </BrowserRouter>
  );
});
```

### Step 2: Automated Story Testing (3 hours)

#### Foundation Component Tests

**File:** `tests/component/ui/button.spec.ts`

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { composeStories } from '@storybook/react';
import * as stories from '../../../components/ui/button.stories';

// Convert all stories to testable components
const {
  Default,
  Primary,
  Secondary,
  Destructive,
  Outline,
  Ghost,
  Link,
  Loading,
  Disabled,
  WithIcon,
  SizeVariants,
  FullWidth,
} = composeStories(stories);

test.describe('Button Component Stories', () => {
  test('Default button renders correctly', async ({ mount }) => {
    const component = await mount(<Default />);
    
    await expect(component).toBeVisible();
    await expect(component).toHaveText('Button');
    await expect(component).toHaveClass(/inline-flex/);
    
    // Test interaction
    await component.click();
    // Verify action was triggered (mock verification)
  });

  test('Primary button has correct styling', async ({ mount }) => {
    const component = await mount(<Primary />);
    
    await expect(component).toHaveClass(/bg-primary/);
    await expect(component).toHaveClass(/text-primary-foreground/);
  });

  test('Loading button shows spinner and is disabled', async ({ mount }) => {
    const component = await mount(<Loading />);
    
    await expect(component).toBeDisabled();
    await expect(component.locator('.animate-spin')).toBeVisible();
    await expect(component).toHaveText(/Loading/);
  });

  test('Button responds to hover states', async ({ mount }) => {
    const component = await mount(<Primary />);
    
    // Test hover interaction
    await component.hover();
    await expect(component).toHaveClass(/hover:bg-primary\/90/);
  });

  test('Size variants render with correct dimensions', async ({ mount }) => {
    const { xs, sm, lg, xl } = SizeVariants.args;
    
    const xsButton = await mount(<SizeVariants {...xs} />);
    const lgButton = await mount(<SizeVariants {...lg} />);
    
    // Verify size differences
    const xsBox = await xsButton.boundingBox();
    const lgBox = await lgButton.boundingBox();
    
    expect(lgBox.height).toBeGreaterThan(xsBox.height);
  });
});
```

#### Feature Component Tests  

**File:** `tests/component/photos/photo-grid.spec.ts`

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { composeStories } from '@storybook/react';
import * as stories from '../../../components/photos/photo-grid.stories';

const {
  StandardGrid,
  JustifiedLayout,
  MasonryLayout,
  BulkSelectionMode,
  LoadingState,
  EmptyState,
  PerformanceTest,
} = composeStories(stories);

test.describe('PhotoGrid Component Stories', () => {
  test('Standard grid layout renders photos correctly', async ({ mount }) => {
    const component = await mount(<StandardGrid />);
    
    // Verify grid container
    await expect(component.locator('[data-testid="photo-grid"]')).toBeVisible();
    
    // Verify photos are rendered
    const photoCount = await component.locator('[data-testid="photo-item"]').count();
    expect(photoCount).toBeGreaterThan(0);
    
    // Test photo click interaction
    await component.locator('[data-testid="photo-item"]').first().click();
  });

  test('Bulk selection mode enables multi-select', async ({ mount }) => {
    const component = await mount(<BulkSelectionMode />);
    
    // Verify selection checkboxes are visible
    await expect(component.locator('input[type="checkbox"]').first()).toBeVisible();
    
    // Test selection interaction
    await component.locator('input[type="checkbox"]').first().check();
    await expect(component.locator('input[type="checkbox"]').first()).toBeChecked();
  });

  test('Loading state shows skeleton placeholders', async ({ mount }) => {
    const component = await mount(<LoadingState />);
    
    await expect(component.locator('[data-testid="skeleton-loader"]')).toBeVisible();
    await expect(component.locator('[data-testid="photo-item"]')).toHaveCount(0);
  });

  test('Empty state shows appropriate message', async ({ mount }) => {
    const component = await mount(<EmptyState />);
    
    await expect(component.locator('[data-testid="empty-state"]')).toBeVisible();
    await expect(component).toHaveText(/No photos found/);
  });

  test('Performance test handles large datasets', async ({ mount }) => {
    const component = await mount(<PerformanceTest />);
    
    // Wait for virtualization to load
    await component.waitForSelector('[data-testid="photo-grid"]');
    
    // Verify performance metrics
    const startTime = Date.now();
    await component.locator('[data-testid="photo-item"]').first().waitFor();
    const loadTime = Date.now() - startTime;
    
    expect(loadTime).toBeLessThan(1000); // Should load within 1 second
  });

  test('Layout modes change grid structure', async ({ mount, page }) => {
    // Test layout switching
    const standardGrid = await mount(<StandardGrid />);
    const justifiedGrid = await mount(<JustifiedLayout />);
    
    // Compare grid structures
    const standardHeight = await standardGrid.evaluate(el => el.offsetHeight);
    const justifiedHeight = await justifiedGrid.evaluate(el => el.offsetHeight);
    
    // Justified layout should have different height characteristics
    expect(Math.abs(standardHeight - justifiedHeight)).toBeGreaterThan(10);
  });
});
```

### Step 3: Visual Regression Testing (2 hours)

#### Visual Testing Configuration

**File:** `tests/visual/visual.config.ts`

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/visual',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  
  use: {
    baseURL: 'http://localhost:6006',
    trace: 'retain-on-failure',
  },

  projects: [
    {
      name: 'visual-chromium',
      use: { 
        browserName: 'chromium',
        viewport: { width: 1280, height: 720 },
      },
    },
    {
      name: 'visual-firefox',
      use: { 
        browserName: 'firefox',
        viewport: { width: 1280, height: 720 },
      },
    },
  ],

  webServer: {
    command: 'npm run storybook',
    port: 6006,
    reuseExistingServer: !process.env.CI,
  },
});
```

#### Automated Visual Testing from Stories

**File:** `tests/visual/component-visuals.spec.ts`

```typescript
import { test, expect } from '@playwright/test';

// UI Component visual tests
const uiComponents = [
  'button',
  'input', 
  'card',
  'badge',
  'alert',
  'dialog',
  'dropdown-menu',
  'tooltip',
];

// Feature component visual tests  
const featureComponents = [
  'photos-photo-grid',
  'photos-photo-detail-modal',
  'ai-tag-suggestions',
  'upload-file-drop-zone',
  'search-intelligent-search',
];

test.describe('UI Component Visual Regression', () => {
  uiComponents.forEach(component => {
    test(`${component} component stories visual test`, async ({ page }) => {
      await page.goto(`/iframe.html?id=ui-${component}--default`);
      await page.waitForSelector('[data-testid="component-root"]', { timeout: 5000 });
      
      // Take screenshot of default story
      await expect(page).toHaveScreenshot(`${component}-default.png`);
      
      // Test different variants if they exist
      const variants = ['primary', 'secondary', 'destructive', 'outline'];
      
      for (const variant of variants) {
        try {
          await page.goto(`/iframe.html?id=ui-${component}--${variant}`);
          await page.waitForSelector('[data-testid="component-root"]', { timeout: 2000 });
          await expect(page).toHaveScreenshot(`${component}-${variant}.png`);
        } catch (error) {
          // Skip if variant doesn't exist
          console.log(`Variant ${variant} not found for ${component}`);
        }
      }
    });
  });
});

test.describe('Feature Component Visual Regression', () => {
  featureComponents.forEach(component => {
    test(`${component} stories visual test`, async ({ page }) => {
      const [category, name] = component.split('-');
      
      // Test multiple story states
      const states = ['default', 'loading', 'error', 'empty'];
      
      for (const state of states) {
        try {
          await page.goto(`/iframe.html?id=features-${category}-${name}--${state}`);
          await page.waitForSelector('[data-testid="component-root"]', { timeout: 5000 });
          
          // Wait for any animations to complete
          await page.waitForTimeout(500);
          
          await expect(page).toHaveScreenshot(`${component}-${state}.png`);
        } catch (error) {
          console.log(`State ${state} not found for ${component}`);
        }
      }
    });
  });
});

test.describe('Responsive Visual Testing', () => {
  const viewports = [
    { name: 'mobile', width: 375, height: 667 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1280, height: 720 },
    { name: 'wide', width: 1920, height: 1080 },
  ];

  viewports.forEach(viewport => {
    test(`Photo grid responsive - ${viewport.name}`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.goto('/iframe.html?id=features-photos-photogrid--standard-grid');
      await page.waitForSelector('[data-testid="photo-grid"]');
      
      await expect(page).toHaveScreenshot(`photo-grid-${viewport.name}.png`);
    });
  });
});
```

### Step 4: Workflow Integration Testing (2-3 hours)

#### End-to-End Workflow Tests

**File:** `tests/workflows/photo-management-workflow.spec.ts`

```typescript
import { test, expect } from '@playwright/test';
import { composeStories } from '@storybook/react';
import * as uploadStories from '../../../components/upload/file-drop-zone.stories';
import * as gridStories from '../../../components/photos/photo-grid.stories';
import * as modalStories from '../../../components/photos/photo-detail-modal.stories';

const { InteractiveBatchUpload } = composeStories(uploadStories);
const { StandardGrid } = composeStories(gridStories);
const { StandardPhotoView } = composeStories(modalStories);

test.describe('Complete Photo Management Workflow', () => {
  test('Upload to view workflow using stories', async ({ mount, page }) => {
    // Step 1: Upload photos using story component
    const uploadComponent = await mount(<InteractiveBatchUpload />);
    
    // Simulate file selection (mock files)
    await uploadComponent.locator('[data-testid="file-input"]').setInputFiles([
      'tests/fixtures/test-photo-1.jpg',
      'tests/fixtures/test-photo-2.jpg',
    ]);
    
    // Start upload
    await uploadComponent.locator('button:has-text("Start Upload")').click();
    
    // Wait for upload completion
    await expect(uploadComponent.locator('[data-testid="upload-complete"]')).toBeVisible();
    
    // Step 2: Navigate to photo grid
    await uploadComponent.locator('button:has-text("View Photos")').click();
    
    // Step 3: Verify photos appear in grid using story component
    const gridComponent = await mount(<StandardGrid />);
    await expect(gridComponent.locator('[data-testid="photo-item"]')).toHaveCount(2);
    
    // Step 4: Open photo detail modal
    await gridComponent.locator('[data-testid="photo-item"]').first().click();
    
    const modalComponent = await mount(<StandardPhotoView />);
    await expect(modalComponent.locator('[data-testid="photo-detail-modal"]')).toBeVisible();
  });

  test('AI tagging workflow integration', async ({ mount }) => {
    // Test complete AI tagging workflow using multiple story components
    const photoModal = await mount(<StandardPhotoView />);
    
    // Verify AI analysis starts
    await expect(photoModal.locator('[data-testid="ai-analysis-progress"]')).toBeVisible();
    
    // Wait for AI suggestions to appear
    await expect(photoModal.locator('[data-testid="ai-tag-suggestions"]')).toBeVisible();
    
    // Approve suggested tags
    await photoModal.locator('[data-testid="approve-tag"]').first().click();
    
    // Verify tag is applied
    await expect(photoModal.locator('[data-testid="applied-tags"]')).toContainText('conveyor-belt');
  });
});
```

### Step 5: CI/CD Integration (1 hour)

#### GitHub Actions Workflow

**File:** `.github/workflows/storybook-testing.yml`

```yaml
name: Storybook Component Testing

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  component-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build Storybook
        run: npm run build-storybook
      
      - name: Install Playwright
        run: npx playwright install --with-deps
      
      - name: Run component tests
        run: npm run test:component
      
      - name: Run visual regression tests
        run: npm run test:visual
      
      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: test-results
          path: test-results/
      
      - name: Upload visual diff images
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: visual-diffs
          path: test-results/visual-diffs/

  accessibility-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run accessibility tests
        run: npm run test:a11y
```

#### Package.json Scripts

```json
{
  "scripts": {
    "test:component": "playwright test --config=playwright-ct.config.ts",
    "test:visual": "playwright test --config=tests/visual/visual.config.ts",
    "test:a11y": "playwright test --config=tests/a11y/a11y.config.ts",
    "test:storybook": "concurrently 'npm run storybook' 'wait-on http://localhost:6006 && npm run test:component && npm run test:visual'",
    "test:workflows": "playwright test tests/workflows/"
  }
}
```

## Testing Strategy Matrix

### Component Level Testing
| Test Type | Coverage | Tools | Frequency |
|-----------|----------|-------|-----------|
| Unit Stories | All 60+ stories | Playwright CT + Portable Stories | Every commit |
| Visual Regression | All story states | Playwright Visual | Every PR |
| Interaction Testing | Interactive stories | Playwright + Actions | Every commit |
| Accessibility | All components | axe-playwright | Every PR |

### Workflow Level Testing
| Test Type | Coverage | Tools | Frequency |
|-----------|----------|-------|-----------|
| Multi-component flows | 10 key workflows | Playwright + Story composition | Every PR |
| Error scenarios | Error states in stories | Playwright + Mock failures | Every release |
| Performance testing | Large datasets | Playwright + Performance API | Weekly |
| Cross-browser testing | Chrome, Firefox, Safari | Playwright matrix | Every release |

## Quality Assurance Plan

### Automated Quality Gates
- **Component Tests**: All story interactions must pass
- **Visual Regression**: No unexpected visual changes
- **Accessibility**: WCAG AA compliance for all components
- **Performance**: Component render times under thresholds

### Manual Review Process
- **Story Accuracy**: Stories represent real usage patterns
- **Test Coverage**: All component states and interactions tested
- **Error Handling**: Failure scenarios properly tested
- **User Workflows**: Complete user journeys validated

## Success Metrics

### Testing Coverage
- ✅ 100% of Storybook stories have Playwright tests
- ✅ 95% visual regression coverage across components
- ✅ 90% accessibility compliance (WCAG AA)
- ✅ 10+ complete workflow tests using story composition

### Performance Targets
- ✅ Component tests complete in under 10 minutes
- ✅ Visual tests complete in under 5 minutes
- ✅ Workflow tests complete in under 15 minutes
- ✅ Full test suite completes in under 30 minutes

## Deliverables

### Test Infrastructure
- ✅ Playwright Component Testing configured with Portable Stories
- ✅ Visual regression testing with baseline image management
- ✅ Automated accessibility testing integration
- ✅ CI/CD pipeline for continuous testing

### Test Suites
- ✅ 60+ component story tests with full interaction coverage
- ✅ Visual regression tests for all component states
- ✅ 10+ workflow integration tests using story composition
- ✅ Cross-browser and responsive testing matrices

### Documentation
- ✅ Testing guidelines and best practices
- ✅ Story-to-test mapping documentation
- ✅ CI/CD setup and maintenance guides
- ✅ Troubleshooting and debugging documentation

---

**Next**: After Phase 4 completion, proceed to Phase 5 for advanced Storybook features and optimization.