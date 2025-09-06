# Phase 2: Feature Management Core - Implementation Plan

**Duration**: 2 Weeks  
**Priority**: 🔥 **HIGH** - Core functionality for platform admins  
**Dependencies**: Phase 1 (Database Foundation) must be complete  
**Claude Code Instructions**: Implement the core feature management interfaces step-by-step

---

## 📋 Phase Overview

**Objective**: Build interactive feature-specific dashboards and complete model management functionality to enable platform admins to manage AI features effectively.

**Key Deliverables**:
- 3 interactive feature-specific dashboards (Photo Tagging, Chatbot, AI Search)
- Complete model & provider management interface
- Model deployment pipeline with visual controls
- Real-time feature health monitoring
- Interactive configuration controls

**Success Criteria**:
- Platform admins can view and configure each AI feature independently
- Model assignments can be changed through the UI
- Real-time metrics display actual data from the database
- All features show proper health status and performance metrics
- Model deployment pipeline is fully functional

---

## 🎯 Feature-Specific Dashboard Implementation

### Step 1: Enhanced Feature Dashboard Page

**File**: `app/platform/ai-management/features/page.tsx`

```typescript
'use client';

import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Metadata } from 'next';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { 
  Camera, 
  MessageSquare, 
  Search,
  Settings,
  TrendingUp,
  AlertCircle,
  Activity,
  Clock,
  DollarSign,
  Zap
} from 'lucide-react';
import { FeatureDashboard } from '@/components/platform/ai-management/features/FeatureDashboard';
import { FeatureMetricsCard } from '@/components/platform/ai-management/features/FeatureMetricsCard';
import { FeatureModelAssignment } from '@/components/platform/ai-management/features/FeatureModelAssignment';

interface AIFeatureWithMetrics {
  id: string;
  name: string;
  display_name: string;
  status: 'active' | 'inactive' | 'maintenance';
  metrics: {
    uptime: number;
    error_rate: number;
    response_time: number;
    total_requests: number;
    success_rate: number;
    cost_per_request: number;
  };
  current_model?: {
    id: string;
    name: string;
    provider_name: string;
  };
}

const FEATURE_ICONS = {
  'photo-tagging': Camera,
  'chatbot': MessageSquare,
  'ai-search': Search
} as const;

export default function AIFeaturesPage() {
  const [selectedFeature, setSelectedFeature] = useState<string | null>(null);

  const { data: features, isLoading, error, refetch } = useQuery({
    queryKey: ['ai-features-with-metrics'],
    queryFn: fetchFeaturesWithMetrics,
    refetchInterval: 30000 // Refresh every 30 seconds
  });

  // Auto-select first feature on load
  useEffect(() => {
    if (features && features.length > 0 && !selectedFeature) {
      setSelectedFeature(features[0].id);
    }
  }, [features, selectedFeature]);

  if (isLoading) {
    return <FeaturesDashboardSkeleton />;
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Failed to Load Features</h3>
          <p className="text-gray-600 mb-4">Unable to fetch AI features data</p>
          <Button onClick={() => refetch()} variant="outline">
            <Activity className="h-4 w-4 mr-2" />
            Retry
          </Button>
        </div>
      </div>
    );
  }

  const selectedFeatureData = features?.find(f => f.id === selectedFeature);

  return (
    <div className="flex flex-col h-full">
      {/* Page Header */}
      <div className="border-b px-6 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold tracking-tight">AI Features Management</h1>
            <p className="text-sm text-muted-foreground mt-1">
              Monitor and configure individual AI features
            </p>
          </div>
          <div className="flex gap-2">
            <Button variant="outline">
              <Settings className="mr-2 h-4 w-4" />
              Global Settings
            </Button>
            <Button variant="outline" onClick={() => refetch()}>
              <Activity className="mr-2 h-4 w-4" />
              Refresh
            </Button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 overflow-y-auto">
        <div className="p-6">
          {/* Feature Overview Cards */}
          <div className="grid gap-6 md:grid-cols-3 mb-8">
            {features?.map((feature) => {
              const Icon = FEATURE_ICONS[feature.name as keyof typeof FEATURE_ICONS] || Activity;
              const isSelected = selectedFeature === feature.id;
              
              return (
                <Card 
                  key={feature.id} 
                  className={`cursor-pointer transition-all duration-200 hover:shadow-lg ${
                    isSelected ? 'ring-2 ring-primary shadow-lg' : ''
                  }`}
                  onClick={() => setSelectedFeature(feature.id)}
                >
                  <CardHeader className="pb-3">
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-3">
                        <div className="p-2 bg-primary/10 rounded-lg">
                          <Icon className="h-6 w-6 text-primary" />
                        </div>
                        <div>
                          <CardTitle className="text-lg">{feature.display_name}</CardTitle>
                          <p className="text-sm text-muted-foreground">
                            {feature.current_model?.name || 'No model assigned'}
                          </p>
                        </div>
                      </div>
                      <Badge variant={getStatusVariant(feature.status)}>
                        {feature.status}
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="grid grid-cols-2 gap-3 text-sm">
                      <div className="flex items-center gap-1">
                        <Activity className="h-3 w-3 text-muted-foreground" />
                        <span className="text-muted-foreground">Uptime:</span>
                        <span className="font-medium">{feature.metrics.uptime.toFixed(1)}%</span>
                      </div>
                      <div className="flex items-center gap-1">
                        <Clock className="h-3 w-3 text-muted-foreground" />
                        <span className="text-muted-foreground">Response:</span>
                        <span className="font-medium">{feature.metrics.response_time.toFixed(0)}ms</span>
                      </div>
                      <div className="flex items-center gap-1">
                        <TrendingUp className="h-3 w-3 text-muted-foreground" />
                        <span className="text-muted-foreground">Requests:</span>
                        <span className="font-medium">{formatNumber(feature.metrics.total_requests)}</span>
                      </div>
                      <div className="flex items-center gap-1">
                        <DollarSign className="h-3 w-3 text-muted-foreground" />
                        <span className="text-muted-foreground">Cost/Req:</span>
                        <span className="font-medium">${feature.metrics.cost_per_request.toFixed(4)}</span>
                      </div>
                    </div>
                    
                    {feature.metrics.error_rate > 5 && (
                      <div className="flex items-center gap-2 text-amber-600 bg-amber-50 p-2 rounded text-sm">
                        <AlertCircle className="h-4 w-4" />
                        <span>Error rate: {feature.metrics.error_rate.toFixed(1)}%</span>
                      </div>
                    )}
                  </CardContent>
                </Card>
              );
            })}
          </div>

          {/* Feature-Specific Dashboard */}
          {selectedFeatureData && (
            <div className="space-y-6">
              <div className="flex items-center gap-4 mb-6">
                <div className="p-2 bg-primary/10 rounded-lg">
                  {(() => {
                    const Icon = FEATURE_ICONS[selectedFeatureData.name as keyof typeof FEATURE_ICONS] || Activity;
                    return <Icon className="h-6 w-6 text-primary" />;
                  })()}
                </div>
                <div>
                  <h2 className="text-xl font-semibold">{selectedFeatureData.display_name}</h2>
                  <p className="text-muted-foreground">Feature-specific management and configuration</p>
                </div>
              </div>

              <Tabs defaultValue="overview" className="space-y-6">
                <TabsList className="grid w-full grid-cols-5">
                  <TabsTrigger value="overview">Overview</TabsTrigger>
                  <TabsTrigger value="models">Models</TabsTrigger>
                  <TabsTrigger value="prompts">Prompts</TabsTrigger>
                  <TabsTrigger value="testing">Testing</TabsTrigger>
                  <TabsTrigger value="settings">Settings</TabsTrigger>
                </TabsList>

                <TabsContent value="overview">
                  <FeatureDashboard featureId={selectedFeatureData.id} />
                </TabsContent>

                <TabsContent value="models">
                  <FeatureModelAssignment featureId={selectedFeatureData.id} />
                </TabsContent>

                <TabsContent value="prompts">
                  <FeaturePromptsManager featureId={selectedFeatureData.id} />
                </TabsContent>

                <TabsContent value="testing">
                  <FeatureTestingInterface featureId={selectedFeatureData.id} />
                </TabsContent>

                <TabsContent value="settings">
                  <FeatureSettingsPanel featureId={selectedFeatureData.id} />
                </TabsContent>
              </Tabs>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// Helper functions
function getStatusVariant(status: string) {
  switch (status) {
    case 'active': return 'default';
    case 'maintenance': return 'secondary';
    case 'inactive': return 'destructive';
    default: return 'secondary';
  }
}

function formatNumber(num: number): string {
  if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
  if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
  return num.toString();
}

// API fetch function
async function fetchFeaturesWithMetrics(): Promise<AIFeatureWithMetrics[]> {
  const response = await fetch('/api/platform/ai-management/features?include_metrics=true&time_range=24h');
  if (!response.ok) {
    throw new Error('Failed to fetch features with metrics');
  }
  const result = await response.json();
  return result.data;
}

// Loading skeleton
function FeaturesDashboardSkeleton() {
  return (
    <div className="flex flex-col h-full">
      <div className="border-b px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="space-y-2">
            <div className="h-8 w-64 bg-gray-200 rounded animate-pulse" />
            <div className="h-4 w-96 bg-gray-200 rounded animate-pulse" />
          </div>
          <div className="flex gap-2">
            <div className="h-10 w-32 bg-gray-200 rounded animate-pulse" />
            <div className="h-10 w-24 bg-gray-200 rounded animate-pulse" />
          </div>
        </div>
      </div>
      
      <div className="p-6">
        <div className="grid gap-6 md:grid-cols-3 mb-8">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-48 bg-gray-200 rounded-lg animate-pulse" />
          ))}
        </div>
        <div className="h-96 bg-gray-200 rounded-lg animate-pulse" />
      </div>
    </div>
  );
}

// Import these components (to be created in subsequent steps)
import { FeaturePromptsManager } from '@/components/platform/ai-management/features/FeaturePromptsManager';
import { FeatureTestingInterface } from '@/components/platform/ai-management/features/FeatureTestingInterface';
import { FeatureSettingsPanel } from '@/components/platform/ai-management/features/FeatureSettingsPanel';
```

### Step 2: Feature Dashboard Component

**File**: `components/platform/ai-management/features/FeatureDashboard.tsx`

```typescript
'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { 
  Activity,
  Clock,
  DollarSign,
  TrendingUp,
  TrendingDown,
  AlertTriangle,
  CheckCircle,
  BarChart3,
  Users,
  Zap
} from 'lucide-react';
import { LineChart, Line, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';

interface FeatureDashboardProps {
  featureId: string;
}

interface FeatureMetrics {
  realtime: {
    uptime: number;
    error_rate: number;
    response_time: number;
    requests_per_minute: number;
    success_rate: number;
    cost_per_request: number;
  };
  historical: {
    timeRange: string;
    data: Array<{
      timestamp: string;
      response_time: number;
      error_rate: number;
      throughput: number;
      cost: number;
    }>;
  };
  usage: {
    total_requests: number;
    unique_users: number;
    peak_usage_hour: number;
    avg_requests_per_user: number;
  };
  costs: {
    total_cost: number;
    cost_trend: number;
    cost_breakdown: Array<{
      category: string;
      amount: number;
      percentage: number;
    }>;
  };
}

export function FeatureDashboard({ featureId }: FeatureDashboardProps) {
  const [timeRange, setTimeRange] = useState('24h');

  const { data: metrics, isLoading, error } = useQuery({
    queryKey: ['feature-metrics', featureId, timeRange],
    queryFn: () => fetchFeatureMetrics(featureId, timeRange),
    refetchInterval: 30000 // Refresh every 30 seconds
  });

  if (isLoading) {
    return <FeatureDashboardSkeleton />;
  }

  if (error || !metrics) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center py-8">
          <div className="text-center">
            <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
            <p className="text-gray-600">Failed to load feature metrics</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* Time Range Selector */}
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold">Performance Overview</h3>
        <Tabs value={timeRange} onValueChange={setTimeRange}>
          <TabsList>
            <TabsTrigger value="1h">1 Hour</TabsTrigger>
            <TabsTrigger value="24h">24 Hours</TabsTrigger>
            <TabsTrigger value="7d">7 Days</TabsTrigger>
            <TabsTrigger value="30d">30 Days</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      {/* Real-time Metrics Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <MetricCard
          title="Uptime"
          value={`${metrics.realtime.uptime.toFixed(1)}%`}
          change={null}
          icon={Activity}
          status={metrics.realtime.uptime >= 99 ? 'success' : metrics.realtime.uptime >= 95 ? 'warning' : 'error'}
        />
        <MetricCard
          title="Response Time"
          value={`${metrics.realtime.response_time.toFixed(0)}ms`}
          change={null}
          icon={Clock}
          status={metrics.realtime.response_time <= 1000 ? 'success' : metrics.realtime.response_time <= 2000 ? 'warning' : 'error'}
        />
        <MetricCard
          title="Success Rate"
          value={`${metrics.realtime.success_rate.toFixed(1)}%`}
          change={null}
          icon={CheckCircle}
          status={metrics.realtime.success_rate >= 98 ? 'success' : metrics.realtime.success_rate >= 95 ? 'warning' : 'error'}
        />
        <MetricCard
          title="Cost per Request"
          value={`$${metrics.realtime.cost_per_request.toFixed(4)}`}
          change={metrics.costs.cost_trend}
          icon={DollarSign}
          status="neutral"
        />
      </div>

      {/* Charts Section */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* Response Time Trends */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Clock className="h-5 w-5" />
              Response Time Trends
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={metrics.historical.data}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis 
                  dataKey="timestamp" 
                  tickFormatter={(value) => new Date(value).toLocaleTimeString()}
                />
                <YAxis />
                <Tooltip 
                  labelFormatter={(value) => new Date(value).toLocaleString()}
                  formatter={(value: number) => [`${value.toFixed(0)}ms`, 'Response Time']}
                />
                <Line 
                  type="monotone" 
                  dataKey="response_time" 
                  stroke="#3b82f6" 
                  strokeWidth={2}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Throughput */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BarChart3 className="h-5 w-5" />
              Request Throughput
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={metrics.historical.data}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis 
                  dataKey="timestamp" 
                  tickFormatter={(value) => new Date(value).toLocaleTimeString()}
                />
                <YAxis />
                <Tooltip 
                  labelFormatter={(value) => new Date(value).toLocaleString()}
                  formatter={(value: number) => [value, 'Requests']}
                />
                <Area 
                  type="monotone" 
                  dataKey="throughput" 
                  stroke="#10b981" 
                  fill="#10b981" 
                  fillOpacity={0.3}
                />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Usage Statistics */}
      <div className="grid gap-6 lg:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center Gap-2">
              <Users className="h-5 w-5" />
              Usage Statistics
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Total Requests</span>
              <span className="font-semibold">{formatNumber(metrics.usage.total_requests)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Unique Users</span>
              <span className="font-semibold">{formatNumber(metrics.usage.unique_users)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Peak Hour</span>
              <span className="font-semibold">{metrics.usage.peak_usage_hour}:00</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Avg Req/User</span>
              <span className="font-semibold">{metrics.usage.avg_requests_per_user.toFixed(1)}</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <DollarSign className="h-5 w-5" />
              Cost Analysis
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-muted-foreground">Total Cost</span>
              <div className="flex items-center gap-2">
                <span className="font-semibold">${metrics.costs.total_cost.toFixed(2)}</span>
                {metrics.costs.cost_trend !== 0 && (
                  <Badge variant={metrics.costs.cost_trend > 0 ? 'destructive' : 'default'}>
                    {metrics.costs.cost_trend > 0 ? '+' : ''}{metrics.costs.cost_trend.toFixed(1)}%
                  </Badge>
                )}
              </div>
            </div>
            <div className="space-y-2">
              {metrics.costs.cost_breakdown.map((item, index) => (
                <div key={index} className="flex justify-between">
                  <span className="text-sm text-muted-foreground">{item.category}</span>
                  <span className="text-sm font-medium">${item.amount.toFixed(2)}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Zap className="h-5 w-5" />
              Performance Score
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-center">
              <div className="text-3xl font-bold text-primary mb-2">
                {calculatePerformanceScore(metrics.realtime)}
              </div>
              <p className="text-sm text-muted-foreground mb-4">
                Overall Performance Rating
              </p>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span>Reliability</span>
                  <span>{getScoreLabel(metrics.realtime.uptime, 99, 95)}</span>
                </div>
                <div className="flex justify-between">
                  <span>Speed</span>
                  <span>{getScoreLabel(2000 - metrics.realtime.response_time, 1000, 500)}</span>
                </div>
                <div className="flex justify-between">
                  <span>Accuracy</span>
                  <span>{getScoreLabel(metrics.realtime.success_rate, 98, 95)}</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Error Rate Chart */}
      {metrics.realtime.error_rate > 1 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-amber-600">
              <AlertTriangle className="h-5 w-5" />
              Error Rate Analysis
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={metrics.historical.data}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis 
                  dataKey="timestamp" 
                  tickFormatter={(value) => new Date(value).toLocaleTimeString()}
                />
                <YAxis />
                <Tooltip 
                  labelFormatter={(value) => new Date(value).toLocaleString()}
                  formatter={(value: number) => [`${value.toFixed(2)}%`, 'Error Rate']}
                />
                <Bar dataKey="error_rate" fill="#f59e0b" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

// Metric Card Component
interface MetricCardProps {
  title: string;
  value: string;
  change?: number | null;
  icon: React.ComponentType<{ className?: string }>;
  status: 'success' | 'warning' | 'error' | 'neutral';
}

function MetricCard({ title, value, change, icon: Icon, status }: MetricCardProps) {
  const getStatusColor = () => {
    switch (status) {
      case 'success': return 'text-green-600';
      case 'warning': return 'text-amber-600';
      case 'error': return 'text-red-600';
      default: return 'text-blue-600';
    }
  };

  const getStatusBg = () => {
    switch (status) {
      case 'success': return 'bg-green-50';
      case 'warning': return 'bg-amber-50';
      case 'error': return 'bg-red-50';
      default: return 'bg-blue-50';
    }
  };

  return (
    <Card>
      <CardContent className="p-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-muted-foreground">{title}</p>
            <p className="text-2xl font-bold">{value}</p>
            {change !== null && change !== undefined && (
              <div className="flex items-center gap-1 mt-1">
                {change > 0 ? (
                  <TrendingUp className="h-3 w-3 text-red-500" />
                ) : (
                  <TrendingDown className="h-3 w-3 text-green-500" />
                )}
                <span className={`text-xs ${change > 0 ? 'text-red-500' : 'text-green-500'}`}>
                  {Math.abs(change).toFixed(1)}%
                </span>
              </div>
            )}
          </div>
          <div className={`p-2 rounded-lg ${getStatusBg()}`}>
            <Icon className={`h-6 w-6 ${getStatusColor()}`} />
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

// Helper functions
function calculatePerformanceScore(metrics: FeatureMetrics['realtime']): string {
  const uptimeScore = Math.min(metrics.uptime / 99 * 100, 100);
  const speedScore = Math.min((2000 - metrics.response_time) / 2000 * 100, 100);
  const accuracyScore = Math.min(metrics.success_rate, 100);
  
  const overallScore = (uptimeScore + speedScore + accuracyScore) / 3;
  
  if (overallScore >= 90) return 'A+';
  if (overallScore >= 80) return 'A';
  if (overallScore >= 70) return 'B';
  if (overallScore >= 60) return 'C';
  return 'D';
}

function getScoreLabel(value: number, good: number, ok: number): string {
  if (value >= good) return 'Excellent';
  if (value >= ok) return 'Good';
  return 'Needs Improvement';
}

function formatNumber(num: number): string {
  if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
  if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
  return num.toString();
}

// API fetch function
async function fetchFeatureMetrics(featureId: string, timeRange: string): Promise<FeatureMetrics> {
  const response = await fetch(`/api/platform/ai-management/features/${featureId}/metrics?time_range=${timeRange}`);
  if (!response.ok) {
    throw new Error('Failed to fetch feature metrics');
  }
  const result = await response.json();
  return result.data;
}

// Loading skeleton
function FeatureDashboardSkeleton() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="h-6 w-40 bg-gray-200 rounded animate-pulse" />
        <div className="h-10 w-64 bg-gray-200 rounded animate-pulse" />
      </div>
      
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="h-24 bg-gray-200 rounded-lg animate-pulse" />
        ))}
      </div>
      
      <div className="grid gap-6 lg:grid-cols-2">
        <div className="h-80 bg-gray-200 rounded-lg animate-pulse" />
        <div className="h-80 bg-gray-200 rounded-lg animate-pulse" />
      </div>
    </div>
  );
}
```

### Step 3: Feature Model Assignment Component

**File**: `components/platform/ai-management/features/FeatureModelAssignment.tsx`

```typescript
'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { 
  Server,
  Settings,
  CheckCircle,
  AlertTriangle,
  Clock,
  Zap,
  Activity,
  ArrowRight,
  RotateCcw
} from 'lucide-react';
import { toast } from 'sonner';

interface FeatureModelAssignmentProps {
  featureId: string;
}

interface ModelAssignment {
  id: string;
  model_id: string;
  environment: 'development' | 'staging' | 'production';
  is_active: boolean;
  assigned_at: string;
  config_overrides: Record<string, any>;
  model: {
    id: string;
    name: string;
    display_name: string;
    provider_name: string;
    model_type: string;
    status: string;
    performance_metrics: Record<string, any>;
  };
}

interface AvailableModel {
  id: string;
  name: string;
  display_name: string;
  provider_name: string;
  model_type: string;
  status: 'available' | 'deprecated' | 'beta' | 'offline';
  pricing: {
    cost_per_token?: number;
    cost_estimate?: string;
  };
  performance_metrics: {
    average_response_time?: number;
    success_rate?: number;
  };
}

export function FeatureModelAssignment({ featureId }: FeatureModelAssignmentProps) {
  const [selectedEnvironment, setSelectedEnvironment] = useState<string>('production');
  const [assignModelDialogOpen, setAssignModelDialogOpen] = useState(false);
  const [selectedModelId, setSelectedModelId] = useState<string>('');
  
  const queryClient = useQueryClient();

  // Fetch current model assignments
  const { data: assignments, isLoading: assignmentsLoading } = useQuery({
    queryKey: ['feature-model-assignments', featureId],
    queryFn: () => fetchFeatureModelAssignments(featureId)
  });

  // Fetch available models
  const { data: availableModels, isLoading: modelsLoading } = useQuery({
    queryKey: ['available-models'],
    queryFn: fetchAvailableModels
  });

  // Model assignment mutation
  const assignModelMutation = useMutation({
    mutationFn: (data: { featureId: string; modelId: string; environment: string }) =>
      assignModelToFeature(data.featureId, data.modelId, data.environment),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['feature-model-assignments', featureId] });
      queryClient.invalidateQueries({ queryKey: ['ai-features-with-metrics'] });
      setAssignModelDialogOpen(false);
      toast.success('Model assigned successfully');
    },
    onError: (error: Error) => {
      toast.error(`Failed to assign model: ${error.message}`);
    }
  });

  const currentAssignment = assignments?.find(a => 
    a.environment === selectedEnvironment && a.is_active
  );

  const handleAssignModel = () => {
    if (!selectedModelId) {
      toast.error('Please select a model');
      return;
    }

    assignModelMutation.mutate({
      featureId,
      modelId: selectedModelId,
      environment: selectedEnvironment
    });
  };

  if (assignmentsLoading || modelsLoading) {
    return <ModelAssignmentSkeleton />;
  }

  return (
    <div className="space-y-6">
      {/* Environment Selector */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold">Model Assignments</h3>
          <p className="text-sm text-muted-foreground">
            Manage model assignments across different environments
          </p>
        </div>
        <Select value={selectedEnvironment} onValueChange={setSelectedEnvironment}>
          <SelectTrigger className="w-40">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="production">Production</SelectItem>
            <SelectItem value="staging">Staging</SelectItem>
            <SelectItem value="development">Development</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Current Assignment */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <Server className="h-5 w-5" />
              Current Assignment - {selectedEnvironment}
            </CardTitle>
            <Dialog open={assignModelDialogOpen} onOpenChange={setAssignModelDialogOpen}>
              <DialogTrigger asChild>
                <Button>
                  <Settings className="h-4 w-4 mr-2" />
                  Change Model
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-2xl">
                <DialogHeader>
                  <DialogTitle>Assign Model to {selectedEnvironment}</DialogTitle>
                </DialogHeader>
                <ModelSelectionDialog
                  availableModels={availableModels || []}
                  selectedModelId={selectedModelId}
                  onSelectModel={setSelectedModelId}
                  onConfirm={handleAssignModel}
                  onCancel={() => setAssignModelDialogOpen(false)}
                  isLoading={assignModelMutation.isPending}
                />
              </DialogContent>
            </Dialog>
          </div>
        </CardHeader>
        <CardContent>
          {currentAssignment ? (
            <div className="space-y-4">
              <div className="flex items-start justify-between">
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <h4 className="font-semibold">{currentAssignment.model.display_name}</h4>
                    <Badge variant="outline">{currentAssignment.model.provider_name}</Badge>
                    <Badge variant={getModelStatusVariant(currentAssignment.model.status)}>
                      {currentAssignment.model.status}
                    </Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    {currentAssignment.model.name} • {currentAssignment.model.model_type}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    Assigned {new Date(currentAssignment.assigned_at).toLocaleString()}
                  </p>
                </div>
                <div className="text-right space-y-1">
                  {currentAssignment.model.performance_metrics?.average_response_time && (
                    <div className="flex items-center gap-1 text-sm">
                      <Clock className="h-3 w-3" />
                      {currentAssignment.model.performance_metrics.average_response_time.toFixed(0)}ms
                    </div>
                  )}
                  {currentAssignment.model.performance_metrics?.success_rate && (
                    <div className="flex items-center gap-1 text-sm">
                      <CheckCircle className="h-3 w-3" />
                      {currentAssignment.model.performance_metrics.success_rate.toFixed(1)}%
                    </div>
                  )}
                </div>
              </div>

              {/* Performance Metrics */}
              <div className="grid grid-cols-3 gap-4 pt-4 border-t">
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-600">
                    {currentAssignment.model.performance_metrics?.success_rate?.toFixed(1) || '--'}%
                  </div>
                  <div className="text-xs text-muted-foreground">Success Rate</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600">
                    {currentAssignment.model.performance_metrics?.average_response_time?.toFixed(0) || '--'}ms
                  </div>
                  <div className="text-xs text-muted-foreground">Avg Response</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600">
                    {currentAssignment.model.performance_metrics?.total_requests || '--'}
                  </div>
                  <div className="text-xs text-muted-foreground">Total Requests</div>
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center py-8">
              <Server className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h4 className="font-medium text-gray-900 mb-2">No Model Assigned</h4>
              <p className="text-sm text-gray-600 mb-4">
                No model is currently assigned to {selectedEnvironment} environment
              </p>
              <Button onClick={() => setAssignModelDialogOpen(true)}>
                Assign Model
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Assignment History */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="h-5 w-5" />
            Assignment History
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {assignments
              ?.filter(a => a.environment === selectedEnvironment)
              .sort((a, b) => new Date(b.assigned_at).getTime() - new Date(a.assigned_at).getTime())
              .slice(0, 5)
              .map((assignment) => (
                <div key={assignment.id} className="flex items-center justify-between py-2 border-b last:border-0">
                  <div className="flex items-center gap-3">
                    <div className={`w-2 h-2 rounded-full ${assignment.is_active ? 'bg-green-500' : 'bg-gray-300'}`} />
                    <div>
                      <p className="font-medium">{assignment.model.display_name}</p>
                      <p className="text-sm text-muted-foreground">
                        {assignment.model.provider_name} • {new Date(assignment.assigned_at).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {assignment.is_active && (
                      <Badge variant="default" className="text-xs">Active</Badge>
                    )}
                  </div>
                </div>
              ))}
          </div>
        </CardContent>
      </Card>

      {/* Environment Comparison */}
      {assignments && assignments.length > 1 && (
        <Card>
          <CardHeader>
            <CardTitle>Environment Comparison</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-3">
              {['production', 'staging', 'development'].map((env) => {
                const assignment = assignments.find(a => a.environment === env && a.is_active);
                return (
                  <div key={env} className="p-4 border rounded-lg">
                    <div className="font-medium capitalize mb-2">{env}</div>
                    {assignment ? (
                      <div className="space-y-1">
                        <p className="text-sm">{assignment.model.display_name}</p>
                        <p className="text-xs text-muted-foreground">{assignment.model.provider_name}</p>
                        <Badge size="sm" variant={getModelStatusVariant(assignment.model.status)}>
                          {assignment.model.status}
                        </Badge>
                      </div>
                    ) : (
                      <p className="text-sm text-muted-foreground">No assignment</p>
                    )}
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

// Model Selection Dialog Component
interface ModelSelectionDialogProps {
  availableModels: AvailableModel[];
  selectedModelId: string;
  onSelectModel: (modelId: string) => void;
  onConfirm: () => void;
  onCancel: () => void;
  isLoading: boolean;
}

function ModelSelectionDialog({
  availableModels,
  selectedModelId,
  onSelectModel,
  onConfirm,
  onCancel,
  isLoading
}: ModelSelectionDialogProps) {
  const selectedModel = availableModels.find(m => m.id === selectedModelId);

  return (
    <div className="space-y-4">
      <div className="max-h-96 overflow-y-auto space-y-2">
        {availableModels.map((model) => (
          <div
            key={model.id}
            className={`p-3 border rounded-lg cursor-pointer transition-colors ${
              selectedModelId === model.id 
                ? 'border-primary bg-primary/5' 
                : 'hover:bg-gray-50'
            }`}
            onClick={() => onSelectModel(model.id)}
          >
            <div className="flex items-start justify-between">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <h4 className="font-medium">{model.display_name}</h4>
                  <Badge variant="outline">{model.provider_name}</Badge>
                  <Badge variant={getModelStatusVariant(model.status)}>
                    {model.status}
                  </Badge>
                </div>
                <p className="text-sm text-muted-foreground">
                  {model.name} • {model.model_type}
                </p>
                {model.pricing.cost_estimate && (
                  <p className="text-xs text-muted-foreground">
                    Est. cost: {model.pricing.cost_estimate}
                  </p>
                )}
              </div>
              <div className="text-right text-sm space-y-1">
                {model.performance_metrics.average_response_time && (
                  <div className="flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    {model.performance_metrics.average_response_time.toFixed(0)}ms
                  </div>
                )}
                {model.performance_metrics.success_rate && (
                  <div className="flex items-center gap-1">
                    <CheckCircle className="h-3 w-3" />
                    {model.performance_metrics.success_rate.toFixed(1)}%
                  </div>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {selectedModel && (
        <Alert>
          <CheckCircle className="h-4 w-4" />
          <AlertDescription>
            <strong>{selectedModel.display_name}</strong> will be assigned to this feature.
            This will deactivate the current model assignment.
          </AlertDescription>
        </Alert>
      )}

      <div className="flex justify-end gap-2">
        <Button variant="outline" onClick={onCancel}>
          Cancel
        </Button>
        <Button 
          onClick={onConfirm} 
          disabled={!selectedModelId || isLoading}
          loading={isLoading}
        >
          {isLoading ? 'Assigning...' : 'Assign Model'}
        </Button>
      </div>
    </div>
  );
}

// Helper functions
function getModelStatusVariant(status: string) {
  switch (status) {
    case 'available': return 'default';
    case 'beta': return 'secondary';
    case 'deprecated': return 'destructive';
    case 'offline': return 'destructive';
    default: return 'secondary';
  }
}

// API functions
async function fetchFeatureModelAssignments(featureId: string): Promise<ModelAssignment[]> {
  const response = await fetch(`/api/platform/ai-management/features/${featureId}/models`);
  if (!response.ok) {
    throw new Error('Failed to fetch model assignments');
  }
  const result = await response.json();
  return result.data;
}

async function fetchAvailableModels(): Promise<AvailableModel[]> {
  const response = await fetch('/api/platform/ai-management/models?include_metrics=true');
  if (!response.ok) {
    throw new Error('Failed to fetch available models');
  }
  const result = await response.json();
  return result.data;
}

async function assignModelToFeature(featureId: string, modelId: string, environment: string) {
  const response = await fetch(`/api/platform/ai-management/features/${featureId}/models`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model_id: modelId,
      environment,
      is_active: true
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to assign model');
  }

  return response.json();
}

// Loading skeleton
function ModelAssignmentSkeleton() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="space-y-2">
          <div className="h-6 w-40 bg-gray-200 rounded animate-pulse" />
          <div className="h-4 w-64 bg-gray-200 rounded animate-pulse" />
        </div>
        <div className="h-10 w-40 bg-gray-200 rounded animate-pulse" />
      </div>
      
      <div className="h-64 bg-gray-200 rounded-lg animate-pulse" />
      <div className="h-48 bg-gray-200 rounded-lg animate-pulse" />
    </div>
  );
}
```

### Step 4: API Endpoint for Feature Metrics

**File**: `app/api/platform/ai-management/features/[id]/metrics/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { withPlatformAdminAuth } from '@/lib/auth/platform-admin-validation';
import { FeatureManagementService } from '@/lib/services/platform/feature-management';

// GET /api/platform/ai-management/features/[id]/metrics
async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient();
    const service = new FeatureManagementService(supabase);
    
    const url = new URL(request.url);
    const timeRange = url.searchParams.get('time_range') || '24h';
    
    // Get basic feature health metrics
    const healthMetrics = await service.getFeatureHealthMetrics(params.id, timeRange);
    
    // Get historical data for charts
    const historicalData = await getFeatureHistoricalData(supabase, params.id, timeRange);
    
    // Get usage statistics
    const usageStats = await getFeatureUsageStats(supabase, params.id, timeRange);
    
    // Get cost analysis
    const costAnalysis = await getFeatureCostAnalysis(supabase, params.id, timeRange);

    const metrics = {
      realtime: {
        uptime: healthMetrics.uptime,
        error_rate: healthMetrics.error_rate,
        response_time: healthMetrics.response_time,
        requests_per_minute: healthMetrics.total_requests / (getMinutesInTimeRange(timeRange)),
        success_rate: healthMetrics.success_rate,
        cost_per_request: healthMetrics.cost_per_request
      },
      historical: {
        timeRange,
        data: historicalData
      },
      usage: usageStats,
      costs: costAnalysis
    };

    return NextResponse.json({ 
      success: true, 
      data: metrics,
      metadata: {
        feature_id: params.id,
        time_range: timeRange,
        generated_at: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Error fetching feature metrics:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch feature metrics',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// Helper functions
async function getFeatureHistoricalData(supabase: any, featureId: string, timeRange: string) {
  const { startDate } = getDateRange(timeRange);
  
  const { data: logs, error } = await supabase
    .from('ai_usage_logs')
    .select('status, response_time_ms, cost_usd, created_at')
    .eq('feature_id', featureId)
    .gte('created_at', startDate.toISOString())
    .order('created_at', { ascending: true });

  if (error) {
    console.error('Error fetching historical data:', error);
    return [];
  }

  // Group data by time intervals
  const intervals = getTimeIntervals(timeRange);
  const grouped = groupDataByIntervals(logs || [], intervals);
  
  return grouped.map(group => ({
    timestamp: group.timestamp,
    response_time: group.avg_response_time,
    error_rate: group.error_rate,
    throughput: group.request_count,
    cost: group.total_cost
  }));
}

async function getFeatureUsageStats(supabase: any, featureId: string, timeRange: string) {
  const { startDate } = getDateRange(timeRange);
  
  const { data: logs } = await supabase
    .from('ai_usage_logs')
    .select('user_id, created_at')
    .eq('feature_id', featureId)
    .gte('created_at', startDate.toISOString());

  const totalRequests = logs?.length || 0;
  const uniqueUsers = new Set(logs?.map(log => log.user_id).filter(Boolean)).size;
  
  // Calculate peak usage hour
  const hourlyUsage = {};
  logs?.forEach(log => {
    const hour = new Date(log.created_at).getHours();
    hourlyUsage[hour] = (hourlyUsage[hour] || 0) + 1;
  });
  
  const peakUsageHour = Object.entries(hourlyUsage)
    .sort(([,a], [,b]) => b - a)[0]?.[0] || 0;

  return {
    total_requests: totalRequests,
    unique_users: uniqueUsers,
    peak_usage_hour: parseInt(peakUsageHour),
    avg_requests_per_user: uniqueUsers > 0 ? totalRequests / uniqueUsers : 0
  };
}

async function getFeatureCostAnalysis(supabase: any, featureId: string, timeRange: string) {
  const { startDate } = getDateRange(timeRange);
  
  const { data: logs } = await supabase
    .from('ai_usage_logs')
    .select('cost_usd, created_at')
    .eq('feature_id', featureId)
    .gte('created_at', startDate.toISOString())
    .not('cost_usd', 'is', null);

  const totalCost = logs?.reduce((sum, log) => sum + (log.cost_usd || 0), 0) || 0;
  
  // Calculate trend (compare with previous period)
  const { startDate: prevStartDate, endDate: prevEndDate } = getPreviousPeriod(timeRange);
  const { data: prevLogs } = await supabase
    .from('ai_usage_logs')
    .select('cost_usd')
    .eq('feature_id', featureId)
    .gte('created_at', prevStartDate.toISOString())
    .lte('created_at', prevEndDate.toISOString())
    .not('cost_usd', 'is', null);

  const prevTotalCost = prevLogs?.reduce((sum, log) => sum + (log.cost_usd || 0), 0) || 0;
  const costTrend = prevTotalCost > 0 ? ((totalCost - prevTotalCost) / prevTotalCost) * 100 : 0;

  return {
    total_cost: totalCost,
    cost_trend: costTrend,
    cost_breakdown: [
      { category: 'API Calls', amount: totalCost * 0.8, percentage: 80 },
      { category: 'Data Processing', amount: totalCost * 0.15, percentage: 15 },
      { category: 'Storage', amount: totalCost * 0.05, percentage: 5 }
    ]
  };
}

function getDateRange(timeRange: string): { startDate: Date; endDate: Date } {
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

function getPreviousPeriod(timeRange: string): { startDate: Date; endDate: Date } {
  const { startDate: currentStart } = getDateRange(timeRange);
  const endDate = new Date(currentStart);
  const startDate = new Date();

  const duration = endDate.getTime() - currentStart.getTime();
  startDate.setTime(currentStart.getTime() - duration);

  return { startDate, endDate };
}

function getMinutesInTimeRange(timeRange: string): number {
  switch (timeRange) {
    case '1h': return 60;
    case '24h': return 1440;
    case '7d': return 10080;
    case '30d': return 43200;
    default: return 1440;
  }
}

function getTimeIntervals(timeRange: string): string[] {
  const intervals = [];
  const { startDate, endDate } = getDateRange(timeRange);
  
  let current = new Date(startDate);
  let intervalMinutes;
  
  switch (timeRange) {
    case '1h':
      intervalMinutes = 5; // 5-minute intervals
      break;
    case '24h':
      intervalMinutes = 60; // 1-hour intervals
      break;
    case '7d':
      intervalMinutes = 360; // 6-hour intervals
      break;
    case '30d':
      intervalMinutes = 1440; // 1-day intervals
      break;
    default:
      intervalMinutes = 60;
  }
  
  while (current <= endDate) {
    intervals.push(current.toISOString());
    current = new Date(current.getTime() + intervalMinutes * 60 * 1000);
  }
  
  return intervals;
}

function groupDataByIntervals(logs: any[], intervals: string[]) {
  return intervals.map(timestamp => {
    const intervalStart = new Date(timestamp);
    const intervalEnd = new Date(intervalStart.getTime() + 60 * 60 * 1000); // 1 hour window
    
    const intervalLogs = logs.filter(log => {
      const logTime = new Date(log.created_at);
      return logTime >= intervalStart && logTime < intervalEnd;
    });
    
    const totalRequests = intervalLogs.length;
    const successfulRequests = intervalLogs.filter(log => log.status === 'success').length;
    const totalResponseTime = intervalLogs.reduce((sum, log) => sum + (log.response_time_ms || 0), 0);
    const totalCost = intervalLogs.reduce((sum, log) => sum + (log.cost_usd || 0), 0);
    
    return {
      timestamp,
      request_count: totalRequests,
      avg_response_time: totalRequests > 0 ? totalResponseTime / totalRequests : 0,
      error_rate: totalRequests > 0 ? ((totalRequests - successfulRequests) / totalRequests) * 100 : 0,
      total_cost: totalCost
    };
  });
}

export const authenticatedGET = withPlatformAdminAuth(GET);

export { 
  authenticatedGET as GET
};
```

### Step 5: Enhanced Model Management Page

**File**: `app/platform/ai-management/models/page.tsx`

```typescript
'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { 
  Server, 
  Plus, 
  Settings, 
  Activity, 
  DollarSign, 
  Clock,
  Search,
  Filter,
  MoreVertical,
  CheckCircle,
  AlertTriangle,
  ArrowUpDown
} from 'lucide-react';
import { toast } from 'sonner';

interface Provider {
  id: string;
  name: string;
  display_name: string;
  status: 'active' | 'inactive' | 'error';
  model_count: number;
  monthly_spend: number;
  health_score: number;
  uptime: number;
  response_time: number;
}

interface AIModel {
  id: string;
  name: string;
  display_name: string;
  provider_name: string;
  model_type: 'llm' | 'vision' | 'embedding';
  status: 'available' | 'deprecated' | 'beta' | 'offline';
  performance_metrics: {
    average_response_time?: number;
    success_rate?: number;
    total_requests?: number;
    total_cost?: number;
  };
  pricing: {
    cost_per_token?: number;
    cost_estimate?: string;
  };
  deployments?: Array<{
    feature_name: string;
    environment: string;
    is_active: boolean;
  }>;
}

interface RecentDeployment {
  id: string;
  model_name: string;
  feature_name: string;
  environment: string;
  status: 'success' | 'failed' | 'in_progress';
  deployed_at: string;
}

export default function ModelsProvidersPage() {
  const [activeTab, setActiveTab] = useState('providers');
  const [searchQuery, setSearchQuery] = useState('');
  const [filterProvider, setFilterProvider] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [sortBy, setSortBy] = useState('name');
  
  const queryClient = useQueryClient();

  // Fetch providers with enhanced data
  const { data: providers, isLoading: providersLoading } = useQuery({
    queryKey: ['enhanced-providers'],
    queryFn: fetchEnhancedProviders,
    refetchInterval: 60000
  });

  // Fetch models with performance metrics
  const { data: models, isLoading: modelsLoading } = useQuery({
    queryKey: ['enhanced-models', filterProvider, filterStatus],
    queryFn: () => fetchEnhancedModels(filterProvider, filterStatus),
    refetchInterval: 60000
  });

  // Fetch recent deployments
  const { data: deployments, isLoading: deploymentsLoading } = useQuery({
    queryKey: ['recent-deployments'],
    queryFn: fetchRecentDeployments,
    refetchInterval: 30000
  });

  // Filter and sort models
  const filteredModels = models?.filter(model => 
    model.display_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    model.name.toLowerCase().includes(searchQuery.toLowerCase())
  ).sort((a, b) => {
    switch (sortBy) {
      case 'performance':
        return (b.performance_metrics.success_rate || 0) - (a.performance_metrics.success_rate || 0);
      case 'cost':
        return (a.performance_metrics.total_cost || 0) - (b.performance_metrics.total_cost || 0);
      case 'usage':
        return (b.performance_metrics.total_requests || 0) - (a.performance_metrics.total_requests || 0);
      default:
        return a.display_name.localeCompare(b.display_name);
    }
  });

  return (
    <div className="flex flex-col h-full">
      {/* Page Header */}
      <div className="border-b px-6 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold tracking-tight">Models & Providers</h1>
            <p className="text-sm text-muted-foreground mt-1">
              Manage AI model lifecycle and provider configurations
            </p>
          </div>
          <div className="flex gap-2">
            <Button variant="outline">
              <Settings className="mr-2 h-4 w-4" />
              Provider Settings
            </Button>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              Add Model
            </Button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 overflow-y-auto p-6">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="providers">Providers</TabsTrigger>
            <TabsTrigger value="models">Models</TabsTrigger>
            <TabsTrigger value="deployments">Deployments</TabsTrigger>
          </TabsList>

          <TabsContent value="providers" className="space-y-6">
            <ProvidersView providers={providers || []} isLoading={providersLoading} />
          </TabsContent>

          <TabsContent value="models" className="space-y-6">
            <ModelsView 
              models={filteredModels || []}
              isLoading={modelsLoading}
              searchQuery={searchQuery}
              onSearchChange={setSearchQuery}
              filterProvider={filterProvider}
              onFilterProviderChange={setFilterProvider}
              filterStatus={filterStatus}
              onFilterStatusChange={setFilterStatus}
              sortBy={sortBy}
              onSortByChange={setSortBy}
              providers={providers || []}
            />
          </TabsContent>

          <TabsContent value="deployments" className="space-y-6">
            <DeploymentsView deployments={deployments || []} isLoading={deploymentsLoading} />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}

// Providers View Component
interface ProvidersViewProps {
  providers: Provider[];
  isLoading: boolean;
}

function ProvidersView({ providers, isLoading }: ProvidersViewProps) {
  if (isLoading) {
    return (
      <div className="grid gap-6 md:grid-cols-1 lg:grid-cols-3">
        {[1, 2, 3].map((i) => (
          <div key={i} className="h-64 bg-gray-200 rounded-lg animate-pulse" />
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Provider Overview Stats */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Active Providers</p>
                <p className="text-2xl font-bold">{providers.filter(p => p.status === 'active').length}</p>
              </div>
              <Server className="h-8 w-8 text-muted-foreground/20" />
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Total Models</p>
                <p className="text-2xl font-bold">{providers.reduce((sum, p) => sum + p.model_count, 0)}</p>
              </div>
              <Activity className="h-8 w-8 text-muted-foreground/20" />
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Monthly Spend</p>
                <p className="text-2xl font-bold">${providers.reduce((sum, p) => sum + p.monthly_spend, 0).toFixed(0)}</p>
              </div>
              <DollarSign className="h-8 w-8 text-muted-foreground/20" />
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Avg Health Score</p>
                <p className="text-2xl font-bold">
                  {providers.length > 0 
                    ? Math.round(providers.reduce((sum, p) => sum + p.health_score, 0) / providers.length)
                    : 0
                  }%
                </p>
              </div>
              <CheckCircle className="h-8 w-8 text-muted-foreground/20" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Provider Cards */}
      <div className="grid gap-6 md:grid-cols-1 lg:grid-cols-3">
        {providers.map((provider) => (
          <Card key={provider.id}>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Server className="h-5 w-5 text-muted-foreground" />
                  <CardTitle className="text-lg">{provider.display_name}</CardTitle>
                </div>
                <Badge variant={getProviderStatusVariant(provider.status)}>
                  {provider.status}
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-muted-foreground">Active Models</p>
                  <p className="text-xl font-semibold">{provider.model_count}</p>
                </div>
                <div>
                  <p className="text-muted-foreground">Monthly Spend</p>
                  <p className="text-xl font-semibold">${provider.monthly_spend.toFixed(0)}</p>
                </div>
              </div>
              
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Health Score</span>
                  <span className="font-medium">{provider.health_score}%</span>
                </div>
                <Progress value={provider.health_score} className="h-2" />
              </div>

              <div className="grid grid-cols-2 gap-4 text-sm">
                <div className="flex justify-between">
                  <span className="text-muted-foreground flex items-center gap-1">
                    <Activity className="h-3 w-3" />
                    Uptime
                  </span>
                  <span className="font-medium">{provider.uptime.toFixed(1)}%</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    Avg Response
                  </span>
                  <span className="font-medium">{provider.response_time.toFixed(0)}ms</span>
                </div>
              </div>

              <Button variant="outline" className="w-full">
                Manage Provider
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}

// Models View Component
interface ModelsViewProps {
  models: AIModel[];
  isLoading: boolean;
  searchQuery: string;
  onSearchChange: (query: string) => void;
  filterProvider: string;
  onFilterProviderChange: (provider: string) => void;
  filterStatus: string;
  onFilterStatusChange: (status: string) => void;
  sortBy: string;
  onSortByChange: (sort: string) => void;
  providers: Provider[];
}

function ModelsView({
  models,
  isLoading,
  searchQuery,
  onSearchChange,
  filterProvider,
  onFilterProviderChange,
  filterStatus,
  onFilterStatusChange,
  sortBy,
  onSortByChange,
  providers
}: ModelsViewProps) {
  if (isLoading) {
    return (
      <div className="space-y-4">
        <div className="flex gap-4">
          <div className="h-10 w-64 bg-gray-200 rounded animate-pulse" />
          <div className="h-10 w-40 bg-gray-200 rounded animate-pulse" />
          <div className="h-10 w-32 bg-gray-200 rounded animate-pulse" />
        </div>
        <div className="grid gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-32 bg-gray-200 rounded-lg animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Filters and Search */}
      <div className="flex items-center gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search models..."
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            className="pl-10"
          />
        </div>
        <Select value={filterProvider} onValueChange={onFilterProviderChange}>
          <SelectTrigger className="w-40">
            <SelectValue placeholder="All Providers" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">All Providers</SelectItem>
            {providers.map((provider) => (
              <SelectItem key={provider.id} value={provider.name}>
                {provider.display_name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select value={filterStatus} onValueChange={onFilterStatusChange}>
          <SelectTrigger className="w-32">
            <SelectValue placeholder="All Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">All Status</SelectItem>
            <SelectItem value="available">Available</SelectItem>
            <SelectItem value="beta">Beta</SelectItem>
            <SelectItem value="deprecated">Deprecated</SelectItem>
            <SelectItem value="offline">Offline</SelectItem>
          </SelectContent>
        </Select>
        <Select value={sortBy} onValueChange={onSortByChange}>
          <SelectTrigger className="w-40">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="name">Name</SelectItem>
            <SelectItem value="performance">Performance</SelectItem>
            <SelectItem value="cost">Cost</SelectItem>
            <SelectItem value="usage">Usage</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Models Grid */}
      <div className="grid gap-4">
        {models.map((model) => (
          <Card key={model.id} className="hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between">
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <h3 className="font-semibold">{model.display_name}</h3>
                    <Badge variant="outline">{model.provider_name}</Badge>
                    <Badge variant={getModelStatusVariant(model.status)}>
                      {model.status}
                    </Badge>
                    <Badge variant="secondary">{model.model_type}</Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">{model.name}</p>
                  {model.deployments && model.deployments.length > 0 && (
                    <div className="flex gap-1">
                      {model.deployments.map((deployment, idx) => (
                        <Badge key={idx} variant="outline" className="text-xs">
                          {deployment.feature_name} ({deployment.environment})
                        </Badge>
                      ))}
                    </div>
                  )}
                </div>
                
                <div className="text-right space-y-1">
                  {model.performance_metrics.success_rate && (
                    <div className="flex items-center gap-1 text-sm">
                      <CheckCircle className="h-3 w-3 text-green-500" />
                      {model.performance_metrics.success_rate.toFixed(1)}%
                    </div>
                  )}
                  {model.performance_metrics.average_response_time && (
                    <div className="flex items-center gap-1 text-sm">
                      <Clock className="h-3 w-3 text-blue-500" />
                      {model.performance_metrics.average_response_time.toFixed(0)}ms
                    </div>
                  )}
                  {model.performance_metrics.total_cost && (
                    <div className="flex items-center gap-1 text-sm">
                      <DollarSign className="h-3 w-3 text-purple-500" />
                      ${model.performance_metrics.total_cost.toFixed(2)}
                    </div>
                  )}
                </div>
              </div>

              <div className="mt-4 pt-4 border-t flex items-center justify-between">
                <div className="flex gap-4 text-sm text-muted-foreground">
                  <span>Requests: {model.performance_metrics.total_requests || 0}</span>
                  {model.pricing.cost_estimate && (
                    <span>Est. Cost: {model.pricing.cost_estimate}</span>
                  )}
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm">
                    Configure
                  </Button>
                  <Button size="sm">
                    Deploy
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}

// Deployments View Component
interface DeploymentsViewProps {
  deployments: RecentDeployment[];
  isLoading: boolean;
}

function DeploymentsView({ deployments, isLoading }: DeploymentsViewProps) {
  if (isLoading) {
    return (
      <div className="space-y-4">
        {[1, 2, 3, 4, 5].map((i) => (
          <div key={i} className="h-16 bg-gray-200 rounded-lg animate-pulse" />
        ))}
      </div>
    );
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>Recent Deployments</CardTitle>
          <Button variant="ghost" size="sm">
            View All
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          {deployments.map((deployment) => (
            <div key={deployment.id} className="flex items-center justify-between py-3 border-b last:border-0">
              <div className="flex items-center gap-3">
                <Activity className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="font-medium">{deployment.model_name}</p>
                  <p className="text-sm text-muted-foreground">
                    {deployment.feature_name} • {deployment.environment}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <Badge variant={getDeploymentStatusVariant(deployment.status)}>
                  {deployment.status}
                </Badge>
                <span className="text-sm text-muted-foreground">
                  {new Date(deployment.deployed_at).toLocaleDateString()}
                </span>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}

// Helper functions
function getProviderStatusVariant(status: string) {
  switch (status) {
    case 'active': return 'default';
    case 'inactive': return 'secondary';
    case 'error': return 'destructive';
    default: return 'secondary';
  }
}

function getModelStatusVariant(status: string) {
  switch (status) {
    case 'available': return 'default';
    case 'beta': return 'secondary';
    case 'deprecated': return 'destructive';
    case 'offline': return 'destructive';
    default: return 'secondary';
  }
}

function getDeploymentStatusVariant(status: string) {
  switch (status) {
    case 'success': return 'default';
    case 'failed': return 'destructive';
    case 'in_progress': return 'secondary';
    default: return 'secondary';
  }
}

// API functions
async function fetchEnhancedProviders(): Promise<Provider[]> {
  const response = await fetch('/api/platform/ai-management/providers?include_metrics=true');
  if (!response.ok) throw new Error('Failed to fetch providers');
  const result = await response.json();
  return result.data;
}

async function fetchEnhancedModels(provider?: string, status?: string): Promise<AIModel[]> {
  const params = new URLSearchParams();
  if (provider) params.append('provider', provider);
  if (status) params.append('status', status);
  params.append('include_metrics', 'true');
  
  const response = await fetch(`/api/platform/ai-management/models?${params}`);
  if (!response.ok) throw new Error('Failed to fetch models');
  const result = await response.json();
  return result.data;
}

async function fetchRecentDeployments(): Promise<RecentDeployment[]> {
  const response = await fetch('/api/platform/ai-management/deployments?limit=10');
  if (!response.ok) throw new Error('Failed to fetch deployments');
  const result = await response.json();
  return result.data;
}
```

---

## ✅ Implementation Checklist

### Feature Dashboard Implementation
- [ ] Create enhanced features page with real-time data
- [ ] Implement FeatureDashboard component with metrics
- [ ] Build FeatureModelAssignment component
- [ ] Create feature metrics API endpoint
- [ ] Test feature selection and dashboard switching

### Model Management Enhancement
- [ ] Enhance models page with advanced filtering
- [ ] Implement provider health monitoring
- [ ] Create model comparison functionality
- [ ] Build deployment history tracking
- [ ] Add model performance visualization

### API Enhancements
- [ ] Create feature metrics endpoint
- [ ] Implement model assignment endpoints
- [ ] Add provider health endpoints
- [ ] Create deployment tracking endpoints
- [ ] Test all new API endpoints

### Component Integration
- [ ] Integrate with existing Global Overview
- [ ] Test navigation between views
- [ ] Verify real-time data updates
- [ ] Ensure proper error handling
- [ ] Validate responsive design

### Testing & Validation
- [ ] Test feature health calculations
- [ ] Verify model assignment workflow
- [ ] Test provider status monitoring
- [ ] Validate real-time updates
- [ ] Check platform admin authentication

---

## 🚀 Success Criteria

**Phase 2 is complete when:**
1. ✅ Platform admins can view detailed metrics for each AI feature
2. ✅ Model assignments can be changed through the UI
3. ✅ Real-time feature health monitoring is functional
4. ✅ Provider health scores are calculated and displayed
5. ✅ Model deployment pipeline is interactive
6. ✅ All feature-specific dashboards work with real data

**Ready for Phase 3:** ✅ Prompt library and spending analytics can be built on this foundation

---

**Estimated Implementation Time:** 10-14 days  
**Critical Path:** Feature metrics API → Dashboard components → Model management enhancement → Integration testing

This phase provides the core interactive management capabilities that platform administrators need to effectively manage AI features and models.