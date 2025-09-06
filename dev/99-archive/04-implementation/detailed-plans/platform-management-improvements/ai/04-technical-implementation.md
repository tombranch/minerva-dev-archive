# Platform AI Management System - Technical Implementation Guide

## ⚠️ PLATFORM ADMIN INFRASTRUCTURE TOOL

**THIS IS INTERNAL PLATFORM ADMINISTRATION INFRASTRUCTURE**
- **Target**: Platform administrators, AI engineers, DevOps teams ONLY
- **Location**: `/app/platform/ai-management/` (existing platform admin area)
- **API Routes**: `/api/platform/ai-management/` (platform admin API endpoints)
- **Access Control**: Platform admin role required (`platform_admin` in user_profiles table)
- **Purpose**: Internal tool for platform team to manage AI infrastructure
- **NOT**: A feature for Minerva app users or organization admins

## Implementation Overview

This document provides detailed technical specifications for implementing the feature-centric platform AI management system redesign, including backend APIs, frontend components, database schemas, and integration patterns for internal platform administration.

---

## Backend Implementation

### API Architecture

#### RESTful API Design
```typescript
// Base API structure - Platform Admin Only
const API_BASE = '/api/platform/ai-management';

interface APIEndpoints {
  // Feature Management
  features: {
    list: 'GET /features';
    get: 'GET /features/:id';
    update: 'PUT /features/:id';
    metrics: 'GET /features/:id/metrics';
    status: 'GET /features/:id/status';
  };
  
  // Model Management
  models: {
    list: 'GET /models';
    get: 'GET /models/:id';
    create: 'POST /models';
    update: 'PUT /models/:id';
    delete: 'DELETE /models/:id';
    deploy: 'POST /models/:id/deploy';
    performance: 'GET /models/:id/performance';
  };
  
  // Provider Management
  providers: {
    list: 'GET /providers';
    get: 'GET /providers/:id';
    create: 'POST /providers';
    update: 'PUT /providers/:id';
    healthCheck: 'GET /providers/:id/health';
    models: 'GET /providers/:id/models';
  };
  
  // Prompt Management
  prompts: {
    list: 'GET /prompts';
    get: 'GET /prompts/:id';
    create: 'POST /prompts';
    update: 'PUT /prompts/:id';
    versions: 'GET /prompts/:id/versions';
    test: 'POST /prompts/:id/test';
  };
  
  // Analytics & Spending
  analytics: {
    spending: 'GET /analytics/spending';
    usage: 'GET /analytics/usage';
    performance: 'GET /analytics/performance';
    budgets: 'GET /analytics/budgets';
    alerts: 'GET /analytics/alerts';
  };
  
  // Testing & Experiments
  testing: {
    experiments: 'GET /experiments';
    create: 'POST /experiments';
    results: 'GET /experiments/:id/results';
    testCases: 'GET /test-cases';
    execute: 'POST /test-cases/execute';
  };
}
```

#### API Route Implementation (Next.js)

```typescript
// app/api/platform/ai-management/features/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { FeatureManagementService } from '@/lib/services/platform/feature-management';
import { validatePlatformAdminAccess } from '@/lib/auth/platform-admin';

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Validate platform admin access
    const hasAccess = await validatePlatformAdminAccess(supabase, user.id);
    if (!hasAccess) {
      return NextResponse.json({ error: 'Platform admin access required' }, { status: 403 });
    }

    const service = new FeatureManagementService(supabase);
    const features = await service.listFeatures();
    
    return NextResponse.json({ data: features });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' }, 
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Validate platform admin access
    const hasAccess = await validatePlatformAdminAccess(supabase, user.id);
    if (!hasAccess) {
      return NextResponse.json({ error: 'Platform admin access required' }, { status: 403 });
    }

    const body = await request.json();
    const service = new FeatureManagementService(supabase);
    const feature = await service.createFeature(body);
    
    return NextResponse.json({ data: feature }, { status: 201 });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' }, 
      { status: 500 }
    );
  }
}
```

### Service Layer Implementation

#### Feature Management Service
```typescript
// lib/services/platform/feature-management.ts
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '@/lib/types/database';

export class FeatureManagementService {
  constructor(private supabase: SupabaseClient<Database>) {}

  async listFeatures() {
    const { data, error } = await this.supabase
      .from('ai_features')
      .select(`
        *,
        feature_model_assignments!inner(
          model:ai_models(*)
        ),
        ai_usage_logs(
          id,
          tokens_used,
          cost_usd,
          status,
          created_at
        )
      `)
      .eq('feature_model_assignments.is_active', true)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }

  async getFeatureMetrics(featureId: string, timeRange: string = '24h') {
    const startDate = this.getStartDate(timeRange);
    
    const { data, error } = await this.supabase
      .from('ai_usage_logs')
      .select('*')
      .eq('feature_id', featureId)
      .gte('created_at', startDate.toISOString());

    if (error) throw error;

    return this.calculateMetrics(data);
  }

  private calculateMetrics(usageLogs: any[]) {
    const totalRequests = usageLogs.length;
    const successfulRequests = usageLogs.filter(log => log.status === 'success').length;
    const totalCost = usageLogs.reduce((sum, log) => sum + (log.cost_usd || 0), 0);
    const averageResponseTime = usageLogs.reduce((sum, log) => sum + (log.response_time_ms || 0), 0) / totalRequests;

    return {
      totalRequests,
      successRate: totalRequests > 0 ? (successfulRequests / totalRequests) * 100 : 0,
      totalCost,
      averageResponseTime,
      errorRate: totalRequests > 0 ? ((totalRequests - successfulRequests) / totalRequests) * 100 : 0
    };
  }

  private getStartDate(timeRange: string): Date {
    const now = new Date();
    switch (timeRange) {
      case '1h': return new Date(now.getTime() - 60 * 60 * 1000);
      case '24h': return new Date(now.getTime() - 24 * 60 * 60 * 1000);
      case '7d': return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      case '30d': return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      default: return new Date(now.getTime() - 24 * 60 * 60 * 1000);
    }
  }
}
```

#### Model Management Service
```typescript
// lib/services/platform/model-management.ts
export class ModelManagementService {
  constructor(private supabase: SupabaseClient<Database>) {}

  async deployModel(modelId: string, featureId: string, environment: string = 'production') {
    const { data: deployment, error } = await this.supabase
      .from('feature_model_assignments')
      .upsert({
        feature_id: featureId,
        model_id: modelId,
        environment,
        is_active: true,
        assigned_at: new Date().toISOString(),
        assigned_by: (await this.supabase.auth.getUser()).data.user?.id
      })
      .select('*')
      .single();

    if (error) throw error;

    // Deactivate previous deployment
    await this.supabase
      .from('feature_model_assignments')
      .update({ is_active: false })
      .eq('feature_id', featureId)
      .eq('environment', environment)
      .neq('id', deployment.id);

    // Log deployment event
    await this.logDeploymentEvent(deployment);

    return deployment;
  }

  async compareModels(modelIds: string[], testCases: any[]) {
    const results = await Promise.all(
      modelIds.map(async (modelId) => {
        const model = await this.getModel(modelId);
        const testResults = await this.runTestCases(model, testCases);
        return {
          modelId,
          model,
          results: testResults
        };
      })
    );

    return this.generateComparisonReport(results);
  }

  private async logDeploymentEvent(deployment: any) {
    // Implementation for logging deployment events
    // This could integrate with external monitoring services
  }
}
```

### Real-time Functionality

#### WebSocket Integration
```typescript
// lib/services/realtime-service.ts
import { createClient, SupabaseClient } from '@supabase/supabase-js';

export class RealtimeService {
  private supabase: SupabaseClient;
  private channels: Map<string, any> = new Map();

  constructor() {
    this.supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    );
  }

  subscribeToFeatureMetrics(featureId: string, callback: (payload: any) => void) {
    const channelName = `feature-metrics-${featureId}`;
    
    if (this.channels.has(channelName)) {
      return this.channels.get(channelName);
    }

    const channel = this.supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'ai_usage_logs',
          filter: `feature_id=eq.${featureId}`
        },
        callback
      )
      .subscribe();

    this.channels.set(channelName, channel);
    return channel;
  }

  subscribeToSpendingAlerts(callback: (payload: any) => void) {
    const channelName = 'spending-alerts';
    
    const channel = this.supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'ai_spending_budgets'
        },
        (payload) => {
          if (this.shouldTriggerAlert(payload)) {
            callback(payload);
          }
        }
      )
      .subscribe();

    this.channels.set(channelName, channel);
    return channel;
  }

  private shouldTriggerAlert(payload: any): boolean {
    // Logic to determine if a spending alert should be triggered
    return true; // Simplified for example
  }

  unsubscribe(channelName: string) {
    const channel = this.channels.get(channelName);
    if (channel) {
      this.supabase.removeChannel(channel);
      this.channels.delete(channelName);
    }
  }
}
```

---

## Frontend Implementation

### Component Architecture

#### Global Overview Component
```typescript
// components/views/GlobalOverview.tsx
import React, { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { SpendingOverviewCard } from '@/components/spending/SpendingOverviewCard';
import { FeatureHealthGrid } from '@/components/features/FeatureHealthGrid';
import { ActivityFeed } from '@/components/activity/ActivityFeed';

export function GlobalOverview() {
  const { data: overviewData, isLoading } = useQuery({
    queryKey: ['global-overview'],
    queryFn: fetchGlobalOverview,
    refetchInterval: 30000 // Refresh every 30 seconds
  });

  if (isLoading) {
    return <GlobalOverviewSkeleton />;
  }

  return (
    <div className="space-y-6">
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <SpendingOverviewCard data={overviewData.spending} />
        <FeatureHealthGrid features={overviewData.features} />
        <div className="lg:col-span-1">
          <Card>
            <CardHeader>
              <CardTitle>Active Models</CardTitle>
            </CardHeader>
            <CardContent>
              <ModelProviderSummary providers={overviewData.providers} />
            </CardContent>
          </Card>
        </div>
      </div>
      
      <div className="grid gap-6 lg:grid-cols-2">
        <PerformanceKPIs metrics={overviewData.kpis} />
        <ActivityFeed activities={overviewData.activities} />
      </div>
    </div>
  );
}

async function fetchGlobalOverview() {
  const response = await fetch('/api/platform/ai-management/overview');
  if (!response.ok) throw new Error('Failed to fetch overview');
  return response.json();
}
```

#### Feature-Specific Dashboard
```typescript
// components/views/FeatureDashboard.tsx
import React, { useState } from 'react';
import { useParams } from 'next/navigation';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { FeatureSelector } from '@/components/features/FeatureSelector';
import { ModelManagement } from '@/components/models/ModelManagement';
import { PromptLibrary } from '@/components/prompts/PromptLibrary';
import { TestingPlayground } from '@/components/testing/TestingPlayground';

export function FeatureDashboard() {
  const params = useParams();
  const [selectedFeature, setSelectedFeature] = useState(params.feature as string);

  return (
    <div className="space-y-6">
      <FeatureSelector 
        selectedFeature={selectedFeature}
        onFeatureChange={setSelectedFeature}
      />
      
      <Tabs defaultValue="overview" className="space-y-6">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="models">Models</TabsTrigger>
          <TabsTrigger value="prompts">Prompts</TabsTrigger>
          <TabsTrigger value="testing">Testing</TabsTrigger>
        </TabsList>
        
        <TabsContent value="overview" className="space-y-4">
          <FeatureOverview featureId={selectedFeature} />
        </TabsContent>
        
        <TabsContent value="models" className="space-y-4">
          <ModelManagement featureId={selectedFeature} />
        </TabsContent>
        
        <TabsContent value="prompts" className="space-y-4">
          <PromptLibrary featureId={selectedFeature} />
        </TabsContent>
        
        <TabsContent value="testing" className="space-y-4">
          <TestingPlayground featureId={selectedFeature} />
        </TabsContent>
      </Tabs>
    </div>
  );
}
```

#### AI Model Card Component
```typescript
// components/models/AIModelCard.tsx
import React from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';
import { MoreHorizontal, Play, Settings, TrendingUp } from 'lucide-react';

interface AIModelCardProps {
  model: {
    id: string;
    name: string;
    provider: string;
    status: 'active' | 'inactive' | 'error';
    metrics: {
      averageLatency: number;
      successRate: number;
      cost: number;
    };
    lastDeployed?: Date;
  };
  variant?: 'default' | 'compact' | 'detailed';
  onDeploy?: (modelId: string) => void;
  onConfigure?: (modelId: string) => void;
  onViewMetrics?: (modelId: string) => void;
}

export function AIModelCard({ 
  model, 
  variant = 'default',
  onDeploy,
  onConfigure,
  onViewMetrics 
}: AIModelCardProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800';
      case 'inactive': return 'bg-gray-100 text-gray-800';
      case 'error': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <Card className="hover:shadow-md transition-shadow">
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{model.name}</CardTitle>
        <div className="flex items-center space-x-2">
          <Badge className={getStatusColor(model.status)}>
            {model.status}
          </Badge>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="sm">
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => onDeploy?.(model.id)}>
                <Play className="mr-2 h-4 w-4" />
                Deploy
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => onConfigure?.(model.id)}>
                <Settings className="mr-2 h-4 w-4" />
                Configure
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => onViewMetrics?.(model.id)}>
                <TrendingUp className="mr-2 h-4 w-4" />
                View Metrics
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardHeader>
      
      <CardContent>
        <div className="text-xs text-muted-foreground mb-2">
          {model.provider}
        </div>
        
        {variant !== 'compact' && (
          <div className="grid grid-cols-3 gap-2 text-sm">
            <div>
              <div className="text-xs text-muted-foreground">Latency</div>
              <div className="font-medium">{model.metrics.averageLatency}ms</div>
            </div>
            <div>
              <div className="text-xs text-muted-foreground">Success Rate</div>
              <div className="font-medium">{model.metrics.successRate}%</div>
            </div>
            <div>
              <div className="text-xs text-muted-foreground">Cost</div>
              <div className="font-medium">${model.metrics.cost}</div>
            </div>
          </div>
        )}
        
        {variant === 'detailed' && model.lastDeployed && (
          <div className="mt-2 text-xs text-muted-foreground">
            Last deployed: {model.lastDeployed.toLocaleDateString()}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
```

### State Management

#### Zustand Store Implementation
```typescript
// lib/store/ai-management-store.ts
import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';

interface AIManagementState {
  // Current selections
  selectedFeature: string | null;
  selectedModel: string | null;
  selectedExperiment: string | null;
  
  // Data
  features: any[];
  models: any[];
  providers: any[];
  experiments: any[];
  
  // UI state
  sidebarCollapsed: boolean;
  activeView: string;
  notifications: any[];
  
  // Actions
  setSelectedFeature: (featureId: string) => void;
  setSelectedModel: (modelId: string) => void;
  addNotification: (notification: any) => void;
  removeNotification: (id: string) => void;
  toggleSidebar: () => void;
  
  // Data actions
  updateFeature: (feature: any) => void;
  updateModel: (model: any) => void;
  addExperiment: (experiment: any) => void;
}

export const useAIManagementStore = create<AIManagementState>()(
  subscribeWithSelector((set, get) => ({
    // Initial state
    selectedFeature: null,
    selectedModel: null,
    selectedExperiment: null,
    features: [],
    models: [],
    providers: [],
    experiments: [],
    sidebarCollapsed: false,
    activeView: 'overview',
    notifications: [],
    
    // Actions
    setSelectedFeature: (featureId) => set({ selectedFeature: featureId }),
    setSelectedModel: (modelId) => set({ selectedModel: modelId }),
    
    addNotification: (notification) => 
      set((state) => ({ 
        notifications: [...state.notifications, { 
          id: Date.now().toString(), 
          ...notification 
        }] 
      })),
      
    removeNotification: (id) =>
      set((state) => ({
        notifications: state.notifications.filter(n => n.id !== id)
      })),
      
    toggleSidebar: () => 
      set((state) => ({ sidebarCollapsed: !state.sidebarCollapsed })),
      
    updateFeature: (feature) =>
      set((state) => ({
        features: state.features.map(f => 
          f.id === feature.id ? { ...f, ...feature } : f
        )
      })),
      
    updateModel: (model) =>
      set((state) => ({
        models: state.models.map(m => 
          m.id === model.id ? { ...m, ...model } : m
        )
      })),
      
    addExperiment: (experiment) =>
      set((state) => ({
        experiments: [...state.experiments, experiment]
      }))
  }))
);

// Selector hooks for performance
export const useSelectedFeature = () => 
  useAIManagementStore(state => state.selectedFeature);

export const useFeatures = () => 
  useAIManagementStore(state => state.features);

export const useNotifications = () => 
  useAIManagementStore(state => state.notifications);
```

#### TanStack Query Integration
```typescript
// lib/queries/ai-management-queries.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Query keys
export const aiManagementKeys = {
  all: ['ai-management'] as const,
  features: () => [...aiManagementKeys.all, 'features'] as const,
  feature: (id: string) => [...aiManagementKeys.features(), id] as const,
  featureMetrics: (id: string, timeRange: string) => 
    [...aiManagementKeys.feature(id), 'metrics', timeRange] as const,
  models: () => [...aiManagementKeys.all, 'models'] as const,
  model: (id: string) => [...aiManagementKeys.models(), id] as const,
  experiments: () => [...aiManagementKeys.all, 'experiments'] as const,
};

// Feature queries
export function useFeatures() {
  return useQuery({
    queryKey: aiManagementKeys.features(),
    queryFn: async () => {
      const response = await fetch('/api/platform/ai-management/features');
      if (!response.ok) throw new Error('Failed to fetch features');
      return response.json();
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useFeatureMetrics(featureId: string, timeRange: string = '24h') {
  return useQuery({
    queryKey: aiManagementKeys.featureMetrics(featureId, timeRange),
    queryFn: async () => {
      const response = await fetch(
        `/api/platform/ai-management/features/${featureId}/metrics?timeRange=${timeRange}`
      );
      if (!response.ok) throw new Error('Failed to fetch metrics');
      return response.json();
    },
    enabled: !!featureId,
    refetchInterval: 30000, // Refresh every 30 seconds
  });
}

// Model mutations
export function useDeployModel() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async ({ modelId, featureId, environment }: {
      modelId: string;
      featureId: string;
      environment: string;
    }) => {
      const response = await fetch(`/api/platform/ai-management/models/${modelId}/deploy`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ featureId, environment }),
      });
      if (!response.ok) throw new Error('Failed to deploy model');
      return response.json();
    },
    onSuccess: (data, variables) => {
      // Invalidate relevant queries
      queryClient.invalidateQueries({ 
        queryKey: aiManagementKeys.feature(variables.featureId) 
      });
      queryClient.invalidateQueries({ 
        queryKey: aiManagementKeys.models() 
      });
    },
  });
}
```

---

## Database Implementation

### Migration Scripts

#### Initial Schema Migration
```sql
-- Migration: 20250130000001_create_ai_management_schema.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- AI Features table
CREATE TABLE ai_features (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    config JSONB NOT NULL DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Providers table
CREATE TABLE ai_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('openai', 'google', 'anthropic', 'custom')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'error')),
    config JSONB NOT NULL DEFAULT '{}',
    health_check JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Models table
CREATE TABLE ai_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    provider_id UUID REFERENCES ai_providers(id) ON DELETE CASCADE,
    model_type VARCHAR(100) NOT NULL CHECK (model_type IN ('llm', 'vision', 'embedding', 'custom')),
    version VARCHAR(50),
    config JSONB NOT NULL DEFAULT '{}',
    performance_metrics JSONB DEFAULT '{}',
    pricing JSONB DEFAULT '{}',
    capabilities TEXT[] DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'deprecated', 'beta', 'unavailable')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(name, provider_id, version)
);

-- Feature-Model assignments
CREATE TABLE feature_model_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    model_id UUID REFERENCES ai_models(id) ON DELETE CASCADE,
    environment VARCHAR(20) DEFAULT 'production' CHECK (environment IN ('development', 'staging', 'production')),
    is_active BOOLEAN DEFAULT false,
    config_overrides JSONB DEFAULT '{}',
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assigned_by UUID REFERENCES auth.users(id),
    UNIQUE(feature_id, environment)
);

-- AI Prompts table
CREATE TABLE ai_prompts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    content TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    feature_id UUID REFERENCES ai_features(id) ON DELETE SET NULL,
    tags TEXT[] DEFAULT '{}',
    variables JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT false,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'review', 'approved', 'archived')),
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Usage logging
CREATE TABLE ai_usage_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    feature_id UUID REFERENCES ai_features(id),
    model_id UUID REFERENCES ai_models(id),
    prompt_id UUID REFERENCES ai_prompts(id),
    user_id UUID REFERENCES auth.users(id),
    request_data JSONB,
    response_data JSONB,
    tokens_used INTEGER,
    response_time_ms INTEGER,
    cost_usd DECIMAL(10,6),
    status VARCHAR(20) CHECK (status IN ('success', 'error', 'timeout')),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spending budgets
CREATE TABLE ai_spending_budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    period_type VARCHAR(20) NOT NULL CHECK (period_type IN ('daily', 'weekly', 'monthly', 'quarterly')),
    budget_amount DECIMAL(10,2) NOT NULL,
    alert_threshold DECIMAL(3,2) DEFAULT 0.8,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- A/B Testing experiments
CREATE TABLE ai_experiments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    experiment_type VARCHAR(50) CHECK (experiment_type IN ('model_comparison', 'prompt_testing', 'parameter_tuning')),
    config JSONB NOT NULL,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'running', 'completed', 'cancelled')),
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    results JSONB DEFAULT '{}',
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_ai_usage_logs_feature_created ON ai_usage_logs(feature_id, created_at DESC);
CREATE INDEX idx_ai_usage_logs_model_created ON ai_usage_logs(model_id, created_at DESC);
CREATE INDEX idx_ai_usage_logs_user_created ON ai_usage_logs(user_id, created_at DESC);
CREATE INDEX idx_feature_model_assignments_active ON feature_model_assignments(feature_id, is_active);
CREATE INDEX idx_ai_prompts_feature_active ON ai_prompts(feature_id, is_active);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_ai_features_updated_at BEFORE UPDATE ON ai_features FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_providers_updated_at BEFORE UPDATE ON ai_providers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_models_updated_at BEFORE UPDATE ON ai_models FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_prompts_updated_at BEFORE UPDATE ON ai_prompts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_spending_budgets_updated_at BEFORE UPDATE ON ai_spending_budgets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_experiments_updated_at BEFORE UPDATE ON ai_experiments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### Row Level Security Policies
```sql
-- Migration: 20250130000002_create_rls_policies.sql

-- Enable RLS on all tables
ALTER TABLE ai_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE feature_model_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_prompts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_usage_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_spending_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_experiments ENABLE ROW LEVEL SECURITY;

-- AI Features policies (Platform Admin Only)
CREATE POLICY "AI features are viewable by platform admins" ON ai_features
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );

CREATE POLICY "AI features are manageable by platform admins" ON ai_features
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );

-- AI Models policies (Platform Admin Only)
CREATE POLICY "AI models are viewable by platform admins" ON ai_models
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );

CREATE POLICY "AI models are manageable by platform admins" ON ai_models
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );

-- Prompts policies (Platform Admin Only)
CREATE POLICY "Prompts are viewable by platform admins" ON ai_prompts
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );

CREATE POLICY "Platform admins can manage all prompts" ON ai_prompts
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );

-- Usage logs policies (Platform Admin Only)
CREATE POLICY "Usage logs are viewable by platform admins" ON ai_usage_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );

CREATE POLICY "Usage logs are insertable by system" ON ai_usage_logs
    FOR INSERT WITH CHECK (true); -- System-level inserts

-- Spending budgets policies (Platform Admin Only)
CREATE POLICY "Spending budgets are viewable by platform admins" ON ai_spending_budgets
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );

CREATE POLICY "Spending budgets are manageable by platform admins" ON ai_spending_budgets
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );
```

### Database Functions and Views

#### Analytics Views
```sql
-- Migration: 20250130000003_create_analytics_views.sql

-- Feature performance summary view
CREATE VIEW feature_performance_summary AS
SELECT 
    f.id,
    f.name,
    f.display_name,
    f.status,
    COUNT(ul.id) as total_requests,
    AVG(ul.response_time_ms) as avg_response_time,
    SUM(CASE WHEN ul.status = 'success' THEN 1 ELSE 0 END)::FLOAT / COUNT(ul.id) * 100 as success_rate,
    SUM(ul.cost_usd) as total_cost,
    DATE_TRUNC('hour', ul.created_at) as hour_bucket
FROM ai_features f
LEFT JOIN ai_usage_logs ul ON f.id = ul.feature_id
WHERE ul.created_at >= NOW() - INTERVAL '24 hours'
GROUP BY f.id, f.name, f.display_name, f.status, DATE_TRUNC('hour', ul.created_at);

-- Model comparison view
CREATE VIEW model_comparison_metrics AS
SELECT 
    m.id,
    m.name,
    p.name as provider_name,
    m.model_type,
    COUNT(ul.id) as usage_count,
    AVG(ul.response_time_ms) as avg_latency,
    SUM(CASE WHEN ul.status = 'success' THEN 1 ELSE 0 END)::FLOAT / COUNT(ul.id) * 100 as success_rate,
    AVG(ul.cost_usd) as avg_cost_per_request,
    SUM(ul.cost_usd) as total_cost
FROM ai_models m
JOIN ai_providers p ON m.provider_id = p.id
LEFT JOIN ai_usage_logs ul ON m.id = ul.model_id
WHERE ul.created_at >= NOW() - INTERVAL '7 days'
GROUP BY m.id, m.name, p.name, m.model_type;

-- Spending analysis function
CREATE OR REPLACE FUNCTION get_spending_breakdown(
    start_date TIMESTAMPTZ DEFAULT NOW() - INTERVAL '30 days',
    end_date TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE (
    feature_name VARCHAR,
    provider_name VARCHAR,
    model_name VARCHAR,
    total_cost DECIMAL,
    request_count BIGINT,
    avg_cost_per_request DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.display_name,
        p.name,
        m.name,
        SUM(ul.cost_usd)::DECIMAL,
        COUNT(ul.id),
        AVG(ul.cost_usd)::DECIMAL
    FROM ai_usage_logs ul
    JOIN ai_features f ON ul.feature_id = f.id
    JOIN ai_models m ON ul.model_id = m.id
    JOIN ai_providers p ON m.provider_id = p.id
    WHERE ul.created_at BETWEEN start_date AND end_date
    GROUP BY f.display_name, p.name, m.name
    ORDER BY SUM(ul.cost_usd) DESC;
END;
$$ LANGUAGE plpgsql;
```

---

## Integration Patterns

### External AI Provider Integration

#### OpenAI Integration
```typescript
// lib/integrations/openai-client.ts
import OpenAI from 'openai';

export class OpenAIIntegration {
  private client: OpenAI;
  
  constructor(apiKey: string, organization?: string) {
    this.client = new OpenAI({
      apiKey,
      organization,
    });
  }

  async createCompletion(params: {
    model: string;
    prompt: string;
    maxTokens?: number;
    temperature?: number;
    metadata?: any;
  }) {
    const startTime = Date.now();
    
    try {
      const response = await this.client.completions.create({
        model: params.model,
        prompt: params.prompt,
        max_tokens: params.maxTokens || 100,
        temperature: params.temperature || 0.7,
      });

      const responseTime = Date.now() - startTime;
      
      // Log usage
      await this.logUsage({
        model: params.model,
        tokensUsed: response.usage?.total_tokens || 0,
        responseTime,
        cost: this.calculateCost(response.usage?.total_tokens || 0, params.model),
        status: 'success',
        metadata: params.metadata,
      });

      return {
        text: response.choices[0]?.text || '',
        usage: response.usage,
        responseTime,
      };
    } catch (error) {
      const responseTime = Date.now() - startTime;
      
      await this.logUsage({
        model: params.model,
        tokensUsed: 0,
        responseTime,
        cost: 0,
        status: 'error',
        error: error instanceof Error ? error.message : 'Unknown error',
        metadata: params.metadata,
      });

      throw error;
    }
  }

  private async logUsage(usage: any) {
    // Log to database via API
    await fetch('/api/platform/ai-management/usage', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(usage),
    });
  }

  private calculateCost(tokens: number, model: string): number {
    // Simplified cost calculation - should use real pricing
    const costPerToken = this.getCostPerToken(model);
    return tokens * costPerToken;
  }

  private getCostPerToken(model: string): number {
    // This should be fetched from database or config
    const pricing: Record<string, number> = {
      'gpt-4': 0.00003,
      'gpt-3.5-turbo': 0.000002,
      // Add more models...
    };
    return pricing[model] || 0.00001;
  }
}
```

### Testing Framework Integration

#### Jest/Vitest Configuration
```typescript
// vitest.config.ts - Extended for AI management testing
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'tests/',
        '**/*.d.ts',
        'app/api/**', // API routes tested separately
      ],
    },
  },
  resolve: {
    alias: {
      '@': new URL('./', import.meta.url).pathname,
    },
  },
});
```

#### Component Testing Examples
```typescript
// tests/components/AIModelCard.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { AIModelCard } from '@/components/models/AIModelCard';

const mockModel = {
  id: '1',
  name: 'GPT-4',
  provider: 'OpenAI',
  status: 'active' as const,
  metrics: {
    averageLatency: 150,
    successRate: 99.5,
    cost: 0.03,
  },
  lastDeployed: new Date('2024-01-01'),
};

describe('AIModelCard', () => {
  it('renders model information correctly', () => {
    render(<AIModelCard model={mockModel} />);
    
    expect(screen.getByText('GPT-4')).toBeInTheDocument();
    expect(screen.getByText('OpenAI')).toBeInTheDocument();
    expect(screen.getByText('active')).toBeInTheDocument();
    expect(screen.getByText('150ms')).toBeInTheDocument();
    expect(screen.getByText('99.5%')).toBeInTheDocument();
  });

  it('calls onDeploy when deploy action is clicked', () => {
    const onDeploy = vi.fn();
    render(<AIModelCard model={mockModel} onDeploy={onDeploy} />);
    
    fireEvent.click(screen.getByRole('button')); // More button
    fireEvent.click(screen.getByText('Deploy'));
    
    expect(onDeploy).toHaveBeenCalledWith('1');
  });

  it('shows different status colors', () => {
    const errorModel = { ...mockModel, status: 'error' as const };
    const { rerender } = render(<AIModelCard model={errorModel} />);
    
    expect(screen.getByText('error')).toHaveClass('bg-red-100 text-red-800');
    
    rerender(<AIModelCard model={mockModel} />);
    expect(screen.getByText('active')).toHaveClass('bg-green-100 text-green-800');
  });
});
```

This technical implementation guide provides a comprehensive foundation for building the feature-centric AI management system with modern web technologies, proper architecture patterns, and robust testing strategies.