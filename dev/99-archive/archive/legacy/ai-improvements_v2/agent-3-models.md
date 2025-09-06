# Agent 3: Model & Provider Management

*Priority: HIGH | Timeline: 3-4 days | Dependencies: None*

## Mission & Context

### What You're Building
Create comprehensive model and provider management tools that allow developers to easily switch between AI models, monitor provider health, compare model performance, and optimize cost vs quality tradeoffs.

### Problem Statement
Developers need granular control over which AI models and providers are used for different features, with the ability to quickly switch models, test performance, and optimize costs based on real usage data.

### Success Criteria
- Easy switching between AI models (Gemini 1.5 Flash, 2.0 Flash, GPT-4, Claude, etc.)
- Real-time provider health monitoring and automatic failover
- Model performance comparison with cost analysis
- Automatic model recommendations based on use case and performance
- One-click model deployment and rollback capabilities

## Technical Foundation

### Existing APIs (Fully Functional)
```typescript
// Model management endpoints
GET    /api/ai/models                    // List all available models
POST   /api/ai/models                    // Add new model configuration
GET    /api/ai/models/[id]              // Get specific model details
PUT    /api/ai/models/[id]              // Update model configuration
DELETE /api/ai/models/[id]              // Remove model
GET    /api/ai/models/discover          // Auto-discover models from providers

// Provider management endpoints  
GET    /api/ai/providers                // List all providers
POST   /api/ai/providers                // Add new provider
GET    /api/ai/providers/[id]           // Get provider details
PUT    /api/ai/providers/[id]           // Update provider settings
DELETE /api/ai/providers/[id]           // Remove provider
POST   /api/ai/providers/[id]/test      // Test provider connection
GET    /api/ai/providers/[id]/models    // Get models from provider

// Status and monitoring
GET    /api/ai/provider-status          // Real-time provider health
```

### Existing Services (Ready to Use)
```typescript
// In lib/ai/model-discovery.ts - already implemented
import { modelDiscoveryService } from '@/lib/ai/model-discovery';

// Available methods:
modelDiscoveryService.discoverModels(providerId)
modelDiscoveryService.testModelCapabilities(modelId)
modelDiscoveryService.getModelPricing(modelId)
modelDiscoveryService.compareModels(modelIds)

// In lib/ai/provider-registry.ts - already implemented  
import { providerRegistry } from '@/lib/ai/provider-registry';

// Available methods:
providerRegistry.getHealthStatus(providerId)
providerRegistry.testConnection(providerId)
providerRegistry.getAvailableModels(providerId) 
providerRegistry.updateProviderConfig(providerId, config)
```

### Current AI Providers & Models
Based on existing implementation:

#### Google AI Platform
- **Gemini 1.5 Flash** - Fast, cost-effective for most tasks
- **Gemini 1.5 Pro** - Higher accuracy, more expensive
- **Gemini 2.0 Flash** - Latest model with improved performance
- **Google Cloud Vision** - Specialized for image analysis

#### OpenAI
- **GPT-4 Vision** - Advanced multimodal capabilities
- **GPT-4 Turbo** - Faster processing, lower cost
- **GPT-4o** - Optimized for various tasks

#### Anthropic
- **Claude 3 Haiku** - Fast and economical
- **Claude 3 Sonnet** - Balanced performance
- **Claude 3 Opus** - Highest capability

#### Clarifai
- **General Detection** - Object and concept detection
- **NSFW Detection** - Content moderation
- **Custom Models** - Organization-specific models

### Database Schema (Already Exists)
```sql
-- Model configurations
ai_models (
  id, name, provider_id, model_type, capabilities,
  pricing_input, pricing_output, max_tokens,
  is_active, configuration, created_at
)

-- Provider settings
ai_providers (
  id, name, provider_type, api_endpoint,
  encrypted_api_key, is_active, health_status,
  configuration, last_health_check
)

-- Model usage tracking
ai_model_usage (
  id, model_id, organization_id, request_count,
  total_cost, avg_response_time, success_rate,
  usage_date
)
```

## Detailed Component Specifications

### 1. Provider Dashboard
```typescript
interface ProviderDashboard {
  // Provider overview
  providers: ProviderStatus[];
  totalProviders: number;
  activeProviders: number;
  healthyProviders: number;
  
  // Quick actions
  actions: [
    'add_provider',
    'test_all_providers', 
    'refresh_health_status',
    'configure_failover'
  ];
  
  // Health summary
  overallHealth: 'healthy' | 'degraded' | 'critical';
  lastHealthCheck: string;
  healthTrend: 'improving' | 'stable' | 'declining';
}

interface ProviderStatus {
  id: string;
  name: string;
  type: 'google' | 'openai' | 'anthropic' | 'clarifai';
  status: 'healthy' | 'warning' | 'error' | 'maintenance';
  responseTime: number;        // Average response time (ms)
  successRate: number;         // Success rate (0-1)
  dailyRequests: number;       // Requests today
  dailyCost: number;          // Cost today
  availableModels: number;     // Number of models available
  lastError?: string;         // Last error message if any
}
```

### 2. Model Catalog
```typescript
interface ModelCatalog {
  // Filtering and search
  filters: {
    provider: string[];
    capability: ['vision', 'text', 'multimodal'];
    priceRange: [number, number];
    responseTime: 'fast' | 'medium' | 'slow';
    accuracy: 'high' | 'medium' | 'basic';
  };
  
  // Display options
  viewMode: 'grid' | 'table' | 'comparison';
  sortBy: 'name' | 'provider' | 'cost' | 'performance' | 'popularity';
  
  // Model information
  models: ModelInfo[];
}

interface ModelInfo {
  id: string;
  name: string;
  displayName: string;        // User-friendly name
  provider: string;
  modelType: 'vision' | 'text' | 'multimodal';
  
  // Capabilities
  capabilities: {
    maxTokens: number;
    inputTypes: string[];      // ['image', 'text']
    outputTypes: string[];     // ['text', 'json', 'structured']
    languages: string[];       // Supported languages
    specialties: string[];     // ['safety_analysis', 'technical_writing']
  };
  
  // Performance metrics
  performance: {
    avgResponseTime: number;   // Milliseconds
    successRate: number;       // 0-1
    accuracyScore: number;     // 0-1 (if available)
    throughput: number;        // Requests per minute
  };
  
  // Pricing
  pricing: {
    inputCostPer1kTokens: number;
    outputCostPer1kTokens: number;
    minimumCost: number;
    freeThreshold: number;     // Free requests per month
  };
  
  // Usage and recommendations
  usage: {
    totalRequests: number;
    requestsToday: number;
    costToday: number;
    usageGrowth: string;       // "+15% this week"
  };
  
  // Configuration
  isActive: boolean;
  isDefault: boolean;          // Default for its category
  configuration: ModelConfig;  // Model-specific settings
  recommendedFor: string[];    // Use cases this model excels at
}
```

### 3. Model Comparison Tool
```typescript
interface ModelComparisonTool {
  // Comparison setup
  selectedModels: string[];    // Up to 4 models
  comparisonType: 'performance' | 'cost' | 'accuracy' | 'comprehensive';
  
  // Test configuration
  testData: {
    samplePhotos: string[];    // Photos to test with
    testPrompts: string[];     // Prompts to use
    iterations: number;        // Number of test runs
  };
  
  // Results
  results: ModelComparisonResults;
}

interface ModelComparisonResults {
  summary: {
    winner: string;            // Best overall model
    bestForCost: string;       // Most cost-effective
    bestForSpeed: string;      // Fastest model
    bestForAccuracy: string;   // Most accurate
  };
  
  detailedResults: {
    [modelId: string]: {
      performance: {
        avgResponseTime: number;
        successRate: number;
        accuracyScore: number;
        consistencyScore: number;
      };
      cost: {
        totalCost: number;
        costPerRequest: number;
        costPerAccurateResult: number;
      };
      quality: {
        accurateResults: number;
        partialResults: number;
        failedResults: number;
      };
    };
  };
  
  recommendations: {
    modelId: string;
    reason: string;
    confidence: number;
    tradeoffs: string[];
  }[];
}
```

### 4. Model Configuration Manager
```typescript
interface ModelConfigurationManager {
  // Model assignment by feature
  featureModelAssignments: {
    photo_analysis: string;      // Model ID for photo tagging
    description_generation: string; // Model ID for descriptions  
    safety_chat: string;         // Model ID for chat
    search_processing: string;   // Model ID for search
  };
  
  // Fallback configuration
  fallbackChain: string[];       // Ordered list of fallback models
  autoFailover: boolean;         // Enable automatic failover
  failoverThreshold: number;     // Error rate threshold for failover
  
  // Performance settings
  performanceSettings: {
    [modelId: string]: {
          timeout: number;           // Request timeout (ms)
          maxRetries: number;        // Max retry attempts
          retryDelay: number;        // Delay between retries (ms)
          rateLimitRpm: number;      // Requests per minute limit
          batchSize: number;         // Batch processing size
        };
  };
  
  // Cost controls
  costControls: {
    dailyBudget: number;         // Daily spending limit
    monthlyBudget: number;       // Monthly spending limit
    costAlertThreshold: number;  // Alert when reaching % of budget
    emergencyStopThreshold: number; // Auto-stop when reaching threshold
  };
}
```

### 5. Model Discovery & Auto-Setup
```typescript
interface ModelDiscoveryTool {
  // Discovery status
  discoveryStatus: 'idle' | 'discovering' | 'complete' | 'error';
  lastDiscovery: string;       // Last discovery timestamp
  
  // Provider scanning
  scanAllProviders: () => Promise<DiscoveryResults>;
  scanProvider: (providerId: string) => Promise<ProviderDiscoveryResults>;
  
  // Auto-configuration
  autoSetupRecommendations: ModelRecommendation[];
  applyRecommendations: (recommendations: ModelRecommendation[]) => Promise<void>;
  
  // Discovery results
  discoveredModels: {
    new: ModelInfo[];            // Newly discovered models
    updated: ModelInfo[];        // Models with updated info
    deprecated: ModelInfo[];     // Models no longer available
  };
}

interface ModelRecommendation {
  featureType: string;           // 'photo_analysis', 'descriptions', etc.
  recommendedModel: string;      // Model ID
  currentModel: string;          // Currently assigned model
  reason: string;               // Why this model is recommended
  expectedImprovement: {
    accuracy: string;           // "+15% accuracy"
    cost: string;              // "-30% cost"
    speed: string;             // "+2x faster"
  };
  confidence: number;           // 0-1 confidence in recommendation
}
```

## UI/UX Specifications

### Layout Structure
```
┌─────────────────────────────────────────────────────────┐
│ Provider Health Bar: [●●●○] 3/4 Healthy                │
├─────────────────────────────────────────────────────────┤
│ Tab Navigation: [Providers] [Models] [Compare] [Config] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ PROVIDERS TAB:                                          │
│ ┌─ Google AI ─────┐ ┌─ OpenAI ───────┐ ┌─ Anthropic ──┐│
│ │ 🟢 Healthy       │ │ 🟡 Slow        │ │ 🟢 Healthy   ││
│ │ 234ms avg        │ │ 1,247ms avg    │ │ 456ms avg    ││
│ │ 99.2% uptime     │ │ 97.8% uptime   │ │ 99.9% uptime ││
│ │ $12.45 today     │ │ $8.92 today    │ │ $3.21 today  ││
│ │ [Test] [Config]  │ │ [Test] [Config]│ │ [Test] [Cfg] ││
│ └─────────────────┘ └───────────────┘ └─────────────┘│
│                                                         │
│ MODELS TAB:                                             │
│ Filter: [Provider ▼] [Type ▼] [Cost ▼] [Performance ▼] │
│ ┌─ Model Grid ─────────────────────────────────────────┐│
│ │ Gemini 2.0 Flash    OpenAI GPT-4o     Claude Sonnet ││
│ │ 🟢 Active           🟢 Active          ⚪ Available   ││
│ │ $0.15/1K tokens     $5.00/1K tokens   $3.00/1K      ││
│ │ 1.2s avg            2.1s avg          1.8s avg      ││
│ │ [Use] [Test] [Info] [Use] [Test]      [Enable]      ││
│ └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### Key Interactions

#### 1. Quick Model Switching
- **Current Assignment**: Visual indicator showing which model is used for each feature
- **One-Click Switch**: Dropdown to quickly change model assignments
- **A/B Test Option**: "Test this model vs current" button on each model card

#### 2. Provider Health Monitoring
- **Real-Time Status**: Color-coded health indicators with auto-refresh
- **Detailed Metrics**: Click provider card for detailed health metrics
- **Alert System**: Browser notifications for provider issues

#### 3. Model Discovery Workflow
- **Auto-Discovery**: Schedule automatic discovery of new models
- **New Model Alerts**: Notifications when new models are discovered
- **Easy Setup**: One-click setup for recommended models

## Implementation Guidelines

### File Structure
```
components/ai/management/models/  
├── ModelManagementContainer.tsx      # Main container
├── ProviderDashboard/
│   ├── ProviderDashboard.tsx         # Provider overview
│   ├── ProviderCard.tsx              # Individual provider status
│   ├── ProviderHealthMonitor.tsx     # Real-time health tracking
│   └── ProviderConfiguration.tsx     # Provider settings
├── ModelCatalog/
│   ├── ModelCatalog.tsx              # Model browser
│   ├── ModelCard.tsx                 # Individual model display
│   ├── ModelFilters.tsx              # Filtering interface
│   └── ModelSearch.tsx               # Search functionality
├── ModelComparison/
│   ├── ModelComparison.tsx           # Comparison tool
│   ├── ComparisonSetup.tsx           # Test configuration
│   ├── ComparisonResults.tsx         # Results display
│   └── ModelRecommendations.tsx      # AI recommendations
├── ModelConfiguration/
│   ├── ModelConfiguration.tsx        # Feature-model assignments
│   ├── FeatureModelSelector.tsx      # Model selection per feature
│   ├── FallbackConfiguration.tsx     # Failover settings
│   └── CostControls.tsx              # Budget and limits
└── hooks/
    ├── useProviderHealth.tsx         # Real-time health monitoring
    ├── useModelDiscovery.tsx         # Model discovery logic
    ├── useModelComparison.tsx        # Comparison functionality
    └── useModelConfiguration.tsx     # Configuration management
```

### Code Patterns

#### Real-Time Provider Monitoring
```typescript
const useProviderHealth = (organizationId: string) => {
  const [healthData, setHealthData] = useState<ProviderStatus[]>([]);
  const [lastUpdate, setLastUpdate] = useState<Date>(new Date());
  
  useEffect(() => {
    // Set up WebSocket connection for real-time updates
    const ws = new WebSocket(`/api/ai/provider-status/stream?org=${organizationId}`);
    
    ws.onmessage = (event) => {
      const update = JSON.parse(event.data);
      setHealthData(prev => updateProviderHealth(prev, update));
      setLastUpdate(new Date());
    };
    
    // Initial data fetch
    fetchProviderHealth(organizationId).then(setHealthData);
    
    return () => ws.close();
  }, [organizationId]);
  
  return { healthData, lastUpdate, refresh: () => fetchProviderHealth(organizationId) };
};
```

#### Model Comparison Logic
```typescript
const useModelComparison = () => {
  const [comparisonResults, setComparisonResults] = useState<ModelComparisonResults | null>(null);
  const [isComparing, setIsComparing] = useState(false);
  
  const compareModels = async (modelIds: string[], testData: any[]) => {
    setIsComparing(true);
    try {
      const results = await Promise.all(
        modelIds.map(modelId => testModelWithData(modelId, testData))
      );
      
      const comparison = analyzeComparisonResults(results);
      setComparisonResults(comparison);
    } catch (error) {
      console.error('Model comparison failed:', error);
    } finally {
      setIsComparing(false);
    }
  };
  
  return { comparisonResults, compareModels, isComparing };
};
```

### Performance Requirements
- **Health Updates**: Real-time provider status updates (< 5 second latency)
- **Model Switching**: < 30 seconds to switch and verify new model
- **Discovery**: Complete model discovery in < 2 minutes
- **Comparison**: Model comparison tests complete in < 5 minutes

### Security Considerations
- Encrypted API keys stored securely in database
- Organization-level isolation for all configurations
- Audit logging for all model changes
- Rate limiting protection for provider testing

## Testing Requirements

### Unit Tests
```typescript
describe('ProviderHealthMonitor', () => {
  it('displays real-time health status', () => {
    // Test health status updates
  });
  
  it('handles provider failures gracefully', () => {
    // Test error state handling
  });
});

describe('ModelComparison', () => {
  it('compares models accurately', () => {
    // Test comparison logic
  });
  
  it('provides actionable recommendations', () => {
    // Test recommendation generation
  });
});
```

### Integration Tests
```typescript
describe('Model Management API Integration', () => {
  it('switches models for features', () => {
    // Test model assignment changes
  });
  
  it('discovers new models from providers', () => {
    // Test discovery workflow
  });
  
  it('handles provider failover', () => {
    // Test automatic failover
  });
});
```

### Performance Tests
- Provider health monitoring under load
- Model switching with active processing
- Discovery with multiple providers simultaneously

## Delivery Requirements

### Files to Create
1. **ModelManagementContainer.tsx** - Main entry point
2. **Provider Management** - Real-time health monitoring and configuration
3. **Model Catalog** - Comprehensive model browser and search
4. **Comparison Tools** - Side-by-side model performance analysis
5. **Configuration Interface** - Feature-model assignments and settings

### Demo Scenarios
1. **Provider Health Check**: Show real-time provider status and failure detection
2. **Model Discovery**: Demonstrate automatic discovery of new models
3. **Model Comparison**: Compare Gemini 2.0 Flash vs GPT-4 for photo tagging
4. **Quick Switch**: Change photo analysis model from Gemini to Claude
5. **Cost Optimization**: Show cost analysis and optimization recommendations

### Handoff Requirements

#### To Agent 1 (Dashboard)
- Provide provider health data for dashboard display
- Export model performance metrics
- Share cost information for budget tracking

#### To Agent 2 (Prompts)
- Enable model-specific prompt optimization
- Provide model capabilities for prompt validation
- Share performance data for prompt effectiveness analysis

#### To Agent 4 (Analytics)
- Export detailed model usage and performance data
- Provide cost breakdown by model and feature
- Share comparison results for trend analysis

#### To Agent 5 (Testing)
- Provide model testing framework integration
- Export model comparison methodology
- Share performance benchmarking tools

---

**Key Success Metric**: Developers should be able to switch AI models for any feature in under 30 seconds and immediately see the performance impact. The system should automatically recommend the best model for each use case based on real performance data.