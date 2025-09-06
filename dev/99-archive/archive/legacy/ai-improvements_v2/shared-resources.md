# Shared Resources & Common Components

*For All Agents | Reference Document*

## Overview

This document defines shared resources, common components, API patterns, and utilities that all agents should use to ensure consistency, avoid duplication, and enable seamless integration.

## Existing Infrastructure to Leverage

### API Endpoints (All Functional)
```typescript
// Core AI Management APIs - USE THESE DIRECTLY
GET    /api/ai/analytics/summary                    // Overall metrics
GET    /api/ai/analytics/cost-analysis             // Cost data  
GET    /api/ai/analytics/accuracy-trends           // Performance trends
GET    /api/ai/analytics/processing-efficiency     // Speed metrics
GET    /api/ai/provider-status                     // Provider health
GET    /api/ai/queue-status/[organizationId]       // Processing queue

// Prompt Management APIs
GET    /api/ai/prompts                             // List prompts
POST   /api/ai/prompts                             // Create prompt
GET    /api/ai/prompts/[id]                        // Get prompt
PUT    /api/ai/prompts/[id]                        // Update prompt
POST   /api/ai/prompts/[id]/test                   // Test prompt
GET    /api/ai/prompts/[id]/performance            // Prompt metrics

// Model & Provider APIs  
GET    /api/ai/models                              // List models
GET    /api/ai/models/discover                     // Discover models
GET    /api/ai/providers                           // List providers
POST   /api/ai/providers/[id]/test                 // Test provider

// Feature-specific APIs
GET    /api/ai/features                            // List AI features
GET    /api/ai/features/[featureId]/performance    // Feature metrics
POST   /api/ai/features/[featureId]/test           // Test feature
```

### Existing Services (Use These)
```typescript
// In lib/ai/ directory - all implemented and working
import { promptService } from '@/lib/ai/prompt-service';
import { modelDiscoveryService } from '@/lib/ai/model-discovery';  
import { providerRegistry } from '@/lib/ai/provider-registry';
import { featureService } from '@/lib/ai/feature-service';

// These services provide complete functionality for:
// - Prompt CRUD operations
// - Model discovery and management
// - Provider health monitoring
// - Feature configuration and testing
```

### Database Schema (Complete & Available)
```sql
-- Core AI infrastructure tables (use via APIs)
ai_prompt_templates       -- Prompt storage and versioning
ai_models                -- Model configurations  
ai_providers             -- Provider settings
ai_processing_results    -- Processing history and metrics
ai_prompt_performance    -- Prompt success rates
ai_model_usage          -- Model usage tracking
ai_corrections          -- User feedback for learning
ai_experiments          -- A/B testing results
ai_organization_settings -- Organization-level settings
```

## Shared UI Components

### 1. Layout Components
```typescript
// All agents should use these for consistent styling
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
```

### 2. Status Indicators
```typescript
// Shared status components - create these for reuse
interface StatusIndicatorProps {
  status: 'healthy' | 'warning' | 'error' | 'maintenance';
  label: string;
  details?: string;
}

interface MetricCardProps {
  title: string;
  value: string | number;
  trend?: string;          // "+15%", "-5%", etc.
  icon?: React.ReactNode;
  status?: 'good' | 'warning' | 'bad';
}

interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  message?: string;
}
```

### 3. Data Visualization Components
```typescript
// Shared chart components - leverage existing ones
import { EnhancedAnalytics } from '@/components/ai/analytics/EnhancedAnalytics';
import { InteractiveAnalytics } from '@/components/ai/analytics/InteractiveAnalytics';

// Create shared chart utilities
interface ChartProps {
  data: any[];
  type: 'line' | 'bar' | 'area' | 'pie';
  xAxis: string;
  yAxis: string;
  colorScheme?: string[];
}
```

## Common Data Types & Interfaces

### 1. Core AI Types
```typescript
// Shared interfaces all agents should use
interface AIFeature {
  id: string;
  name: string;
  description: string;
  category: 'photo_analysis' | 'description_generation' | 'safety_chat' | 'search_processing';
  status: 'active' | 'inactive' | 'error';
  performance: FeaturePerformance;
}

interface FeaturePerformance {
  successRate: number;       // 0-1
  avgResponseTime: number;   // milliseconds  
  requestCount: number;      // total requests
  errorCount: number;        // total errors
  cost: number;             // total cost
  accuracy: number;         // 0-1 accuracy score
}

interface PromptTemplate {
  id: string;
  name: string;
  content: string;
  category: string;
  provider_type: string;
  is_active: boolean;
  is_default: boolean;
  performance: PromptPerformance;
}

interface ModelInfo {
  id: string;
  name: string;
  provider: string;
  capabilities: string[];
  pricing: ModelPricing;
  performance: ModelPerformance;
  isActive: boolean;
}

interface ProviderStatus {
  id: string;
  name: string;
  type: string;
  status: 'healthy' | 'warning' | 'error' | 'maintenance';
  responseTime: number;
  successRate: number;
  lastError?: string;
}
```

### 2. Analytics & Metrics Types
```typescript
interface AnalyticsTimeRange {
  start: string;
  end: string;
  period: '1h' | '24h' | '7d' | '30d' | '90d';
}

interface MetricDataPoint {
  timestamp: string;
  value: number;
  label?: string;
}

interface TrendData {
  current: number;
  previous: number;
  change: number;           // absolute change
  changePercent: number;    // percentage change
  trend: 'up' | 'down' | 'stable';
}
```

### 3. Testing & Validation Types
```typescript
interface TestResult {
  success: boolean;
  score: number;           // 0-1 score
  details: TestDetails;
  duration: number;        // milliseconds
  cost: number;           // estimated cost
}

interface TestDetails {
  accuracy?: number;
  responseTime?: number;
  errorRate?: number;
  sampleSize: number;
  confidence: number;      // statistical confidence
}

interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
  suggestions: string[];
}
```

## Shared Utilities & Hooks

### 1. Data Fetching Patterns
```typescript
// Standard data fetching hook all agents should use
const useAIData = <T>(
  endpoint: string, 
  options?: { 
    refetchInterval?: number;
    enabled?: boolean;
    params?: Record<string, any>;
  }
) => {
  return useQuery({
    queryKey: [endpoint, options?.params],
    queryFn: () => fetchAIData<T>(endpoint, options?.params),
    refetchInterval: options?.refetchInterval ?? 30000,
    enabled: options?.enabled ?? true,
  });
};

// Mutation hook for AI operations
const useAIMutation = <T, V>(
  endpoint: string,
  options?: {
    onSuccess?: (data: T) => void;
    onError?: (error: Error) => void;
  }
) => {
  return useMutation({
    mutationFn: (variables: V) => mutateAIData<T>(endpoint, variables),
    onSuccess: options?.onSuccess,
    onError: options?.onError,
  });
};
```

### 2. Error Handling
```typescript
// Standard error handling pattern
interface AIError {
  code: string;
  message: string;
  details?: any;
}

const useErrorHandler = () => {
  const handleError = useCallback((error: AIError | Error) => {
    console.error('AI Management Error:', error);
    
    // Log to error tracking service
    if ('code' in error) {
      trackError('ai_management_error', {
        code: error.code,
        message: error.message,
        details: error.details
      });
    }
    
    // Show user-friendly error message
    showErrorNotification(getErrorMessage(error));
  }, []);
  
  return { handleError };
};
```

### 3. Real-time Updates
```typescript
// Shared WebSocket hook for real-time data
const useRealTimeData = (
  endpoint: string,
  onUpdate: (data: any) => void
) => {
  useEffect(() => {
    const ws = new WebSocket(`${endpoint}/stream`);
    
    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        onUpdate(data);
      } catch (error) {
        console.error('WebSocket data parsing error:', error);
      }
    };
    
    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
    
    return () => {
      ws.close();
    };
  }, [endpoint, onUpdate]);
};
```

## Styling & Design System

### 1. Color Scheme
```css
/* Shared color palette - use these consistently */
:root {
  /* Status colors */
  --ai-success: #10b981;    /* Green - healthy/success */
  --ai-warning: #f59e0b;    /* Yellow - warning/attention */
  --ai-error: #ef4444;      /* Red - error/critical */
  --ai-info: #3b82f6;       /* Blue - info/neutral */
  --ai-muted: #6b7280;      /* Gray - disabled/muted */
  
  /* Performance colors */
  --ai-high-performance: #10b981;
  --ai-medium-performance: #f59e0b; 
  --ai-low-performance: #ef4444;
  
  /* Chart colors */
  --ai-chart-primary: #3b82f6;
  --ai-chart-secondary: #8b5cf6;
  --ai-chart-tertiary: #06b6d4;
}
```

### 2. Typography
```css
/* Shared typography classes */
.ai-title-xl { @apply text-2xl font-bold text-gray-900; }
.ai-title-lg { @apply text-xl font-semibold text-gray-900; }
.ai-title-md { @apply text-lg font-medium text-gray-900; }
.ai-body-lg { @apply text-base text-gray-700; }
.ai-body-md { @apply text-sm text-gray-600; }
.ai-body-sm { @apply text-xs text-gray-500; }
.ai-metric { @apply text-2xl font-bold text-gray-900; }
.ai-trend { @apply text-sm font-medium; }
```

### 3. Layout Patterns
```css
/* Standard layout classes */
.ai-dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.ai-metric-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.ai-sidebar-layout {
  display: grid;
  grid-template-columns: 250px 1fr;
  gap: 2rem;
}
```

## Performance Guidelines

### 1. Data Loading
- **Use React Query** for all API calls with appropriate caching
- **Implement pagination** for large datasets (>100 items)
- **Show loading states** for operations taking >500ms
- **Debounce user inputs** with 300ms delay for search/filtering

### 2. Component Performance
- **Memoize expensive calculations** with useMemo
- **Virtualize large lists** (>50 items) using react-window
- **Lazy load tabs/modals** to reduce initial bundle size
- **Optimize re-renders** with React.memo and useCallback

### 3. Bundle Size
- **Tree-shake unused code** by importing only what's needed
- **Code split by route** to reduce initial load time
- **Compress images** and use appropriate formats
- **Monitor bundle size** and keep components under 50KB each

## Security Considerations

### 1. Data Handling
- **Never log sensitive data** (API keys, user data, etc.)
- **Sanitize all inputs** before sending to APIs
- **Use HTTPS** for all API communications
- **Implement proper error boundaries** to prevent crashes

### 2. Authentication
- **Include organization context** in all API calls
- **Handle authentication errors** gracefully
- **Implement proper session management**
- **Use role-based access control** where applicable

### 3. API Security
- **Validate all inputs** on both client and server
- **Use proper CORS settings**
- **Implement rate limiting** for expensive operations
- **Log security events** for audit purposes

## Testing Standards

### 1. Unit Testing
```typescript
// Test patterns all agents should follow
describe('ComponentName', () => {
  it('renders correctly', () => {
    render(<ComponentName {...defaultProps} />);
    expect(screen.getByText('Expected Text')).toBeInTheDocument();
  });
  
  it('handles user interactions', () => {
    const onAction = jest.fn();
    render(<ComponentName onAction={onAction} />);
    fireEvent.click(screen.getByRole('button'));
    expect(onAction).toHaveBeenCalled();
  });
  
  it('handles loading states', () => {
    render(<ComponentName loading={true} />);
    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
  });
  
  it('handles error states', () => {
    render(<ComponentName error="Test error" />);
    expect(screen.getByText('Test error')).toBeInTheDocument();
  });
});
```

### 2. Integration Testing
- **Test API integration** with mock servers
- **Test component integration** with other agents
- **Test error handling** and recovery
- **Test performance** under load

### 3. Accessibility
- **Use semantic HTML** elements
- **Provide ARIA labels** for complex components
- **Ensure keyboard navigation** works
- **Test with screen readers**

## Development Workflow

### 1. Code Organization
```
components/ai/management/
├── shared/                    # Shared components (all agents)
│   ├── StatusIndicator.tsx
│   ├── MetricCard.tsx  
│   ├── LoadingSpinner.tsx
│   ├── ErrorBoundary.tsx
│   └── ChartComponents.tsx
├── [agent-name]/             # Agent-specific components
│   ├── [AgentName]Container.tsx
│   ├── components/
│   └── hooks/
└── utils/                    # Shared utilities
    ├── api-client.ts
    ├── error-handling.ts
    ├── formatting.ts
    └── validation.ts
```

### 2. Naming Conventions
- **Components**: PascalCase (e.g., `DashboardContainer`)
- **Files**: kebab-case or PascalCase for components
- **Functions**: camelCase (e.g., `calculateMetrics`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `AI_FEATURES`)
- **Types/Interfaces**: PascalCase (e.g., `FeaturePerformance`)

### 3. Documentation
- **Document all public interfaces** with JSDoc
- **Include usage examples** for shared components
- **Document performance considerations**
- **Include accessibility notes**

## Integration Points

### 1. Data Flow
```
Dashboard (Agent 1) ←→ All other agents (status updates)
Prompts (Agent 2) ←→ Testing (Agent 5) (prompt testing)
Models (Agent 3) ←→ Analytics (Agent 4) (performance data)
Configuration (Agent 6) ←→ All agents (settings)
```

### 2. Event System
```typescript
// Shared event types for agent communication
interface AIManagementEvent {
  type: 'prompt_updated' | 'model_changed' | 'test_completed' | 'config_changed';
  payload: any;
  source: string;
  timestamp: string;
}

// Event bus for agent communication
const useEventBus = () => {
  const emit = (event: AIManagementEvent) => {
    window.dispatchEvent(new CustomEvent('ai-management', { detail: event }));
  };
  
  const subscribe = (callback: (event: AIManagementEvent) => void) => {
    const handler = (e: CustomEvent) => callback(e.detail);
    window.addEventListener('ai-management', handler);
    return () => window.removeEventListener('ai-management', handler);
  };
  
  return { emit, subscribe };
};
```

### 3. State Management
- **Use Zustand** for global state management
- **Keep agent state local** where possible
- **Share only necessary data** between agents
- **Use React Query** for server state

---

**Remember**: The goal is to create a cohesive, professional AI management platform. Consistency in design, code patterns, and user experience is crucial for success. When in doubt, follow the patterns established by existing components and prioritize developer usability.