# Chunk 3: Production Infrastructure Implementation

**Priority:** High (P1)  
**Estimated Effort:** 3-4 days  
**Dependencies:** None (can run parallel with Chunks 1 & 2)  
**Deliverable:** Production-ready monitoring and infrastructure

---

## 📋 Overview

Chunk 3 establishes the essential production infrastructure required for reliable operation, cost control, and issue diagnosis. This foundation is critical for production deployment and ongoing maintenance.

### Business Context
- Production systems require comprehensive monitoring for reliability
- Google Cloud Vision API costs must be controlled and monitored
- Database schema inconsistencies must be resolved for full feature functionality
- Error tracking is essential for user support and system improvement

---

## 🎯 Scope & Deliverables

### 1. Error Monitoring & Alerting
**Status:** Missing (critical for production)  
**Effort:** 1 day  
**Files to Create/Modify:**
- `lib/monitoring/error-tracking.ts` (new)
- `lib/monitoring/sentry-config.ts` (new)
- `app/layout.tsx` (modify for Sentry integration)

### 2. API Cost Monitoring
**Status:** Missing (critical for budget control)  
**Effort:** 1 day  
**Files to Create/Modify:**
- `lib/monitoring/cost-tracking.ts` (new)
- `app/api/monitoring/costs/route.ts` (new)
- `components/admin/cost-dashboard.tsx` (new)

### 3. Database Schema Synchronization
**Status:** Inconsistent (affects AI features)  
**Effort:** 1 day  
**Files to Create/Modify:**
- `supabase/migrations/20250714000000_ai_tables.sql` (new)
- `types/database.ts` (verify/update)
- Database function migrations

### 4. Performance Monitoring
**Status:** Basic implementation needed  
**Effort:** 1 day  
**Files to Create/Modify:**
- `lib/monitoring/performance.ts` (new)
- `components/admin/performance-dashboard.tsx` (new)
- Performance alerting system

---

## 🔧 Technical Specifications

### 1. Error Monitoring & Alerting Implementation

#### Architecture Overview
```typescript
// lib/monitoring/error-tracking.ts
interface ErrorContext {
  userId?: string;
  organizationId?: string;
  userAgent?: string;
  url?: string;
  timestamp: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  component?: string;
  action?: string;
}

interface ErrorMetadata {
  photoId?: string;
  uploadSessionId?: string;
  searchQuery?: string;
  apiEndpoint?: string;
  errorCode?: string;
}

export class ErrorTrackingService {
  static captureError(error: Error, context: ErrorContext, metadata?: ErrorMetadata): void
  static captureMessage(message: string, level: 'info' | 'warning' | 'error'): void
  static setUserContext(user: { id: string; organizationId: string }): void
  static addBreadcrumb(message: string, category: string, data?: Record<string, any>): void
}
```

#### Sentry Integration
```typescript
// lib/monitoring/sentry-config.ts
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  
  beforeSend(event, hint) {
    // Filter out sensitive information
    if (event.user) {
      delete event.user.email;
    }
    
    // Add organization context
    if (event.tags) {
      event.tags.organization = getCurrentOrganizationId();
    }
    
    return event;
  },
  
  integrations: [
    new Sentry.BrowserTracing({
      tracePropagationTargets: [
        'localhost',
        /^https:\/\/minerva-app\.vercel\.app/,
      ],
    }),
  ],
});
```

#### Error Handling Patterns
```typescript
// Standardized error handling across the application
export function withErrorHandling<T extends any[], R>(
  fn: (...args: T) => Promise<R>,
  component: string,
  action: string
) {
  return async (...args: T): Promise<R> => {
    try {
      return await fn(...args);
    } catch (error) {
      ErrorTrackingService.captureError(error as Error, {
        component,
        action,
        severity: 'high',
        timestamp: new Date().toISOString(),
      });
      throw error;
    }
  };
}

// API route error handling
export function handleApiError(error: unknown, req: NextRequest): NextResponse {
  const errorId = crypto.randomUUID();
  
  ErrorTrackingService.captureError(error as Error, {
    severity: 'high',
    url: req.url,
    timestamp: new Date().toISOString(),
    component: 'api',
    action: req.method,
  }, {
    errorCode: errorId,
  });
  
  return NextResponse.json(
    { error: 'Internal server error', errorId },
    { status: 500 }
  );
}
```

### 2. API Cost Monitoring Implementation

#### Architecture Overview
```typescript
// lib/monitoring/cost-tracking.ts
interface ApiCostMetrics {
  date: string;
  service: 'google_vision' | 'supabase' | 'vercel';
  operation: string;
  requestCount: number;
  estimatedCost: number;
  organizationId: string;
}

interface CostAlert {
  id: string;
  type: 'daily_limit' | 'monthly_limit' | 'spike_detection';
  threshold: number;
  currentValue: number;
  organizationId: string;
  createdAt: string;
}

export class CostTrackingService {
  static async trackApiCall(
    service: string,
    operation: string,
    organizationId: string,
    estimatedCost: number
  ): Promise<void>
  
  static async getDailyCosts(organizationId: string, days: number = 30): Promise<ApiCostMetrics[]>
  static async checkCostLimits(organizationId: string): Promise<CostAlert[]>
  static async createCostAlert(alert: Omit<CostAlert, 'id' | 'createdAt'>): Promise<void>
}
```

#### Google Cloud Vision Cost Tracking
```typescript
// Enhanced AI processing with cost tracking
export async function processPhotoWithCostTracking(
  photoId: string,
  imageUrl: string,
  organizationId: string
): Promise<void> {
  const startTime = Date.now();
  
  try {
    // Check cost limits before processing
    const costAlerts = await CostTrackingService.checkCostLimits(organizationId);
    const hasCriticalAlert = costAlerts.some(alert => 
      alert.type === 'daily_limit' && alert.currentValue >= alert.threshold
    );
    
    if (hasCriticalAlert) {
      throw new Error('Daily API cost limit exceeded');
    }
    
    // Process photo
    const result = await processPhotoWithGoogleVision(imageUrl);
    
    // Track successful API call
    await CostTrackingService.trackApiCall(
      'google_vision',
      'image_analysis',
      organizationId,
      calculateVisionApiCost(result)
    );
    
  } catch (error) {
    // Track failed API call (still costs money)
    await CostTrackingService.trackApiCall(
      'google_vision',
      'image_analysis_failed',
      organizationId,
      0.001 // Minimal cost for failed request
    );
    
    throw error;
  }
}

function calculateVisionApiCost(result: any): number {
  // Google Vision API pricing calculation
  const baseCost = 0.0015; // $1.50 per 1000 images
  let multiplier = 1;
  
  // Additional features increase cost
  if (result.textDetection) multiplier += 0.5;
  if (result.objectLocalization) multiplier += 0.5;
  
  return baseCost * multiplier;
}
```

#### Cost Dashboard Implementation
```typescript
// components/admin/cost-dashboard.tsx
interface CostDashboardProps {
  organizationId: string;
}

export function CostDashboard({ organizationId }: CostDashboardProps) {
  const [costData, setCostData] = useState<ApiCostMetrics[]>([]);
  const [alerts, setAlerts] = useState<CostAlert[]>([]);
  
  // Real-time cost monitoring
  useEffect(() => {
    const fetchCostData = async () => {
      const [costs, currentAlerts] = await Promise.all([
        CostTrackingService.getDailyCosts(organizationId, 30),
        CostTrackingService.checkCostLimits(organizationId)
      ]);
      
      setCostData(costs);
      setAlerts(currentAlerts);
    };
    
    fetchCostData();
    const interval = setInterval(fetchCostData, 300000); // Every 5 minutes
    
    return () => clearInterval(interval);
  }, [organizationId]);
  
  return (
    <div className="space-y-6">
      {/* Cost alerts */}
      {alerts.length > 0 && (
        <Alert variant="destructive">
          <AlertTriangle className="h-4 w-4" />
          <AlertTitle>Cost Alerts</AlertTitle>
          <AlertDescription>
            {alerts.map(alert => (
              <div key={alert.id}>
                {alert.type}: ${alert.currentValue.toFixed(2)} / ${alert.threshold.toFixed(2)}
              </div>
            ))}
          </AlertDescription>
        </Alert>
      )}
      
      {/* Cost charts and metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <CostMetricCard title="Today's Costs" value={getTodaysCosts(costData)} />
        <CostMetricCard title="Monthly Costs" value={getMonthlyCosts(costData)} />
        <CostMetricCard title="API Calls" value={getTotalApiCalls(costData)} />
      </div>
      
      <CostChart data={costData} />
    </div>
  );
}
```

### 3. Database Schema Synchronization

#### Missing Database Tables Migration
```sql
-- supabase/migrations/20250714000000_ai_tables.sql

-- AI processing results table (referenced in code but missing)
CREATE TABLE ai_processing_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID REFERENCES photos(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  processing_type TEXT NOT NULL CHECK (processing_type IN ('initial', 'reprocessing', 'correction')),
  ai_provider TEXT NOT NULL DEFAULT 'google_vision',
  raw_response JSONB NOT NULL,
  confidence_scores JSONB DEFAULT '{}',
  processing_time_ms INTEGER,
  api_cost_usd DECIMAL(10,6),
  error_message TEXT,
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  created_at TIMESTAMP DEFAULT NOW(),
  processed_at TIMESTAMP
);

-- AI corrections table (referenced in code but missing)
CREATE TABLE ai_corrections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID REFERENCES photos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  correction_type TEXT NOT NULL CHECK (correction_type IN ('tag_added', 'tag_removed', 'tag_modified', 'description_edited', 'suggestion_accepted', 'suggestion_rejected')),
  original_value JSONB,
  corrected_value JSONB,
  ai_confidence DECIMAL(3,2),
  user_confidence TEXT CHECK (user_confidence IN ('low', 'medium', 'high')),
  context_data JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

-- AI cost tracking table (referenced in code but missing)
CREATE TABLE ai_cost_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  service_name TEXT NOT NULL,
  operation_type TEXT NOT NULL,
  request_count INTEGER DEFAULT 1,
  cost_usd DECIMAL(10,6) NOT NULL,
  billing_date DATE DEFAULT CURRENT_DATE,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

-- AI processing errors table (referenced in code but missing)
CREATE TABLE ai_processing_errors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID REFERENCES photos(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  error_type TEXT NOT NULL,
  error_message TEXT NOT NULL,
  error_details JSONB DEFAULT '{}',
  retry_count INTEGER DEFAULT 0,
  resolved_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_ai_processing_results_photo_id ON ai_processing_results(photo_id);
CREATE INDEX idx_ai_processing_results_organization_id ON ai_processing_results(organization_id);
CREATE INDEX idx_ai_processing_results_created_at ON ai_processing_results(created_at DESC);

CREATE INDEX idx_ai_corrections_photo_id ON ai_corrections(photo_id);
CREATE INDEX idx_ai_corrections_user_id ON ai_corrections(user_id);
CREATE INDEX idx_ai_corrections_organization_id ON ai_corrections(organization_id);
CREATE INDEX idx_ai_corrections_correction_type ON ai_corrections(correction_type);
CREATE INDEX idx_ai_corrections_created_at ON ai_corrections(created_at DESC);

CREATE INDEX idx_ai_cost_tracking_organization_id ON ai_cost_tracking(organization_id);
CREATE INDEX idx_ai_cost_tracking_billing_date ON ai_cost_tracking(billing_date DESC);
CREATE INDEX idx_ai_cost_tracking_service_name ON ai_cost_tracking(service_name);

CREATE INDEX idx_ai_processing_errors_photo_id ON ai_processing_errors(photo_id);
CREATE INDEX idx_ai_processing_errors_organization_id ON ai_processing_errors(organization_id);
CREATE INDEX idx_ai_processing_errors_error_type ON ai_processing_errors(error_type);
CREATE INDEX idx_ai_processing_errors_created_at ON ai_processing_errors(created_at DESC);

-- Row Level Security policies
ALTER TABLE ai_processing_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_corrections ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_cost_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_processing_errors ENABLE ROW LEVEL SECURITY;

-- RLS policies for organization isolation
CREATE POLICY "ai_processing_results_organization_access" 
  ON ai_processing_results FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY "ai_corrections_organization_access" 
  ON ai_corrections FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY "ai_cost_tracking_organization_access" 
  ON ai_cost_tracking FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY "ai_processing_errors_organization_access" 
  ON ai_processing_errors FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

-- Functions for AI analytics (referenced in code)
CREATE OR REPLACE FUNCTION get_ai_accuracy_metrics(p_organization_id UUID, p_days INTEGER DEFAULT 30)
RETURNS TABLE (
  date DATE,
  total_corrections INTEGER,
  accuracy_score DECIMAL,
  confidence_trend DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    DATE(ac.created_at) as date,
    COUNT(*)::INTEGER as total_corrections,
    (1.0 - COUNT(CASE WHEN ac.correction_type IN ('tag_removed', 'tag_modified', 'suggestion_rejected') THEN 1 END)::DECIMAL / COUNT(*)) as accuracy_score,
    AVG(ac.ai_confidence) as confidence_trend
  FROM ai_corrections ac
  WHERE ac.organization_id = p_organization_id
    AND ac.created_at >= CURRENT_DATE - INTERVAL '%s days' % p_days
  GROUP BY DATE(ac.created_at)
  ORDER BY date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function for cost analysis
CREATE OR REPLACE FUNCTION get_cost_analysis(p_organization_id UUID, p_days INTEGER DEFAULT 30)
RETURNS TABLE (
  service_name TEXT,
  total_cost DECIMAL,
  request_count BIGINT,
  avg_cost_per_request DECIMAL,
  cost_trend DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    act.service_name,
    SUM(act.cost_usd) as total_cost,
    SUM(act.request_count) as request_count,
    AVG(act.cost_usd / act.request_count) as avg_cost_per_request,
    (SUM(CASE WHEN act.billing_date >= CURRENT_DATE - 7 THEN act.cost_usd ELSE 0 END) / 
     NULLIF(SUM(CASE WHEN act.billing_date < CURRENT_DATE - 7 THEN act.cost_usd ELSE 0 END), 0)) as cost_trend
  FROM ai_cost_tracking act
  WHERE act.organization_id = p_organization_id
    AND act.billing_date >= CURRENT_DATE - p_days
  GROUP BY act.service_name
  ORDER BY total_cost DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 4. Performance Monitoring Implementation

#### Architecture Overview
```typescript
// lib/monitoring/performance.ts
interface PerformanceMetric {
  metric: string;
  value: number;
  unit: string;
  timestamp: string;
  tags: Record<string, string>;
}

interface PerformanceThreshold {
  metric: string;
  warning: number;
  critical: number;
  unit: string;
}

export class PerformanceMonitoringService {
  static trackMetric(metric: string, value: number, unit: string, tags?: Record<string, string>): void
  static trackDuration<T>(name: string, operation: () => Promise<T>): Promise<T>
  static getMetrics(timeRange: string): Promise<PerformanceMetric[]>
  static checkThresholds(): Promise<PerformanceThreshold[]>
}
```

#### Key Performance Metrics
```typescript
// Performance tracking implementation
const PERFORMANCE_THRESHOLDS: PerformanceThreshold[] = [
  { metric: 'search_response_time', warning: 500, critical: 1000, unit: 'ms' },
  { metric: 'upload_processing_time', warning: 30000, critical: 60000, unit: 'ms' },
  { metric: 'ai_processing_time', warning: 10000, critical: 30000, unit: 'ms' },
  { metric: 'page_load_time', warning: 3000, critical: 5000, unit: 'ms' },
  { metric: 'api_response_time', warning: 200, critical: 500, unit: 'ms' },
];

// Enhanced search with performance tracking
export async function searchPhotosWithMetrics(
  params: SearchParams,
  organizationId: string
): Promise<SearchResults> {
  return PerformanceMonitoringService.trackDuration('search_photos', async () => {
    const startTime = Date.now();
    
    try {
      const results = await searchService.searchPhotos(params);
      
      // Track successful search
      PerformanceMonitoringService.trackMetric(
        'search_response_time',
        Date.now() - startTime,
        'ms',
        {
          organization_id: organizationId,
          result_count: results.totalCount.toString(),
          has_query: Boolean(params.query).toString(),
        }
      );
      
      return results;
    } catch (error) {
      // Track failed search
      PerformanceMonitoringService.trackMetric(
        'search_error_rate',
        1,
        'count',
        { organization_id: organizationId, error: error.message }
      );
      
      throw error;
    }
  });
}
```

---

## 🧪 Testing Strategy

### Infrastructure Tests

**1. Error Tracking:**
```typescript
// __tests__/lib/monitoring/error-tracking.test.ts
describe('ErrorTrackingService', () => {
  test('captures errors with context');
  test('filters sensitive information');
  test('adds organization context');
  test('handles breadcrumbs correctly');
});
```

**2. Cost Monitoring:**
```typescript
// __tests__/lib/monitoring/cost-tracking.test.ts
describe('CostTrackingService', () => {
  test('tracks API costs accurately');
  test('detects cost limit violations');
  test('calculates daily/monthly totals');
  test('generates cost alerts');
});
```

**3. Performance Monitoring:**
```typescript
// __tests__/lib/monitoring/performance.test.ts
describe('PerformanceMonitoringService', () => {
  test('tracks metrics correctly');
  test('measures operation duration');
  test('detects threshold violations');
  test('aggregates metrics properly');
});
```

### Database Migration Tests

```typescript
// __tests__/database/migrations.test.ts
describe('Database Migrations', () => {
  test('creates all AI tables correctly');
  test('applies RLS policies properly');
  test('creates indexes for performance');
  test('functions work as expected');
});
```

---

## 📊 Acceptance Criteria

### Monitoring Requirements

**✅ Error Tracking:**
- [ ] Captures all application errors with context
- [ ] Filters sensitive information from logs
- [ ] Provides real-time error alerts
- [ ] Integrates with Sentry for advanced features
- [ ] Maintains error history and trends

**✅ Cost Monitoring:**
- [ ] Tracks all API costs in real-time
- [ ] Sends alerts when limits are approached
- [ ] Provides cost breakdown by service
- [ ] Prevents processing when limits exceeded
- [ ] Generates cost reports and forecasts

**✅ Performance Monitoring:**
- [ ] Tracks key performance metrics
- [ ] Provides performance trend analysis
- [ ] Alerts on threshold violations
- [ ] Integrates with application monitoring
- [ ] Supports performance debugging

### Database Requirements

**✅ Schema Synchronization:**
- [ ] All referenced tables exist and are functional
- [ ] RLS policies protect organization data
- [ ] Indexes provide optimal query performance
- [ ] Functions support application features
- [ ] Migration is reversible and safe

---

## 🚀 Implementation Timeline

### Day 1: Error Monitoring
- Set up Sentry integration
- Implement error tracking service
- Add error handling to critical paths
- Create error dashboard

### Day 2: Cost Monitoring
- Implement cost tracking service
- Add cost monitoring to AI processing
- Create cost dashboard and alerts
- Set up billing notifications

### Day 3: Database Synchronization
- Create and test migration files
- Verify all table references work
- Test RLS policies and functions
- Update type definitions

### Day 4: Performance Monitoring
- Implement performance tracking
- Add metrics to critical operations
- Create performance dashboard
- Set up alerting thresholds

---

## 🔍 Risk Assessment

### High Risk
- **Migration Safety**: Database migrations could affect existing data
  - *Mitigation*: Thorough testing in staging environment
- **Cost Overruns**: Monitoring setup could increase costs
  - *Mitigation*: Conservative alert thresholds and monitoring

### Medium Risk
- **Performance Impact**: Monitoring could slow down operations
  - *Mitigation*: Asynchronous tracking and minimal overhead
- **Alert Fatigue**: Too many alerts could be ignored
  - *Mitigation*: Careful threshold tuning and alert prioritization

---

**Next Steps:** Begin with error monitoring setup as it provides immediate value for debugging and production support.