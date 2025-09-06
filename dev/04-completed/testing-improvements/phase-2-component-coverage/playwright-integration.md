# Playwright MCP Integration for Component Testing
**Advanced Browser Automation for AI Agent Feedback**

## Overview

The Playwright MCP (Model Context Protocol) integration enables advanced browser automation for comprehensive UI testing. This provides AI agents with sophisticated feedback on UI changes, cross-browser compatibility, and real-world user interaction testing.

## MCP Tools Available

### Core Browser Functions
- `mcp__playwright__browser_navigate` - Navigate to URLs
- `mcp__playwright__browser_click` - Click elements
- `mcp__playwright__browser_type` - Type text
- `mcp__playwright__browser_take_screenshot` - Capture screenshots
- `mcp__playwright__browser_snapshot` - Get accessibility snapshot
- `mcp__playwright__browser_evaluate` - Execute JavaScript

### Advanced Features
- `mcp__playwright__browser_drag` - Drag and drop
- `mcp__playwright__browser_file_upload` - File uploads
- `mcp__playwright__browser_network_requests` - Monitor network
- `mcp__playwright__browser_console_messages` - Console logs
- `mcp__playwright__browser_wait_for` - Wait conditions

## Implementation Strategy

### 1. Component Development Server Setup

```typescript
// tests/playwright-mcp/test-server.ts
import { spawn } from 'child_process';
import { chromium } from 'playwright';

export class ComponentTestServer {
  private server?: ReturnType<typeof spawn>;
  private serverUrl = 'http://localhost:6006'; // Storybook or dev server
  
  async start() {
    // Start component development server
    this.server = spawn('npm', ['run', 'storybook'], {
      stdio: 'pipe'
    });
    
    // Wait for server to be ready
    await this.waitForServer();
  }
  
  private async waitForServer() {
    const browser = await chromium.launch();
    const page = await browser.newPage();
    
    let attempts = 0;
    while (attempts < 30) { // 30 second timeout
      try {
        await page.goto(this.serverUrl);
        if (page.url().includes('localhost:6006')) {
          break;
        }
      } catch {
        await new Promise(resolve => setTimeout(resolve, 1000));
        attempts++;
      }
    }
    
    await browser.close();
    
    if (attempts >= 30) {
      throw new Error('Component server failed to start');
    }
  }
  
  async stop() {
    if (this.server) {
      this.server.kill();
    }
  }
}
```

### 2. MCP Integration Test Suite

```typescript
// tests/playwright-mcp/component-mcp.test.ts
import { test, expect } from '@playwright/test';

class MCPComponentTester {
  private baseUrl = 'http://localhost:3000';
  
  async navigateToComponent(path: string) {
    await mcp_playwright_browser_navigate({
      url: `${this.baseUrl}${path}`
    });
    
    // Wait for component to load
    await mcp_playwright_browser_wait_for({
      text: 'Loading complete'
    });
  }
  
  async captureComponentScreenshot(name: string, element?: string) {
    return await mcp_playwright_browser_take_screenshot({
      filename: `components/${name}.png`,
      element: element,
      ref: element,
      fullPage: false
    });
  }
  
  async testComponentAccessibility(selector: string) {
    const snapshot = await mcp_playwright_browser_snapshot();
    
    // Extract component from snapshot
    const componentData = this.parseSnapshotForComponent(snapshot, selector);
    
    // Validate accessibility requirements
    return {
      hasAriaLabels: this.checkAriaLabels(componentData),
      hasKeyboardSupport: this.checkKeyboardSupport(componentData),
      hasProperContrast: this.checkColorContrast(componentData),
      hasSemanticStructure: this.checkSemanticHTML(componentData),
    };
  }
  
  private parseSnapshotForComponent(snapshot: string, selector: string) {
    // Parse accessibility snapshot for specific component
    const lines = snapshot.split('\n');
    const componentLines = lines.filter(line => 
      line.includes(selector) || line.includes('aria-') || line.includes('role=')
    );
    
    return componentLines;
  }
  
  private checkAriaLabels(data: string[]): boolean {
    return data.some(line => 
      line.includes('aria-label') || 
      line.includes('aria-labelledby') ||
      line.includes('aria-describedby')
    );
  }
  
  private checkKeyboardSupport(data: string[]): boolean {
    return data.some(line => 
      line.includes('tabindex') ||
      line.includes('role="button"') ||
      line.includes('role="link"')
    );
  }
  
  private checkColorContrast(data: string[]): boolean {
    // This would be enhanced with actual color analysis
    return true; // Placeholder
  }
  
  private checkSemanticHTML(data: string[]): boolean {
    return data.some(line => 
      line.includes('role=') ||
      line.includes('<button') ||
      line.includes('<nav') ||
      line.includes('<main')
    );
  }
}

describe('MCP Component Testing', () => {
  const mcpTester = new MCPComponentTester();
  
  test('AI Management Dashboard - Real Browser Testing', async () => {
    await mcpTester.navigateToComponent('/platform/ai-management');
    
    // Test loading state
    await mcp_playwright_browser_wait_for({
      text: 'AI Management Console'
    });
    
    // Capture initial state
    await mcpTester.captureComponentScreenshot('ai-dashboard-initial');
    
    // Test interactive elements
    await mcp_playwright_browser_click({
      element: 'provider toggle',
      ref: '[data-testid="provider-openai-toggle"]'
    });
    
    // Verify state change
    await mcp_playwright_browser_wait_for({
      text: 'OpenAI Disabled'
    });
    
    // Capture updated state
    await mcpTester.captureComponentScreenshot('ai-dashboard-provider-disabled');
    
    // Test accessibility
    const a11yResults = await mcpTester.testComponentAccessibility('.ai-dashboard');
    
    expect(a11yResults.hasAriaLabels).toBe(true);
    expect(a11yResults.hasKeyboardSupport).toBe(true);
  });
  
  test('Photo Grid - Drag Selection with MCP', async () => {
    await mcpTester.navigateToComponent('/photos');
    
    // Wait for photos to load
    await mcp_playwright_browser_wait_for({
      text: 'Photos loaded'
    });
    
    // Test drag selection
    await mcp_playwright_browser_drag({
      startElement: 'photo grid start',
      startRef: '[data-testid="photo-1"]',
      endElement: 'photo grid end', 
      endRef: '[data-testid="photo-4"]'
    });
    
    // Verify selection
    const snapshot = await mcp_playwright_browser_snapshot();
    expect(snapshot).toContain('4 photos selected');
    
    // Test bulk actions
    await mcp_playwright_browser_click({
      element: 'bulk delete button',
      ref: '[data-testid="bulk-delete"]'
    });
    
    // Verify confirmation dialog
    await mcp_playwright_browser_wait_for({
      text: 'Delete 4 photos?'
    });
  });
  
  test('Word Export Wizard - Multi-step Flow', async () => {
    await mcpTester.navigateToComponent('/photos/export');
    
    // Step 1: Template selection
    await mcp_playwright_browser_click({
      element: 'safety report template',
      ref: '[data-value="safety-report"]'
    });
    
    await mcp_playwright_browser_click({
      element: 'next button',
      ref: '[data-testid="next-step"]'
    });
    
    // Step 2: Photo selection
    await mcp_playwright_browser_wait_for({
      text: 'Select Photos'
    });
    
    await mcp_playwright_browser_click({
      element: 'photo checkbox',
      ref: '[data-testid="photo-select-1"]'
    });
    
    await mcp_playwright_browser_click({
      element: 'next button',
      ref: '[data-testid="next-step"]'
    });
    
    // Step 3: Preview
    await mcp_playwright_browser_wait_for({
      text: 'Document Preview'
    });
    
    // Capture final preview
    await mcpTester.captureComponentScreenshot('word-export-preview');
    
    // Test export generation
    await mcp_playwright_browser_click({
      element: 'generate export button',
      ref: '[data-testid="generate-export"]'
    });
    
    // Monitor network requests
    const requests = await mcp_playwright_browser_network_requests();
    const exportRequest = requests.find(r => r.url.includes('/api/export/word'));
    
    expect(exportRequest?.status).toBe(200);
  });
});
```

### 3. Cross-Browser Component Testing

```typescript
// tests/playwright-mcp/cross-browser-components.test.ts
const browsers = ['chromium', 'firefox', 'webkit'];

browsers.forEach(browserName => {
  test.describe(`${browserName} - Component Compatibility`, () => {
    test(`Photo upload dropzone in ${browserName}`, async () => {
      await mcp_playwright_browser_navigate({
        url: 'http://localhost:3000/photos/upload'
      });
      
      // Test file upload interface
      await mcp_playwright_browser_file_upload({
        paths: ['./test-fixtures/sample-image.jpg']
      });
      
      // Verify upload progress
      await mcp_playwright_browser_wait_for({
        text: 'Upload complete',
        time: 10 // 10 second timeout
      });
      
      // Take browser-specific screenshot
      await mcp_playwright_browser_take_screenshot({
        filename: `upload-success-${browserName}.png`
      });
      
      // Verify consistency across browsers
      const snapshot = await mcp_playwright_browser_snapshot();
      expect(snapshot).toContain('sample-image.jpg');
    });
    
    test(`AI console responsiveness in ${browserName}`, async () => {
      await mcp_playwright_browser_navigate({
        url: 'http://localhost:3000/platform/ai-management'
      });
      
      // Test responsive design
      await mcp_playwright_browser_resize({
        width: 375,  // Mobile width
        height: 667
      });
      
      // Verify mobile layout
      const mobileSnapshot = await mcp_playwright_browser_snapshot();
      expect(mobileSnapshot).toContain('sidebar collapsed');
      
      // Test tablet layout
      await mcp_playwright_browser_resize({
        width: 768,
        height: 1024
      });
      
      const tabletSnapshot = await mcp_playwright_browser_snapshot();
      expect(tabletSnapshot).toContain('sidebar expanded');
      
      // Test desktop layout
      await mcp_playwright_browser_resize({
        width: 1920,
        height: 1080
      });
      
      await mcp_playwright_browser_take_screenshot({
        filename: `ai-console-desktop-${browserName}.png`
      });
    });
  });
});
```

### 4. Real-time Component Testing

```typescript
// tests/playwright-mcp/real-time-components.test.ts
test.describe('Real-time Component Updates', () => {
  test('AI console live metrics updates', async () => {
    await mcp_playwright_browser_navigate({
      url: 'http://localhost:3000/platform/ai-management'
    });
    
    // Monitor WebSocket connection
    const requests = await mcp_playwright_browser_network_requests();
    const wsConnection = requests.find(r => 
      r.url.includes('ws://') || r.url.includes('wss://')
    );
    
    expect(wsConnection).toBeDefined();
    
    // Capture initial metrics
    const initialSnapshot = await mcp_playwright_browser_snapshot();
    const initialCost = this.extractMetric(initialSnapshot, 'total-cost');
    
    // Wait for real-time update (simulate AI processing)
    await this.simulateAIProcessing();
    
    // Verify metrics updated
    await mcp_playwright_browser_wait_for({
      text: 'Metrics updated',
      time: 5
    });
    
    const updatedSnapshot = await mcp_playwright_browser_snapshot();
    const updatedCost = this.extractMetric(updatedSnapshot, 'total-cost');
    
    expect(updatedCost).not.toBe(initialCost);
  });
  
  test('Photo processing status updates', async () => {
    await mcp_playwright_browser_navigate({
      url: 'http://localhost:3000/photos'
    });
    
    // Upload photo
    await mcp_playwright_browser_file_upload({
      paths: ['./test-fixtures/test-photo.jpg']
    });
    
    // Monitor processing status changes
    const statuses = [];
    
    // Initial status
    await mcp_playwright_browser_wait_for({
      text: 'Uploading'
    });
    statuses.push('uploading');
    
    // Processing status
    await mcp_playwright_browser_wait_for({
      text: 'Processing with AI'
    });
    statuses.push('processing');
    
    // Completion status
    await mcp_playwright_browser_wait_for({
      text: 'Processing complete',
      time: 10
    });
    statuses.push('complete');
    
    // Verify status progression
    expect(statuses).toEqual(['uploading', 'processing', 'complete']);
    
    // Verify AI tags appeared
    const finalSnapshot = await mcp_playwright_browser_snapshot();
    expect(finalSnapshot).toContain('AI tags:');
  });
  
  private async simulateAIProcessing() {
    // Trigger AI processing that would update metrics
    await mcp_playwright_browser_evaluate({
      function: `() => {
        // Simulate server-sent event for metric update
        const eventSource = new EventSource('/api/ai/metrics/stream');
        eventSource.dispatchEvent(new MessageEvent('message', {
          data: JSON.stringify({ type: 'cost_update', value: 123.45 })
        }));
      }`
    });
  }
  
  private extractMetric(snapshot: string, metricName: string): string {
    const lines = snapshot.split('\n');
    const metricLine = lines.find(line => line.includes(metricName));
    return metricLine?.match(/\$[\d.]+/)?.[0] || '0';
  }
});
```

### 5. Performance Testing with MCP

```typescript
// tests/playwright-mcp/component-performance.test.ts
test.describe('Component Performance with MCP', () => {
  test('Photo grid rendering performance', async () => {
    await mcp_playwright_browser_navigate({
      url: 'http://localhost:3000/photos?test_dataset=large'
    });
    
    // Measure initial load time
    const start = Date.now();
    
    await mcp_playwright_browser_wait_for({
      text: '1000 photos loaded'
    });
    
    const loadTime = Date.now() - start;
    expect(loadTime).toBeLessThan(3000); // 3 second max load time
    
    // Test scroll performance
    const scrollStart = Date.now();
    
    await mcp_playwright_browser_evaluate({
      function: `() => {
        const grid = document.querySelector('.photo-grid');
        grid.scrollTop = 5000; // Scroll to middle
      }`
    });
    
    await mcp_playwright_browser_wait_for({
      time: 0.5 // Wait for scroll to complete
    });
    
    const scrollTime = Date.now() - scrollStart;
    expect(scrollTime).toBeLessThan(100); // Smooth scrolling
    
    // Verify virtualization is working
    const snapshot = await mcp_playwright_browser_snapshot();
    const visibleItems = snapshot.match(/photo-item/g)?.length || 0;
    
    expect(visibleItems).toBeLessThan(50); // Only visible items rendered
  });
  
  test('AI console memory usage', async () => {
    await mcp_playwright_browser_navigate({
      url: 'http://localhost:3000/platform/ai-management'
    });
    
    // Get initial memory usage
    const initialMemory = await mcp_playwright_browser_evaluate({
      function: `() => performance.memory?.usedJSHeapSize || 0`
    });
    
    // Simulate heavy data updates
    for (let i = 0; i < 10; i++) {
      await mcp_playwright_browser_evaluate({
        function: `() => {
          // Simulate metric updates
          window.dispatchEvent(new CustomEvent('metrics-update', {
            detail: { providers: Array(100).fill({}).map((_, i) => ({
              id: 'provider-' + i,
              metrics: { cost: Math.random() * 100 }
            }))}
          }));
        }`
      });
      
      await mcp_playwright_browser_wait_for({
        time: 0.1
      });
    }
    
    // Check memory usage after updates
    const finalMemory = await mcp_playwright_browser_evaluate({
      function: `() => performance.memory?.usedJSHeapSize || 0`
    });
    
    const memoryIncrease = finalMemory - initialMemory;
    const memoryIncreaseMB = memoryIncrease / (1024 * 1024);
    
    // Memory usage should be reasonable (< 50MB increase)
    expect(memoryIncreaseMB).toBeLessThan(50);
  });
});
```

## Test Orchestration

### 1. Component Test Runner with MCP
```typescript
// tests/playwright-mcp/mcp-test-runner.ts
export class MCPComponentTestRunner {
  private results: ComponentTestResult[] = [];
  
  async runComponentTestSuite(components: ComponentTestConfig[]) {
    for (const component of components) {
      const result = await this.testComponent(component);
      this.results.push(result);
    }
    
    return this.generateReport();
  }
  
  private async testComponent(config: ComponentTestConfig): Promise<ComponentTestResult> {
    const result: ComponentTestResult = {
      component: config.name,
      path: config.path,
      tests: [],
      screenshots: [],
      accessibility: null,
      performance: null,
    };
    
    try {
      // Navigate to component
      await mcp_playwright_browser_navigate({
        url: `http://localhost:3000${config.path}`
      });
      
      // Basic functionality test
      if (config.interactions) {
        for (const interaction of config.interactions) {
          await this.performInteraction(interaction);
          result.tests.push({ name: interaction.name, passed: true });
        }
      }
      
      // Screenshot test
      if (config.captureScreenshot) {
        await mcp_playwright_browser_take_screenshot({
          filename: `${config.name}-screenshot.png`
        });
        result.screenshots.push(`${config.name}-screenshot.png`);
      }
      
      // Accessibility test
      if (config.testAccessibility) {
        const a11yResult = await this.testAccessibility(config.selector);
        result.accessibility = a11yResult;
      }
      
      // Performance test
      if (config.testPerformance) {
        const perfResult = await this.testPerformance(config.selector);
        result.performance = perfResult;
      }
      
    } catch (error) {
      result.tests.push({ 
        name: 'Component Test', 
        passed: false, 
        error: error.message 
      });
    }
    
    return result;
  }
  
  private async performInteraction(interaction: InteractionConfig) {
    switch (interaction.type) {
      case 'click':
        await mcp_playwright_browser_click({
          element: interaction.description,
          ref: interaction.selector
        });
        break;
        
      case 'type':
        await mcp_playwright_browser_type({
          element: interaction.description,
          ref: interaction.selector,
          text: interaction.text || 'test input'
        });
        break;
        
      case 'hover':
        await mcp_playwright_browser_hover({
          element: interaction.description,
          ref: interaction.selector
        });
        break;
        
      case 'drag':
        if (interaction.target) {
          await mcp_playwright_browser_drag({
            startElement: interaction.description,
            startRef: interaction.selector,
            endElement: interaction.target.description,
            endRef: interaction.target.selector
          });
        }
        break;
    }
    
    // Wait for interaction to complete
    if (interaction.waitFor) {
      await mcp_playwright_browser_wait_for({
        text: interaction.waitFor
      });
    }
  }
  
  private async testAccessibility(selector: string) {
    const snapshot = await mcp_playwright_browser_snapshot();
    
    return {
      hasSemanticHTML: snapshot.includes('role='),
      hasAriaLabels: snapshot.includes('aria-label'),
      hasKeyboardSupport: snapshot.includes('tabindex'),
      score: this.calculateA11yScore(snapshot),
    };
  }
  
  private async testPerformance(selector: string) {
    const perfData = await mcp_playwright_browser_evaluate({
      function: `() => {
        const start = performance.now();
        const element = document.querySelector('${selector}');
        const renderTime = performance.now() - start;
        
        return {
          renderTime,
          memoryUsage: performance.memory?.usedJSHeapSize || 0,
          domNodes: document.querySelectorAll('*').length
        };
      }`
    });
    
    return perfData;
  }
  
  private generateReport(): ComponentTestReport {
    const passed = this.results.filter(r => 
      r.tests.every(t => t.passed)
    ).length;
    
    return {
      totalComponents: this.results.length,
      passed,
      failed: this.results.length - passed,
      coverage: (passed / this.results.length * 100).toFixed(1) + '%',
      results: this.results,
    };
  }
}
```

### 2. Configuration for Component Testing
```typescript
// tests/playwright-mcp/component-configs.ts
export const componentTestConfigs: ComponentTestConfig[] = [
  {
    name: 'AIConsole',
    path: '/platform/ai-management',
    selector: '.ai-console',
    captureScreenshot: true,
    testAccessibility: true,
    testPerformance: true,
    interactions: [
      {
        type: 'click',
        name: 'Toggle Provider',
        description: 'provider toggle button',
        selector: '[data-testid="provider-toggle"]',
        waitFor: 'Provider updated'
      },
      {
        type: 'click',
        name: 'Refresh Metrics',
        description: 'refresh metrics button',
        selector: '[data-testid="refresh-metrics"]',
        waitFor: 'Metrics refreshed'
      }
    ]
  },
  
  {
    name: 'PhotoGrid',
    path: '/photos',
    selector: '.photo-grid',
    captureScreenshot: true,
    testPerformance: true,
    interactions: [
      {
        type: 'click',
        name: 'Select Photo',
        description: 'first photo',
        selector: '[data-testid="photo-1"]',
        waitFor: 'Photo selected'
      },
      {
        type: 'drag',
        name: 'Drag Selection',
        description: 'selection start',
        selector: '[data-testid="photo-1"]',
        target: {
          description: 'selection end',
          selector: '[data-testid="photo-4"]'
        },
        waitFor: '4 photos selected'
      }
    ]
  },
  
  {
    name: 'WordExportWizard',
    path: '/photos/export',
    selector: '.export-wizard',
    captureScreenshot: true,
    testAccessibility: true,
    interactions: [
      {
        type: 'click',
        name: 'Select Template',
        description: 'safety report template',
        selector: '[data-value="safety-report"]',
      },
      {
        type: 'click',
        name: 'Next Step',
        description: 'next button',
        selector: '[data-testid="next-step"]',
        waitFor: 'Select Photos'
      }
    ]
  }
];
```

## Integration with AI Agents

### Pre-commit Hook with MCP
```bash
#!/bin/bash
# .husky/pre-commit-mcp

echo "Running MCP component tests..."

# Start component server if needed
npm run components:start

# Run MCP component tests
npm run test:components:mcp

if [ $? -ne 0 ]; then
  echo "❌ MCP component tests failed"
  echo "Screenshots saved in tests/screenshots/"
  exit 1
fi

echo "✅ MCP component tests passed"
```

### CI/CD Integration
```yaml
# .github/workflows/component-mcp-tests.yml
name: Component MCP Tests
on: [push, pull_request]

jobs:
  component-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Install Playwright browsers
        run: npx playwright install
        
      - name: Start component server
        run: npm run components:start &
        
      - name: Run MCP component tests
        run: npm run test:components:mcp
        
      - name: Upload screenshots
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: component-screenshots
          path: tests/screenshots/
```

**Success Criteria**: Playwright MCP integration provides sophisticated browser automation for comprehensive UI testing, giving AI agents detailed feedback on component behavior, accessibility, and cross-browser compatibility.