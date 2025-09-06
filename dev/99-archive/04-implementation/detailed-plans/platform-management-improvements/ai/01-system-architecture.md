# Platform AI Management System - Technical Architecture

## ⚠️ PLATFORM ADMIN INFRASTRUCTURE TOOL

**THIS IS INTERNAL PLATFORM ADMINISTRATION INFRASTRUCTURE**
- **Location**: `/app/platform/ai-management/` (existing platform admin area)
- **API Routes**: `/api/platform/ai-management/` (platform admin API endpoints)
- **Access Control**: Platform admin role validation required on all routes
- **Purpose**: Internal tool for platform team to manage AI infrastructure
- **Security**: All APIs validate `platform_admin` role before processing requests

## Architecture Overview

The improved **platform AI management system** follows a **feature-centric architecture** that consolidates scattered platform admin tools into a unified system for managing AI infrastructure. This system is used by platform administrators to manage the AI capabilities that end-users consume through the main Minerva application.

### Core Architectural Principles

1. **Feature-First Design**: All platform admin components organized around AI infrastructure management (Photo Tagging, Chatbot, AI Search infrastructure)
2. **Unified Data Layer**: Single source of truth for all AI infrastructure data and configurations
3. **Modular Components**: Loosely coupled platform admin services with proper access control
4. **Real-time Synchronization**: Live updates across platform admin views and components
5. **Scalable Infrastructure**: Designed to handle growing AI infrastructure management needs
6. **Platform Security**: All components validate platform admin access before processing

## System Components

### 1. Frontend Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Platform Admin React Application               │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌────────┐ │
│  │ Infrastructure │ AI Feature │ │   Model &   │ │ Prompt │ │
│  │  Overview   │ │ Management  │ │  Provider   │ │Library │ │
│  │  (Admin)    │ │ Dashboard   │ │ Management  │ │ (Admin)│ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └────────┘ │
│  ┌─────────────┐ ┌─────────────────────────────────────────┐ │
│  │Infrastructure│ │     Testing & Infrastructure           │ │
│  │Cost Analytics│ │         Experimentation                │ │
│  └─────────────┘ └─────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│             Platform Admin Component Library                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────────────┐ │
│  │ AI Infra │ │  Prompt  │ │ Platform │ │   Platform      │ │
│  │  Cards   │ │ Editor   │ │ Metrics  │ │   Navigation    │ │
│  └──────────┘ └──────────┘ └──────────┘ └─────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                State Management Layer                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   Zustand   │ │ TanStack    │ │    Platform Admin       │ │
│  │    Store    │ │   Query     │ │   WebSocket Client      │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

#### Frontend Components

**Core Platform Admin Views** (6 main views for infrastructure management):
- `InfrastructureOverviewApp` - Platform admin executive dashboard
- `AIFeatureManagementApp` - AI infrastructure feature management
- `ModelProviderApp` - MLOps and model infrastructure management
- `PromptLibraryApp` - Platform admin prompt engineering workspace
- `InfrastructureCostApp` - Infrastructure cost insights and controls
- `InfrastructureTestingApp` - Infrastructure testing and A/B experiments

**Platform Admin Component Library**:
- `AIInfrastructureCard` - Infrastructure component display
- `PlatformPromptEditor` - Platform admin prompt editor with validation
- `PlatformMetricsDashboard` - Infrastructure metrics visualization
- `PlatformNavigationShell` - Platform admin navigation and layout
- `InfrastructureToggle` - Infrastructure A/B testing controls

### 2. Backend Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Platform Admin API Gateway Layer               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │            Next.js API Routes (Edge Functions)          │ │
│  │       /api/platform/ai-management/[...params]          │ │
│  │         (with platform admin validation)               │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│               Platform Admin Business Logic                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │Infrastructure│ │    Model    │ │   Infrastructure        │ │
│  │  Management │ │Infrastructure│ │    Analytics            │ │
│  │   Service   │ │   Service   │ │     Service             │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   Prompt    │ │Infrastructure│ │   Infrastructure        │ │
│  │Infrastructure│ │Cost Tracking│ │     Testing             │ │
│  │   Service   │ │   Service   │ │     Service             │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│            Platform Admin Data Access Layer                 │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │            Supabase Client (with RLS)                   │ │
│  │    (PostgreSQL + Real-time + Platform Auth)            │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│            AI Provider Integrations (Managed)               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────────────┐ │
│  │ OpenAI   │ │ Google   │ │  Custom  │ │   Platform      │ │
│  │   API    │ │Cloud AI  │ │ Models   │ │   Analytics     │ │
│  └──────────┘ └──────────┘ └──────────┘ └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

#### Backend Services

**Core Services**:
- `FeatureManagementService` - Manages AI feature configurations and status
- `ModelManagementService` - Handles model lifecycle, deployment, and monitoring
- `PromptManagementService` - Version control and collaboration for prompts
- `SpendingTrackingService` - Real-time cost tracking and budget management
- `AnalyticsService` - Performance metrics and insights generation
- `TestingService` - A/B testing and experimentation management

**API Structure**:
```
/api/platform/ai-management/
├── /features/
│   ├── /photo-tagging/
│   │   ├── /config
│   │   ├── /metrics
│   │   └── /status
│   ├── /chatbot/
│   └── /ai-search/
├── /models/
│   ├── /providers/
│   ├── /deployments/
│   └── /performance/
├── /prompts/
│   ├── /library/
│   ├── /versions/
│   └── /testing/
├── /spending/
│   ├── /analytics/
│   ├── /budgets/
│   └── /optimization/
└── /testing/
    ├── /experiments/
    ├── /results/
    └── /configurations/

Note: All endpoints require platform_admin role validation
```

### 3. Database Architecture

#### New Database Schema

**Core Tables**:

```sql
-- AI Features Management
CREATE TABLE ai_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE, -- 'photo-tagging', 'chatbot', 'ai-search'
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'inactive', 'maintenance'
    config JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Models Management
CREATE TABLE ai_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    provider VARCHAR(100) NOT NULL, -- 'openai', 'google', 'custom'
    model_type VARCHAR(100) NOT NULL, -- 'llm', 'vision', 'embedding'
    version VARCHAR(50),
    config JSONB NOT NULL DEFAULT '{}',
    performance_metrics JSONB DEFAULT '{}',
    cost_per_token DECIMAL(10,8),
    status VARCHAR(20) DEFAULT 'available',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Feature-Model Relationships
CREATE TABLE feature_model_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    model_id UUID REFERENCES ai_models(id) ON DELETE CASCADE,
    environment VARCHAR(20) DEFAULT 'production', -- 'development', 'staging', 'production'
    is_active BOOLEAN DEFAULT false,
    config_overrides JSONB DEFAULT '{}',
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assigned_by UUID REFERENCES users(id),
    UNIQUE(feature_id, environment)
);

-- Prompt Management
CREATE TABLE ai_prompts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    content TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    feature_id UUID REFERENCES ai_features(id),
    tags TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT false,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Usage Tracking
CREATE TABLE ai_usage_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_id UUID REFERENCES ai_features(id),
    model_id UUID REFERENCES ai_models(id),
    prompt_id UUID REFERENCES ai_prompts(id),
    user_id UUID REFERENCES users(id),
    tokens_used INTEGER,
    response_time_ms INTEGER,
    cost_usd DECIMAL(10,6),
    status VARCHAR(20), -- 'success', 'error', 'timeout'
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spending Management
CREATE TABLE ai_spending_budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    feature_id UUID REFERENCES ai_features(id),
    period_type VARCHAR(20) NOT NULL, -- 'daily', 'weekly', 'monthly', 'quarterly'
    budget_amount DECIMAL(10,2) NOT NULL,
    alert_threshold DECIMAL(3,2) DEFAULT 0.8, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- A/B Testing
CREATE TABLE ai_experiments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    feature_id UUID REFERENCES ai_features(id),
    experiment_type VARCHAR(50), -- 'model_comparison', 'prompt_testing', 'parameter_tuning'
    config JSONB NOT NULL,
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'running', 'completed', 'cancelled'
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    results JSONB DEFAULT '{}',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Data Migration Strategy

**From Current Scattered Systems**:

1. **Platform Costs Data** → `ai_usage_logs` + `ai_spending_budgets`
2. **AI Management Settings** → `ai_features` + `feature_model_assignments`
3. **Debug AI Data** → `ai_usage_logs` (error tracking)
4. **Scattered Model Data** → `ai_models` (centralized catalog)

### 4. Real-time Architecture

#### WebSocket Integration

```typescript
// Real-time data synchronization
interface AIManagementWebSocket {
  // Feature status updates
  onFeatureStatusChange: (featureId: string, status: FeatureStatus) => void;
  
  // Live metrics updates
  onMetricsUpdate: (featureId: string, metrics: PerformanceMetrics) => void;
  
  // Spending alerts
  onSpendingAlert: (budgetId: string, alert: SpendingAlert) => void;
  
  // Model deployment updates
  onModelDeployment: (deploymentId: string, status: DeploymentStatus) => void;
  
  // Experiment results
  onExperimentUpdate: (experimentId: string, results: ExperimentResults) => void;
}
```

#### Event-Driven Updates

- **Feature Configuration Changes** → Broadcast to all connected clients
- **Model Performance Metrics** → Real-time dashboard updates
- **Spending Threshold Alerts** → Immediate notifications
- **A/B Test Results** → Live experiment monitoring

### 5. Security Architecture

#### Authentication & Authorization

```typescript
// Role-based access control
interface AIManagementRoles {
  'ai-admin': {
    permissions: ['manage-all-features', 'manage-budgets', 'manage-models'];
  };
  'ai-developer': {
    permissions: ['manage-assigned-features', 'edit-prompts', 'run-tests'];
    featureAccess: string[]; // Array of feature IDs
  };
  'ai-viewer': {
    permissions: ['view-metrics', 'view-configs'];
    featureAccess: string[];
  };
  'finance-manager': {
    permissions: ['view-spending', 'manage-budgets', 'view-analytics'];
  };
}
```

#### Data Protection

- **API Keys**: Encrypted storage in Supabase with rotation capabilities
- **Audit Logging**: All configuration changes tracked with user attribution
- **Rate Limiting**: Per-user and per-feature API rate limits
- **Data Encryption**: All sensitive data encrypted at rest and in transit
- **Platform Admin Access**: All routes validate `platform_admin` role before processing
- **Row Level Security**: Database policies enforce platform admin access controls

### 6. Performance Architecture

#### Caching Strategy

```typescript
// Multi-layer caching
interface CachingLayers {
  // Browser-level caching
  clientCache: {
    duration: '5m'; // Static configuration data
    keys: ['features', 'models', 'prompts'];
  };
  
  // API-level caching
  serverCache: {
    duration: '1m'; // Dynamic metrics data
    keys: ['metrics', 'usage', 'spending'];
  };
  
  // Database-level caching
  databaseCache: {
    duration: '15m'; // Historical analytics
    keys: ['analytics', 'reports'];
  };
}
```

#### Performance Targets

- **Initial Page Load**: < 2 seconds
- **View Transitions**: < 500ms
- **Real-time Updates**: < 100ms latency
- **API Response Time**: < 200ms (95th percentile)
- **Database Query Time**: < 50ms (average)

### 7. Monitoring & Observability

#### Metrics Collection

```typescript
// Key performance indicators
interface SystemMetrics {
  // System performance
  responseTime: number;
  errorRate: number;
  throughput: number;
  
  // Business metrics
  featureUsage: Record<string, number>;
  costPerFeature: Record<string, number>;
  userSatisfaction: number;
  
  // Technical metrics
  modelLatency: Record<string, number>;
  promptEffectiveness: Record<string, number>;
  experimentSuccessRate: number;
}
```

#### Alerting System

- **Performance Degradation**: Automatic alerts for slow response times
- **Error Rate Spikes**: Immediate notification of system errors
- **Budget Overruns**: Proactive spending alerts
- **Model Failures**: AI model availability monitoring

## Technology Stack

### Frontend
- **Framework**: React 18+ with TypeScript
- **State Management**: Zustand + TanStack Query
- **UI Components**: shadcn/ui + Tailwind CSS
- **Charts & Visualization**: Recharts + D3.js
- **Real-time**: WebSocket client with auto-reconnection

### Backend
- **Runtime**: Next.js 15+ API Routes (Edge Functions)
- **Database**: PostgreSQL via Supabase
- **Authentication**: Supabase Auth with RLS
- **File Storage**: Supabase Storage
- **Real-time**: Supabase Realtime

### Infrastructure
- **Hosting**: Vercel (Frontend + API)
- **Database**: Supabase (managed PostgreSQL)
- **CDN**: Vercel Edge Network
- **Monitoring**: PostHog + Vercel Analytics
- **CI/CD**: GitHub Actions

### External Services
- **AI Providers**: OpenAI, Google Cloud AI, Anthropic
- **Analytics**: PostHog
- **Error Tracking**: PostHog (error analysis)
- **Performance Monitoring**: Vercel Speed Insights

## Deployment Architecture

### Environment Strategy

```yaml
# Development Environment
development:
  database: Local Supabase instance
  ai_providers: Sandbox APIs with limited tokens
  caching: Disabled for development clarity
  monitoring: Development PostHog project
  access: Local platform admin accounts

# Staging Environment  
staging:
  database: Dedicated Supabase staging instance
  ai_providers: Production APIs with budget limits
  caching: Enabled with shorter TTLs
  monitoring: Staging PostHog project
  access: Platform admin role validation required

# Production Environment
production:
  database: Production Supabase instance with backups
  ai_providers: Production APIs with full access
  caching: Fully optimized with CDN
  monitoring: Production PostHog with alerting
  access: Strict platform admin authentication
```

### Rollout Strategy

1. **Phase 1**: Deploy with feature flags (10% internal users)
2. **Phase 2**: Gradual rollout (50% internal users)
3. **Phase 3**: Full internal deployment
4. **Phase 4**: External stakeholder access
5. **Phase 5**: Complete migration from old system

This architecture provides a solid foundation for the feature-centric AI management system while ensuring scalability, maintainability, and excellent developer experience.