# Agent Integration & Coordination Guide

*Critical Reference for All Agents*

## Overview

This guide explains how the 6 agents coordinate their work, integrate their components, and ensure seamless operation of the unified AI Management Platform. Follow these patterns to avoid conflicts and enable smooth handoffs.

## Integration Architecture

### High-Level Component Structure
```
components/ai/
├── AIManagementPortal.tsx           # Main entry point (create this)
├── management/                      # New management platform
│   ├── dashboard/                   # Agent 1: Core Dashboard
│   ├── prompts/                     # Agent 2: Prompt Management
│   ├── models/                      # Agent 3: Model Management  
│   ├── analytics/                   # Agent 4: Analytics
│   ├── testing/                     # Agent 5: Testing Framework
│   └── configuration/               # Agent 6: Configuration
├── shared/                          # Shared components (all agents)
│   ├── StatusIndicator.tsx
│   ├── MetricCard.tsx
│   ├── LoadingSpinner.tsx
│   ├── ErrorBoundary.tsx
│   └── ChartComponents.tsx
└── existing components...           # Keep existing components
```

### Main Entry Point
```typescript
// components/ai/AIManagementPortal.tsx
// This is the main component that integrates all agent work
export function AIManagementPortal({ organizationId }: { organizationId: string }) {
  const [activeTab, setActiveTab] = useState('dashboard');
  
  return (
    <div className="ai-management-portal">
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-6">
          <TabsTrigger value="dashboard">Dashboard</TabsTrigger>
          <TabsTrigger value="prompts">Prompts</TabsTrigger>
          <TabsTrigger value="models">Models</TabsTrigger>
          <TabsTrigger value="analytics">Analytics</TabsTrigger>
          <TabsTrigger value="testing">Testing</TabsTrigger>
          <TabsTrigger value="configuration">Configuration</TabsTrigger>
        </TabsList>
        
        <TabsContent value="dashboard">
          <DashboardContainer organizationId={organizationId} />
        </TabsContent>
        
        <TabsContent value="prompts">
          <PromptManagementContainer organizationId={organizationId} />
        </TabsContent>
        
        <TabsContent value="models">
          <ModelManagementContainer organizationId={organizationId} />
        </TabsContent>
        
        <TabsContent value="analytics">
          <AnalyticsContainer organizationId={organizationId} />
        </TabsContent>
        
        <TabsContent value="testing">
          <TestingContainer organizationId={organizationId} />
        </TabsContent>
        
        <TabsContent value="configuration">
          <ConfigurationContainer organizationId={organizationId} />
        </TabsContent>
      </Tabs>
    </div>
  );
}
```

## Agent Dependencies & Handoff Points

### Phase 1: Foundation (Week 1)
```
Agent 2 (Prompts) → STARTS IMMEDIATELY
├── No dependencies
├── Creates: PromptManagementContainer.tsx
├── Exports: Prompt testing functionality
└── Handoff: Prompt performance data to Agent 1 & 4

Agent 1 (Dashboard) → STARTS DAY 1
├── Depends on: Basic prompt data from Agent 2
├── Creates: DashboardContainer.tsx
├── Exports: Quick action buttons, real-time data
└── Handoff: Dashboard framework to all agents

Agent 3 (Models) → STARTS DAY 2  
├── Depends on: Dashboard framework from Agent 1
├── Creates: ModelManagementContainer.tsx
├── Exports: Model switching, comparison tools
└── Handoff: Model data to Agent 1, 2, 4
```

### Phase 2: Enhancement (Week 2)
```
Agent 4 (Analytics) → STARTS WEEK 2
├── Depends on: Data from Agents 1, 2, 3
├── Creates: AnalyticsContainer.tsx
├── Exports: Performance metrics, insights
└── Handoff: Analytics data to Agent 1

Agent 5 (Testing) → STARTS WEEK 2
├── Depends on: Prompts (Agent 2), Models (Agent 3)
├── Creates: TestingContainer.tsx  
├── Exports: Testing framework, A/B testing
└── Handoff: Test results to Agent 4

Agent 6 (Configuration) → STARTS WEEK 2/3
├── Depends on: All other agents for integration
├── Creates: ConfigurationContainer.tsx
├── Exports: Industry presets, setup wizard
└── Handoff: Configuration data to all agents
```

## Specific Integration Points

### 1. Agent 1 (Dashboard) ↔ All Others

#### Dashboard receives FROM other agents:
```typescript
// From Agent 2 (Prompts)
interface PromptMetrics {
  totalPrompts: number;
  activePrompts: number;
  promptSuccessRate: number;
  recentPromptChanges: PromptChange[];
}

// From Agent 3 (Models)
interface ModelStatus {
  activeModels: number;
  modelHealth: ProviderStatus[];
  modelSwitchingAvailable: boolean;
}

// From Agent 4 (Analytics)
interface AnalyticsSummary {
  overallAccuracy: number;
  costTrend: string;
  userSatisfaction: number;
  topInsights: Insight[];
}

// Dashboard integration pattern
const DashboardContainer = ({ organizationId }: { organizationId: string }) => {
  const promptMetrics = usePromptMetrics(organizationId);
  const modelStatus = useModelStatus(organizationId);
  const analytics = useAnalyticsSummary(organizationId);
  
  return (
    <div className="dashboard-grid">
      <FeatureHealthCards 
        promptData={promptMetrics}
        modelData={modelStatus}
        analyticsData={analytics}
      />
      <QuickActions onPromptTest={() => navigateToPrompts()} />
      {/* Other dashboard components */}
    </div>
  );
};
```

#### Dashboard provides TO other agents:
```typescript
// Quick action integration
interface QuickActions {
  testPrompt: (promptId: string) => void;
  switchModel: (featureId: string, modelId: string) => void;
  viewAnalytics: (feature: string) => void;
  runExperiment: (config: ExperimentConfig) => void;
}

// Navigation context
interface NavigationContext {
  currentTab: string;
  navigateTo: (tab: string, params?: any) => void;
  showModal: (type: string, props: any) => void;
}
```

### 2. Agent 2 (Prompts) ↔ Others

#### Prompt Management integrates with:
```typescript
// With Agent 3 (Models) - Model-specific prompts
interface ModelPromptIntegration {
  getPromptsForModel: (modelId: string) => PromptTemplate[];
  testPromptWithModel: (promptId: string, modelId: string) => Promise<TestResult>;
  optimizePromptForModel: (promptId: string, modelId: string) => Promise<OptimizedPrompt>;
}

// With Agent 5 (Testing) - Prompt testing framework
interface PromptTestingIntegration {
  createTestSuite: (promptId: string) => TestSuite;
  runABTest: (promptIds: string[]) => Promise<ExperimentResult>;
  validatePrompt: (promptId: string) => Promise<ValidationResult>;
}

// With Agent 4 (Analytics) - Performance data
interface PromptAnalyticsIntegration {
  getPromptPerformance: (promptId: string) => PromptPerformance;
  trackPromptUsage: (promptId: string, result: any) => void;
  getOptimizationSuggestions: (promptId: string) => OptimizationSuggestion[];
}
```

### 3. Agent 3 (Models) ↔ Others

#### Model Management integrates with:
```typescript
// With Agent 2 (Prompts) - Model switching
interface ModelPromptIntegration {
  updatePromptForModel: (promptId: string, modelId: string) => Promise<void>;
  getModelCapabilities: (modelId: string) => ModelCapabilities;
}

// With Agent 5 (Testing) - Model comparison
interface ModelTestingIntegration {
  compareModels: (modelIds: string[], testData: any[]) => Promise<ComparisonResult>;
  benchmarkModel: (modelId: string) => Promise<BenchmarkResult>;
}

// With Agent 4 (Analytics) - Model performance
interface ModelAnalyticsIntegration {
  getModelPerformance: (modelId: string) => ModelPerformance;
  getCostAnalysis: (modelId: string) => CostAnalysis;
}
```

## Data Flow Patterns

### 1. Real-Time Data Updates
```typescript
// Shared WebSocket connection for real-time updates
const useAIManagementWebSocket = (organizationId: string) => {
  const [socket, setSocket] = useState<WebSocket | null>(null);
  
  useEffect(() => {
    const ws = new WebSocket(`/api/ai/management/stream?org=${organizationId}`);
    
    ws.onmessage = (event) => {
      const update = JSON.parse(event.data);
      
      // Broadcast to all agents
      window.dispatchEvent(new CustomEvent('ai-management-update', {
        detail: update
      }));
    };
    
    setSocket(ws);
    return () => ws.close();
  }, [organizationId]);
  
  return socket;
};

// Agents subscribe to specific update types
const useRealtimeUpdates = (updateTypes: string[]) => {
  const [updates, setUpdates] = useState<any[]>([]);
  
  useEffect(() => {
    const handler = (event: CustomEvent) => {
      const update = event.detail;
      if (updateTypes.includes(update.type)) {
        setUpdates(prev => [update, ...prev.slice(0, 99)]); // Keep last 100
      }
    };
    
    window.addEventListener('ai-management-update', handler);
    return () => window.removeEventListener('ai-management-update', handler);
  }, [updateTypes]);
  
  return updates;
};
```

### 2. Cross-Agent Communication
```typescript
// Event bus for agent-to-agent communication
interface AgentMessage {
  source: string;           // Agent that sent the message
  target: string;          // Target agent (or 'all')
  type: string;            // Message type
  payload: any;            // Message data
}

const useAgentCommunication = (agentName: string) => {
  const sendMessage = (message: Omit<AgentMessage, 'source'>) => {
    window.dispatchEvent(new CustomEvent('agent-message', {
      detail: { ...message, source: agentName }
    }));
  };
  
  const subscribeToMessages = (handler: (message: AgentMessage) => void) => {
    const eventHandler = (event: CustomEvent) => {
      const message = event.detail as AgentMessage;
      if (message.target === agentName || message.target === 'all') {
        handler(message);
      }
    };
    
    window.addEventListener('agent-message', eventHandler);
    return () => window.removeEventListener('agent-message', eventHandler);
  };
  
  return { sendMessage, subscribeToMessages };
};

// Example usage in Agent 2 (Prompts)
const PromptEditor = () => {
  const { sendMessage } = useAgentCommunication('prompts');
  
  const handlePromptUpdate = (promptId: string) => {
    // Notify other agents about prompt update
    sendMessage({
      target: 'all',
      type: 'prompt_updated',
      payload: { promptId, timestamp: Date.now() }
    });
  };
};
```

### 3. Shared State Management
```typescript
// Global AI Management state using Zustand
interface AIManagementState {
  // Current selections
  selectedOrganization: string;
  activeFeature: string | null;
  selectedModel: string | null;
  selectedPrompt: string | null;
  
  // UI state
  sidebarOpen: boolean;
  activeTab: string;
  modalStack: ModalState[];
  
  // Real-time data
  systemHealth: SystemHealth;
  activeTests: TestExecution[];
  
  // Actions
  setActiveFeature: (feature: string) => void;
  setSelectedModel: (modelId: string) => void;
  setSelectedPrompt: (promptId: string) => void;
  updateSystemHealth: (health: SystemHealth) => void;
}

const useAIManagementStore = create<AIManagementState>((set) => ({
  selectedOrganization: '',
  activeFeature: null,
  selectedModel: null,
  selectedPrompt: null,
  sidebarOpen: true,
  activeTab: 'dashboard',
  modalStack: [],
  systemHealth: { status: 'unknown', lastCheck: null },
  activeTests: [],
  
  setActiveFeature: (feature) => set({ activeFeature: feature }),
  setSelectedModel: (modelId) => set({ selectedModel: modelId }),
  setSelectedPrompt: (promptId) => set({ selectedPrompt: promptId }),
  updateSystemHealth: (health) => set({ systemHealth: health }),
}));
```

## Error Handling & Recovery

### 1. Graceful Degradation
```typescript
// Each agent should handle failures of other agents gracefully
const withFallback = <T>(
  primaryData: T | undefined,
  fallbackData: T,
  errorMessage?: string
) => {
  if (primaryData === undefined) {
    console.warn(`Fallback used: ${errorMessage || 'Primary data unavailable'}`);
    return fallbackData;
  }
  return primaryData;
};

// Example: Dashboard handles missing analytics gracefully
const DashboardContainer = () => {
  const analyticsData = useAnalyticsData(); // May fail
  const fallbackAnalytics = { accuracy: 0, cost: 0, satisfaction: 0 };
  
  const displayData = withFallback(
    analyticsData, 
    fallbackAnalytics,
    'Analytics service unavailable'
  );
  
  return (
    <div>
      <MetricCard 
        title="Accuracy" 
        value={displayData.accuracy}
        status={analyticsData ? 'normal' : 'warning'}
      />
    </div>
  );
};
```

### 2. Error Boundaries
```typescript
// Shared error boundary for all agent components
interface AIManagementErrorBoundaryProps {
  children: React.ReactNode;
  agentName: string;
  fallback?: React.ComponentType<{ error: Error; retry: () => void }>;
}

const AIManagementErrorBoundary: React.FC<AIManagementErrorBoundaryProps> = ({
  children,
  agentName,
  fallback: Fallback
}) => {
  return (
    <ErrorBoundary
      fallback={({ error, resetErrorBoundary }) => (
        <div className="ai-error-boundary">
          <h3>Agent Error: {agentName}</h3>
          <p>{error.message}</p>
          <Button onClick={resetErrorBoundary}>Retry</Button>
        </div>
      )}
      onError={(error) => {
        console.error(`Agent ${agentName} error:`, error);
        // Log to error tracking
      }}
    >
      {children}
    </ErrorBoundary>
  );
};
```

## Testing Integration

### 1. Cross-Agent Integration Tests
```typescript
// Test that agents work together correctly
describe('AI Management Integration', () => {
  it('dashboard displays data from all agents', async () => {
    // Mock data from each agent
    mockPromptMetrics();
    mockModelStatus();
    mockAnalyticsData();
    
    render(<AIManagementPortal organizationId="test" />);
    
    // Verify dashboard shows data from all sources
    expect(screen.getByText('Prompt Performance')).toBeInTheDocument();
    expect(screen.getByText('Model Health')).toBeInTheDocument();
    expect(screen.getByText('Analytics Summary')).toBeInTheDocument();
  });
  
  it('prompt changes trigger updates in other agents', async () => {
    const { user } = setup(<AIManagementPortal organizationId="test" />);
    
    // Navigate to prompts tab
    await user.click(screen.getByText('Prompts'));
    
    // Update a prompt
    await user.click(screen.getByText('Edit Prompt'));
    await user.type(screen.getByRole('textbox'), 'Updated prompt content');
    await user.click(screen.getByText('Save'));
    
    // Verify other agents receive the update
    await waitFor(() => {
      expect(mockAnalyticsUpdate).toHaveBeenCalledWith(
        expect.objectContaining({ type: 'prompt_updated' })
      );
    });
  });
});
```

### 2. Mock Strategies
```typescript
// Mock entire agent components for testing
const mockAgent = (agentName: string, mockData: any) => {
  jest.mock(`../management/${agentName}/${agentName}Container`, () => ({
    [`${agentName}Container`]: ({ organizationId }: { organizationId: string }) => (
      <div data-testid={`${agentName}-mock`}>
        Mock {agentName} Component
        <div data-testid={`${agentName}-data`}>
          {JSON.stringify(mockData)}
        </div>
      </div>
    )
  }));
};
```

## Performance Optimization

### 1. Bundle Splitting
```typescript
// Lazy load agent components to reduce initial bundle size
const DashboardContainer = lazy(() => import('./dashboard/DashboardContainer'));
const PromptManagementContainer = lazy(() => import('./prompts/PromptManagementContainer'));
const ModelManagementContainer = lazy(() => import('./models/ModelManagementContainer'));
const AnalyticsContainer = lazy(() => import('./analytics/AnalyticsContainer'));
const TestingContainer = lazy(() => import('./testing/TestingContainer'));
const ConfigurationContainer = lazy(() => import('./configuration/ConfigurationContainer'));

// Wrap in Suspense
const LazyAgentContainer = ({ agent, ...props }: any) => (
  <Suspense fallback={<LoadingSpinner message={`Loading ${agent}...`} />}>
    {agent === 'dashboard' && <DashboardContainer {...props} />}
    {agent === 'prompts' && <PromptManagementContainer {...props} />}
    {/* ... other agents */}
  </Suspense>
);
```

### 2. Data Caching Strategy
```typescript
// Shared cache configuration for React Query
const aiManagementQueryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,    // 5 minutes
      cacheTime: 10 * 60 * 1000,   // 10 minutes
      refetchOnWindowFocus: false,  // Prevent excessive refetching
      retry: (failureCount, error) => {
        // Custom retry logic for AI APIs
        return failureCount < 3 && !isAuthError(error);
      },
    },
  },
});

// Cache keys should be consistent across agents
const cacheKeys = {
  prompts: (orgId: string) => ['prompts', orgId],
  models: (orgId: string) => ['models', orgId],
  analytics: (orgId: string, timeRange: string) => ['analytics', orgId, timeRange],
  // ... etc
};
```

## Deployment & Release Coordination

### 1. Feature Flags
```typescript
// Use feature flags to enable agents progressively
const useFeatureFlags = () => {
  return {
    dashboardEnabled: true,           // Always enabled
    promptManagementEnabled: true,    // Agent 2 - Critical
    modelManagementEnabled: true,     // Agent 3 - High priority
    analyticsEnabled: false,          // Agent 4 - Enable after foundation
    testingEnabled: false,           // Agent 5 - Enable after core features
    configurationEnabled: false,     // Agent 6 - Enable last
  };
};

// Conditional rendering based on feature flags
const AIManagementPortal = ({ organizationId }: { organizationId: string }) => {
  const flags = useFeatureFlags();
  
  return (
    <Tabs>
      <TabsList>
        <TabsTrigger value="dashboard">Dashboard</TabsTrigger>
        <TabsTrigger value="prompts">Prompts</TabsTrigger>
        {flags.modelManagementEnabled && (
          <TabsTrigger value="models">Models</TabsTrigger>
        )}
        {flags.analyticsEnabled && (
          <TabsTrigger value="analytics">Analytics</TabsTrigger>
        )}
        {/* ... other conditional tabs */}
      </TabsList>
    </Tabs>
  );
};
```

### 2. Version Compatibility
```typescript
// Ensure agent compatibility
interface AgentVersion {
  name: string;
  version: string;
  compatibleWith: string[];
  requiredAPIs: string[];
}

const checkAgentCompatibility = (agents: AgentVersion[]) => {
  // Validate that all agents are compatible with each other
  // Check that required APIs are available
  // Return compatibility matrix
};
```

## Final Integration Checklist

### For Each Agent:
- [ ] Container component follows naming convention (`[Agent]Container.tsx`)
- [ ] Exports required interfaces for other agents
- [ ] Handles graceful degradation when other agents fail
- [ ] Implements proper error boundaries
- [ ] Uses shared components from `shared/` directory
- [ ] Follows performance guidelines (lazy loading, caching)
- [ ] Includes comprehensive tests for integration points
- [ ] Documents all public interfaces and integration points

### For Overall System:
- [ ] Main `AIManagementPortal.tsx` integrates all agents
- [ ] Real-time data flow works across all agents
- [ ] Cross-agent communication events function correctly
- [ ] Shared state management is consistent
- [ ] Error handling prevents cascade failures
- [ ] Performance is acceptable with all agents loaded
- [ ] Feature flags allow progressive rollout
- [ ] Documentation is complete and accurate

---

**Critical Success Factor**: Each agent must work independently while providing seamless integration points for others. The system should degrade gracefully if any single agent fails, maintaining core functionality for developers.