# Agent 6: Configuration & Settings Management

*Priority: MEDIUM | Timeline: 3-4 days | Dependencies: Agent 1 (Dashboard), Agent 2 (Prompts), Agent 3 (Models)*

## Mission & Context

### What You're Building
Create comprehensive configuration management tools that allow developers to set up industry-specific presets, manage AI feature settings, configure thresholds and limits, and provide guided setup for new organizations.

### Problem Statement
Developers need easy ways to configure AI systems for different industries, use cases, and organizational requirements, with smart defaults that reduce setup time while maintaining flexibility for customization.

### Success Criteria
- Industry-specific configuration presets (Manufacturing, Construction, Oil & Gas, etc.)
- Guided setup wizard for new organizations
- Advanced configuration management for AI features
- Template system for reusable configurations
- Configuration validation and conflict detection

## Technical Foundation

### Existing Configuration APIs
```typescript
// Organization settings (already exists)
GET /api/ai/organization-settings/[organizationId]
PUT /api/ai/organization-settings/[organizationId]

// Response format management (exists)
GET /api/ai/response-schemas
POST /api/ai/response-schemas
GET /api/ai/response-schemas/[id]
PUT /api/ai/response-schemas/[id]
```

### Existing Components to Leverage
```typescript
// Current configuration components
components/ai/configuration/ServiceConfiguration.tsx
components/ai/configuration/ResponseFormatManager.tsx
components/ai/settings/ProviderConfiguration.tsx
components/ai/settings/ProcessingRules.tsx
components/ai/settings/QualityControls.tsx
components/ai/onboarding/SmartDefaultsWizard.tsx
```

### Database Schema (Available)
```sql
-- Organization-level AI settings
ai_organization_settings (
  organization_id, daily_cost_limit, monthly_cost_limit,
  auto_apply_threshold, suggestion_threshold,
  processing_rules, quality_controls, feature_flags
)

-- Response format templates
ai_response_schemas (
  id, name, schema_definition, category,
  organization_id, is_default, created_at
)

-- Configuration templates
ai_configuration_templates (
  id, name, description, industry, template_data,
  is_public, created_by, usage_count
)
```

## Detailed Component Specifications

### 1. Industry Preset Manager
```typescript
interface IndustryPresetManager {
  // Available presets
  presets: IndustryPreset[];
  
  // Preset operations
  operations: {
    applyPreset: (presetId: string, organizationId: string) => Promise<void>;
    customizePreset: (presetId: string) => PresetCustomization;
    createCustomPreset: (config: CustomPresetConfig) => Promise<IndustryPreset>;
    sharePreset: (presetId: string, sharing: SharingConfig) => Promise<void>;
  };
  
  // Preset comparison
  comparison: {
    comparePresets: (presetIds: string[]) => PresetComparison;
    showDifferences: (current: any, preset: IndustryPreset) => ConfigurationDiff;
  };
}

interface IndustryPreset {
  id: string;
  name: string;                    // "Manufacturing Safety", "Construction Compliance"
  description: string;
  industry: 'manufacturing' | 'construction' | 'oil_gas' | 'mining' | 'aerospace' | 'healthcare';
  
  // Configuration data
  configuration: {
    // AI processing settings
    processing: {
      confidenceThresholds: {
        autoApply: number;         // Auto-apply threshold
        suggest: number;           // Suggestion threshold
        minimum: number;           // Minimum confidence
      };
      costControls: {
        dailyLimit: number;
        monthlyLimit: number;
        alertThreshold: number;
      };
      qualitySettings: {
        accuracyTarget: number;
        consistencyTarget: number;
        responseTimeTarget: number;
      };
    };
    
    // Feature enablement
    features: {
      photoTagging: boolean;
      descriptions: boolean;
      safetyChat: boolean;
      enhancedSearch: boolean;
      batchProcessing: boolean;
    };
    
    // Industry-specific prompts
    prompts: {
      [category: string]: {
        promptId: string;
        customizations: any;
      };
    };
    
    // Model preferences
    models: {
      [feature: string]: {
        primary: string;           // Primary model ID
        fallback: string;          // Fallback model ID
        configuration: any;        // Model-specific settings
      };
    };
    
    // Compliance settings
    compliance: {
      standards: string[];         // ["OSHA", "ISO 45001", "ANSI"]
      requirements: ComplianceRequirement[];
      reporting: ReportingConfig;
    };
  };
  
  // Metadata
  metadata: {
    createdBy: string;
    createdAt: string;
    version: string;
    usageCount: number;
    rating: number;              // User rating
    tags: string[];
  };
}
```

### 2. Guided Setup Wizard
```typescript
interface GuidedSetupWizard {
  // Wizard steps
  steps: SetupStep[];
  currentStep: number;
  completedSteps: Set<number>;
  
  // Organization context
  organizationContext: {
    industry: string;
    size: 'small' | 'medium' | 'large' | 'enterprise';
    useCase: string[];           // Primary use cases
    expertise: 'beginner' | 'intermediate' | 'expert';
    compliance: string[];        // Required compliance standards
  };
  
  // Wizard state
  wizardState: {
    selections: { [stepId: string]: any };
    recommendations: Recommendation[];
    estimatedSetupTime: number;
    configurationPreview: any;
  };
  
  // Navigation
  navigation: {
    canGoNext: boolean;
    canGoPrevious: boolean;
    goToStep: (step: number) => void;
    complete: () => Promise<SetupResult>;
  };
}

interface SetupStep {
  id: string;
  title: string;
  description: string;
  type: 'selection' | 'configuration' | 'validation' | 'confirmation';
  
  // Step content
  content: {
    questions: SetupQuestion[];
    options: SetupOption[];
    validation: ValidationRule[];
  };
  
  // Step state
  state: {
    isCompleted: boolean;
    hasErrors: boolean;
    selectedOptions: any[];
    customValues: { [key: string]: any };
  };
  
  // Recommendations
  recommendations: {
    suggested: any[];            // Suggested selections
    reasoning: string[];         // Why these are suggested
    alternatives: any[];         // Alternative options
  };
}
```

### 3. Advanced Configuration Manager
```typescript
interface AdvancedConfigurationManager {
  // Configuration categories
  categories: {
    processing: ProcessingConfiguration;
    quality: QualityConfiguration;
    cost: CostConfiguration;
    security: SecurityConfiguration;
    compliance: ComplianceConfiguration;
    integration: IntegrationConfiguration;
  };
  
  // Configuration validation
  validation: {
    validateConfiguration: (config: any) => ValidationResult;
    detectConflicts: (config: any) => ConfigurationConflict[];
    suggestOptimizations: (config: any) => OptimizationSuggestion[];
  };
  
  // Configuration templates
  templates: {
    save: (name: string, config: any) => Promise<ConfigurationTemplate>;
    load: (templateId: string) => Promise<any>;
    share: (templateId: string, permissions: SharingPermissions) => Promise<void>;
  };
}

interface ProcessingConfiguration {
  // Batch processing settings
  batchProcessing: {
    enabled: boolean;
    batchSize: number;           // Photos per batch
    maxConcurrent: number;       // Concurrent batches
    priority: 'speed' | 'accuracy' | 'cost';
    retryPolicy: RetryPolicy;
  };
  
  // Queue management
  queueManagement: {
    maxQueueSize: number;
    priorityRules: PriorityRule[];
    processingSchedule: ProcessingSchedule;
    autoScaling: AutoScalingConfig;
  };
  
  // Error handling
  errorHandling: {
    maxRetries: number;
    retryDelay: number;          // Milliseconds
    fallbackBehavior: 'skip' | 'manual' | 'alternative_model';
    errorNotifications: NotificationConfig;
  };
}

interface QualityConfiguration {
  // Accuracy targets
  accuracyTargets: {
    overall: number;             // Overall accuracy target
    byFeature: { [feature: string]: number };
    byCategory: { [category: string]: number };
  };
  
  // Quality gates
  qualityGates: {
    preProcessing: QualityGate[];
    postProcessing: QualityGate[];
    periodic: QualityGate[];
  };
  
  // Feedback integration
  feedbackIntegration: {
    collectFeedback: boolean;
    autoLearn: boolean;
    feedbackWeight: number;      // How much to weight user corrections
    reviewThreshold: number;     // When to flag for human review
  };
}
```

### 4. Configuration Template System
```typescript
interface ConfigurationTemplateSystem {
  // Template management
  templates: ConfigurationTemplate[];
  
  // Template operations
  operations: {
    create: (config: TemplateConfig) => Promise<ConfigurationTemplate>;
    update: (templateId: string, updates: any) => Promise<ConfigurationTemplate>;
    clone: (templateId: string, newName: string) => Promise<ConfigurationTemplate>;
    delete: (templateId: string) => Promise<void>;
    export: (templateId: string) => Promise<string>;
    import: (templateData: string) => Promise<ConfigurationTemplate>;
  };
  
  // Template marketplace
  marketplace: {
    publicTemplates: PublicTemplate[];
    featuredTemplates: FeaturedTemplate[];
    downloadTemplate: (templateId: string) => Promise<ConfigurationTemplate>;
    publishTemplate: (templateId: string, metadata: PublicationMetadata) => Promise<void>;
    rateTemplate: (templateId: string, rating: number, review?: string) => Promise<void>;
  };
}

interface ConfigurationTemplate {
  id: string;
  name: string;
  description: string;
  category: 'industry' | 'use_case' | 'organization_size' | 'custom';
  
  // Template content
  configuration: {
    processing: any;
    quality: any;
    cost: any;
    security: any;
    compliance: any;
  };
  
  // Template metadata
  metadata: {
    author: string;
    version: string;
    compatibility: string[];     // Compatible system versions
    requirements: string[];      // Required features/models
    tags: string[];
    rating: number;
    downloadCount: number;
  };
  
  // Customization options
  customization: {
    parameters: TemplateParameter[];
    validation: ValidationRule[];
    presets: { [name: string]: any };
  };
}
```

### 5. Configuration Validation Engine
```typescript
interface ConfigurationValidationEngine {
  // Validation rules
  validationRules: ValidationRule[];
  
  // Validation execution
  validate: (configuration: any) => ValidationResult;
  
  // Conflict detection
  detectConflicts: (configuration: any) => ConfigurationConflict[];
  
  // Optimization suggestions
  optimize: (configuration: any) => OptimizationSuggestion[];
  
  // Health checks
  healthCheck: (configuration: any) => HealthCheckResult;
}

interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
  suggestions: ValidationSuggestion[];
  
  // Validation summary
  summary: {
    totalChecks: number;
    passed: number;
    failed: number;
    warnings: number;
    severity: 'low' | 'medium' | 'high' | 'critical';
  };
}

interface ConfigurationConflict {
  id: string;
  type: 'setting_conflict' | 'resource_conflict' | 'dependency_conflict';
  severity: 'low' | 'medium' | 'high' | 'critical';
  
  // Conflict details
  description: string;
  affectedSettings: string[];
  cause: string;
  
  // Resolution
  resolutions: ConflictResolution[];
  recommendedResolution: string;
  
  // Impact analysis
  impact: {
    features: string[];          // Affected features
    performance: string;         // Performance impact
    cost: string;               // Cost impact
    reliability: string;        // Reliability impact
  };
}
```

## UI/UX Specifications

### Layout Structure
```
┌─────────────────────────────────────────────────────────┐
│ Configuration Header: [Industry Presets] [Wizard] [Advanced] │
├─────────────────────────────────────────────────────────┤
│ Tab Navigation: [Presets] [Wizard] [Advanced] [Templates] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ INDUSTRY PRESETS TAB:                                   │
│ ┌─ Preset Categories ──────────────────────────────────┐│
│ │ [Manufacturing] [Construction] [Oil & Gas] [Mining]  ││
│ └─────────────────────────────────────────────────────┘│
│                                                         │
│ ┌─ Manufacturing Presets ──────────────────────────────┐│
│ │ ┌─ OSHA Compliance ─┐ ┌─ ISO 45001 ────┐ ┌─ Custom ┐││
│ │ │ ⚙️ 15 Settings    │ │ ⚙️ 22 Settings │ │ 🎨 Build ││
│ │ │ 🏭 Auto-tagging   │ │ 📋 Documentation│ │ Your Own ││
│ │ │ ⚡ Fast processing│ │ ⚖️ Compliance   │ │          ││
│ │ │ [Preview] [Apply] │ │ [Preview] [Apply]│ │ [Start]  ││
│ │ └─────────────────┘ └───────────────┘ └─────────┘││
│ └─────────────────────────────────────────────────────┘│
│                                                         │
│ SETUP WIZARD TAB:                                       │
│ ┌─ Progress: Step 2 of 5 ─────────────────────────────┐│
│ │ ●●○○○ Organization Setup                             ││
│ └─────────────────────────────────────────────────────┘│
│ ┌─ What's your primary industry? ──────────────────────┐│  
│ │ ○ Manufacturing        ○ Construction               ││
│ │ ○ Oil & Gas           ○ Mining                      ││
│ │ ○ Healthcare          ○ Other: ___________          ││
│ │                                                     ││
│ │ Based on your selection, we'll configure:           ││
│ │ • Safety tagging priorities                         ││
│ │ • Compliance requirements                          ││
│ │ • Industry-specific prompts                        ││
│ │                                                     ││
│ │ [Back] [Continue] [Skip Wizard]                     ││
│ └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### Key Interactions

#### 1. Industry Preset Application
- **Preview Mode**: Show what will change before applying preset
- **Customization**: Modify preset settings before application
- **Impact Analysis**: Show expected impact on performance and cost

#### 2. Guided Setup Flow
- **Smart Recommendations**: AI-powered suggestions based on inputs
- **Progress Tracking**: Clear indication of setup progress
- **Skip Options**: Allow advanced users to skip wizard steps

#### 3. Advanced Configuration
- **Visual Validation**: Real-time validation with clear error indicators
- **Conflict Resolution**: Guided resolution of configuration conflicts
- **Template Integration**: Easy save/load of configuration templates

## Implementation Guidelines

### File Structure
```
components/ai/management/configuration/
├── ConfigurationContainer.tsx        # Main configuration dashboard
├── IndustryPresets/
│   ├── IndustryPresetManager.tsx     # Industry preset management
│   ├── PresetBrowser.tsx             # Browse available presets
│   ├── PresetComparison.tsx          # Compare presets
│   ├── PresetCustomizer.tsx          # Customize presets
│   └── PresetMarketplace.tsx         # Community presets
├── SetupWizard/
│   ├── GuidedSetupWizard.tsx         # Main wizard component
│   ├── WizardStep.tsx                # Individual wizard step
│   ├── OrganizationSetup.tsx         # Organization configuration
│   ├── FeatureSelection.tsx          # Feature enablement
│   ├── ModelConfiguration.tsx        # Model selection
│   ├── QualitySettings.tsx           # Quality and accuracy settings
│   └── ReviewAndComplete.tsx         # Final review step
├── AdvancedConfiguration/
│   ├── AdvancedConfigManager.tsx     # Advanced settings
│   ├── ProcessingConfiguration.tsx   # Processing settings
│   ├── QualityConfiguration.tsx      # Quality management
│   ├── CostConfiguration.tsx         # Cost controls
│   ├── SecurityConfiguration.tsx     # Security settings
│   └── ComplianceConfiguration.tsx   # Compliance settings
├── Templates/
│   ├── ConfigurationTemplates.tsx    # Template management
│   ├── TemplateEditor.tsx            # Edit templates
│   ├── TemplateMarketplace.tsx       # Public template sharing
│   └── TemplateImportExport.tsx      # Import/export functionality
├── Validation/
│   ├── ConfigurationValidator.tsx    # Configuration validation
│   ├── ConflictDetector.tsx          # Detect conflicts
│   ├── OptimizationEngine.tsx        # Optimization suggestions
│   └── HealthChecker.tsx             # Configuration health
└── hooks/
    ├── useConfigurationValidation.tsx # Validation logic
    ├── useIndustryPresets.tsx         # Preset management
    ├── useSetupWizard.tsx            # Wizard state management
    └── useTemplateSystem.tsx         # Template operations
```

### Code Patterns

#### Configuration Validation
```typescript
const useConfigurationValidation = (configuration: any) => {
  const [validationResult, setValidationResult] = useState<ValidationResult | null>(null);
  const [isValidating, setIsValidating] = useState(false);
  
  const validate = useCallback(async (config: any) => {
    setIsValidating(true);
    try {
      const result = await validateConfiguration(config);
      setValidationResult(result);
      return result;
    } catch (error) {
      console.error('Validation failed:', error);
      return null;
    } finally {
      setIsValidating(false);
    }
  }, []);
  
  // Auto-validate when configuration changes
  useEffect(() => {
    if (configuration) {
      const debounced = debounce(() => validate(configuration), 500);
      debounced();
      return () => debounced.cancel();
    }
  }, [configuration, validate]);
  
  return { validationResult, isValidating, validate };
};
```

#### Industry Preset Management
```typescript
const useIndustryPresets = (organizationId: string) => {
  const [presets, setPresets] = useState<IndustryPreset[]>([]);
  const [loading, setLoading] = useState(true);
  
  const applyPreset = async (presetId: string, customizations?: any) => {
    try {
      const result = await applyIndustryPreset(organizationId, presetId, customizations);
      
      // Track preset application
      trackEvent('preset_applied', {
        presetId,
        organizationId,
        customizations: !!customizations
      });
      
      return result;
    } catch (error) {
      console.error('Failed to apply preset:', error);
      throw error;
    }
  };
  
  const comparePresets = (presetIds: string[]) => {
    const selectedPresets = presets.filter(p => presetIds.includes(p.id));
    return generatePresetComparison(selectedPresets);
  };
  
  return { presets, applyPreset, comparePresets, loading };
};
```

### Performance Requirements
- **Preset Application**: < 30 seconds to apply industry preset
- **Wizard Completion**: < 10 minutes for complete guided setup
- **Validation**: < 2 seconds for configuration validation
- **Template Operations**: < 5 seconds for save/load operations

## Testing Requirements

### Unit Tests
```typescript
describe('IndustryPresetManager', () => {
  it('applies industry presets correctly', () => {
    // Test preset application
  });
  
  it('validates preset customizations', () => {
    // Test customization validation
  });
  
  it('detects configuration conflicts', () => {
    // Test conflict detection
  });
});

describe('GuidedSetupWizard', () => {
  it('guides users through setup process', () => {
    // Test wizard flow
  });
  
  it('generates appropriate recommendations', () => {
    // Test recommendation engine
  });
});
```

### Integration Tests
```typescript
describe('Configuration Management Integration', () => {
  it('integrates with existing AI system', () => {
    // Test integration with AI components
  });
  
  it('preserves existing configurations', () => {
    // Test configuration migration
  });
  
  it('validates complete system configuration', () => {
    // Test end-to-end configuration validation
  });
});
```

## Delivery Requirements

### Files to Create
1. **ConfigurationContainer.tsx** - Main configuration management interface
2. **Industry Presets** - Complete preset system with customization
3. **Guided Setup Wizard** - Step-by-step organization setup
4. **Advanced Configuration** - Comprehensive settings management
5. **Template System** - Configuration template management

### Demo Scenarios
1. **Industry Preset Application**: Apply manufacturing safety preset to new organization
2. **Guided Setup**: Complete setup wizard for construction company
3. **Advanced Configuration**: Configure complex batch processing rules
4. **Template Creation**: Create and share custom configuration template
5. **Validation & Conflicts**: Demonstrate configuration validation and conflict resolution

### Handoff Requirements

#### To Agent 1 (Dashboard)
- Provide configuration status indicators
- Export setup progress tracking
- Share configuration health metrics

#### To Agent 2 (Prompts)
- Apply industry-specific prompt configurations
- Integrate prompt customization in presets
- Share template-based prompt management

#### To Agent 3 (Models)
- Apply model preferences from presets
- Integrate model configuration in wizard
- Share template-based model management

#### To Other Agents
- Provide configuration validation for all components
- Export industry-specific settings
- Share template system for reusable configurations

---

**Key Success Metric**: A new organization should be able to go from zero configuration to fully operational AI system in under 15 minutes using the guided setup wizard, with industry-appropriate settings that require minimal further customization.