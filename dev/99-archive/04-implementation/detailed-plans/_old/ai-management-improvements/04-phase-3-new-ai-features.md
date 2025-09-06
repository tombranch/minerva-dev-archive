# Phase 3: New AI Features Implementation Guide

*For: Claude Code*  
*Timeline: 3-4 days*  
*Priority: High - Key value additions*

## Overview

Implement three major new AI features that users have been requesting: individual photo description generation, a safety assistant chatbot, and AI-enhanced search capabilities. These features will significantly increase the value of the Minerva platform.

## Objectives

1. Add photo description generation for individual photos
2. Implement a context-aware safety assistant chatbot
3. Create AI-enhanced search with natural language processing
4. Integrate all features with the existing AI management system
5. Ensure optimal performance and cost efficiency

## Implementation Tasks

### Task 1: Photo Description Generation

#### 1.1 Create API Endpoint `/app/api/photos/[id]/generate-description/route.ts`

```typescript
// POST /api/photos/[id]/generate-description
interface DescriptionRequest {
  style: 'technical' | 'safety-focused' | 'compliance';
  length: 'brief' | 'detailed';
  context?: {
    projectId?: string;
    siteInfo?: string;
    existingTags?: string[];
  };
}

interface DescriptionResponse {
  description: string;
  confidence: number;
  cost: number;
  processingTime: number;
  suggestions?: string[];
}

// Features to implement:
// - Use existing photo analysis data if available
// - Generate context-aware descriptions
// - Support different description styles
// - Track usage and performance
```

#### 1.2 Create Bulk Description API `/app/api/photos/bulk-generate-descriptions/route.ts`

```typescript
// POST /api/photos/bulk-generate-descriptions
interface BulkDescriptionRequest {
  photoIds: string[];
  style: 'technical' | 'safety-focused' | 'compliance';
  length: 'brief' | 'detailed';
  batchSize?: number; // Default 10
}

// Process photos in batches
// Provide progress updates via WebSocket or polling
// Optimize for cost and speed
```

#### 1.3 Create Description Service `/lib/ai/description-service.ts`

```typescript
class PhotoDescriptionService {
  async generateDescription(
    photoId: string, 
    options: DescriptionOptions
  ): Promise<DescriptionResult>
  
  async generateBulkDescriptions(
    photoIds: string[], 
    options: BulkDescriptionOptions
  ): Promise<BulkDescriptionResult>
  
  private async buildDescriptionPrompt(
    photo: Photo, 
    context: PhotoContext, 
    style: DescriptionStyle
  ): Promise<string>
  
  private async selectOptimalModel(style: DescriptionStyle): Promise<ModelConfig>
}
```

#### 1.4 Add UI Components

Create `/components/photos/PhotoDescriptionGenerator.tsx`:
```typescript
// Features:
// - Style selector (dropdown)
// - Length selector (radio buttons)  
// - Preview area
// - Generate button with loading state
// - Edit and save functionality
// - Cost estimate display
```

Create `/components/photos/BulkDescriptionModal.tsx`:
```typescript
// Features:
// - Photo selection interface
// - Batch configuration
// - Progress tracking
// - Results summary
// - Error handling
```

#### 1.5 Integration Points

- Add "Generate Description" button to photo detail view
- Add bulk action in photo grid
- Integrate with existing photo editing workflow
- Add to AI features dashboard

### Task 2: Safety Assistant (Chatbot)

#### 2.1 Create Chat API Endpoints

Create `/app/api/ai/chat/route.ts`:
```typescript
// POST /api/ai/chat
interface ChatRequest {
  message: string;
  context?: {
    photoId?: string;
    projectId?: string;
    conversationId?: string;
  };
  organizationId: string;
}

interface ChatResponse {
  response: string;
  confidence: number;
  sources?: string[];
  suggestions?: string[];
  conversationId: string;
}
```

Create `/app/api/ai/chat/[conversationId]/route.ts`:
```typescript
// GET /api/ai/chat/[conversationId] - Get conversation history
// DELETE /api/ai/chat/[conversationId] - Clear conversation
```

#### 2.2 Create Chat Service `/lib/ai/chat-service.ts`

```typescript
class SafetyAssistantService {
  async processMessage(
    message: string, 
    context: ChatContext
  ): Promise<ChatResponse>
  
  async getConversationHistory(conversationId: string): Promise<ChatMessage[]>
  
  private async buildContextPrompt(
    message: string, 
    context: ChatContext, 
    history: ChatMessage[]
  ): Promise<string>
  
  private async detectIntent(message: string): Promise<ChatIntent>
  
  // Intent types: question, request_analysis, safety_guidance, compliance_help
}
```

#### 2.3 Create Chat Components

Create `/components/ai/SafetyAssistant.tsx`:
```typescript
// Features:
// - Chat interface with message bubbles
// - Typing indicators
// - Context awareness (current photo/project)
// - Message actions (copy, share)
// - Conversation history
// - Quick action buttons
```

Create `/components/ai/ChatContextProvider.tsx`:
```typescript
// Provides current context to chat:
// - Current photo being viewed
// - Current project
// - Organization info
// - User role and permissions
```

#### 2.4 Chat Prompt Templates

Add to `/lib/ai/prompt-templates/chat-templates.ts`:
```typescript
export const CHAT_PROMPT_TEMPLATES = {
  general_safety: `
    You are a safety assistant for {organization_name}, helping with industrial safety questions.
    Current context: {context}
    User question: {user_message}
    
    Provide helpful, accurate safety guidance based on:
    - Industry best practices
    - Relevant safety standards
    - The specific context provided
    
    Keep responses concise but comprehensive.
  `,
  
  photo_analysis: `
    Analyze this photo and answer the user's question: {user_message}
    
    Photo context: {photo_context}
    Photo tags: {photo_tags}
    
    Focus on safety implications and provide actionable insights.
  `,
  
  compliance_guidance: `
    Provide compliance guidance for {organization_name} regarding: {user_message}
    
    Industry: {organization_industry}
    Applicable standards: {safety_standards}
    Context: {context}
    
    Include specific regulatory references where applicable.
  `
};
```

### Task 3: AI-Enhanced Search

#### 3.1 Create Search Enhancement API

Create `/app/api/search/ai-enhanced/route.ts`:
```typescript
// POST /api/search/ai-enhanced
interface AISearchRequest {
  query: string;
  type: 'natural_language' | 'semantic' | 'visual_similarity';
  filters?: SearchFilters;
  organizationId: string;
}

interface AISearchResponse {
  results: SearchResult[];
  interpretation: string; // What the AI understood
  suggestions: string[]; // Alternative queries
  totalResults: number;
}
```

#### 3.2 Create Search Service `/lib/ai/enhanced-search-service.ts`

```typescript
class EnhancedSearchService {
  async processNaturalLanguageQuery(
    query: string, 
    filters: SearchFilters
  ): Promise<SearchResult[]>
  
  async semanticSimilaritySearch(
    query: string,
    limit: number
  ): Promise<SearchResult[]>
  
  async visualSimilaritySearch(
    referencePhotoId: string,
    limit: number
  ): Promise<SearchResult[]>
  
  private async interpretQuery(query: string): Promise<QueryInterpretation>
  
  private async generateEmbeddings(text: string): Promise<number[]>
  
  // Query interpretation examples:
  // "photos with missing guards" → filter by hazard_types: ["missing_guard"]
  // "machinery in poor condition" → filter by condition: "poor"
  // "PPE violations" → filter by safety_issues: ["ppe_violation"]
}
```

#### 3.3 Add Search Embeddings to Database

Create migration `/supabase/migrations/[timestamp]_search_embeddings.sql`:
```sql
-- Add embedding columns to photos table
ALTER TABLE photos ADD COLUMN IF NOT EXISTS 
  description_embedding vector(1536);

ALTER TABLE photos ADD COLUMN IF NOT EXISTS 
  tags_embedding vector(1536);

-- Create indexes for vector similarity search
CREATE INDEX IF NOT EXISTS photos_description_embedding_idx 
  ON photos USING ivfflat (description_embedding vector_cosine_ops);

CREATE INDEX IF NOT EXISTS photos_tags_embedding_idx 
  ON photos USING ivfflat (tags_embedding vector_cosine_ops);
```

#### 3.4 Create Enhanced Search UI

Create `/components/search/EnhancedSearchBar.tsx`:
```typescript
// Features:
// - Natural language input
// - Search type selector
// - Auto-suggestions
// - Query interpretation display
// - Search history
```

Create `/components/search/SearchResultsEnhanced.tsx`:
```typescript
// Features:
// - Relevance scoring display
// - Explanation of why results match
// - Visual similarity indicators
// - Alternative query suggestions
```

### Task 4: Integration with AI Management

#### 4.1 Add Features to AI Management Dashboard

Update `/components/ai/UnifiedAIManagement.tsx`:
```typescript
// Add new feature cards:
const newFeatures = [
  {
    id: 'photo-descriptions',
    title: 'Photo Descriptions',
    description: 'AI-generated descriptions for photos',
    metrics: { /* usage stats */ },
    actions: ['Configure', 'Test', 'View Analytics']
  },
  {
    id: 'safety-assistant',
    title: 'Safety Assistant',
    description: 'AI chatbot for safety questions',
    metrics: { /* conversation stats */ },
    actions: ['Configure', 'Test Chat', 'View Conversations']
  },
  {
    id: 'smart-search',
    title: 'Smart Search',
    description: 'AI-enhanced search capabilities',
    metrics: { /* search performance */ },
    actions: ['Configure', 'Test Search', 'View Analytics']
  }
];
```

#### 4.2 Create Feature-Specific Settings

Create `/components/ai/features/PhotoDescriptionSettings.tsx`:
```typescript
// Settings for description generation:
// - Default style and length
// - Model selection
// - Cost limits
// - Quality thresholds
```

Create `/components/ai/features/ChatAssistantSettings.tsx`:
```typescript
// Settings for chat assistant:
// - Personality/tone configuration
// - Context awareness level
// - Response length limits
// - Knowledge base sources
```

## Performance Considerations

1. **Cost Optimization**:
   - Cache common descriptions
   - Use faster models for simple descriptions
   - Batch processing for bulk operations
   - Rate limiting for chat

2. **Speed Optimization**:
   - Parallel processing for bulk operations
   - Pre-compute embeddings for search
   - WebSocket updates for real-time features
   - Progressive loading for results

3. **Quality Assurance**:
   - Confidence thresholds for each feature
   - Fallback prompts for poor results
   - User feedback integration
   - A/B testing for improvements

## Acceptance Criteria

1. **Photo Descriptions**:
   - [ ] Individual photo description generation works
   - [ ] Bulk processing handles 20+ photos
   - [ ] Different styles produce appropriate outputs
   - [ ] Integration with photo workflow is seamless

2. **Safety Assistant**:
   - [ ] Natural conversation flow
   - [ ] Context awareness from current photo/project
   - [ ] Accurate safety guidance
   - [ ] Conversation history persistence

3. **Enhanced Search**:
   - [ ] Natural language queries work correctly
   - [ ] Semantic search finds relevant results
   - [ ] Visual similarity produces good matches
   - [ ] Performance is under 2 seconds

## Testing Requirements

1. **Feature Testing**:
   - Test each feature with various inputs
   - Verify cost tracking accuracy
   - Test error handling and edge cases

2. **Integration Testing**:
   - Test with existing photo workflows
   - Verify AI management integration
   - Test multi-user scenarios

3. **Performance Testing**:
   - Load test with 100+ concurrent requests
   - Test bulk operations with large datasets
   - Verify response times meet targets

## Code References

- Existing description service: `/lib/ai/description-generator.ts`
- Photo components: `/components/photos/`
- Search components: `/components/search/`
- AI management: `/components/ai/UnifiedAIManagement.tsx`

## Success Metrics

- Photo descriptions generated: >1000/month
- Chat conversations: >500/month  
- Enhanced search usage: >80% of all searches
- User satisfaction: >4.5/5 for new features

---

*These new features will significantly enhance Minerva's AI capabilities and provide immediate value to users.*