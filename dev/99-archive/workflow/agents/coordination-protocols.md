# Agent Coordination Protocols - Enhanced Workflow System

## Overview

This document defines the protocols and mechanisms that enable seamless coordination between the 16 specialized agents in the Minerva workflow system. These protocols ensure agents work together effectively, share context appropriately, and deliver consistent, high-quality results.

## Core Coordination Principles

### 1. Context Continuity
Every agent receives relevant context from previous agents in the workflow, enabling informed decisions and reducing duplicate work.

### 2. Structured Communication
Agents communicate through standardized data structures that preserve essential information and enable automated processing.

### 3. Quality Gate Compliance
Each agent validates and updates quality gates, ensuring systematic progress toward deployment readiness.

### 4. Conflict Resolution
When agents provide conflicting recommendations, established resolution protocols determine the optimal path forward.

## Agent Coordination Architecture

### Workflow State as Central Hub
```json
{
  "workflowState": {
    "currentFeature": "advanced-photo-search",
    "phase": "implementation|review|deployment",
    "agentSequence": [
      {"agent": "prd-writer", "status": "completed", "timestamp": "2025-08-01T10:30:00Z"},
      {"agent": "architecture-reviewer", "status": "in_progress", "timestamp": "2025-08-01T11:15:00Z"}
    ],
    "sharedContext": {
      "technicalDecisions": [],
      "qualityRequirements": [],
      "constraints": [],
      "artifacts": []
    },
    "qualityGates": {
      "passed": [],
      "pending": [],
      "failed": []
    }
  }
}
```

### Agent Communication Protocol
```typescript
interface AgentContext {
  workflowId: string;
  featureName: string;
  phase: 'planning' | 'implementation' | 'review' | 'deployment';
  prdReference?: string;
  previousAgentOutputs: AgentOutput[];
  currentTask: TaskSpecification;
  sharedDecisions: TechnicalDecision[];
  qualityRequirements: QualityRequirement[];
  constraints: Constraint[];
}

interface AgentOutput {
  agentName: string;
  phase: string;
  timestamp: string;
  keyFindings: string[];
  recommendations: Recommendation[];
  artifactsCreated: string[];
  nextSteps: string[];
  qualityGateUpdates: QualityGateUpdate[];
  contextForNextAgent: Record<string, any>;
}
```

## Agent-Specific Coordination Roles

### 1. Planning Phase Agents

#### prd-writer (Workflow Initiator)
**Role:** Establishes foundation context for all subsequent agents
**Coordination Responsibilities:**
- Initialize workflow state with feature requirements
- Define quality gates and success criteria
- Create structured context for implementation agents
- Establish technical constraints and business requirements

**Output Format:**
```json
{
  "contextForNextAgent": {
    "requirements": ["User stories with acceptance criteria"],
    "successMetrics": ["Measurable KPIs"],
    "technicalConstraints": ["Technology and architecture limitations"],
    "businessContext": ["User personas and use cases"]
  },
  "qualityGateUpdates": [
    {"gate": "requirements-complete", "status": "passed", "evidence": ["PRD document created", "Stakeholder review completed"]}
  ]
}
```

#### architecture-reviewer (Technical Foundation)
**Role:** Validates technical approach and establishes implementation guidelines
**Coordination Responsibilities:**
- Receive and validate PRD technical requirements
- Provide technical decisions for implementation agents
- Identify integration points with existing system
- Establish performance and scalability guidelines

**Context Reception:**
```json
{
  "receivedContext": {
    "prdRequirements": "from prd-writer",
    "businessConstraints": "from prd-writer",
    "existingSystemContext": "from workflow state"
  }
}
```

**Output Format:**
```json
{
  "contextForNextAgent": {
    "technicalDecisions": ["Architecture patterns to follow", "Technology choices"],
    "integrationPoints": ["Existing system touchpoints"],
    "performanceTargets": ["Response time", "throughput", "scalability requirements"],
    "implementationGuidance": ["Code organization", "design patterns"]
  }
}
```

### 2. Implementation Phase Agents

#### api-designer (Interface Definition)
**Role:** Defines API contracts and data models
**Coordination Responsibilities:**
- Receive architecture decisions and requirements
- Design APIs that align with existing system patterns
- Provide schema definitions for database-architect
- Create interface contracts for code-writer

**Coordination Pattern:**
```typescript
// Receives context from architecture-reviewer
const apiDesignContext = {
  architecturalDecisions: previousAgent.technicalDecisions,
  integrationRequirements: previousAgent.integrationPoints,
  performanceTargets: previousAgent.performanceTargets
};

// Provides context to database-architect and code-writer
const apiDesignOutput = {
  apiSpecifications: [...],
  dataModels: [...],
  authenticationRequirements: [...],
  performanceConsiderations: [...]
};
```

#### database-architect (Data Layer Design)
**Role:** Designs database schema and migration strategy
**Coordination Responsibilities:**
- Receive API data model requirements
- Design schemas compatible with existing database
- Provide migration strategy for devops-engineer
- Ensure performance alignment with architecture decisions

**Context Integration:**
```json
{
  "inputContext": {
    "dataModels": "from api-designer",
    "performanceTargets": "from architecture-reviewer", 
    "existingSchema": "from workflow state"
  },
  "outputContext": {
    "schemaChanges": "for code-writer",
    "migrationStrategy": "for devops-engineer",
    "performanceOptimizations": "for performance-optimizer"
  }
}
```

#### code-writer (Implementation)
**Role:** Implements features based on all previous agent decisions
**Coordination Responsibilities:**
- Integrate all previous agent outputs into implementation
- Follow established patterns and technical decisions
- Implement according to API specifications and database designs
- Create implementation that satisfies PRD requirements

**Comprehensive Context Reception:**
```json
{
  "implementationContext": {
    "requirements": "from prd-writer",
    "architectureDecisions": "from architecture-reviewer",
    "apiSpecifications": "from api-designer", 
    "databaseSchema": "from database-architect",
    "existingCodePatterns": "from workflow state"
  }
}
```

### 3. Quality Assurance Phase Agents

#### testing-strategist (Test Planning)
**Role:** Creates comprehensive test strategy based on implementation
**Coordination Responsibilities:**
- Analyze implementation for test requirements
- Design tests that validate PRD acceptance criteria
- Coordinate with quality-assurance-specialist on test execution
- Provide test requirements for code-writer if needed

#### quality-assurance-specialist (Quality Validation)
**Role:** Validates implementation quality against all previous requirements
**Coordination Responsibilities:**
- Validate implementation against PRD requirements
- Check compliance with architecture decisions
- Verify API implementation matches specifications
- Confirm database implementation follows schema design

**Validation Context:**
```json
{
  "validationCriteria": {
    "prdRequirements": "from prd-writer",
    "architectureCompliance": "from architecture-reviewer",
    "apiCompliance": "from api-designer",
    "databaseCompliance": "from database-architect",
    "implementationQuality": "from code analysis"
  }
}
```

#### security-auditor (Security Validation)
**Role:** Validates security aspects across all implementation layers
**Coordination Responsibilities:**
- Review API security implementation
- Validate database security (RLS policies, encryption)
- Ensure authentication/authorization compliance
- Coordinate with production-readiness-auditor on security deployment

#### performance-optimizer (Performance Validation)
**Role:** Validates performance against established targets
**Coordination Responsibilities:**
- Validate against performance targets from architecture-reviewer
- Analyze implementation efficiency from code-writer
- Validate database query performance from database-architect
- Provide optimization recommendations for final implementation

### 4. Deployment Phase Agents

#### production-readiness-auditor (Deployment Readiness)
**Role:** Final validation that all agent requirements are met
**Coordination Responsibilities:**
- Validate all quality gates have been satisfied
- Check that all agent recommendations have been addressed
- Ensure deployment safety based on all previous agent analysis
- Coordinate final deployment decision

**Comprehensive Validation:**
```json
{
  "deploymentReadiness": {
    "requirementsSatisfied": "validated against prd-writer output",
    "architectureCompliant": "validated against architecture-reviewer decisions",
    "qualityStandards": "validated against quality-assurance-specialist results",
    "securityApproved": "validated against security-auditor findings",
    "performanceValidated": "validated against performance-optimizer analysis"
  }
}
```

## Conflict Resolution Protocols

### 1. Priority-Based Resolution
When agents provide conflicting recommendations, resolution follows priority order:

1. **Security concerns** (security-auditor) - Always highest priority
2. **Performance targets** (performance-optimizer) - Must meet PRD requirements  
3. **Architecture compliance** (architecture-reviewer) - Maintain system integrity
4. **Quality standards** (quality-assurance-specialist) - Ensure maintainability
5. **Implementation preferences** (code-writer) - Lowest priority for conflicts

### 2. Context-Aware Resolution
```typescript
interface ConflictResolution {
  conflictingRecommendations: Recommendation[];
  resolutionStrategy: 'priority-based' | 'compromise' | 'sequential' | 'escalation';
  resolvedRecommendation: Recommendation;
  justification: string;
  impactAssessment: string;
}
```

### 3. Escalation Procedures
- **Technical conflicts** - Escalate to architecture-reviewer for final decision
- **Security conflicts** - Escalate to security-auditor with no override
- **Business conflicts** - Reference PRD requirements from prd-writer
- **Performance conflicts** - Reference performance targets from architecture-reviewer

## Quality Gate Coordination

### Gate Ownership and Validation
```json
{
  "qualityGates": {
    "requirements-complete": {
      "owner": "prd-writer",
      "validators": ["architecture-reviewer", "testing-strategist"],
      "criteria": ["All user stories defined", "Acceptance criteria clear"]
    },
    "architecture-reviewed": {
      "owner": "architecture-reviewer", 
      "validators": ["performance-optimizer", "security-auditor"],
      "criteria": ["Technical approach validated", "Performance targets defined"]
    },
    "implementation-complete": {
      "owner": "code-writer",
      "validators": ["quality-assurance-specialist", "testing-strategist"],
      "criteria": ["All features implemented", "Tests written and passing"]
    },
    "quality-validated": {
      "owner": "quality-assurance-specialist",
      "validators": ["typescript-safety-validator", "ui-ux-reviewer"],
      "criteria": ["Code quality standards met", "No critical issues"]
    },
    "security-approved": {
      "owner": "security-auditor",
      "validators": ["production-readiness-auditor"],
      "criteria": ["No security vulnerabilities", "Compliance verified"]
    },
    "production-ready": {
      "owner": "production-readiness-auditor",
      "validators": ["devops-engineer"],
      "criteria": ["All gates passed", "Deployment validated"]
    }
  }
}
```

### Gate Progression Rules
1. **Sequential dependency** - Later gates require earlier gates to pass
2. **Multiple validation** - Critical gates require validation from multiple agents
3. **Override protection** - Security and critical quality gates cannot be overridden
4. **Audit trail** - All gate changes logged with justification

## Agent Orchestration Patterns

### 1. Sequential Pattern (Standard Feature Development)
```
prd-writer → architecture-reviewer → api-designer → database-architect → 
code-writer → testing-strategist → quality-assurance-specialist → 
security-auditor → performance-optimizer → production-readiness-auditor
```

### 2. Parallel Pattern (Independent Analysis)
```
After code-writer completion:
├── quality-assurance-specialist
├── security-auditor  
├── performance-optimizer
├── typescript-safety-validator
└── ui-ux-reviewer
    ↓
production-readiness-auditor (consolidates all results)
```

### 3. Iterative Pattern (Complex Features)
```
prd-writer → architecture-reviewer → [implementation cycle] → 
[quality cycle] → [refinement cycle] → production-readiness-auditor

Where each cycle involves multiple agents and feedback loops
```

## Context Sharing Best Practices

### 1. Information Relevance
Agents receive only context relevant to their responsibilities:
- **Technical agents** receive technical decisions and constraints
- **Quality agents** receive quality requirements and standards
- **Security agents** receive security requirements and compliance needs

### 2. Context Freshness
Context is updated in real-time:
- **Immediate updates** when agent completes work
- **Version tracking** to prevent stale context usage
- **Conflict detection** when context changes affect ongoing work

### 3. Context Validation
Context integrity is maintained:
- **Schema validation** ensures context structure consistency  
- **Semantic validation** ensures context makes sense
- **Completeness validation** ensures required context is present

## Monitoring and Improvement

### Coordination Metrics
```json
{
  "coordinationMetrics": {
    "contextPassingEfficiency": "95%", 
    "conflictResolutionTime": "avg 15 minutes",
    "qualityGatePassRate": "91%",
    "agentConsensusRate": "87%",
    "reworkRate": "8%"
  }
}
```

### Continuous Improvement
- **Agent performance tracking** - Identify agents that frequently conflict
- **Context optimization** - Refine context structure based on usage patterns
- **Conflict pattern analysis** - Identify and address recurring conflicts
- **Workflow optimization** - Adjust agent sequences for better efficiency

## Implementation Guidelines

### For Command Developers
1. **Always load workflow state** before engaging agents
2. **Pass complete context** to each agent based on their role
3. **Update workflow state** after each agent completes
4. **Validate quality gates** before proceeding to next phase
5. **Handle conflicts systematically** using established protocols

### For Agent Developers  
1. **Expect structured context** - Design agents to consume standardized context
2. **Provide structured output** - Follow output format specifications
3. **Update quality gates** - Explicitly pass/fail gates within agent responsibility
4. **Consider downstream agents** - Provide context needed by subsequent agents
5. **Handle missing context gracefully** - Degrade functionality rather than fail

This coordination protocol transforms individual specialized agents into a cohesive, intelligent development team that consistently delivers high-quality results while maintaining efficiency and reliability.