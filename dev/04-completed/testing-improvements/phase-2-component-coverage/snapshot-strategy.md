# Component Snapshot Testing Strategy
**Visual Regression Prevention for 275 Components**

## Overview

Snapshot testing creates a baseline of component output, enabling AI agents to detect visual regressions immediately. This strategy covers all 275 components with efficient snapshot management and automated baseline updates.

## Snapshot Testing Architecture

### 1. Component Categories & Snapshot Types

```typescript
// Snapshot classification by component type
export const snapshotStrategies = {
  'static-ui': {
    // Static UI components (buttons, cards, etc.)
    components: ['Button', 'Card', 'Badge', 'Avatar'],
    snapshotType: 'html',
    variants: ['default', 'hover', 'disabled', 'error'],
    updateFrequency: 'rarely'
  },
  
  'interactive': {
    // Interactive components with state changes
    components: ['Dialog', 'Dropdown', 'Tabs', 'Accordion'],
    snapshotType: 'html + states',
    variants: ['closed', 'open', 'loading', 'error'],
    updateFrequency: 'medium'
  },
  
  'data-driven': {
    // Components that display dynamic data
    components: ['PhotoGrid', 'AIConsole', 'TagList'],
    snapshotType: 'html + data-variants',
    variants: ['empty', 'loading', 'populated', 'error'],
    updateFrequency: 'frequent'
  },
  
  'layout': {
    // Layout and navigation components
    components: ['Sidebar', 'Header', 'Navigation'],
    snapshotType: 'html + responsive',
    variants: ['mobile', 'tablet', 'desktop'],
    updateFrequency: 'rarely'
  }
};
```

### 2. Snapshot Test Generator

```typescript
// tests/snapshots/snapshot-generator.ts
import { render } from '@testing-library/react';
import { ComponentPropsWithoutRef, ReactElement } from 'react';

export class SnapshotGenerator {
  private componentFixtures = new Map();
  
  generateSnapshotsForComponent<T extends React.ComponentType<any>>(
    Component: T,
    config: SnapshotConfig<T>
  ) {
    describe(`${Component.displayName || Component.name} Snapshots`, () => {
      // Default state snapshot
      it('renders default state', () => {
        const { container } = render(<Component {...config.defaultProps} />);
        expect(container.firstChild).toMatchSnapshot(`${config.name}-default`);
      });
      
      // Variant snapshots
      if (config.variants) {
        config.variants.forEach(variant => {
          it(`renders ${variant.name} variant`, () => {
            const { container } = render(
              <Component {...config.defaultProps} {...variant.props} />
            );
            expect(container.firstChild).toMatchSnapshot(
              `${config.name}-${variant.name}`
            );
          });
        });
      }
      
      // State snapshots for interactive components
      if (config.states) {
        config.states.forEach(state => {
          it(`renders ${state.name} state`, () => {
            const { container } = render(
              <Component {...config.defaultProps} {...state.props} />
            );
            expect(container.firstChild).toMatchSnapshot(
              `${config.name}-${state.name}`
            );
          });
        });
      }
      
      // Data variant snapshots
      if (config.dataVariants) {
        config.dataVariants.forEach(dataVariant => {
          it(`renders with ${dataVariant.name} data`, () => {
            const { container } = render(
              <Component {...config.defaultProps} {...dataVariant.props} />
            );
            expect(container.firstChild).toMatchSnapshot(
              `${config.name}-data-${dataVariant.name}`
            );
          });
        });
      }
      
      // Responsive snapshots for layout components
      if (config.responsive) {
        ['mobile', 'tablet', 'desktop'].forEach(breakpoint => {
          it(`renders ${breakpoint} layout`, () => {
            const { container } = render(
              <div className={`viewport-${breakpoint}`}>
                <Component {...config.defaultProps} />
              </div>
            );
            expect(container.firstChild).toMatchSnapshot(
              `${config.name}-${breakpoint}`
            );
          });
        });
      }
    });
  }
  
  generateBulkSnapshots(configs: SnapshotConfig[]) {
    configs.forEach(config => {
      this.generateSnapshotsForComponent(config.component, config);
    });
  }
}
```

### 3. Component Snapshot Configurations

```typescript
// tests/snapshots/configs/ui-components.ts
export const uiComponentSnapshots: SnapshotConfig[] = [
  {
    name: 'Button',
    component: Button,
    defaultProps: { children: 'Test Button' },
    variants: [
      { name: 'primary', props: { variant: 'default' } },
      { name: 'secondary', props: { variant: 'secondary' } },
      { name: 'destructive', props: { variant: 'destructive' } },
      { name: 'outline', props: { variant: 'outline' } },
      { name: 'ghost', props: { variant: 'ghost' } },
      { name: 'link', props: { variant: 'link' } },
    ],
    states: [
      { name: 'disabled', props: { disabled: true } },
      { name: 'loading', props: { loading: true } },
      { name: 'with-icon', props: { 
        children: (
          <>
            <Icon name="plus" />
            Test Button
          </>
        )
      }},
    ]
  },
  
  {
    name: 'Card',
    component: Card,
    defaultProps: {},
    variants: [
      { 
        name: 'basic',
        props: {
          children: (
            <>
              <Card.Header>
                <Card.Title>Test Title</Card.Title>
              </Card.Header>
              <Card.Content>Test content</Card.Content>
            </>
          )
        }
      },
      {
        name: 'with-footer',
        props: {
          children: (
            <>
              <Card.Header>
                <Card.Title>Test Title</Card.Title>
                <Card.Description>Test description</Card.Description>
              </Card.Header>
              <Card.Content>Test content</Card.Content>
              <Card.Footer>
                <Button>Action</Button>
              </Card.Footer>
            </>
          )
        }
      }
    ]
  },
  
  {
    name: 'Dialog',
    component: Dialog,
    defaultProps: { open: true },
    states: [
      { name: 'closed', props: { open: false } },
      { name: 'open', props: { open: true } },
    ],
    variants: [
      {
        name: 'basic-dialog',
        props: {
          children: (
            <Dialog.Content>
              <Dialog.Header>
                <Dialog.Title>Test Dialog</Dialog.Title>
              </Dialog.Header>
              <div>Dialog content</div>
            </Dialog.Content>
          )
        }
      },
      {
        name: 'confirmation-dialog',
        props: {
          children: (
            <Dialog.Content>
              <Dialog.Header>
                <Dialog.Title>Confirm Action</Dialog.Title>
                <Dialog.Description>Are you sure?</Dialog.Description>
              </Dialog.Header>
              <Dialog.Footer>
                <Button variant="outline">Cancel</Button>
                <Button variant="destructive">Delete</Button>
              </Dialog.Footer>
            </Dialog.Content>
          )
        }
      }
    ]
  }
];
```

```typescript
// tests/snapshots/configs/feature-components.ts
export const featureComponentSnapshots: SnapshotConfig[] = [
  {
    name: 'PhotoGrid',
    component: PhotoGrid,
    defaultProps: { photos: [] },
    dataVariants: [
      {
        name: 'empty',
        props: { photos: [] }
      },
      {
        name: 'single-photo',
        props: {
          photos: [{
            id: '1',
            url: 'https://example.com/photo1.jpg',
            title: 'Test Photo',
            tags: ['test'],
            ai_tags: []
          }]
        }
      },
      {
        name: 'multiple-photos',
        props: {
          photos: Array.from({ length: 6 }, (_, i) => ({
            id: String(i + 1),
            url: `https://example.com/photo${i + 1}.jpg`,
            title: `Test Photo ${i + 1}`,
            tags: ['test', 'photo'],
            ai_tags: [{
              name: 'test-tag',
              confidence: 0.9,
              category: 'test'
            }]
          }))
        }
      },
      {
        name: 'loading-state',
        props: {
          photos: [],
          loading: true
        }
      }
    ],
    states: [
      { name: 'selection-mode', props: { selectionMode: true } },
      { name: 'with-selection', props: { 
        selectionMode: true, 
        selectedPhotos: ['1', '2'] 
      }},
    ]
  },
  
  {
    name: 'AIConsole',
    component: AIConsole,
    defaultProps: { data: { providers: [], metrics: {} } },
    dataVariants: [
      {
        name: 'no-providers',
        props: {
          data: {
            providers: [],
            metrics: { totalCost: 0, successRate: 0 }
          }
        }
      },
      {
        name: 'active-providers',
        props: {
          data: {
            providers: [
              { id: 'openai', name: 'OpenAI', status: 'active', usage: { requests: 150 } },
              { id: 'google', name: 'Google Vision', status: 'active', usage: { requests: 89 } }
            ],
            metrics: { totalCost: 45.67, successRate: 0.94 }
          }
        }
      },
      {
        name: 'provider-error',
        props: {
          data: {
            providers: [
              { id: 'openai', name: 'OpenAI', status: 'error', error: 'API key invalid' }
            ],
            metrics: { totalCost: 0, successRate: 0 }
          }
        }
      }
    ],
    states: [
      { name: 'loading', props: { loading: true } },
      { name: 'error', props: { error: 'Failed to load console data' } }
    ]
  },
  
  {
    name: 'WordExportWizard',
    component: WordExportWizard,
    defaultProps: { step: 'template' },
    states: [
      { name: 'step-template', props: { step: 'template' } },
      { name: 'step-photos', props: { 
        step: 'photos', 
        selectedTemplate: 'safety-report' 
      }},
      { name: 'step-preview', props: { 
        step: 'preview',
        selectedTemplate: 'safety-report',
        selectedPhotos: ['photo1', 'photo2']
      }},
      { name: 'step-generating', props: { 
        step: 'generating',
        progress: 75
      }},
    ],
    variants: [
      {
        name: 'safety-template',
        props: { 
          step: 'template',
          availableTemplates: [
            { id: 'safety-report', name: 'Safety Report', description: 'Standard safety inspection report' }
          ]
        }
      }
    ]
  }
];
```

### 4. Automated Snapshot Management

```typescript
// tests/snapshots/snapshot-manager.ts
import { execSync } from 'child_process';
import { readFileSync, writeFileSync, readdirSync } from 'fs';
import { join } from 'path';

export class SnapshotManager {
  private snapshotDir = 'tests/snapshots/__snapshots__';
  
  async updateOutdatedSnapshots(threshold = 0.95) {
    // Find components with low snapshot coverage
    const components = this.scanComponents();
    const outdated = [];
    
    for (const component of components) {
      const coverage = await this.calculateSnapshotCoverage(component);
      if (coverage < threshold) {
        outdated.push(component);
      }
    }
    
    // Generate missing snapshots
    for (const component of outdated) {
      await this.generateMissingSnapshots(component);
    }
    
    return {
      updated: outdated.length,
      components: outdated
    };
  }
  
  async validateSnapshotHealth() {
    const issues = [];
    
    // Check for orphaned snapshots
    const orphaned = await this.findOrphanedSnapshots();
    if (orphaned.length > 0) {
      issues.push({
        type: 'orphaned_snapshots',
        count: orphaned.length,
        files: orphaned
      });
    }
    
    // Check for large snapshots
    const large = await this.findLargeSnapshots(10000); // 10KB threshold
    if (large.length > 0) {
      issues.push({
        type: 'large_snapshots',
        count: large.length,
        files: large
      });
    }
    
    // Check for duplicate snapshots
    const duplicates = await this.findDuplicateSnapshots();
    if (duplicates.length > 0) {
      issues.push({
        type: 'duplicate_snapshots',
        count: duplicates.length,
        pairs: duplicates
      });
    }
    
    return issues;
  }
  
  async optimizeSnapshots() {
    // Remove redundant snapshots
    const duplicates = await this.findDuplicateSnapshots();
    for (const [original, duplicate] of duplicates) {
      this.removeSnapshot(duplicate);
    }
    
    // Compress large snapshots
    const large = await this.findLargeSnapshots(5000);
    for (const snapshot of large) {
      await this.compressSnapshot(snapshot);
    }
    
    // Update snapshot index
    await this.updateSnapshotIndex();
  }
  
  private async calculateSnapshotCoverage(component: string): Promise<number> {
    const config = this.getComponentConfig(component);
    if (!config) return 0;
    
    const expectedSnapshots = this.calculateExpectedSnapshots(config);
    const existingSnapshots = this.countExistingSnapshots(component);
    
    return existingSnapshots / expectedSnapshots;
  }
  
  private calculateExpectedSnapshots(config: SnapshotConfig): number {
    let count = 1; // default snapshot
    
    if (config.variants) count += config.variants.length;
    if (config.states) count += config.states.length;
    if (config.dataVariants) count += config.dataVariants.length;
    if (config.responsive) count += 3; // mobile, tablet, desktop
    
    return count;
  }
  
  private countExistingSnapshots(component: string): number {
    const snapshotFile = join(this.snapshotDir, `${component}.test.tsx.snap`);
    
    try {
      const content = readFileSync(snapshotFile, 'utf-8');
      return (content.match(/exports\[`/g) || []).length;
    } catch {
      return 0;
    }
  }
  
  private async findOrphanedSnapshots(): Promise<string[]> {
    const snapshotFiles = readdirSync(this.snapshotDir);
    const componentFiles = this.scanComponents();
    
    const orphaned = snapshotFiles.filter(snapFile => {
      const componentName = snapFile.replace('.test.tsx.snap', '');
      return !componentFiles.includes(componentName);
    });
    
    return orphaned;
  }
  
  private async findLargeSnapshots(thresholdBytes: number): Promise<string[]> {
    const snapshotFiles = readdirSync(this.snapshotDir);
    const large = [];
    
    for (const file of snapshotFiles) {
      const filePath = join(this.snapshotDir, file);
      const stats = require('fs').statSync(filePath);
      
      if (stats.size > thresholdBytes) {
        large.push(file);
      }
    }
    
    return large;
  }
  
  private async findDuplicateSnapshots(): Promise<Array<[string, string]>> {
    const snapshotFiles = readdirSync(this.snapshotDir);
    const duplicates = [];
    const hashes = new Map();
    
    for (const file of snapshotFiles) {
      const content = readFileSync(join(this.snapshotDir, file), 'utf-8');
      const hash = require('crypto').createHash('md5').update(content).digest('hex');
      
      if (hashes.has(hash)) {
        duplicates.push([hashes.get(hash), file]);
      } else {
        hashes.set(hash, file);
      }
    }
    
    return duplicates;
  }
  
  private async compressSnapshot(filename: string): Promise<void> {
    const filePath = join(this.snapshotDir, filename);
    const content = readFileSync(filePath, 'utf-8');
    
    // Remove unnecessary whitespace while preserving structure
    const compressed = content
      .replace(/\n\s+/g, '\n') // Remove leading whitespace
      .replace(/\n{3,}/g, '\n\n') // Limit consecutive newlines
      .replace(/\s+>/g, '>') // Remove spaces before closing tags
      .trim();
    
    if (compressed.length < content.length) {
      writeFileSync(filePath, compressed);
    }
  }
  
  private scanComponents(): string[] {
    // Scan component directories for all components
    const componentDirs = [
      'components/ui',
      'components/photos',
      'components/ai',
      'components/platform',
      'components/admin',
      'components/auth',
      'components/layout'
    ];
    
    const components = [];
    
    for (const dir of componentDirs) {
      try {
        const files = readdirSync(dir);
        const tsxFiles = files
          .filter(file => file.endsWith('.tsx'))
          .map(file => file.replace('.tsx', ''));
        components.push(...tsxFiles);
      } catch {
        // Directory doesn't exist, skip
      }
    }
    
    return components;
  }
  
  private getComponentConfig(componentName: string): SnapshotConfig | null {
    // Look up component configuration
    const allConfigs = [
      ...uiComponentSnapshots,
      ...featureComponentSnapshots,
      // Add other config arrays
    ];
    
    return allConfigs.find(config => config.name === componentName) || null;
  }
  
  private async updateSnapshotIndex(): Promise<void> {
    const components = this.scanComponents();
    const index = {
      total: components.length,
      coverage: {},
      lastUpdated: new Date().toISOString()
    };
    
    for (const component of components) {
      index.coverage[component] = await this.calculateSnapshotCoverage(component);
    }
    
    writeFileSync(
      'tests/snapshots/snapshot-index.json',
      JSON.stringify(index, null, 2)
    );
  }
}
```

### 5. Snapshot Testing Automation

```typescript
// tests/snapshots/automated-snapshot-tests.ts
import { describe, it, beforeAll, afterAll } from 'vitest';
import { SnapshotGenerator } from './snapshot-generator';
import { SnapshotManager } from './snapshot-manager';
import { 
  uiComponentSnapshots, 
  featureComponentSnapshots,
  layoutComponentSnapshots,
  platformComponentSnapshots,
  adminComponentSnapshots,
} from './configs';

describe('Automated Component Snapshots', () => {
  const generator = new SnapshotGenerator();
  const manager = new SnapshotManager();
  
  beforeAll(async () => {
    // Ensure snapshot directory is ready
    await manager.validateSnapshotHealth();
  });
  
  describe('UI Components (35 components)', () => {
    uiComponentSnapshots.forEach(config => {
      generator.generateSnapshotsForComponent(config.component, config);
    });
  });
  
  describe('Feature Components (80 components)', () => {
    featureComponentSnapshots.forEach(config => {
      generator.generateSnapshotsForComponent(config.component, config);
    });
  });
  
  describe('Layout Components (25 components)', () => {
    layoutComponentSnapshots.forEach(config => {
      generator.generateSnapshotsForComponent(config.component, config);
    });
  });
  
  describe('Platform Components (40 components)', () => {
    platformComponentSnapshots.forEach(config => {
      generator.generateSnapshotsForComponent(config.component, config);
    });
  });
  
  describe('Admin Components (30 components)', () => {
    adminComponentSnapshots.forEach(config => {
      generator.generateSnapshotsForComponent(config.component, config);
    });
  });
  
  afterAll(async () => {
    // Generate coverage report
    const report = await manager.updateSnapshotIndex();
    console.log(`Snapshot coverage updated: ${Object.keys(report.coverage).length} components`);
  });
});
```

### 6. CI/CD Integration

```yaml
# .github/workflows/snapshot-tests.yml
name: Component Snapshot Tests
on:
  push:
    branches: [main]
  pull_request:

jobs:
  snapshot-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run snapshot tests
        run: npm run test:snapshots
        
      - name: Check for snapshot changes
        run: |
          if git diff --name-only | grep -q "\.snap$"; then
            echo "Snapshot changes detected:"
            git diff --name-only | grep "\.snap$"
            echo "Please review and commit snapshot updates"
            exit 1
          fi
          
      - name: Generate snapshot report
        run: npm run test:snapshots:report
        
      - name: Upload snapshot artifacts
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: snapshot-diffs
          path: tests/snapshots/__diffs__/
```

### 7. Performance Optimization

```typescript
// tests/snapshots/performance/snapshot-optimizer.ts
export class SnapshotOptimizer {
  async optimizeSnapshotSuite() {
    // 1. Remove redundant snapshots
    await this.deduplicateSnapshots();
    
    // 2. Compress large snapshots
    await this.compressLargeSnapshots();
    
    // 3. Generate parallel test execution plan
    await this.createParallelTestPlan();
    
    // 4. Create snapshot cache
    await this.buildSnapshotCache();
  }
  
  private async createParallelTestPlan() {
    const components = this.getAllComponents();
    const batches = this.createBatches(components, 4); // 4 parallel workers
    
    const plan = {
      batches,
      estimatedTime: this.estimateExecutionTime(batches),
      optimizations: [
        'Deduplicated identical snapshots',
        'Compressed large snapshots',
        'Cached common props',
        'Parallel execution'
      ]
    };
    
    writeFileSync(
      'tests/snapshots/execution-plan.json', 
      JSON.stringify(plan, null, 2)
    );
  }
  
  private createBatches(components: string[], batchCount: number): string[][] {
    const batches = Array.from({ length: batchCount }, () => []);
    
    components.forEach((component, index) => {
      batches[index % batchCount].push(component);
    });
    
    return batches;
  }
  
  private estimateExecutionTime(batches: string[][]): number {
    // Estimate based on component complexity
    const complexityMap = {
      'simple': 50,    // ms per snapshot
      'medium': 150,   // ms per snapshot
      'complex': 300   // ms per snapshot
    };
    
    return batches.reduce((total, batch) => {
      const batchTime = batch.reduce((batchTotal, component) => {
        const complexity = this.getComponentComplexity(component);
        const snapshotCount = this.getSnapshotCount(component);
        return batchTotal + (complexityMap[complexity] * snapshotCount);
      }, 0);
      
      return Math.max(total, batchTime); // Parallel execution
    }, 0);
  }
}
```

## Test Commands & Scripts

```json
{
  "scripts": {
    "test:snapshots": "vitest run tests/snapshots",
    "test:snapshots:update": "vitest run tests/snapshots -u",
    "test:snapshots:watch": "vitest tests/snapshots",
    "test:snapshots:coverage": "vitest run tests/snapshots --coverage",
    "test:snapshots:optimize": "node tests/snapshots/optimize.js",
    "test:snapshots:report": "node tests/snapshots/generate-report.js",
    "test:snapshots:validate": "node tests/snapshots/validate-health.js"
  }
}
```

## Success Metrics

### Coverage Targets by Component Category
| Category | Components | Target Coverage | Snapshot Types |
|----------|------------|----------------|----------------|
| UI Library | 35 | 100% | Static + States |
| AI Management | 50 | 95% | Data + Interactive |
| Photo Management | 40 | 95% | Data + States |
| Platform Admin | 30 | 90% | Data + Responsive |
| Layout | 25 | 100% | Responsive + States |
| Auth & Forms | 20 | 95% | States + Validation |
| Search & Export | 25 | 90% | Data + Interactive |
| Miscellaneous | 50 | 85% | Basic + States |

### Performance Targets
- **Snapshot generation**: <10s per component
- **Full suite execution**: <5 minutes
- **Snapshot size**: <5KB average per snapshot
- **Duplication rate**: <5% identical snapshots

### Quality Metrics
- **Coverage**: 90% of components with comprehensive snapshots
- **Freshness**: Snapshots updated within 1 week of component changes
- **Accuracy**: <1% false positive rate for visual regressions
- **Maintainability**: Automated snapshot optimization and cleanup

**Success Criteria**: Comprehensive snapshot testing provides immediate visual regression detection for AI agents, ensuring UI consistency across 275 components with minimal maintenance overhead.