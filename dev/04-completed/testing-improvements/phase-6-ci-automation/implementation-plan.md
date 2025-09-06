# Phase 6: CI/CD Automation Implementation
**Week 6 - Automated Testing Pipeline**

*Duration: 3 days*  
*Target: <10 minute full test suite*  
*Focus: GitHub Actions integration, pre-commit hooks*

---

## Overview

CI/CD automation ensures all tests run automatically on every code change, providing AI agents with immediate feedback and preventing regressions from reaching production.

## Day-by-Day Implementation

### Day 1: GitHub Actions Pipeline
**Time: 5 hours**

```yaml
# .github/workflows/test-suite.yml
name: Comprehensive Test Suite
on:
  push:
    branches: [main, develop]
  pull_request:
    types: [opened, synchronize, reopened]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  NODE_VERSION: '20'
  SUPABASE_URL: ${{ secrets.TEST_SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.TEST_SUPABASE_ANON_KEY }}
  
jobs:
  # Fast feedback jobs (< 3 minutes)
  fast-feedback:
    name: Fast Feedback
    runs-on: ubuntu-latest
    timeout-minutes: 5
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci --prefer-offline --no-audit
        
      - name: Type checking
        run: npm run type-check
        
      - name: Linting
        run: npm run lint:check
        
      - name: Format checking
        run: npm run format:check
        
      - name: Smoke tests
        run: npm run test:smoke
        timeout-minutes: 1
        
    outputs:
      changed-files: ${{ steps.changes.outputs.files }}
      
  # API Contract Tests (parallel with fast feedback)
  api-contracts:
    name: API Contract Tests
    runs-on: ubuntu-latest
    timeout-minutes: 8
    
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci --prefer-offline
        
      - name: Setup test database
        run: npm run test:db:setup
        
      - name: Run API contract tests
        run: npm run test:api-contracts
        
      - name: Upload API test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: api-contract-results
          path: coverage/api-contracts/
          retention-days: 3
          
  # Component Tests
  component-tests:
    name: Component Tests
    runs-on: ubuntu-latest
    timeout-minutes: 10
    
    strategy:
      matrix:
        shard: [1, 2, 3, 4] # Parallel component testing
        
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci --prefer-offline
        
      - name: Run component tests (shard ${{ matrix.shard }})
        run: npm run test:components -- --shard=${{ matrix.shard }}/4
        
      - name: Upload component snapshots
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: component-snapshots-${{ matrix.shard }}
          path: tests/snapshots/__diffs__/
          
  # Performance Tests
  performance-tests:
    name: Performance Tests
    runs-on: ubuntu-latest
    timeout-minutes: 12
    
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci --prefer-offline
        
      - name: Setup performance test environment
        run: |
          npm run test:perf:setup
          npm run build:test
          
      - name: Run performance tests
        run: npm run test:performance
        
      - name: Check performance regressions
        run: npm run test:perf:check-regressions
        
      - name: Upload performance report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: performance-report
          path: performance-report.json
          
  # Database Security Tests
  database-security:
    name: Database Security Tests
    runs-on: ubuntu-latest
    timeout-minutes: 8
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_USER: test
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
          
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci --prefer-offline
        
      - name: Setup test database with RLS
        run: npm run test:db:setup:rls
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test_db
          
      - name: Run RLS tests
        run: npm run test:rls
        
      - name: Run migration security tests
        run: npm run test:migration-security
        
      - name: Generate security audit report
        run: npm run test:security-audit:report
        
  # E2E Tests (only on important changes)
  e2e-tests:
    name: E2E Tests
    runs-on: ubuntu-latest
    timeout-minutes: 20
    if: contains(github.event.head_commit.message, '[e2e]') || github.event_name == 'schedule'
    
    strategy:
      matrix:
        browser: [chromium, firefox]
        
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci --prefer-offline
        
      - name: Install Playwright browsers
        run: npx playwright install ${{ matrix.browser }} --with-deps
        
      - name: Build application
        run: npm run build
        
      - name: Start test server
        run: |
          npm run start:test &
          npm run wait-for-server
          
      - name: Setup E2E test data
        run: npm run test:e2e:setup-data
        
      - name: Run E2E tests
        run: npm run test:e2e -- --project=${{ matrix.browser }}
        
      - name: Upload E2E artifacts
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: e2e-results-${{ matrix.browser }}
          path: |
            test-results/
            screenshots/
            
  # Test Results Aggregation
  test-results:
    name: Aggregate Test Results
    runs-on: ubuntu-latest
    needs: [fast-feedback, api-contracts, component-tests, performance-tests, database-security]
    if: always()
    
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v4
        
      - name: Generate comprehensive test report
        run: |
          node scripts/aggregate-test-results.js
          
      - name: Comment on PR with results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = JSON.parse(fs.readFileSync('test-summary.json', 'utf8'));
            
            const comment = `## 🧪 Test Results
            
            | Test Suite | Status | Duration | Coverage |
            |-----------|--------|----------|----------|
            | Fast Feedback | ${{ needs.fast-feedback.result == 'success' ? '✅' : '❌' }} | ${report.fastFeedback.duration} | - |
            | API Contracts | ${{ needs.api-contracts.result == 'success' ? '✅' : '❌' }} | ${report.apiContracts.duration} | ${report.apiContracts.coverage}% |
            | Components | ${{ needs.component-tests.result == 'success' ? '✅' : '❌' }} | ${report.components.duration} | ${report.components.coverage}% |
            | Performance | ${{ needs.performance-tests.result == 'success' ? '✅' : '❌' }} | ${report.performance.duration} | - |
            | Database Security | ${{ needs.database-security.result == 'success' ? '✅' : '❌' }} | ${report.dbSecurity.duration} | ${report.dbSecurity.coverage}% |
            
            **Overall Status**: ${{ needs.fast-feedback.result == 'success' && needs.api-contracts.result == 'success' && needs.component-tests.result == 'success' && needs.performance-tests.result == 'success' && needs.database-security.result == 'success' ? '✅ All tests passing' : '❌ Some tests failed' }}
            
            **Total Duration**: ${report.totalDuration}
            **Overall Coverage**: ${report.overallCoverage}%
            `;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

### Day 2: Pre-commit Hooks & Local Automation
**Time: 4 hours**

```json
// package.json - Scripts and hooks configuration
{
  "scripts": {
    "test:all": "run-s test:smoke test:api-contracts test:components test:performance test:rls",
    "test:fast": "run-p test:smoke test:lint test:type-check",
    "test:smoke": "vitest run tests/smoke --reporter=basic --timeout=30000",
    "test:api-contracts": "vitest run tests/api-contracts --reporter=json --outputFile=coverage/api-contracts.json",
    "test:components": "vitest run tests/components --reporter=json --coverage --outputFile=coverage/components.json",
    "test:performance": "vitest run tests/performance --reporter=json --outputFile=coverage/performance.json",
    "test:rls": "vitest run tests/database/rls --reporter=json --outputFile=coverage/rls.json",
    "test:e2e": "playwright test --reporter=json --output-file=coverage/e2e.json",
    "test:coverage": "nyc report --reporter=json-summary --reporter=html",
    
    "validate:quick": "run-s format:check lint:check type-check test:smoke",
    "validate:all": "run-s validate:quick test:all",
    
    "pre-commit": "lint-staged && npm run test:smoke",
    "pre-push": "npm run validate:quick && npm run test:api-contracts"
  },
  "husky": {
    "hooks": {
      "pre-commit": "npm run pre-commit",
      "pre-push": "npm run pre-push",
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
    }
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix --max-warnings 0",
      "prettier --write"
    ],
    "*.{js,jsx}": [
      "eslint --fix --max-warnings 0", 
      "prettier --write"
    ],
    "*.{json,md,yml,yaml}": [
      "prettier --write"
    ]
  }
}
```

```typescript
// scripts/test-automation/test-orchestrator.ts
export class TestOrchestrator {
  private config: TestConfig;
  private results: TestResults = {};
  
  constructor(config: TestConfig) {
    this.config = config;
  }
  
  async runTestSuite(suite: TestSuiteType): Promise<TestSuiteResult> {
    console.log(`🚀 Running ${suite} test suite...`);
    
    const startTime = Date.now();
    
    try {
      switch (suite) {
        case 'fast-feedback':
          return await this.runFastFeedback();
        case 'comprehensive':
          return await this.runComprehensiveTests();
        case 'pre-commit':
          return await this.runPreCommitTests();
        case 'pre-push':
          return await this.runPrePushTests();
        case 'ci-full':
          return await this.runFullCITests();
        default:
          throw new Error(`Unknown test suite: ${suite}`);
      }
    } catch (error) {
      return {
        suite,
        success: false,
        duration: Date.now() - startTime,
        error: error.message,
        results: this.results,
      };
    }
  }
  
  private async runFastFeedback(): Promise<TestSuiteResult> {
    // Parallel execution of fastest tests
    const tasks = [
      this.runTask('lint', 'npm run lint:check'),
      this.runTask('format', 'npm run format:check'), 
      this.runTask('types', 'npm run type-check'),
      this.runTask('smoke', 'npm run test:smoke'),
    ];
    
    const results = await Promise.allSettled(tasks);
    const success = results.every(r => r.status === 'fulfilled');
    
    return {
      suite: 'fast-feedback',
      success,
      duration: this.getTotalDuration(results),
      results: this.results,
    };
  }
  
  private async runComprehensiveTests(): Promise<TestSuiteResult> {
    // Sequential execution for comprehensive coverage
    const testSequence = [
      { name: 'smoke', command: 'npm run test:smoke' },
      { name: 'api-contracts', command: 'npm run test:api-contracts' },
      { name: 'components', command: 'npm run test:components' },
      { name: 'performance', command: 'npm run test:performance' },
      { name: 'rls', command: 'npm run test:rls' },
    ];
    
    for (const test of testSequence) {
      console.log(`  Running ${test.name} tests...`);
      await this.runTask(test.name, test.command);
    }
    
    const success = Object.values(this.results).every(r => r.success);
    
    return {
      suite: 'comprehensive',
      success,
      duration: Object.values(this.results).reduce((sum, r) => sum + r.duration, 0),
      results: this.results,
    };
  }
  
  private async runTask(name: string, command: string): Promise<TaskResult> {
    const startTime = Date.now();
    
    try {
      const result = await this.executeCommand(command);
      
      this.results[name] = {
        success: true,
        duration: Date.now() - startTime,
        output: result.stdout,
        coverage: this.extractCoverage(result.stdout),
      };
      
      console.log(`  ✅ ${name}: ${this.results[name].duration}ms`);
      return this.results[name];
      
    } catch (error) {
      this.results[name] = {
        success: false,
        duration: Date.now() - startTime,
        output: error.stderr || error.stdout,
        error: error.message,
      };
      
      console.log(`  ❌ ${name}: ${error.message}`);
      throw error;
    }
  }
  
  private async executeCommand(command: string): Promise<{ stdout: string; stderr: string }> {
    const { spawn } = require('child_process');
    const [cmd, ...args] = command.split(' ');
    
    return new Promise((resolve, reject) => {
      const process = spawn(cmd, args, { stdio: 'pipe' });
      let stdout = '';
      let stderr = '';
      
      process.stdout.on('data', (data: Buffer) => {
        stdout += data.toString();
      });
      
      process.stderr.on('data', (data: Buffer) => {
        stderr += data.toString();
      });
      
      process.on('close', (code: number) => {
        if (code === 0) {
          resolve({ stdout, stderr });
        } else {
          reject({ code, stdout, stderr, message: `Command failed with code ${code}` });
        }
      });
    });
  }
  
  generateReport(): TestReport {
    const totalTests = Object.keys(this.results).length;
    const passedTests = Object.values(this.results).filter(r => r.success).length;
    const totalDuration = Object.values(this.results).reduce((sum, r) => sum + r.duration, 0);
    const overallCoverage = this.calculateOverallCoverage();
    
    return {
      timestamp: new Date().toISOString(),
      summary: {
        totalTests,
        passed: passedTests,
        failed: totalTests - passedTests,
        duration: totalDuration,
        coverage: overallCoverage,
      },
      results: this.results,
      recommendations: this.generateRecommendations(),
    };
  }
  
  private generateRecommendations(): string[] {
    const recommendations = [];
    
    if (this.results.smoke?.duration > 30000) {
      recommendations.push('Smoke tests taking >30s - consider optimizing test data setup');
    }
    
    if (this.results.components?.coverage < 90) {
      recommendations.push('Component coverage below 90% - add tests for missing components');
    }
    
    if (this.results.performance && !this.results.performance.success) {
      recommendations.push('Performance tests failing - review baseline expectations');
    }
    
    const totalDuration = Object.values(this.results).reduce((sum, r) => sum + r.duration, 0);
    if (totalDuration > 600000) { // 10 minutes
      recommendations.push('Test suite taking >10min - consider parallelization improvements');
    }
    
    return recommendations;
  }
}
```

### Day 3: Testing Dashboard & Monitoring
**Time: 3 hours**

```typescript
// scripts/test-dashboard/dashboard-generator.ts
export class TestDashboardGenerator {
  async generateDashboard(testResults: TestResults[]): Promise<string> {
    const dashboard = this.createDashboardHTML({
      overview: this.generateOverview(testResults),
      trends: this.generateTrends(testResults),
      coverage: this.generateCoverageReport(testResults),
      performance: this.generatePerformanceMetrics(testResults),
      alerts: this.generateAlerts(testResults),
    });
    
    return dashboard;
  }
  
  private generateOverview(results: TestResults[]): DashboardOverview {
    const latest = results[results.length - 1];
    
    return {
      totalTests: Object.keys(latest.results).length,
      passingRate: this.calculatePassingRate(latest),
      averageDuration: this.calculateAverageDuration(results.slice(-10)),
      overallCoverage: latest.summary.coverage,
      status: latest.summary.failed === 0 ? 'healthy' : 'issues',
      lastUpdate: latest.timestamp,
    };
  }
  
  private generateTrends(results: TestResults[]): TrendData {
    const last30Days = results.slice(-30);
    
    return {
      passingRate: last30Days.map(r => ({
        date: r.timestamp,
        value: this.calculatePassingRate(r),
      })),
      duration: last30Days.map(r => ({
        date: r.timestamp,
        value: r.summary.duration,
      })),
      coverage: last30Days.map(r => ({
        date: r.timestamp,
        value: r.summary.coverage,
      })),
    };
  }
  
  private generateAlerts(results: TestResults[]): Alert[] {
    const alerts = [];
    const latest = results[results.length - 1];
    
    // Performance regression alert
    if (latest.summary.duration > 600000) { // 10 minutes
      alerts.push({
        type: 'performance',
        severity: 'high',
        message: 'Test suite duration exceeds 10 minutes',
        value: latest.summary.duration,
        threshold: 600000,
      });
    }
    
    // Coverage drop alert
    if (latest.summary.coverage < 85) {
      alerts.push({
        type: 'coverage',
        severity: 'medium',
        message: 'Overall coverage below 85%',
        value: latest.summary.coverage,
        threshold: 85,
      });
    }
    
    // Flaky test alert
    const flakyTests = this.detectFlakyTests(results.slice(-10));
    if (flakyTests.length > 0) {
      alerts.push({
        type: 'reliability',
        severity: 'medium',
        message: `${flakyTests.length} flaky tests detected`,
        details: flakyTests,
      });
    }
    
    return alerts;
  }
  
  private createDashboardHTML(data: DashboardData): string {
    return `
<!DOCTYPE html>
<html>
<head>
    <title>Minerva Test Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: system-ui; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .card { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric { display: inline-block; margin: 10px 20px 10px 0; }
        .metric-label { font-size: 14px; color: #666; }
        .metric-value { font-size: 24px; font-weight: bold; color: #333; }
        .status-healthy { color: #10b981; }
        .status-issues { color: #ef4444; }
        .alert { padding: 12px; margin: 8px 0; border-radius: 4px; }
        .alert-high { background: #fef2f2; border-left: 4px solid #ef4444; }
        .alert-medium { background: #fffbeb; border-left: 4px solid #f59e0b; }
        .chart-container { width: 100%; height: 300px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Minerva Test Dashboard</h1>
        
        <div class="card">
            <h2>Overview</h2>
            <div class="metric">
                <div class="metric-label">Total Tests</div>
                <div class="metric-value">${data.overview.totalTests}</div>
            </div>
            <div class="metric">
                <div class="metric-label">Passing Rate</div>
                <div class="metric-value status-${data.overview.status}">${data.overview.passingRate}%</div>
            </div>
            <div class="metric">
                <div class="metric-label">Average Duration</div>
                <div class="metric-value">${Math.round(data.overview.averageDuration / 1000)}s</div>
            </div>
            <div class="metric">
                <div class="metric-label">Coverage</div>
                <div class="metric-value">${data.overview.overallCoverage}%</div>
            </div>
            <div class="metric">
                <div class="metric-label">Last Update</div>
                <div class="metric-value">${new Date(data.overview.lastUpdate).toLocaleString()}</div>
            </div>
        </div>
        
        <div class="card">
            <h2>Coverage by Category</h2>
            <div class="chart-container">
                <canvas id="coverageChart"></canvas>
            </div>
        </div>
        
        <div class="card">
            <h2>Performance Trends</h2>
            <div class="chart-container">
                <canvas id="performanceChart"></canvas>
            </div>
        </div>
        
        ${data.alerts.length > 0 ? `
        <div class="card">
            <h2>⚠️ Alerts</h2>
            ${data.alerts.map(alert => `
                <div class="alert alert-${alert.severity}">
                    <strong>${alert.type.toUpperCase()}</strong>: ${alert.message}
                    ${alert.value ? `<br>Current: ${alert.value}, Threshold: ${alert.threshold}` : ''}
                </div>
            `).join('')}
        </div>
        ` : ''}
        
        <div class="card">
            <h2>Test Suite Breakdown</h2>
            <table style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="background: #f9f9f9;">
                        <th style="padding: 12px; text-align: left;">Test Suite</th>
                        <th style="padding: 12px; text-align: center;">Status</th>
                        <th style="padding: 12px; text-align: center;">Duration</th>
                        <th style="padding: 12px; text-align: center;">Coverage</th>
                    </tr>
                </thead>
                <tbody>
                    ${Object.entries(data.coverage).map(([suite, metrics]) => `
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 12px;">${suite}</td>
                            <td style="padding: 12px; text-align: center;">${metrics.success ? '✅' : '❌'}</td>
                            <td style="padding: 12px; text-align: center;">${Math.round(metrics.duration / 1000)}s</td>
                            <td style="padding: 12px; text-align: center;">${metrics.coverage || 'N/A'}%</td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        </div>
    </div>
    
    <script>
        // Coverage Chart
        const coverageCtx = document.getElementById('coverageChart').getContext('2d');
        new Chart(coverageCtx, {
            type: 'doughnut',
            data: {
                labels: ${JSON.stringify(Object.keys(data.coverage))},
                datasets: [{
                    data: ${JSON.stringify(Object.values(data.coverage).map(m => m.coverage || 0))},
                    backgroundColor: ['#10b981', '#f59e0b', '#3b82f6', '#8b5cf6', '#ef4444']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: { display: true, text: 'Test Coverage by Suite' }
                }
            }
        });
        
        // Performance Chart  
        const perfCtx = document.getElementById('performanceChart').getContext('2d');
        new Chart(perfCtx, {
            type: 'line',
            data: {
                labels: ${JSON.stringify(data.trends.duration.slice(-15).map(d => new Date(d.date).toLocaleDateString()))},
                datasets: [{
                    label: 'Duration (seconds)',
                    data: ${JSON.stringify(data.trends.duration.slice(-15).map(d => d.value / 1000))},
                    borderColor: '#3b82f6',
                    tension: 0.1
                }, {
                    label: 'Coverage %',
                    data: ${JSON.stringify(data.trends.coverage.slice(-15).map(d => d.value))},
                    borderColor: '#10b981',
                    tension: 0.1,
                    yAxisID: 'y1'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: { beginAtZero: true, position: 'left' },
                    y1: { type: 'linear', display: true, position: 'right', min: 0, max: 100 }
                }
            }
        });
    </script>
</body>
</html>`;
  }
}
```

## Automated Test Scripts

```bash
#!/bin/bash
# scripts/test-automation/run-tests.sh

set -e

TEST_TYPE=${1:-"all"}
ENVIRONMENT=${2:-"ci"}
PARALLEL=${3:-"true"}

echo "🧪 Running Minerva Test Suite"
echo "Type: $TEST_TYPE"
echo "Environment: $ENVIRONMENT"
echo "Parallel: $PARALLEL"

# Set environment variables
export NODE_ENV=test
export CI=${CI:-true}
export PARALLEL_TESTS=$PARALLEL

# Function to run tests with timing
run_with_timing() {
    local name=$1
    local command=$2
    
    echo "⏱️  Starting $name..."
    local start=$(date +%s)
    
    if eval "$command"; then
        local end=$(date +%s)
        local duration=$((end - start))
        echo "✅ $name completed in ${duration}s"
        return 0
    else
        local end=$(date +%s)
        local duration=$((end - start))
        echo "❌ $name failed after ${duration}s"
        return 1
    fi
}

# Main test execution
case $TEST_TYPE in
    "smoke")
        run_with_timing "Smoke Tests" "npm run test:smoke"
        ;;
    "fast")
        if [ "$PARALLEL" = "true" ]; then
            run_with_timing "Fast Feedback (Parallel)" "npm run test:fast"
        else
            run_with_timing "Lint" "npm run lint:check" &&
            run_with_timing "Type Check" "npm run type-check" &&
            run_with_timing "Smoke Tests" "npm run test:smoke"
        fi
        ;;
    "api")
        run_with_timing "API Contract Tests" "npm run test:api-contracts"
        ;;
    "components")
        if [ "$PARALLEL" = "true" ]; then
            run_with_timing "Component Tests (Parallel)" "npm run test:components -- --parallel"
        else
            run_with_timing "Component Tests" "npm run test:components"
        fi
        ;;
    "performance")
        run_with_timing "Performance Tests" "npm run test:performance"
        ;;
    "security")
        run_with_timing "Database Security Tests" "npm run test:rls" &&
        run_with_timing "Migration Security" "npm run test:migration-security"
        ;;
    "e2e")
        run_with_timing "E2E Tests" "npm run test:e2e"
        ;;
    "all")
        echo "🚀 Running comprehensive test suite..."
        
        # Fast feedback first
        run_with_timing "Fast Feedback" "npm run test:fast" &&
        
        # Core functionality tests (parallel)
        if [ "$PARALLEL" = "true" ]; then
            echo "Running core tests in parallel..."
            (run_with_timing "API Contracts" "npm run test:api-contracts") &
            (run_with_timing "Components" "npm run test:components") &
            (run_with_timing "Performance" "npm run test:performance") &
            (run_with_timing "Security" "npm run test:rls") &
            wait
        else
            run_with_timing "API Contracts" "npm run test:api-contracts" &&
            run_with_timing "Components" "npm run test:components" &&
            run_with_timing "Performance" "npm run test:performance" &&
            run_with_timing "Security" "npm run test:rls"
        fi &&
        
        # Generate final report
        run_with_timing "Test Report Generation" "npm run test:report"
        ;;
    *)
        echo "❌ Unknown test type: $TEST_TYPE"
        echo "Available types: smoke, fast, api, components, performance, security, e2e, all"
        exit 1
        ;;
esac

# Generate dashboard if all tests passed
if [ $? -eq 0 ]; then
    echo "📊 Generating test dashboard..."
    npm run test:dashboard:generate
    echo "✅ All tests completed successfully!"
else
    echo "❌ Some tests failed. Check the output above."
    exit 1
fi
```

## Test Execution Commands

```bash
# Local development
npm run test:dev          # Fast feedback loop
npm run test:pre-commit   # Pre-commit validation
npm run test:pre-push     # Pre-push comprehensive

# CI/CD
npm run test:ci:fast      # Fast CI feedback
npm run test:ci:full      # Full CI suite
npm run test:ci:nightly   # Nightly comprehensive tests

# Manual execution
npm run test:parallel     # All tests in parallel
npm run test:sequential   # All tests sequentially
npm run test:with-coverage # Tests with coverage report
```

## Success Metrics

### Pipeline Performance Targets
- **Fast Feedback**: <3 minutes
- **API Contracts**: <5 minutes  
- **Component Tests**: <8 minutes
- **Performance Tests**: <10 minutes
- **Full Suite**: <12 minutes
- **E2E Tests**: <20 minutes

### Quality Gates
- **Pre-commit**: Lint + Format + Types + Smoke (<1 minute)
- **Pre-push**: Fast feedback + API contracts (<8 minutes)
- **CI Success**: All tests pass with >85% coverage
- **Deployment**: E2E tests pass in production-like environment

### Automation Coverage
- ✅ Automated lint and format checking
- ✅ Type safety validation
- ✅ Unit and integration test execution
- ✅ Performance regression detection
- ✅ Security vulnerability scanning
- ✅ Cross-browser compatibility testing
- ✅ Test result aggregation and reporting
- ✅ Automated failure notifications

**Success Criteria**: Complete CI/CD automation provides AI agents with <3 minute feedback loops and comprehensive test coverage validation, ensuring production-ready code quality.