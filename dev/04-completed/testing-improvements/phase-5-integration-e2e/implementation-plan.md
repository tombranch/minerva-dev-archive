# Phase 5: Integration & E2E Testing Implementation
**Week 5 - Complete User Journey Validation**

*Duration: 5 days*  
*Target: All MVP features E2E tested*  
*Focus: Playwright MCP for real browser automation*

---

## Overview

End-to-end testing validates complete user workflows using real browsers. This ensures AI agents understand the full impact of their changes on user experience and critical business flows.

## Day-by-Day Implementation

### Day 1: E2E Test Infrastructure
**Time: 4 hours**

```typescript
// tests/e2e/e2e-test-framework.ts
export class E2ETestFramework {
  private testData: TestDataManager;
  private screenshots: string[] = [];
  
  constructor() {
    this.testData = new TestDataManager();
  }
  
  async setupTestEnvironment() {
    // Create isolated test organizations and users
    await this.testData.createTestOrganizations([
      { id: 'e2e-org-1', name: 'E2E Test Organization 1' },
      { id: 'e2e-org-2', name: 'E2E Test Organization 2' },
    ]);
    
    await this.testData.createTestUsers([
      { email: 'admin@e2e-org1.com', orgId: 'e2e-org-1', role: 'admin' },
      { email: 'engineer@e2e-org1.com', orgId: 'e2e-org-1', role: 'engineer' },
      { email: 'viewer@e2e-org1.com', orgId: 'e2e-org-1', role: 'viewer' },
    ]);
    
    await this.testData.seedTestPhotos();
  }
  
  async runE2EWorkflow(workflow: E2EWorkflow): Promise<E2EResult> {
    const startTime = Date.now();
    
    try {
      // Navigate to starting point
      await mcp_playwright_browser_navigate({
        url: workflow.startUrl
      });
      
      // Execute workflow steps
      for (const step of workflow.steps) {
        await this.executeStep(step);
        
        // Take screenshot after each step
        const screenshot = await mcp_playwright_browser_take_screenshot({
          filename: `${workflow.name}-step-${step.order}.png`
        });
        this.screenshots.push(screenshot);
        
        // Validate step completion
        if (step.validation) {
          await this.validateStep(step);
        }
      }
      
      return {
        workflow: workflow.name,
        success: true,
        duration: Date.now() - startTime,
        screenshots: this.screenshots,
        steps: workflow.steps.length,
        error: null,
      };
      
    } catch (error) {
      return {
        workflow: workflow.name,
        success: false,
        duration: Date.now() - startTime,
        screenshots: this.screenshots,
        steps: 0,
        error: error.message,
      };
    }
  }
  
  private async executeStep(step: WorkflowStep) {
    switch (step.action.type) {
      case 'click':
        await mcp_playwright_browser_click({
          element: step.action.description,
          ref: step.action.selector
        });
        break;
        
      case 'type':
        await mcp_playwright_browser_type({
          element: step.action.description,
          ref: step.action.selector,
          text: step.action.text
        });
        break;
        
      case 'upload':
        await mcp_playwright_browser_file_upload({
          paths: step.action.files
        });
        break;
        
      case 'wait':
        await mcp_playwright_browser_wait_for({
          text: step.action.condition,
          time: step.action.timeout
        });
        break;
        
      case 'drag':
        await mcp_playwright_browser_drag({
          startElement: step.action.startDescription,
          startRef: step.action.startSelector,
          endElement: step.action.endDescription,
          endRef: step.action.endSelector
        });
        break;
    }
    
    // Wait for any animations or processing
    if (step.action.waitAfter) {
      await mcp_playwright_browser_wait_for({
        time: step.action.waitAfter
      });
    }
  }
  
  private async validateStep(step: WorkflowStep) {
    const snapshot = await mcp_playwright_browser_snapshot();
    
    for (const validation of step.validation!) {
      switch (validation.type) {
        case 'text_present':
          if (!snapshot.includes(validation.text)) {
            throw new Error(`Expected text "${validation.text}" not found`);
          }
          break;
          
        case 'element_visible':
          if (!snapshot.includes(validation.selector)) {
            throw new Error(`Element "${validation.selector}" not visible`);
          }
          break;
          
        case 'url_contains':
          // Get current URL from snapshot or use evaluate
          const currentUrl = await mcp_playwright_browser_evaluate({
            function: '() => window.location.href'
          });
          if (!currentUrl.includes(validation.text)) {
            throw new Error(`URL does not contain "${validation.text}"`);
          }
          break;
      }
    }
  }
}
```

### Day 2: Authentication & Organization Workflows
**Time: 5 hours**

```typescript
// tests/e2e/workflows/auth-workflows.test.ts
import { test, expect } from '@playwright/test';
import { E2ETestFramework } from '../e2e-test-framework';

test.describe('Authentication Workflows', () => {
  const e2e = new E2ETestFramework();
  
  test.beforeEach(async () => {
    await e2e.setupTestEnvironment();
  });
  
  test('Complete user onboarding flow', async () => {
    const result = await e2e.runE2EWorkflow({
      name: 'user-onboarding',
      startUrl: 'http://localhost:3000/auth/signup',
      steps: [
        {
          order: 1,
          name: 'Fill signup form',
          action: {
            type: 'type',
            description: 'email input',
            selector: 'input[name="email"]',
            text: 'newuser@example.com'
          }
        },
        {
          order: 2,
          name: 'Enter password',
          action: {
            type: 'type',
            description: 'password input',
            selector: 'input[name="password"]',
            text: 'SecurePassword123!'
          }
        },
        {
          order: 3,
          name: 'Submit signup',
          action: {
            type: 'click',
            description: 'signup button',
            selector: 'button[type="submit"]'
          },
          validation: [
            { type: 'text_present', text: 'Check your email' }
          ]
        },
        {
          order: 4,
          name: 'Verify email simulation',
          action: {
            type: 'click',
            description: 'verify link simulation',
            selector: '[data-testid="mock-verify-email"]'
          }
        },
        {
          order: 5,
          name: 'Organization setup',
          action: {
            type: 'type',
            description: 'organization name',
            selector: 'input[name="organizationName"]',
            text: 'Test Manufacturing Co'
          }
        },
        {
          order: 6,
          name: 'Complete onboarding',
          action: {
            type: 'click',
            description: 'complete setup button',
            selector: 'button[data-testid="complete-setup"]'
          },
          validation: [
            { type: 'url_contains', text: '/dashboard' },
            { type: 'text_present', text: 'Welcome to Minerva' }
          ]
        }
      ]
    });
    
    expect(result.success).toBe(true);
    expect(result.steps).toBe(6);
    expect(result.duration).toBeLessThan(30000); // 30 seconds
  });
  
  test('Organization switching workflow', async () => {
    // Pre-setup user with multiple org access
    await e2e.testData.createUserWithMultipleOrgs('multiorg@test.com', [
      'e2e-org-1', 'e2e-org-2'
    ]);
    
    const result = await e2e.runE2EWorkflow({
      name: 'organization-switching',
      startUrl: 'http://localhost:3000/auth/login',
      steps: [
        {
          order: 1,
          name: 'Login',
          action: {
            type: 'type',
            description: 'email input',
            selector: 'input[name="email"]',
            text: 'multiorg@test.com'
          }
        },
        {
          order: 2,
          name: 'Enter password',
          action: {
            type: 'type', 
            description: 'password input',
            selector: 'input[name="password"]',
            text: 'test123'
          }
        },
        {
          order: 3,
          name: 'Submit login',
          action: {
            type: 'click',
            description: 'login button',
            selector: 'button[type="submit"]'
          }
        },
        {
          order: 4,
          name: 'Select organization',
          action: {
            type: 'click',
            description: 'org selector',
            selector: '[data-testid="org-selector"]'
          }
        },
        {
          order: 5,
          name: 'Choose first org',
          action: {
            type: 'click',
            description: 'org option 1',
            selector: '[data-testid="org-option-e2e-org-1"]'
          },
          validation: [
            { type: 'text_present', text: 'E2E Test Organization 1' }
          ]
        },
        {
          order: 6,
          name: 'Switch to second org',
          action: {
            type: 'click',
            description: 'org switcher',
            selector: '[data-testid="org-switcher"]'
          }
        },
        {
          order: 7,
          name: 'Select second org',
          action: {
            type: 'click',
            description: 'org option 2',
            selector: '[data-testid="org-option-e2e-org-2"]'
          },
          validation: [
            { type: 'text_present', text: 'E2E Test Organization 2' }
          ]
        }
      ]
    });
    
    expect(result.success).toBe(true);
    expect(result.steps).toBe(7);
  });
});
```

### Day 3: Photo Management Workflows
**Time: 5 hours**

```typescript
// tests/e2e/workflows/photo-workflows.test.ts
test.describe('Photo Management Workflows', () => {
  const e2e = new E2ETestFramework();
  
  test('Complete photo upload and processing workflow', async () => {
    const result = await e2e.runE2EWorkflow({
      name: 'photo-upload-processing',
      startUrl: 'http://localhost:3000/photos',
      steps: [
        {
          order: 1,
          name: 'Navigate to upload',
          action: {
            type: 'click',
            description: 'upload button',
            selector: '[data-testid="upload-photos-btn"]'
          }
        },
        {
          order: 2,
          name: 'Upload test photo',
          action: {
            type: 'upload',
            description: 'photo upload',
            files: ['./test-fixtures/safety-equipment-1.jpg']
          },
          validation: [
            { type: 'text_present', text: 'Upload in progress' }
          ]
        },
        {
          order: 3,
          name: 'Wait for upload completion',
          action: {
            type: 'wait',
            condition: 'Upload complete',
            timeout: 10
          }
        },
        {
          order: 4,
          name: 'Wait for AI processing',
          action: {
            type: 'wait',
            condition: 'AI analysis complete',
            timeout: 15
          },
          validation: [
            { type: 'text_present', text: 'AI tags suggested' }
          ]
        },
        {
          order: 5,
          name: 'Review AI suggestions',
          action: {
            type: 'click',
            description: 'view suggestions',
            selector: '[data-testid="view-ai-suggestions"]'
          }
        },
        {
          order: 6,
          name: 'Accept AI tags',
          action: {
            type: 'click',
            description: 'accept tags button',
            selector: '[data-testid="accept-ai-tags"]'
          }
        },
        {
          order: 7,
          name: 'Add custom tag',
          action: {
            type: 'type',
            description: 'custom tag input',
            selector: 'input[data-testid="custom-tag-input"]',
            text: 'safety-inspection'
          }
        },
        {
          order: 8,
          name: 'Save photo',
          action: {
            type: 'click',
            description: 'save photo button',
            selector: '[data-testid="save-photo"]'
          },
          validation: [
            { type: 'text_present', text: 'Photo saved successfully' },
            { type: 'url_contains', text: '/photos' }
          ]
        }
      ]
    });
    
    expect(result.success).toBe(true);
    expect(result.duration).toBeLessThan(45000); // 45 seconds
  });
  
  test('Bulk operations workflow', async () => {
    // Pre-seed photos for bulk operations
    await e2e.testData.createTestPhotos(10, 'e2e-org-1');
    
    const result = await e2e.runE2EWorkflow({
      name: 'bulk-photo-operations',
      startUrl: 'http://localhost:3000/photos',
      steps: [
        {
          order: 1,
          name: 'Enter selection mode',
          action: {
            type: 'click',
            description: 'select mode button',
            selector: '[data-testid="selection-mode-btn"]'
          }
        },
        {
          order: 2,
          name: 'Drag select photos',
          action: {
            type: 'drag',
            startDescription: 'selection area start',
            startSelector: '[data-testid="photo-1"]',
            endDescription: 'selection area end',
            endSelector: '[data-testid="photo-5"]'
          },
          validation: [
            { type: 'text_present', text: '5 photos selected' }
          ]
        },
        {
          order: 3,
          name: 'Open bulk actions menu',
          action: {
            type: 'click',
            description: 'bulk actions button',
            selector: '[data-testid="bulk-actions-btn"]'
          }
        },
        {
          order: 4,
          name: 'Select bulk tag operation',
          action: {
            type: 'click',
            description: 'bulk tag option',
            selector: '[data-testid="bulk-tag-option"]'
          }
        },
        {
          order: 5,
          name: 'Enter bulk tag',
          action: {
            type: 'type',
            description: 'bulk tag input',
            selector: 'input[data-testid="bulk-tag-input"]',
            text: 'bulk-operation-test'
          }
        },
        {
          order: 6,
          name: 'Apply bulk tags',
          action: {
            type: 'click',
            description: 'apply tags button',
            selector: '[data-testid="apply-bulk-tags"]'
          },
          validation: [
            { type: 'text_present', text: '5 photos updated' }
          ]
        },
        {
          order: 7,
          name: 'Verify tag application',
          action: {
            type: 'click',
            description: 'first photo',
            selector: '[data-testid="photo-1"]'
          },
          validation: [
            { type: 'text_present', text: 'bulk-operation-test' }
          ]
        }
      ]
    });
    
    expect(result.success).toBe(true);
  });
});
```

### Day 4: AI Management & Export Workflows
**Time: 5 hours**

```typescript
// tests/e2e/workflows/ai-management-workflows.test.ts
test.describe('AI Management Workflows', () => {
  const e2e = new E2ETestFramework();
  
  test('AI provider configuration workflow', async () => {
    const result = await e2e.runE2EWorkflow({
      name: 'ai-provider-config',
      startUrl: 'http://localhost:3000/platform/ai-management',
      steps: [
        {
          order: 1,
          name: 'Navigate to providers',
          action: {
            type: 'click',
            description: 'providers tab',
            selector: '[data-testid="providers-tab"]'
          }
        },
        {
          order: 2,
          name: 'Configure OpenAI provider',
          action: {
            type: 'click',
            description: 'openai config',
            selector: '[data-testid="provider-openai-config"]'
          }
        },
        {
          order: 3,
          name: 'Update model selection',
          action: {
            type: 'click',
            description: 'model dropdown',
            selector: '[data-testid="openai-model-select"]'
          }
        },
        {
          order: 4,
          name: 'Select GPT-4 Vision',
          action: {
            type: 'click',
            description: 'gpt-4 vision option',
            selector: '[data-value="gpt-4-vision-preview"]'
          }
        },
        {
          order: 5,
          name: 'Test provider configuration',
          action: {
            type: 'click',
            description: 'test provider button',
            selector: '[data-testid="test-provider-btn"]'
          }
        },
        {
          order: 6,
          name: 'Wait for test results',
          action: {
            type: 'wait',
            condition: 'Provider test complete',
            timeout: 10
          },
          validation: [
            { type: 'text_present', text: 'Test successful' }
          ]
        },
        {
          order: 7,
          name: 'Save configuration',
          action: {
            type: 'click',
            description: 'save config button',
            selector: '[data-testid="save-config-btn"]'
          },
          validation: [
            { type: 'text_present', text: 'Configuration saved' }
          ]
        }
      ]
    });
    
    expect(result.success).toBe(true);
  });
  
  test('AI experiment setup workflow', async () => {
    const result = await e2e.runE2EWorkflow({
      name: 'ai-experiment-setup',
      startUrl: 'http://localhost:3000/platform/ai-management/experiments',
      steps: [
        {
          order: 1,
          name: 'Create new experiment',
          action: {
            type: 'click',
            description: 'new experiment button',
            selector: '[data-testid="new-experiment-btn"]'
          }
        },
        {
          order: 2,
          name: 'Enter experiment name',
          action: {
            type: 'type',
            description: 'experiment name input',
            selector: 'input[name="experimentName"]',
            text: 'Safety Tag Accuracy Test'
          }
        },
        {
          order: 3,
          name: 'Select A variant provider',
          action: {
            type: 'click',
            description: 'variant A provider',
            selector: '[data-testid="variant-a-provider"]'
          }
        },
        {
          order: 4,
          name: 'Choose OpenAI for A',
          action: {
            type: 'click',
            description: 'openai option',
            selector: '[data-value="openai-gpt4-vision"]'
          }
        },
        {
          order: 5,
          name: 'Select B variant provider',
          action: {
            type: 'click',
            description: 'variant B provider',
            selector: '[data-testid="variant-b-provider"]'
          }
        },
        {
          order: 6,
          name: 'Choose Google Vision for B',
          action: {
            type: 'click',
            description: 'google vision option',
            selector: '[data-value="google-vision"]'
          }
        },
        {
          order: 7,
          name: 'Set traffic split',
          action: {
            type: 'type',
            description: 'traffic split slider',
            selector: 'input[data-testid="traffic-split"]',
            text: '50'
          }
        },
        {
          order: 8,
          name: 'Start experiment',
          action: {
            type: 'click',
            description: 'start experiment button',
            selector: '[data-testid="start-experiment"]'
          },
          validation: [
            { type: 'text_present', text: 'Experiment started' },
            { type: 'text_present', text: 'Status: Running' }
          ]
        }
      ]
    });
    
    expect(result.success).toBe(true);
  });
});

// tests/e2e/workflows/export-workflows.test.ts
test.describe('Export Workflows', () => {
  const e2e = new E2ETestFramework();
  
  test('Word document export workflow', async () => {
    // Pre-setup photos for export
    await e2e.testData.createTestPhotos(5, 'e2e-org-1');
    
    const result = await e2e.runE2EWorkflow({
      name: 'word-document-export',
      startUrl: 'http://localhost:3000/photos/export',
      steps: [
        {
          order: 1,
          name: 'Select export template',
          action: {
            type: 'click',
            description: 'safety report template',
            selector: '[data-testid="template-safety-report"]'
          }
        },
        {
          order: 2,
          name: 'Proceed to photo selection',
          action: {
            type: 'click',
            description: 'next step button',
            selector: '[data-testid="next-step-btn"]'
          }
        },
        {
          order: 3,
          name: 'Select photos for export',
          action: {
            type: 'click',
            description: 'select all button',
            selector: '[data-testid="select-all-photos"]'
          },
          validation: [
            { type: 'text_present', text: '5 photos selected' }
          ]
        },
        {
          order: 4,
          name: 'Proceed to preview',
          action: {
            type: 'click',
            description: 'next step button',
            selector: '[data-testid="next-step-btn"]'
          }
        },
        {
          order: 5,
          name: 'Review document preview',
          action: {
            type: 'wait',
            condition: 'Preview loaded',
            timeout: 5
          },
          validation: [
            { type: 'text_present', text: 'Document Preview' }
          ]
        },
        {
          order: 6,
          name: 'Generate Word document',
          action: {
            type: 'click',
            description: 'generate document button',
            selector: '[data-testid="generate-document"]'
          }
        },
        {
          order: 7,
          name: 'Wait for document generation',
          action: {
            type: 'wait',
            condition: 'Document ready for download',
            timeout: 15
          },
          validation: [
            { type: 'text_present', text: 'Download ready' }
          ]
        },
        {
          order: 8,
          name: 'Download document',
          action: {
            type: 'click',
            description: 'download button',
            selector: '[data-testid="download-document"]'
          },
          validation: [
            { type: 'text_present', text: 'Download started' }
          ]
        }
      ]
    });
    
    expect(result.success).toBe(true);
    expect(result.duration).toBeLessThan(60000); // 60 seconds
  });
});
```

### Day 5: Cross-Browser & Performance E2E
**Time: 4 hours**

```typescript
// tests/e2e/cross-browser/cross-browser-e2e.test.ts
const browsers = ['chromium', 'firefox', 'webkit'];

browsers.forEach(browserName => {
  test.describe(`${browserName} - E2E Workflows`, () => {
    test(`Photo upload workflow in ${browserName}`, async () => {
      const result = await e2e.runE2EWorkflow({
        name: `photo-upload-${browserName}`,
        browser: browserName,
        startUrl: 'http://localhost:3000/photos',
        steps: [
          // Same steps as photo upload workflow
          // but running in specific browser
        ]
      });
      
      expect(result.success).toBe(true);
    });
    
    test(`AI console workflow in ${browserName}`, async () => {
      const result = await e2e.runE2EWorkflow({
        name: `ai-console-${browserName}`,
        browser: browserName,
        startUrl: 'http://localhost:3000/platform/ai-management',
        steps: [
          // AI management workflow steps
        ]
      });
      
      expect(result.success).toBe(true);
    });
  });
});

// tests/e2e/performance/e2e-performance.test.ts
test.describe('E2E Performance Tests', () => {
  test('Photo upload performance under load', async () => {
    // Test concurrent uploads from multiple browser sessions
    const sessions = await Promise.all([
      e2e.createSession('user1@test.com'),
      e2e.createSession('user2@test.com'), 
      e2e.createSession('user3@test.com'),
    ]);
    
    const startTime = Date.now();
    
    const uploadPromises = sessions.map(async (session, index) => {
      return session.runWorkflow({
        name: `concurrent-upload-${index}`,
        startUrl: 'http://localhost:3000/photos',
        steps: [
          {
            order: 1,
            name: 'Upload photo',
            action: {
              type: 'upload',
              files: [`./test-fixtures/test-photo-${index}.jpg`]
            }
          },
          {
            order: 2,
            name: 'Wait for processing',
            action: {
              type: 'wait',
              condition: 'Processing complete',
              timeout: 20
            }
          }
        ]
      });
    });
    
    const results = await Promise.allSettled(uploadPromises);
    const successful = results.filter(r => r.status === 'fulfilled').length;
    const totalTime = Date.now() - startTime;
    
    expect(successful).toBe(3); // All uploads should succeed
    expect(totalTime).toBeLessThan(30000); // Within 30 seconds
  });
  
  test('Real-time updates performance', async () => {
    // Test AI console real-time updates with multiple users
    const sessions = await Promise.all([
      e2e.createSession('admin@test.com'),
      e2e.createSession('user1@test.com'),
      e2e.createSession('user2@test.com'),
    ]);
    
    // All sessions navigate to AI console
    await Promise.all(
      sessions.map(session => 
        session.navigate('http://localhost:3000/platform/ai-management')
      )
    );
    
    // Trigger AI processing that will generate real-time updates
    await e2e.testData.triggerAIProcessingBatch(10);
    
    // Verify all sessions receive updates
    const updateChecks = sessions.map(async session => {
      return session.waitForUpdates(['cost_update', 'processing_complete'], 15000);
    });
    
    const updateResults = await Promise.all(updateChecks);
    
    expect(updateResults.every(r => r.received)).toBe(true);
  });
});
```

## Test Execution Commands

```bash
# Run all E2E tests
npm run test:e2e

# Run specific workflow
npm run test:e2e -- --grep "photo-upload"

# Run cross-browser tests
npm run test:e2e:cross-browser

# Run E2E performance tests
npm run test:e2e:performance

# Generate E2E report with screenshots
npm run test:e2e:report

# Run E2E tests with visual comparison
npm run test:e2e:visual
```

## E2E Test Matrix

| Workflow | Chrome | Firefox | Safari | Mobile | Duration | Status |
|----------|--------|---------|---------|---------|----------|--------|
| User Onboarding | ✅ | ✅ | ✅ | ✅ | <30s | ✅ |
| Photo Upload | ✅ | ✅ | ✅ | ✅ | <45s | ✅ |
| AI Processing | ✅ | ✅ | ✅ | ⚠️ | <60s | ✅ |
| Bulk Operations | ✅ | ✅ | ✅ | ⚠️ | <30s | ✅ |
| Word Export | ✅ | ✅ | ✅ | ❌ | <60s | ✅ |
| AI Management | ✅ | ✅ | ✅ | ⚠️ | <45s | ✅ |
| Organization Switch | ✅ | ✅ | ✅ | ✅ | <15s | ✅ |
| Search & Filter | ✅ | ✅ | ✅ | ✅ | <20s | ✅ |

Legend:
- ✅ Fully supported
- ⚠️ Limited functionality 
- ❌ Not supported

## CI/CD Integration

```yaml
# .github/workflows/e2e-tests.yml
name: E2E Tests
on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 4 * * *' # Daily at 4 AM

jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        browser: [chromium, firefox, webkit]
        
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Install Playwright browsers
        run: npx playwright install ${{ matrix.browser }}
        
      - name: Start test environment
        run: |
          npm run build
          npm run start:test &
          npm run test:setup-data
          
      - name: Run E2E tests
        run: npm run test:e2e -- --project=${{ matrix.browser }}
        
      - name: Upload test artifacts
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: e2e-results-${{ matrix.browser }}
          path: |
            test-results/
            screenshots/
            videos/
```

**Success Criteria**: Complete E2E coverage of all MVP features with cross-browser compatibility ensures AI agents understand full user impact of their changes.