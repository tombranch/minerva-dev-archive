# Chunk 1: Bulk Operations & Core UX Implementation

**Priority:** Critical (P0)  
**Estimated Effort:** 5-7 days  
**Dependencies:** None  
**Deliverable:** Core bulk operations for production readiness

---

## 📋 Overview

Chunk 1 focuses on implementing the essential bulk operations that are critical for user workflow completion. These features enable engineers to efficiently manage multiple photos, which is fundamental to their daily work with 200-400 photos per week.

### Business Context
- Engineers need to manage photos in batches for efficiency
- Site/project organization is essential for SharePoint workflow
- Tag management allows post-upload AI refinement
- These features directly impact user adoption and workflow efficiency

---

## 🎯 Scope & Deliverables

### 1. Bulk Download with ZIP Creation
**Status:** Missing (critical gap)  
**Effort:** 2-3 days  
**Files to Create/Modify:**
- `lib/export/bulk-download.ts` (new)
- `components/photos/bulk-download-modal.tsx` (new)
- `app/api/export/bulk-download/route.ts` (new)

### 2. Tag Management Modal
**Status:** Missing (critical gap)  
**Effort:** 2-3 days  
**Files to Create/Modify:**
- `components/photos/tag-management-modal.tsx` (new)
- `components/photos/tag-selector.tsx` (enhance)
- `lib/ai-processing.ts` (enhance for corrections)

### 3. Site/Project Selection in Upload
**Status:** Backend ready, UI missing  
**Effort:** 1-2 days  
**Files to Modify:**
- `components/upload/upload-interface.tsx`
- `components/upload/site-project-selector.tsx` (new)
- `hooks/use-sites-projects.ts` (new)

---

## 🔧 Technical Specifications

### 1. Bulk Download Implementation

#### Architecture Overview
```typescript
// lib/export/bulk-download.ts
export interface BulkDownloadOptions {
  photoIds: string[];
  format: 'zip' | 'tar';
  structure: 'flat' | 'hierarchical' | 'by-project' | 'by-date';
  includeMetadata: boolean;
  filenamePattern: string;
}

export class BulkDownloadService {
  async createBulkDownload(options: BulkDownloadOptions): Promise<string> {
    // Create ZIP file with selected photos
    // Return download URL or blob
  }
}
```

#### Implementation Details

**File Structure Options:**
1. **Flat**: All photos in root with descriptive names
2. **Hierarchical**: Customer/Project/Photos (SharePoint compatible)
3. **By Project**: Separate folders for each project
4. **By Date**: Organized by upload/taken date

**Progress Tracking:**
- Real-time progress updates via WebSocket or polling
- Granular progress (file compression, metadata generation)
- Error handling for individual file failures

**Performance Requirements:**
- Handle up to 50 photos efficiently
- Stream large files to prevent memory issues
- Cancel/resume capability for large downloads

#### API Implementation

```typescript
// app/api/export/bulk-download/route.ts
export async function POST(request: NextRequest) {
  const { photoIds, options } = await request.json();
  
  // Validate photo access
  // Create ZIP archive
  // Stream response or return signed URL
  
  return NextResponse.json({ 
    downloadUrl: signedUrl,
    expires: expirationTime,
    fileSize: archiveSize 
  });
}
```

#### UI Component

```typescript
// components/photos/bulk-download-modal.tsx
interface BulkDownloadModalProps {
  selectedPhotoIds: Set<string>;
  isOpen: boolean;
  onClose: () => void;
}

export function BulkDownloadModal({ selectedPhotoIds, isOpen, onClose }: BulkDownloadModalProps) {
  // File structure selection
  // Metadata inclusion options
  // Progress tracking
  // Download initiation
}
```

### 2. Tag Management Modal Implementation

#### Architecture Overview
```typescript
// components/photos/tag-management-modal.tsx
interface TagManagementModalProps {
  photos: PhotoWithDetails[];
  isOpen: boolean;
  onClose: () => void;
  onTagsUpdate: (photoId: string, tags: TagUpdate[]) => void;
}

interface TagUpdate {
  tagId: string;
  action: 'add' | 'remove' | 'modify';
  confidence?: number;
  source: 'user' | 'ai_corrected';
}
```

#### Features Required

**1. Multi-Photo Tag Editing:**
- Select multiple photos for batch tag operations
- Add tags to all selected photos
- Remove tags from all selected photos
- Replace tags across selected photos

**2. AI Correction Tracking:**
- Log all user tag modifications
- Track confidence scores for learning
- Record user vs AI tag decisions
- Integration with existing AI correction system

**3. Tag Suggestions:**
- Show AI-suggested tags for approval
- Display confidence levels with visual indicators
- Bulk approve/reject AI suggestions
- Smart tag recommendations based on similar photos

#### Implementation Details

**Tag Operations:**
```typescript
// Tag management operations
interface TagOperation {
  type: 'add' | 'remove' | 'replace' | 'approve_ai' | 'reject_ai';
  tagId: string;
  photoIds: string[];
  confidence?: number;
  userComment?: string;
}

async function executeTagOperation(operation: TagOperation): Promise<void> {
  // Execute database operation
  // Log AI correction if applicable
  // Update UI state
  // Trigger re-indexing for search
}
```

**UI Components:**
- Tag search and selection interface
- Bulk operation controls
- Progress tracking for large operations
- Undo/redo capability
- Visual feedback for AI confidence levels

### 3. Site/Project Selection in Upload

#### Architecture Overview
```typescript
// components/upload/site-project-selector.tsx
interface SiteProjectSelectorProps {
  onSiteChange: (siteId: string | null) => void;
  onProjectChange: (projectId: string | null) => void;
  initialSiteId?: string;
  initialProjectId?: string;
  required?: boolean;
}

// hooks/use-sites-projects.ts
export function useSitesProjects(organizationId: string) {
  // Fetch sites and projects
  // Cache for performance
  // Provide search/filter capabilities
}
```

#### Features Required

**1. Smart Site/Project Selection:**
- Autocomplete with search functionality
- Recent selections prioritized
- Create new site/project inline
- Optional vs required assignment

**2. AI-Powered Suggestions:**
- Suggest based on photo content analysis
- Learn from user selection patterns
- Show confidence in suggestions
- Remember user preferences

**3. Workflow Integration:**
- Seamless integration with existing upload flow
- Bulk assignment after upload
- Progress indicators for assignment operations
- Error handling and validation

#### Implementation Details

**Data Management:**
```typescript
// Site/Project data structures
interface Site {
  id: string;
  name: string;
  customer?: string;
  location?: string;
  recentUploads?: number;
}

interface Project {
  id: string;
  siteId: string;
  name: string;
  description?: string;
  status: 'active' | 'completed' | 'on_hold';
  photoCount?: number;
}
```

**UI Components:**
- Combobox with search and creation
- Visual hierarchy (Site → Project)
- Smart suggestions based on context
- Validation and error states

---

## 🧪 Testing Strategy

### Unit Tests Required

**1. Bulk Download Service:**
```typescript
// __tests__/lib/export/bulk-download.test.ts
describe('BulkDownloadService', () => {
  test('creates ZIP with correct structure');
  test('handles file access errors gracefully');
  test('includes metadata when requested');
  test('respects filename patterns');
  test('handles large file sets efficiently');
});
```

**2. Tag Management:**
```typescript
// __tests__/components/photos/tag-management.test.ts
describe('TagManagementModal', () => {
  test('displays selected photos correctly');
  test('executes bulk tag operations');
  test('tracks AI corrections properly');
  test('shows progress for large operations');
});
```

**3. Site/Project Selection:**
```typescript
// __tests__/components/upload/site-project-selector.test.ts
describe('SiteProjectSelector', () => {
  test('loads sites and projects');
  test('provides autocomplete functionality');
  test('creates new entries inline');
  test('validates required selections');
});
```

### Integration Tests

**1. End-to-End Bulk Operations:**
- Upload multiple photos
- Select photos for bulk operations
- Execute bulk download
- Verify file structure and content

**2. Tag Management Workflow:**
- Upload photos with AI processing
- Open tag management modal
- Execute bulk tag operations
- Verify AI correction logging

**3. Upload with Site/Project:**
- Select site and project during upload
- Verify proper assignment
- Test autocomplete and suggestions
- Validate error handling

### Performance Tests

**1. Bulk Download Performance:**
- Test with 50 photos (max batch size)
- Measure memory usage during compression
- Verify streaming performance
- Test cancel/resume functionality

**2. Tag Operation Performance:**
- Bulk tag operations on 50 photos
- Database transaction performance
- UI responsiveness during operations
- Search re-indexing speed

---

## 📊 Acceptance Criteria

### Functional Requirements

**✅ Bulk Download:**
- [ ] Creates ZIP files with selected photos
- [ ] Supports multiple file structure options
- [ ] Includes metadata when requested
- [ ] Shows progress for large operations
- [ ] Handles errors gracefully
- [ ] Works on mobile devices

**✅ Tag Management:**
- [ ] Allows bulk tag addition/removal
- [ ] Tracks AI corrections properly
- [ ] Shows AI suggestions with confidence
- [ ] Supports undo/redo operations
- [ ] Provides progress feedback
- [ ] Validates tag operations

**✅ Site/Project Selection:**
- [ ] Integrates seamlessly with upload
- [ ] Provides smart suggestions
- [ ] Allows inline creation
- [ ] Works with optional assignment
- [ ] Remembers user preferences
- [ ] Validates selections properly

### Performance Requirements

- Bulk download creates ZIP for 20 photos in <60 seconds
- Tag operations complete for 20 photos in <10 seconds
- Site/project autocomplete responds in <200ms
- UI remains responsive during all operations
- Mobile experience equivalent to desktop

### User Experience Requirements

- Clear progress indicators for all operations
- Intuitive keyboard shortcuts
- Accessible screen reader support
- Error messages are helpful and actionable
- Consistent with existing UI patterns
- Mobile-optimized touch interactions

---

## 🚀 Implementation Timeline

### Day 1-2: Bulk Download Foundation
- Set up ZIP creation infrastructure
- Implement basic download API
- Create progress tracking system
- Basic UI modal implementation

### Day 3: Bulk Download Polish
- Add file structure options
- Implement metadata inclusion
- Error handling and recovery
- Mobile optimization

### Day 4-5: Tag Management Implementation
- Create tag management modal
- Implement bulk tag operations
- AI correction tracking integration
- Progress feedback system

### Day 6: Site/Project Selection
- Create selector components
- Implement autocomplete
- Add inline creation capability
- Smart suggestions integration

### Day 7: Integration & Testing
- End-to-end testing
- Performance optimization
- Bug fixes and polish
- Documentation updates

---

## 🔍 Risk Assessment

### High Risk
- **ZIP Creation Memory Usage**: Large files could cause memory issues
  - *Mitigation*: Implement streaming compression
- **Database Performance**: Bulk operations could slow down system
  - *Mitigation*: Use transactions and batch operations

### Medium Risk
- **Mobile Performance**: Complex operations may be slow on mobile
  - *Mitigation*: Progressive enhancement and optimization
- **User Confusion**: New bulk operations might confuse existing users
  - *Mitigation*: Clear UI patterns and help documentation

### Low Risk
- **Browser Compatibility**: ZIP creation might not work in all browsers
  - *Mitigation*: Feature detection and fallbacks

---

## 📝 Implementation Notes

### Development Setup
1. Install additional dependencies for ZIP creation (`jszip`, `file-saver`)
2. Set up testing environment for large file operations
3. Configure development database with test data
4. Set up performance monitoring tools

### Code Quality Standards
- Follow existing TypeScript patterns
- Maintain 80%+ test coverage
- Use existing shadcn/ui components
- Document all public APIs
- Follow accessibility guidelines

### Performance Considerations
- Use Web Workers for large ZIP operations
- Implement proper cancellation for long operations
- Cache site/project data aggressively
- Optimize database queries for bulk operations

---

**Next Steps:** Begin implementation with bulk download service, as it's the most critical feature for user workflow completion.