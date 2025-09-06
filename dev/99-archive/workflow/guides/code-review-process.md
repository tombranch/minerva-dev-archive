# Code Review Process Guide - Enhanced Workflow

## Overview

The enhanced `/review` command transforms code review from a manual, time-consuming process into an intelligent, automated quality assurance system that leverages existing validation scripts and specialized agents.

## Review Process Architecture

### 1. Script-Based Validation Foundation
The review process starts by executing Minerva's comprehensive validation scripts:

```bash
npm run validate:all          # Master validation script
npm run lint                  # ESLint code quality analysis
npm run format:check          # Prettier formatting validation  
npm run test:ci               # Unit tests with coverage reporting
npm run test:e2e              # End-to-end test suite
npm run build                 # Production build validation
```

### 2. Intelligent Agent Analysis
Specialized agents analyze script outputs with full workflow context:

- **Script Output Analysis:** Agents parse and interpret validation results
- **Context-Aware Recommendations:** Suggestions tied to current feature and PRD requirements
- **Quality Gate Validation:** Automated assessment of deployment readiness
- **Prioritized Action Plans:** Ranked list of issues with impact assessment

## Enhanced Review Workflow

### Standard Review Process
```bash
/review
```

**Execution Flow:**

#### Phase 1: Validation Script Execution (Parallel)
```bash
# All validation scripts run simultaneously for speed
[PARALLEL] npm run validate:all
[PARALLEL] npm run lint  
[PARALLEL] npm run format:check
[PARALLEL] npm run test:ci
[PARALLEL] npm run test:e2e  
[PARALLEL] npm run build
```

#### Phase 2: Context-Aware Agent Analysis

1. **TypeScript Analysis** - `typescript-safety-validator`:
   ```bash
   Input: Build errors, type warnings, any usage detection
   Context: Current feature requirements, existing type patterns
   Output: Specific type fixes, safety violations, improvement recommendations
   ```

2. **Code Quality Analysis** - `quality-assurance-specialist`:
   ```bash
   Input: ESLint output, test results, coverage reports
   Context: PRD quality requirements, existing code patterns
   Output: Quality issues prioritized by impact, technical debt identification
   ```

3. **Test Analysis** - `testing-strategist`:
   ```bash
   Input: Test results, coverage reports, e2e test output
   Context: PRD acceptance criteria, test coverage targets
   Output: Test gaps, flaky test identification, coverage improvement plan
   ```

4. **Security Analysis** - `security-auditor`:
   ```bash
   Input: Code patterns, dependency vulnerabilities, auth flow changes
   Context: Current feature security requirements, existing security patterns
   Output: Vulnerability assessment, security improvement recommendations
   ```

5. **Performance Analysis** - `performance-optimizer`:
   ```bash
   Input: Build bundle analysis, performance test results
   Context: PRD performance targets, existing performance benchmarks
   Output: Performance bottlenecks, optimization opportunities, impact assessment
   ```

6. **Technical Debt Analysis** - `todo-placeholder-detector`:
   ```bash
   Input: Code scanning for TODOs, placeholder code, incomplete implementations
   Context: Current feature scope, development timeline
   Output: Technical debt inventory, completion requirements, risk assessment
   ```

#### Phase 3: Quality Gate Validation

**Automated Quality Gate Assessment:**
```json
{
  "implementation-complete": {
    "status": "passed|failed|warning",
    "criteria": [
      "All PRD requirements implemented",
      "No critical build errors", 
      "Error handling complete"
    ],
    "evidence": ["Build success", "Test coverage >85%", "No TODO markers in core paths"]
  },
  "quality-validated": {
    "status": "passed|failed|warning", 
    "criteria": [
      "Code quality standards met",
      "No critical lint errors",
      "Test coverage targets achieved"
    ],
    "evidence": ["ESLint clean", "Test coverage 87%", "No code quality violations"]
  },
  "security-approved": {
    "status": "passed|failed|warning",
    "criteria": [
      "No security vulnerabilities",
      "Authentication properly implemented", 
      "Data validation complete"
    ],
    "evidence": ["Security scan clean", "Auth tests passing", "Input validation verified"]
  }
}
```

#### Phase 4: Consolidated Recommendations

**Prioritized Action Plan:**
```markdown
## Critical Issues (Must Fix Before Deployment)
1. **Type Safety Violation** - `src/components/SearchFilter.tsx:45`
   - Issue: Using `any` type for search parameters
   - Impact: Runtime errors, poor developer experience
   - Fix: Define `SearchParams` interface
   - Estimated effort: 15 minutes

## High Priority Issues (Should Fix)
2. **Performance Bottleneck** - `src/hooks/usePhotoSearch.ts`
   - Issue: Expensive search operation on every keystroke
   - Impact: Poor user experience, high CPU usage
   - Fix: Implement debouncing with 300ms delay
   - Estimated effort: 30 minutes

## Medium Priority Issues (Could Fix)
3. **Test Coverage Gap** - Search component edge cases
   - Issue: Missing tests for error states
   - Impact: Potential production bugs
   - Fix: Add error state test cases
   - Estimated effort: 45 minutes
```

### Review Command Variants

#### Quick Review
```bash
/review --quick
```
**Executes:** Lint + Format + Type check only
**Use case:** Fast validation during development
**Duration:** ~30 seconds

#### Production Review
```bash
/review --production
```
**Executes:** Full validation + enhanced security scan + performance analysis
**Use case:** Pre-deployment validation
**Duration:** ~5 minutes

#### Security-Focused Review
```bash
/review --security
```
**Executes:** Security audit + dependency scan + auth flow validation
**Use case:** Security-sensitive features
**Duration:** ~2 minutes

#### Performance Review
```bash
/review --performance
```
**Executes:** Performance testing + bundle analysis + optimization recommendations
**Use case:** Performance-critical features
**Duration:** ~3 minutes

#### Directory-Specific Review
```bash
/review src/components/photo-search
```
**Executes:** Full review focused on specific directory
**Use case:** Focused validation of specific module
**Duration:** ~1 minute

## Integration with Workflow State

### Context-Aware Analysis
The enhanced review system uses workflow state for intelligent analysis:

```json
{
  "reviewContext": {
    "currentFeature": "advanced-photo-search",
    "prdRequirements": [
      "Search response time <500ms",
      "Support 10k+ photos", 
      "Mobile-responsive interface"
    ],
    "previousReviewFindings": [
      "Performance optimization needed",
      "Mobile responsiveness gaps"
    ],
    "qualityGateTargets": {
      "testCoverage": ">85%",
      "buildTime": "<120s",
      "bundleSize": "<2MB"
    }
  }
}
```

### Quality Gate Updates
Review results automatically update workflow state:

```bash
# Before review
"qualityGates": {
  "passed": ["requirements-complete", "architecture-reviewed"],
  "pending": ["quality-validated", "security-approved"],
  "failed": []
}

# After successful review
"qualityGates": {
  "passed": ["requirements-complete", "architecture-reviewed", "quality-validated", "security-approved"],
  "pending": ["production-ready"],
  "failed": []
}
```

## Advanced Review Patterns

### Continuous Review Integration
```bash
# Git hook integration (optional)
git config core.hooksPath .githooks
# Pre-commit hook runs: /review --quick
# Pre-push hook runs: /review --production
```

### Review-Driven Development
```bash
# Development cycle with frequent reviews
git add .
/review --quick          # Fast feedback during development
# Fix issues
git add .
/review                  # Full review before commit
git commit -m "feat: implement advanced search"
```

### Team Review Workflow
```bash
# Individual developer review
/review

# Create PR with review context
gh pr create --title "feat: advanced search" --body "$(cat <<'EOF'
## Review Summary
✅ All quality gates passed
✅ Security scan clean  
✅ Performance targets met
✅ Test coverage: 87%

## Key Changes
- Implemented faceted search interface
- Added search result caching
- Enhanced mobile responsiveness

/review output attached for detailed analysis.
EOF
)"
```

## Review Quality Metrics

### Success Indicators
- **Script Pass Rate:** >95% of validation scripts pass on first run
- **Issue Resolution Time:** Average <2 hours from identification to fix
- **False Positive Rate:** <5% of agent recommendations are irrelevant
- **Quality Gate Pass Rate:** >90% of reviews pass all quality gates

### Tracking and Improvement
```json
{
  "reviewMetrics": {
    "totalReviews": 156,
    "averageDuration": "3.2 minutes",
    "scriptPassRate": "94%",
    "qualityGatePassRate": "91%",
    "issuesByPriority": {
      "critical": 12,
      "high": 45,
      "medium": 89,
      "low": 23
    },
    "mostCommonIssues": [
      "Type safety violations",
      "Test coverage gaps", 
      "Performance optimization opportunities"
    ]
  }
}
```

## Troubleshooting Review Issues

### Script Failures
```bash
# Individual script debugging
npm run lint -- --debug
npm run test:ci -- --verbose
npm run build -- --verbose

# Script timeout issues
/review --extend-timeout
```

### Agent Analysis Issues
```bash
# Check agent context
cat .claude/workflow-state.json | jq '.agentContext'

# Reset agent context
/review --reset-context

# Verbose agent output
/review --verbose
```

### Quality Gate Failures
```bash
# Identify specific gate failures
/review --gates-only

# Override gate for emergency (with justification)
/review --override-gate security-approved --reason "emergency hotfix"
```

## Integration with External Tools

### IDE Integration
```bash
# VS Code integration
code --install-extension claude-code-review
# Automatic review on file save
```

### CI/CD Pipeline
```bash
# GitHub Actions integration
name: Code Review
on: [push, pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Claude Code Review
        run: /review --production --ci-mode
```

### Slack Integration
```bash
# Review notifications
/review --notify-slack #dev-team
```

## Best Practices

### When to Review
- **Before every commit** - Use `/review --quick` for fast feedback
- **Before creating PRs** - Use `/review` for comprehensive validation
- **Before deployment** - Use `/review --production` for final validation
- **After fixing issues** - Use `/review --focus [specific-area]` to validate fixes

### Review Efficiency
- **Use appropriate variant** - Don't run full review for minor changes
- **Address critical issues first** - Follow priority recommendations
- **Batch similar fixes** - Fix all type issues at once, all test issues together
- **Learn from patterns** - Notice recurring issues and address root causes

### Quality Standards
- **Never override quality gates without justification** - Maintain high standards
- **Address all critical issues** - Don't deploy with critical problems
- **Track improvement trends** - Monitor review metrics over time
- **Share learnings** - Document common issues and solutions

The enhanced review process transforms code quality assurance from a manual bottleneck into an automated accelerator that maintains Minerva's high standards while providing rapid, intelligent feedback to developers.