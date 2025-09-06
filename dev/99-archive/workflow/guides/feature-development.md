# Feature Development Guide - Enhanced Workflow

## Overview

This guide walks through the complete feature development process using the enhanced Claude Code workflow system. The process is designed to accelerate development while maintaining Minerva's high quality and security standards.

## Complete Feature Development Flow

### Phase 1: Requirements & Planning

#### Step 1: Create Comprehensive PRD
```bash
/prd advanced photo search with AI-powered filtering and faceted navigation
```

**What happens:**
- **prd-writer agent** creates comprehensive PRD document
- **architecture-reviewer agent** assesses technical feasibility
- **api-designer agent** plans API endpoints if needed
- **database-architect agent** evaluates database changes
- **Workflow state initialized** with feature context
- **Development todo list created** with structured tasks

**Expected outputs:**
- `dev/planning/feature-prds/advanced-photo-search-prd.md` - Complete PRD
- `dev/planning/feature-prds/advanced-photo-search-implementation.md` - Technical plan
- `.claude/workflow-state.json` - Workflow context initialized
- Structured todo list with implementation tasks

**Quality gates established:**
- ✅ `requirements-complete` - All user stories and acceptance criteria defined
- ⏳ `architecture-reviewed` - Technical approach needs validation
- ⏳ `implementation-complete` - Code implementation pending
- ⏳ `quality-validated` - QA validation pending
- ⏳ `security-approved` - Security review pending
- ⏳ `production-ready` - Deployment readiness pending

#### Step 2: Review PRD and Setup Development Environment
```bash
# Optional: Review PRD before implementation
git checkout -b feature/advanced-photo-search
npm run dev:safe  # Start development server
```

### Phase 2: Implementation

#### Step 3: Implement Feature End-to-End
```bash
/feature advanced photo search with AI-powered filtering and faceted navigation
```

**Enhanced workflow with context passing:**

1. **Architecture Review** - `architecture-reviewer` agent:
   - **Receives:** PRD requirements, technical constraints, existing system context
   - **Analyzes:** Integration points, performance impact, scalability considerations
   - **Outputs:** Technical decisions, architecture patterns, implementation guidance
   - **Updates:** Workflow state with architecture decisions

2. **API Design** - `api-designer` agent:
   - **Receives:** Architecture decisions, PRD requirements, existing API patterns
   - **Designs:** REST endpoints, request/response schemas, authentication requirements
   - **Outputs:** OpenAPI specifications, endpoint documentation
   - **Updates:** Workflow state with API design decisions

3. **Database Design** - `database-architect` agent:
   - **Receives:** API requirements, PRD data needs, existing schema context
   - **Designs:** Schema changes, indexing strategy, migration plan
   - **Outputs:** Migration files, schema documentation, performance considerations
   - **Updates:** Workflow state with database decisions

4. **Implementation** - `code-writer` agent:
   - **Receives:** All previous agent outputs, technical decisions, PRD requirements
   - **Implements:** Complete feature following established patterns
   - **Outputs:** React components, API routes, database queries, error handling
   - **Updates:** Workflow state with implementation status

5. **Testing Strategy** - `testing-strategist` agent:
   - **Receives:** Implementation details, PRD acceptance criteria, existing test patterns
   - **Designs:** Test plan, edge cases, integration scenarios
   - **Outputs:** Test specifications, test data requirements, coverage targets
   - **Updates:** Workflow state with testing plan

6. **Quality Assurance** - Multiple agents in parallel:
   - **typescript-safety-validator:** Type safety validation
   - **ui-ux-reviewer:** User experience and accessibility review
   - **security-auditor:** Security vulnerability assessment
   - **performance-optimizer:** Performance impact analysis

7. **Documentation** - `documentation-writer` agent:
   - **Receives:** All implementation details, API specifications, usage patterns
   - **Creates:** API docs, user guides, setup instructions
   - **Updates:** Existing documentation with new feature information

8. **Production Readiness** - `production-readiness-auditor` agent:
   - **Receives:** Complete feature context, all agent outputs, PRD criteria
   - **Validates:** Deployment readiness, monitoring setup, rollback procedures
   - **Creates:** Deployment checklist, monitoring configuration

**Quality gates updated:**
- ✅ `requirements-complete` - Already passed from PRD phase
- ✅ `architecture-reviewed` - Technical approach validated and documented
- ✅ `implementation-complete` - All features implemented with proper testing
- ⏳ `quality-validated` - Needs comprehensive quality review
- ⏳ `security-approved` - Needs security validation
- ⏳ `production-ready` - Needs final deployment readiness check

### Phase 3: Quality Validation

#### Step 4: Comprehensive Code Review
```bash
/review
```

**Enhanced review with workflow context:**

1. **Validation Scripts Execution:**
   ```bash
   npm run validate:all          # Full validation suite
   npm run lint                  # ESLint code quality
   npm run format:check          # Prettier formatting
   npm run test:ci               # Unit tests with coverage
   npm run test:e2e              # End-to-end tests
   npm run build                 # Production build validation
   ```

2. **Context-Aware Agent Analysis:**
   - **typescript-safety-validator:** Analyzes build output against PRD type safety requirements
   - **quality-assurance-specialist:** Reviews test results against PRD acceptance criteria
   - **testing-strategist:** Validates test coverage meets PRD requirements
   - **security-auditor:** Reviews for vulnerabilities with feature context
   - **performance-optimizer:** Analyzes performance impact against PRD targets
   - **todo-placeholder-detector:** Scans for incomplete work

3. **Quality Gate Validation:**
   - **Automated assessment** of each quality gate based on script results
   - **Context-aware recommendations** tied to specific PRD requirements
   - **Prioritized action plan** with specific fixes and improvements

**Quality gates updated:**
- ✅ `implementation-complete` - Confirmed through successful builds and tests
- ✅ `quality-validated` - Code quality standards met
- ✅ `security-approved` - No security vulnerabilities identified
- ⏳ `production-ready` - Final deployment check pending

#### Step 5: Address Review Findings (if any)
```bash
# Fix any issues identified in review
# Re-run review to validate fixes
/review --quick  # Fast validation of fixes
```

### Phase 4: Deployment

#### Step 6: Pre-Deployment Validation
```bash
/deploy --check-only
```

**Enhanced deployment validation:**

1. **Workflow State Validation:**
   - All quality gates must be passed
   - PRD acceptance criteria validated
   - Agent consensus on deployment readiness

2. **Production Readiness Assessment:**
   - **production-readiness-auditor** performs final validation
   - Deployment checklist completion verified
   - Rollback procedures validated
   - Monitoring and alerting configured

3. **Risk Assessment:**
   - Database migration impact analysis
   - Performance impact on existing features
   - User experience impact assessment
   - Rollback trigger configuration

**Final quality gate:**
- ✅ `production-ready` - All criteria met, ready for deployment

#### Step 7: Production Deployment
```bash
/deploy
```

**Safe deployment process:**
1. **Pre-deployment backup** of current state
2. **Database migrations** executed with validation
3. **Application deployment** with health checks
4. **Post-deployment validation** of core functionality
5. **Monitoring activation** for new feature metrics
6. **Rollback triggers** configured for automatic safety

### Phase 5: Post-Deployment

#### Step 8: Workflow Completion
```bash
# Workflow state automatically updated to "deployed"
# Metrics collected for efficiency analysis
# Documentation updated with deployment information
```

**Workflow completion activities:**
- Workflow state archived with completion metrics
- Feature branch merged and cleaned up
- Documentation updated with final feature information
- Success metrics tracked for continuous improvement

## Advanced Workflow Patterns

### Pattern 1: Iterative Development
```bash
# For large features, use iterative approach
/prd advanced search - phase 1 basic functionality
/feature advanced search - phase 1 basic functionality
/review && /deploy --staging

/prd advanced search - phase 2 AI enhancement  
/feature advanced search - phase 2 AI enhancement
/review && /deploy
```

### Pattern 2: API-First Development
```bash
# Focus on API design first
/prd mobile app REST API endpoints
/api mobile app REST API endpoints  # Use specialized API command
/review --api-focus
/deploy --api-only
```

### Pattern 3: Performance-Critical Features
```bash
# Extra focus on performance
/prd high-performance photo processing
/feature high-performance photo processing
/debug --performance  # Specialized performance analysis
/review --performance-focus
/deploy --performance-monitoring
```

## Quality Assurance Integration

### Automated Quality Gates
- **Requirements Traceability:** Every implementation task traces back to PRD requirement
- **Test Coverage Enforcement:** Minimum coverage thresholds based on PRD criticality
- **Performance Validation:** Automated performance testing against PRD targets
- **Security Compliance:** Mandatory security review for all data-handling features

### Manual Review Points
- **PRD Review:** Stakeholder review of requirements before implementation
- **Architecture Review:** Senior developer review of technical approach
- **UX Review:** Design team review of user interface changes
- **Security Review:** Security team review of sensitive features

## Troubleshooting Common Issues

### Workflow State Issues
```bash
# Check current workflow state
cat .claude/workflow-state.json

# Reset workflow state if corrupted
rm .claude/workflow-state.json
/prd [feature-name]  # Restart workflow
```

### Quality Gate Failures
```bash
# Identify failed gates
/review --gates-only

# Address specific gate failure
/debug [specific-issue]

# Re-validate gates
/review --validate-gates
```

### Agent Coordination Issues
```bash
# Check agent outputs and coordination
cat .claude/workflow-state.json | jq '.agentContext'

# Reset agent context if needed
/feature [feature-name] --reset-context
```

## Success Metrics

### Development Efficiency
- **Feature completion time:** Target 60% reduction vs manual process
- **Rework rate:** Target <10% of initial implementation needs changes
- **Quality gate pass rate:** Target >90% first-time pass rate

### Quality Metrics
- **Bug rate:** Target <2 bugs per feature in first week post-deployment
- **Performance impact:** Target <5% degradation on existing features
- **Security incidents:** Target 0 security issues from new features

### Process Consistency
- **Workflow compliance:** Target 100% features follow complete workflow
- **Documentation completeness:** Target 100% features have complete docs
- **Test coverage:** Target >85% coverage on all new features

This enhanced workflow system provides a comprehensive, automated approach to feature development that maintains Minerva's high standards while significantly accelerating development speed and consistency.