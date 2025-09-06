# Phase 3: Feature-Specific Component Stories
**Estimated Time:** 8-10 hours  
**Prerequisites:** Phase 1 & 2 completed successfully  
**Status:** Ready for Implementation

## Overview

Phase 3 focuses on creating comprehensive stories for Minerva's feature-specific components that power the core functionality of the machine safety photo organizer. This phase documents the complex, business-logic components that make Minerva unique and valuable for industrial safety teams.

## Objectives

### Primary Goals
- ✅ Document all photo management components with realistic data
- ✅ Create comprehensive AI component stories with various states
- ✅ Build interactive search and filtering component examples
- ✅ Document organization and project management interfaces
- ✅ Create upload workflow component stories

### Success Criteria
- All 25+ feature components documented with interactive examples
- Realistic mock data for photo management scenarios
- AI processing state demonstrations with various outcomes
- Search and filter workflows with comprehensive examples
- Upload progress and error state handling demonstrations
- Organization hierarchy and multi-tenant patterns documented

## Component Analysis

Based on the Minerva components directory, here are the feature-specific components requiring documentation:

### Photo Management Components (Priority 1) - 3 hours
**Location:** `components/photos/`

| Component | Complexity | Business Logic | Est. Time |
|-----------|------------|----------------|-----------|
| `photo-grid.tsx` | High | Grid layout, selection, lazy loading | 30 min |
| `photo-detail-modal.tsx` | High | Metadata, tagging, actions | 25 min |
| `photo-filters.tsx` | Medium | Multi-criteria filtering | 20 min |
| `bulk-operations-modal.tsx` | Medium | Batch actions, progress tracking | 20 min |
| `photo-upload-modal.tsx` | High | File handling, validation, progress | 25 min |
| `justified-photo-grid.tsx` | Medium | Advanced layout algorithm | 15 min |
| `masonry-photo-grid.tsx` | Medium | Masonry layout implementation | 15 min |
| `photo-toolbar.tsx` | Medium | Actions, view modes, selection | 15 min |
| `photo-chat.tsx` | High | AI conversation interface | 25 min |

### AI Management Components (Priority 1) - 2.5 hours
**Location:** `components/ai/`

| Component | Complexity | Business Logic | Est. Time |
|-----------|------------|----------------|-----------|
| `ai-tag-suggestions.tsx` | High | ML predictions, confidence scores | 25 min |
| `ai-analytics-dashboard.tsx` | High | Performance metrics, charts | 30 min |
| `processing-indicator.tsx` | Medium | Real-time processing status | 15 min |
| `UnifiedAIManagement.tsx` | High | Complete AI control interface | 30 min |
| `features/PhotoTaggingManagement.tsx` | High | Tagging workflows, feedback | 25 min |
| `features/SmartProcessingPipeline.tsx` | High | Pipeline configuration | 25 min |
| `monitoring/RealTimeMonitor.tsx` | Medium | Live system monitoring | 20 min |

### Search & Organization Components (Priority 2) - 1.5 hours
**Location:** `components/search/`, `components/organization/`

| Component | Complexity | Business Logic | Est. Time |
|-----------|------------|----------------|-----------|
| `intelligent-search.tsx` | High | AI-powered search interface | 25 min |
| `search-filters.tsx` | Medium | Advanced filtering UI | 15 min |
| `saved-searches.tsx` | Medium | Search persistence, management | 15 min |
| `project-manager.tsx` | High | Project CRUD, organization | 20 min |
| `site-manager.tsx` | Medium | Site hierarchy management | 15 min |
| `export-wizard.tsx` | High | Multi-step export process | 20 min |

### Upload Components (Priority 2) - 1 hour
**Location:** `components/upload/`

| Component | Complexity | Business Logic | Est. Time |
|-----------|------------|----------------|-----------|
| `file-drop-zone.tsx` | Medium | Drag & drop, validation | 20 min |
| `upload-progress.tsx` | Medium | Progress tracking, error handling | 15 min |
| `file-preview.tsx` | Medium | File thumbnails, metadata | 15 min |
| `site-project-selector.tsx` | Medium | Organization assignment | 10 min |

## Implementation Strategy

### Story Development Approach

Each component story will follow this enhanced pattern for feature components:

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { ComponentName } from './component-name';
import { mockPhotoData, mockAIResults, mockUserData } from '../../../.storybook/mocks';

const meta: Meta<typeof ComponentName> = {
  title: 'Features/ComponentCategory/ComponentName',
  component: ComponentName,
  parameters: {
    layout: 'fullscreen', // Many feature components need full layout
    docs: {
      description: {
        component: `
Business logic component description with:
- Use case in Minerva workflow
- Key features and capabilities  
- Integration with other components
- Performance considerations
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    // Complex prop controls with realistic options
  },
  decorators: [
    // Context providers, mock data setup
  ],
};

export default meta;
type Story = StoryObj<typeof meta>;

// Standard story patterns for feature components:
export const Default: Story = { /* ... */ };
export const WithData: Story = { /* ... */ };
export const LoadingState: Story = { /* ... */ };
export const ErrorState: Story = { /* ... */ };
export const EmptyState: Story = { /* ... */ };
export const InteractiveWorkflow: Story = { /* ... */ };
```

## Phase 3 Implementation Plan

### Step 1: Photo Management Components (3 hours)

#### Photo Grid Component Stories
**File:** `components/photos/photo-grid.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { PhotoGrid } from './photo-grid';
import { mockPhotoData } from '../../../.storybook/mocks/photo-data';
import { PhotoManagementProvider } from '../../../stores/photo-management-store';

const meta: Meta<typeof PhotoGrid> = {
  title: 'Features/Photos/PhotoGrid',
  component: PhotoGrid,
  parameters: {
    layout: 'fullscreen',
    docs: {
      description: {
        component: `
Main photo display component supporting multiple layout modes, selection, and lazy loading.
Core component of the Minerva photo management interface.

**Key Features:**
- Responsive grid layouts (justified, masonry, standard)
- Bulk selection with keyboard shortcuts
- Lazy loading for performance with large datasets
- Photo metadata overlay and quick actions
- Integration with AI tagging and search systems
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <PhotoManagementProvider>
        <div className="h-screen">
          <Story />
        </div>
      </PhotoManagementProvider>
    ),
  ],
  argTypes: {
    layoutMode: {
      control: { type: 'select' },
      options: ['grid', 'justified', 'masonry'],
      description: 'Photo layout algorithm',
    },
    density: {
      control: { type: 'range', min: 100, max: 400, step: 50 },
      description: 'Photo size density',
    },
    selectionMode: {
      control: 'boolean',
      description: 'Enable bulk selection mode',
    },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const StandardGrid: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection,
    layoutMode: 'grid',
    density: 200,
  },
};

export const JustifiedLayout: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection,
    layoutMode: 'justified',
    density: 250,
  },
  parameters: {
    docs: {
      description: {
        story: 'Justified layout optimizes row heights for better space utilization.',
      },
    },
  },
};

export const MasonryLayout: Story = {
  args: {
    photos: mockPhotoData.mixedAspectRatios,
    layoutMode: 'masonry',
    density: 200,
  },
  parameters: {
    docs: {
      description: {
        story: 'Masonry layout handles varied aspect ratios efficiently.',
      },
    },
  },
};

export const SelectionMode: Story = {
  args: {
    photos: mockPhotoData.manufacturingInspection,
    layoutMode: 'grid',
    selectionMode: true,
    selectedPhotos: [mockPhotoData.manufacturingInspection[0].id, mockPhotoData.manufacturingInspection[2].id],
  },
  parameters: {
    docs: {
      description: {
        story: 'Bulk selection mode for batch operations like tagging, moving, or deleting photos.',
      },
    },
  },
};

export const LoadingState: Story = {
  args: {
    photos: [],
    isLoading: true,
    layoutMode: 'grid',
  },
  parameters: {
    docs: {
      description: {
        story: 'Loading state while fetching photos from the server.',
      },
    },
  },
};

export const EmptyState: Story = {
  args: {
    photos: [],
    isLoading: false,
    layoutMode: 'grid',
  },
  parameters: {
    docs: {
      description: {
        story: 'Empty state when no photos match current filters or project is empty.',
      },
    },
  },
};

export const LargeDataset: Story = {
  args: {
    photos: mockPhotoData.largeDemoDataset, // 500+ photos
    layoutMode: 'justified',
    density: 150,
  },
  parameters: {
    docs: {
      description: {
        story: 'Performance test with large dataset demonstrating lazy loading and virtualization.',
      },
    },
  },
};
```

#### AI Tag Suggestions Component
**File:** `components/ai/ai-tag-suggestions.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { AITagSuggestions } from './ai-tag-suggestions';
import { mockAITaggingData } from '../../../.storybook/mocks/ai-data';

const meta: Meta<typeof AITagSuggestions> = {
  title: 'Features/AI/TagSuggestions',
  component: AITagSuggestions,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: `
AI-powered tag suggestions component that analyzes photos and suggests relevant safety tags
based on computer vision analysis and machine learning models.

**Key Features:**
- Real-time tag suggestions with confidence scores
- Manual tag approval/rejection workflow
- Batch tag application for multiple photos
- Learning from user feedback to improve accuracy
- Integration with safety category hierarchies
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="w-full max-w-2xl">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof meta>;

export const HighConfidenceSuggestions: Story = {
  args: {
    photoId: 'photo-123',
    suggestions: mockAITaggingData.highConfidenceTags,
    isAnalyzing: false,
  },
  parameters: {
    docs: {
      description: {
        story: 'High-confidence AI tag suggestions with clear safety categories identified.',
      },
    },
  },
};

export const MixedConfidenceResults: Story = {
  args: {
    photoId: 'photo-456',
    suggestions: mockAITaggingData.mixedConfidenceTags,
    isAnalyzing: false,
  },
  parameters: {
    docs: {
      description: {
        story: 'Mixed confidence results requiring user review and validation.',
      },
    },
  },
};

export const AnalyzingState: Story = {
  args: {
    photoId: 'photo-789',
    suggestions: [],
    isAnalyzing: true,
    progress: 65,
  },
  parameters: {
    docs: {
      description: {
        story: 'AI analysis in progress with real-time progress indication.',
      },
    },
  },
};

export const ErrorState: Story = {
  args: {
    photoId: 'photo-error',
    suggestions: [],
    isAnalyzing: false,
    error: 'Analysis failed: Image quality too low for reliable processing',
  },
  parameters: {
    docs: {
      description: {
        story: 'Error state when AI analysis fails with actionable error message.',
      },
    },
  },
};

export const BatchTaggingMode: Story = {
  args: {
    photoIds: ['photo-1', 'photo-2', 'photo-3'],
    suggestions: mockAITaggingData.batchSuggestions,
    mode: 'batch',
    isAnalyzing: false,
  },
  parameters: {
    docs: {
      description: {
        story: 'Batch tagging mode for applying consistent tags across multiple photos.',
      },
    },
  },
};
```

### Step 2: Mock Data Setup (1 hour)

Create comprehensive mock data for realistic stories:

**File:** `.storybook/mocks/photo-data.ts`

```typescript
export const mockPhotoData = {
  manufacturingInspection: [
    {
      id: 'photo-001',
      url: 'https://picsum.photos/800/600?random=1',
      thumbnail: 'https://picsum.photos/200/150?random=1', 
      filename: 'conveyor_safety_check_001.jpg',
      uploadedAt: '2025-08-15T10:30:00Z',
      tags: ['conveyor-belt', 'safety-guard', 'inspection'],
      aiConfidence: 0.92,
      location: 'Manufacturing Floor A',
      project: 'Q3 Safety Inspection',
      site: 'Main Production Facility',
      metadata: {
        camera: 'iPhone 15 Pro',
        size: '2.4 MB',
        dimensions: '4032x3024',
        gps: { lat: 40.7128, lng: -74.0060 },
      },
    },
    // ... more realistic photo data
  ],
  
  largeDemoDataset: Array.from({ length: 500 }, (_, i) => ({
    id: `photo-${String(i).padStart(3, '0')}`,
    url: `https://picsum.photos/800/600?random=${i}`,
    thumbnail: `https://picsum.photos/200/150?random=${i}`,
    filename: `safety_photo_${String(i).padStart(3, '0')}.jpg`,
    uploadedAt: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString(),
    tags: generateRandomTags(),
    aiConfidence: 0.3 + Math.random() * 0.7,
    location: randomLocation(),
    project: randomProject(),
    site: randomSite(),
  })),
};

function generateRandomTags() {
  const allTags = [
    'conveyor-belt', 'safety-guard', 'emergency-stop', 'warning-sign',
    'hard-hat', 'safety-shoes', 'fire-extinguisher', 'first-aid',
    'machinery', 'electrical-panel', 'hazard-sign', 'safety-barrier'
  ];
  const count = Math.floor(Math.random() * 4) + 1;
  return allTags.sort(() => 0.5 - Math.random()).slice(0, count);
}
```

**File:** `.storybook/mocks/ai-data.ts`

```typescript
export const mockAITaggingData = {
  highConfidenceTags: [
    {
      tag: 'conveyor-belt',
      confidence: 0.94,
      category: 'machinery',
      boundingBox: { x: 120, y: 80, width: 340, height: 180 },
      approved: null,
    },
    {
      tag: 'safety-guard',
      confidence: 0.87,
      category: 'safety-equipment',
      boundingBox: { x: 200, y: 150, width: 120, height: 90 },
      approved: null,
    },
    {
      tag: 'emergency-stop',
      confidence: 0.91,
      category: 'controls',
      boundingBox: { x: 450, y: 60, width: 40, height: 40 },
      approved: null,
    },
  ],
  
  mixedConfidenceTags: [
    {
      tag: 'hard-hat',
      confidence: 0.78,
      category: 'ppe',
      boundingBox: { x: 300, y: 20, width: 60, height: 50 },
      approved: null,
    },
    {
      tag: 'safety-shoes',
      confidence: 0.45,
      category: 'ppe',
      boundingBox: { x: 250, y: 400, width: 80, height: 40 },
      approved: null,
      flagged: true,
      reason: 'Low confidence - manual review recommended',
    },
    {
      tag: 'warning-sign',
      confidence: 0.62,
      category: 'signage',
      boundingBox: { x: 500, y: 200, width: 100, height: 80 },
      approved: null,
    },
  ],
};
```

### Step 3: Complex Workflow Components (2 hours)

Document complex components like export wizards, upload workflows, and search interfaces.

### Step 4: Interactive Component Testing (1 hour)

Create interactive stories that demonstrate component workflows and user interactions.

## Testing & Validation Strategy

### Component Integration Tests
- **Mock Data Accuracy**: Ensure all mock data reflects real-world usage patterns
- **State Management**: Test component state changes and data flow
- **Error Handling**: Validate error states and user feedback mechanisms
- **Performance**: Test components with large datasets and complex interactions

### User Workflow Validation
- **Complete Workflows**: Document end-to-end user workflows with multiple components
- **Edge Cases**: Include edge cases and error scenarios in stories
- **Accessibility**: Ensure all interactive components meet a11y standards
- **Responsive Design**: Test components across all viewport sizes

### Integration Points
- **API Integration**: Mock realistic API responses and error states
- **Store Integration**: Test components with realistic store state
- **Navigation**: Validate component integration with routing and navigation
- **Theme Support**: Ensure all components work with light/dark themes

## Deliverables

### Component Stories
- ✅ 25+ feature-specific component stories with realistic data
- ✅ Interactive workflow demonstrations
- ✅ Comprehensive state handling (loading, error, empty, success)
- ✅ Performance testing with large datasets

### Mock Data Infrastructure
- ✅ Realistic photo metadata and AI analysis results
- ✅ User data and organization hierarchies
- ✅ Search and filtering mock responses
- ✅ Upload progress and error simulation

### Documentation
- ✅ Business logic component API documentation
- ✅ Workflow integration guides
- ✅ Performance considerations and best practices
- ✅ Troubleshooting guides for complex components

## Quality Checklist

For each feature component story:
- [ ] **Realistic Data**: Uses production-like mock data
- [ ] **Complete States**: Loading, error, empty, and success states documented
- [ ] **Interactions**: All user interactions work correctly
- [ ] **Performance**: Large datasets handle smoothly
- [ ] **Accessibility**: No a11y violations, keyboard navigation works
- [ ] **Documentation**: Clear business context and usage guidelines
- [ ] **Integration**: Shows how component fits into larger workflows

## Next Steps

After Phase 3 completion:

1. **Workflow Validation**: Test complete user workflows across multiple components
2. **Performance Review**: Validate component performance with realistic datasets
3. **Business Review**: Demo feature components to stakeholders for feedback
4. **Begin Phase 4**: Start Playwright integration for component testing

---

**Note**: Phase 3 creates the comprehensive component library that demonstrates Minerva's unique value proposition. Focus on realistic scenarios and complete user workflows to maximize the value of the component documentation.