# Phase 3: Productivity Tools Implementation Plan

## Overview
This phase focuses on implementing the Prompt Library and Spending Analytics systems - the productivity tools that enable efficient prompt management, version control, cost tracking, and budget optimization for the AI platform.

## Priority: High
These features provide significant operational value and complete the core platform management capabilities.

## Prerequisites
- Phase 1 (Database Foundation) must be completed
- Phase 2 (Feature Management Core) must be completed

## Implementation Checklist

### A. Database Extensions (5 additional tables)
- [ ] Add prompt library tables to migration
- [ ] Add spending analytics tables to migration
- [ ] Add notification system tables
- [ ] Update TypeScript interfaces
- [ ] Add RLS policies for new tables

### B. Backend Services
- [ ] Implement PromptLibraryService
- [ ] Implement SpendingAnalyticsService
- [ ] Implement NotificationService
- [ ] Add budget monitoring and alerting
- [ ] Create cost optimization engine

### C. API Endpoints
- [ ] Implement /api/platform/ai-management/prompts
- [ ] Implement /api/platform/ai-management/spending
- [ ] Implement /api/platform/ai-management/budgets
- [ ] Implement /api/platform/ai-management/notifications
- [ ] Add WebSocket endpoints for real-time updates

### D. Frontend Components
- [ ] Implement PromptLibrary page
- [ ] Implement SpendingAnalytics page
- [ ] Create PromptEditor component
- [ ] Create BudgetManagement component
- [ ] Create CostOptimization component
- [ ] Add notification system UI
- [ ] Integrate real-time updates

---

## 1. Database Schema Extensions

### Add to existing migration file:

```sql
-- Prompt Library System
CREATE TABLE ai_prompt_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#3B82F6', -- Hex color for UI
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE ai_prompts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES ai_prompt_categories(id) ON DELETE SET NULL,
    template TEXT NOT NULL,
    variables JSONB DEFAULT '[]', -- Array of variable definitions
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    usage_count INTEGER DEFAULT 0,
    last_used_at TIMESTAMP WITH TIME ZONE,
    tags TEXT[] DEFAULT '{}',
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Full-text search
    search_vector tsvector GENERATED ALWAYS AS (
        to_tsvector('english', name || ' ' || COALESCE(description, '') || ' ' || template)
    ) STORED
);

CREATE TABLE ai_prompt_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_id UUID NOT NULL REFERENCES ai_prompts(id) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    template TEXT NOT NULL,
    variables JSONB DEFAULT '[]',
    changelog TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(prompt_id, version)
);

-- Spending Analytics & Budget Management
CREATE TABLE ai_spending_budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES ai_providers(id) ON DELETE CASCADE,
    budget_type VARCHAR(20) NOT NULL CHECK (budget_type IN ('monthly', 'quarterly', 'yearly', 'custom')),
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    alert_threshold DECIMAL(5,2) DEFAULT 80.00, -- Percentage
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE ai_cost_optimizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    optimization_type VARCHAR(50) NOT NULL,
    current_cost DECIMAL(12,2) NOT NULL,
    projected_savings DECIMAL(12,2) NOT NULL,
    recommendation TEXT NOT NULL,
    implementation_effort VARCHAR(20) CHECK (implementation_effort IN ('low', 'medium', 'high')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'dismissed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notification System
CREATE TABLE ai_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'error', 'success')),
    target_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    metadata JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for performance
CREATE INDEX idx_prompts_search ON ai_prompts USING gin(search_vector);
CREATE INDEX idx_prompts_category ON ai_prompts(category_id);
CREATE INDEX idx_prompts_active ON ai_prompts(is_active);
CREATE INDEX idx_prompts_usage ON ai_prompts(usage_count DESC);
CREATE INDEX idx_prompt_versions_prompt ON ai_prompt_versions(prompt_id, version DESC);
CREATE INDEX idx_budgets_feature ON ai_spending_budgets(feature_id);
CREATE INDEX idx_budgets_active ON ai_spending_budgets(is_active);
CREATE INDEX idx_notifications_user ON ai_notifications(target_user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON ai_notifications(target_user_id, is_read) WHERE is_read = false;

-- RLS Policies
ALTER TABLE ai_prompt_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_prompts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_prompt_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_spending_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_cost_optimizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_notifications ENABLE ROW LEVEL SECURITY;

-- Platform admin access
CREATE POLICY platform_admin_prompt_categories ON ai_prompt_categories
    FOR ALL USING (auth.jwt() ->> 'role' = 'platform_admin');

CREATE POLICY platform_admin_prompts ON ai_prompts
    FOR ALL USING (auth.jwt() ->> 'role' = 'platform_admin');

CREATE POLICY platform_admin_prompt_versions ON ai_prompt_versions
    FOR ALL USING (auth.jwt() ->> 'role' = 'platform_admin');

CREATE POLICY platform_admin_budgets ON ai_spending_budgets
    FOR ALL USING (auth.jwt() ->> 'role' = 'platform_admin');

CREATE POLICY platform_admin_optimizations ON ai_cost_optimizations
    FOR ALL USING (auth.jwt() ->> 'role' = 'platform_admin');

CREATE POLICY platform_admin_notifications ON ai_notifications
    FOR ALL USING (auth.jwt() ->> 'role' = 'platform_admin');

-- Insert default prompt categories
INSERT INTO ai_prompt_categories (name, description, color) VALUES
('System', 'Core system prompts for AI features', '#EF4444'),
('User Interface', 'Prompts for user-facing AI interactions', '#3B82F6'),
('Analysis', 'Prompts for data analysis and insights', '#10B981'),
('Content Generation', 'Prompts for generating various content types', '#F59E0B'),
('Quality Assurance', 'Prompts for testing and validation', '#8B5CF6');
```

## 2. TypeScript Interfaces

### Create: `lib/types/platform/prompt-library.ts`

```typescript
export interface PromptCategory {
  id: string;
  name: string;
  description?: string;
  color: string;
  created_at: string;
  updated_at: string;
}

export interface PromptVariable {
  name: string;
  type: 'text' | 'number' | 'boolean' | 'select';
  description?: string;
  required: boolean;
  default?: string;
  options?: string[]; // For select type
}

export interface Prompt {
  id: string;
  name: string;
  description?: string;
  category_id?: string;
  category?: PromptCategory;
  template: string;
  variables: PromptVariable[];
  version: number;
  is_active: boolean;
  usage_count: number;
  last_used_at?: string;
  tags: string[];
  created_by?: string;
  created_at: string;
  updated_at: string;
}

export interface PromptVersion {
  id: string;
  prompt_id: string;
  version: number;
  template: string;
  variables: PromptVariable[];
  changelog?: string;
  created_by?: string;
  created_at: string;
}

export interface PromptSearchParams {
  query?: string;
  category_id?: string;
  tags?: string[];
  is_active?: boolean;
  limit?: number;
  offset?: number;
}

export interface SpendingBudget {
  id: string;
  name: string;
  description?: string;
  feature_id?: string;
  feature?: AIFeature;
  provider_id?: string;
  provider?: AIProvider;
  budget_type: 'monthly' | 'quarterly' | 'yearly' | 'custom';
  amount: number;
  currency: string;
  alert_threshold: number;
  start_date: string;
  end_date: string;
  is_active: boolean;
  current_spending?: number;
  utilization_percentage?: number;
  created_at: string;
  updated_at: string;
}

export interface CostOptimization {
  id: string;
  feature_id: string;
  feature?: AIFeature;
  optimization_type: string;
  current_cost: number;
  projected_savings: number;
  recommendation: string;
  implementation_effort: 'low' | 'medium' | 'high';
  status: 'pending' | 'in_progress' | 'completed' | 'dismissed';
  created_at: string;
  updated_at: string;
}

export interface SpendingAnalyticsData {
  total_spending: number;
  budget_utilization: number;
  top_features: Array<{
    feature_name: string;
    spending: number;
    percentage: number;
  }>;
  spending_trends: Array<{
    date: string;
    amount: number;
  }>;
  cost_optimizations: CostOptimization[];
}

export interface PlatformNotification {
  id: string;
  type: string;
  title: string;
  message: string;
  severity: 'info' | 'warning' | 'error' | 'success';
  target_user_id: string;
  metadata: Record<string, any>;
  is_read: boolean;
  created_at: string;
  read_at?: string;
}
```

## 3. Backend Services

### Create: `lib/services/platform/prompt-library-service.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js';
import {
  Prompt,
  PromptCategory,
  PromptVersion,
  PromptVariable,
  PromptSearchParams,
} from '@/lib/types/platform/prompt-library';

export class PromptLibraryService {
  constructor(private supabase: SupabaseClient) {}

  async getCategories(): Promise<PromptCategory[]> {
    const { data, error } = await this.supabase
      .from('ai_prompt_categories')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  }

  async searchPrompts(params: PromptSearchParams): Promise<{
    prompts: Prompt[];
    total: number;
  }> {
    let query = this.supabase
      .from('ai_prompts')
      .select(`
        *,
        category:ai_prompt_categories(*)
      `, { count: 'exact' });

    if (params.query) {
      query = query.textSearch('search_vector', params.query);
    }

    if (params.category_id) {
      query = query.eq('category_id', params.category_id);
    }

    if (params.tags && params.tags.length > 0) {
      query = query.overlaps('tags', params.tags);
    }

    if (params.is_active !== undefined) {
      query = query.eq('is_active', params.is_active);
    }

    query = query.order('updated_at', { ascending: false });

    if (params.limit) {
      query = query.limit(params.limit);
    }

    if (params.offset) {
      query = query.range(params.offset, params.offset + (params.limit || 50) - 1);
    }

    const { data, error, count } = await query;

    if (error) throw error;

    return {
      prompts: data || [],
      total: count || 0,
    };
  }

  async getPrompt(id: string): Promise<Prompt | null> {
    const { data, error } = await this.supabase
      .from('ai_prompts')
      .select(`
        *,
        category:ai_prompt_categories(*)
      `)
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }

  async createPrompt(promptData: {
    name: string;
    description?: string;
    category_id?: string;
    template: string;
    variables: PromptVariable[];
    tags?: string[];
  }): Promise<Prompt> {
    const { data, error } = await this.supabase
      .from('ai_prompts')
      .insert([promptData])
      .select(`
        *,
        category:ai_prompt_categories(*)
      `)
      .single();

    if (error) throw error;

    // Create initial version
    await this.createVersion(data.id, {
      template: promptData.template,
      variables: promptData.variables,
      changelog: 'Initial version',
    });

    return data;
  }

  async updatePrompt(id: string, updates: {
    name?: string;
    description?: string;
    category_id?: string;
    template?: string;
    variables?: PromptVariable[];
    tags?: string[];
    is_active?: boolean;
  }): Promise<Prompt> {
    const current = await this.getPrompt(id);
    if (!current) throw new Error('Prompt not found');

    // If template or variables changed, create new version
    if (updates.template || updates.variables) {
      await this.createVersion(id, {
        template: updates.template || current.template,
        variables: updates.variables || current.variables,
        changelog: 'Updated via prompt editor',
      });

      updates.version = current.version + 1;
    }

    const { data, error } = await this.supabase
      .from('ai_prompts')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select(`
        *,
        category:ai_prompt_categories(*)
      `)
      .single();

    if (error) throw error;
    return data;
  }

  async getPromptVersions(promptId: string): Promise<PromptVersion[]> {
    const { data, error } = await this.supabase
      .from('ai_prompt_versions')
      .select('*')
      .eq('prompt_id', promptId)
      .order('version', { ascending: false });

    if (error) throw error;
    return data || [];
  }

  private async createVersion(promptId: string, versionData: {
    template: string;
    variables: PromptVariable[];
    changelog?: string;
  }): Promise<PromptVersion> {
    // Get current version number
    const { data: currentPrompt } = await this.supabase
      .from('ai_prompts')
      .select('version')
      .eq('id', promptId)
      .single();

    const newVersion = (currentPrompt?.version || 0) + 1;

    const { data, error } = await this.supabase
      .from('ai_prompt_versions')
      .insert([{
        prompt_id: promptId,
        version: newVersion,
        ...versionData,
      }])
      .select('*')
      .single();

    if (error) throw error;
    return data;
  }

  async incrementUsage(promptId: string): Promise<void> {
    await this.supabase.rpc('increment_prompt_usage', {
      prompt_id: promptId,
    });
  }

  async getPopularPrompts(limit: number = 10): Promise<Prompt[]> {
    const { data, error } = await this.supabase
      .from('ai_prompts')
      .select(`
        *,
        category:ai_prompt_categories(*)
      `)
      .eq('is_active', true)
      .order('usage_count', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  }
}
```

### Create: `lib/services/platform/spending-analytics-service.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js';
import {
  SpendingBudget,
  CostOptimization,
  SpendingAnalyticsData,
} from '@/lib/types/platform/prompt-library';

export class SpendingAnalyticsService {
  constructor(private supabase: SupabaseClient) {}

  async getSpendingAnalytics(timeRange: string = '30d'): Promise<SpendingAnalyticsData> {
    const [
      totalSpending,
      budgetUtilization,
      topFeatures,
      spendingTrends,
      costOptimizations,
    ] = await Promise.all([
      this.getTotalSpending(timeRange),
      this.getBudgetUtilization(),
      this.getTopSpendingFeatures(timeRange),
      this.getSpendingTrends(timeRange),
      this.getCostOptimizations(),
    ]);

    return {
      total_spending: totalSpending,
      budget_utilization: budgetUtilization,
      top_features: topFeatures,
      spending_trends: spendingTrends,
      cost_optimizations: costOptimizations,
    };
  }

  private async getTotalSpending(timeRange: string): Promise<number> {
    const { data, error } = await this.supabase.rpc('get_total_spending', {
      time_range: timeRange,
    });

    if (error) throw error;
    return data || 0;
  }

  private async getBudgetUtilization(): Promise<number> {
    const { data, error } = await this.supabase.rpc('get_budget_utilization');

    if (error) throw error;
    return data || 0;
  }

  private async getTopSpendingFeatures(timeRange: string): Promise<Array<{
    feature_name: string;
    spending: number;
    percentage: number;
  }>> {
    const { data, error } = await this.supabase.rpc(
      'get_top_spending_features',
      { time_range: timeRange }
    );

    if (error) throw error;
    return data || [];
  }

  private async getSpendingTrends(timeRange: string): Promise<Array<{
    date: string;
    amount: number;
  }>> {
    const { data, error } = await this.supabase.rpc('get_spending_trends', {
      time_range: timeRange,
    });

    if (error) throw error;
    return data || [];
  }

  async getBudgets(): Promise<SpendingBudget[]> {
    const { data, error } = await this.supabase
      .from('ai_spending_budgets')
      .select(`
        *,
        feature:ai_features(*),
        provider:ai_providers(*)
      `)
      .eq('is_active', true)
      .order('created_at', { ascending: false });

    if (error) throw error;

    // Calculate current spending for each budget
    const budgetsWithSpending = await Promise.all(
      (data || []).map(async (budget) => {
        const currentSpending = await this.getCurrentBudgetSpending(budget.id);
        const utilizationPercentage = (currentSpending / budget.amount) * 100;

        return {
          ...budget,
          current_spending: currentSpending,
          utilization_percentage: utilizationPercentage,
        };
      })
    );

    return budgetsWithSpending;
  }

  private async getCurrentBudgetSpending(budgetId: string): Promise<number> {
    const { data, error } = await this.supabase.rpc(
      'get_current_budget_spending',
      { budget_id: budgetId }
    );

    if (error) throw error;
    return data || 0;
  }

  async createBudget(budgetData: {
    name: string;
    description?: string;
    feature_id?: string;
    provider_id?: string;
    budget_type: 'monthly' | 'quarterly' | 'yearly' | 'custom';
    amount: number;
    currency?: string;
    alert_threshold?: number;
    start_date: string;
    end_date: string;
  }): Promise<SpendingBudget> {
    const { data, error } = await this.supabase
      .from('ai_spending_budgets')
      .insert([budgetData])
      .select(`
        *,
        feature:ai_features(*),
        provider:ai_providers(*)
      `)
      .single();

    if (error) throw error;
    return data;
  }

  async getCostOptimizations(): Promise<CostOptimization[]> {
    const { data, error } = await this.supabase
      .from('ai_cost_optimizations')
      .select(`
        *,
        feature:ai_features(*)
      `)
      .order('projected_savings', { ascending: false });

    if (error) throw error;
    return data || [];
  }

  async generateCostOptimizations(): Promise<CostOptimization[]> {
    // This would typically analyze usage patterns and generate recommendations
    const { data, error } = await this.supabase.rpc('generate_cost_optimizations');

    if (error) throw error;
    return data || [];
  }

  async updateOptimizationStatus(
    id: string,
    status: 'pending' | 'in_progress' | 'completed' | 'dismissed'
  ): Promise<void> {
    const { error } = await this.supabase
      .from('ai_cost_optimizations')
      .update({
        status,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id);

    if (error) throw error;
  }
}
```

### Create: `lib/services/platform/notification-service.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js';
import { PlatformNotification } from '@/lib/types/platform/prompt-library';

export class NotificationService {
  constructor(private supabase: SupabaseClient) {}

  async getNotifications(userId: string, limit: number = 50): Promise<PlatformNotification[]> {
    const { data, error } = await this.supabase
      .from('ai_notifications')
      .select('*')
      .eq('target_user_id', userId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  }

  async getUnreadCount(userId: string): Promise<number> {
    const { count, error } = await this.supabase
      .from('ai_notifications')
      .select('*', { count: 'exact', head: true })
      .eq('target_user_id', userId)
      .eq('is_read', false);

    if (error) throw error;
    return count || 0;
  }

  async markAsRead(notificationIds: string[]): Promise<void> {
    const { error } = await this.supabase
      .from('ai_notifications')
      .update({
        is_read: true,
        read_at: new Date().toISOString(),
      })
      .in('id', notificationIds);

    if (error) throw error;
  }

  async createNotification(notification: {
    type: string;
    title: string;
    message: string;
    severity?: 'info' | 'warning' | 'error' | 'success';
    target_user_id: string;
    metadata?: Record<string, any>;
  }): Promise<PlatformNotification> {
    const { data, error } = await this.supabase
      .from('ai_notifications')
      .insert([notification])
      .select('*')
      .single();

    if (error) throw error;
    return data;
  }

  async createBudgetAlert(
    budgetId: string,
    currentSpending: number,
    budgetAmount: number,
    threshold: number
  ): Promise<void> {
    const percentage = (currentSpending / budgetAmount) * 100;
    
    await this.createNotification({
      type: 'budget_alert',
      title: 'Budget Alert',
      message: `Budget utilization has reached ${percentage.toFixed(1)}% (${threshold}% threshold)`,
      severity: percentage >= 90 ? 'error' : 'warning',
      target_user_id: 'platform_admin', // Would be actual admin user ID
      metadata: {
        budget_id: budgetId,
        current_spending: currentSpending,
        budget_amount: budgetAmount,
        utilization_percentage: percentage,
      },
    });
  }
}
```

## 4. API Endpoints

### Create: `app/api/platform/ai-management/prompts/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase-server';
import { withPlatformAdminAuth } from '@/lib/auth/platform-admin-validation';
import { PromptLibraryService } from '@/lib/services/platform/prompt-library-service';

async function GET(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new PromptLibraryService(supabase);

    const url = new URL(request.url);
    const query = url.searchParams.get('query');
    const categoryId = url.searchParams.get('category_id');
    const tags = url.searchParams.get('tags')?.split(',');
    const isActive = url.searchParams.get('is_active');
    const limit = parseInt(url.searchParams.get('limit') || '50');
    const offset = parseInt(url.searchParams.get('offset') || '0');

    const { prompts, total } = await service.searchPrompts({
      query: query || undefined,
      category_id: categoryId || undefined,
      tags: tags || undefined,
      is_active: isActive ? isActive === 'true' : undefined,
      limit,
      offset,
    });

    return NextResponse.json({
      success: true,
      data: prompts,
      metadata: {
        total,
        limit,
        offset,
        has_more: offset + limit < total,
      },
    });
  } catch (error) {
    console.error('Error fetching prompts:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch prompts',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

async function POST(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new PromptLibraryService(supabase);

    const body = await request.json();

    if (!body.name || !body.template) {
      return NextResponse.json(
        {
          success: false,
          error: 'Missing required fields: name, template',
        },
        { status: 400 }
      );
    }

    const prompt = await service.createPrompt({
      name: body.name,
      description: body.description,
      category_id: body.category_id,
      template: body.template,
      variables: body.variables || [],
      tags: body.tags || [],
    });

    return NextResponse.json(
      {
        success: true,
        data: prompt,
      },
      { status: 201 }
    );
  } catch (error) {
    console.error('Error creating prompt:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to create prompt',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

export const authenticatedGET = withPlatformAdminAuth(GET);
export const authenticatedPOST = withPlatformAdminAuth(POST);

export { authenticatedGET as GET, authenticatedPOST as POST };
```

### Create: `app/api/platform/ai-management/prompts/[id]/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase-server';
import { withPlatformAdminAuth } from '@/lib/auth/platform-admin-validation';
import { PromptLibraryService } from '@/lib/services/platform/prompt-library-service';

async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient();
    const service = new PromptLibraryService(supabase);

    const prompt = await service.getPrompt(params.id);

    if (!prompt) {
      return NextResponse.json(
        {
          success: false,
          error: 'Prompt not found',
        },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: prompt,
    });
  } catch (error) {
    console.error('Error fetching prompt:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch prompt',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient();
    const service = new PromptLibraryService(supabase);

    const body = await request.json();

    const prompt = await service.updatePrompt(params.id, body);

    return NextResponse.json({
      success: true,
      data: prompt,
    });
  } catch (error) {
    console.error('Error updating prompt:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to update prompt',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

export const authenticatedGET = withPlatformAdminAuth(GET);
export const authenticatedPUT = withPlatformAdminAuth(PUT);

export { authenticatedGET as GET, authenticatedPUT as PUT };
```

### Create: `app/api/platform/ai-management/spending/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase-server';
import { withPlatformAdminAuth } from '@/lib/auth/platform-admin-validation';
import { SpendingAnalyticsService } from '@/lib/services/platform/spending-analytics-service';

async function GET(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new SpendingAnalyticsService(supabase);

    const url = new URL(request.url);
    const timeRange = url.searchParams.get('time_range') || '30d';

    const analytics = await service.getSpendingAnalytics(timeRange);

    return NextResponse.json({
      success: true,
      data: analytics,
      metadata: {
        time_range: timeRange,
        generated_at: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error('Error fetching spending analytics:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch spending analytics',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

export const authenticatedGET = withPlatformAdminAuth(GET);

export { authenticatedGET as GET };
```

### Create: `app/api/platform/ai-management/budgets/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase-server';
import { withPlatformAdminAuth } from '@/lib/auth/platform-admin-validation';
import { SpendingAnalyticsService } from '@/lib/services/platform/spending-analytics-service';

async function GET(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new SpendingAnalyticsService(supabase);

    const budgets = await service.getBudgets();

    return NextResponse.json({
      success: true,
      data: budgets,
    });
  } catch (error) {
    console.error('Error fetching budgets:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch budgets',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

async function POST(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new SpendingAnalyticsService(supabase);

    const body = await request.json();

    if (!body.name || !body.amount || !body.start_date || !body.end_date) {
      return NextResponse.json(
        {
          success: false,
          error: 'Missing required fields: name, amount, start_date, end_date',
        },
        { status: 400 }
      );
    }

    const budget = await service.createBudget(body);

    return NextResponse.json(
      {
        success: true,
        data: budget,
      },
      { status: 201 }
    );
  } catch (error) {
    console.error('Error creating budget:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to create budget',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    );
  }
}

export const authenticatedGET = withPlatformAdminAuth(GET);
export const authenticatedPOST = withPlatformAdminAuth(POST);

export { authenticatedGET as GET, authenticatedPOST as POST };
```

## 5. Frontend Pages

### Create: `app/platform/ai-management/prompts/page.tsx`

```typescript
'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Search, Plus, Filter, Code, Tags, Clock, TrendingUp } from 'lucide-react';
import { PromptEditor } from '@/components/platform/ai-management/PromptEditor';
import { PromptLibrary } from '@/components/platform/ai-management/PromptLibrary';
import { PromptSearch } from '@/components/platform/ai-management/PromptSearch';

async function fetchPrompts(params: {
  query?: string;
  category_id?: string;
  tags?: string[];
  limit?: number;
  offset?: number;
}) {
  const searchParams = new URLSearchParams();
  
  if (params.query) searchParams.set('query', params.query);
  if (params.category_id) searchParams.set('category_id', params.category_id);
  if (params.tags && params.tags.length > 0) searchParams.set('tags', params.tags.join(','));
  if (params.limit) searchParams.set('limit', params.limit.toString());
  if (params.offset) searchParams.set('offset', params.offset.toString());

  const response = await fetch(`/api/platform/ai-management/prompts?${searchParams}`);
  if (!response.ok) throw new Error('Failed to fetch prompts');
  return response.json();
}

async function fetchPromptCategories() {
  const response = await fetch('/api/platform/ai-management/prompts/categories');
  if (!response.ok) throw new Error('Failed to fetch categories');
  return response.json();
}

async function fetchPopularPrompts() {
  const response = await fetch('/api/platform/ai-management/prompts/popular');
  if (!response.ok) throw new Error('Failed to fetch popular prompts');
  return response.json();
}

export default function PromptsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('');
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [showEditor, setShowEditor] = useState(false);
  const [editingPrompt, setEditingPrompt] = useState(null);

  const queryClient = useQueryClient();

  const { data: promptsData, isLoading: promptsLoading } = useQuery({
    queryKey: ['prompts', { query: searchQuery, category_id: selectedCategory, tags: selectedTags }],
    queryFn: () => fetchPrompts({
      query: searchQuery || undefined,
      category_id: selectedCategory || undefined,
      tags: selectedTags.length > 0 ? selectedTags : undefined,
      limit: 50,
    }),
    staleTime: 30000,
  });

  const { data: categoriesData } = useQuery({
    queryKey: ['prompt-categories'],
    queryFn: fetchPromptCategories,
    staleTime: 300000, // 5 minutes
  });

  const { data: popularPromptsData } = useQuery({
    queryKey: ['popular-prompts'],
    queryFn: fetchPopularPrompts,
    staleTime: 300000,
  });

  const prompts = promptsData?.data || [];
  const categories = categoriesData?.data || [];
  const popularPrompts = popularPromptsData?.data || [];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Prompt Library</h1>
          <p className="text-muted-foreground">
            Manage and organize AI prompts with version control
          </p>
        </div>
        <Button onClick={() => setShowEditor(true)}>
          <Plus className="h-4 w-4 mr-2" />
          New Prompt
        </Button>
      </div>

      {/* Overview Cards */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Prompts</CardTitle>
            <Code className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{promptsData?.metadata?.total || 0}</div>
            <p className="text-xs text-muted-foreground">Active templates</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Categories</CardTitle>
            <Tags className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{categories.length}</div>
            <p className="text-xs text-muted-foreground">Organized collections</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Most Used</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {popularPrompts[0]?.name ? popularPrompts[0].name.substring(0, 12) + '...' : 'N/A'}
            </div>
            <p className="text-xs text-muted-foreground">
              {popularPrompts[0]?.usage_count || 0} uses
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Recent Activity</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {prompts.filter(p => {
                const updated = new Date(p.updated_at);
                const dayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
                return updated > dayAgo;
              }).length}
            </div>
            <p className="text-xs text-muted-foreground">Updated today</p>
          </CardContent>
        </Card>
      </div>

      {/* Main Content */}
      <Tabs defaultValue="library" className="space-y-4">
        <TabsList>
          <TabsTrigger value="library">Prompt Library</TabsTrigger>
          <TabsTrigger value="popular">Popular Prompts</TabsTrigger>
          <TabsTrigger value="search">Advanced Search</TabsTrigger>
        </TabsList>

        <TabsContent value="library" className="space-y-4">
          <PromptLibrary
            prompts={prompts}
            categories={categories}
            loading={promptsLoading}
            onEditPrompt={(prompt) => {
              setEditingPrompt(prompt);
              setShowEditor(true);
            }}
          />
        </TabsContent>

        <TabsContent value="popular" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {popularPrompts.map((prompt) => (
              <Card key={prompt.id} className="cursor-pointer hover:shadow-md transition-shadow">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <CardTitle className="text-lg">{prompt.name}</CardTitle>
                    <Badge variant="secondary">{prompt.usage_count} uses</Badge>
                  </div>
                  <CardDescription>{prompt.description}</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex flex-wrap gap-1 mb-3">
                    {prompt.tags.map((tag) => (
                      <Badge key={tag} variant="outline" className="text-xs">
                        {tag}
                      </Badge>
                    ))}
                  </div>
                  <div className="text-sm text-muted-foreground">
                    Version {prompt.version} • {prompt.category?.name}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>

        <TabsContent value="search" className="space-y-4">
          <PromptSearch
            categories={categories}
            onSearch={(query, categoryId, tags) => {
              setSearchQuery(query);
              setSelectedCategory(categoryId);
              setSelectedTags(tags);
            }}
          />
        </TabsContent>
      </Tabs>

      {/* Prompt Editor Modal */}
      {showEditor && (
        <PromptEditor
          prompt={editingPrompt}
          categories={categories}
          onSave={() => {
            queryClient.invalidateQueries({ queryKey: ['prompts'] });
            setShowEditor(false);
            setEditingPrompt(null);
          }}
          onCancel={() => {
            setShowEditor(false);
            setEditingPrompt(null);
          }}
        />
      )}
    </div>
  );
}
```

### Create: `app/platform/ai-management/spending/page.tsx`

```typescript
'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { 
  DollarSign, 
  TrendingUp, 
  TrendingDown, 
  AlertTriangle, 
  Target,
  PieChart,
  BarChart3,
  Plus
} from 'lucide-react';
import { SpendingChart } from '@/components/platform/ai-management/SpendingChart';
import { BudgetManagement } from '@/components/platform/ai-management/BudgetManagement';
import { CostOptimization } from '@/components/platform/ai-management/CostOptimization';

async function fetchSpendingAnalytics(timeRange: string) {
  const response = await fetch(`/api/platform/ai-management/spending?time_range=${timeRange}`);
  if (!response.ok) throw new Error('Failed to fetch spending analytics');
  return response.json();
}

async function fetchBudgets() {
  const response = await fetch('/api/platform/ai-management/budgets');
  if (!response.ok) throw new Error('Failed to fetch budgets');
  return response.json();
}

export default function SpendingPage() {
  const [timeRange, setTimeRange] = useState('30d');
  const [showBudgetDialog, setShowBudgetDialog] = useState(false);

  const { data: analyticsData, isLoading: analyticsLoading } = useQuery({
    queryKey: ['spending-analytics', timeRange],
    queryFn: () => fetchSpendingAnalytics(timeRange),
    refetchInterval: 60000, // Refresh every minute
  });

  const { data: budgetsData, isLoading: budgetsLoading } = useQuery({
    queryKey: ['budgets'],
    queryFn: fetchBudgets,
    staleTime: 300000, // 5 minutes
  });

  const analytics = analyticsData?.data;
  const budgets = budgetsData?.data || [];

  const formatCurrency = (amount: number) => 
    new Intl.NumberFormat('en-US', { 
      style: 'currency', 
      currency: 'USD' 
    }).format(amount);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Spending Analytics</h1>
          <p className="text-muted-foreground">
            Monitor AI costs, manage budgets, and optimize spending
          </p>
        </div>
        <div className="flex items-center gap-4">
          <Select value={timeRange} onValueChange={setTimeRange}>
            <SelectTrigger className="w-32">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="7d">Last 7 days</SelectItem>
              <SelectItem value="30d">Last 30 days</SelectItem>
              <SelectItem value="90d">Last 90 days</SelectItem>
              <SelectItem value="1y">Last year</SelectItem>
            </SelectContent>
          </Select>
          <Button onClick={() => setShowBudgetDialog(true)}>
            <Plus className="h-4 w-4 mr-2" />
            New Budget
          </Button>
        </div>
      </div>

      {/* Overview Cards */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Spending</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {analyticsLoading ? '...' : formatCurrency(analytics?.total_spending || 0)}
            </div>
            <p className="text-xs text-muted-foreground">
              {timeRange === '7d' ? 'Last 7 days' : 
               timeRange === '30d' ? 'Last 30 days' :
               timeRange === '90d' ? 'Last 90 days' : 'Last year'}
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Budget Utilization</CardTitle>
            <Target className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {analyticsLoading ? '...' : `${(analytics?.budget_utilization || 0).toFixed(1)}%`}
            </div>
            <p className="text-xs text-muted-foreground">
              Across all active budgets
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Cost Optimizations</CardTitle>
            <TrendingDown className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {analytics?.cost_optimizations?.length || 0}
            </div>
            <p className="text-xs text-muted-foreground">
              Available recommendations
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Budgets</CardTitle>
            <AlertTriangle className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{budgets.length}</div>
            <p className="text-xs text-muted-foreground">
              {budgets.filter(b => b.utilization_percentage > 80).length} over 80%
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Main Content */}
      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="budgets">Budget Management</TabsTrigger>
          <TabsTrigger value="optimization">Cost Optimization</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            {/* Spending Trends Chart */}
            <Card className="md:col-span-2">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <BarChart3 className="h-5 w-5" />
                  Spending Trends
                </CardTitle>
                <CardDescription>Daily spending over time</CardDescription>
              </CardHeader>
              <CardContent>
                <SpendingChart 
                  data={analytics?.spending_trends || []}
                  loading={analyticsLoading}
                />
              </CardContent>
            </Card>

            {/* Top Spending Features */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <PieChart className="h-5 w-5" />
                  Top Spending Features
                </CardTitle>
                <CardDescription>Features consuming the most resources</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {analytics?.top_features?.slice(0, 5).map((feature, index) => (
                    <div key={index} className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div className="w-2 h-2 rounded-full bg-blue-500" />
                        <span className="text-sm font-medium">{feature.feature_name}</span>
                      </div>
                      <div className="text-right">
                        <div className="text-sm font-medium">
                          {formatCurrency(feature.spending)}
                        </div>
                        <div className="text-xs text-muted-foreground">
                          {feature.percentage.toFixed(1)}%
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Budget Alerts */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <AlertTriangle className="h-5 w-5" />
                  Budget Alerts
                </CardTitle>
                <CardDescription>Budgets requiring attention</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {budgets
                    .filter(budget => budget.utilization_percentage > 80)
                    .slice(0, 5)
                    .map((budget) => (
                      <div key={budget.id} className="flex items-center justify-between p-3 rounded-lg border">
                        <div>
                          <div className="font-medium text-sm">{budget.name}</div>
                          <div className="text-xs text-muted-foreground">
                            {formatCurrency(budget.current_spending)} / {formatCurrency(budget.amount)}
                          </div>
                        </div>
                        <div className="text-right">
                          <div className={`text-sm font-medium ${
                            budget.utilization_percentage > 95 ? 'text-red-600' :
                            budget.utilization_percentage > 80 ? 'text-amber-600' :
                            'text-green-600'
                          }`}>
                            {budget.utilization_percentage.toFixed(1)}%
                          </div>
                        </div>
                      </div>
                    ))}
                  {budgets.filter(b => b.utilization_percentage > 80).length === 0 && (
                    <div className="text-sm text-muted-foreground text-center py-4">
                      All budgets are within normal ranges
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="budgets" className="space-y-4">
          <BudgetManagement
            budgets={budgets}
            loading={budgetsLoading}
            onCreateBudget={() => setShowBudgetDialog(true)}
          />
        </TabsContent>

        <TabsContent value="optimization" className="space-y-4">
          <CostOptimization
            optimizations={analytics?.cost_optimizations || []}
            loading={analyticsLoading}
          />
        </TabsContent>
      </Tabs>
    </div>
  );
}
```

## 6. Supporting Components

### Create: `components/platform/ai-management/PromptEditor.tsx`

```typescript
'use client';

import { useState, useEffect } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { X, Plus, Code, Eye } from 'lucide-react';
import { Prompt, PromptCategory, PromptVariable } from '@/lib/types/platform/prompt-library';

interface PromptEditorProps {
  prompt?: Prompt | null;
  categories: PromptCategory[];
  onSave: () => void;
  onCancel: () => void;
}

export function PromptEditor({ prompt, categories, onSave, onCancel }: PromptEditorProps) {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    category_id: '',
    template: '',
    variables: [] as PromptVariable[],
    tags: [] as string[],
  });
  
  const [newTag, setNewTag] = useState('');
  const [previewMode, setPreviewMode] = useState(false);

  const queryClient = useQueryClient();

  useEffect(() => {
    if (prompt) {
      setFormData({
        name: prompt.name,
        description: prompt.description || '',
        category_id: prompt.category_id || '',
        template: prompt.template,
        variables: prompt.variables,
        tags: prompt.tags,
      });
    }
  }, [prompt]);

  const savePromptMutation = useMutation({
    mutationFn: async (data: typeof formData) => {
      const url = prompt 
        ? `/api/platform/ai-management/prompts/${prompt.id}`
        : '/api/platform/ai-management/prompts';
      
      const method = prompt ? 'PUT' : 'POST';
      
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      
      if (!response.ok) throw new Error('Failed to save prompt');
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['prompts'] });
      onSave();
    },
  });

  const addVariable = () => {
    setFormData(prev => ({
      ...prev,
      variables: [
        ...prev.variables,
        { name: '', type: 'text', description: '', required: false }
      ]
    }));
  };

  const updateVariable = (index: number, field: keyof PromptVariable, value: any) => {
    setFormData(prev => ({
      ...prev,
      variables: prev.variables.map((variable, i) => 
        i === index ? { ...variable, [field]: value } : variable
      )
    }));
  };

  const removeVariable = (index: number) => {
    setFormData(prev => ({
      ...prev,
      variables: prev.variables.filter((_, i) => i !== index)
    }));
  };

  const addTag = () => {
    if (newTag.trim() && !formData.tags.includes(newTag.trim())) {
      setFormData(prev => ({
        ...prev,
        tags: [...prev.tags, newTag.trim()]
      }));
      setNewTag('');
    }
  };

  const removeTag = (tag: string) => {
    setFormData(prev => ({
      ...prev,
      tags: prev.tags.filter(t => t !== tag)
    }));
  };

  const renderPreview = () => {
    let preview = formData.template;
    formData.variables.forEach(variable => {
      const placeholder = `{{${variable.name}}}`;
      const replacement = `<span class="bg-yellow-100 px-1 rounded">${variable.name}</span>`;
      preview = preview.replace(new RegExp(placeholder, 'g'), replacement);
    });
    
    return { __html: preview };
  };

  return (
    <Dialog open onOpenChange={() => onCancel()}>
      <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>
            {prompt ? 'Edit Prompt' : 'Create New Prompt'}
          </DialogTitle>
          <DialogDescription>
            {prompt 
              ? 'Modify the existing prompt template and configuration'
              : 'Create a new reusable prompt template with variables'
            }
          </DialogDescription>
        </DialogHeader>

        <div className="grid gap-6 py-4">
          {/* Basic Information */}
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="name">Name</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                placeholder="Enter prompt name"
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="category">Category</Label>
              <Select 
                value={formData.category_id} 
                onValueChange={(value) => setFormData(prev => ({ ...prev, category_id: value }))}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select a category" />
                </SelectTrigger>
                <SelectContent>
                  {categories.map((category) => (
                    <SelectItem key={category.id} value={category.id}>
                      {category.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              value={formData.description}
              onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
              placeholder="Describe what this prompt does..."
            />
          </div>

          {/* Template Editor */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <Label htmlFor="template">Template</Label>
              <div className="flex gap-2">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => setPreviewMode(!previewMode)}
                >
                  {previewMode ? <Code className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  {previewMode ? 'Edit' : 'Preview'}
                </Button>
              </div>
            </div>
            
            {previewMode ? (
              <Card>
                <CardContent className="p-4">
                  <div 
                    className="prose prose-sm max-w-none"
                    dangerouslySetInnerHTML={renderPreview()}
                  />
                </CardContent>
              </Card>
            ) : (
              <Textarea
                id="template"
                value={formData.template}
                onChange={(e) => setFormData(prev => ({ ...prev, template: e.target.value }))}
                placeholder="Enter your prompt template with {{variable}} placeholders..."
                className="h-32"
              />
            )}
          </div>

          {/* Variables */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <Label>Variables</Label>
              <Button type="button" variant="outline" size="sm" onClick={addVariable}>
                <Plus className="h-4 w-4 mr-2" />
                Add Variable
              </Button>
            </div>
            
            {formData.variables.map((variable, index) => (
              <Card key={index}>
                <CardHeader className="pb-3">
                  <div className="flex items-center justify-between">
                    <CardTitle className="text-sm">Variable {index + 1}</CardTitle>
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeVariable(index)}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                </CardHeader>
                <CardContent className="space-y-3">
                  <div className="grid gap-3 md:grid-cols-3">
                    <div>
                      <Label className="text-xs">Name</Label>
                      <Input
                        value={variable.name}
                        onChange={(e) => updateVariable(index, 'name', e.target.value)}
                        placeholder="Variable name"
                        className="text-sm"
                      />
                    </div>
                    
                    <div>
                      <Label className="text-xs">Type</Label>
                      <Select 
                        value={variable.type} 
                        onValueChange={(value) => updateVariable(index, 'type', value)}
                      >
                        <SelectTrigger className="text-sm">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="text">Text</SelectItem>
                          <SelectItem value="number">Number</SelectItem>
                          <SelectItem value="boolean">Boolean</SelectItem>
                          <SelectItem value="select">Select</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    
                    <div className="flex items-end">
                      <label className="flex items-center space-x-2 text-sm">
                        <input
                          type="checkbox"
                          checked={variable.required}
                          onChange={(e) => updateVariable(index, 'required', e.target.checked)}
                        />
                        <span>Required</span>
                      </label>
                    </div>
                  </div>
                  
                  <div>
                    <Label className="text-xs">Description</Label>
                    <Input
                      value={variable.description || ''}
                      onChange={(e) => updateVariable(index, 'description', e.target.value)}
                      placeholder="Describe this variable..."
                      className="text-sm"
                    />
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          {/* Tags */}
          <div className="space-y-2">
            <Label>Tags</Label>
            <div className="flex flex-wrap gap-2 mb-2">
              {formData.tags.map((tag) => (
                <Badge key={tag} variant="secondary" className="px-2 py-1">
                  {tag}
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="h-auto p-0 ml-2"
                    onClick={() => removeTag(tag)}
                  >
                    <X className="h-3 w-3" />
                  </Button>
                </Badge>
              ))}
            </div>
            <div className="flex gap-2">
              <Input
                value={newTag}
                onChange={(e) => setNewTag(e.target.value)}
                placeholder="Add a tag..."
                onKeyPress={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault();
                    addTag();
                  }
                }}
              />
              <Button type="button" variant="outline" onClick={addTag}>
                Add
              </Button>
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onCancel}>
            Cancel
          </Button>
          <Button 
            onClick={() => savePromptMutation.mutate(formData)}
            disabled={savePromptMutation.isPending || !formData.name || !formData.template}
          >
            {savePromptMutation.isPending ? 'Saving...' : 'Save Prompt'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
```

## Implementation Notes

1. **Database First**: Execute the migration script to create all required tables
2. **Service Layer**: Implement the business logic services before API endpoints
3. **API Integration**: Create RESTful endpoints with proper authentication
4. **Frontend Components**: Build reactive UI components with real-time updates
5. **Testing**: Add unit tests for services and integration tests for APIs

## Success Metrics

- [ ] All prompt operations (create, read, update, delete) working
- [ ] Version control system functional
- [ ] Full-text search working on prompts
- [ ] Budget management with alerts implemented
- [ ] Cost optimization recommendations generated
- [ ] Real-time spending analytics dashboard
- [ ] Notification system operational

## Timeline Estimate
- Database & Backend: 2-3 days
- API Endpoints: 1-2 days  
- Frontend Components: 3-4 days
- Integration & Testing: 1-2 days
- **Total: 7-11 days**

---

This completes Phase 3, providing comprehensive productivity tools for prompt management and spending analytics. The implementation includes version control, search capabilities, budget management, cost optimization, and real-time monitoring.