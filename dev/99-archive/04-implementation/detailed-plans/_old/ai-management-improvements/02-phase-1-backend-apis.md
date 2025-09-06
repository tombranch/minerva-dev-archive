# Phase 1: Backend APIs Implementation Guide

*For: Claude Code*  
*Timeline: 2-3 days*  
*Priority: Critical - Blocks other phases*

## Overview

This phase completes the missing backend infrastructure for AI model and provider management. Currently, the frontend `EnhancedModelManagement` component exists but the backend APIs are not implemented.

## Objectives

1. Implement complete CRUD APIs for AI models
2. Implement provider management endpoints
3. Add model auto-discovery functionality
4. Ensure proper error handling and validation
5. Maintain multi-tenant security with RLS

## Implementation Tasks

### Task 1: Create AI Models API Endpoints

Create the following files and endpoints:

#### 1.1 Create `/app/api/ai/models/route.ts`
```typescript
// GET /api/ai/models - List all models for an organization
// POST /api/ai/models - Create a new model

Required functionality:
- Filter by organizationId and optionally by providerId
- Include model capabilities and configuration
- Sort by name or creation date
- Paginate results
```

#### 1.2 Create `/app/api/ai/models/[id]/route.ts`
```typescript
// GET /api/ai/models/[id] - Get specific model details
// PUT /api/ai/models/[id] - Update model configuration
// DELETE /api/ai/models/[id] - Delete a model

Required functionality:
- Verify organization ownership
- Cascade delete related data
- Audit trail for changes
```

#### 1.3 Create `/app/api/ai/models/discover/route.ts`
```typescript
// GET /api/ai/models/discover - Auto-discover models from providers

Required functionality:
- Query each provider's API for available models
- Map provider-specific model info to our schema
- Return standardized model information
```

### Task 2: Create AI Providers API Endpoints

#### 2.1 Create `/app/api/ai/providers/route.ts`
```typescript
// GET /api/ai/providers - List all providers
// POST /api/ai/providers - Add a new provider

Required functionality:
- Include provider health status
- Encrypt API keys before storage
- Validate provider configuration
```

#### 2.2 Create `/app/api/ai/providers/[id]/route.ts`
```typescript
// GET /api/ai/providers/[id] - Get provider details
// PUT /api/ai/providers/[id] - Update provider
// DELETE /api/ai/providers/[id] - Delete provider

Required functionality:
- Check for dependent models before deletion
- Update last health check timestamp
```

#### 2.3 Create `/app/api/ai/providers/[id]/test/route.ts`
```typescript
// POST /api/ai/providers/[id]/test - Test provider connection

Required functionality:
- Ping provider API
- Measure response time
- Verify authentication
- Return detailed status report
```

#### 2.4 Create `/app/api/ai/providers/[id]/models/route.ts`
```typescript
// GET /api/ai/providers/[id]/models - Get available models for a provider

Required functionality:
- Provider-specific model discovery
- Cache results for performance
- Include pricing information
```

### Task 3: Model Auto-Discovery Implementation

Create `/lib/ai/model-discovery.ts`:

```typescript
interface ModelDiscoveryService {
  discoverGoogleModels(apiKey: string): Promise<ModelInfo[]>
  discoverOpenAIModels(apiKey: string): Promise<ModelInfo[]>
  discoverAnthropicModels(apiKey: string): Promise<ModelInfo[]>
}

// Implement discovery for:
// - Google: Gemini 2.0 Flash, 1.5 Pro, 1.5 Flash
// - OpenAI: GPT-4 Vision, GPT-4 Turbo
// - Anthropic: Claude 3 Opus, Sonnet, Haiku
```

### Task 4: Database Schema Updates

Create migration: `/supabase/migrations/[timestamp]_ai_models_providers.sql`

```sql
-- Create ai_providers table if not exists
CREATE TABLE IF NOT EXISTS ai_providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  provider_type TEXT NOT NULL,
  api_key_encrypted TEXT,
  endpoint TEXT,
  settings JSONB DEFAULT '{}',
  is_enabled BOOLEAN DEFAULT true,
  health_status TEXT DEFAULT 'unknown',
  last_health_check TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create ai_models table if not exists
CREATE TABLE IF NOT EXISTS ai_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID REFERENCES ai_providers(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  model_id TEXT NOT NULL, -- e.g., 'gemini-2.0-flash'
  name TEXT NOT NULL,
  version TEXT,
  type TEXT NOT NULL, -- 'vision', 'language', 'multimodal'
  capabilities JSONB DEFAULT '[]',
  config JSONB DEFAULT '{}',
  cost_per_1k_tokens DECIMAL(10, 6),
  max_tokens INTEGER,
  is_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS policies
-- ... (include appropriate RLS policies)
```

### Task 5: Integration with Existing Code

Update the following files to use the new APIs:

1. **Update `/lib/ai/providers/gemini.ts`**:
   - Add method to list available Gemini models
   - Support specific model versions in API calls

2. **Update `/lib/ai/ai-service.ts`**:
   - Integrate with model selection logic
   - Use provider configurations from database

3. **Create `/lib/ai/provider-registry.ts`**:
   - Central registry for all providers
   - Dynamic provider loading
   - Health check coordination

## Acceptance Criteria

1. **API Functionality**:
   - [ ] All CRUD operations work for models and providers
   - [ ] Model discovery returns accurate results
   - [ ] Provider health checks function correctly
   - [ ] Proper error handling and validation

2. **Security**:
   - [ ] API keys are encrypted in database
   - [ ] RLS policies enforce organization isolation
   - [ ] Audit trail for all changes

3. **Performance**:
   - [ ] Model discovery results are cached
   - [ ] API responses < 500ms for list operations
   - [ ] Bulk operations supported

4. **Integration**:
   - [ ] Frontend EnhancedModelManagement component works
   - [ ] Existing AI processing uses new model configs
   - [ ] No breaking changes to current functionality

## Testing Requirements

1. **Unit Tests**:
   - Test each API endpoint
   - Test model discovery for each provider
   - Test encryption/decryption of API keys

2. **Integration Tests**:
   - Test full CRUD flow
   - Test provider health checks
   - Test multi-tenant isolation

3. **Manual Testing**:
   - Add providers through UI
   - Discover and enable models
   - Verify in AI processing

## Code References

- Frontend component: `/components/ai/features/EnhancedModelManagement.tsx`
- Current AI service: `/lib/ai/ai-service.ts`
- Provider implementations: `/lib/ai/providers/`
- Database client: `/lib/supabase-server.ts`

## Notes for Implementation

1. Use the existing pattern from other API routes for consistency
2. Leverage the organization ID from the auth context
3. Return consistent error messages and status codes
4. Log all operations for debugging
5. Consider rate limiting for discovery endpoints

## Success Metrics

- All API endpoints return 200/201 for valid requests
- Model discovery identifies all available models
- Provider health checks complete in < 2 seconds
- Zero security violations in multi-tenant tests

---

*This implementation guide provides everything needed to complete Phase 1. Once these APIs are implemented, the frontend will automatically work and enable the next phases of the project.*