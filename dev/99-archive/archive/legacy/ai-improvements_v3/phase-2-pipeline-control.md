# Phase 2: AI Pipeline Control Center

*AI Management Platform v4 - Phase 2 Implementation*

## Overview

Create the core control interface that gives developers direct access to the AI processing pipeline. This phase addresses the primary pain point: making it easy to edit prompts, switch models, and configure processing rules without navigating complex interfaces.

## Goals

- **Direct Prompt Control**: Edit system prompts that drive photo tagging with immediate preview
- **One-Click Model Switching**: Switch between Google Vision and Gemini with clear impact visibility
- **Processing Configuration**: Set confidence thresholds, auto-apply rules, and cost limits
- **Provider Management**: Configure API settings, rate limits, and fallback strategies

## Current State Analysis

### **The Core Problem**
```
Current Workflow: Features Tab → FeaturePromptManager → Complex Form → Save → ???
Developer Need: Quick prompt edit → Test → Deploy → Monitor impact

Current Model Switching: Models Tab → Provider Config → Multiple Forms
Developer Need: "Use Gemini for this batch" → One click → Done
```

### **Existing Infrastructure to Leverage**
- **Prompt Service**: Complete CRUD operations at `/api/ai/prompts/*`
- **Model Registry**: Provider switching logic in `lib/ai/model-registry.ts`
- **Processing Pipeline**: Configuration in `lib/ai-processing.ts`
- **Database Schema**: All needed tables already exist

## Pipeline Control Interface Design

### **Visual Layout**
```
┌─────────────────────────────────────────────────────────────┐
│ ⚙️ AI Pipeline Control                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────┐ ┌─────────────────────┐             │
│ │ 📝 Prompt Editor    │ │ 🤖 Model Selector   │             │
│ │                     │ │                     │             │
│ │ [System Prompts ▼]  │ │ Current: Google     │             │
│ │                     │ │ Switch to: Gemini   │             │
│ │ Tag Generation:     │ │                     │             │
│ │ ┌─────────────────┐ │ │ ✅ Google Vision     │             │
│ │ │You are analyzing│ │ │    Speed: Fast      │             │
│ │ │industrial safety│ │ │    Cost: Low        │             │
│ │ │photos. Identify │ │ │    Accuracy: 89%    │             │
│ │ │machine types,   │ │ │                     │             │
│ │ │hazards, and     │ │ │ 🔄 Gemini 1.5       │             │
│ │ │safety controls..│ │ │    Speed: Medium    │             │
│ │ └─────────────────┘ │ │    Cost: Medium     │             │
│ │                     │ │    Accuracy: 94%    │             │
│ │ [💾 Save] [🧪 Test] │ │                     │             │
│ └─────────────────────┘ │ [🔄 Switch Model]   │             │
│                         └─────────────────────┘             │
│                                                             │
│ ┌─────────────────────┐ ┌─────────────────────┐             │
│ │ ⚙️ Processing Rules │ │ 🔧 Provider Config  │             │
│ │                     │ │                     │             │
│ │ Confidence: 75% ▼   │ │ API Keys: ✅ Valid  │             │
│ │ Auto-apply: 80% ▼   │ │ Rate Limits: Normal │             │
│ │ Max Cost: $50/day   │ │ Fallback: Enabled   │             │
│ │ Retry: 3 attempts   │ │ Timeout: 30s        │             │
│ │                     │ │                     │             │
│ │ [💾 Apply Changes]  │ │ [🔧 Configure]      │             │
│ └─────────────────────┘ └─────────────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Technical Implementation

### **1. Pipeline Control Main Component**

#### **PipelineControl.tsx**
```typescript
// components/ai/console/PipelineControl/PipelineControl.tsx
'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { PromptEditor } from './PromptEditor';
import { ModelSelector } from './ModelSelector';
import { ProcessingRules } from './ProcessingRules';
import { ProviderConfig } from './ProviderConfig';

interface PipelineControlProps {
  organizationId: string;
  onUpdate: () => void;
}

export function PipelineControl({ organizationId, onUpdate }: PipelineControlProps) {
  const [activePrompts, setActivePrompts] = useState<any[]>([]);
  const [currentModel, setCurrentModel] = useState<string>('google');
  const [processingConfig, setProcessingConfig] = useState<any>(null);
  const [hasChanges, setHasChanges] = useState(false);

  useEffect(() => {
    loadPipelineData();
  }, [organizationId]);

  const loadPipelineData = async () => {
    try {
      const [prompts, models, config] = await Promise.all([
        fetch(`/api/ai/pipeline/prompts?org=${organizationId}`).then(r => r.json()),
        fetch(`/api/ai/pipeline/models?org=${organizationId}`).then(r => r.json()),
        fetch(`/api/ai/pipeline/config?org=${organizationId}`).then(r => r.json())
      ]);

      setActivePrompts(prompts);
      setCurrentModel(models.active);
      setProcessingConfig(config);
    } catch (error) {
      console.error('Failed to load pipeline data:', error);
    }
  };

  const handlePromptChange = (promptId: string, content: string) => {
    setActivePrompts(prev => 
      prev.map(p => p.id === promptId ? { ...p, content } : p)
    );
    setHasChanges(true);
  };

  const handleModelSwitch = async (newModel: string) => {
    try {
      const response = await fetch('/api/ai/pipeline/models', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          organizationId,
          activeModel: newModel
        })
      });

      if (response.ok) {
        setCurrentModel(newModel);
        onUpdate(); // Refresh live status
      }
    } catch (error) {
      console.error('Model switch failed:', error);
    }
  };

  const saveChanges = async () => {
    try {
      await fetch('/api/ai/pipeline/prompts', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          organizationId,
          prompts: activePrompts
        })
      });

      setHasChanges(false);
      onUpdate(); // Refresh live status
    } catch (error) {
      console.error('Save failed:', error);
    }
  };

  return (
    <Card className="h-[400px]">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          ⚙️ Pipeline Control
          {hasChanges && (
            <span className="text-sm text-orange-500">• Unsaved changes</span>
          )}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 h-full">
          {/* Top Row */}
          <PromptEditor
            prompts={activePrompts}
            onChange={handlePromptChange}
            onSave={saveChanges}
            hasChanges={hasChanges}
          />
          
          <ModelSelector
            currentModel={currentModel}
            onSwitch={handleModelSwitch}
            organizationId={organizationId}
          />
          
          {/* Bottom Row */}
          <ProcessingRules
            config={processingConfig}
            onChange={(config) => {
              setProcessingConfig(config);
              setHasChanges(true);
            }}
            onSave={saveChanges}
          />
          
          <ProviderConfig
            organizationId={organizationId}
            onConfigChange={loadPipelineData}
          />
        </div>
      </CardContent>
    </Card>
  );
}
```

### **2. Direct Prompt Editor**

#### **PromptEditor.tsx**
```typescript
// components/ai/console/PipelineControl/PromptEditor.tsx
interface PromptEditorProps {
  prompts: any[];
  onChange: (promptId: string, content: string) => void;
  onSave: () => void;
  hasChanges: boolean;
}

export function PromptEditor({ prompts, onChange, onSave, hasChanges }: PromptEditorProps) {
  const [selectedPrompt, setSelectedPrompt] = useState<string>('tag-generation');
  const [isEditing, setIsEditing] = useState(false);

  const currentPrompt = prompts.find(p => p.id === selectedPrompt);

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h3 className="font-medium">📝 Prompt Editor</h3>
        <button 
          onClick={() => setIsEditing(!isEditing)}
          className="text-sm text-blue-600"
        >
          {isEditing ? '👁️ Preview' : '✏️ Edit'}
        </button>
      </div>

      {/* Prompt Selector */}
      <select
        value={selectedPrompt}
        onChange={(e) => setSelectedPrompt(e.target.value)}
        className="w-full p-2 border rounded text-sm"
      >
        <option value="tag-generation">Tag Generation</option>
        <option value="description-generation">Description Generation</option>
        <option value="hazard-detection">Hazard Detection</option>
        <option value="machine-identification">Machine Identification</option>
      </select>

      {/* Prompt Content */}
      <div className="flex-1">
        {isEditing ? (
          <textarea
            value={currentPrompt?.content || ''}
            onChange={(e) => onChange(selectedPrompt, e.target.value)}
            className="w-full h-32 p-3 border rounded text-sm font-mono"
            placeholder="Enter your prompt..."
          />
        ) : (
          <div className="h-32 p-3 border rounded text-sm bg-muted overflow-y-auto">
            {currentPrompt?.content || 'No prompt content'}
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="flex gap-2">
        <button
          onClick={onSave}
          disabled={!hasChanges}
          className="px-3 py-1 bg-blue-600 text-white rounded text-sm disabled:opacity-50"
        >
          💾 Save
        </button>
        <button
          className="px-3 py-1 border rounded text-sm hover:bg-muted"
          onClick={() => {/* Navigate to testing lab */}}
        >
          🧪 Test
        </button>
      </div>
    </div>
  );
}
```

### **3. One-Click Model Selector**

#### **ModelSelector.tsx**
```typescript
// components/ai/console/PipelineControl/ModelSelector.tsx
interface ModelSelectorProps {
  currentModel: string;
  onSwitch: (model: string) => void;
  organizationId: string;
}

export function ModelSelector({ currentModel, onSwitch, organizationId }: ModelSelectorProps) {
  const [modelStats, setModelStats] = useState<any>(null);
  const [isSwitching, setIsSwitching] = useState(false);

  useEffect(() => {
    loadModelStats();
  }, [organizationId]);

  const loadModelStats = async () => {
    try {
      const response = await fetch(`/api/ai/models/stats?org=${organizationId}`);
      const stats = await response.json();
      setModelStats(stats);
    } catch (error) {
      console.error('Failed to load model stats:', error);
    }
  };

  const handleSwitch = async (newModel: string) => {
    setIsSwitching(true);
    try {
      await onSwitch(newModel);
    } finally {
      setIsSwitching(false);
    }
  };

  const models = [
    {
      id: 'google',
      name: 'Google Vision',
      speed: 'Fast',
      cost: 'Low',
      accuracy: modelStats?.google?.accuracy || 89
    },
    {
      id: 'gemini',
      name: 'Gemini 1.5',
      speed: 'Medium',
      cost: 'Medium',
      accuracy: modelStats?.gemini?.accuracy || 94
    }
  ];

  return (
    <div className="space-y-3">
      <h3 className="font-medium">🤖 Model Selector</h3>
      
      <div className="text-sm">
        <span className="text-muted-foreground">Current: </span>
        <span className="font-medium">{models.find(m => m.id === currentModel)?.name}</span>
      </div>

      <div className="space-y-2">
        {models.map((model) => (
          <div
            key={model.id}
            className={`p-3 border rounded ${
              model.id === currentModel ? 'border-blue-500 bg-blue-50' : 'border-gray-200'
            }`}
          >
            <div className="flex items-center justify-between">
              <div>
                <div className="font-medium">{model.name}</div>
                <div className="text-sm text-muted-foreground">
                  Speed: {model.speed} • Cost: {model.cost} • Accuracy: {model.accuracy}%
                </div>
              </div>
              {model.id === currentModel ? (
                <span className="text-green-600">✅ Active</span>
              ) : (
                <button
                  onClick={() => handleSwitch(model.id)}
                  disabled={isSwitching}
                  className="px-2 py-1 text-sm border rounded hover:bg-muted"
                >
                  Switch
                </button>
              )}
            </div>
          </div>
        ))}
      </div>

      {isSwitching && (
        <div className="text-sm text-blue-600">🔄 Switching models...</div>
      )}
    </div>
  );
}
```

### **4. Processing Rules Configuration**

#### **ProcessingRules.tsx**
```typescript
// components/ai/console/PipelineControl/ProcessingRules.tsx
interface ProcessingRulesProps {
  config: any;
  onChange: (config: any) => void;
  onSave: () => void;
}

export function ProcessingRules({ config, onChange, onSave }: ProcessingRulesProps) {
  const updateConfig = (key: string, value: any) => {
    onChange({
      ...config,
      [key]: value
    });
  };

  return (
    <div className="space-y-3">
      <h3 className="font-medium">⚙️ Processing Rules</h3>
      
      <div className="space-y-3">
        {/* Confidence Threshold */}
        <div>
          <label className="text-sm text-muted-foreground">
            Confidence Threshold: {config?.confidenceThreshold || 75}%
          </label>
          <input
            type="range"
            min="50"
            max="95"
            step="5"
            value={config?.confidenceThreshold || 75}
            onChange={(e) => updateConfig('confidenceThreshold', parseInt(e.target.value))}
            className="w-full"
          />
        </div>

        {/* Auto-apply Threshold */}
        <div>
          <label className="text-sm text-muted-foreground">
            Auto-apply at: {config?.autoApplyThreshold || 80}%
          </label>
          <input
            type="range"
            min="70"
            max="95"
            step="5"
            value={config?.autoApplyThreshold || 80}
            onChange={(e) => updateConfig('autoApplyThreshold', parseInt(e.target.value))}
            className="w-full"
          />
        </div>

        {/* Daily Cost Limit */}
        <div>
          <label className="text-sm text-muted-foreground">Max Daily Cost</label>
          <div className="flex items-center gap-2">
            <span>$</span>
            <input
              type="number"
              min="10"
              max="1000"
              value={config?.dailyCostLimit || 50}
              onChange={(e) => updateConfig('dailyCostLimit', parseInt(e.target.value))}
              className="flex-1 p-1 border rounded text-sm"
            />
          </div>
        </div>

        {/* Retry Attempts */}
        <div>
          <label className="text-sm text-muted-foreground">Retry Attempts</label>
          <select
            value={config?.retryAttempts || 3}
            onChange={(e) => updateConfig('retryAttempts', parseInt(e.target.value))}
            className="w-full p-1 border rounded text-sm"
          >
            <option value="1">1 attempt</option>
            <option value="2">2 attempts</option>
            <option value="3">3 attempts</option>
            <option value="5">5 attempts</option>
          </select>
        </div>
      </div>

      <button
        onClick={onSave}
        className="w-full px-3 py-2 bg-blue-600 text-white rounded text-sm"
      >
        💾 Apply Changes
      </button>
    </div>
  );
}
```

### **5. Enhanced API Endpoints**

#### **Pipeline Prompts API**
```typescript
// /api/ai/pipeline/prompts/route.ts
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const organizationId = searchParams.get('org');

  try {
    // Get active prompts for the organization
    const { data: prompts } = await supabase
      .from('ai_prompt_templates')
      .select('*')
      .eq('organization_id', organizationId)
      .eq('is_active', true)
      .order('category');

    // Format for direct editing
    const formattedPrompts = prompts?.map(prompt => ({
      id: prompt.name,
      category: prompt.category,
      content: prompt.content,
      variables: prompt.variables || {},
      lastModified: prompt.updated_at
    })) || [];

    return NextResponse.json(formattedPrompts);
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch prompts' }, { status: 500 });
  }
}

export async function PUT(request: NextRequest) {
  const { organizationId, prompts } = await request.json();

  try {
    // Update prompts in database
    for (const prompt of prompts) {
      await supabase
        .from('ai_prompt_templates')
        .update({
          content: prompt.content,
          updated_at: new Date().toISOString()
        })
        .eq('organization_id', organizationId)
        .eq('name', prompt.id);
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to update prompts' }, { status: 500 });
  }
}
```

#### **Model Switching API**
```typescript
// /api/ai/pipeline/models/route.ts
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const organizationId = searchParams.get('org');

  try {
    // Get current model configuration
    const { data: settings } = await supabase
      .from('organization_settings')
      .select('ai_settings')
      .eq('id', organizationId)
      .single();

    const activeModel = settings?.ai_settings?.defaultProvider || 'google';

    return NextResponse.json({ active: activeModel });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch model config' }, { status: 500 });
  }
}

export async function PUT(request: NextRequest) {
  const { organizationId, activeModel } = await request.json();

  try {
    // Update organization's default provider
    const { data: currentSettings } = await supabase
      .from('organization_settings')
      .select('ai_settings')
      .eq('id', organizationId)
      .single();

    const updatedSettings = {
      ...(currentSettings?.ai_settings || {}),
      defaultProvider: activeModel,
      lastModelSwitch: new Date().toISOString()
    };

    await supabase
      .from('organization_settings')
      .update({ ai_settings: updatedSettings })
      .eq('id', organizationId);

    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to switch model' }, { status: 500 });
  }
}
```

## Implementation Tasks

### **Week 2 Tasks**

#### **Day 1-2: Core Components**
- [ ] Build `PipelineControl.tsx` main component
- [ ] Create `PromptEditor.tsx` with direct editing capability
- [ ] Implement `ModelSelector.tsx` with one-click switching
- [ ] Set up basic API endpoints for pipeline control

#### **Day 3-4: Configuration Tools**
- [ ] Build `ProcessingRules.tsx` for threshold and cost settings
- [ ] Create `ProviderConfig.tsx` for API key management
- [ ] Implement `/api/ai/pipeline/*` endpoints
- [ ] Add real-time updates to pipeline changes

#### **Day 5: Integration and Polish**
- [ ] Integrate all components into main console
- [ ] Test prompt editing and model switching workflows
- [ ] Add validation and error handling
- [ ] Performance optimization and polish

## Acceptance Criteria

### **Functional Requirements**
- [ ] Direct prompt editing saves in under 5 seconds
- [ ] Model switching takes effect immediately
- [ ] Configuration changes apply to new processing
- [ ] All changes reflected in Live Status area
- [ ] Provider configuration validates API keys

### **User Experience Requirements**
- [ ] Prompt editing feels like a code editor
- [ ] Model switching shows clear before/after comparison
- [ ] Configuration sliders provide immediate feedback
- [ ] Error states are clear and actionable
- [ ] All changes autosave or have clear save states

### **Performance Requirements**
- [ ] Prompt loading in <1 second
- [ ] Model switch completes in <3 seconds
- [ ] Configuration saves in <2 seconds
- [ ] No performance impact on existing processing

## Success Metrics

### **Task Efficiency**
- [ ] Prompt editing: 30 seconds (vs 5+ minutes currently)
- [ ] Model switching: 10 seconds (vs 2+ minutes currently)
- [ ] Configuration changes: 1 minute (vs 5+ minutes currently)

### **Developer Satisfaction**
- [ ] "Easy to edit prompts" - 90% agreement
- [ ] "Model switching is straightforward" - 85% agreement
- [ ] "Can quickly adjust settings" - 80% agreement

## Risk Mitigation

### **Technical Risks**
- **Prompt Validation**: Validate prompts before saving to prevent breaking changes
- **Model Switching**: Ensure graceful handling of in-flight processing
- **Configuration Impact**: Clear warnings about configuration change effects

### **User Experience Risks**
- **Accidental Changes**: Confirmation dialogs for major changes
- **Complex Prompts**: Syntax highlighting and validation for prompt editing
- **Error Recovery**: Clear rollback mechanisms for failed changes

## Phase 2 Deliverables

1. **Direct prompt editing interface** with immediate save/test
2. **One-click model switching** with performance comparison
3. **Processing configuration tools** for thresholds and limits
4. **Provider management interface** for API settings
5. **Enhanced pipeline APIs** for real-time control
6. **Integration** with existing processing system

This phase transforms the AI management experience from complex, multi-step processes to direct, immediate control over the core AI pipeline functionality.