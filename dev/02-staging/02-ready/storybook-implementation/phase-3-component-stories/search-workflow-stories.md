# Phase 3: Search & Organization Workflow Stories
**Modules:** Search, Organization, Upload  
**Components:** 8 workflow and organization components  
**Estimated Time:** 2 hours  
**Priority:** Medium-High (core user workflows)

## Overview

Search and organization components enable users to efficiently find, organize, and manage their industrial safety photos. These components form the backbone of user workflows, from basic search to complex project organization and export processes.

## Component Priority Matrix

### Tier 1: Core Search Components (45 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| IntelligentSearch | `search/intelligent-search.tsx` | High | High | 25 min |
| SearchFilters | `search/search-filters.tsx` | Medium | High | 20 min |

### Tier 2: Organization Components (45 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| ProjectManager | `organization/project-manager.tsx` | High | High | 20 min |
| ExportWizard | `organization/export-wizard.tsx` | High | High | 25 min |

### Tier 3: Upload & Management (30 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| FileDropZone | `upload/file-drop-zone.tsx` | Medium | High | 15 min |
| UploadProgress | `upload/upload-progress.tsx` | Medium | Medium | 15 min |

## Detailed Implementation Guide

### Tier 1: Core Search Components

#### 1. IntelligentSearch Component (`search/intelligent-search.tsx`)

**Story File:** `components/search/intelligent-search.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { IntelligentSearch } from './intelligent-search';
import { mockSearchData, mockPhotoData } from '../../../.storybook/mocks';
import { action } from '@storybook/addon-actions';

const meta: Meta<typeof IntelligentSearch> = {
  title: 'Features/Search/IntelligentSearch',
  component: IntelligentSearch,
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        component: `
**IntelligentSearch** - AI-powered search interface for industrial safety photos

Advanced search component that combines text search, AI-powered semantic search,
visual similarity, and intelligent suggestions to help users find photos quickly.

**Key Features:**
- **Natural Language Search**: "Photos of conveyor belts with safety guards"
- **AI-Powered Suggestions**: Real-time search suggestions based on content
- **Visual Similarity**: Find photos similar to a selected reference photo
- **Semantic Understanding**: Searches understand safety concepts and relationships
- **Multi-Modal Search**: Combine text, tags, metadata, and visual similarity
- **Search History**: Remember and suggest previous successful searches

**Search Types:**
- **Text Search**: Traditional keyword matching in filenames and tags
- **Semantic Search**: AI understanding of safety concepts and relationships
- **Visual Search**: Find visually similar photos using computer vision
- **Metadata Search**: Search by date, location, project, user, camera, etc.
- **Combination Search**: Multiple criteria combined with intelligent ranking

**AI Features:**
- Auto-complete with safety-specific vocabulary
- Search intent recognition (find, compare, analyze, inspect)
- Contextual suggestions based on current project and user role
- Learning from search patterns to improve suggestions
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="max-w-4xl">
        <Story />
      </div>
    ),
  ],
  argTypes: {
    placeholder: {
      control: 'text',
      description: 'Search input placeholder text',
    },
    mode: {
      control: { type: 'select' },
      options: ['simple', 'advanced', 'visual'],
      description: 'Search interface mode',
    },
    enableAI: {
      control: 'boolean',
      description: 'Enable AI-powered search features',
    },
    showSuggestions: {
      control: 'boolean',
      description: 'Show search suggestions dropdown',
    },
    onSearch: { action: 'search-executed' },
    onSuggestionSelect: { action: 'suggestion-selected' },
    onModeChange: { action: 'mode-changed' },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const SimpleTextSearch: Story = {
  args: {
    placeholder: 'Search photos by tags, location, or content...',
    mode: 'simple',
    enableAI: true,
    showSuggestions: true,
    initialValue: '',
    onSearch: action('search-executed'),
    onSuggestionSelect: action('suggestion-selected'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Simple text search interface with AI-powered suggestions and auto-complete.',
      },
    },
  },
};

export const WithActiveSearch: Story = {
  args: {
    placeholder: 'Search photos...',
    mode: 'simple',
    enableAI: true,
    showSuggestions: true,
    initialValue: 'conveyor belt safety',
    isSearching: false,
    results: mockSearchData.conveyorBeltResults,
    suggestions: [
      { text: 'conveyor belt safety guards', type: 'semantic', count: 23 },
      { text: 'conveyor belt maintenance', type: 'semantic', count: 18 },
      { text: 'conveyor belt emergency stops', type: 'semantic', count: 12 },
      { text: 'belt safety inspection', type: 'semantic', count: 31 },
    ],
    onSearch: action('search-executed'),
    onSuggestionSelect: action('suggestion-selected'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Active search with results and AI-generated semantic suggestions.',
      },
    },
  },
};

export const AdvancedSearchMode: Story = {
  args: {
    mode: 'advanced',
    enableAI: true,
    showFilters: true,
    filters: {
      dateRange: { start: '2025-08-01', end: '2025-08-15' },
      tags: ['machinery', 'safety-guard'],
      projects: ['Q3 Safety Inspection'],
      sites: ['Main Production Facility'],
      users: ['John Smith'],
      aiConfidenceMin: 0.7,
    },
    onSearch: action('search-executed'),
    onFilterChange: action('filter-changed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Advanced search mode with comprehensive filters and criteria selection.',
      },
    },
  },
};

export const VisualSimilaritySearch: Story = {
  args: {
    mode: 'visual',
    referencePhoto: mockPhotoData.manufacturingInspection[0],
    visualResults: mockSearchData.visualSimilarityResults,
    similarityThreshold: 0.8,
    onSearch: action('visual-search-executed'),
    onSimilarityThresholdChange: action('similarity-threshold-changed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Visual similarity search using a reference photo to find similar images.',
      },
    },
  },
};

export const SearchInProgress: Story = {
  args: {
    mode: 'simple',
    initialValue: 'emergency stop buttons',
    isSearching: true,
    searchProgress: 0.67,
    searchStage: 'Analyzing photo content...',
    onSearch: action('search-executed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Search in progress with AI analysis and progress indication.',
      },
    },
  },
};

export const NoResults: Story = {
  args: {
    mode: 'simple',
    initialValue: 'xyz nonexistent term',
    isSearching: false,
    results: [],
    suggestions: [
      { text: 'safety equipment', type: 'alternative', count: 156 },
      { text: 'emergency systems', type: 'alternative', count: 89 },
      { text: 'inspection tools', type: 'alternative', count: 67 },
    ],
    onSearch: action('search-executed'),
    onSuggestionSelect: action('suggestion-selected'),
  },
  parameters: {
    docs: {
      description: {
        story: 'No results state with alternative search suggestions to help users find content.',
      },
    },
  },
};

export const SavedSearches: Story = {
  args: {
    mode: 'simple',
    showSavedSearches: true,
    savedSearches: [
      {
        id: 'saved-1',
        name: 'Conveyor Safety Inspections',
        query: 'conveyor belt safety guards',
        filters: { tags: ['machinery', 'safety-guard'] },
        lastUsed: '2025-08-14T15:30:00Z',
        resultCount: 23,
      },
      {
        id: 'saved-2',
        name: 'PPE Compliance Photos',
        query: 'hard hat safety shoes',
        filters: { tags: ['ppe'], aiConfidenceMin: 0.8 },
        lastUsed: '2025-08-13T09:15:00Z',
        resultCount: 156,
      },
      {
        id: 'saved-3',
        name: 'Emergency Equipment Check',
        query: 'emergency stop fire extinguisher',
        filters: { tags: ['emergency', 'safety-equipment'] },
        lastUsed: '2025-08-12T11:45:00Z',
        resultCount: 45,
      },
    ],
    onSavedSearchSelect: action('saved-search-selected'),
    onSavedSearchDelete: action('saved-search-deleted'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Saved searches interface allowing users to quickly rerun common search queries.',
      },
    },
  },
};

export const InteractiveSearchDemo: Story = {
  render: () => {
    const [mode, setMode] = React.useState<'simple' | 'advanced' | 'visual'>('simple');
    const [searchValue, setSearchValue] = React.useState('');
    const [isSearching, setIsSearching] = React.useState(false);
    const [results, setResults] = React.useState([]);
    const [suggestions, setSuggestions] = React.useState([]);
    
    const handleSearch = (query: string) => {
      setIsSearching(true);
      action('search-executed')(query);
      
      // Simulate search delay
      setTimeout(() => {
        setIsSearching(false);
        if (query.toLowerCase().includes('conveyor')) {
          setResults(mockSearchData.conveyorBeltResults);
        } else if (query.toLowerCase().includes('safety')) {
          setResults(mockSearchData.safetyEquipmentResults);
        } else {
          setResults([]);
        }
      }, 1500);
    };
    
    const handleInputChange = (value: string) => {
      setSearchValue(value);
      
      // Generate suggestions based on input
      if (value.length > 2) {
        const newSuggestions = mockSearchData.allSuggestions
          .filter(s => s.text.toLowerCase().includes(value.toLowerCase()))
          .slice(0, 5);
        setSuggestions(newSuggestions);
      } else {
        setSuggestions([]);
      }
    };
    
    return (
      <div className="space-y-4">
        <div className="p-4 bg-muted rounded-lg">
          <h3 className="font-semibold mb-2">Interactive Search Demo</h3>
          <p className="text-sm text-muted-foreground">
            Try searching for "conveyor", "safety", or other terms to see the intelligent search in action.
          </p>
        </div>
        
        <IntelligentSearch
          mode={mode}
          placeholder="Try searching for 'conveyor belt' or 'safety equipment'..."
          enableAI={true}
          showSuggestions={true}
          initialValue={searchValue}
          isSearching={isSearching}
          results={results}
          suggestions={suggestions}
          onSearch={handleSearch}
          onInputChange={handleInputChange}
          onModeChange={setMode}
          onSuggestionSelect={(suggestion) => {
            setSearchValue(suggestion.text);
            handleSearch(suggestion.text);
          }}
        />
      </div>
    );
  },
  parameters: {
    docs: {
      description: {
        story: 'Interactive search demo with real-time suggestions and result handling.',
      },
    },
  },
};
```

#### 2. SearchFilters Component (`search/search-filters.tsx`)

**Story File:** `components/search/search-filters.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { SearchFilters } from './search-filters';
import { mockFilterData } from '../../../.storybook/mocks';
import { action } from '@storybook/addon-actions';

const meta: Meta<typeof SearchFilters> = {
  title: 'Features/Search/SearchFilters',
  component: SearchFilters,
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        component: `
**SearchFilters** - Advanced filtering interface for photo search

Comprehensive filtering system allowing users to narrow down photo searches
using multiple criteria including metadata, AI analysis, and custom parameters.

**Filter Categories:**
- **Date Range**: Upload date, capture date, modification date
- **Location**: Site, building, area, GPS coordinates
- **Project**: Project assignment, status, team members
- **Content**: AI tags, manual tags, confidence scores
- **Technical**: Camera type, resolution, file size, format
- **User**: Uploaded by, tagged by, commented by

**Advanced Features:**
- **Smart Suggestions**: AI-powered filter suggestions based on content
- **Saved Filter Sets**: Store common filter combinations
- **Quick Filters**: One-click filters for common scenarios
- **Filter Analytics**: Show result counts before applying
- **Batch Operations**: Apply filters to enable bulk actions
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="max-w-2xl">
        <Story />
      </div>
    ),
  ],
  argTypes: {
    filters: {
      control: false,
      description: 'Current filter values',
    },
    availableOptions: {
      control: false,
      description: 'Available filter options from data',
    },
    showResultCount: {
      control: 'boolean',
      description: 'Show result count for each filter',
    },
    enableSmartSuggestions: {
      control: 'boolean',
      description: 'Enable AI-powered filter suggestions',
    },
    onFilterChange: { action: 'filter-changed' },
    onFilterReset: { action: 'filters-reset' },
    onFilterSave: { action: 'filter-saved' },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const BasicFilters: Story = {
  args: {
    filters: {
      dateRange: null,
      tags: [],
      projects: [],
      sites: [],
      users: [],
    },
    availableOptions: mockFilterData.basicOptions,
    showResultCount: true,
    enableSmartSuggestions: false,
    onFilterChange: action('filter-changed'),
    onFilterReset: action('filters-reset'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Basic filter interface with common filtering options and result counts.',
      },
    },
  },
};

export const ActiveFilters: Story = {
  args: {
    filters: {
      dateRange: { 
        start: '2025-08-01', 
        end: '2025-08-15' 
      },
      tags: ['conveyor-belt', 'safety-guard'],
      projects: ['Q3 Safety Inspection'],
      sites: ['Main Production Facility'],
      users: [],
      aiConfidenceMin: 0.7,
      fileTypes: ['jpg', 'png'],
    },
    availableOptions: mockFilterData.comprehensiveOptions,
    showResultCount: true,
    resultCount: 47,
    onFilterChange: action('filter-changed'),
    onFilterReset: action('filters-reset'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Active filters showing applied criteria and current result count.',
      },
    },
  },
};

export const AdvancedFilters: Story = {
  args: {
    mode: 'advanced',
    filters: {
      dateRange: { start: '2025-08-01', end: '2025-08-15' },
      tags: ['machinery'],
      projects: [],
      sites: [],
      users: [],
      aiConfidenceMin: 0.8,
      fileSize: { min: 1, max: 10 }, // MB
      resolution: { min: '1920x1080' },
      hasGPS: true,
      hasComments: false,
      analysisStatus: 'completed',
    },
    availableOptions: mockFilterData.advancedOptions,
    showResultCount: true,
    enableSmartSuggestions: true,
    smartSuggestions: [
      { filter: 'tags', value: 'emergency-stop', reason: 'Often found with machinery', count: 23 },
      { filter: 'sites', value: 'Building B', reason: 'Similar machinery location', count: 18 },
    ],
    onFilterChange: action('filter-changed'),
    onSmartSuggestionApply: action('smart-suggestion-applied'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Advanced filters with technical criteria and AI-powered smart suggestions.',
      },
    },
  },
};

export const SavedFilterSets: Story = {
  args: {
    filters: {},
    availableOptions: mockFilterData.basicOptions,
    showSavedFilters: true,
    savedFilterSets: [
      {
        id: 'filter-set-1',
        name: 'Conveyor Safety Inspection',
        filters: {
          tags: ['conveyor-belt', 'safety-guard'],
          aiConfidenceMin: 0.8,
          dateRange: { start: '2025-08-01', end: '2025-08-15' },
        },
        lastUsed: '2025-08-14T15:30:00Z',
        resultCount: 23,
      },
      {
        id: 'filter-set-2',
        name: 'PPE Compliance Check',
        filters: {
          tags: ['hard-hat', 'safety-shoes', 'gloves'],
          aiConfidenceMin: 0.7,
          projects: ['Q3 Safety Inspection'],
        },
        lastUsed: '2025-08-13T09:15:00Z',
        resultCount: 156,
      },
      {
        id: 'filter-set-3',
        name: 'High-Res Equipment Photos',
        filters: {
          tags: ['machinery', 'equipment'],
          resolution: { min: '1920x1080' },
          fileSize: { min: 2 },
        },
        lastUsed: '2025-08-12T11:45:00Z',
        resultCount: 89,
      },
    ],
    onFilterSetSelect: action('filter-set-selected'),
    onFilterSetDelete: action('filter-set-deleted'),
    onFilterSave: action('filter-saved'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Saved filter sets allowing users to quickly apply common filter combinations.',
      },
    },
  },
};

export const QuickFilters: Story = {
  args: {
    filters: {},
    availableOptions: mockFilterData.basicOptions,
    showQuickFilters: true,
    quickFilters: [
      { name: 'Today\'s Photos', filters: { dateRange: { start: '2025-08-15', end: '2025-08-15' } }, count: 23 },
      { name: 'High Confidence AI', filters: { aiConfidenceMin: 0.9 }, count: 89 },
      { name: 'Needs Review', filters: { analysisStatus: 'manual_review' }, count: 12 },
      { name: 'PPE Photos', filters: { tags: ['hard-hat', 'safety-shoes'] }, count: 156 },
      { name: 'Machinery', filters: { tags: ['machinery', 'equipment'] }, count: 234 },
      { name: 'Emergency Equipment', filters: { tags: ['emergency-stop', 'fire-extinguisher'] }, count: 45 },
    ],
    onQuickFilterApply: action('quick-filter-applied'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Quick filter buttons for common filtering scenarios and workflows.',
      },
    },
  },
};
```

### Mock Data for Search Components

**File:** `.storybook/mocks/search-data.ts`

```typescript
export const mockSearchData = {
  conveyorBeltResults: [
    {
      id: 'photo-001',
      url: 'https://picsum.photos/400/300?random=1',
      thumbnail: 'https://picsum.photos/200/150?random=1',
      filename: 'conveyor_safety_check_001.jpg',
      tags: ['conveyor-belt', 'safety-guard', 'machinery'],
      aiConfidence: 0.94,
      project: 'Q3 Safety Inspection',
      site: 'Main Production',
      uploadedAt: '2025-08-15T10:30:00Z',
      matchScore: 0.96,
      matchReasons: ['High tag relevance', 'Visual similarity', 'Context match'],
    },
    // ... more results
  ],
  
  safetyEquipmentResults: [
    // Different result set for safety equipment searches
  ],
  
  visualSimilarityResults: [
    // Results for visual similarity searches
  ],
  
  allSuggestions: [
    { text: 'conveyor belt safety guards', type: 'semantic', count: 23 },
    { text: 'conveyor belt maintenance', type: 'semantic', count: 18 },
    { text: 'safety equipment inspection', type: 'semantic', count: 156 },
    { text: 'emergency stop buttons', type: 'semantic', count: 45 },
    { text: 'hard hat compliance', type: 'semantic', count: 89 },
    // ... more suggestions
  ],
};

export const mockFilterData = {
  basicOptions: {
    tags: [
      { value: 'conveyor-belt', label: 'Conveyor Belt', count: 234 },
      { value: 'safety-guard', label: 'Safety Guard', count: 156 },
      { value: 'hard-hat', label: 'Hard Hat', count: 189 },
      { value: 'emergency-stop', label: 'Emergency Stop', count: 67 },
      // ... more tag options
    ],
    projects: [
      { value: 'q3-safety-inspection', label: 'Q3 Safety Inspection', count: 345 },
      { value: 'annual-compliance', label: 'Annual Compliance Review', count: 567 },
      { value: 'equipment-maintenance', label: 'Equipment Maintenance', count: 123 },
      // ... more project options
    ],
    sites: [
      { value: 'main-production', label: 'Main Production Facility', count: 456 },
      { value: 'building-a', label: 'Building A', count: 234 },
      { value: 'warehouse-1', label: 'Warehouse 1', count: 123 },
      // ... more site options
    ],
    users: [
      { value: 'john-smith', label: 'John Smith', count: 234 },
      { value: 'maria-garcia', label: 'Maria Garcia', count: 156 },
      { value: 'david-chen', label: 'David Chen', count: 189 },
      // ... more user options
    ],
  },
  
  comprehensiveOptions: {
    // Extended options with more detailed data
  },
  
  advancedOptions: {
    // Technical filter options for advanced mode
  },
};
```

## Quality Checklist

### Search Component Stories Quality
- [ ] **Realistic Search Results**: Mock data reflects actual search scenarios
- [ ] **Complete Workflow States**: Searching, results, no results, error states
- [ ] **AI Integration**: Semantic search, suggestions, and smart filtering
- [ ] **Performance**: Large result sets and complex filtering handle smoothly
- [ ] **User Experience**: Intuitive interface with helpful feedback
- [ ] **Accessibility**: Keyboard navigation and screen reader support

### Search Functionality Validation
- [ ] **Text Search**: Keyword matching and relevance ranking
- [ ] **AI-Powered Search**: Semantic understanding and suggestions
- [ ] **Visual Search**: Image similarity and visual matching
- [ ] **Filter Combinations**: Multiple criteria applied correctly
- [ ] **Saved Searches**: Persistence and quick reuse workflows
- [ ] **Result Accuracy**: Realistic match scores and relevance

### Integration Testing
- [ ] **Search Store**: State management and search persistence
- [ ] **API Simulation**: Realistic search timing and responses
- [ ] **Filter Integration**: Combined search and filtering workflows
- [ ] **Export Integration**: Search results to export workflows

---

**Next Phase**: After completing Phase 3 component stories, proceed to Phase 4 for Playwright integration and automated component testing.