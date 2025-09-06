# Phase 3: Photo Management Component Stories
**Module:** Photo Management  
**Components:** 9 core photo handling components  
**Estimated Time:** 3 hours  
**Priority:** High (core business functionality)

## Overview

Photo management components form the heart of the Minerva application, handling the display, organization, and manipulation of industrial safety photos. These components must handle large datasets efficiently while providing intuitive interfaces for safety engineers and inspectors.

## Component Priority Matrix

### Tier 1: Core Display Components (1.5 hours)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| PhotoGrid | `photo-grid.tsx` | High | Critical | 30 min |
| PhotoDetailModal | `photo-detail-modal.tsx` | High | Critical | 25 min |
| PhotoFilters | `photo-filters.tsx` | Medium | High | 20 min |
| PhotoToolbar | `photo-toolbar.tsx` | Medium | High | 15 min |

### Tier 2: Advanced Layout Components (45 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| JustifiedPhotoGrid | `justified-photo-grid.tsx` | Medium | Medium | 15 min |
| MasonryPhotoGrid | `masonry-photo-grid.tsx` | Medium | Medium | 15 min |
| MobilePhotoGrid | `mobile-photo-grid.tsx` | Medium | High | 15 min |

### Tier 3: Specialized Components (45 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| BulkOperationsModal | `bulk-operations-modal.tsx` | Medium | High | 20 min |
| PhotoChat | `photo-chat.tsx` | High | Medium | 25 min |

## Detailed Implementation Guide

### Tier 1: Core Display Components

#### 1. PhotoGrid Component (`photo-grid.tsx`)

**Story File:** `components/photos/photo-grid.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { PhotoGrid } from './photo-grid';
import { PhotoManagementProvider } from '../../../stores/photo-management-store';
import { mockPhotoData } from '../../../.storybook/mocks/photo-data';
import { action } from '@storybook/addon-actions';

const meta: Meta<typeof PhotoGrid> = {
  title: 'Features/Photos/PhotoGrid',
  component: PhotoGrid,
  parameters: {
    layout: 'fullscreen',
    docs: {
      description: {
        component: `
**PhotoGrid** - The primary photo display component in Minerva

Core functionality for displaying industrial safety photos in responsive grid layouts.
Supports multiple layout algorithms, bulk selection, lazy loading, and real-time updates.

**Key Features:**
- **Layout Modes**: Standard grid, justified rows, masonry layout
- **Performance**: Virtualized rendering for 1000+ photos
- **Selection**: Bulk selection with keyboard shortcuts (Shift+Click, Ctrl+A)
- **Lazy Loading**: Images load as they enter viewport
- **Responsive**: Adapts column count based on screen size
- **Integration**: Works with search, filters, and AI tagging systems

**Common Use Cases:**
- Project photo overview and browsing
- Photo selection for bulk operations
- Visual search and identification
- Progress tracking during inspections
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <PhotoManagementProvider>
        <div className="h-screen bg-background">
          <Story />
        </div>
      </PhotoManagementProvider>
    ),
  ],
  argTypes: {
    photos: {
      description: 'Array of photo objects to display',
      control: false, // Complex object, controlled by stories
    },
    layoutMode: {
      control: { type: 'select' },
      options: ['grid', 'justified', 'masonry'],
      description: 'Grid layout algorithm',
      table: {
        type: { summary: 'grid | justified | masonry' },
        defaultValue: { summary: 'grid' },
      },
    },
    density: {
      control: { type: 'range', min: 100, max: 400, step: 25 },
      description: 'Photo size density (pixels)',
      table: {
        type: { summary: 'number' },
        defaultValue: { summary: '200' },
      },
    },
    selectionMode: {
      control: 'boolean',
      description: 'Enable multi-select mode for bulk operations',
    },
    showMetadata: {
      control: 'boolean',
      description: 'Show photo metadata overlay on hover',
    },
    onPhotoClick: { action: 'photo-clicked' },
    onSelectionChange: { action: 'selection-changed' },
    onPhotoLoad: { action: 'photo-loaded' },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const StandardGrid: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection.slice(0, 24),
    layoutMode: 'grid',
    density: 200,
    selectionMode: false,
    showMetadata: true,
    onPhotoClick: action('photo-clicked'),
    onSelectionChange: action('selection-changed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Standard grid layout with consistent photo sizes. Best for general browsing and consistent visual presentation.',
      },
    },
  },
};

export const JustifiedLayout: Story = {
  args: {
    photos: mockPhotoData.mixedAspectRatios.slice(0, 30),
    layoutMode: 'justified',
    density: 250,
    showMetadata: true,
    onPhotoClick: action('photo-clicked'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Justified layout optimizes row heights for better space utilization. Handles mixed aspect ratios elegantly.',
      },
    },
  },
};

export const MasonryLayout: Story = {
  args: {
    photos: mockPhotoData.mixedAspectRatios.slice(0, 24),
    layoutMode: 'masonry',
    density: 200,
    showMetadata: true,
    onPhotoClick: action('photo-clicked'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Masonry layout creates a Pinterest-style display. Ideal for varied photo dimensions and portrait orientations.',
      },
    },
  },
};

export const BulkSelectionMode: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection.slice(0, 16),
    layoutMode: 'grid',
    density: 180,
    selectionMode: true,
    selectedPhotos: ['photo-001', 'photo-003', 'photo-007'],
    showMetadata: false,
    onPhotoClick: action('photo-clicked'),
    onSelectionChange: action('selection-changed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Bulk selection mode for batch operations. Shows selection checkboxes and highlights selected photos.',
      },
    },
  },
};

export const HighDensityView: Story = {
  args: {
    photos: mockPhotoData.largeDemoDataset.slice(0, 100),
    layoutMode: 'grid',
    density: 120,
    showMetadata: false,
    onPhotoClick: action('photo-clicked'),
  },
  parameters: {
    docs: {
      description: {
        story: 'High-density view for quick overview of large photo collections. Smaller thumbnails allow more photos per view.',
      },
    },
  },
};

export const LargeDensityView: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection.slice(0, 12),
    layoutMode: 'grid',
    density: 350,
    showMetadata: true,
    onPhotoClick: action('photo-clicked'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Large density view for detailed photo inspection. Bigger thumbnails show more detail for quality assessment.',
      },
    },
  },
};

export const LoadingState: Story = {
  args: {
    photos: [],
    isLoading: true,
    layoutMode: 'grid',
    density: 200,
  },
  parameters: {
    docs: {
      description: {
        story: 'Loading state while fetching photos from server. Shows skeleton placeholders maintaining layout.',
      },
    },
  },
};

export const EmptyState: Story = {
  args: {
    photos: [],
    isLoading: false,
    layoutMode: 'grid',
    density: 200,
    emptyMessage: 'No photos found',
    emptyDescription: 'Try adjusting your filters or upload new photos to get started.',
  },
  parameters: {
    docs: {
      description: {
        story: 'Empty state when no photos match current filters or project has no photos yet.',
      },
    },
  },
};

export const ErrorState: Story = {
  args: {
    photos: [],
    isLoading: false,
    error: 'Failed to load photos. Please check your connection and try again.',
    layoutMode: 'grid',
    density: 200,
    onRetry: action('retry-clicked'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Error state when photo loading fails. Provides retry action and helpful error message.',
      },
    },
  },
};

export const PerformanceTest: Story = {
  args: {
    photos: mockPhotoData.largeDemoDataset, // 500+ photos
    layoutMode: 'justified',
    density: 180,
    showMetadata: true,
    virtualized: true,
    onPhotoClick: action('photo-clicked'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Performance test with large dataset (500+ photos). Tests virtualization and smooth scrolling.',
      },
    },
    chromatic: { disable: true }, // Skip visual testing for performance story
  },
};

export const InteractiveDemo: Story = {
  render: () => {
    const [layoutMode, setLayoutMode] = React.useState<'grid' | 'justified' | 'masonry'>('grid');
    const [density, setDensity] = React.useState(200);
    const [selectionMode, setSelectionMode] = React.useState(false);
    const [selectedPhotos, setSelectedPhotos] = React.useState<string[]>([]);

    return (
      <div className="h-screen flex flex-col">
        <div className="p-4 border-b space-y-4">
          <div className="flex items-center gap-4">
            <label className="text-sm font-medium">Layout:</label>
            <select 
              value={layoutMode} 
              onChange={(e) => setLayoutMode(e.target.value as any)}
              className="px-3 py-1 border rounded"
            >
              <option value="grid">Grid</option>
              <option value="justified">Justified</option>
              <option value="masonry">Masonry</option>
            </select>
            
            <label className="text-sm font-medium">Density:</label>
            <input
              type="range"
              min={100}
              max={400}
              step={25}
              value={density}
              onChange={(e) => setDensity(Number(e.target.value))}
              className="w-32"
            />
            <span className="text-sm text-muted-foreground">{density}px</span>
            
            <label className="text-sm font-medium flex items-center gap-2">
              <input
                type="checkbox"
                checked={selectionMode}
                onChange={(e) => setSelectionMode(e.target.checked)}
              />
              Selection Mode
            </label>
            
            {selectionMode && (
              <span className="text-sm text-muted-foreground">
                {selectedPhotos.length} selected
              </span>
            )}
          </div>
        </div>
        
        <div className="flex-1">
          <PhotoGrid
            photos={mockPhotoData.manufacturingInspection}
            layoutMode={layoutMode}
            density={density}
            selectionMode={selectionMode}
            selectedPhotos={selectedPhotos}
            onSelectionChange={setSelectedPhotos}
            onPhotoClick={action('photo-clicked')}
            showMetadata={true}
          />
        </div>
      </div>
    );
  },
  parameters: {
    docs: {
      description: {
        story: 'Interactive demo allowing real-time adjustment of grid properties. Perfect for testing different configurations.',
      },
    },
  },
};
```

#### 2. PhotoDetailModal Component (`photo-detail-modal.tsx`)

**Story File:** `components/photos/photo-detail-modal.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { PhotoDetailModal } from './photo-detail-modal';
import { mockPhotoData, mockAITaggingData } from '../../../.storybook/mocks';
import { action } from '@storybook/addon-actions';

const meta: Meta<typeof PhotoDetailModal> = {
  title: 'Features/Photos/PhotoDetailModal',
  component: PhotoDetailModal,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: `
**PhotoDetailModal** - Comprehensive photo viewing and editing interface

Full-screen modal for viewing photo details, metadata, AI tags, and performing actions.
Central component for photo inspection and data management workflows.

**Key Features:**
- **High-resolution viewing** with zoom and pan capabilities
- **Metadata display** including EXIF data, GPS location, and upload info
- **AI tag management** with confidence scores and manual overrides
- **Action menu** for move, delete, download, and sharing operations
- **Navigation** between photos within current collection
- **Comments and notes** for collaborative inspection workflows

**Integration Points:**
- AI tagging system for automated photo analysis
- Photo management store for actions and state
- Export system for generating reports
- Collaboration features for team communication
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    photo: {
      description: 'Photo object with metadata and AI analysis',
      control: false,
    },
    isOpen: {
      control: 'boolean',
      description: 'Modal visibility state',
    },
    onClose: { action: 'modal-closed' },
    onPhotoAction: { action: 'photo-action' },
    onTagUpdate: { action: 'tag-updated' },
    onNavigate: { action: 'navigate-photo' },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const StandardPhotoView: Story = {
  args: {
    photo: {
      ...mockPhotoData.manufacturingInspection[0],
      aiAnalysis: mockAITaggingData.highConfidenceTags,
      exifData: {
        camera: 'iPhone 15 Pro',
        lens: '24mm f/1.78',
        iso: 100,
        shutterspeed: '1/120',
        aperture: 'f/1.8',
        focalLength: '24mm',
        timestamp: '2025-08-15T10:30:00Z',
      },
      gpsData: {
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10,
        accuracy: 5,
      },
    },
    isOpen: true,
    canNavigate: true,
    hasNextPhoto: true,
    hasPreviousPhoto: true,
    onClose: action('modal-closed'),
    onPhotoAction: action('photo-action'),
    onTagUpdate: action('tag-updated'),
    onNavigate: action('navigate-photo'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Standard photo detail view with complete metadata, AI tags, and navigation controls.',
      },
    },
  },
};

export const AIAnalysisInProgress: Story = {
  args: {
    photo: {
      ...mockPhotoData.manufacturingInspection[1],
      aiAnalysis: null,
      isAnalyzing: true,
      analysisProgress: 0.65,
    },
    isOpen: true,
    onClose: action('modal-closed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Photo detail view while AI analysis is in progress, showing real-time progress indicator.',
      },
    },
  },
};

export const MixedConfidenceAIResults: Story = {
  args: {
    photo: {
      ...mockPhotoData.manufacturingInspection[2],
      aiAnalysis: mockAITaggingData.mixedConfidenceTags,
      userTagOverrides: {
        'safety-shoes': { approved: false, reason: 'Not clearly visible' },
        'hard-hat': { approved: true },
      },
    },
    isOpen: true,
    onClose: action('modal-closed'),
    onTagUpdate: action('tag-updated'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Photo with mixed-confidence AI results requiring user review and tag validation.',
      },
    },
  },
};

export const PhotoWithComments: Story = {
  args: {
    photo: {
      ...mockPhotoData.manufacturingInspection[0],
      comments: [
        {
          id: 'comment-1',
          author: 'John Smith',
          content: 'Safety guard appears properly installed and secured.',
          timestamp: '2025-08-15T11:00:00Z',
          role: 'Safety Engineer',
        },
        {
          id: 'comment-2',
          author: 'Maria Garcia',
          content: 'Recommend additional signage for this area.',
          timestamp: '2025-08-15T11:15:00Z',
          role: 'Plant Manager',
        },
      ],
      userCanComment: true,
    },
    isOpen: true,
    onClose: action('modal-closed'),
    onCommentAdd: action('comment-added'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Photo with collaborative comments from multiple team members for inspection discussions.',
      },
    },
  },
};

export const PhotoEditMode: Story = {
  args: {
    photo: {
      ...mockPhotoData.manufacturingInspection[0],
      editMode: true,
    },
    isOpen: true,
    editMode: true,
    onClose: action('modal-closed'),
    onSave: action('photo-saved'),
    onCancel: action('edit-cancelled'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Photo in edit mode allowing users to modify tags, location, project assignment, and metadata.',
      },
    },
  },
};

export const PhotoWithoutAIAnalysis: Story = {
  args: {
    photo: {
      ...mockPhotoData.manufacturingInspection[3],
      aiAnalysis: null,
      manualTags: ['machinery', 'inspection', 'completed'],
      taggedBy: 'John Smith',
      taggedAt: '2025-08-15T10:45:00Z',
    },
    isOpen: true,
    onClose: action('modal-closed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Photo with only manual tags, no AI analysis. Shows manual tagging workflow.',
      },
    },
  },
};

export const HighResolutionPhoto: Story = {
  args: {
    photo: {
      ...mockPhotoData.manufacturingInspection[0],
      url: 'https://picsum.photos/4000/3000?random=1',
      metadata: {
        ...mockPhotoData.manufacturingInspection[0].metadata,
        dimensions: '4000x3000',
        size: '8.5 MB',
      },
    },
    isOpen: true,
    zoomEnabled: true,
    onClose: action('modal-closed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'High-resolution photo with zoom and pan capabilities for detailed inspection.',
      },
    },
  },
};

export const ErrorLoadingPhoto: Story = {
  args: {
    photo: {
      ...mockPhotoData.manufacturingInspection[0],
      url: 'invalid-url',
      loadError: true,
    },
    isOpen: true,
    onClose: action('modal-closed'),
    onRetryLoad: action('retry-load'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Error state when photo fails to load, with retry action and fallback display.',
      },
    },
  },
};
```

### Tier 2: Advanced Layout Components

#### 3. MobilePhotoGrid Component (`mobile-photo-grid.tsx`)

**Story File:** `components/photos/mobile-photo-grid.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { MobilePhotoGrid } from './mobile-photo-grid';
import { mockPhotoData } from '../../../.storybook/mocks/photo-data';

const meta: Meta<typeof MobilePhotoGrid> = {
  title: 'Features/Photos/MobilePhotoGrid',
  component: MobilePhotoGrid,
  parameters: {
    layout: 'fullscreen',
    viewport: {
      defaultViewport: 'mobile1',
    },
    docs: {
      description: {
        component: `
**MobilePhotoGrid** - Mobile-optimized photo grid component

Specialized photo grid designed for mobile devices with touch interactions,
pull-to-refresh, infinite scrolling, and gesture-based selection.

**Mobile-Specific Features:**
- **Touch gestures**: Long-press for selection, swipe for actions
- **Pull-to-refresh**: Native mobile refresh pattern
- **Infinite scroll**: Load more photos as user scrolls
- **Optimized layout**: Single/double column layouts for mobile screens
- **Fast navigation**: Quick photo preview with tap-to-view
- **Offline support**: Cached photos available without connection

**Performance Optimizations:**
- Smaller thumbnail sizes for mobile bandwidth
- Progressive image loading with blur-up technique
- Virtual scrolling for large collections
- Touch-optimized hit targets (44px minimum)
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="h-screen w-full max-w-sm mx-auto border">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof meta>;

export const SingleColumnLayout: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection.slice(0, 20),
    columnCount: 1,
    showMetadata: true,
    enablePullToRefresh: true,
    onPhotoTap: action('photo-tapped'),
    onPullToRefresh: action('pull-to-refresh'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Single column layout optimized for narrow mobile screens and portrait orientation.',
      },
    },
  },
};

export const DoubleColumnLayout: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection.slice(0, 30),
    columnCount: 2,
    showMetadata: false,
    enablePullToRefresh: true,
    onPhotoTap: action('photo-tapped'),
    onLongPress: action('photo-long-press'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Double column layout for wider mobile screens and landscape orientation.',
      },
    },
  },
};

export const SelectionMode: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection.slice(0, 16),
    columnCount: 2,
    selectionMode: true,
    selectedPhotos: ['photo-001', 'photo-003'],
    onSelectionChange: action('selection-changed'),
    onSelectionAction: action('selection-action'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Mobile selection mode with touch-friendly selection indicators and batch action bar.',
      },
    },
  },
};
```

## Mock Data Requirements

### Enhanced Photo Data Structure

```typescript
// .storybook/mocks/photo-data.ts
export interface PhotoData {
  id: string;
  url: string;
  thumbnail: string;
  filename: string;
  uploadedAt: string;
  uploadedBy: string;
  tags: string[];
  manualTags?: string[];
  aiAnalysis?: AITagResult[];
  isAnalyzing?: boolean;
  analysisProgress?: number;
  project: string;
  site: string;
  location: string;
  gpsData?: {
    latitude: number;
    longitude: number;
    altitude?: number;
    accuracy?: number;
  };
  exifData?: {
    camera: string;
    lens?: string;
    iso?: number;
    shutterspeed?: string;
    aperture?: string;
    focalLength?: string;
    timestamp: string;
  };
  metadata: {
    size: string;
    dimensions: string;
    fileType: string;
    checksum?: string;
  };
  comments?: Comment[];
  userCanEdit?: boolean;
  userCanComment?: boolean;
  loadError?: boolean;
}

export const mockPhotoData = {
  manufacturingInspection: [
    // 30+ realistic photos with complete metadata
  ],
  mixedAspectRatios: [
    // Photos with various aspect ratios for layout testing
  ],
  largeDemoDataset: [
    // 500+ photos for performance testing
  ],
  highResolutionSamples: [
    // Large photos for zoom/pan testing
  ],
};
```

## Quality Checklist

### Component Stories Quality
- [ ] **Realistic Data**: All stories use production-like mock data
- [ ] **Complete States**: Loading, error, empty, and success states
- [ ] **Mobile Responsive**: Components work on mobile, tablet, desktop
- [ ] **Performance**: Large datasets (100+ photos) handle smoothly
- [ ] **Accessibility**: Keyboard navigation and screen reader support
- [ ] **Interactions**: All user interactions trigger actions correctly

### Business Logic Validation
- [ ] **Photo Selection**: Multi-select with keyboard shortcuts works
- [ ] **Layout Algorithms**: Grid, justified, and masonry layouts render correctly
- [ ] **AI Integration**: AI tagging states and workflows are realistic
- [ ] **Metadata Display**: All photo metadata displays correctly
- [ ] **Navigation**: Photo-to-photo navigation works smoothly

### Integration Testing
- [ ] **Store Integration**: Components work with photo management store
- [ ] **API Simulation**: Mock API responses for all states
- [ ] **Error Handling**: Network errors and retry mechanisms work
- [ ] **Performance**: Virtualization works with large datasets

---

**Next Component Module**: After completing photo management stories, proceed to AI management component stories for comprehensive AI workflow documentation.