# Phase 3: Developer Testing Lab

*AI Management Platform v4 - Phase 3 Implementation*

## Overview

Create a comprehensive testing environment that allows developers to validate prompt changes, run A/B experiments, and debug the AI processing pipeline before deploying changes to production. This phase ensures quality and reduces the risk of deploying ineffective prompts or configurations.

## Goals

- **Live Prompt Testing**: Test prompt changes with real photos before deployment
- **A/B Experiment Framework**: Compare prompt variations side-by-side with quantitative results
- **Validation Tools**: Prevent deployment of breaking changes or performance regressions
- **Debug Interface**: Step-by-step visibility into AI processing pipeline for troubleshooting

## Current State Analysis

### **The Testing Gap**
```
Current Process: Edit prompt → Save → Deploy → Hope it works → Fix issues later
Needed Process: Edit prompt → Test → Compare → Validate → Deploy with confidence

Current Debugging: "Why did this photo get tagged wrong?" → Guess → Try again
Needed Debugging: View exact processing steps → Identify issue → Fix precisely
```

### **Existing Infrastructure to Leverage**
- **Sample Photos**: Existing photos in database for testing
- **Processing Pipeline**: Complete AI processing logic that can be run in test mode
- **Prompt System**: Existing prompt templates and versioning
- **Analytics Data**: Historical performance for comparison baselines

## Testing Lab Interface Design

### **Visual Layout**
```
┌─────────────────────────────────────────────────────────────┐
│ 🧪 Testing Lab                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────┐ ┌─────────────────────┐             │
│ │ 🔬 Live Testing     │ │ ⚖️ A/B Experiments  │             │
│ │                     │ │                     │             │
│ │ [Sample Photo ▼]    │ │ Current vs New      │             │
│ │ ┌─────────────────┐ │ │                     │             │
│ │ │[📷 Safety Photo]│ │ │ Prompt A:           │             │
│ │ │                 │ │ │ ✅ Machine: CNC     │             │
│ │ │ Original: CNC   │ │ │ ✅ Hazard: Pinch    │             │
│ │ │ Current: CNC    │ │ │ ❌ Control: None    │             │
│ │ │ Test: CNC Mill  │ │ │ Score: 87%          │             │
│ │ └─────────────────┘ │ │                     │             │
│ │                     │ │ Prompt B:           │             │
│ │ Confidence: 89% ▲   │ │ ✅ Machine: CNC     │             │
│ │ Tags: +1 improved   │ │ ✅ Hazard: Pinch    │             │
│ │                     │ │ ✅ Control: Safety  │             │
│ │ [🧪 Test Another]   │ │ Score: 94% ⭐       │             │
│ └─────────────────────┘ │                     │             │
│                         │ [📊 Full Report]    │             │
│                         └─────────────────────┘             │
│                                                             │
│ ┌─────────────────────┐ ┌─────────────────────┐             │
│ │ ✅ Validation Tools │ │ 🔍 Debug Interface  │             │
│ │                     │ │                     │             │
│ │ ✅ Syntax Valid     │ │ Processing Steps:   │             │
│ │ ✅ Variables OK     │ │                     │             │
│ │ ⚠️ Token limit 95%  │ │ 1. Image Analysis   │             │
│ │ ✅ Performance OK   │ │ 2. Tag Generation   │             │
│ │ ❌ Cost +40%        │ │ 3. Confidence Check │             │
│ │                     │ │ 4. Result Mapping   │             │
│ │ [🚫 Block Deploy]   │ │                     │             │
│ │ [⚠️ Deploy Warning] │ │ [🔍 Step Details]   │             │
│ └─────────────────────┘ └─────────────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Technical Implementation

### **1. Testing Lab Main Component**

#### **TestingLab.tsx**
```typescript
// components/ai/console/TestingLab/TestingLab.tsx
'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LiveTesting } from './LiveTesting';
import { ExperimentManager } from './ExperimentManager';
import { ValidationTools } from './ValidationTools';
import { DebugInterface } from './DebugInterface';

interface TestingLabProps {
  organizationId: string;
  onTestComplete: () => void;
}

export function TestingLab({ organizationId, onTestComplete }: TestingLabProps) {
  const [activeTab, setActiveTab] = useState<'live' | 'experiments' | 'validation' | 'debug'>('live');
  const [testResults, setTestResults] = useState<any>(null);
  const [isRunningTest, setIsRunningTest] = useState(false);

  const runLiveTest = async (promptId: string, photoId: string, promptContent: string) => {
    setIsRunningTest(true);
    try {
      const response = await fetch('/api/ai/testing/live-test', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          organizationId,
          promptId,
          photoId,
          promptContent
        })
      });

      const results = await response.json();
      setTestResults(results);
      onTestComplete();
    } catch (error) {
      console.error('Live test failed:', error);
    } finally {
      setIsRunningTest(false);
    }
  };

  const runABExperiment = async (experimentConfig: any) => {
    setIsRunningTest(true);
    try {
      const response = await fetch('/api/ai/testing/ab-experiment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          organizationId,
          ...experimentConfig
        })
      });

      const results = await response.json();
      setTestResults(results);
    } catch (error) {
      console.error('A/B experiment failed:', error);
    } finally {
      setIsRunningTest(false);
    }
  };

  return (
    <Card className="h-[400px]">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          🧪 Testing Lab
          {isRunningTest && (
            <span className="text-sm text-blue-500">• Running test...</span>
          )}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Tab Navigation */}
        <div className="flex gap-2 border-b">
          <button
            onClick={() => setActiveTab('live')}
            className={`px-3 py-1 text-sm ${activeTab === 'live' ? 'border-b-2 border-blue-500' : ''}`}
          >
            🔬 Live Test
          </button>
          <button
            onClick={() => setActiveTab('experiments')}
            className={`px-3 py-1 text-sm ${activeTab === 'experiments' ? 'border-b-2 border-blue-500' : ''}`}
          >
            ⚖️ A/B Tests
          </button>
          <button
            onClick={() => setActiveTab('validation')}
            className={`px-3 py-1 text-sm ${activeTab === 'validation' ? 'border-b-2 border-blue-500' : ''}`}
          >
            ✅ Validation
          </button>
          <button
            onClick={() => setActiveTab('debug')}
            className={`px-3 py-1 text-sm ${activeTab === 'debug' ? 'border-b-2 border-blue-500' : ''}`}
          >
            🔍 Debug
          </button>
        </div>

        {/* Tab Content */}
        <div className="flex-1 overflow-hidden">
          {activeTab === 'live' && (
            <LiveTesting
              organizationId={organizationId}
              onRunTest={runLiveTest}
              testResults={testResults}
              isRunning={isRunningTest}
            />
          )}
          
          {activeTab === 'experiments' && (
            <ExperimentManager
              organizationId={organizationId}
              onRunExperiment={runABExperiment}
              experimentResults={testResults}
            />
          )}
          
          {activeTab === 'validation' && (
            <ValidationTools
              organizationId={organizationId}
            />
          )}
          
          {activeTab === 'debug' && (
            <DebugInterface
              organizationId={organizationId}
              testResults={testResults}
            />
          )}
        </div>
      </CardContent>
    </Card>
  );
}
```

### **2. Live Testing Component**

#### **LiveTesting.tsx**
```typescript
// components/ai/console/TestingLab/LiveTesting.tsx
interface LiveTestingProps {
  organizationId: string;
  onRunTest: (promptId: string, photoId: string, promptContent: string) => void;
  testResults: any;
  isRunning: boolean;
}

export function LiveTesting({ organizationId, onRunTest, testResults, isRunning }: LiveTestingProps) {
  const [selectedPhoto, setSelectedPhoto] = useState<string>('');
  const [selectedPrompt, setSelectedPrompt] = useState<string>('tag-generation');
  const [promptContent, setPromptContent] = useState<string>('');
  const [samplePhotos, setSamplePhotos] = useState<any[]>([]);

  useEffect(() => {
    loadSamplePhotos();
    loadPromptContent();
  }, [organizationId, selectedPrompt]);

  const loadSamplePhotos = async () => {
    try {
      const response = await fetch(`/api/ai/testing/sample-photos?org=${organizationId}&limit=10`);
      const photos = await response.json();
      setSamplePhotos(photos);
      if (photos.length > 0 && !selectedPhoto) {
        setSelectedPhoto(photos[0].id);
      }
    } catch (error) {
      console.error('Failed to load sample photos:', error);
    }
  };

  const loadPromptContent = async () => {
    try {
      const response = await fetch(`/api/ai/pipeline/prompts?org=${organizationId}`);
      const prompts = await response.json();
      const prompt = prompts.find((p: any) => p.id === selectedPrompt);
      setPromptContent(prompt?.content || '');
    } catch (error) {
      console.error('Failed to load prompt content:', error);
    }
  };

  const currentPhoto = samplePhotos.find(p => p.id === selectedPhoto);

  return (
    <div className="space-y-4 h-full">
      {/* Photo & Prompt Selection */}
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="text-sm text-muted-foreground">Sample Photo</label>
          <select
            value={selectedPhoto}
            onChange={(e) => setSelectedPhoto(e.target.value)}
            className="w-full p-2 border rounded text-sm"
          >
            {samplePhotos.map(photo => (
              <option key={photo.id} value={photo.id}>
                {photo.filename} - {photo.existing_tags?.slice(0, 2).join(', ')}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="text-sm text-muted-foreground">Prompt Template</label>
          <select
            value={selectedPrompt}
            onChange={(e) => setSelectedPrompt(e.target.value)}
            className="w-full p-2 border rounded text-sm"
          >
            <option value="tag-generation">Tag Generation</option>
            <option value="description-generation">Description Generation</option>
            <option value="hazard-detection">Hazard Detection</option>
          </select>
        </div>
      </div>

      {/* Photo Preview & Current Results */}
      {currentPhoto && (
        <div className="grid grid-cols-2 gap-4">
          <div>
            <div className="text-sm text-muted-foreground mb-2">Current Photo</div>
            <div className="border rounded p-3 space-y-2">
              <div className="w-full h-24 bg-muted rounded flex items-center justify-center">
                📷 {currentPhoto.filename}
              </div>
              <div className="text-sm">
                <div><strong>Current Tags:</strong></div>
                <div className="text-muted-foreground">
                  {currentPhoto.existing_tags?.join(', ') || 'No tags'}
                </div>
              </div>
            </div>
          </div>

          <div>
            <div className="text-sm text-muted-foreground mb-2">Test Results</div>
            {testResults ? (
              <div className="border rounded p-3 space-y-2">
                <div className="text-sm">
                  <div><strong>New Tags:</strong></div>
                  <div className="text-green-600">
                    {testResults.tags?.join(', ') || 'No tags generated'}
                  </div>
                </div>
                <div className="text-sm">
                  <div><strong>Confidence:</strong> {testResults.confidence}%</div>
                  <div><strong>Changes:</strong> {testResults.changes || 'No changes'}</div>
                </div>
              </div>
            ) : (
              <div className="border rounded p-3 text-sm text-muted-foreground">
                Run a test to see results here
              </div>
            )}
          </div>
        </div>
      )}

      {/* Test Actions */}
      <div className="flex gap-2">
        <button
          onClick={() => onRunTest(selectedPrompt, selectedPhoto, promptContent)}
          disabled={isRunning || !selectedPhoto}
          className="px-4 py-2 bg-blue-600 text-white rounded text-sm disabled:opacity-50"
        >
          {isRunning ? '🔄 Testing...' : '🧪 Run Test'}
        </button>
        
        <button
          onClick={loadSamplePhotos}
          className="px-4 py-2 border rounded text-sm hover:bg-muted"
        >
          🔄 New Sample
        </button>
      </div>
    </div>
  );
}
```

### **3. A/B Experiment Manager**

#### **ExperimentManager.tsx**
```typescript
// components/ai/console/TestingLab/ExperimentManager.tsx
interface ExperimentManagerProps {
  organizationId: string;
  onRunExperiment: (config: any) => void;
  experimentResults: any;
}

export function ExperimentManager({ organizationId, onRunExperiment, experimentResults }: ExperimentManagerProps) {
  const [promptA, setPromptA] = useState<string>('');
  const [promptB, setPromptB] = useState<string>('');
  const [testScope, setTestScope] = useState<'sample' | 'batch'>('sample');
  const [sampleSize, setSampleSize] = useState<number>(10);

  const runExperiment = () => {
    onRunExperiment({
      promptA,
      promptB,
      testScope,
      sampleSize
    });
  };

  return (
    <div className="space-y-4 h-full">
      {/* Experiment Configuration */}
      <div className="space-y-3">
        <div>
          <label className="text-sm text-muted-foreground">Test Scope</label>
          <select
            value={testScope}
            onChange={(e) => setTestScope(e.target.value as 'sample' | 'batch')}
            className="w-full p-2 border rounded text-sm"
          >
            <option value="sample">Sample Photos ({sampleSize})</option>
            <option value="batch">Recent Batch (50)</option>
          </select>
        </div>

        {testScope === 'sample' && (
          <div>
            <label className="text-sm text-muted-foreground">
              Sample Size: {sampleSize}
            </label>
            <input
              type="range"
              min="5"
              max="50"
              step="5"
              value={sampleSize}
              onChange={(e) => setSampleSize(parseInt(e.target.value))}
              className="w-full"
            />
          </div>
        )}
      </div>

      {/* Results Comparison */}
      {experimentResults && (
        <div className="grid grid-cols-2 gap-4">
          <div className="border rounded p-3">
            <h4 className="font-medium text-sm mb-2">Prompt A (Current)</h4>
            <div className="space-y-1 text-sm">
              <div>Accuracy: {experimentResults.promptA?.accuracy}%</div>
              <div>Confidence: {experimentResults.promptA?.avgConfidence}%</div>
              <div>Cost: ${experimentResults.promptA?.cost}</div>
              <div>Speed: {experimentResults.promptA?.avgTime}s</div>
            </div>
          </div>

          <div className="border rounded p-3">
            <h4 className="font-medium text-sm mb-2">Prompt B (Test)</h4>
            <div className="space-y-1 text-sm">
              <div className={experimentResults.promptB?.accuracy > experimentResults.promptA?.accuracy ? 'text-green-600' : ''}>
                Accuracy: {experimentResults.promptB?.accuracy}%
                {experimentResults.promptB?.accuracy > experimentResults.promptA?.accuracy && ' ⭐'}
              </div>
              <div>Confidence: {experimentResults.promptB?.avgConfidence}%</div>
              <div>Cost: ${experimentResults.promptB?.cost}</div>
              <div>Speed: {experimentResults.promptB?.avgTime}s</div>
            </div>
          </div>
        </div>
      )}

      {/* Action Buttons */}
      <div className="flex gap-2">
        <button
          onClick={runExperiment}
          disabled={!promptA || !promptB}
          className="px-4 py-2 bg-blue-600 text-white rounded text-sm disabled:opacity-50"
        >
          ⚖️ Run A/B Test
        </button>
        
        {experimentResults && experimentResults.promptB?.accuracy > experimentResults.promptA?.accuracy && (
          <button
            className="px-4 py-2 bg-green-600 text-white rounded text-sm"
            onClick={() => {/* Deploy prompt B */}}
          >
            🚀 Deploy Winner
          </button>
        )}
      </div>
    </div>
  );
}
```

### **4. Validation Tools**

#### **ValidationTools.tsx**
```typescript
// components/ai/console/TestingLab/ValidationTools.tsx
interface ValidationToolsProps {
  organizationId: string;
}

export function ValidationTools({ organizationId }: ValidationToolsProps) {
  const [validationResults, setValidationResults] = useState<any>(null);
  const [isValidating, setIsValidating] = useState(false);

  const runValidation = async () => {
    setIsValidating(true);
    try {
      const response = await fetch('/api/ai/testing/validation', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ organizationId })
      });
      
      const results = await response.json();
      setValidationResults(results);
    } catch (error) {
      console.error('Validation failed:', error);
    } finally {
      setIsValidating(false);
    }
  };

  useEffect(() => {
    runValidation();
  }, [organizationId]);

  const validationChecks = [
    {
      id: 'syntax',
      name: 'Prompt Syntax',
      status: validationResults?.syntax?.valid ? 'pass' : 'fail',
      message: validationResults?.syntax?.message || 'Checking...'
    },
    {
      id: 'variables',
      name: 'Variable References',
      status: validationResults?.variables?.valid ? 'pass' : 'warning',
      message: validationResults?.variables?.message || 'Checking...'
    },
    {
      id: 'tokens',
      name: 'Token Limit',
      status: validationResults?.tokens?.usage < 90 ? 'pass' : 'warning',
      message: `${validationResults?.tokens?.usage || 0}% of limit used`
    },
    {
      id: 'performance',
      name: 'Performance Impact',
      status: validationResults?.performance?.impact === 'low' ? 'pass' : 'warning',
      message: validationResults?.performance?.message || 'Checking...'
    },
    {
      id: 'cost',
      name: 'Cost Impact',
      status: validationResults?.cost?.increase < 20 ? 'pass' : 'fail',
      message: `+${validationResults?.cost?.increase || 0}% cost increase`
    }
  ];

  const hasBlockingIssues = validationChecks.some(check => check.status === 'fail');
  const hasWarnings = validationChecks.some(check => check.status === 'warning');

  return (
    <div className="space-y-4 h-full">
      <div className="flex items-center justify-between">
        <h3 className="font-medium">Pre-deployment Validation</h3>
        <button
          onClick={runValidation}
          disabled={isValidating}
          className="text-sm text-blue-600 hover:text-blue-800"
        >
          {isValidating ? '🔄 Validating...' : '🔄 Re-validate'}
        </button>
      </div>

      {/* Validation Results */}
      <div className="space-y-2">
        {validationChecks.map(check => (
          <div key={check.id} className="flex items-center gap-3 p-2 border rounded">
            <div className="w-6 h-6 flex items-center justify-center">
              {check.status === 'pass' && <span className="text-green-600">✅</span>}
              {check.status === 'warning' && <span className="text-yellow-600">⚠️</span>}
              {check.status === 'fail' && <span className="text-red-600">❌</span>}
            </div>
            <div className="flex-1">
              <div className="font-medium text-sm">{check.name}</div>
              <div className="text-xs text-muted-foreground">{check.message}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Action Recommendations */}
      <div className="border-t pt-4">
        {hasBlockingIssues ? (
          <button
            disabled
            className="w-full px-4 py-2 bg-red-100 text-red-700 rounded text-sm opacity-50"
          >
            🚫 Deployment Blocked
          </button>
        ) : hasWarnings ? (
          <button
            className="w-full px-4 py-2 bg-yellow-100 text-yellow-700 rounded text-sm"
          >
            ⚠️ Deploy with Warnings
          </button>
        ) : (
          <button
            className="w-full px-4 py-2 bg-green-100 text-green-700 rounded text-sm"
          >
            ✅ Safe to Deploy
          </button>
        )}
      </div>
    </div>
  );
}
```

### **5. Enhanced Testing APIs**

#### **Live Testing API**
```typescript
// /api/ai/testing/live-test/route.ts
export async function POST(request: NextRequest) {
  const { organizationId, promptId, photoId, promptContent } = await request.json();

  try {
    // Get the photo for testing
    const { data: photo } = await supabase
      .from('photos')
      .select('*')
      .eq('id', photoId)
      .eq('organization_id', organizationId)
      .single();

    if (!photo) {
      return NextResponse.json({ error: 'Photo not found' }, { status: 404 });
    }

    // Run AI processing with test prompt
    const testResult = await processPhotoWithPrompt(photo, promptContent);
    
    // Compare with existing tags
    const existingTags = photo.tags || [];
    const newTags = testResult.tags || [];
    
    const changes = {
      added: newTags.filter(tag => !existingTags.includes(tag)),
      removed: existingTags.filter(tag => !newTags.includes(tag)),
      unchanged: newTags.filter(tag => existingTags.includes(tag))
    };

    return NextResponse.json({
      photoId,
      existingTags,
      newTags,
      confidence: testResult.confidence,
      changes: `+${changes.added.length} added, -${changes.removed.length} removed`,
      processingTime: testResult.processingTime,
      cost: testResult.cost
    });
  } catch (error) {
    console.error('Live test error:', error);
    return NextResponse.json({ error: 'Test failed' }, { status: 500 });
  }
}

async function processPhotoWithPrompt(photo: any, promptContent: string) {
  // Use existing AI processing pipeline with custom prompt
  // This integrates with the existing provider factory and processing logic
  
  const provider = providerFactory.getProvider('google'); // or current active provider
  const result = await provider.processPhoto(photo, { customPrompt: promptContent });
  
  return {
    tags: result.tags,
    confidence: result.confidence,
    processingTime: result.processingTime,
    cost: result.cost
  };
}
```

## Implementation Tasks

### **Week 3 Tasks**

#### **Day 1-2: Core Testing Framework**
- [ ] Build `TestingLab.tsx` main component with tab navigation
- [ ] Create `LiveTesting.tsx` for real-time prompt testing
- [ ] Implement `/api/ai/testing/live-test` endpoint
- [ ] Set up sample photo selection and testing workflow

#### **Day 3-4: Advanced Features**
- [ ] Build `ExperimentManager.tsx` for A/B testing
- [ ] Create `ValidationTools.tsx` for pre-deployment checks
- [ ] Implement `/api/ai/testing/ab-experiment` endpoint
- [ ] Add validation API for syntax and performance checks

#### **Day 5: Debug Interface and Integration**
- [ ] Create `DebugInterface.tsx` for pipeline visibility
- [ ] Integrate all testing components into main console
- [ ] Add comprehensive error handling and edge cases
- [ ] Performance optimization and testing

## Acceptance Criteria

### **Functional Requirements**
- [ ] Live testing returns results in under 10 seconds
- [ ] A/B experiments can compare prompts across sample sizes
- [ ] Validation catches breaking changes before deployment
- [ ] Debug interface shows step-by-step processing details
- [ ] All testing happens in isolation from production

### **User Experience Requirements**
- [ ] Testing interface is intuitive for developers
- [ ] Results clearly show improvements/regressions
- [ ] Validation provides actionable feedback
- [ ] Testing doesn't impact production performance

### **Performance Requirements**
- [ ] Test execution completes in <10 seconds
- [ ] A/B experiments finish in <60 seconds for 10 samples
- [ ] Validation checks complete in <5 seconds
- [ ] No memory leaks during extended testing sessions

## Success Metrics

### **Quality Improvements**
- [ ] 95% of prompt changes tested before deployment
- [ ] 50% reduction in deployed prompts that need rollback
- [ ] 30% improvement in prompt optimization cycle time

### **Developer Confidence**
- [ ] "Testing gives me confidence in changes" - 90% agreement
- [ ] "A/B testing helps optimize prompts" - 85% agreement
- [ ] "Validation prevents production issues" - 80% agreement

## Risk Mitigation

### **Technical Risks**
- **Test Isolation**: Ensure testing doesn't affect production AI processing
- **Resource Usage**: Limit test execution to prevent excessive API costs
- **Data Accuracy**: Use representative sample photos for realistic testing

### **User Experience Risks**
- **Test Complexity**: Keep testing interface simple and focused
- **Result Interpretation**: Provide clear explanations of test results
- **Performance Impact**: Ensure testing doesn't slow down main interface

## Phase 3 Deliverables

1. **Live testing interface** for immediate prompt validation
2. **A/B experiment framework** for prompt optimization
3. **Validation tools** to prevent deployment issues
4. **Debug interface** for processing pipeline visibility
5. **Testing APIs** integrated with existing AI infrastructure
6. **Documentation** for testing workflows and best practices

This phase completes the transformation from "deploy and hope" to "test and deploy with confidence," dramatically improving the quality and reliability of AI optimizations.