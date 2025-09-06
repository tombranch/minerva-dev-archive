# Phase 2: Feature-Oriented Reorganization Implementation Guide

*For: Claude Code*  
*Timeline: 2-3 days*  
*Priority: High - Core UX improvement*

## Overview

Transform the AI management system from technical concept organization (providers, models, prompts) to user-friendly feature organization (Photo Tagging, Descriptions, Safety Assistant, etc.). This makes the system intuitive for non-technical users.

## Objectives

1. Reorganize prompts around app features instead of technical use cases
2. Create feature-focused UI components
3. Implement feature performance tracking
4. Maintain backward compatibility
5. Provide clear migration path

## Current vs. Target State

### Current Organization (Technical):
```
Prompts → Use Cases → Providers → Models
- safety_analysis
- equipment_inspection  
- compliance_check
- general_tagging
```

### Target Organization (Feature-Based):
```
Features → Sub-Features → Optimal Configuration
- Photo Tagging
  - Safety Analysis
  - Equipment Detection
  - Hazard Identification
- Photo Descriptions
- Safety Assistant
- Smart Search
```

## Implementation Tasks

### Task 1: Create Feature Management Components

#### 1.1 Create `/components/ai/features/FeaturePromptManager.tsx`
```typescript
interface AIFeature {
  id: string;
  name: string;
  icon: React.ComponentType;
  description: string;
  subFeatures: SubFeature[];
  currentPrompt: PromptTemplate | null;
  performance: FeaturePerformance;
  settings: FeatureSettings;
}

interface SubFeature {
  id: string;
  name: string;
  description: string;
  promptId?: string;
  enabled: boolean;
}

// Component should:
// - Display features as cards with icons
// - Show performance metrics per feature
// - Allow prompt selection per feature
// - Provide one-click optimization
```

#### 1.2 Create `/components/ai/features/FeaturePerformanceCard.tsx`
```typescript
// Display for each feature:
// - Usage count (last 30 days)
// - Success rate
// - Average confidence score
// - Cost per use
// - User satisfaction (if available)
// - Trend indicators
```

#### 1.3 Create `/components/ai/features/PromptImpactPreview.tsx`
```typescript
// When changing a prompt, show:
// - Estimated accuracy change
// - Cost impact
// - Speed difference
// - Before/after comparison
// - Test with sample data
```

### Task 2: Update Prompt Assignment Component

#### 2.1 Refactor `/components/ai/settings/PromptAssignment.tsx`

Replace current use case approach with feature-based organization:

```typescript
const AI_FEATURES = [
  {
    id: 'photo-tagging',
    name: 'Photo Tagging',
    icon: Tag,
    description: 'Automatically tag photos with relevant labels',
    subFeatures: [
      { id: 'safety-analysis', name: 'Safety Analysis' },
      { id: 'equipment-id', name: 'Equipment Identification' },
      { id: 'hazard-detection', name: 'Hazard Detection' },
      { id: 'component-analysis', name: 'Component Analysis' }
    ]
  },
  {
    id: 'photo-descriptions',
    name: 'Photo Descriptions',
    icon: FileText,
    description: 'Generate detailed descriptions for photos',
    subFeatures: [
      { id: 'technical-desc', name: 'Technical Descriptions' },
      { id: 'safety-focused', name: 'Safety-Focused Descriptions' },
      { id: 'compliance-desc', name: 'Compliance Descriptions' }
    ]
  },
  {
    id: 'safety-assistant',
    name: 'Safety Assistant',
    icon: MessageSquare,
    description: 'AI chatbot for safety questions and guidance',
    subFeatures: [
      { id: 'qa-photos', name: 'Q&A about Photos' },
      { id: 'safety-recs', name: 'Safety Recommendations' },
      { id: 'compliance-guide', name: 'Compliance Guidance' }
    ]
  },
  {
    id: 'smart-search',
    name: 'Smart Search',
    icon: Search,
    description: 'Natural language search across photos',
    subFeatures: [
      { id: 'natural-lang', name: 'Natural Language Search' },
      { id: 'visual-similarity', name: 'Visual Similarity' },
      { id: 'semantic-search', name: 'Semantic Search' }
    ]
  }
];
```

### Task 3: Create Feature Service Layer

#### 3.1 Create `/lib/ai/feature-service.ts`
```typescript
class AIFeatureService {
  // Map features to optimal prompts
  async getFeatureConfiguration(featureId: string): Promise<FeatureConfig>
  
  // Track feature performance
  async trackFeatureUsage(featureId: string, result: UsageResult): Promise<void>
  
  // Get performance metrics
  async getFeaturePerformance(featureId: string, timeRange: TimeRange): Promise<FeaturePerformance>
  
  // Optimize feature configuration
  async optimizeFeature(featureId: string): Promise<OptimizationResult>
  
  // Get feature-specific prompts
  async getFeaturePrompts(featureId: string): Promise<PromptTemplate[]>
}
```

#### 3.2 Create `/lib/ai/feature-defaults.ts`
```typescript
// Default configurations for each feature
export const FEATURE_DEFAULTS = {
  'photo-tagging': {
    primaryPrompt: 'Industrial Safety Analysis - Gemini',
    fallbackPrompt: 'Quick Tag Generation - Universal',
    model: 'gemini-2.0-flash',
    confidence: 0.75
  },
  'photo-descriptions': {
    primaryPrompt: 'Technical Description Generator',
    model: 'gemini-1.5-pro',
    confidence: 0.80
  },
  // ... etc
};
```

### Task 4: Update Main AI Management Page

#### 4.1 Modify `/components/ai/UnifiedAIManagement.tsx`

Change the Prompts tab to focus on features:

```typescript
// Replace current prompts tab content with:
<TabsContent value="prompts" className="mt-6">
  <ErrorBoundary fallback={AIErrorFallback}>
    <FeaturePromptManager organizationId={organizationId} />
  </ErrorBoundary>
</TabsContent>

// Update tab label from "Prompts" to "AI Features"
```

### Task 5: API Updates for Feature Tracking

#### 5.1 Create `/app/api/ai/features/[featureId]/performance/route.ts`
```typescript
// GET /api/ai/features/[featureId]/performance
// Track and return feature-specific metrics
```

#### 5.2 Create `/app/api/ai/features/[featureId]/optimize/route.ts`
```typescript
// POST /api/ai/features/[featureId]/optimize
// Run optimization analysis and suggest improvements
```

### Task 6: Migration and Backward Compatibility

#### 6.1 Create migration utilities in `/lib/ai/feature-migration.ts`
```typescript
// Map existing use cases to new features
const USE_CASE_TO_FEATURE_MAP = {
  'safety_analysis': 'photo-tagging.safety-analysis',
  'equipment_inspection': 'photo-tagging.equipment-id',
  'compliance_check': 'photo-tagging.safety-analysis',
  'incident_analysis': 'safety-assistant.qa-photos',
  'general_tagging': 'photo-tagging.general'
};

// Migrate existing prompt assignments
export async function migratePromptAssignments(organizationId: string): Promise<void>
```

## UI/UX Requirements

### Feature Cards Design
- Large, clickable cards with clear icons
- Performance metrics prominently displayed
- Status indicators (configured, needs attention, optimal)
- Quick actions: Configure, Test, Optimize

### Simplified Language
Replace technical terms:
- "Prompt Templates" → "AI Instructions"
- "Confidence Threshold" → "Accuracy Level"
- "Provider" → "AI Service"
- "Model" → "AI Version"

### Visual Feedback
- Green checkmarks for configured features
- Yellow warnings for suboptimal performance
- Red alerts for features needing attention
- Trend arrows for performance changes

## Acceptance Criteria

1. **Feature Organization**:
   - [ ] All prompts accessible through feature interface
   - [ ] Sub-features properly categorized
   - [ ] Performance metrics display correctly
   - [ ] One-click optimization works

2. **User Experience**:
   - [ ] Non-technical users can configure without confusion
   - [ ] Clear visual feedback for all actions
   - [ ] Intuitive navigation between features
   - [ ] Help text and tooltips available

3. **Backward Compatibility**:
   - [ ] Existing configurations continue to work
   - [ ] Migration tool successfully maps old to new
   - [ ] No data loss during transition
   - [ ] API compatibility maintained

4. **Performance**:
   - [ ] Feature cards load in < 1 second
   - [ ] Real-time performance updates
   - [ ] Smooth animations and transitions

## Testing Requirements

1. **User Testing**:
   - Test with non-technical users
   - Verify feature discovery is intuitive
   - Confirm terminology is clear

2. **Migration Testing**:
   - Test migration with existing data
   - Verify all mappings work correctly
   - Ensure no configuration is lost

3. **Integration Testing**:
   - Test with actual AI processing
   - Verify feature tracking works
   - Confirm optimization suggestions are valid

## Code References

- Current implementation: `/components/ai/settings/PromptAssignment.tsx`
- Prompt library: `/components/ai/prompt-manager/PromptLibrary.tsx`
- AI service: `/lib/ai/ai-service.ts`
- Prompt templates: `/lib/ai/prompt-templates/index.ts`

## Implementation Notes

1. Preserve all existing functionality while adding feature layer
2. Use feature flags to gradually roll out changes
3. Provide "Classic View" option for power users
4. Log all feature interactions for analytics
5. Cache feature performance data for speed

## Success Metrics

- User configuration time reduced by 50%
- Feature adoption rate > 80%
- Support tickets for AI config reduced by 40%
- User satisfaction score > 4.5/5

---

*This guide transforms the AI management system into a feature-focused platform that's intuitive for all users while maintaining powerful capabilities for advanced users.*