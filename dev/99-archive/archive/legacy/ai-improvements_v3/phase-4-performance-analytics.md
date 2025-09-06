# Phase 4: Performance Analytics & Optimization

*AI Management Platform v4 - Phase 4 Implementation*

## Overview

Create an intelligent analytics system that not only tracks AI performance but provides actionable insights and automated optimization recommendations. This phase transforms the platform from reactive monitoring to proactive optimization, helping developers continuously improve AI accuracy and efficiency.

## Goals

- **Provider Performance Comparison**: Real-time accuracy, cost, and speed analysis between Google Vision and Gemini
- **Automated Optimization Insights**: AI-driven recommendations for prompt improvements and model selection
- **ROI Tracking**: Cost per accurate tag analysis and budget optimization recommendations  
- **Predictive Analytics**: Trend analysis and performance forecasting for capacity planning

## Current State Analysis

### **The Analytics Gap**
```
Current Analytics: Basic charts showing historical data
Needed Analytics: Actionable insights that directly improve AI performance

Current Process: Look at charts → Guess what to optimize → Try changes
Needed Process: View insights → Get specific recommendations → Implement with confidence
```

### **Existing Data Sources to Leverage**
- **Processing Results**: Complete history in `ai_processing_results` table
- **Cost Tracking**: Existing cost monitoring and budgets  
- **User Corrections**: Manual tag corrections for accuracy tracking
- **Performance Metrics**: Response times, confidence scores, success rates

## Performance Analytics Interface Design

### **Visual Layout**
```
┌─────────────────────────────────────────────────────────────┐
│ 📊 Performance Analytics                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────┐ ┌─────────────────────┐             │
│ │ 🎯 Smart Insights   │ │ ⚖️ Provider Compare │             │
│ │                     │ │                     │             │
│ │ 💡 Switch to Gemini │ │ Google Vision:      │             │
│ │    for CNC photos   │ │ ✅ Speed: 1.2s      │             │
│ │    (+12% accuracy)  │ │ ⚠️ Accuracy: 87%    │             │
│ │                     │ │ ✅ Cost: $0.002     │             │
│ │ 🔧 Optimize prompt  │ │                     │             │
│ │    for "hazard"     │ │ Gemini 1.5:         │             │
│ │    (+8% confidence) │ │ ⚠️ Speed: 2.1s      │             │
│ │                     │ │ ✅ Accuracy: 94%    │             │
│ │ 💰 Reduce costs by  │ │ ⚠️ Cost: $0.008     │             │
│ │    15% with hybrid  │ │                     │             │
│ │                     │ │ 🎯 Recommendation:  │             │
│ │ [🚀 Apply All]      │ │    Use Gemini for   │             │
│ └─────────────────────┘ │    high-value tags  │             │
│                         └─────────────────────┘             │
│                                                             │
│ ┌─────────────────────┐ ┌─────────────────────┐             │
│ │ 💰 ROI Analysis     │ │ 📈 Trend Forecasting│             │
│ │                     │ │                     │             │
│ │ Cost per accurate   │ │ Next 30 days:       │             │
│ │ tag: $0.023        │ │                     │             │
│ │                     │ │ 📸 Photos: 2,400    │             │
│ │ Best performing:    │ │ 💰 Cost: ~$180      │             │
│ │ • Machine tags: 98% │ │ 🎯 Accuracy: 91%    │             │
│ │ • Hazard tags: 89%  │ │                     │             │
│ │ • Control tags: 76% │ │ ⚠️ Risk: Budget      │             │
│ │                     │ │    overrun by 20%   │             │
│ │ Optimization        │ │                     │             │
│ │ potential: -$45/mo  │ │ [📋 Export Report]  │             │
│ └─────────────────────┘ └─────────────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Technical Implementation

### **1. Performance Analytics Main Component**

#### **PerformanceAnalytics.tsx**
```typescript
// components/ai/console/Analytics/PerformanceAnalytics.tsx
'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { SmartInsights } from './SmartInsights';
import { ProviderComparison } from './ProviderComparison';
import { ROIAnalysis } from './ROIAnalysis';
import { TrendForecasting } from './TrendForecasting';

interface PerformanceAnalyticsProps {
  organizationId: string;
  data: any;
}

export function PerformanceAnalytics({ organizationId, data }: PerformanceAnalyticsProps) {
  const [analyticsData, setAnalyticsData] = useState<any>(null);
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d'>('30d');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadAnalyticsData();
  }, [organizationId, timeRange]);

  const loadAnalyticsData = async () => {
    setIsLoading(true);
    try {
      const [insights, comparison, roi, trends] = await Promise.all([
        fetch(`/api/ai/analytics/insights?org=${organizationId}&range=${timeRange}`).then(r => r.json()),
        fetch(`/api/ai/analytics/provider-comparison?org=${organizationId}&range=${timeRange}`).then(r => r.json()),
        fetch(`/api/ai/analytics/roi?org=${organizationId}&range=${timeRange}`).then(r => r.json()),
        fetch(`/api/ai/analytics/trends?org=${organizationId}&range=${timeRange}`).then(r => r.json())
      ]);

      setAnalyticsData({
        insights,
        comparison,
        roi,
        trends
      });
    } catch (error) {
      console.error('Failed to load analytics data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const applyOptimization = async (optimizationId: string) => {
    try {
      const response = await fetch('/api/ai/analytics/apply-optimization', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          organizationId,
          optimizationId
        })
      });

      if (response.ok) {
        // Refresh analytics data
        loadAnalyticsData();
      }
    } catch (error) {
      console.error('Failed to apply optimization:', error);
    }
  };

  if (isLoading) {
    return (
      <Card className="h-[400px] flex items-center justify-center">
        <div>🔄 Loading analytics...</div>
      </Card>
    );
  }

  return (
    <Card className="h-[400px]">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          📊 Performance Analytics
          <select
            value={timeRange}
            onChange={(e) => setTimeRange(e.target.value as any)}
            className="ml-auto text-sm border rounded px-2 py-1"
          >
            <option value="7d">Last 7 days</option>
            <option value="30d">Last 30 days</option>
            <option value="90d">Last 90 days</option>
          </select>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 h-full">
          {/* Top Row */}
          <SmartInsights
            insights={analyticsData?.insights}
            onApplyOptimization={applyOptimization}
          />
          
          <ProviderComparison
            comparison={analyticsData?.comparison}
            organizationId={organizationId}
          />
          
          {/* Bottom Row */}
          <ROIAnalysis
            roi={analyticsData?.roi}
            timeRange={timeRange}
          />
          
          <TrendForecasting
            trends={analyticsData?.trends}
            organizationId={organizationId}
          />
        </div>
      </CardContent>
    </Card>
  );
}
```

### **2. AI-Powered Smart Insights**

#### **SmartInsights.tsx**
```typescript
// components/ai/console/Analytics/SmartInsights.tsx
interface SmartInsightsProps {
  insights: any;
  onApplyOptimization: (optimizationId: string) => void;
}

export function SmartInsights({ insights, onApplyOptimization }: SmartInsightsProps) {
  const [selectedInsight, setSelectedInsight] = useState<string | null>(null);

  const insightTypes = [
    {
      id: 'model-optimization',
      icon: '🤖',
      title: 'Model Optimization',
      insights: insights?.modelOptimization || []
    },
    {
      id: 'prompt-improvements',
      icon: '🔧',
      title: 'Prompt Improvements',
      insights: insights?.promptImprovements || []
    },
    {
      id: 'cost-optimization',
      icon: '💰',
      title: 'Cost Optimization',
      insights: insights?.costOptimization || []
    }
  ];

  return (
    <div className="space-y-3">
      <h3 className="font-medium">🎯 Smart Insights</h3>
      
      <div className="space-y-2 max-h-64 overflow-y-auto">
        {insightTypes.map(type => (
          <div key={type.id}>
            {type.insights.map((insight: any, index: number) => (
              <div
                key={`${type.id}-${index}`}
                className="p-3 border rounded hover:bg-muted cursor-pointer"
                onClick={() => setSelectedInsight(insight.id)}
              >
                <div className="flex items-start gap-3">
                  <span className="text-lg">{type.icon}</span>
                  <div className="flex-1">
                    <div className="font-medium text-sm">{insight.title}</div>
                    <div className="text-xs text-muted-foreground mt-1">
                      {insight.description}
                    </div>
                    <div className="flex items-center gap-2 mt-2">
                      <span className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded">
                        +{insight.improvement}
                      </span>
                      <span className="text-xs text-muted-foreground">
                        Impact: {insight.impact}
                      </span>
                    </div>
                  </div>
                </div>
                
                {selectedInsight === insight.id && (
                  <div className="mt-3 pt-3 border-t">
                    <div className="text-sm space-y-2">
                      <div><strong>Details:</strong> {insight.details}</div>
                      <div><strong>Expected Outcome:</strong> {insight.expectedOutcome}</div>
                      <div className="flex gap-2">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            onApplyOptimization(insight.id);
                          }}
                          className="px-3 py-1 bg-blue-600 text-white rounded text-xs"
                        >
                          🚀 Apply
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setSelectedInsight(null);
                          }}
                          className="px-3 py-1 border rounded text-xs"
                        >
                          Cancel
                        </button>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        ))}
      </div>

      {insights?.optimizations?.length > 0 && (
        <button
          onClick={() => onApplyOptimization('apply-all')}
          className="w-full px-3 py-2 bg-green-600 text-white rounded text-sm"
        >
          🚀 Apply All Optimizations
        </button>
      )}
    </div>
  );
}
```

### **3. Provider Performance Comparison**

#### **ProviderComparison.tsx**
```typescript
// components/ai/console/Analytics/ProviderComparison.tsx
interface ProviderComparisonProps {
  comparison: any;
  organizationId: string;
}

export function ProviderComparison({ comparison, organizationId }: ProviderComparisonProps) {
  const providers = [
    {
      id: 'google',
      name: 'Google Vision',
      metrics: comparison?.google || {}
    },
    {
      id: 'gemini', 
      name: 'Gemini 1.5',
      metrics: comparison?.gemini || {}
    }
  ];

  const getScoreColor = (score: number, isReversed = false) => {
    if (isReversed) {
      return score < 70 ? 'text-green-600' : score < 90 ? 'text-yellow-600' : 'text-red-600';
    }
    return score > 90 ? 'text-green-600' : score > 70 ? 'text-yellow-600' : 'text-red-600';
  };

  const getBestProvider = (metricKey: string) => {
    const googleValue = comparison?.google?.[metricKey] || 0;
    const geminiValue = comparison?.gemini?.[metricKey] || 0;
    
    // For speed and cost, lower is better
    if (metricKey === 'avgResponseTime' || metricKey === 'costPerPhoto') {
      return googleValue < geminiValue ? 'google' : 'gemini';
    }
    // For accuracy, higher is better
    return googleValue > geminiValue ? 'google' : 'gemini';
  };

  return (
    <div className="space-y-3">
      <h3 className="font-medium">⚖️ Provider Comparison</h3>
      
      <div className="space-y-3">
        {providers.map(provider => (
          <div key={provider.id} className="border rounded p-3">
            <div className="font-medium text-sm mb-2">{provider.name}</div>
            
            <div className="grid grid-cols-3 gap-2 text-xs">
              <div>
                <div className="text-muted-foreground">Speed</div>
                <div className={`font-medium ${getScoreColor(provider.metrics.avgResponseTime * 100, true)}`}>
                  {provider.metrics.avgResponseTime?.toFixed(1) || '0.0'}s
                  {getBestProvider('avgResponseTime') === provider.id && ' ⭐'}
                </div>
              </div>
              
              <div>
                <div className="text-muted-foreground">Accuracy</div>
                <div className={`font-medium ${getScoreColor(provider.metrics.accuracy || 0)}`}>
                  {provider.metrics.accuracy?.toFixed(0) || '0'}%
                  {getBestProvider('accuracy') === provider.id && ' ⭐'}
                </div>
              </div>
              
              <div>
                <div className="text-muted-foreground">Cost</div>
                <div className={`font-medium ${getScoreColor(provider.metrics.costPerPhoto * 1000, true)}`}>
                  ${provider.metrics.costPerPhoto?.toFixed(3) || '0.000'}
                  {getBestProvider('costPerPhoto') === provider.id && ' ⭐'}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Recommendation */}
      {comparison?.recommendation && (
        <div className="bg-blue-50 border border-blue-200 rounded p-3">
          <div className="text-sm font-medium text-blue-800">🎯 Recommendation</div>
          <div className="text-sm text-blue-700 mt-1">
            {comparison.recommendation.message}
          </div>
          {comparison.recommendation.action && (
            <button className="mt-2 px-3 py-1 bg-blue-600 text-white rounded text-xs">
              {comparison.recommendation.action}
            </button>
          )}
        </div>
      )}
    </div>
  );
}
```

### **4. ROI Analysis Component**

#### **ROIAnalysis.tsx**
```typescript
// components/ai/console/Analytics/ROIAnalysis.tsx
interface ROIAnalysisProps {
  roi: any;
  timeRange: string;
}

export function ROIAnalysis({ roi, timeRange }: ROIAnalysisProps) {
  const metrics = [
    {
      label: 'Cost per accurate tag',
      value: `$${roi?.costPerAccurateTag?.toFixed(3) || '0.000'}`,
      trend: roi?.costTrend || '→'
    },
    {
      label: 'Processing efficiency',
      value: `${roi?.processingEfficiency?.toFixed(1) || '0.0'}%`,
      trend: roi?.efficiencyTrend || '→'
    },
    {
      label: 'Error rate',
      value: `${roi?.errorRate?.toFixed(1) || '0.0'}%`,
      trend: roi?.errorTrend || '→'
    }
  ];

  const categoryPerformance = [
    { name: 'Machine Detection', accuracy: roi?.categories?.machine || 0, color: 'bg-green-500' },
    { name: 'Hazard Detection', accuracy: roi?.categories?.hazard || 0, color: 'bg-yellow-500' },
    { name: 'Control Detection', accuracy: roi?.categories?.control || 0, color: 'bg-red-500' }
  ];

  return (
    <div className="space-y-3">
      <h3 className="font-medium">💰 ROI Analysis</h3>
      
      {/* Key Metrics */}
      <div className="space-y-2">
        {metrics.map((metric, index) => (
          <div key={index} className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">{metric.label}:</span>
            <div className="flex items-center gap-1">
              <span className="font-medium">{metric.value}</span>
              <span className={`text-xs ${
                metric.trend === '↑' ? 'text-green-600' : 
                metric.trend === '↓' ? 'text-red-600' : 'text-muted-foreground'
              }`}>
                {metric.trend}
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Category Performance */}
      <div>
        <div className="text-sm text-muted-foreground mb-2">Performance by Category</div>
        <div className="space-y-1">
          {categoryPerformance.map((category, index) => (
            <div key={index} className="flex items-center gap-2">
              <div className={`w-2 h-2 rounded ${category.color}`}></div>
              <span className="text-xs flex-1">{category.name}</span>
              <span className="text-xs font-medium">{category.accuracy}%</span>
            </div>
          ))}
        </div>
      </div>

      {/* Optimization Potential */}
      {roi?.optimizationPotential && (
        <div className="bg-green-50 border border-green-200 rounded p-2">
          <div className="text-sm font-medium text-green-800">Optimization Potential</div>
          <div className="text-sm text-green-700">
            Save ${roi.optimizationPotential.monthlySavings}/month
          </div>
          <div className="text-xs text-green-600 mt-1">
            {roi.optimizationPotential.method}
          </div>
        </div>
      )}
    </div>
  );
}
```

### **5. Enhanced Analytics APIs**

#### **AI Insights Generation API**
```typescript
// /api/ai/analytics/insights/route.ts
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const organizationId = searchParams.get('org');
  const timeRange = searchParams.get('range') || '30d';

  try {
    // Analyze performance data to generate insights
    const performanceData = await getPerformanceData(organizationId, timeRange);
    const insights = await generateSmartInsights(performanceData);

    return NextResponse.json(insights);
  } catch (error) {
    return NextResponse.json({ error: 'Failed to generate insights' }, { status: 500 });
  }
}

async function generateSmartInsights(performanceData: any) {
  const insights = {
    modelOptimization: [],
    promptImprovements: [],
    costOptimization: []
  };

  // Analyze model performance differences
  if (performanceData.geminiAccuracy > performanceData.googleAccuracy + 5) {
    insights.modelOptimization.push({
      id: 'switch-to-gemini-high-value',
      title: 'Switch to Gemini for high-value photos',
      description: `Gemini shows ${(performanceData.geminiAccuracy - performanceData.googleAccuracy).toFixed(1)}% better accuracy`,
      improvement: `+${(performanceData.geminiAccuracy - performanceData.googleAccuracy).toFixed(1)}% accuracy`,
      impact: 'High',
      details: 'Analysis shows Gemini consistently outperforms Google Vision for complex safety photos',
      expectedOutcome: 'Improved tag accuracy with minimal cost increase'
    });
  }

  // Analyze prompt performance
  const lowConfidenceCategories = performanceData.categories
    .filter((cat: any) => cat.avgConfidence < 75)
    .sort((a: any, b: any) => a.avgConfidence - b.avgConfidence);

  lowConfidenceCategories.forEach((category: any) => {
    insights.promptImprovements.push({
      id: `optimize-prompt-${category.name}`,
      title: `Optimize ${category.name} detection prompt`,
      description: `Current confidence: ${category.avgConfidence}%`,
      improvement: `+8% confidence`,
      impact: 'Medium',
      details: `The ${category.name} detection prompt could be more specific about key visual indicators`,
      expectedOutcome: 'Higher confidence scores and fewer manual corrections needed'
    });
  });

  // Analyze cost optimization opportunities
  if (performanceData.dailyCost > performanceData.budget * 0.8) {
    insights.costOptimization.push({
      id: 'hybrid-provider-strategy',
      title: 'Implement hybrid provider strategy',
      description: 'Use cheaper provider for simple photos',
      improvement: '-25% costs',
      impact: 'High',
      details: 'Route simple photos to Google Vision, complex photos to Gemini',
      expectedOutcome: 'Significant cost reduction while maintaining accuracy'
    });
  }

  return insights;
}
```

#### **Provider Comparison API**
```typescript
// /api/ai/analytics/provider-comparison/route.ts
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const organizationId = searchParams.get('org');
  const timeRange = searchParams.get('range') || '30d';

  try {
    const comparison = await generateProviderComparison(organizationId, timeRange);
    return NextResponse.json(comparison);
  } catch (error) {
    return NextResponse.json({ error: 'Failed to generate comparison' }, { status: 500 });
  }
}

async function generateProviderComparison(organizationId: string, timeRange: string) {
  // Query processing results by provider
  const { data: results } = await supabase
    .from('ai_processing_results')
    .select('*')
    .eq('organization_id', organizationId)
    .gte('created_at', getDateRangeStart(timeRange));

  const googleResults = results?.filter(r => r.ai_provider === 'google') || [];
  const geminiResults = results?.filter(r => r.ai_provider === 'gemini') || [];

  const google = {
    avgResponseTime: googleResults.reduce((sum, r) => sum + (r.provider_response_time_ms || 0), 0) / googleResults.length / 1000,
    accuracy: calculateAccuracy(googleResults),
    costPerPhoto: googleResults.reduce((sum, r) => sum + (r.cost || 0), 0) / googleResults.length,
    totalProcessed: googleResults.length
  };

  const gemini = {
    avgResponseTime: geminiResults.reduce((sum, r) => sum + (r.provider_response_time_ms || 0), 0) / geminiResults.length / 1000,
    accuracy: calculateAccuracy(geminiResults),
    costPerPhoto: geminiResults.reduce((sum, r) => sum + (r.cost || 0), 0) / geminiResults.length,
    totalProcessed: geminiResults.length
  };

  // Generate recommendation
  const recommendation = generateProviderRecommendation(google, gemini);

  return { google, gemini, recommendation };
}

function generateProviderRecommendation(google: any, gemini: any) {
  if (gemini.accuracy > google.accuracy + 5 && gemini.costPerPhoto < google.costPerPhoto * 2) {
    return {
      message: `Consider switching to Gemini for a ${(gemini.accuracy - google.accuracy).toFixed(1)}% accuracy improvement`,
      action: '🔄 Switch to Gemini'
    };
  } else if (google.avgResponseTime < gemini.avgResponseTime * 0.7) {
    return {
      message: 'Google Vision provides significantly faster processing for time-sensitive workflows',
      action: '⚡ Optimize for Speed'
    };
  }
  
  return {
    message: 'Current provider selection is well-balanced for your workload',
    action: null
  };
}
```

## Implementation Tasks

### **Week 4 Tasks**

#### **Day 1-2: Analytics Infrastructure**
- [ ] Build `PerformanceAnalytics.tsx` main component
- [ ] Create `SmartInsights.tsx` with AI-generated recommendations
- [ ] Implement `/api/ai/analytics/insights` endpoint with insight generation logic
- [ ] Set up provider comparison analytics

#### **Day 3-4: Advanced Analytics**
- [ ] Build `ProviderComparison.tsx` with real-time metrics
- [ ] Create `ROIAnalysis.tsx` for cost optimization insights
- [ ] Implement trend forecasting and capacity planning
- [ ] Add automated optimization application

#### **Day 5: Integration and Polish**
- [ ] Integrate all analytics components into main console
- [ ] Add export functionality for reports
- [ ] Performance optimization for large datasets
- [ ] Comprehensive testing and documentation

## Acceptance Criteria

### **Functional Requirements**
- [ ] Analytics load in under 3 seconds
- [ ] Smart insights provide actionable recommendations
- [ ] Provider comparison shows real-time metrics
- [ ] ROI analysis tracks cost optimization opportunities
- [ ] Automated optimizations can be applied with one click

### **User Experience Requirements**
- [ ] Insights are clearly explained and actionable
- [ ] Charts and metrics are easy to interpret
- [ ] Recommendations include expected impact
- [ ] Export functionality works for reporting

### **Performance Requirements**
- [ ] Analytics queries complete in <2 seconds
- [ ] Insights generation completes in <5 seconds
- [ ] UI remains responsive during data loading
- [ ] Memory usage optimized for large datasets

## Success Metrics

### **Optimization Impact**
- [ ] 30% of insights result in measurable improvements
- [ ] 20% cost reduction through automated optimization
- [ ] 15% accuracy improvement through prompt optimization
- [ ] 50% reduction in manual performance monitoring

### **Developer Satisfaction**
- [ ] "Analytics provide actionable insights" - 90% agreement
- [ ] "Recommendations help optimize AI performance" - 85% agreement
- [ ] "ROI tracking helps with budget planning" - 80% agreement

## Risk Mitigation

### **Technical Risks**
- **Data Accuracy**: Validate analytics calculations against known baselines
- **Performance**: Optimize queries for large datasets and long time ranges
- **Insight Quality**: Continuously improve insight generation algorithms

### **User Experience Risks**
- **Information Overload**: Present insights progressively, most important first
- **Trust in Recommendations**: Provide detailed explanations and expected outcomes
- **Action Paralysis**: Prioritize recommendations by impact and effort

## Phase 4 Deliverables

1. **AI-powered insights engine** with automated optimization recommendations
2. **Real-time provider comparison** with performance metrics
3. **ROI analysis dashboard** for cost optimization
4. **Trend forecasting** for capacity planning
5. **Automated optimization system** for one-click improvements
6. **Comprehensive analytics APIs** for data-driven decisions

This phase completes the transformation of the AI management platform into an intelligent, self-optimizing system that not only monitors performance but actively suggests and implements improvements.