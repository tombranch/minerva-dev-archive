# Chunk 2: Export & Integration Features Implementation

**Priority:** Critical (P0)  
**Estimated Effort:** 4-6 days  
**Dependencies:** None (can run parallel with Chunk 1)  
**Deliverable:** Complete export functionality for production workflows

---

## 📋 Overview

Chunk 2 implements comprehensive export functionality that bridges the gap between Minerva's photo organization and existing engineering workflows. This is critical for user adoption as engineers need to integrate photos into Word documents and SharePoint systems.

### Business Context
- Engineers create safety reports in Word documents with embedded photos
- SharePoint folder structure must be maintained for compliance
- Export functionality is the final step in the photo-to-report workflow
- Metadata export enables advanced reporting and analysis

---

## 🎯 Scope & Deliverables

### 1. Word Document Export
**Status:** Missing (critical for engineer workflow)  
**Effort:** 3-4 days  
**Files to Create:**
- `lib/export/word-export.ts`
- `components/organization/word-export-wizard.tsx`
- `app/api/export/word/route.ts`

### 2. Advanced ZIP Export (Enhancement)
**Status:** Basic implementation needed  
**Effort:** 1-2 days  
**Files to Enhance:**
- `lib/export/bulk-download.ts` (from Chunk 1)
- `components/organization/export-wizard.tsx`

### 3. Metadata Export (CSV/JSON)
**Status:** Missing  
**Effort:** 1 day  
**Files to Create:**
- `lib/export/metadata-export.ts`
- `app/api/export/metadata/route.ts`

---

## 🔧 Technical Specifications

### 1. Word Document Export Implementation

#### Architecture Overview
```typescript
// lib/export/word-export.ts
interface WordExportOptions {
  photos: PhotoWithDetails[];
  template: 'safety_report' | 'inspection_checklist' | 'custom';
  includeMetadata: boolean;
  imageSize: 'small' | 'medium' | 'large';
  organizationMethod: 'chronological' | 'by_project' | 'by_tag_category';
  customSections?: DocumentSection[];
}

interface DocumentSection {
  type: 'heading' | 'photo_grid' | 'photo_list' | 'metadata_table' | 'text';
  title?: string;
  content?: string;
  photoFilter?: (photo: PhotoWithDetails) => boolean;
  gridColumns?: number;
}

export class WordExportService {
  async createDocument(options: WordExportOptions): Promise<Blob>
  async createFromTemplate(templateId: string, photos: PhotoWithDetails[]): Promise<Blob>
  async saveTemplate(template: DocumentTemplate): Promise<string>
}
```

#### Implementation Details

**Document Generation:**
- Use `docx` library for Word document creation
- Support multiple template formats
- Embed photos at appropriate resolution
- Include comprehensive metadata tables
- Generate table of contents and page numbers

**Template System:**
```typescript
interface DocumentTemplate {
  id: string;
  name: string;
  description: string;
  sections: DocumentSection[];
  pageSettings: {
    orientation: 'portrait' | 'landscape';
    margins: { top: number; bottom: number; left: number; right: number };
    paperSize: 'A4' | 'Letter';
  };
  headerFooter: {
    includeHeader: boolean;
    includeFooter: boolean;
    headerText?: string;
    footerText?: string;
    includePageNumbers: boolean;
  };
}

// Pre-built templates
const SAFETY_REPORT_TEMPLATE: DocumentTemplate = {
  id: 'safety_report',
  name: 'Machine Safety Assessment Report',
  sections: [
    { type: 'heading', title: 'Executive Summary' },
    { type: 'heading', title: 'Machine Overview' },
    { type: 'photo_grid', title: 'Machine Photos', gridColumns: 2 },
    { type: 'heading', title: 'Hazard Analysis' },
    { type: 'photo_list', title: 'Identified Hazards', 
      photoFilter: (photo) => photo.tags.some(tag => tag.category === 'hazard') },
    { type: 'heading', title: 'Control Measures' },
    { type: 'photo_list', title: 'Safety Controls',
      photoFilter: (photo) => photo.tags.some(tag => tag.category === 'control') },
    { type: 'metadata_table', title: 'Photo Index' }
  ]
};
```

**Photo Integration:**
- Automatic image resizing for document optimization
- Maintain aspect ratios
- Include captions with metadata
- Support for photo annotations overlay
- Batch processing for multiple photos

#### API Implementation

```typescript
// app/api/export/word/route.ts
export async function POST(request: NextRequest) {
  const { photoIds, templateId, options } = await request.json();
  
  // Validate access to photos
  const photos = await validateAndFetchPhotos(photoIds, organizationId);
  
  // Generate Word document
  const documentBlob = await wordExportService.createDocument({
    photos,
    template: templateId,
    ...options
  });
  
  // Return document or signed URL for large files
  return new NextResponse(documentBlob, {
    headers: {
      'Content-Type': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'Content-Disposition': `attachment; filename="${generateFilename(options)}.docx"`
    }
  });
}
```

#### UI Implementation

```typescript
// components/organization/word-export-wizard.tsx
interface WordExportWizardProps {
  selectedPhotos: PhotoWithDetails[];
  isOpen: boolean;
  onClose: () => void;
  onExportComplete: (downloadUrl: string) => void;
}

export function WordExportWizard({ selectedPhotos, isOpen, onClose, onExportComplete }: WordExportWizardProps) {
  // Step 1: Template selection
  // Step 2: Photo organization and filtering
  // Step 3: Document customization
  // Step 4: Generation and download
  
  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl">
        <DialogHeader>
          <DialogTitle>Export to Word Document</DialogTitle>
        </DialogHeader>
        
        <div className="space-y-6">
          {step === 1 && <TemplateSelection />}
          {step === 2 && <PhotoOrganization />}
          {step === 3 && <DocumentCustomization />}
          {step === 4 && <GenerationProgress />}
        </div>
      </DialogContent>
    </Dialog>
  );
}
```

### 2. Advanced ZIP Export Enhancement

#### Enhanced Architecture
```typescript
// Enhanced bulk-download.ts (from Chunk 1)
interface AdvancedZipOptions extends BulkDownloadOptions {
  compression: 'none' | 'fast' | 'best';
  includeWordReport?: boolean;
  includeMetadataFile?: boolean;
  customFolderStructure?: FolderStructure[];
  watermarkImages?: boolean;
}

interface FolderStructure {
  name: string;
  path: string;
  photoFilter: (photo: PhotoWithDetails) => boolean;
  includeSubfolders?: boolean;
}
```

#### Implementation Enhancements

**SharePoint-Compatible Export:**
```typescript
const SHAREPOINT_STRUCTURE: FolderStructure[] = [
  {
    name: 'Customer Photos',
    path: '{customer_name}/{project_name}/Photos',
    photoFilter: (photo) => Boolean(photo.project?.site?.customer),
    includeSubfolders: true
  },
  {
    name: 'Unassigned Photos', 
    path: 'Unassigned/Photos',
    photoFilter: (photo) => !photo.project_id,
    includeSubfolders: false
  }
];

// Enhanced ZIP creation with Word reports
async function createAdvancedZip(options: AdvancedZipOptions): Promise<Blob> {
  const zip = new JSZip();
  
  // Add photos with folder structure
  await addPhotosToZip(zip, options);
  
  // Add Word report if requested
  if (options.includeWordReport) {
    const wordDoc = await wordExportService.createDocument({
      photos: options.photos,
      template: 'safety_report'
    });
    zip.file('Safety_Report.docx', wordDoc);
  }
  
  // Add metadata file
  if (options.includeMetadataFile) {
    const metadata = await generateMetadataFile(options.photos);
    zip.file('photo_metadata.csv', metadata);
  }
  
  return zip.generateAsync({ type: 'blob', compression: options.compression });
}
```

### 3. Metadata Export Implementation

#### Architecture Overview
```typescript
// lib/export/metadata-export.ts
interface MetadataExportOptions {
  format: 'csv' | 'json' | 'xlsx';
  includeFields: MetadataField[];
  groupBy?: 'project' | 'site' | 'date' | 'tag_category';
  includeStatistics?: boolean;
}

interface MetadataField {
  key: keyof PhotoWithDetails | string;
  label: string;
  formatter?: (value: any) => string;
}

export class MetadataExportService {
  async exportToCSV(photos: PhotoWithDetails[], options: MetadataExportOptions): Promise<string>
  async exportToJSON(photos: PhotoWithDetails[], options: MetadataExportOptions): Promise<string>
  async exportToExcel(photos: PhotoWithDetails[], options: MetadataExportOptions): Promise<Blob>
}
```

#### Implementation Details

**CSV Export:**
```typescript
async function exportToCSV(photos: PhotoWithDetails[], options: MetadataExportOptions): Promise<string> {
  const fields = options.includeFields;
  const headers = fields.map(field => field.label);
  
  const rows = photos.map(photo => {
    return fields.map(field => {
      const value = getNestedValue(photo, field.key);
      return field.formatter ? field.formatter(value) : String(value || '');
    });
  });
  
  // Add statistics if requested
  if (options.includeStatistics) {
    rows.push([]);
    rows.push(['Statistics']);
    rows.push(['Total Photos', photos.length.toString()]);
    rows.push(['Date Range', `${getDateRange(photos)}`]);
    // Add more statistics...
  }
  
  return [headers, ...rows].map(row => 
    row.map(cell => `"${cell.replace(/"/g, '""')}"`).join(',')
  ).join('\n');
}
```

**Metadata Fields Configuration:**
```typescript
const DEFAULT_METADATA_FIELDS: MetadataField[] = [
  { key: 'original_filename', label: 'Filename' },
  { key: 'created_at', label: 'Upload Date', formatter: (date) => new Date(date).toLocaleDateString() },
  { key: 'taken_at', label: 'Photo Date', formatter: (date) => date ? new Date(date).toLocaleDateString() : 'Unknown' },
  { key: 'project.name', label: 'Project' },
  { key: 'site.name', label: 'Site' },
  { key: 'uploader.first_name', label: 'Uploader' },
  { key: 'ai_description', label: 'AI Description' },
  { key: 'user_description', label: 'User Description' },
  { key: 'tags', label: 'Tags', formatter: (tags) => tags.map(t => t.name).join('; ') },
  { key: 'file_size', label: 'File Size', formatter: formatFileSize },
  { key: 'width', label: 'Width' },
  { key: 'height', label: 'Height' }
];
```

---

## 🧪 Testing Strategy

### Unit Tests Required

**1. Word Export Service:**
```typescript
// __tests__/lib/export/word-export.test.ts
describe('WordExportService', () => {
  test('creates basic Word document with photos');
  test('applies template correctly');
  test('includes metadata tables');
  test('handles missing photos gracefully');
  test('respects image size settings');
  test('generates proper document structure');
});
```

**2. Metadata Export:**
```typescript
// __tests__/lib/export/metadata-export.test.ts
describe('MetadataExportService', () => {
  test('exports CSV with correct headers');
  test('handles nested object properties');
  test('applies custom formatters');
  test('includes statistics when requested');
  test('groups data correctly');
});
```

### Integration Tests

**1. End-to-End Export Workflow:**
- Select photos for export
- Choose Word template
- Customize document options
- Generate and download document
- Verify document content and format

**2. Batch Export Operations:**
- Export large photo sets
- Test multiple format generation
- Verify performance with 50+ photos
- Test error handling and recovery

### Performance Tests

**1. Document Generation Performance:**
- Word document with 50 photos in <120 seconds
- CSV export with 200 photos in <10 seconds
- Memory usage stays below 512MB during generation
- Concurrent export operations

---

## 📊 Acceptance Criteria

### Functional Requirements

**✅ Word Document Export:**
- [ ] Creates properly formatted Word documents
- [ ] Supports multiple templates (safety report, inspection checklist)
- [ ] Embeds photos at appropriate resolution
- [ ] Includes comprehensive metadata
- [ ] Generates table of contents
- [ ] Maintains consistent formatting

**✅ Advanced ZIP Export:**
- [ ] Creates SharePoint-compatible folder structure
- [ ] Includes Word reports in ZIP when requested
- [ ] Supports metadata file inclusion
- [ ] Handles custom folder structures
- [ ] Compresses efficiently for large file sets

**✅ Metadata Export:**
- [ ] Exports to CSV, JSON, and Excel formats
- [ ] Includes all relevant photo metadata
- [ ] Supports custom field selection
- [ ] Groups data by project/site/date
- [ ] Includes summary statistics

### Performance Requirements

- Word document generation: <2 minutes for 20 photos
- CSV export: <10 seconds for 100 photos
- ZIP creation: <90 seconds for 50 photos with Word report
- Memory usage: <512MB during any export operation
- Concurrent exports: Support 3 simultaneous operations

### Quality Requirements

- Generated documents are professional quality
- All exports include proper error handling
- Progress indicators for long operations
- Cancellation support for all exports
- Mobile-friendly interfaces (where applicable)

---

## 🚀 Implementation Timeline

### Day 1-2: Word Export Foundation
- Set up `docx` library and basic document creation
- Implement template system architecture
- Create safety report template
- Basic photo embedding functionality

### Day 3: Word Export Enhancement
- Add metadata tables and statistics
- Implement document customization options
- Create export wizard UI
- Add progress tracking

### Day 4: Advanced ZIP Export
- Enhance ZIP creation with Word report inclusion
- Implement SharePoint folder structure
- Add compression options
- Custom folder structure support

### Day 5: Metadata Export
- Implement CSV/JSON export
- Add Excel export capability
- Create field selection interface
- Add grouping and statistics

### Day 6: Integration & Polish
- End-to-end testing
- Performance optimization
- Error handling refinement
- Documentation and help content

---

## 🔍 Risk Assessment

### High Risk
- **Document Generation Memory**: Large documents could cause memory issues
  - *Mitigation*: Stream processing and memory optimization
- **Template Complexity**: Complex templates might be difficult to maintain
  - *Mitigation*: Simple, well-documented template structure

### Medium Risk
- **Browser Compatibility**: Document generation might not work in all browsers
  - *Mitigation*: Server-side generation fallback
- **Export Performance**: Large exports might timeout
  - *Mitigation*: Background processing and progress tracking

### Low Risk
- **Format Compatibility**: Generated documents might not open correctly
  - *Mitigation*: Extensive testing with different Word versions

---

## 📝 Implementation Notes

### Development Setup
1. Install document generation libraries (`docx`, `xlsx`, `csv-parse`)
2. Set up testing with sample photo data
3. Configure file serving for large exports
4. Set up background job processing if needed

### Performance Considerations
- Use streaming for large file operations
- Implement caching for template rendering
- Optimize image processing for documents
- Consider worker threads for CPU-intensive operations

### User Experience
- Clear progress indicators for all operations
- Intuitive template selection interface
- Helpful error messages and recovery options
- Preview functionality for document generation

---

**Next Steps:** Begin with Word export service as it's the most requested feature by engineers for their reporting workflow.