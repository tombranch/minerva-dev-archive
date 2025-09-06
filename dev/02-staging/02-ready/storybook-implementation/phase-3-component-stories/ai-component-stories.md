# Phase 3: AI Component Stories
**Module:** AI Management & Processing  
**Components:** 7 core AI functionality components  
**Estimated Time:** 2.5 hours  
**Priority:** High (core business differentiator)

## Overview

AI components represent Minerva's core differentiating technology, providing automated safety analysis, intelligent tagging, and processing pipeline management. These components handle complex machine learning workflows while presenting intuitive interfaces for industrial users.

## Component Priority Matrix

### Tier 1: Core AI Components (1.5 hours)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| AITagSuggestions | `ai-tag-suggestions.tsx` | High | Critical | 25 min |
| UnifiedAIManagement | `UnifiedAIManagement.tsx` | High | Critical | 30 min |
| PhotoTaggingManagement | `features/PhotoTaggingManagement.tsx` | High | Critical | 25 min |
| ProcessingIndicator | `processing-indicator.tsx` | Medium | High | 10 min |

### Tier 2: Analytics & Monitoring (45 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| AIAnalyticsDashboard | `ai-analytics-dashboard.tsx` | High | High | 30 min |
| RealTimeMonitor | `monitoring/RealTimeMonitor.tsx` | Medium | Medium | 15 min |

### Tier 3: Pipeline Management (30 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|-----------|
| SmartProcessingPipeline | `features/SmartProcessingPipeline.tsx` | High | Medium | 30 min |

## Detailed Implementation Guide

### Tier 1: Core AI Components

#### 1. AITagSuggestions Component (`ai-tag-suggestions.tsx`)

**Story File:** `components/ai/ai-tag-suggestions.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { AITagSuggestions } from './ai-tag-suggestions';
import { mockAITaggingData, mockPhotoData } from '../../../.storybook/mocks';
import { action } from '@storybook/addon-actions';

const meta: Meta<typeof AITagSuggestions> = {
  title: 'Features/AI/TagSuggestions',
  component: AITagSuggestions,
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        component: `
**AITagSuggestions** - Intelligent tag suggestion system

Core AI component that analyzes industrial safety photos and suggests relevant tags
based on computer vision analysis and machine learning models trained on safety data.

**Key Features:**
- **Real-time Analysis**: Process photos as they're uploaded or selected
- **Confidence Scoring**: Each suggestion includes confidence percentage
- **Category Classification**: Tags organized by safety categories (PPE, machinery, hazards)
- **Bounding Boxes**: Visual indicators showing detected objects in photos
- **User Feedback Loop**: Learn from approvals/rejections to improve accuracy
- **Batch Processing**: Handle multiple photos simultaneously

**Safety Categories:**
- **PPE (Personal Protective Equipment)**: Hard hats, safety shoes, gloves, glasses
- **Machinery**: Conveyors, presses, tools, equipment types
- **Hazards**: Sharp edges, pinch points, hot surfaces, electrical
- **Controls**: Emergency stops, guards, barriers, signage
- **Environment**: Lighting, cleanliness, organization, maintenance

**Integration Points:**
- Google Cloud Vision API for object detection
- Custom ML models trained on industrial safety data
- Photo management system for tag application
- Analytics system for accuracy tracking
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
    photoId: {
      control: 'text',
      description: 'ID of photo being analyzed',
    },
    photoUrl: {
      control: 'text', 
      description: 'URL of photo for display',
    },
    suggestions: {
      control: false,
      description: 'Array of AI-generated tag suggestions',
    },
    isAnalyzing: {
      control: 'boolean',
      description: 'Whether AI analysis is in progress',
    },
    progress: {
      control: { type: 'range', min: 0, max: 100, step: 5 },
      description: 'Analysis progress percentage',
    },
    onTagApprove: { action: 'tag-approved' },
    onTagReject: { action: 'tag-rejected' },
    onRetryAnalysis: { action: 'retry-analysis' },
    onBatchApply: { action: 'batch-apply' },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const HighConfidenceResults: Story = {
  args: {
    photoId: 'photo-001',
    photoUrl: 'https://picsum.photos/800/600?random=1',
    suggestions: [
      {
        tag: 'conveyor-belt',
        confidence: 0.94,
        category: 'machinery',
        boundingBox: { x: 120, y: 80, width: 340, height: 180 },
        description: 'Industrial conveyor belt system',
        approved: null,
      },
      {
        tag: 'safety-guard',
        confidence: 0.87,
        category: 'safety-equipment',
        boundingBox: { x: 200, y: 150, width: 120, height: 90 },
        description: 'Protective safety guard or barrier',
        approved: null,
      },
      {
        tag: 'emergency-stop',
        confidence: 0.91,
        category: 'controls',
        boundingBox: { x: 450, y: 60, width: 40, height: 40 },
        description: 'Emergency stop button',
        approved: null,
      },
    ],
    isAnalyzing: false,
    onTagApprove: action('tag-approved'),
    onTagReject: action('tag-rejected'),
    onBatchApply: action('batch-apply'),
  },
  parameters: {
    docs: {
      description: {
        story: 'High-confidence AI tag suggestions with clear object detection and safety categorization.',
      },
    },
  },
};

export const MixedConfidenceResults: Story = {
  args: {
    photoId: 'photo-002',
    photoUrl: 'https://picsum.photos/800/600?random=2',
    suggestions: [
      {
        tag: 'hard-hat',
        confidence: 0.78,
        category: 'ppe',
        boundingBox: { x: 300, y: 20, width: 60, height: 50 },
        description: 'Personal protective equipment - hard hat',
        approved: null,
      },
      {
        tag: 'safety-shoes',
        confidence: 0.45,
        category: 'ppe',
        boundingBox: { x: 250, y: 400, width: 80, height: 40 },
        description: 'Safety footwear',
        approved: null,
        flagged: true,
        flagReason: 'Low confidence - manual review recommended',
      },
      {
        tag: 'warning-sign',
        confidence: 0.62,
        category: 'signage',
        boundingBox: { x: 500, y: 200, width: 100, height: 80 },
        description: 'Safety warning signage',
        approved: null,
      },
      {
        tag: 'electrical-panel',
        confidence: 0.83,
        category: 'equipment',
        boundingBox: { x: 50, y: 100, width: 80, height: 120 },
        description: 'Electrical control panel',
        approved: null,
      },
    ],
    isAnalyzing: false,
    onTagApprove: action('tag-approved'),
    onTagReject: action('tag-rejected'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Mixed confidence results requiring user review. Low-confidence tags are flagged for attention.',
      },
    },
  },
};

export const AnalysisInProgress: Story = {
  args: {
    photoId: 'photo-003',
    photoUrl: 'https://picsum.photos/800/600?random=3',
    suggestions: [],
    isAnalyzing: true,
    progress: 67,
    analysisStage: 'Detecting objects...',
    estimatedTimeRemaining: 8,
  },
  parameters: {
    docs: {
      description: {
        story: 'AI analysis in progress with real-time progress updates and stage information.',
      },
    },
  },
};

export const AnalysisError: Story = {
  args: {
    photoId: 'photo-error',
    photoUrl: 'https://picsum.photos/800/600?random=4',
    suggestions: [],
    isAnalyzing: false,
    error: {
      type: 'analysis_failed',
      message: 'Image quality too low for reliable analysis',
      details: 'Photo appears blurry or poorly lit. Try uploading a clearer image.',
      retryable: true,
    },
    onRetryAnalysis: action('retry-analysis'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Error state when AI analysis fails with actionable error message and retry option.',
      },
    },
  },
};

export const BatchAnalysisMode: Story = {
  args: {
    mode: 'batch',
    photoIds: ['photo-1', 'photo-2', 'photo-3', 'photo-4'],
    batchSuggestions: [
      {
        photoId: 'photo-1',
        suggestions: mockAITaggingData.highConfidenceTags.slice(0, 2),
        status: 'completed',
      },
      {
        photoId: 'photo-2',
        suggestions: mockAITaggingData.mixedConfidenceTags.slice(0, 3),
        status: 'completed',
      },
      {
        photoId: 'photo-3',
        suggestions: [],
        status: 'analyzing',
        progress: 45,
      },
      {
        photoId: 'photo-4',
        suggestions: [],
        status: 'queued',
      },
    ],
    onBatchApply: action('batch-apply-all'),
    onBatchReview: action('batch-review'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Batch analysis mode for processing multiple photos simultaneously with progress tracking.',
      },
    },
  },
};

export const WithUserFeedback: Story = {
  args: {
    photoId: 'photo-feedback',
    photoUrl: 'https://picsum.photos/800/600?random=5',
    suggestions: [
      {
        tag: 'conveyor-belt',
        confidence: 0.89,
        category: 'machinery',
        approved: true,
        approvedBy: 'John Smith',
        approvedAt: '2025-08-15T10:30:00Z',
      },
      {
        tag: 'safety-guard',
        confidence: 0.72,
        category: 'safety-equipment',
        approved: false,
        rejectedBy: 'John Smith',
        rejectedAt: '2025-08-15T10:31:00Z',
        rejectionReason: 'Guard is partially obstructed, not clearly visible',
      },
      {
        tag: 'warning-sign',
        confidence: 0.65,
        category: 'signage',
        approved: null,
      },
    ],
    showFeedbackHistory: true,
    onTagApprove: action('tag-approved'),
    onTagReject: action('tag-rejected'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Tag suggestions with user feedback history showing approved/rejected tags and reasons.',
      },
    },
  },
};

export const CustomCategoryFiltering: Story = {
  args: {
    photoId: 'photo-filter',
    photoUrl: 'https://picsum.photos/800/600?random=6',
    suggestions: mockAITaggingData.comprehensiveTags,
    categoryFilter: ['ppe', 'controls'],
    showConfidenceThreshold: true,
    confidenceThreshold: 0.7,
    onTagApprove: action('tag-approved'),
    onCategoryFilterChange: action('category-filter-changed'),
    onConfidenceThresholdChange: action('confidence-threshold-changed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Advanced filtering options for tag categories and confidence thresholds.',
      },
    },
  },
};

export const InteractiveWorkflow: Story = {
  render: () => {
    const [suggestions, setSuggestions] = React.useState(mockAITaggingData.mixedConfidenceTags);
    const [isAnalyzing, setIsAnalyzing] = React.useState(false);
    const [progress, setProgress] = React.useState(0);
    
    const handleRetryAnalysis = () => {
      setIsAnalyzing(true);
      setProgress(0);
      
      // Simulate analysis progress
      const interval = setInterval(() => {
        setProgress(prev => {
          if (prev >= 100) {
            clearInterval(interval);
            setIsAnalyzing(false);
            setSuggestions(mockAITaggingData.highConfidenceTags);
            return 100;
          }
          return prev + 10;
        });
      }, 300);
    };
    
    const handleTagApprove = (tagIndex: number) => {
      setSuggestions(prev => prev.map((suggestion, index) =>
        index === tagIndex ? { ...suggestion, approved: true } : suggestion
      ));
      action('tag-approved')(tagIndex);
    };
    
    const handleTagReject = (tagIndex: number, reason?: string) => {
      setSuggestions(prev => prev.map((suggestion, index) =>
        index === tagIndex ? { ...suggestion, approved: false, rejectionReason: reason } : suggestion
      ));
      action('tag-rejected')(tagIndex, reason);
    };
    
    return (
      <div className="space-y-4">
        <div className="p-4 bg-muted rounded-lg">
          <h3 className="font-semibold mb-2">Interactive AI Tagging Demo</h3>
          <p className="text-sm text-muted-foreground">
            Try approving/rejecting tags or clicking "Retry Analysis" to see the workflow in action.
          </p>
        </div>
        
        <AITagSuggestions
          photoId="interactive-demo"
          photoUrl="https://picsum.photos/800/600?random=7"
          suggestions={suggestions}
          isAnalyzing={isAnalyzing}
          progress={progress}
          onTagApprove={handleTagApprove}
          onTagReject={handleTagReject}
          onRetryAnalysis={handleRetryAnalysis}
        />
      </div>
    );
  },
  parameters: {
    docs: {
      description: {
        story: 'Interactive demo showing the complete AI tagging workflow with real-time updates.',
      },
    },
  },
};
```

#### 2. UnifiedAIManagement Component (`UnifiedAIManagement.tsx`)

**Story File:** `components/ai/UnifiedAIManagement.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { UnifiedAIManagement } from './UnifiedAIManagement';
import { mockAISystemData } from '../../../.storybook/mocks/ai-system-data';
import { action } from '@storybook/addon-actions';

const meta: Meta<typeof UnifiedAIManagement> = {
  title: 'Features/AI/UnifiedManagement',
  component: UnifiedAIManagement,
  parameters: {
    layout: 'fullscreen',
    docs: {
      description: {
        component: `
**UnifiedAIManagement** - Comprehensive AI system control center

Central management interface for all AI operations in Minerva, providing real-time monitoring,
configuration management, and performance analytics in a unified dashboard.

**Key Features:**
- **System Overview**: Real-time status of all AI services and pipelines
- **Model Management**: Configure and switch between different AI models
- **Performance Monitoring**: Track accuracy, speed, and resource usage
- **Queue Management**: Monitor and control photo processing queues
- **Cost Tracking**: Monitor API usage and costs across providers
- **Configuration**: Manage API keys, thresholds, and processing rules

**Management Sections:**
- **Live Status**: Current system health and active processing
- **Analytics**: Performance metrics and accuracy trends
- **Settings**: Model configuration and processing parameters
- **Queue Control**: Batch processing and priority management
- **Cost Monitor**: Usage tracking and budget management
- **Troubleshooting**: Error logs and diagnostic tools

**Provider Integration:**
- Google Cloud Vision API
- OpenAI GPT models for description generation
- Custom ML models for safety-specific detection
- Monitoring and alerting systems
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    activeTab: {
      control: { type: 'select' },
      options: ['overview', 'analytics', 'settings', 'queue', 'costs'],
      description: 'Active management tab',
    },
    systemStatus: {
      control: { type: 'select' },
      options: ['healthy', 'warning', 'error', 'maintenance'],
      description: 'Overall system health status',
    },
    onTabChange: { action: 'tab-changed' },
    onSystemAction: { action: 'system-action' },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const SystemOverview: Story = {
  args: {
    activeTab: 'overview',
    systemStatus: 'healthy',
    systemData: {
      status: 'healthy',
      uptime: '99.8%',
      activeProcessing: 12,
      queueSize: 45,
      dailyAnalyzed: 1247,
      errorRate: 0.02,
      averageProcessingTime: '2.3s',
      providers: [
        {
          name: 'Google Vision',
          status: 'active',
          responseTime: '1.2s',
          usage: '68%',
          dailyRequests: 856,
        },
        {
          name: 'OpenAI GPT-4',
          status: 'active', 
          responseTime: '3.1s',
          usage: '23%',
          dailyRequests: 192,
        },
        {
          name: 'Custom Safety Model',
          status: 'active',
          responseTime: '0.8s',
          usage: '45%',
          dailyRequests: 654,
        },
      ],
    },
    onTabChange: action('tab-changed'),
    onSystemAction: action('system-action'),
  },
  parameters: {
    docs: {
      description: {
        story: 'System overview showing healthy AI operations with all providers active and performing well.',
      },
    },
  },
};

export const SystemWithWarnings: Story = {
  args: {
    activeTab: 'overview',
    systemStatus: 'warning',
    systemData: {
      status: 'warning',
      uptime: '97.2%',
      activeProcessing: 3,
      queueSize: 178,
      dailyAnalyzed: 892,
      errorRate: 0.08,
      averageProcessingTime: '4.7s',
      alerts: [
        {
          type: 'warning',
          message: 'Queue size above normal threshold',
          timestamp: '2025-08-15T14:30:00Z',
          action: 'Consider scaling up processing capacity',
        },
        {
          type: 'warning',
          message: 'Google Vision API response time elevated',
          timestamp: '2025-08-15T14:15:00Z',
          action: 'Monitor provider status',
        },
      ],
      providers: [
        {
          name: 'Google Vision',
          status: 'slow',
          responseTime: '4.8s',
          usage: '89%',
          dailyRequests: 1024,
        },
        {
          name: 'OpenAI GPT-4',
          status: 'active',
          responseTime: '3.2s',
          usage: '34%',
          dailyRequests: 178,
        },
        {
          name: 'Custom Safety Model',
          status: 'active',
          responseTime: '0.9s',
          usage: '67%',
          dailyRequests: 543,
        },
      ],
    },
    onTabChange: action('tab-changed'),
    onSystemAction: action('system-action'),
  },
  parameters: {
    docs: {
      description: {
        story: 'System with warning state showing performance issues and queue buildup requiring attention.',
      },
    },
  },
};

export const AnalyticsView: Story = {
  args: {
    activeTab: 'analytics',
    systemStatus: 'healthy',
    analyticsData: {
      accuracy: {
        overall: 0.87,
        byCategory: {
          ppe: 0.92,
          machinery: 0.89,
          hazards: 0.84,
          controls: 0.91,
          signage: 0.79,
        },
        trend: 'improving',
        weeklyChange: 0.03,
      },
      performance: {
        averageProcessingTime: '2.3s',
        throughput: '450 photos/hour',
        uptime: '99.8%',
        errorRate: 0.02,
      },
      usage: {
        dailyVolume: 1247,
        monthlyVolume: 28450,
        peakHours: ['09:00', '14:00', '16:00'],
        topCategories: ['machinery', 'ppe', 'controls'],
      },
      costs: {
        daily: 23.45,
        monthly: 687.20,
        projection: 721.00,
        breakdown: {
          'Google Vision': 14.20,
          'OpenAI GPT-4': 6.78,
          'Computing': 2.47,
        },
      },
    },
    onTabChange: action('tab-changed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Analytics dashboard showing AI performance metrics, accuracy trends, and usage statistics.',
      },
    },
  },
};

export const QueueManagement: Story = {
  args: {
    activeTab: 'queue',
    systemStatus: 'healthy',
    queueData: {
      current: {
        size: 45,
        processing: 12,
        estimatedTime: '8 minutes',
        priority: {
          high: 5,
          normal: 32,
          low: 8,
        },
      },
      history: [
        {
          id: 'batch-001',
          photos: 25,
          status: 'completed',
          startTime: '2025-08-15T14:00:00Z',
          endTime: '2025-08-15T14:03:00Z',
          accuracy: 0.89,
        },
        {
          id: 'batch-002',
          photos: 18,
          status: 'processing',
          startTime: '2025-08-15T14:05:00Z',
          progress: 0.67,
        },
        {
          id: 'batch-003',
          photos: 45,
          status: 'queued',
          priority: 'normal',
          estimatedStart: '2025-08-15T14:15:00Z',
        },
      ],
    },
    onQueueAction: action('queue-action'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Queue management interface showing current processing status and batch history.',
      },
    },
  },
};
```

### Mock Data for AI Components

**File:** `.storybook/mocks/ai-system-data.ts`

```typescript
export const mockAISystemData = {
  healthySystem: {
    status: 'healthy',
    uptime: '99.8%',
    activeProcessing: 12,
    queueSize: 45,
    dailyAnalyzed: 1247,
    errorRate: 0.02,
    averageProcessingTime: '2.3s',
  },
  
  providers: [
    {
      name: 'Google Vision',
      status: 'active',
      responseTime: '1.2s',
      usage: '68%',
      dailyRequests: 856,
      monthlyQuota: 100000,
      accuracy: 0.89,
    },
    {
      name: 'OpenAI GPT-4',
      status: 'active',
      responseTime: '3.1s', 
      usage: '23%',
      dailyRequests: 192,
      monthlyQuota: 10000,
      accuracy: 0.92,
    },
  ],
  
  analyticsData: {
    accuracyTrends: Array.from({ length: 30 }, (_, i) => ({
      date: new Date(Date.now() - (29 - i) * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      accuracy: 0.75 + Math.random() * 0.2,
      volume: 800 + Math.random() * 600,
    })),
    
    categoryPerformance: [
      { category: 'PPE', accuracy: 0.92, volume: 234, improvement: 0.03 },
      { category: 'Machinery', accuracy: 0.89, volume: 456, improvement: 0.01 },
      { category: 'Hazards', accuracy: 0.84, volume: 123, improvement: -0.02 },
      { category: 'Controls', accuracy: 0.91, volume: 287, improvement: 0.05 },
      { category: 'Signage', accuracy: 0.79, volume: 147, improvement: 0.02 },
    ],
  },
};

export const mockAITaggingData = {
  highConfidenceTags: [
    {
      tag: 'conveyor-belt',
      confidence: 0.94,
      category: 'machinery',
      boundingBox: { x: 120, y: 80, width: 340, height: 180 },
      description: 'Industrial conveyor belt system',
      approved: null,
    },
    // ... more high confidence tags
  ],
  
  mixedConfidenceTags: [
    {
      tag: 'hard-hat',
      confidence: 0.78,
      category: 'ppe',
      boundingBox: { x: 300, y: 20, width: 60, height: 50 },
      description: 'Personal protective equipment - hard hat',
      approved: null,
    },
    // ... more mixed confidence tags
  ],
  
  comprehensiveTags: [
    // Large dataset for filtering tests
  ],
};
```

## Quality Checklist

### AI Component Stories Quality
- [ ] **Realistic AI Responses**: Mock data reflects actual AI analysis results
- [ ] **Complete Workflow States**: Analysis, processing, error, and success states
- [ ] **Performance Scenarios**: Handle high-volume processing and queue management
- [ ] **Error Handling**: Network failures, API limits, and processing errors
- [ ] **User Feedback**: Tag approval/rejection workflows with learning loops
- [ ] **Real-time Updates**: Progress indicators and live status monitoring

### Business Logic Validation  
- [ ] **Confidence Scoring**: Accurate representation of ML confidence levels
- [ ] **Category Classification**: Proper safety category organization
- [ ] **Batch Processing**: Multi-photo analysis workflows
- [ ] **Cost Tracking**: Realistic API usage and cost monitoring
- [ ] **Performance Metrics**: Accurate system health and analytics displays
- [ ] **Provider Integration**: Multiple AI service provider support

### Integration Testing
- [ ] **API Simulation**: Realistic API response timing and data
- [ ] **Queue Management**: Processing priority and batch handling
- [ ] **Store Integration**: AI state management and data persistence
- [ ] **Error Recovery**: Retry mechanisms and graceful failure handling

---

**Next Component Module**: After completing AI component stories, proceed to search and organization component stories for comprehensive workflow documentation.