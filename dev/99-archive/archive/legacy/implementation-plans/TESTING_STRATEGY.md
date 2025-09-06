# Comprehensive Testing Strategy

**Document Version:** 1.0  
**Created:** July 13, 2025  
**Scope:** All 4 implementation chunks  
**Objective:** Ensure production-ready quality

---

## 📋 Overview

This document outlines the comprehensive testing strategy for completing the Minerva Machine Safety Photo Organizer implementation. Testing is organized by chunk to support parallel development while ensuring integration quality.

### Testing Philosophy
- **Test-Driven Development**: Write tests before or alongside implementation
- **Quality Gates**: Each chunk must pass all tests before integration
- **Realistic Data**: Use production-like test data and scenarios
- **Performance Focus**: Test under realistic load conditions

---

## 🧪 Testing Framework & Tools

### Current Testing Infrastructure
- **Unit Testing**: Vitest with Testing Library
- **Integration Testing**: Vitest with Supabase test client
- **E2E Testing**: Playwright with realistic user scenarios
- **Performance Testing**: Custom performance monitoring
- **Visual Testing**: Playwright with screenshot comparison

### Additional Tools for Implementation
```json
{
  "devDependencies": {
    "@testing-library/jest-dom": "^6.1.4",
    "@testing-library/react": "^14.1.2",
    "@testing-library/user-event": "^14.5.1",
    "msw": "^2.0.0",
    "playwright": "^1.40.0",
    "vitest": "^1.0.0",
    "happy-dom": "^12.10.3"
  }
}
```

---

## 🎯 Chunk-Specific Testing Plans

### Chunk 1: Bulk Operations Testing

#### Unit Tests
```typescript
// __tests__/lib/export/bulk-download.test.ts
describe('BulkDownloadService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    setupTestEnvironment();
  });

  test('creates ZIP with correct structure', async () => {
    const photos = createTestPhotos(5);
    const options: BulkDownloadOptions = {
      photoIds: photos.map(p => p.id),
      format: 'zip',
      structure: 'hierarchical',
      includeMetadata: true,
      filenamePattern: '{project}-{filename}'
    };

    const result = await bulkDownloadService.createBulkDownload(options);
    
    expect(result).toBeInstanceOf(Blob);
    
    // Verify ZIP contents
    const zip = await JSZip.loadAsync(result);
    expect(Object.keys(zip.files)).toHaveLength(6); // 5 photos + 1 metadata file
    
    // Verify folder structure
    expect(zip.files['TestProject/photo1.jpg']).toBeDefined();
    expect(zip.files['metadata.csv']).toBeDefined();
  });

  test('handles file access errors gracefully', async () => {
    const photos = createTestPhotos(3);
    photos[1].url = 'invalid-url'; // Simulate broken photo URL
    
    const options: BulkDownloadOptions = {
      photoIds: photos.map(p => p.id),
      format: 'zip',
      structure: 'flat',
      includeMetadata: false,
      filenamePattern: '{filename}'
    };

    const result = await bulkDownloadService.createBulkDownload(options);
    const zip = await JSZip.loadAsync(result);
    
    // Should include successful photos and error log
    expect(Object.keys(zip.files)).toHaveLength(3); // 2 photos + 1 error log
    expect(zip.files['download_errors.txt']).toBeDefined();
  });

  test('respects filename patterns', async () => {
    const photos = createTestPhotos(2);
    const options: BulkDownloadOptions = {
      photoIds: photos.map(p => p.id),
      format: 'zip',
      structure: 'flat',
      includeMetadata: false,
      filenamePattern: '{project}_{date}_{filename}'
    };

    const result = await bulkDownloadService.createBulkDownload(options);
    const zip = await JSZip.loadAsync(result);
    
    const filenames = Object.keys(zip.files);
    expect(filenames[0]).toMatch(/^TestProject_\d{4}-\d{2}-\d{2}_/);
  });

  test('handles large file sets efficiently', async () => {
    const photos = createTestPhotos(50); // Maximum batch size
    const startTime = Date.now();
    
    const options: BulkDownloadOptions = {
      photoIds: photos.map(p => p.id),
      format: 'zip',
      structure: 'hierarchical',
      includeMetadata: true,
      filenamePattern: '{filename}'
    };

    const result = await bulkDownloadService.createBulkDownload(options);
    const endTime = Date.now();
    
    expect(result).toBeInstanceOf(Blob);
    expect(endTime - startTime).toBeLessThan(120000); // Less than 2 minutes
    expect(result.size).toBeGreaterThan(1000000); // At least 1MB
  });
});

// __tests__/components/photos/tag-management-modal.test.ts
describe('TagManagementModal', () => {
  test('displays selected photos correctly', async () => {
    const photos = createTestPhotos(3);
    render(
      <TagManagementModal
        photos={photos}
        isOpen={true}
        onClose={vi.fn()}
        onTagsUpdate={vi.fn()}
      />
    );

    expect(screen.getByText('Manage Tags for 3 Photos')).toBeInTheDocument();
    photos.forEach(photo => {
      expect(screen.getByText(photo.original_filename)).toBeInTheDocument();
    });
  });

  test('executes bulk tag operations', async () => {
    const photos = createTestPhotos(2);
    const onTagsUpdate = vi.fn();
    
    render(
      <TagManagementModal
        photos={photos}
        isOpen={true}
        onClose={vi.fn()}
        onTagsUpdate={onTagsUpdate}
      />
    );

    // Add tag to all photos
    await userEvent.click(screen.getByRole('button', { name: /add tag/i }));
    await userEvent.type(screen.getByRole('combobox'), 'emergency stop');
    await userEvent.click(screen.getByRole('option', { name: /emergency stop/i }));
    await userEvent.click(screen.getByRole('button', { name: /apply to all/i }));

    expect(onTagsUpdate).toHaveBeenCalledTimes(2);
    expect(onTagsUpdate).toHaveBeenCalledWith(photos[0].id, expect.arrayContaining([
      expect.objectContaining({ action: 'add', tagId: expect.any(String) })
    ]));
  });
});

// __tests__/components/upload/site-project-selector.test.ts
describe('SiteProjectSelector', () => {
  test('loads sites and projects', async () => {
    const mockSites = createTestSites(3);
    const mockProjects = createTestProjects(5);
    
    mockSupabaseQueries({
      sites: mockSites,
      projects: mockProjects
    });

    render(
      <SiteProjectSelector
        onSiteChange={vi.fn()}
        onProjectChange={vi.fn()}
      />
    );

    await waitFor(() => {
      expect(screen.getByRole('combobox', { name: /site/i })).toBeInTheDocument();
      expect(screen.getByRole('combobox', { name: /project/i })).toBeInTheDocument();
    });
  });

  test('provides autocomplete functionality', async () => {
    const mockSites = createTestSites(10);
    mockSupabaseQueries({ sites: mockSites });

    render(<SiteProjectSelector onSiteChange={vi.fn()} onProjectChange={vi.fn()} />);

    const siteInput = screen.getByRole('combobox', { name: /site/i });
    await userEvent.type(siteInput, 'Factory');

    await waitFor(() => {
      const options = screen.getAllByRole('option');
      expect(options.length).toBeGreaterThan(0);
      expect(options[0]).toHaveTextContent(/factory/i);
    });
  });
});
```

#### Integration Tests
```typescript
// __tests__/integration/bulk-operations.test.ts
describe('Bulk Operations Integration', () => {
  beforeEach(async () => {
    await setupTestDatabase();
    await seedTestData();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  test('complete bulk download workflow', async () => {
    // 1. Upload multiple photos
    const photos = await uploadTestPhotos(5);
    
    // 2. Select photos for bulk download
    const page = await createTestPage();
    await page.goto('/dashboard/photos');
    
    // Enter selection mode
    await page.click('[data-testid="selection-mode-toggle"]');
    
    // Select multiple photos
    for (const photo of photos) {
      await page.click(`[data-testid="photo-checkbox-${photo.id}"]`);
    }
    
    // 3. Execute bulk download
    await page.click('[data-testid="bulk-download-button"]');
    
    // Configure download options
    await page.selectOption('[data-testid="structure-select"]', 'hierarchical');
    await page.check('[data-testid="include-metadata-checkbox"]');
    
    // Start download
    const downloadPromise = page.waitForDownload();
    await page.click('[data-testid="start-download-button"]');
    
    // 4. Verify download
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toMatch(/\.zip$/);
    
    // Verify ZIP contents
    const downloadPath = await download.path();
    const zipBuffer = await fs.readFile(downloadPath);
    const zip = await JSZip.loadAsync(zipBuffer);
    
    expect(Object.keys(zip.files)).toHaveLength(6); // 5 photos + metadata
  });

  test('tag management workflow', async () => {
    const photos = await uploadTestPhotos(3);
    
    const page = await createTestPage();
    await page.goto('/dashboard/photos');
    
    // Select photos and open tag management
    await page.click('[data-testid="selection-mode-toggle"]');
    await page.click('[data-testid="select-all-button"]');
    await page.click('[data-testid="manage-tags-button"]');
    
    // Add tags to all photos
    await page.fill('[data-testid="tag-search-input"]', 'emergency stop');
    await page.click('[data-testid="tag-option-emergency-stop"]');
    await page.click('[data-testid="apply-to-all-button"]');
    
    // Verify tags were added
    await page.waitForSelector('[data-testid="tag-operation-success"]');
    
    // Check database state
    const updatedPhotos = await getPhotosWithTags(photos.map(p => p.id));
    expect(updatedPhotos).toHaveLength(3);
    updatedPhotos.forEach(photo => {
      expect(photo.tags).toContainEqual(
        expect.objectContaining({ name: 'emergency stop' })
      );
    });
  });
});
```

#### Performance Tests
```typescript
// __tests__/performance/bulk-operations.test.ts
describe('Bulk Operations Performance', () => {
  test('bulk download performance with 50 photos', async () => {
    const photos = await uploadTestPhotos(50);
    const startTime = Date.now();
    
    const options: BulkDownloadOptions = {
      photoIds: photos.map(p => p.id),
      format: 'zip',
      structure: 'hierarchical',
      includeMetadata: true,
      filenamePattern: '{filename}'
    };

    const result = await bulkDownloadService.createBulkDownload(options);
    const endTime = Date.now();
    
    // Performance requirements
    expect(endTime - startTime).toBeLessThan(120000); // < 2 minutes
    expect(result.size).toBeLessThan(100000000); // < 100MB compressed
    
    // Memory usage should be reasonable
    const memoryUsage = process.memoryUsage();
    expect(memoryUsage.heapUsed).toBeLessThan(512000000); // < 512MB
  });

  test('tag operations performance', async () => {
    const photos = await uploadTestPhotos(50);
    const startTime = Date.now();
    
    // Execute bulk tag operation
    await tagService.bulkAddTags(
      photos.map(p => p.id),
      ['emergency-stop', 'safety-critical'],
      'user-bulk-operation'
    );
    
    const endTime = Date.now();
    
    // Should complete within 10 seconds
    expect(endTime - startTime).toBeLessThan(10000);
    
    // Verify all tags were added
    const taggedPhotos = await getPhotosWithTags(photos.map(p => p.id));
    expect(taggedPhotos).toHaveLength(50);
    taggedPhotos.forEach(photo => {
      expect(photo.tags.length).toBeGreaterThanOrEqual(2);
    });
  });
});
```

### Chunk 2: Export Features Testing

#### Unit Tests
```typescript
// __tests__/lib/export/word-export.test.ts
describe('WordExportService', () => {
  test('creates basic Word document with photos', async () => {
    const photos = createTestPhotos(3);
    const options: WordExportOptions = {
      photos,
      template: 'safety_report',
      includeMetadata: true,
      imageSize: 'medium',
      organizationMethod: 'chronological'
    };

    const documentBlob = await wordExportService.createDocument(options);
    
    expect(documentBlob).toBeInstanceOf(Blob);
    expect(documentBlob.type).toBe('application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    expect(documentBlob.size).toBeGreaterThan(50000); // Reasonable document size
  });

  test('applies template correctly', async () => {
    const photos = createTestPhotos(5);
    const customTemplate: DocumentTemplate = {
      id: 'custom_test',
      name: 'Test Template',
      description: 'Test template',
      sections: [
        { type: 'heading', title: 'Test Section' },
        { type: 'photo_grid', title: 'Photos', gridColumns: 2 },
        { type: 'metadata_table', title: 'Photo Details' }
      ],
      pageSettings: {
        orientation: 'portrait',
        margins: { top: 720, bottom: 720, left: 720, right: 720 },
        paperSize: 'A4'
      },
      headerFooter: {
        includeHeader: true,
        includeFooter: true,
        headerText: 'Safety Assessment Report',
        footerText: 'Confidential',
        includePageNumbers: true
      }
    };

    const documentBlob = await wordExportService.createFromTemplate(customTemplate.id, photos);
    
    expect(documentBlob).toBeInstanceOf(Blob);
    
    // TODO: Add more specific template validation
    // This would require parsing the generated Word document
  });

  test('handles missing photos gracefully', async () => {
    const photos = createTestPhotos(3);
    photos[1].url = 'https://invalid-url.com/missing.jpg'; // Broken URL
    
    const options: WordExportOptions = {
      photos,
      template: 'safety_report',
      includeMetadata: true,
      imageSize: 'medium',
      organizationMethod: 'chronological'
    };

    const documentBlob = await wordExportService.createDocument(options);
    
    // Should still create document with available photos
    expect(documentBlob).toBeInstanceOf(Blob);
    expect(documentBlob.size).toBeGreaterThan(20000);
  });
});

// __tests__/lib/export/metadata-export.test.ts
describe('MetadataExportService', () => {
  test('exports CSV with correct headers', async () => {
    const photos = createTestPhotos(3);
    const options: MetadataExportOptions = {
      format: 'csv',
      includeFields: [
        { key: 'original_filename', label: 'Filename' },
        { key: 'created_at', label: 'Upload Date' },
        { key: 'ai_description', label: 'AI Description' }
      ],
      includeStatistics: false
    };

    const csvData = await metadataExportService.exportToCSV(photos, options);
    
    const lines = csvData.split('\n');
    expect(lines[0]).toBe('"Filename","Upload Date","AI Description"');
    expect(lines).toHaveLength(4); // Header + 3 data rows
    
    // Verify CSV formatting
    lines.slice(1).forEach(line => {
      expect(line).toMatch(/^"[^"]*","[^"]*","[^"]*"$/);
    });
  });

  test('includes statistics when requested', async () => {
    const photos = createTestPhotos(5);
    const options: MetadataExportOptions = {
      format: 'csv',
      includeFields: [
        { key: 'original_filename', label: 'Filename' }
      ],
      includeStatistics: true
    };

    const csvData = await metadataExportService.exportToCSV(photos, options);
    
    expect(csvData).toContain('Statistics');
    expect(csvData).toContain('Total Photos","5"');
  });
});
```

#### Integration Tests
```typescript
// __tests__/integration/export-features.test.ts
describe('Export Features Integration', () => {
  test('complete Word export workflow', async () => {
    const photos = await uploadTestPhotos(5);
    
    const page = await createTestPage();
    await page.goto('/dashboard/photos');
    
    // Select photos
    await page.click('[data-testid="selection-mode-toggle"]');
    await page.click('[data-testid="select-all-button"]');
    
    // Open export wizard
    await page.click('[data-testid="export-menu-button"]');
    await page.click('[data-testid="export-word-option"]');
    
    // Step 1: Template selection
    await page.click('[data-testid="template-safety-report"]');
    await page.click('[data-testid="next-step-button"]');
    
    // Step 2: Photo organization
    await page.selectOption('[data-testid="organization-method"]', 'by_project');
    await page.click('[data-testid="next-step-button"]');
    
    // Step 3: Document customization
    await page.check('[data-testid="include-metadata-checkbox"]');
    await page.selectOption('[data-testid="image-size"]', 'medium');
    await page.click('[data-testid="next-step-button"]');
    
    // Step 4: Generate document
    const downloadPromise = page.waitForDownload();
    await page.click('[data-testid="generate-document-button"]');
    
    // Wait for generation and download
    await page.waitForSelector('[data-testid="generation-complete"]');
    const download = await downloadPromise;
    
    expect(download.suggestedFilename()).toMatch(/\.docx$/);
    expect(await download.path()).toBeTruthy();
  });
});
```

### Chunk 3: Infrastructure Testing

#### Unit Tests
```typescript
// __tests__/lib/monitoring/error-tracking.test.ts
describe('ErrorTrackingService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    setupMockSentry();
  });

  test('captures errors with context', () => {
    const error = new Error('Test error');
    const context: ErrorContext = {
      userId: 'user-123',
      organizationId: 'org-456',
      severity: 'high',
      component: 'photo-upload',
      action: 'process-file',
      timestamp: new Date().toISOString()
    };

    ErrorTrackingService.captureError(error, context);
    
    expect(mockSentry.captureException).toHaveBeenCalledWith(error, {
      tags: expect.objectContaining({
        component: 'photo-upload',
        action: 'process-file',
        severity: 'high'
      }),
      user: expect.objectContaining({
        id: 'user-123',
        organizationId: 'org-456'
      })
    });
  });

  test('filters sensitive information', () => {
    const error = new Error('Database connection failed');
    const context: ErrorContext = {
      userId: 'user-123',
      organizationId: 'org-456',
      severity: 'critical',
      timestamp: new Date().toISOString()
    };

    ErrorTrackingService.captureError(error, context);
    
    const capturedEvent = mockSentry.captureException.mock.calls[0][1];
    expect(capturedEvent.user?.email).toBeUndefined();
    expect(capturedEvent.tags?.organizationId).toBeDefined();
  });
});

// __tests__/lib/monitoring/cost-tracking.test.ts
describe('CostTrackingService', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  test('tracks API costs accurately', async () => {
    await CostTrackingService.trackApiCall(
      'google_vision',
      'image_analysis',
      'org-123',
      0.0015
    );

    const costs = await CostTrackingService.getDailyCosts('org-123', 1);
    expect(costs).toHaveLength(1);
    expect(costs[0]).toMatchObject({
      service: 'google_vision',
      operation: 'image_analysis',
      estimatedCost: 0.0015,
      organizationId: 'org-123'
    });
  });

  test('detects cost limit violations', async () => {
    // Simulate multiple API calls approaching limit
    for (let i = 0; i < 100; i++) {
      await CostTrackingService.trackApiCall(
        'google_vision',
        'image_analysis',
        'org-123',
        0.1 // High cost per call
      );
    }

    const alerts = await CostTrackingService.checkCostLimits('org-123');
    expect(alerts).toContainEqual(
      expect.objectContaining({
        type: 'daily_limit',
        currentValue: expect.any(Number),
        threshold: expect.any(Number)
      })
    );
  });
});
```

#### Database Migration Tests
```typescript
// __tests__/database/ai-tables-migration.test.ts
describe('AI Tables Migration', () => {
  test('creates all AI tables correctly', async () => {
    await runMigration('20250714000000_ai_tables.sql');
    
    // Verify tables exist
    const tables = await queryDatabase(`
      SELECT table_name FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('ai_processing_results', 'ai_corrections', 'ai_cost_tracking', 'ai_processing_errors')
    `);
    
    expect(tables).toHaveLength(4);
    expect(tables.map(t => t.table_name)).toContain('ai_processing_results');
    expect(tables.map(t => t.table_name)).toContain('ai_corrections');
    expect(tables.map(t => t.table_name)).toContain('ai_cost_tracking');
    expect(tables.map(t => t.table_name)).toContain('ai_processing_errors');
  });

  test('applies RLS policies properly', async () => {
    await runMigration('20250714000000_ai_tables.sql');
    
    // Test RLS enforcement
    const testUserId = await createTestUser('org-123');
    const otherOrgUserId = await createTestUser('org-456');
    
    // Insert data as first user
    await insertAICorrection({
      organizationId: 'org-123',
      userId: testUserId,
      correctionType: 'tag_added'
    });
    
    // Try to access as user from different org
    const results = await queryAsUser(otherOrgUserId, 'SELECT * FROM ai_corrections');
    expect(results).toHaveLength(0); // Should not see other org's data
  });

  test('creates indexes for performance', async () => {
    await runMigration('20250714000000_ai_tables.sql');
    
    const indexes = await queryDatabase(`
      SELECT indexname FROM pg_indexes 
      WHERE tablename IN ('ai_processing_results', 'ai_corrections', 'ai_cost_tracking', 'ai_processing_errors')
    `);
    
    expect(indexes.length).toBeGreaterThan(10); // Should have multiple indexes
    expect(indexes.map(i => i.indexname)).toContain('idx_ai_corrections_organization_id');
  });
});
```

### Chunk 4: Polish & Enhancement Testing

#### Component Tests
```typescript
// __tests__/components/admin/feedback-management.test.ts
describe('FeedbackManagement', () => {
  test('displays feedback list correctly', async () => {
    const mockFeedback = createTestFeedback(5);
    mockSupabaseQueries({ feedback: mockFeedback });

    render(<FeedbackManagement organizationId="org-123" />);

    await waitFor(() => {
      expect(screen.getByText('Total Feedback')).toBeInTheDocument();
      expect(screen.getByText('5')).toBeInTheDocument();
    });

    // Verify feedback items are displayed
    mockFeedback.forEach(feedback => {
      expect(screen.getByText(feedback.comment)).toBeInTheDocument();
    });
  });

  test('allows status updates', async () => {
    const mockFeedback = createTestFeedback(1);
    const updateStatusMock = vi.fn();
    
    mockSupabaseQueries({ 
      feedback: mockFeedback,
      updateStatus: updateStatusMock
    });

    render(<FeedbackManagement organizationId="org-123" />);

    await waitFor(() => {
      expect(screen.getByDisplayValue('new')).toBeInTheDocument();
    });

    // Change status
    await userEvent.selectOptions(screen.getByDisplayValue('new'), 'in_progress');

    expect(updateStatusMock).toHaveBeenCalledWith(
      mockFeedback[0].id,
      'in_progress'
    );
  });
});

// __tests__/components/search/advanced-search.test.ts
describe('AdvancedSearch', () => {
  test('implements AND/OR tag logic correctly', async () => {
    const onSearchChange = vi.fn();
    
    render(<AdvancedSearch onSearchChange={onSearchChange} />);

    // Switch to advanced mode
    await userEvent.click(screen.getByRole('button', { name: /advanced/i }));

    // Add multiple tags
    await userEvent.type(screen.getByRole('combobox'), 'emergency stop');
    await userEvent.click(screen.getByRole('option', { name: /emergency stop/i }));
    
    await userEvent.type(screen.getByRole('combobox'), 'safety guard');
    await userEvent.click(screen.getByRole('option', { name: /safety guard/i }));

    // Select AND logic
    await userEvent.click(screen.getByLabelText(/all tags \(and\)/i));

    // Trigger search
    await userEvent.click(screen.getByRole('button', { name: /search/i }));

    expect(onSearchChange).toHaveBeenCalledWith(
      expect.objectContaining({
        tags: ['emergency stop', 'safety guard'],
        tagOperator: 'AND'
      })
    );
  });
});
```

---

## 🚀 End-to-End Testing Scenarios

### Critical User Workflows

#### Engineer Daily Workflow Test
```typescript
// e2e/engineer-workflow.spec.ts
test('complete engineer workflow', async ({ page }) => {
  // 1. Login as engineer
  await page.goto('/login');
  await page.fill('[data-testid="email-input"]', 'engineer@example.com');
  await page.fill('[data-testid="password-input"]', 'password123');
  await page.click('[data-testid="login-button"]');

  // 2. Upload multiple photos
  await page.goto('/dashboard/upload');
  
  const fileChooserPromise = page.waitForEvent('filechooser');
  await page.click('[data-testid="file-input"]');
  const fileChooser = await fileChooserPromise;
  await fileChooser.setFiles([
    './test-data/machine1.jpg',
    './test-data/machine2.jpg',
    './test-data/safety-control.jpg'
  ]);

  // Wait for upload completion
  await page.waitForSelector('[data-testid="upload-complete"]', { timeout: 60000 });

  // 3. Search for specific hazards
  await page.goto('/dashboard/photos');
  await page.fill('[data-testid="search-input"]', 'emergency stop');
  await page.press('[data-testid="search-input"]', 'Enter');

  // Verify search results
  await expect(page.locator('[data-testid="photo-grid"] img')).toHaveCount(1);

  // 4. Create bulk download for report
  await page.click('[data-testid="selection-mode-toggle"]');
  await page.click('[data-testid="select-all-button"]');
  await page.click('[data-testid="bulk-download-button"]');

  // Configure download for SharePoint
  await page.selectOption('[data-testid="structure-select"]', 'hierarchical');
  await page.check('[data-testid="include-metadata-checkbox"]');

  const downloadPromise = page.waitForDownload();
  await page.click('[data-testid="start-download-button"]');
  
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toMatch(/safety_photos_\d+\.zip/);

  // 5. Generate Word report
  await page.click('[data-testid="export-menu-button"]');
  await page.click('[data-testid="export-word-option"]');
  
  await page.click('[data-testid="template-safety-report"]');
  await page.click('[data-testid="generate-document-button"]');

  await page.waitForSelector('[data-testid="generation-complete"]');
  
  // Verify report generation
  expect(page.locator('[data-testid="download-report-button"]')).toBeVisible();
});
```

#### Admin Management Workflow Test
```typescript
// e2e/admin-workflow.spec.ts
test('admin feedback management', async ({ page }) => {
  // 1. Login as admin
  await page.goto('/login');
  await page.fill('[data-testid="email-input"]', 'admin@example.com');
  await page.fill('[data-testid="password-input"]', 'admin123');
  await page.click('[data-testid="login-button"]');

  // 2. Navigate to feedback management
  await page.goto('/dashboard/admin/feedback');

  // 3. Review pending feedback
  await page.click('[data-testid="filter-status"]');
  await page.click('[data-testid="status-new"]');

  // Verify feedback list
  await expect(page.locator('[data-testid="feedback-row"]')).toHaveCountGreaterThan(0);

  // 4. Respond to feedback
  await page.click('[data-testid="feedback-row"]:first-child [data-testid="respond-button"]');
  
  await page.fill('[data-testid="response-textarea"]', 'Thank you for your feedback. We are addressing this issue.');
  await page.check('[data-testid="public-response-checkbox"]');
  await page.selectOption('[data-testid="new-status-select"]', 'in_progress');
  
  await page.click('[data-testid="send-response-button"]');

  // Verify response was sent
  await expect(page.locator('[data-testid="response-success"]')).toBeVisible();

  // 5. Check cost monitoring
  await page.goto('/dashboard/admin/costs');
  
  // Verify cost dashboard
  await expect(page.locator('[data-testid="cost-chart"]')).toBeVisible();
  await expect(page.locator('[data-testid="cost-alerts"]')).toBeVisible();
});
```

### Performance Testing Scenarios

#### Load Testing
```typescript
// e2e/performance.spec.ts
test('search performance with large dataset', async ({ page }) => {
  // Navigate to photos page with large dataset
  await page.goto('/dashboard/photos');
  
  // Measure search response time
  const startTime = Date.now();
  
  await page.fill('[data-testid="search-input"]', 'emergency');
  await page.press('[data-testid="search-input"]', 'Enter');
  
  await page.waitForSelector('[data-testid="search-results"]');
  
  const endTime = Date.now();
  const responseTime = endTime - startTime;
  
  // Verify performance requirement
  expect(responseTime).toBeLessThan(1000); // Less than 1 second
});

test('bulk operations performance', async ({ page }) => {
  await page.goto('/dashboard/photos');
  
  // Select 50 photos (maximum batch)
  await page.click('[data-testid="selection-mode-toggle"]');
  await page.click('[data-testid="select-all-button"]');
  
  const startTime = Date.now();
  
  // Start bulk download
  await page.click('[data-testid="bulk-download-button"]');
  await page.click('[data-testid="start-download-button"]');
  
  // Wait for completion
  await page.waitForSelector('[data-testid="download-ready"]', { timeout: 120000 });
  
  const endTime = Date.now();
  const processingTime = endTime - startTime;
  
  // Verify performance requirement
  expect(processingTime).toBeLessThan(120000); // Less than 2 minutes
});
```

---

## 📊 Quality Gates & Acceptance Criteria

### Code Quality Requirements
- **Test Coverage**: Minimum 80% for all new code
- **Type Safety**: 100% TypeScript coverage, no `any` types
- **Linting**: Zero ESLint errors or warnings
- **Performance**: All performance tests pass requirements

### Functional Quality Gates
- **Unit Tests**: 100% pass rate for all chunks
- **Integration Tests**: All workflow tests pass
- **E2E Tests**: Critical user journeys complete successfully
- **Manual Testing**: UAT scenarios validated by product team

### Performance Quality Gates
- **Search Response**: <500ms for 95% of queries
- **Upload Processing**: 20 photos in <2 minutes
- **Bulk Operations**: 50 photos processed in <2 minutes
- **Memory Usage**: <512MB during bulk operations

### Security Quality Gates
- **Authentication**: All protected routes require valid auth
- **Authorization**: RLS policies prevent cross-org access
- **Input Validation**: All user inputs properly validated
- **Error Handling**: No sensitive data exposed in errors

---

## 🔄 Continuous Integration

### Automated Testing Pipeline
```yaml
# .github/workflows/test.yml
name: Test Suite
on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:unit
      - run: npm run test:coverage

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install
      - run: npm run test:e2e
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

---

This comprehensive testing strategy ensures that all implementation chunks meet production quality standards while supporting parallel development and continuous integration.