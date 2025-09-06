# Agent 1: Core AI Management Dashboard

*Priority: HIGH | Timeline: 3-4 days | Dependencies: None*

## Mission & Context

### What You're Building
Create the main dashboard for the AI Management Platform - the central command center where developers monitor, control, and optimize all AI features that end users interact with.

### Problem Statement
Developers need immediate visibility into AI system performance, costs, and health across all features (photo tagging, descriptions, chat, search) with quick access to critical actions.

### Success Criteria
- Real-time performance metrics for all AI features
- Quick action buttons for common tasks (test prompts, switch models, view errors)
- Cost monitoring with alerts and trends
- Feature health indicators with drill-down capabilities
- Response time under 2 seconds for all dashboard data

## Technical Foundation

### Existing APIs to Integrate
```typescript
// These endpoints already exist and work
GET /api/ai/analytics/summary                    // Overall stats
GET /api/ai/analytics/cost-analysis             // Cost data
GET /api/ai/analytics/accuracy-trends           // Performance trends
GET /api/ai/analytics/processing-efficiency     // Speed metrics
GET /api/ai/provider-status                     // Provider health
GET /api/ai/queue-status/[organizationId]       // Processing queue
GET /api/ai/processing-metrics/[organizationId] // Processing stats
```

### Existing Components to Leverage
- `components/ai/monitoring/RealTimeMonitor.tsx` - Real-time data fetching
- `components/ai/analytics/EnhancedAnalytics.tsx` - Chart components
- `components/ai/monitoring/CostMonitor.tsx` - Cost tracking
- `components/ui/card.tsx` - Layout components
- `components/ui/progress.tsx` - Progress indicators
- `components/ui/badge.tsx` - Status indicators

### Database Tables (Read-Only Access)
```sql
-- AI processing results and metrics
ai_processing_results     -- Processing history, costs, performance
ai_prompt_performance     -- Prompt success rates and metrics  
ai_models                 -- Model configurations and status
ai_providers              -- Provider health and availability
photo_tags                -- Tagging results and accuracy
ai_corrections            -- User feedback and learning data
```

## Detailed Component Specifications

### 1. Dashboard Header
```typescript
interface DashboardHeader {
  // Real-time status indicators
  systemStatus: 'healthy' | 'degraded' | 'error';
  activeFeatures: number;
  processingQueue: number;
  
  // Quick actions
  actions: [
    'Test Photo Processing',
    'View Error Logs', 
    'Export Analytics',
    'Emergency Stop Processing'
  ];
}
```

### 2. Feature Health Cards
```typescript
interface FeatureHealthCard {
  feature: 'photo_tagging' | 'descriptions' | 'chat' | 'search';
  status: 'healthy' | 'warning' | 'error';
  metrics: {
    successRate: number;     // Last 24h success rate
    avgResponseTime: number; // Average response time
    requestCount: number;    // Requests in last 24h
    errorCount: number;      // Errors in last 24h
  };
  quickActions: string[]; // Feature-specific actions
}
```

### 3. Cost Overview Section
```typescript
interface CostOverview {
  current: {
    daily: number;          // Today's spend
    monthly: number;        // Month-to-date spend
    trending: 'up' | 'down' | 'stable';
  };
  limits: {
    dailyLimit: number;
    monthlyLimit: number;
    alertThreshold: number;
  };
  breakdown: {             // Cost by feature
    photo_tagging: number;
    descriptions: number;
    chat: number;
    search: number;
  };
}
```

### 4. Performance Metrics Grid
```typescript
interface PerformanceMetrics {
  processing: {
    totalProcessed: number;    // Photos processed today
    averageTime: number;       // Average processing time
    queueLength: number;       // Current queue size
    throughput: number;        // Photos/hour rate
  };
  accuracy: {
    overallAccuracy: number;   // % of correct AI results
    tagAccuracy: number;       // Tag accuracy rate
    userSatisfaction: number;  // Based on corrections
    improvementTrend: string;  // Week-over-week change
  };
}
```

### 5. Recent Activity Feed
```typescript
interface ActivityFeed {
  events: ActivityEvent[];
  filters: ['all', 'errors', 'successes', 'warnings'];
  realTimeUpdates: boolean;
}

interface ActivityEvent {
  timestamp: string;
  type: 'processing' | 'error' | 'model_switch' | 'prompt_update';
  feature: string;
  description: string;
  severity: 'info' | 'warning' | 'error';
  details?: any;
}
```

## UI/UX Specifications

### Layout Structure
```
┌─────────────────────────────────────────────────────────┐
│ Dashboard Header: System Status + Quick Actions        │
├─────────────────────────────────────────────────────────┤
│ Feature Health Cards (2x2 Grid)                        │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│ │Photo Tag │ │Descriptions│ │Chat      │ │Search    │   │
│ │🟢 Healthy│ │🟡 Warning │ │🟢 Healthy│ │🔴 Error  │   │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘   │
├─────────────────────────────────────────────────────────┤
│ Cost Overview (Left) | Performance Metrics (Right)     │
├─────────────────────────────────────────────────────────┤
│ Recent Activity Feed (Scrollable, Real-time Updates)   │
└─────────────────────────────────────────────────────────┘
```

### Color Coding
- **Green**: Healthy, within thresholds
- **Yellow**: Warning, attention needed
- **Red**: Error, immediate action required
- **Blue**: Information, neutral status
- **Gray**: Disabled or unavailable

### Interactive Elements
- **Feature Health Cards**: Click to drill down to feature details
- **Cost Charts**: Hover for detailed breakdowns
- **Activity Feed**: Click events for full error logs
- **Quick Actions**: One-click access to common tasks

## Implementation Guidelines

### File Structure
```
components/ai/management/dashboard/
├── DashboardContainer.tsx          # Main container component
├── DashboardHeader.tsx             # Header with status and actions
├── FeatureHealthGrid.tsx           # 2x2 grid of feature cards
├── FeatureHealthCard.tsx           # Individual feature status card
├── CostOverviewPanel.tsx           # Cost monitoring section
├── PerformanceMetricsPanel.tsx     # Performance stats section
├── ActivityFeed.tsx                # Real-time activity log
├── QuickActions.tsx                # Quick action buttons
└── hooks/
    ├── useDashboardData.tsx        # Data fetching logic
    ├── useRealTimeUpdates.tsx      # WebSocket connections
    └── useCostMonitoring.tsx       # Cost tracking logic
```

### Code Patterns

#### Data Fetching Pattern
```typescript
// Use React Query for caching and real-time updates
const useDashboardData = (organizationId: string) => {
  const { data: summary } = useQuery({
    queryKey: ['ai-summary', organizationId],
    queryFn: () => fetchAISummary(organizationId),
    refetchInterval: 30000, // 30 second updates
  });

  const { data: costs } = useQuery({
    queryKey: ['ai-costs', organizationId],
    queryFn: () => fetchCostAnalysis(organizationId),
    refetchInterval: 60000, // 1 minute updates
  });

  return { summary, costs, isLoading: !summary || !costs };
};
```

#### Error Handling Pattern
```typescript
const DashboardContainer = () => {
  const [error, setError] = useState<string | null>(null);
  
  const handleError = useCallback((error: Error) => {
    console.error('Dashboard error:', error);
    setError(error.message);
    // Optional: Send to error tracking service
  }, []);

  if (error) {
    return <DashboardErrorState error={error} onRetry={() => setError(null)} />;
  }

  return <DashboardContent onError={handleError} />;
};
```

### Performance Requirements
- **Initial Load**: < 2 seconds for all dashboard data
- **Real-time Updates**: 30-second refresh for metrics, 5-second for critical alerts
- **Memory Usage**: < 50MB for dashboard components
- **Network**: Efficient data fetching with caching

### Security Considerations
- All API calls include organization-level authentication
- Cost data requires admin permissions
- Error logs sanitized of sensitive information
- Real-time updates over secure WebSocket connections

## Testing Requirements

### Unit Tests
```typescript
// Test each component independently
describe('FeatureHealthCard', () => {
  it('displays correct status colors', () => {
    // Test green/yellow/red status indicators
  });
  
  it('shows accurate metrics', () => {
    // Test metric display and formatting
  });
  
  it('handles click events', () => {
    // Test drill-down navigation
  });
});
```

### Integration Tests
```typescript
// Test API integration
describe('Dashboard API Integration', () => {
  it('fetches all required data', () => {
    // Test all API endpoints return data
  });
  
  it('handles API errors gracefully', () => {
    // Test error states and fallbacks
  });
  
  it('updates data in real-time', () => {
    // Test WebSocket updates
  });
});
```

### Performance Tests
- Load testing with large datasets
- Memory leak detection during long sessions
- Network failure recovery testing

## Delivery Requirements

### Files to Create
1. **DashboardContainer.tsx** - Main entry point component
2. **Supporting Components** - All dashboard sections as specified
3. **Custom Hooks** - Data fetching and real-time update logic
4. **Types** - TypeScript interfaces for all data structures
5. **Styles** - CSS modules or styled-components for dashboard layout

### Documentation to Update
- Component documentation with props and usage examples
- API integration guide for dashboard endpoints
- Performance optimization notes

### Demo Scenarios
1. **Healthy System**: All features green, normal costs, steady processing
2. **Warning State**: One feature yellow, approaching cost limits
3. **Error State**: Feature down, high error rate, queue backing up
4. **Real-time Updates**: Show live data changes and alerts

### Handoff Requirements

#### To Agent 2 (Prompts)
- Dashboard includes "Quick Test Prompt" action buttons
- Feature health cards link to prompt management
- Error logs show prompt-related failures

#### To Agent 3 (Models)
- Dashboard shows model switching capabilities
- Provider status integrated into feature health
- Model performance metrics displayed

#### To Other Agents
- Dashboard provides entry points to all other management tools
- Consistent styling and interaction patterns established
- Real-time data sharing patterns documented

---

**Remember**: This dashboard is for developers managing AI systems. Every metric should help them make decisions about optimizing AI performance for end users. Focus on actionable information, not just pretty charts.