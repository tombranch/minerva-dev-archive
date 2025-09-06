# Agent 2: Prompt Management System

*Priority: CRITICAL | Timeline: 4-5 days | Dependencies: None*

## Mission & Context

### What You're Building
Restore and enhance the core prompt management system that drives ALL AI features. This is the most critical component missing from the current system - developers need direct, powerful control over the prompts that determine AI behavior.

### Problem Statement  
The existing AI system has fully functional APIs and processing capabilities, but developers cannot effectively manage the prompts that control AI behavior. The prompt management interface is buried, incomplete, or abstracted away, making it impossible to optimize AI accuracy and responses.

### Success Criteria
- Direct editing of prompts for all AI features (tagging, descriptions, chat, search)
- Real-time testing of prompt changes against actual photos
- Version control and rollback capabilities for prompts
- Performance tracking showing how prompt changes affect accuracy
- One-click deployment of optimized prompts to production

## Technical Foundation

### Existing APIs (Fully Functional)
```typescript
// These endpoints exist and work - use them directly
GET    /api/ai/prompts                     // List all prompts
POST   /api/ai/prompts                     // Create new prompt
GET    /api/ai/prompts/[id]               // Get specific prompt
PUT    /api/ai/prompts/[id]               // Update prompt
DELETE /api/ai/prompts/[id]               // Delete prompt
POST   /api/ai/prompts/[id]/test          // Test prompt with data
POST   /api/ai/prompts/[id]/duplicate     // Duplicate prompt
POST   /api/ai/prompts/[id]/set-default   // Set as default
GET    /api/ai/prompts/[id]/performance   // Get performance data
GET    /api/ai/prompts/[id]/usage         // Get usage statistics
```

### Existing Services (Ready to Use)
```typescript
// In lib/ai/prompt-service.ts - fully implemented
import { promptService } from '@/lib/ai/prompt-service';

// Available methods:
promptService.getPromptTemplates(organizationId, filters)
promptService.getDefaultPrompt(organizationId, category, providerType)
promptService.createPromptTemplate(organizationId, template)
promptService.updatePromptTemplate(promptId, updates)
promptService.testPrompt(promptId, testData)
promptService.duplicatePrompt(promptId, newName)
promptService.setDefaultPrompt(promptId)
promptService.getPromptPerformance(promptId)
```

### Database Schema (Already Exists)
```sql
-- Core prompt storage
ai_prompt_templates (
  id, name, content, category, provider_type, 
  organization_id, is_active, is_default, 
  created_at, updated_at, created_by
)

-- Version history
ai_prompt_versions (
  id, template_id, version_number, content,
  change_description, created_at, created_by
)

-- Performance tracking
ai_prompt_performance (
  id, template_id, success_rate, avg_response_time,
  total_requests, error_count, last_used_at
)
```

### Current AI Feature Categories
These are the prompt categories you need to manage:

1. **Photo Tagging** (`photo_analysis`)
   - Safety analysis prompts
   - Equipment identification 
   - Hazard detection
   - Component analysis

2. **Photo Descriptions** (`description_generation`)
   - Technical documentation
   - Safety reports
   - Compliance documentation

3. **Safety Assistant** (`safety_chat`)
   - Conversational responses
   - Safety recommendations
   - Q&A about photos/projects

4. **Enhanced Search** (`search_processing`)
   - Query understanding
   - Semantic search enhancement
   - Result ranking

## Detailed Component Specifications

### 1. Prompt Library Browser
```typescript
interface PromptLibraryBrowser {
  // Filtering and organization
  categories: ['photo_analysis', 'description_generation', 'safety_chat', 'search_processing'];
  providers: ['google_vision', 'gemini', 'openai', 'claude'];
  statuses: ['active', 'inactive', 'draft', 'archived'];
  
  // Display options
  viewMode: 'grid' | 'list' | 'table';
  sortBy: 'name' | 'last_modified' | 'performance' | 'usage';
  
  // Actions
  actions: ['create_new', 'import', 'export', 'bulk_edit'];
}
```

### 2. Prompt Editor
```typescript
interface PromptEditor {
  // Editor features
  content: string;           // Prompt text with syntax highlighting
  variables: Variable[];     // Available template variables
  validation: string[];      // Real-time validation errors
  preview: string;          // Rendered prompt with sample data
  
  // Metadata
  metadata: {
    name: string;
    category: string;
    providerType: string;
    description: string;
    tags: string[];
  };
  
  // Testing capabilities
  testData: any;            // Sample data for testing
  testResults: TestResult; // Results from last test
  
  // Version control
  currentVersion: number;
  versionHistory: Version[];
  hasUnsavedChanges: boolean;
}
```

### 3. Variable System
```typescript
interface PromptVariable {
  name: string;              // Variable name (e.g., 'photo_url')
  type: 'string' | 'number' | 'boolean' | 'object';
  description: string;       // What this variable represents
  required: boolean;         // Is this variable required?
  defaultValue?: any;        // Default value if not provided
  validation?: string;       // Regex or validation rule
  examples: string[];        // Example values
}

// Pre-defined variables for each category
const PHOTO_ANALYSIS_VARIABLES: PromptVariable[] = [
  {
    name: 'photo_url',
    type: 'string',
    description: 'URL of the photo to analyze',
    required: true,
    examples: ['https://storage.url/photo.jpg']
  },
  {
    name: 'organization_context',
    type: 'object', 
    description: 'Organization-specific context and preferences',
    required: false,
    examples: ['{"industry": "manufacturing", "standards": ["OSHA", "ISO"]}']
  }
];
```

### 4. Testing Framework
```typescript
interface PromptTester {
  // Test configuration
  testType: 'single_photo' | 'batch_photos' | 'synthetic_data';
  testData: TestData[];
  
  // Test execution
  runTest: (promptId: string, testData: TestData[]) => Promise<TestResults>;
  
  // Results analysis
  results: {
    success: boolean;
    accuracy: number;        // % of correct results
    responseTime: number;    // Average response time
    cost: number;           // Estimated cost
    errors: string[];       // Any errors encountered
    samples: TestSample[];  // Sample results for review
  };
  
  // Comparison testing
  comparePrompts: (promptIds: string[], testData: TestData[]) => Promise<ComparisonResults>;
}
```

### 5. Performance Analytics
```typescript
interface PromptPerformanceAnalytics {
  // Usage metrics
  usage: {
    totalRequests: number;
    requestsToday: number;
    averageDaily: number;
    trending: 'up' | 'down' | 'stable';
  };
  
  // Quality metrics
  quality: {
    successRate: number;      // % of successful API calls
    userSatisfaction: number; // Based on corrections/feedback
    accuracyScore: number;    // Calculated accuracy
    consistencyScore: number; // Result consistency
  };
  
  // Performance metrics
  performance: {
    averageResponseTime: number;
    p95ResponseTime: number;
    errorRate: number;
    costPerRequest: number;
  };
  
  // Historical data
  trends: {
    timeRange: '24h' | '7d' | '30d' | '90d';
    dataPoints: PerformanceDataPoint[];
  };
}
```

## UI/UX Specifications

### Layout Structure
```
┌─────────────────────────────────────────────────────────┐
│ Header: [Create New] [Import] [Export] [Settings]      │
├─────────────────────────────────────────────────────────┤
│ Sidebar (Left)        │ Main Content Area              │
│ ┌─ Categories ───┐    │ ┌─ Prompt Editor ─────────────┐│
│ │ Photo Analysis │    │ │ Name: [Input Field]         ││
│ │ Descriptions   │    │ │ Category: [Dropdown]        ││  
│ │ Chat Assistant │    │ │ Provider: [Dropdown]        ││
│ │ Search         │    │ │                             ││
│ └───────────────┘    │ │ [Large Text Editor Area]    ││
│                      │ │ with syntax highlighting     ││
│ ┌─ Recent ──────┐    │ │                             ││
│ │ • Tag prompt   │    │ │ Variables: [Variable Panel] ││
│ │ • Chat prompt  │    │ │ Preview: [Rendered Preview] ││
│ │ • Search prompt│    │ └─────────────────────────────┘│
│ └───────────────┘    │                                │
│                      │ ┌─ Test Panel ────────────────┐│
│ ┌─ Actions ─────┐    │ │ Test Data: [Upload/Select]  ││
│ │ Test Prompt    │    │ │ [Run Test] [Compare]        ││
│ │ Duplicate      │    │ │ Results: [Performance Data] ││
│ │ Set Default    │    │ └─────────────────────────────┘│
│ │ View Analytics │    │                                │
│ └───────────────┘    │                                │
└─────────────────────────────────────────────────────────┘
```

### Key Interactions

#### 1. Quick Prompt Testing
- **Select Photo**: Choose from recent uploads or test library
- **One-Click Test**: Instant testing with visual results
- **Side-by-Side Comparison**: Test multiple prompt versions simultaneously

#### 2. Prompt Editing Workflow
- **Auto-save**: Save changes every 30 seconds
- **Validation**: Real-time syntax and variable validation
- **Preview**: Live preview of prompt with sample data
- **Variables Panel**: Drag-and-drop variable insertion

#### 3. Version Management
- **Version History**: Visual timeline of changes
- **Compare Versions**: Diff view showing changes
- **Rollback**: One-click revert to previous version
- **Branching**: Create variants for testing

## Implementation Guidelines

### File Structure
```
components/ai/management/prompts/
├── PromptManagementContainer.tsx     # Main container
├── PromptLibraryBrowser.tsx          # Prompt list/grid view
├── PromptEditor/
│   ├── PromptEditor.tsx              # Main editor component
│   ├── PromptTextEditor.tsx          # Text editor with syntax highlighting
│   ├── VariablePanel.tsx             # Variable management
│   ├── PromptPreview.tsx             # Live preview
│   └── PromptMetadata.tsx            # Name, category, etc.
├── PromptTester/
│   ├── PromptTester.tsx              # Testing interface
│   ├── TestConfiguration.tsx         # Test setup
│   ├── TestResults.tsx               # Results display
│   └── PromptComparison.tsx          # A/B testing
├── PromptAnalytics/
│   ├── PromptAnalytics.tsx           # Performance dashboard
│   ├── UsageMetrics.tsx              # Usage statistics
│   ├── QualityMetrics.tsx            # Quality tracking
│   └── PerformanceTrends.tsx         # Trend analysis
└── hooks/
    ├── usePromptEditor.tsx           # Editor state management
    ├── usePromptTesting.tsx          # Testing logic
    ├── usePromptAnalytics.tsx        # Analytics data
    └── usePromptVersions.tsx         # Version control
```

### Code Patterns

#### Prompt Editor State Management
```typescript
const usePromptEditor = (promptId?: string) => {
  const [prompt, setPrompt] = useState<PromptTemplate | null>(null);
  const [content, setContent] = useState('');
  const [hasChanges, setHasChanges] = useState(false);
  const [validationErrors, setValidationErrors] = useState<string[]>([]);
  
  // Auto-save logic
  useEffect(() => {
    if (hasChanges && promptId) {
      const timer = setTimeout(() => {
        savePrompt(promptId, { content });
        setHasChanges(false);
      }, 30000);
      return () => clearTimeout(timer);
    }
  }, [hasChanges, content, promptId]);
  
  return {
    prompt,
    content,
    setContent: (value: string) => {
      setContent(value);
      setHasChanges(true);
      validatePrompt(value);
    },
    save: () => savePrompt(promptId, { content }),
    hasChanges,
    validationErrors
  };
};
```

#### Testing Integration
```typescript
const usePromptTesting = () => {
  const [testResults, setTestResults] = useState<TestResults | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  
  const runTest = async (promptId: string, testData: any[]) => {
    setIsLoading(true);
    try {
      const results = await promptService.testPrompt(promptId, testData);
      setTestResults(results);
    } catch (error) {
      console.error('Test failed:', error);
    } finally {
      setIsLoading(false);
    }
  };
  
  return { testResults, runTest, isLoading };
};
```

### Security & Permissions
- Organization-level isolation for all prompts
- Role-based editing permissions (admin/editor/viewer)
- Audit logging for all prompt changes
- Secure test data handling (no sensitive info in logs)

### Performance Requirements
- **Editor Responsiveness**: < 100ms for typing, validation
- **Test Execution**: < 10 seconds for single photo tests
- **Data Loading**: < 2 seconds for prompt library
- **Auto-save**: Non-blocking background saves

## Testing Requirements

### Unit Tests
```typescript
describe('PromptEditor', () => {
  it('validates prompt syntax in real-time', () => {
    // Test variable syntax validation
  });
  
  it('auto-saves changes after 30 seconds', () => {  
    // Test auto-save functionality
  });
  
  it('prevents saving invalid prompts', () => {
    // Test validation prevents invalid saves
  });
});

describe('PromptTester', () => {
  it('executes tests with sample data', () => {
    // Test prompt execution
  });
  
  it('compares multiple prompt versions', () => {
    // Test A/B comparison functionality
  });
});
```

### Integration Tests  
```typescript
describe('Prompt Management API Integration', () => {
  it('creates and saves new prompts', () => {
    // Test full create workflow
  });
  
  it('loads and edits existing prompts', () => {
    // Test edit workflow
  });
  
  it('runs tests against real AI APIs', () => {
    // Test actual AI processing
  });
});
```

### User Acceptance Testing
1. **Developer Workflow**: Can a developer edit and test a photo tagging prompt in < 5 minutes?
2. **Performance Impact**: Does a prompt change improve AI accuracy within 24 hours?
3. **Error Recovery**: Can developers quickly identify and fix broken prompts?
4. **Version Control**: Can developers safely experiment and rollback changes?

## Delivery Requirements

### Files to Create
1. **PromptManagementContainer.tsx** - Main entry point
2. **Editor Components** - Full-featured prompt editor with syntax highlighting
3. **Testing Interface** - Real-time prompt testing capabilities
4. **Analytics Dashboard** - Performance tracking and metrics
5. **Version Control** - History and rollback functionality

### Documentation to Update
- Prompt template examples for each AI feature category
- Variable reference guide for developers
- Testing best practices and methodologies
- Performance optimization guidelines

### Demo Scenarios
1. **Edit Photo Tagging Prompt**: Modify safety analysis prompt and test with sample photos
2. **Create Description Prompt**: Build new technical documentation prompt from scratch
3. **A/B Test Prompts**: Compare two prompt versions and analyze performance
4. **Version Rollback**: Demonstrate rolling back to previous prompt version
5. **Performance Analysis**: Show how prompt changes affect accuracy metrics

### Handoff Requirements

#### To Agent 1 (Dashboard)
- Provide prompt performance metrics for dashboard display
- Export quick action integration ("Test Prompt" buttons)
- Share error tracking for prompt-related failures

#### To Agent 3 (Models)  
- Integrate with model selection (prompts optimized per model)
- Provide prompt testing with different models
- Share performance data across model/prompt combinations

#### To Agent 4 (Analytics)
- Export detailed prompt performance data  
- Provide success/failure metrics by prompt
- Share user feedback and correction data

#### To Agent 5 (Testing)
- Provide prompt testing framework as foundation
- Export test data formats and validation logic
- Share A/B testing methodology

---

**CRITICAL SUCCESS FACTOR**: Developers must be able to directly edit prompts that control AI behavior and immediately see the results. This is the core missing piece that makes AI optimization impossible. Everything else is secondary to getting this right.