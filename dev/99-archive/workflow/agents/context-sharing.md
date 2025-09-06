# Agent Context Sharing - Implementation Specification

## Overview

This document provides the technical specification for context sharing between agents in the enhanced Minerva workflow system. It defines data structures, sharing mechanisms, and implementation patterns that enable seamless agent coordination.

## Context Data Structures

### 1. Core Workflow Context
```typescript
interface WorkflowContext {
  // Workflow identification
  workflowId: string;
  featureName: string;
  featureDescription: string;
  
  // Current state
  phase: 'planning' | 'implementation' | 'review' | 'deployment';
  currentAgent?: string;
  startTime: string;
  lastUpdated: string;
  
  // References
  prdPath?: string;
  branchName?: string;
  
  // Progress tracking
  agentSequence: AgentExecution[];
  qualityGates: QualityGateStatus;
  
  // Shared context
  sharedDecisions: TechnicalDecision[];
  constraints: Constraint[];
  artifacts: ArtifactReference[];
}
```

### 2. Agent-Specific Context
```typescript
interface AgentContext {
  // Agent identification
  agentName: string;
  agentVersion: string;
  executionId: string;
  
  // Task context
  currentTask: TaskSpecification;
  expectedOutputs: string[];
  timeEstimate?: number;
  
  // Input context
  workflowContext: WorkflowContext;
  previousAgentOutputs: AgentOutput[];
  relevantArtifacts: ArtifactReference[];
  
  // Agent-specific data
  agentSpecificContext: Record<string, any>;
}
```

### 3. Agent Output Structure
```typescript
interface AgentOutput {
  // Execution metadata
  agentName: string;
  executionId: string;
  timestamp: string;
  duration: number;
  status: 'success' | 'warning' | 'error';
  
  // Core outputs
  keyFindings: Finding[];
  recommendations: Recommendation[];
  artifactsCreated: ArtifactReference[];
  nextSteps: string[];
  
  // Quality gates
  qualityGateUpdates: QualityGateUpdate[];
  
  // Context for next agents
  contextForNextAgent: Record<string, any>;
  
  // Agent-specific outputs
  agentSpecificOutputs: Record<string, any>;
}
```

### 4. Supporting Data Structures
```typescript
interface TechnicalDecision {
  id: string;
  decision: string;
  rationale: string;
  madeBy: string; // agent name
  timestamp: string;
  impact: 'low' | 'medium' | 'high';
  category: 'architecture' | 'technology' | 'pattern' | 'security' | 'performance';
  affectedComponents: string[];
}

interface Constraint {
  id: string;
  type: 'technical' | 'business' | 'regulatory' | 'performance' | 'security';
  description: string;
  impact: string;
  source: string; // PRD, architecture, etc.
  severity: 'info' | 'warning' | 'critical';
}

interface ArtifactReference {
  id: string;
  type: 'file' | 'directory' | 'documentation' | 'configuration';
  path: string;
  description: string;
  createdBy: string; // agent name
  lastModified: string;
  relevantTo: string[]; // agent names that might need this
}

interface QualityGateUpdate {
  gateName: string;
  newStatus: 'passed' | 'failed' | 'warning';
  evidence: string[];
  issues?: Issue[];
  recommendations?: string[];
}
```

## Context Sharing Mechanisms

### 1. Workflow State File (`.claude/workflow-state.json`)
**Primary storage** for all workflow context and agent outputs:

```json
{
  "version": "2.0",
  "workflowId": "wf_20250801_advanced_search",
  "featureName": "advanced-photo-search",
  "featureDescription": "AI-powered photo search with faceted navigation",
  "phase": "implementation",
  "currentAgent": "code-writer",
  "startTime": "2025-08-01T10:30:00Z",
  "lastUpdated": "2025-08-01T15:45:00Z",
  "prdPath": "dev/planning/feature-prds/advanced-photo-search-prd.md",
  "branchName": "feature/advanced-photo-search",
  
  "agentSequence": [
    {
      "agentName": "prd-writer",
      "executionId": "exec_001",
      "status": "completed",
      "startTime": "2025-08-01T10:30:00Z",
      "endTime": "2025-08-01T11:15:00Z",
      "outputs": {
        "keyFindings": ["8 user stories identified", "3 critical performance requirements"],
        "artifactsCreated": ["dev/planning/feature-prds/advanced-photo-search-prd.md"],
        "contextForNextAgent": {
          "requirements": [...],
          "successMetrics": [...],
          "constraints": [...]
        }
      }
    }
  ],
  
  "qualityGates": {
    "passed": ["requirements-complete"],
    "pending": ["architecture-reviewed", "implementation-complete"],
    "failed": []
  },
  
  "sharedDecisions": [
    {
      "id": "dec_001",
      "decision": "Use Supabase full-text search with pgvector for semantic search",
      "rationale": "Leverages existing infrastructure while providing AI-powered search capabilities",
      "madeBy": "architecture-reviewer",
      "timestamp": "2025-08-01T11:45:00Z",
      "impact": "high",
      "category": "architecture"
    }
  ],
  
  "constraints": [
    {
      "id": "con_001", 
      "type": "performance",
      "description": "Search results must return in <500ms",
      "impact": "Affects UI responsiveness and user experience",
      "source": "PRD performance requirements",
      "severity": "critical"
    }
  ],
  
  "artifacts": [
    {
      "id": "art_001",
      "type": "documentation",
      "path": "dev/planning/feature-prds/advanced-photo-search-prd.md",
      "description": "Complete PRD with requirements and acceptance criteria",
      "createdBy": "prd-writer",
      "relevantTo": ["architecture-reviewer", "code-writer", "testing-strategist"]
    }
  ]
}
```

### 2. Context Injection Pattern
Each command injects relevant context into agent prompts:

```typescript
// Context injection example for architecture-reviewer agent
function createAgentContext(agentName: string, workflowState: WorkflowContext): AgentContext {
  const relevantOutputs = workflowState.agentSequence
    .filter(agent => isRelevantToAgent(agent.agentName, agentName))
    .map(agent => agent.outputs);
  
  const relevantDecisions = workflowState.sharedDecisions
    .filter(decision => isRelevantToAgent(decision.category, agentName));
  
  const relevantConstraints = workflowState.constraints
    .filter(constraint => isRelevantToAgent(constraint.type, agentName));
  
  return {
    agentName,
    agentVersion: getAgentVersion(agentName),
    executionId: generateExecutionId(),
    currentTask: getTaskForAgent(agentName, workflowState),
    workflowContext: workflowState,
    previousAgentOutputs: relevantOutputs,
    relevantConstraints,
    relevantDecisions,
    agentSpecificContext: getAgentSpecificContext(agentName, workflowState)
  };
}
```

### 3. Context Relevance Mapping
```typescript
const CONTEXT_RELEVANCE_MAP = {
  'architecture-reviewer': {
    needsFrom: ['prd-writer'],
    provides: ['technical-decisions', 'architecture-patterns', 'performance-targets'],
    constraintTypes: ['technical', 'performance', 'security'],
    artifactTypes: ['documentation', 'configuration']
  },
  
  'api-designer': {
    needsFrom: ['prd-writer', 'architecture-reviewer'],
    provides: ['api-specifications', 'data-models', 'authentication-requirements'],
    constraintTypes: ['technical', 'security', 'performance'],
    artifactTypes: ['documentation', 'configuration']
  },
  
  'code-writer': {
    needsFrom: ['prd-writer', 'architecture-reviewer', 'api-designer', 'database-architect'],
    provides: ['implementation', 'test-code', 'documentation'],
    constraintTypes: ['technical', 'business', 'performance'],
    artifactTypes: ['file', 'directory']
  },
  
  'quality-assurance-specialist': {
    needsFrom: ['prd-writer', 'code-writer', 'testing-strategist'],
    provides: ['quality-assessment', 'improvement-recommendations'],
    constraintTypes: ['business', 'technical'],
    artifactTypes: ['file', 'documentation']
  }
};
```

## Agent-Specific Context Patterns

### 1. Planning Phase Context

#### prd-writer Context
```typescript
interface PRDWriterContext extends AgentContext {
  agentSpecificContext: {
    businessRequirements: string[];
    userPersonas: UserPersona[];
    existingFeatures: FeatureReference[];
    technicalStack: TechnologyStack;
  };
}
```

#### architecture-reviewer Context  
```typescript
interface ArchitectureReviewerContext extends AgentContext {
  agentSpecificContext: {
    prdRequirements: Requirement[];
    existingArchitecture: ArchitectureOverview;
    performanceTargets: PerformanceTarget[];
    integrationPoints: IntegrationPoint[];
  };
}
```

### 2. Implementation Phase Context

#### api-designer Context
```typescript
interface APIDesignerContext extends AgentContext {
  agentSpecificContext: {
    architectureDecisions: TechnicalDecision[];
    existingAPIPatterns: APIPattern[];
    authenticationRequirements: AuthRequirement[];
    performanceRequirements: PerformanceRequirement[];
  };
}
```

#### code-writer Context
```typescript
interface CodeWriterContext extends AgentContext {
  agentSpecificContext: {
    requirements: Requirement[];
    architectureDecisions: TechnicalDecision[];
    apiSpecifications: APISpecification[];
    databaseSchema: SchemaDefinition[];
    existingCodePatterns: CodePattern[];
    testingRequirements: TestRequirement[];
  };
}
```

### 3. Quality Assurance Phase Context

#### security-auditor Context
```typescript
interface SecurityAuditorContext extends AgentContext {
  agentSpecificContext: {
    implementationFiles: FileReference[];
    apiEndpoints: APIEndpoint[];
    databaseSchema: SchemaDefinition[];
    authenticationFlow: AuthFlow[];
    securityRequirements: SecurityRequirement[];
  };
}
```

#### performance-optimizer Context
```typescript
interface PerformanceOptimizerContext extends AgentContext {
  agentSpecificContext: {
    performanceTargets: PerformanceTarget[];
    implementationFiles: FileReference[];
    databaseQueries: QueryAnalysis[];
    apiEndpoints: APIEndpoint[];
    existingPerformanceBaseline: PerformanceBaseline;
  };
}
```

## Context Update Mechanisms

### 1. Immediate Context Updates
```typescript
function updateWorkflowContext(
  agentName: string, 
  agentOutput: AgentOutput, 
  workflowState: WorkflowContext
): WorkflowContext {
  // Update agent sequence
  const agentExecution: AgentExecution = {
    agentName,
    executionId: agentOutput.executionId,
    status: 'completed',
    startTime: agentOutput.timestamp,
    endTime: new Date().toISOString(),
    outputs: agentOutput
  };
  
  workflowState.agentSequence.push(agentExecution);
  
  // Update shared decisions
  if (agentOutput.contextForNextAgent.technicalDecisions) {
    workflowState.sharedDecisions.push(...agentOutput.contextForNextAgent.technicalDecisions);
  }
  
  // Update quality gates
  agentOutput.qualityGateUpdates.forEach(update => {
    updateQualityGate(workflowState.qualityGates, update);
  });
  
  // Update artifacts
  workflowState.artifacts.push(...agentOutput.artifactsCreated);
  
  // Update timestamp
  workflowState.lastUpdated = new Date().toISOString();
  
  return workflowState;
}
```

### 2. Context Validation
```typescript
function validateContext(context: AgentContext): ValidationResult {
  const validation: ValidationResult = {
    isValid: true,
    warnings: [],
    errors: []
  };
  
  // Check required context presence
  if (!context.workflowContext.prdPath) {
    validation.warnings.push('No PRD reference found');
  }
  
  // Check context freshness
  const lastUpdate = new Date(context.workflowContext.lastUpdated);
  const now = new Date();
  if (now.getTime() - lastUpdate.getTime() > 24 * 60 * 60 * 1000) {
    validation.warnings.push('Workflow context is more than 24 hours old');
  }
  
  // Check agent-specific requirements
  const requirements = CONTEXT_RELEVANCE_MAP[context.agentName];
  if (requirements) {
    requirements.needsFrom.forEach(requiredAgent => {
      const hasOutput = context.previousAgentOutputs.some(
        output => output.agentName === requiredAgent
      );
      if (!hasOutput) {
        validation.errors.push(`Missing required context from ${requiredAgent}`);
        validation.isValid = false;
      }
    });
  }
  
  return validation;
}
```

### 3. Context Cleanup and Archival
```typescript
function archiveWorkflowContext(workflowState: WorkflowContext): void {
  // Move to archive directory
  const archivePath = `dev/workflow/archive/${workflowState.workflowId}.json`;
  
  // Create summary for future reference
  const summary: WorkflowSummary = {
    workflowId: workflowState.workflowId,
    featureName: workflowState.featureName,
    duration: calculateDuration(workflowState.startTime, workflowState.lastUpdated),
    agentsUsed: workflowState.agentSequence.map(a => a.agentName),
    finalStatus: determineWorkflowStatus(workflowState),
    keyDecisions: workflowState.sharedDecisions.filter(d => d.impact === 'high'),
    lessonsLearned: extractLessonsLearned(workflowState)
  };
  
  // Save archive and summary
  saveToFile(archivePath, workflowState);
  saveToFile(`dev/workflow/summaries/${workflowState.workflowId}-summary.json`, summary);
  
  // Clean up active workflow state
  removeFile('.claude/workflow-state.json');
}
```

## Context Security and Privacy

### 1. Sensitive Data Handling
```typescript
interface SensitiveDataPolicy {
  encryptionRequired: boolean;
  accessControl: string[];
  retentionPeriod: number; // days
  anonymizationRules: AnonymizationRule[];
}

const CONTEXT_SECURITY_POLICIES = {
  'security-auditor': {
    encryptionRequired: true,
    accessControl: ['security-auditor', 'production-readiness-auditor'],
    retentionPeriod: 90,
    anonymizationRules: [
      { field: 'apiKeys', action: 'redact' },
      { field: 'passwords', action: 'remove' }
    ]
  }
};
```

### 2. Context Access Control
```typescript
function hasContextAccess(agentName: string, contextType: string): boolean {
  const policy = CONTEXT_SECURITY_POLICIES[contextType];
  if (!policy) return true; // No specific policy, allow access
  
  return policy.accessControl.includes(agentName);
}
```

## Performance Optimization

### 1. Context Size Management
```typescript
function optimizeContextSize(context: AgentContext): AgentContext {
  // Remove irrelevant outputs older than 24 hours
  context.previousAgentOutputs = context.previousAgentOutputs.filter(output => {
    const outputAge = Date.now() - new Date(output.timestamp).getTime();
    const isRelevant = CONTEXT_RELEVANCE_MAP[context.agentName]?.needsFrom.includes(output.agentName);
    return isRelevant || outputAge < 24 * 60 * 60 * 1000;
  });
  
  // Compress large artifacts
  context.relevantArtifacts = context.relevantArtifacts.map(artifact => {
    if (artifact.type === 'file' && artifact.path.endsWith('.json')) {
      return compressArtifact(artifact);
    }
    return artifact;
  });
  
  return context;
}
```

### 2. Context Caching
```typescript
const contextCache = new Map<string, AgentContext>();

function getCachedContext(agentName: string, workflowId: string): AgentContext | null {
  const cacheKey = `${workflowId}_${agentName}`;
  const cached = contextCache.get(cacheKey);
  
  if (cached && isCacheValid(cached)) {
    return cached;
  }
  
  return null;
}
```

## Error Handling and Recovery

### 1. Context Corruption Recovery
```typescript
function recoverCorruptedContext(workflowId: string): WorkflowContext {
  try {
    // Attempt to load from backup
    const backup = loadBackupContext(workflowId);
    if (backup) return backup;
    
    // Reconstruct from agent outputs
    return reconstructFromArtifacts(workflowId);
  } catch (error) {
    // Create minimal context for continuation
    return createMinimalContext(workflowId);
  }
}
```

### 2. Missing Context Handling
```typescript
function handleMissingContext(agentName: string, missingContext: string[]): AgentContext {
  const degradedContext = createDegradedContext(agentName);
  
  // Add warnings about missing context
  degradedContext.warnings = missingContext.map(missing => 
    `Missing context: ${missing}. Agent will operate with reduced capabilities.`
  );
  
  return degradedContext;
}
```

## Testing and Validation

### 1. Context Testing Framework
```typescript
describe('Context Sharing', () => {
  it('should pass complete context between agents', () => {
    const prdOutput = mockPRDWriterOutput();
    const archContext = createArchitectureReviewerContext(prdOutput);
    
    expect(archContext.agentSpecificContext.prdRequirements).toBeDefined();
    expect(archContext.previousAgentOutputs).toHaveLength(1);
  });
  
  it('should validate context integrity', () => {
    const context = createMockContext();
    const validation = validateContext(context);
    
    expect(validation.isValid).toBe(true);
    expect(validation.errors).toHaveLength(0);
  });
});
```

### 2. Context Integration Tests
```bash
# Test full context flow
npm run test:context-flow

# Test context validation  
npm run test:context-validation

# Test context performance
npm run test:context-performance
```

This context sharing specification enables seamless agent coordination while maintaining performance, security, and reliability standards required for production use in the Minerva workflow system.