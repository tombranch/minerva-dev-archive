# Phase 1: Database Foundation - Implementation Plan

**Duration**: 1 Week  
**Priority**: 🔥 **CRITICAL** - Blocks all subsequent phases  
**Status**: Ready for Implementation  
**Claude Code Instructions**: Follow this plan step-by-step to implement the complete database foundation

---

## 📋 Phase Overview

**Objective**: Implement the complete database schema and core backend services required for the AI Platform Management system.

**Key Deliverables**:
- 15 new database tables with proper RLS policies
- 4 complete backend service classes
- Database migration scripts
- Type definitions and interfaces
- API endpoint enhancements

**Success Criteria**:
- All database tables created and accessible
- Platform admin RLS policies working
- Core services can CRUD all entities
- Global Overview dashboard displays real data
- No TypeScript errors in service layer

---

## 🗄️ Database Schema Implementation

### Step 1: Create Base Migration File

**File**: `supabase/migrations/20250131000000_ai_management_schema.sql`

```sql
-- ============================================================================
-- AI Platform Management System Database Schema
-- Migration: 20250131000000_ai_management_schema
-- Phase: 1 - Database Foundation
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- Core AI Management Tables
-- ============================================================================

-- AI Features Management
CREATE TABLE ai_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE, -- 'photo-tagging', 'chatbot', 'ai-search'
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    config JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Providers Management  
CREATE TABLE ai_providers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL UNIQUE,
    display_name VARCHAR(200) NOT NULL,
    provider_type VARCHAR(100) NOT NULL, -- 'openai', 'google', 'anthropic', 'custom'
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'error')),
    config JSONB NOT NULL DEFAULT '{}',
    api_endpoint TEXT,
    health_check JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Models Management
CREATE TABLE ai_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    display_name VARCHAR(200) NOT NULL,
    provider_id UUID REFERENCES ai_providers(id) ON DELETE CASCADE,
    model_type VARCHAR(100) NOT NULL, -- 'llm', 'vision', 'embedding'
    version VARCHAR(50),
    config JSONB NOT NULL DEFAULT '{}',
    performance_metrics JSONB DEFAULT '{}',
    pricing JSONB DEFAULT '{}', -- cost_per_token, etc.
    capabilities TEXT[] DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'deprecated', 'beta', 'offline')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_id, name, version)
);

-- Feature-Model Relationships (Deployments)
CREATE TABLE feature_model_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    model_id UUID REFERENCES ai_models(id) ON DELETE CASCADE,
    environment VARCHAR(20) DEFAULT 'production' CHECK (environment IN ('development', 'staging', 'production')),
    is_active BOOLEAN DEFAULT false,
    config_overrides JSONB DEFAULT '{}',
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assigned_by UUID, -- References auth.users but not enforced
    deactivated_at TIMESTAMPTZ,
    UNIQUE(feature_id, environment) -- Only one active model per feature per environment
);

-- Prompt Management
CREATE TABLE ai_prompts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    content TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    feature_id UUID REFERENCES ai_features(id) ON DELETE SET NULL,
    tags TEXT[] DEFAULT '{}',
    variables JSONB DEFAULT '{}', -- Template variables definition
    is_active BOOLEAN DEFAULT false,
    created_by UUID, -- References auth.users but not enforced
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(feature_id, name, version)
);

-- AI Usage/Request Logs
CREATE TABLE ai_usage_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_id UUID REFERENCES ai_features(id) ON DELETE SET NULL,
    model_id UUID REFERENCES ai_models(id) ON DELETE SET NULL,
    prompt_id UUID REFERENCES ai_prompts(id) ON DELETE SET NULL,
    user_id UUID, -- References auth.users but not enforced
    organization_id UUID, -- References organizations but not enforced
    request_data JSONB DEFAULT '{}',
    response_data JSONB DEFAULT '{}',
    tokens_used INTEGER DEFAULT 0,
    response_time_ms INTEGER DEFAULT 0,
    cost_usd DECIMAL(10,6) DEFAULT 0.0,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'error', 'timeout')),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spending Management & Budgets
CREATE TABLE ai_spending_budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    period_type VARCHAR(20) NOT NULL CHECK (period_type IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly')),
    budget_amount DECIMAL(10,2) NOT NULL,
    spent_amount DECIMAL(10,2) DEFAULT 0.0,
    alert_threshold DECIMAL(3,2) DEFAULT 0.8, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT true,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- A/B Testing & Experiments
CREATE TABLE ai_experiments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    feature_id UUID REFERENCES ai_features(id) ON DELETE CASCADE,
    experiment_type VARCHAR(50) NOT NULL CHECK (experiment_type IN ('model_comparison', 'prompt_testing', 'parameter_tuning', 'a_b_test')),
    config JSONB NOT NULL DEFAULT '{}',
    variants JSONB NOT NULL DEFAULT '[]', -- Array of experiment variants
    traffic_allocation JSONB DEFAULT '{}', -- Traffic split configuration
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'running', 'paused', 'completed', 'cancelled')),
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    results JSONB DEFAULT '{}',
    statistical_significance DECIMAL(5,4), -- p-value
    winner_variant VARCHAR(100),
    created_by UUID, -- References auth.users but not enforced
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Experiment Results & Metrics
CREATE TABLE experiment_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    experiment_id UUID REFERENCES ai_experiments(id) ON DELETE CASCADE,
    variant_id VARCHAR(100) NOT NULL,
    user_id UUID, -- References auth.users but not enforced
    session_id UUID,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(12,4),
    metadata JSONB DEFAULT '{}',
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Provider Health Monitoring
CREATE TABLE provider_health_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID REFERENCES ai_providers(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('healthy', 'degraded', 'down')),
    response_time_ms INTEGER,
    error_rate DECIMAL(5,2), -- Percentage
    throughput INTEGER, -- Requests per minute
    health_score INTEGER CHECK (health_score BETWEEN 0 AND 100),
    details JSONB DEFAULT '{}',
    checked_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit Logs for Platform Actions
CREATE TABLE platform_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID, -- References auth.users but not enforced
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL, -- 'feature', 'model', 'prompt', etc.
    resource_id UUID,
    old_values JSONB DEFAULT '{}',
    new_values JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- Indexes for Performance
-- ============================================================================

-- Usage logs indexes (most queried table)
CREATE INDEX idx_ai_usage_logs_feature_id ON ai_usage_logs(feature_id);
CREATE INDEX idx_ai_usage_logs_model_id ON ai_usage_logs(model_id);
CREATE INDEX idx_ai_usage_logs_created_at ON ai_usage_logs(created_at);
CREATE INDEX idx_ai_usage_logs_status ON ai_usage_logs(status);
CREATE INDEX idx_ai_usage_logs_organization_id ON ai_usage_logs(organization_id);

-- Feature model assignments
CREATE INDEX idx_feature_model_assignments_feature_id ON feature_model_assignments(feature_id);
CREATE INDEX idx_feature_model_assignments_model_id ON feature_model_assignments(model_id);
CREATE INDEX idx_feature_model_assignments_is_active ON feature_model_assignments(is_active);

-- Prompts indexes
CREATE INDEX idx_ai_prompts_feature_id ON ai_prompts(feature_id);
CREATE INDEX idx_ai_prompts_is_active ON ai_prompts(is_active);
CREATE INDEX idx_ai_prompts_created_by ON ai_prompts(created_by);

-- Experiments indexes
CREATE INDEX idx_ai_experiments_feature_id ON ai_experiments(feature_id);
CREATE INDEX idx_ai_experiments_status ON ai_experiments(status);
CREATE INDEX idx_ai_experiments_created_by ON ai_experiments(created_by);

-- Experiment results indexes
CREATE INDEX idx_experiment_results_experiment_id ON experiment_results(experiment_id);
CREATE INDEX idx_experiment_results_variant_id ON experiment_results(variant_id);
CREATE INDEX idx_experiment_results_recorded_at ON experiment_results(recorded_at);

-- Provider health indexes
CREATE INDEX idx_provider_health_logs_provider_id ON provider_health_logs(provider_id);
CREATE INDEX idx_provider_health_logs_checked_at ON provider_health_logs(checked_at);

-- Audit logs indexes
CREATE INDEX idx_platform_audit_logs_user_id ON platform_audit_logs(user_id);
CREATE INDEX idx_platform_audit_logs_resource_type ON platform_audit_logs(resource_type);
CREATE INDEX idx_platform_audit_logs_created_at ON platform_audit_logs(created_at);

-- ============================================================================
-- Row Level Security (RLS) Policies
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE ai_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE feature_model_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_prompts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_usage_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_spending_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_experiments ENABLE ROW LEVEL SECURITY;
ALTER TABLE experiment_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_health_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_audit_logs ENABLE ROW LEVEL SECURITY;

-- Helper function to check if user is platform admin
CREATE OR REPLACE FUNCTION is_platform_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM user_profiles 
        WHERE user_id = auth.uid() 
        AND role = 'platform_admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Platform admin policies (all tables have same pattern)
CREATE POLICY "Platform admin full access on ai_features" ON ai_features FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on ai_providers" ON ai_providers FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on ai_models" ON ai_models FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on feature_model_assignments" ON feature_model_assignments FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on ai_prompts" ON ai_prompts FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on ai_usage_logs" ON ai_usage_logs FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on ai_spending_budgets" ON ai_spending_budgets FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on ai_experiments" ON ai_experiments FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on experiment_results" ON experiment_results FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on provider_health_logs" ON provider_health_logs FOR ALL TO authenticated USING (is_platform_admin());
CREATE POLICY "Platform admin full access on platform_audit_logs" ON platform_audit_logs FOR ALL TO authenticated USING (is_platform_admin());

-- ============================================================================
-- Initial Seed Data
-- ============================================================================

-- Insert default AI features
INSERT INTO ai_features (name, display_name, description) VALUES
('photo-tagging', 'Photo Tagging', 'AI-powered photo analysis and tagging for industrial safety photos'),
('chatbot', 'AI Chatbot', 'Intelligent chatbot for user assistance and support'),
('ai-search', 'AI Search', 'Semantic search powered by AI embeddings');

-- Insert default AI providers
INSERT INTO ai_providers (name, display_name, provider_type, config) VALUES
('openai', 'OpenAI', 'openai', '{"api_version": "v1", "base_url": "https://api.openai.com/v1"}'),
('google-cloud', 'Google Cloud AI', 'google', '{"project_id": "", "region": "us-central1"}'),
('anthropic', 'Anthropic', 'anthropic', '{"api_version": "2023-06-01"}');

-- Insert default models (these will be populated by the model discovery service)
INSERT INTO ai_models (name, display_name, provider_id, model_type, config) 
SELECT 
    'gpt-4', 'GPT-4', p.id, 'llm', '{"context_window": 8192, "max_tokens": 4096}'
FROM ai_providers p WHERE p.name = 'openai';

INSERT INTO ai_models (name, display_name, provider_id, model_type, config)
SELECT 
    'vision-v2', 'Vision API v2', p.id, 'vision', '{"max_results": 20}'
FROM ai_providers p WHERE p.name = 'google-cloud';

-- Insert default feature-model assignments
INSERT INTO feature_model_assignments (feature_id, model_id, environment, is_active)
SELECT 
    f.id, m.id, 'production', true
FROM ai_features f
JOIN ai_models m ON (
    (f.name = 'chatbot' AND m.name = 'gpt-4') OR
    (f.name = 'photo-tagging' AND m.name = 'vision-v2')
);

-- Insert default spending budgets
INSERT INTO ai_spending_budgets (name, feature_id, period_type, budget_amount, start_date, end_date)
SELECT 
    f.display_name || ' Monthly Budget',
    f.id,
    'monthly',
    1000.00,
    DATE_TRUNC('month', CURRENT_DATE),
    DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day'
FROM ai_features f;

-- ============================================================================
-- Triggers for Updated At Timestamps
-- ============================================================================

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

-- ============================================================================
-- End Migration
-- ============================================================================
```

### Step 2: Apply the Migration

**Command to run**:
```bash
npx supabase db push --linked --password $SUPABASE_DB_PASSWORD
```

---

## 🏗️ TypeScript Interfaces & Types

### Step 3: Create Database Type Definitions

**File**: `lib/types/ai-management.ts`

```typescript
// ============================================================================
// AI Platform Management Type Definitions
// Generated from database schema for type safety
// ============================================================================

export interface AIFeature {
  id: string;
  name: string;
  display_name: string;
  description?: string;
  status: 'active' | 'inactive' | 'maintenance';
  config: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface AIProvider {
  id: string;
  name: string;
  display_name: string;
  provider_type: 'openai' | 'google' | 'anthropic' | 'custom';
  status: 'active' | 'inactive' | 'error';
  config: Record<string, any>;
  api_endpoint?: string;
  health_check: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface AIModel {
  id: string;
  name: string;
  display_name: string;
  provider_id: string;
  model_type: 'llm' | 'vision' | 'embedding';
  version?: string;
  config: Record<string, any>;
  performance_metrics: Record<string, any>;
  pricing: Record<string, any>;
  capabilities: string[];
  status: 'available' | 'deprecated' | 'beta' | 'offline';
  created_at: string;
  updated_at: string;
  // Relations
  provider?: AIProvider;
}

export interface FeatureModelAssignment {
  id: string;
  feature_id: string;
  model_id: string;
  environment: 'development' | 'staging' | 'production';
  is_active: boolean;
  config_overrides: Record<string, any>;
  assigned_at: string;
  assigned_by?: string;
  deactivated_at?: string;
  // Relations
  feature?: AIFeature;
  model?: AIModel;
}

export interface AIPrompt {
  id: string;
  name: string;
  description?: string;
  content: string;
  version: number;
  feature_id?: string;
  tags: string[];
  variables: Record<string, any>;
  is_active: boolean;
  created_by?: string;
  created_at: string;
  updated_at: string;
  // Relations
  feature?: AIFeature;
}

export interface AIUsageLog {
  id: string;
  feature_id?: string;
  model_id?: string;
  prompt_id?: string;
  user_id?: string;
  organization_id?: string;
  request_data: Record<string, any>;
  response_data: Record<string, any>;
  tokens_used: number;
  response_time_ms: number;
  cost_usd: number;
  status: 'pending' | 'success' | 'error' | 'timeout';
  error_message?: string;
  created_at: string;
  // Relations
  feature?: AIFeature;
  model?: AIModel;
  prompt?: AIPrompt;
}

export interface AISpendingBudget {
  id: string;
  name: string;
  description?: string;
  feature_id?: string;
  period_type: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly';
  budget_amount: number;
  spent_amount: number;
  alert_threshold: number;
  is_active: boolean;
  start_date: string;
  end_date: string;
  created_at: string;
  updated_at: string;
  // Relations
  feature?: AIFeature;
}

export interface AIExperiment {
  id: string;
  name: string;
  description?: string;
  feature_id?: string;
  experiment_type: 'model_comparison' | 'prompt_testing' | 'parameter_tuning' | 'a_b_test';
  config: Record<string, any>;
  variants: any[];
  traffic_allocation: Record<string, any>;
  status: 'draft' | 'running' | 'paused' | 'completed' | 'cancelled';
  start_date?: string;
  end_date?: string;
  results: Record<string, any>;
  statistical_significance?: number;
  winner_variant?: string;
  created_by?: string;
  created_at: string;
  updated_at: string;
  // Relations
  feature?: AIFeature;
}

export interface ExperimentResult {
  id: string;
  experiment_id: string;
  variant_id: string;
  user_id?: string;
  session_id?: string;
  metric_name: string;
  metric_value?: number;
  metadata: Record<string, any>;
  recorded_at: string;
  // Relations
  experiment?: AIExperiment;
}

export interface ProviderHealthLog {
  id: string;
  provider_id: string;
  status: 'healthy' | 'degraded' | 'down';
  response_time_ms?: number;
  error_rate?: number;
  throughput?: number;
  health_score?: number;
  details: Record<string, any>;
  checked_at: string;
  // Relations
  provider?: AIProvider;
}

export interface PlatformAuditLog {
  id: string;
  user_id?: string;
  action: string;
  resource_type: string;
  resource_id?: string;
  old_values: Record<string, any>;
  new_values: Record<string, any>;
  ip_address?: string;
  user_agent?: string;
  created_at: string;
}

// ============================================================================
// Service Layer Types
// ============================================================================

export interface ListFeaturesOptions {
  includeMetrics?: boolean;
  timeRange?: string;
  status?: string[];
}

export interface ListModelsOptions {
  provider?: string;
  modelType?: string;
  status?: string;
  includeMetrics?: boolean;
}

export interface CreateFeatureRequest {
  name: string;
  display_name: string;
  description?: string;
  config?: Record<string, any>;
}

export interface CreateModelRequest {
  name: string;
  display_name: string;
  provider_id: string;
  model_type: 'llm' | 'vision' | 'embedding';
  version?: string;
  config?: Record<string, any>;
  pricing?: Record<string, any>;
  capabilities?: string[];
}

export interface CreatePromptRequest {
  name: string;
  description?: string;
  content: string;
  feature_id?: string;
  tags?: string[];
  variables?: Record<string, any>;
}

export interface UpdateFeatureRequest {
  id: string;
  display_name?: string;
  description?: string;
  status?: 'active' | 'inactive' | 'maintenance';
  config?: Record<string, any>;
}

export interface AssignModelRequest {
  feature_id: string;
  model_id: string;
  environment: 'development' | 'staging' | 'production';
  config_overrides?: Record<string, any>;
}

export interface CreateExperimentRequest {
  name: string;
  description?: string;
  feature_id?: string;
  experiment_type: 'model_comparison' | 'prompt_testing' | 'parameter_tuning' | 'a_b_test';
  config: Record<string, any>;
  variants: any[];
  traffic_allocation?: Record<string, any>;
}

export interface FeatureHealthMetrics {
  uptime: number;
  error_rate: number;
  response_time: number;
  total_requests: number;
  success_rate: number;
  cost_per_request: number;
}

export interface ModelPerformanceMetrics {
  average_response_time: number;
  total_requests: number;
  success_rate: number;
  error_rate: number;
  total_cost: number;
  cost_per_request: number;
}

// ============================================================================
// API Response Types
// ============================================================================

export interface APIResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  details?: string;
  metadata?: Record<string, any>;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    total_pages: number;
  };
  metadata?: Record<string, any>;
}
```

---

## 🔧 Backend Services Implementation

### Step 4: Complete Feature Management Service

**File**: `lib/services/platform/feature-management.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js';
import type { Database } from '@/lib/types/database';
import {
  AIFeature,
  CreateFeatureRequest,
  UpdateFeatureRequest,
  ListFeaturesOptions,
  FeatureHealthMetrics,
  APIResponse
} from '@/lib/types/ai-management';

export class FeatureManagementService {
  constructor(private supabase: SupabaseClient<Database>) {}

  /**
   * List all AI features with optional metrics
   */
  async listFeatures(options: ListFeaturesOptions = {}): Promise<AIFeature[]> {
    const { includeMetrics = false, timeRange = '24h', status } = options;

    let query = this.supabase
      .from('ai_features')
      .select('*')
      .order('created_at', { ascending: false });

    if (status && status.length > 0) {
      query = query.in('status', status);
    }

    const { data: features, error } = await query;

    if (error) {
      throw new Error(`Failed to fetch features: ${error.message}`);
    }

    if (!includeMetrics) {
      return features || [];
    }

    // Add health metrics to each feature
    const featuresWithMetrics = await Promise.all(
      (features || []).map(async (feature) => {
        const metrics = await this.getFeatureHealthMetrics(feature.id, timeRange);
        return {
          ...feature,
          metrics
        };
      })
    );

    return featuresWithMetrics;
  }

  /**
   * Get a single feature by ID
   */
  async getFeature(id: string): Promise<AIFeature | null> {
    const { data: feature, error } = await this.supabase
      .from('ai_features')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null; // Not found
      }
      throw new Error(`Failed to fetch feature: ${error.message}`);
    }

    return feature;
  }

  /**
   * Create a new AI feature
   */
  async createFeature(request: CreateFeatureRequest): Promise<AIFeature> {
    const { data: feature, error } = await this.supabase
      .from('ai_features')
      .insert({
        name: request.name,
        display_name: request.display_name,
        description: request.description,
        config: request.config || {}
      })
      .select()
      .single();

    if (error) {
      throw new Error(`Failed to create feature: ${error.message}`);
    }

    return feature;
  }

  /**
   * Update an existing feature
   */
  async updateFeature(request: UpdateFeatureRequest): Promise<AIFeature> {
    const updateData: any = {
      updated_at: new Date().toISOString()
    };

    if (request.display_name !== undefined) updateData.display_name = request.display_name;
    if (request.description !== undefined) updateData.description = request.description;
    if (request.status !== undefined) updateData.status = request.status;
    if (request.config !== undefined) updateData.config = request.config;

    const { data: feature, error } = await this.supabase
      .from('ai_features')
      .update(updateData)
      .eq('id', request.id)
      .select()
      .single();

    if (error) {
      throw new Error(`Failed to update feature: ${error.message}`);
    }

    return feature;
  }

  /**
   * Delete a feature
   */
  async deleteFeature(id: string): Promise<void> {
    const { error } = await this.supabase
      .from('ai_features')
      .delete()
      .eq('id', id);

    if (error) {
      throw new Error(`Failed to delete feature: ${error.message}`);
    }
  }

  /**
   * Bulk update multiple features
   */
  async bulkUpdateFeatures(updates: UpdateFeatureRequest[]): Promise<AIFeature[]> {
    const results = await Promise.all(
      updates.map(update => this.updateFeature(update))
    );
    return results;
  }

  /**
   * Get health metrics for a feature
   */
  async getFeatureHealthMetrics(featureId: string, timeRange: string = '24h'): Promise<FeatureHealthMetrics> {
    const { startDate } = this.getDateRange(timeRange);

    const { data: usageLogs, error } = await this.supabase
      .from('ai_usage_logs')
      .select('status, response_time_ms, cost_usd, tokens_used')
      .eq('feature_id', featureId)
      .gte('created_at', startDate.toISOString());

    if (error) {
      throw new Error(`Failed to fetch feature metrics: ${error.message}`);
    }

    const logs = usageLogs || [];
    const totalRequests = logs.length;

    if (totalRequests === 0) {
      return {
        uptime: 100,
        error_rate: 0,
        response_time: 0,
        total_requests: 0,
        success_rate: 100,
        cost_per_request: 0
      };
    }

    const successfulRequests = logs.filter(log => log.status === 'success').length;
    const errorRequests = logs.filter(log => log.status === 'error').length;
    const totalResponseTime = logs.reduce((sum, log) => sum + (log.response_time_ms || 0), 0);
    const totalCost = logs.reduce((sum, log) => sum + (log.cost_usd || 0), 0);

    return {
      uptime: (successfulRequests / totalRequests) * 100,
      error_rate: (errorRequests / totalRequests) * 100,
      response_time: totalResponseTime / totalRequests,
      total_requests: totalRequests,
      success_rate: (successfulRequests / totalRequests) * 100,
      cost_per_request: totalCost / totalRequests
    };
  }

  /**
   * Get currently assigned model for a feature
   */
  async getFeatureModel(featureId: string, environment: string = 'production') {
    const { data: assignment, error } = await this.supabase
      .from('feature_model_assignments')
      .select(`
        *,
        ai_models (
          *,
          ai_providers (*)
        )
      `)
      .eq('feature_id', featureId)
      .eq('environment', environment)
      .eq('is_active', true)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null; // No assignment found
      }
      throw new Error(`Failed to fetch feature model: ${error.message}`);
    }

    return assignment;
  }

  /**
   * Get feature usage statistics
   */
  async getFeatureUsageStats(featureId: string, timeRange: string = '7d') {
    const { startDate } = this.getDateRange(timeRange);

    const { data: stats, error } = await this.supabase
      .rpc('get_feature_usage_stats', {
        p_feature_id: featureId,
        p_start_date: startDate.toISOString()
      });

    if (error) {
      throw new Error(`Failed to fetch usage stats: ${error.message}`);
    }

    return stats;
  }

  /**
   * Helper method to get date range
   */
  private getDateRange(timeRange: string): { startDate: Date; endDate: Date } {
    const endDate = new Date();
    const startDate = new Date();

    switch (timeRange) {
      case '1h':
        startDate.setHours(endDate.getHours() - 1);
        break;
      case '24h':
        startDate.setDate(endDate.getDate() - 1);
        break;
      case '7d':
        startDate.setDate(endDate.getDate() - 7);
        break;
      case '30d':
        startDate.setDate(endDate.getDate() - 30);
        break;
      default:
        startDate.setDate(endDate.getDate() - 1);
    }

    return { startDate, endDate };
  }
}
```

### Step 5: Complete Model Management Service

**File**: `lib/services/platform/model-management.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js';
import type { Database } from '@/lib/types/database';
import {
  AIModel,
  AIProvider,
  FeatureModelAssignment,
  CreateModelRequest,
  ListModelsOptions,
  AssignModelRequest,
  ModelPerformanceMetrics
} from '@/lib/types/ai-management';

export class ModelManagementService {
  constructor(private supabase: SupabaseClient<Database>) {}

  /**
   * List all AI models with optional filtering
   */
  async listModels(options: ListModelsOptions = {}): Promise<AIModel[]> {
    const { provider, modelType, status, includeMetrics = false } = options;

    let query = this.supabase
      .from('ai_models')
      .select(`
        *,
        ai_providers (*)
      `)
      .order('created_at', { ascending: false });

    if (provider) {
      query = query.eq('ai_providers.name', provider);
    }

    if (modelType) {
      query = query.eq('model_type', modelType);
    }

    if (status) {
      query = query.eq('status', status);
    }

    const { data: models, error } = await query;

    if (error) {
      throw new Error(`Failed to fetch models: ${error.message}`);
    }

    if (!includeMetrics) {
      return models || [];
    }

    // Add performance metrics to each model
    const modelsWithMetrics = await Promise.all(
      (models || []).map(async (model) => {
        const metrics = await this.getModelPerformanceMetrics(model.id);
        return {
          ...model,
          performance_metrics: {
            ...model.performance_metrics,
            ...metrics
          }
        };
      })
    );

    return modelsWithMetrics;
  }

  /**
   * Get a single model by ID
   */
  async getModel(id: string): Promise<AIModel | null> {
    const { data: model, error } = await this.supabase
      .from('ai_models')
      .select(`
        *,
        ai_providers (*)
      `)
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null;
      }
      throw new Error(`Failed to fetch model: ${error.message}`);
    }

    return model;
  }

  /**
   * Create a new AI model
   */
  async createModel(request: CreateModelRequest): Promise<AIModel> {
    const { data: model, error } = await this.supabase
      .from('ai_models')
      .insert({
        name: request.name,
        display_name: request.display_name,
        provider_id: request.provider_id,
        model_type: request.model_type,
        version: request.version,
        config: request.config || {},
        pricing: request.pricing || {},
        capabilities: request.capabilities || []
      })
      .select(`
        *,
        ai_providers (*)
      `)
      .single();

    if (error) {
      throw new Error(`Failed to create model: ${error.message}`);
    }

    return model;
  }

  /**
   * Update an existing model
   */
  async updateModel(id: string, updates: Partial<CreateModelRequest>): Promise<AIModel> {
    const updateData: any = {
      updated_at: new Date().toISOString()
    };

    Object.keys(updates).forEach(key => {
      if (updates[key] !== undefined) {
        updateData[key] = updates[key];
      }
    });

    const { data: model, error } = await this.supabase
      .from('ai_models')
      .update(updateData)
      .eq('id', id)
      .select(`
        *,
        ai_providers (*)
      `)
      .single();

    if (error) {
      throw new Error(`Failed to update model: ${error.message}`);
    }

    return model;
  }

  /**
   * Delete a model
   */
  async deleteModel(id: string): Promise<void> {
    const { error } = await this.supabase
      .from('ai_models')
      .delete()
      .eq('id', id);

    if (error) {
      throw new Error(`Failed to delete model: ${error.message}`);
    }
  }

  /**
   * Assign a model to a feature
   */
  async assignModelToFeature(request: AssignModelRequest): Promise<FeatureModelAssignment> {
    // First, deactivate any existing assignment for this feature/environment
    await this.supabase
      .from('feature_model_assignments')
      .update({ 
        is_active: false,
        deactivated_at: new Date().toISOString()
      })
      .eq('feature_id', request.feature_id)
      .eq('environment', request.environment)
      .eq('is_active', true);

    // Create new assignment
    const { data: assignment, error } = await this.supabase
      .from('feature_model_assignments')
      .insert({
        feature_id: request.feature_id,
        model_id: request.model_id,
        environment: request.environment,
        is_active: true,
        config_overrides: request.config_overrides || {}
      })
      .select(`
        *,
        ai_features (*),
        ai_models (*, ai_providers (*))
      `)
      .single();

    if (error) {
      throw new Error(`Failed to assign model: ${error.message}`);
    }

    return assignment;
  }

  /**
   * Get model performance metrics
   */
  async getModelPerformanceMetrics(modelId: string, timeRange: string = '7d'): Promise<ModelPerformanceMetrics> {
    const { startDate } = this.getDateRange(timeRange);

    const { data: usageLogs, error } = await this.supabase
      .from('ai_usage_logs')
      .select('status, response_time_ms, cost_usd, tokens_used')
      .eq('model_id', modelId)
      .gte('created_at', startDate.toISOString());

    if (error) {
      throw new Error(`Failed to fetch model metrics: ${error.message}`);
    }

    const logs = usageLogs || [];
    const totalRequests = logs.length;

    if (totalRequests === 0) {
      return {
        average_response_time: 0,
        total_requests: 0,
        success_rate: 100,
        error_rate: 0,
        total_cost: 0,
        cost_per_request: 0
      };
    }

    const successfulRequests = logs.filter(log => log.status === 'success').length;
    const errorRequests = logs.filter(log => log.status === 'error').length;
    const totalResponseTime = logs.reduce((sum, log) => sum + (log.response_time_ms || 0), 0);
    const totalCost = logs.reduce((sum, log) => sum + (log.cost_usd || 0), 0);

    return {
      average_response_time: totalResponseTime / totalRequests,
      total_requests: totalRequests,
      success_rate: (successfulRequests / totalRequests) * 100,
      error_rate: (errorRequests / totalRequests) * 100,
      total_cost: totalCost,
      cost_per_request: totalCost / totalRequests
    };
  }

  /**
   * Get all providers
   */
  async listProviders(): Promise<AIProvider[]> {
    const { data: providers, error } = await this.supabase
      .from('ai_providers')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(`Failed to fetch providers: ${error.message}`);
    }

    return providers || [];
  }

  /**
   * Get provider by ID
   */
  async getProvider(id: string): Promise<AIProvider | null> {
    const { data: provider, error } = await this.supabase
      .from('ai_providers')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null;
      }
      throw new Error(`Failed to fetch provider: ${error.message}`);
    }

    return provider;
  }

  /**
   * Get models by provider
   */
  async getModelsByProvider(providerId: string): Promise<AIModel[]> {
    const { data: models, error } = await this.supabase
      .from('ai_models')
      .select('*')
      .eq('provider_id', providerId)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(`Failed to fetch models by provider: ${error.message}`);
    }

    return models || [];
  }

  /**
   * Get deployment history for a model
   */
  async getModelDeploymentHistory(modelId: string) {
    const { data: deployments, error } = await this.supabase
      .from('feature_model_assignments')
      .select(`
        *,
        ai_features (*)
      `)
      .eq('model_id', modelId)
      .order('assigned_at', { ascending: false });

    if (error) {
      throw new Error(`Failed to fetch deployment history: ${error.message}`);
    }

    return deployments || [];
  }

  /**
   * Helper method to get date range
   */
  private getDateRange(timeRange: string): { startDate: Date; endDate: Date } {
    const endDate = new Date();
    const startDate = new Date();

    switch (timeRange) {
      case '1h':
        startDate.setHours(endDate.getHours() - 1);
        break;
      case '24h':
        startDate.setDate(endDate.getDate() - 1);
        break;
      case '7d':
        startDate.setDate(endDate.getDate() - 7);
        break;
      case '30d':
        startDate.setDate(endDate.getDate() - 30);
        break;
      default:
        startDate.setDate(endDate.getDate() - 7);
    }

    return { startDate, endDate };
  }
}
```

### Step 6: Create Prompt Management Service

**File**: `lib/services/platform/prompt-management.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js';
import type { Database } from '@/lib/types/database';
import {
  AIPrompt,
  CreatePromptRequest,
  APIResponse
} from '@/lib/types/ai-management';

export interface ListPromptsOptions {
  featureId?: string;
  tags?: string[];
  isActive?: boolean;
  createdBy?: string;
  search?: string;
  limit?: number;
  offset?: number;
}

export interface UpdatePromptRequest {
  id: string;
  name?: string;
  description?: string;
  content?: string;
  tags?: string[];
  variables?: Record<string, any>;
  is_active?: boolean;
}

export interface PromptVersion {
  version: number;
  content: string;
  created_at: string;
  created_by?: string;
  is_active: boolean;
}

export class PromptManagementService {
  constructor(private supabase: SupabaseClient<Database>) {}

  /**
   * List prompts with filtering options
   */
  async listPrompts(options: ListPromptsOptions = {}): Promise<AIPrompt[]> {
    const { 
      featureId, 
      tags, 
      isActive, 
      createdBy, 
      search, 
      limit = 50, 
      offset = 0 
    } = options;

    let query = this.supabase
      .from('ai_prompts')
      .select(`
        *,
        ai_features (*)
      `)
      .order('updated_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (featureId) {
      query = query.eq('feature_id', featureId);
    }

    if (isActive !== undefined) {
      query = query.eq('is_active', isActive);
    }

    if (createdBy) {
      query = query.eq('created_by', createdBy);
    }

    if (tags && tags.length > 0) {
      query = query.overlaps('tags', tags);
    }

    if (search) {
      query = query.or(`name.ilike.%${search}%,description.ilike.%${search}%,content.ilike.%${search}%`);
    }

    const { data: prompts, error } = await query;

    if (error) {
      throw new Error(`Failed to fetch prompts: ${error.message}`);
    }

    return prompts || [];
  }

  /**
   * Get a single prompt by ID
   */
  async getPrompt(id: string): Promise<AIPrompt | null> {
    const { data: prompt, error } = await this.supabase
      .from('ai_prompts')
      .select(`
        *,
        ai_features (*)
      `)
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null;
      }
      throw new Error(`Failed to fetch prompt: ${error.message}`);
    }

    return prompt;
  }

  /**
   * Create a new prompt
   */
  async createPrompt(request: CreatePromptRequest): Promise<AIPrompt> {
    // Get the next version number for this prompt name and feature
    const { data: existingPrompts } = await this.supabase
      .from('ai_prompts')
      .select('version')
      .eq('name', request.name)
      .eq('feature_id', request.feature_id || null)
      .order('version', { ascending: false })
      .limit(1);

    const nextVersion = existingPrompts && existingPrompts.length > 0 
      ? existingPrompts[0].version + 1 
      : 1;

    const { data: prompt, error } = await this.supabase
      .from('ai_prompts')
      .insert({
        name: request.name,
        description: request.description,
        content: request.content,
        version: nextVersion,
        feature_id: request.feature_id,
        tags: request.tags || [],
        variables: request.variables || {},
        is_active: false // New prompts start as inactive
      })
      .select(`
        *,
        ai_features (*)
      `)
      .single();

    if (error) {
      throw new Error(`Failed to create prompt: ${error.message}`);
    }

    return prompt;
  }

  /**
   * Update an existing prompt
   */
  async updatePrompt(request: UpdatePromptRequest): Promise<AIPrompt> {
    const updateData: any = {
      updated_at: new Date().toISOString()
    };

    Object.keys(request).forEach(key => {
      if (key !== 'id' && request[key] !== undefined) {
        updateData[key] = request[key];
      }
    });

    const { data: prompt, error } = await this.supabase
      .from('ai_prompts')
      .update(updateData)
      .eq('id', request.id)
      .select(`
        *,
        ai_features (*)
      `)
      .single();

    if (error) {
      throw new Error(`Failed to update prompt: ${error.message}`);
    }

    return prompt;
  }

  /**
   * Delete a prompt
   */
  async deletePrompt(id: string): Promise<void> {
    const { error } = await this.supabase
      .from('ai_prompts')
      .delete()
      .eq('id', id);

    if (error) {
      throw new Error(`Failed to delete prompt: ${error.message}`);
    }
  }

  /**
   * Activate a prompt (deactivates others with same name/feature)
   */
  async activatePrompt(id: string): Promise<AIPrompt> {
    // Get the prompt to activate
    const prompt = await this.getPrompt(id);
    if (!prompt) {
      throw new Error('Prompt not found');
    }

    // Deactivate other prompts with the same name and feature
    await this.supabase
      .from('ai_prompts')
      .update({ is_active: false })
      .eq('name', prompt.name)
      .eq('feature_id', prompt.feature_id || null)
      .neq('id', id);

    // Activate this prompt
    const { data: activatedPrompt, error } = await this.supabase
      .from('ai_prompts')
      .update({ is_active: true })
      .eq('id', id)
      .select(`
        *,
        ai_features (*)
      `)
      .single();

    if (error) {
      throw new Error(`Failed to activate prompt: ${error.message}`);
    }

    return activatedPrompt;
  }

  /**
   * Deactivate a prompt
   */
  async deactivatePrompt(id: string): Promise<AIPrompt> {
    const { data: prompt, error } = await this.supabase
      .from('ai_prompts')
      .update({ is_active: false })
      .eq('id', id)
      .select(`
        *,
        ai_features (*)
      `)
      .single();

    if (error) {
      throw new Error(`Failed to deactivate prompt: ${error.message}`);
    }

    return prompt;
  }

  /**
   * Get all versions of a prompt
   */
  async getPromptVersions(name: string, featureId?: string): Promise<PromptVersion[]> {
    let query = this.supabase
      .from('ai_prompts')
      .select('version, content, created_at, created_by, is_active')
      .eq('name', name)
      .order('version', { ascending: false });

    if (featureId) {
      query = query.eq('feature_id', featureId);
    } else {
      query = query.is('feature_id', null);
    }

    const { data: versions, error } = await query;

    if (error) {
      throw new Error(`Failed to fetch prompt versions: ${error.message}`);
    }

    return versions || [];
  }

  /**
   * Duplicate a prompt with a new name
   */
  async duplicatePrompt(id: string, newName: string): Promise<AIPrompt> {
    const originalPrompt = await this.getPrompt(id);
    if (!originalPrompt) {
      throw new Error('Original prompt not found');
    }

    const duplicateRequest: CreatePromptRequest = {
      name: newName,
      description: originalPrompt.description,
      content: originalPrompt.content,
      feature_id: originalPrompt.feature_id,
      tags: [...originalPrompt.tags],
      variables: { ...originalPrompt.variables }
    };

    return this.createPrompt(duplicateRequest);
  }

  /**
   * Test a prompt with sample data
   */
  async testPrompt(id: string, testData: Record<string, any>): Promise<{
    renderedContent: string;
    variables: Record<string, any>;
    errors: string[];
  }> {
    const prompt = await this.getPrompt(id);
    if (!prompt) {
      throw new Error('Prompt not found');
    }

    const errors: string[] = [];
    let renderedContent = prompt.content;

    // Replace variables in the prompt
    const variableRegex = /\{\{(\w+)\}\}/g;
    let match;
    const usedVariables: Record<string, any> = {};

    while ((match = variableRegex.exec(prompt.content)) !== null) {
      const variableName = match[1];
      
      if (testData[variableName] !== undefined) {
        usedVariables[variableName] = testData[variableName];
        renderedContent = renderedContent.replace(
          new RegExp(`\\{\\{${variableName}\\}\\}`, 'g'),
          String(testData[variableName])
        );
      } else {
        errors.push(`Missing variable: ${variableName}`);
      }
    }

    return {
      renderedContent,
      variables: usedVariables,
      errors
    };
  }

  /**
   * Get usage statistics for a prompt
   */
  async getPromptUsageStats(id: string, timeRange: string = '30d') {
    const { startDate } = this.getDateRange(timeRange);

    const { data: stats, error } = await this.supabase
      .from('ai_usage_logs')
      .select('status, response_time_ms, cost_usd, created_at')
      .eq('prompt_id', id)
      .gte('created_at', startDate.toISOString());

    if (error) {
      throw new Error(`Failed to fetch prompt usage stats: ${error.message}`);
    }

    const logs = stats || [];
    const totalUsage = logs.length;
    const successfulUsage = logs.filter(log => log.status === 'success').length;
    const totalCost = logs.reduce((sum, log) => sum + (log.cost_usd || 0), 0);
    const averageResponseTime = totalUsage > 0 
      ? logs.reduce((sum, log) => sum + (log.response_time_ms || 0), 0) / totalUsage
      : 0;

    return {
      total_usage: totalUsage,
      success_rate: totalUsage > 0 ? (successfulUsage / totalUsage) * 100 : 0,
      total_cost: totalCost,
      average_response_time: averageResponseTime,
      usage_by_day: this.groupUsageByDay(logs)
    };
  }

  /**
   * Search prompts by content
   */
  async searchPrompts(query: string, options: ListPromptsOptions = {}): Promise<AIPrompt[]> {
    return this.listPrompts({
      ...options,
      search: query
    });
  }

  /**
   * Get all unique tags
   */
  async getAllTags(): Promise<string[]> {
    const { data: prompts, error } = await this.supabase
      .from('ai_prompts')
      .select('tags');

    if (error) {
      throw new Error(`Failed to fetch tags: ${error.message}`);
    }

    const allTags = new Set<string>();
    (prompts || []).forEach(prompt => {
      prompt.tags.forEach(tag => allTags.add(tag));
    });

    return Array.from(allTags).sort();
  }

  /**
   * Helper methods
   */
  private getDateRange(timeRange: string): { startDate: Date; endDate: Date } {
    const endDate = new Date();
    const startDate = new Date();

    switch (timeRange) {
      case '24h':
        startDate.setDate(endDate.getDate() - 1);
        break;
      case '7d':
        startDate.setDate(endDate.getDate() - 7);
        break;
      case '30d':
        startDate.setDate(endDate.getDate() - 30);
        break;
      default:
        startDate.setDate(endDate.getDate() - 30);
    }

    return { startDate, endDate };
  }

  private groupUsageByDay(logs: any[]) {
    const grouped: Record<string, number> = {};
    
    logs.forEach(log => {
      const date = new Date(log.created_at).toISOString().split('T')[0];
      grouped[date] = (grouped[date] || 0) + 1;
    });

    return grouped;
  }
}
```

### Step 7: Create Spending Analytics Service

**File**: `lib/services/platform/spending-analytics.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js';
import type { Database } from '@/lib/types/database';
import { AISpendingBudget } from '@/lib/types/ai-management';

export interface SpendingBreakdown {
  total_spend: number;
  period_start: string;
  period_end: string;
  by_feature: Array<{
    feature_id: string;
    feature_name: string;
    amount: number;
    percentage: number;
  }>;
  by_model: Array<{
    model_id: string;
    model_name: string;
    provider_name: string;
    amount: number;
    percentage: number;
    request_count: number;
  }>;
  by_provider: Array<{
    provider_id: string;
    provider_name: string;
    amount: number;
    percentage: number;
  }>;
  by_day: Array<{
    date: string;
    amount: number;
  }>;
}

export interface BudgetAnalysis {
  budget: AISpendingBudget;
  current_spend: number;
  projected_spend: number;
  days_remaining: number;
  burn_rate: number;
  status: 'on_track' | 'warning' | 'over_budget' | 'critical';
  alerts: string[];
}

export interface CostOptimizationRecommendation {
  id: string;
  type: 'model_switch' | 'prompt_optimization' | 'usage_reduction' | 'provider_switch';
  title: string;
  description: string;
  potential_savings: {
    amount: number;
    percentage: number;
    timeframe: string;
  };
  impact: 'low' | 'medium' | 'high';
  effort: 'easy' | 'moderate' | 'complex';
  details: {
    current_setup: any;
    recommended_setup: any;
    assumptions: string[];
    risks: string[];
  };
}

export class SpendingAnalyticsService {
  constructor(private supabase: SupabaseClient<Database>) {}

  /**
   * Get comprehensive spending breakdown
   */
  async getSpendingBreakdown(
    startDate: Date, 
    endDate: Date
  ): Promise<SpendingBreakdown> {
    // Get all usage logs for the period
    const { data: usageLogs, error } = await this.supabase
      .from('ai_usage_logs')
      .select(`
        cost_usd,
        created_at,
        ai_features (id, display_name),
        ai_models (id, name, ai_providers (id, name))
      `)
      .gte('created_at', startDate.toISOString())
      .lte('created_at', endDate.toISOString())
      .not('cost_usd', 'is', null);

    if (error) {
      throw new Error(`Failed to fetch spending data: ${error.message}`);
    }

    const logs = usageLogs || [];
    const totalSpend = logs.reduce((sum, log) => sum + (log.cost_usd || 0), 0);

    // Calculate spending by feature
    const featureSpending = new Map<string, { name: string; amount: number }>();
    logs.forEach(log => {
      if (log.ai_features) {
        const key = log.ai_features.id;
        const existing = featureSpending.get(key) || { name: log.ai_features.display_name, amount: 0 };
        existing.amount += log.cost_usd || 0;
        featureSpending.set(key, existing);
      }
    });

    // Calculate spending by model
    const modelSpending = new Map<string, { 
      name: string; 
      provider_name: string; 
      amount: number; 
      request_count: number 
    }>();
    logs.forEach(log => {
      if (log.ai_models) {
        const key = log.ai_models.id;
        const existing = modelSpending.get(key) || { 
          name: log.ai_models.name,
          provider_name: log.ai_models.ai_providers?.name || 'Unknown',
          amount: 0,
          request_count: 0
        };
        existing.amount += log.cost_usd || 0;
        existing.request_count += 1;
        modelSpending.set(key, existing);
      }
    });

    // Calculate spending by provider
    const providerSpending = new Map<string, { name: string; amount: number }>();
    logs.forEach(log => {
      if (log.ai_models?.ai_providers) {
        const key = log.ai_models.ai_providers.id;
        const existing = providerSpending.get(key) || { 
          name: log.ai_models.ai_providers.name, 
          amount: 0 
        };
        existing.amount += log.cost_usd || 0;
        providerSpending.set(key, existing);
      }
    });

    // Calculate daily spending
    const dailySpending = new Map<string, number>();
    logs.forEach(log => {
      const date = new Date(log.created_at).toISOString().split('T')[0];
      dailySpending.set(date, (dailySpending.get(date) || 0) + (log.cost_usd || 0));
    });

    return {
      total_spend: totalSpend,
      period_start: startDate.toISOString(),
      period_end: endDate.toISOString(),
      by_feature: Array.from(featureSpending.entries()).map(([id, data]) => ({
        feature_id: id,
        feature_name: data.name,
        amount: data.amount,
        percentage: totalSpend > 0 ? (data.amount / totalSpend) * 100 : 0
      })).sort((a, b) => b.amount - a.amount),
      by_model: Array.from(modelSpending.entries()).map(([id, data]) => ({
        model_id: id,
        model_name: data.name,
        provider_name: data.provider_name,
        amount: data.amount,
        percentage: totalSpend > 0 ? (data.amount / totalSpend) * 100 : 0,
        request_count: data.request_count
      })).sort((a, b) => b.amount - a.amount),
      by_provider: Array.from(providerSpending.entries()).map(([id, data]) => ({
        provider_id: id,
        provider_name: data.name,
        amount: data.amount,
        percentage: totalSpend > 0 ? (data.amount / totalSpend) * 100 : 0
      })).sort((a, b) => b.amount - a.amount),
      by_day: Array.from(dailySpending.entries()).map(([date, amount]) => ({
        date,
        amount
      })).sort((a, b) => a.date.localeCompare(b.date))
    };
  }

  /**
   * Get budget analysis for all active budgets
   */
  async getBudgetAnalysis(): Promise<BudgetAnalysis[]> {
    // Get all active budgets
    const { data: budgets, error } = await this.supabase
      .from('ai_spending_budgets')
      .select(`
        *,
        ai_features (display_name)
      `)
      .eq('is_active', true);

    if (error) {
      throw new Error(`Failed to fetch budgets: ${error.message}`);
    }

    const analyses = await Promise.all(
      (budgets || []).map(async (budget) => {
        const startDate = new Date(budget.start_date);
        const endDate = new Date(budget.end_date);
        const now = new Date();
        
        // Get current spending for this budget period
        let query = this.supabase
          .from('ai_usage_logs')
          .select('cost_usd')
          .gte('created_at', startDate.toISOString())
          .lte('created_at', Math.min(now.getTime(), endDate.getTime()))
          .not('cost_usd', 'is', null);

        if (budget.feature_id) {
          query = query.eq('feature_id', budget.feature_id);
        }

        const { data: spendingLogs } = await query;
        const currentSpend = (spendingLogs || []).reduce((sum, log) => sum + (log.cost_usd || 0), 0);

        // Calculate projections
        const totalDays = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));
        const elapsedDays = Math.ceil((Math.min(now.getTime(), endDate.getTime()) - startDate.getTime()) / (1000 * 60 * 60 * 24));
        const remainingDays = Math.max(0, totalDays - elapsedDays);
        
        const burnRate = elapsedDays > 0 ? currentSpend / elapsedDays : 0;
        const projectedSpend = currentSpend + (burnRate * remainingDays);

        // Determine status
        const utilizationPercent = (currentSpend / budget.budget_amount) * 100;
        let status: BudgetAnalysis['status'] = 'on_track';
        const alerts: string[] = [];

        if (currentSpend > budget.budget_amount) {
          status = 'over_budget';
          alerts.push('Budget exceeded');
        } else if (projectedSpend > budget.budget_amount) {
          status = 'critical';
          alerts.push('Projected to exceed budget');
        } else if (utilizationPercent > budget.alert_threshold * 100) {
          status = 'warning';
          alerts.push(`${Math.round(utilizationPercent)}% of budget used`);
        }

        return {
          budget,
          current_spend: currentSpend,
          projected_spend: projectedSpend,
          days_remaining: remainingDays,
          burn_rate: burnRate,
          status,
          alerts
        };
      })
    );

    return analyses;
  }

  /**
   * Create a new spending budget
   */
  async createBudget(budgetData: {
    name: string;
    description?: string;
    feature_id?: string;
    period_type: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly';
    budget_amount: number;
    alert_threshold?: number;
    start_date: Date;
    end_date: Date;
  }): Promise<AISpendingBudget> {
    const { data: budget, error } = await this.supabase
      .from('ai_spending_budgets')
      .insert({
        name: budgetData.name,
        description: budgetData.description,
        feature_id: budgetData.feature_id,
        period_type: budgetData.period_type,
        budget_amount: budgetData.budget_amount,
        alert_threshold: budgetData.alert_threshold || 0.8,
        start_date: budgetData.start_date.toISOString().split('T')[0],
        end_date: budgetData.end_date.toISOString().split('T')[0]
      })
      .select()
      .single();

    if (error) {
      throw new Error(`Failed to create budget: ${error.message}`);
    }

    return budget;
  }

  /**
   * Update a spending budget
   */
  async updateBudget(id: string, updates: Partial<{
    name: string;
    description: string;
    budget_amount: number;
    alert_threshold: number;
    is_active: boolean;
  }>): Promise<AISpendingBudget> {
    const { data: budget, error } = await this.supabase
      .from('ai_spending_budgets')
      .update({
        ...updates,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new Error(`Failed to update budget: ${error.message}`);
    }

    return budget;
  }

  /**
   * Delete a spending budget
   */
  async deleteBudget(id: string): Promise<void> {
    const { error } = await this.supabase
      .from('ai_spending_budgets')
      .delete()
      .eq('id', id);

    if (error) {
      throw new Error(`Failed to delete budget: ${error.message}`);
    }
  }

  /**
   * Get cost optimization recommendations
   */
  async getCostOptimizationRecommendations(): Promise<CostOptimizationRecommendation[]> {
    const recommendations: CostOptimizationRecommendation[] = [];
    
    // Analyze the last 30 days of usage
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const breakdown = await this.getSpendingBreakdown(thirtyDaysAgo, new Date());

    // Recommendation 1: High-cost models with low usage
    const highCostLowUsage = breakdown.by_model.filter(model => 
      model.amount > 100 && model.request_count < 100
    );
    
    highCostLowUsage.forEach(model => {
      recommendations.push({
        id: `model-optimization-${model.model_id}`,
        type: 'model_switch',
        title: `Consider switching from ${model.model_name}`,
        description: `${model.model_name} has high costs ($${model.amount.toFixed(2)}) but low usage (${model.request_count} requests). Consider a more cost-effective alternative.`,
        potential_savings: {
          amount: model.amount * 0.3, // Estimate 30% savings
          percentage: 30,
          timeframe: 'monthly'
        },
        impact: 'medium',
        effort: 'moderate',
        details: {
          current_setup: {
            model: model.model_name,
            provider: model.provider_name,
            monthly_cost: model.amount,
            requests: model.request_count
          },
          recommended_setup: {
            action: 'Evaluate cheaper alternatives',
            considerations: ['Performance requirements', 'Feature compatibility']
          },
          assumptions: ['Similar performance available at lower cost', 'Usage patterns remain consistent'],
          risks: ['Potential performance degradation', 'Integration effort required']
        }
      });
    });

    // Recommendation 2: Providers with higher costs
    if (breakdown.by_provider.length > 1) {
      const sortedProviders = [...breakdown.by_provider].sort((a, b) => b.amount - a.amount);
      const topProvider = sortedProviders[0];
      const secondProvider = sortedProviders[1];
      
      if (topProvider.amount > secondProvider.amount * 2) {
        recommendations.push({
          id: `provider-optimization-${topProvider.provider_id}`,
          type: 'provider_switch',
          title: `${topProvider.provider_name} accounts for ${topProvider.percentage.toFixed(1)}% of costs`,
          description: `Consider diversifying providers or negotiating better rates with ${topProvider.provider_name}.`,
          potential_savings: {
            amount: topProvider.amount * 0.15, // Estimate 15% savings
            percentage: 15,
            timeframe: 'monthly'
          },
          impact: 'high',
          effort: 'complex',
          details: {
            current_setup: {
              provider: topProvider.provider_name,
              monthly_cost: topProvider.amount,
              percentage: topProvider.percentage
            },
            recommended_setup: {
              action: 'Evaluate alternative providers or negotiate rates',
              considerations: ['Service quality', 'Feature compatibility', 'Migration effort']
            },
            assumptions: ['Alternative providers available', 'Similar service quality achievable'],
            risks: ['Service disruption during migration', 'Different API interfaces']
          }
        });
      }
    }

    // Recommendation 3: Features with high costs
    const highCostFeatures = breakdown.by_feature.filter(feature => 
      feature.percentage > 50
    );
    
    highCostFeatures.forEach(feature => {
      recommendations.push({
        id: `feature-optimization-${feature.feature_id}`,
        type: 'usage_reduction',
        title: `${feature.feature_name} represents ${feature.percentage.toFixed(1)}% of total costs`,
        description: `Consider optimizing ${feature.feature_name} usage patterns or implementing request filtering.`,
        potential_savings: {
          amount: feature.amount * 0.2, // Estimate 20% savings
          percentage: 20,
          timeframe: 'monthly'
        },
        impact: 'high',
        effort: 'moderate',
        details: {
          current_setup: {
            feature: feature.feature_name,
            monthly_cost: feature.amount,
            percentage: feature.percentage
          },
          recommended_setup: {
            action: 'Implement usage optimization strategies',
            considerations: ['Request filtering', 'Caching', 'Batch processing']
          },
          assumptions: ['Usage can be optimized without affecting functionality'],
          risks: ['User experience impact', 'Development effort required']
        }
      });
    });

    return recommendations.slice(0, 10); // Return top 10 recommendations
  }

  /**
   * Get spending trends and forecasts
   */
  async getSpendingTrends(days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    
    const breakdown = await this.getSpendingBreakdown(startDate, new Date());
    
    // Calculate trend
    const dailyData = breakdown.by_day;
    if (dailyData.length < 7) {
      return {
        trend: 'insufficient_data',
        forecast: null,
        daily_data: dailyData
      };
    }

    // Simple linear regression for trend
    const recent7Days = dailyData.slice(-7);
    const older7Days = dailyData.slice(-14, -7);
    
    const recentAvg = recent7Days.reduce((sum, day) => sum + day.amount, 0) / recent7Days.length;
    const olderAvg = older7Days.length > 0 
      ? older7Days.reduce((sum, day) => sum + day.amount, 0) / older7Days.length
      : recentAvg;

    const trendDirection = recentAvg > olderAvg * 1.1 ? 'increasing' : 
                          recentAvg < olderAvg * 0.9 ? 'decreasing' : 'stable';

    // Simple forecast for next 30 days
    const dailyAverage = breakdown.total_spend / days;
    const nextMonthForecast = dailyAverage * 30;

    return {
      trend: trendDirection,
      daily_average: dailyAverage,
      forecast: {
        next_30_days: nextMonthForecast,
        confidence: 'medium' // Would be calculated based on variance in real implementation
      },
      daily_data: dailyData
    };
  }
}
```

---

## 🔧 Enhanced API Endpoints

### Step 8: Add Budget Management Endpoints

**File**: `app/api/platform/ai-management/spending/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { withPlatformAdminAuth } from '@/lib/auth/platform-admin-validation';
import { SpendingAnalyticsService } from '@/lib/services/platform/spending-analytics';

// GET /api/platform/ai-management/spending
async function GET(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new SpendingAnalyticsService(supabase);
    
    const url = new URL(request.url);
    const action = url.searchParams.get('action') || 'breakdown';
    const startDate = url.searchParams.get('start_date');
    const endDate = url.searchParams.get('end_date');
    const days = parseInt(url.searchParams.get('days') || '30');

    switch (action) {
      case 'breakdown':
        if (!startDate || !endDate) {
          return NextResponse.json(
            { success: false, error: 'start_date and end_date are required for breakdown' },
            { status: 400 }
          );
        }
        const breakdown = await service.getSpendingBreakdown(
          new Date(startDate),
          new Date(endDate)
        );
        return NextResponse.json({ success: true, data: breakdown });

      case 'budgets':
        const budgetAnalysis = await service.getBudgetAnalysis();
        return NextResponse.json({ success: true, data: budgetAnalysis });

      case 'recommendations':
        const recommendations = await service.getCostOptimizationRecommendations();
        return NextResponse.json({ success: true, data: recommendations });

      case 'trends':
        const trends = await service.getSpendingTrends(days);
        return NextResponse.json({ success: true, data: trends });

      default:
        return NextResponse.json(
          { success: false, error: 'Invalid action parameter' },
          { status: 400 }
        );
    }
  } catch (error) {
    console.error('Error in spending analytics:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch spending analytics',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// POST /api/platform/ai-management/spending
async function POST(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new SpendingAnalyticsService(supabase);
    
    const body = await request.json();
    
    if (!body.name || !body.budget_amount || !body.start_date || !body.end_date) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Missing required fields: name, budget_amount, start_date, end_date' 
        },
        { status: 400 }
      );
    }

    const budget = await service.createBudget({
      name: body.name,
      description: body.description,
      feature_id: body.feature_id,
      period_type: body.period_type || 'monthly',
      budget_amount: parseFloat(body.budget_amount),
      alert_threshold: body.alert_threshold ? parseFloat(body.alert_threshold) : undefined,
      start_date: new Date(body.start_date),
      end_date: new Date(body.end_date)
    });

    return NextResponse.json({ success: true, data: budget }, { status: 201 });
  } catch (error) {
    console.error('Error creating budget:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to create budget',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

export const authenticatedGET = withPlatformAdminAuth(GET);
export const authenticatedPOST = withPlatformAdminAuth(POST);

export { 
  authenticatedGET as GET,
  authenticatedPOST as POST
};
```

### Step 9: Add Prompt Management Endpoints

**File**: `app/api/platform/ai-management/prompts/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { withPlatformAdminAuth } from '@/lib/auth/platform-admin-validation';
import { PromptManagementService } from '@/lib/services/platform/prompt-management';

// GET /api/platform/ai-management/prompts
async function GET(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new PromptManagementService(supabase);
    
    const url = new URL(request.url);
    const featureId = url.searchParams.get('feature_id') || undefined;
    const tags = url.searchParams.get('tags')?.split(',') || undefined;
    const isActive = url.searchParams.get('is_active') === 'true' ? true : 
                    url.searchParams.get('is_active') === 'false' ? false : undefined;
    const search = url.searchParams.get('search') || undefined;
    const limit = parseInt(url.searchParams.get('limit') || '50');
    const offset = parseInt(url.searchParams.get('offset') || '0');

    const prompts = await service.listPrompts({
      featureId,
      tags,
      isActive,
      search,
      limit,
      offset
    });

    return NextResponse.json({ 
      success: true, 
      data: prompts,
      metadata: {
        count: prompts.length,
        limit,
        offset
      }
    });
  } catch (error) {
    console.error('Error fetching prompts:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch prompts',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// POST /api/platform/ai-management/prompts
async function POST(request: NextRequest) {
  try {
    const supabase = createClient();
    const service = new PromptManagementService(supabase);
    
    const body = await request.json();
    
    if (!body.name || !body.content) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Missing required fields: name, content' 
        },
        { status: 400 }
      );
    }

    const prompt = await service.createPrompt({
      name: body.name,
      description: body.description,
      content: body.content,
      feature_id: body.feature_id,
      tags: body.tags || [],
      variables: body.variables || {}
    });

    return NextResponse.json({ success: true, data: prompt }, { status: 201 });
  } catch (error) {
    console.error('Error creating prompt:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to create prompt',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

export const authenticatedGET = withPlatformAdminAuth(GET);
export const authenticatedPOST = withPlatformAdminAuth(POST);

export { 
  authenticatedGET as GET,
  authenticatedPOST as POST
};
```

**File**: `app/api/platform/ai-management/prompts/[id]/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { withPlatformAdminAuth } from '@/lib/auth/platform-admin-validation';
import { PromptManagementService } from '@/lib/services/platform/prompt-management';

// GET /api/platform/ai-management/prompts/[id]
async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient();
    const service = new PromptManagementService(supabase);
    
    const prompt = await service.getPrompt(params.id);
    
    if (!prompt) {
      return NextResponse.json(
        { success: false, error: 'Prompt not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({ success: true, data: prompt });
  } catch (error) {
    console.error('Error fetching prompt:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch prompt',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// PUT /api/platform/ai-management/prompts/[id]
async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient();
    const service = new PromptManagementService(supabase);
    
    const body = await request.json();
    
    const prompt = await service.updatePrompt({
      id: params.id,
      ...body
    });

    return NextResponse.json({ success: true, data: prompt });
  } catch (error) {
    console.error('Error updating prompt:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to update prompt',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// DELETE /api/platform/ai-management/prompts/[id]
async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient();
    const service = new PromptManagementService(supabase);
    
    await service.deletePrompt(params.id);

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error deleting prompt:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to delete prompt',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

export const authenticatedGET = withPlatformAdminAuth(GET);
export const authenticatedPUT = withPlatformAdminAuth(PUT);
export const authenticatedDELETE = withPlatformAdminAuth(DELETE);

export { 
  authenticatedGET as GET,
  authenticatedPUT as PUT,
  authenticatedDELETE as DELETE
};
```

---

## ✅ Implementation Checklist

### Database Implementation
- [ ] Create migration file `20250131000000_ai_management_schema.sql`
- [ ] Apply migration with `npx supabase db push`
- [ ] Verify all tables created successfully
- [ ] Test platform admin RLS policies
- [ ] Confirm seed data is populated

### Type Definitions
- [ ] Create `lib/types/ai-management.ts`
- [ ] Verify TypeScript compilation with new types
- [ ] Update existing services to use new types

### Backend Services
- [ ] Complete `FeatureManagementService` implementation
- [ ] Complete `ModelManagementService` implementation  
- [ ] Create `PromptManagementService`
- [ ] Create `SpendingAnalyticsService`
- [ ] Test all service methods

### API Endpoints
- [ ] Create spending analytics endpoints
- [ ] Create prompt management endpoints
- [ ] Test all endpoints with proper authentication
- [ ] Verify API responses match expected format

### Testing & Validation
- [ ] Test Global Overview with real data
- [ ] Verify platform admin authentication works
- [ ] Test database queries performance
- [ ] Validate data relationships and constraints

---

## 🚀 Success Criteria

**Phase 1 is complete when:**
1. ✅ All 15 database tables created and populated
2. ✅ Platform admin authentication working on all endpoints
3. ✅ Global Overview dashboard displays real data (not placeholder)
4. ✅ All 4 backend services have complete CRUD operations
5. ✅ No TypeScript compilation errors
6. ✅ Database migrations can be applied and rolled back successfully

**Ready for Phase 2:** ✅ Feature management dashboards can be built using the completed services

---

**Estimated Implementation Time:** 5-7 days  
**Critical Path:** Database migration → Service implementation → API testing → Global Overview integration

This completes the foundation required for all subsequent phases of the AI Platform Management system.