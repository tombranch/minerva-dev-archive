# Priority API Endpoints for Testing
**222 Total Endpoints - Prioritized by Risk & Usage**

## Critical Priority (Must Test First)

### 🔴 Security & Authentication (15 endpoints)
These endpoints handle authentication and authorization - failures here compromise the entire system.

```typescript
// HIGH RISK - No withAuth middleware detected
⚠️ /api/ai/analytics/summary            // Missing auth wrapper
⚠️ /api/platform/test-data              // Completely open endpoint
⚠️ /api/debug/check-photos              // Debug endpoint exposed

// Core Auth Flow
/api/auth/session/refresh               // Session management
/api/auth/session/invalidate           // Session termination
/api/auth/profile                      // User context
/api/auth/csrf-token                   // CSRF protection
/api/create-user                       // User creation
/api/create-org                        // Organization creation
/api/check-user                        // User validation

// Organization Context
/api/photos (GET)                      // Must validate org context
/api/admin/users                       // Admin access control
/api/platform/organizations           // Multi-tenant isolation
```

### 🔴 Photo Management Core (30 endpoints)
Core user workflow - photo upload, management, and retrieval.

```typescript
// Upload & Processing Pipeline
/api/photos (POST)                     // Upload endpoint
/api/photos/[id] (GET, PUT, DELETE)   // CRUD operations
/api/photos/[id]/ai-results           // AI processing results
/api/photos/bulk-download              // Bulk operations
/api/photos/download                   // Single download

// Metadata & Organization
/api/photos/[id]/notes                 // Notes management
/api/photos/[id]/notes/[noteId]       // Note CRUD
/api/photos/[id]/activity             // Activity tracking
/api/photos/[id]/chat                 // AI chat context

// Search & Filtering
/api/search/ai-enhanced                // AI-powered search
/api/photos?tags=                     // Tag filtering
/api/photos?date_from=                // Date filtering
/api/photos?project_id=               // Project filtering
```

### 🔴 AI Processing Pipeline (25 endpoints)
AI integration points - critical for photo analysis functionality.

```typescript
// Core Processing
/api/ai/process-dual                   // Dual provider processing
/api/ai/analyze-ppe                    // PPE detection
/api/ai/generate-embeddings           // Vector embeddings
/api/ai/tag-correction                // Tag refinement

// Provider Management
/api/ai/providers                      // List providers
/api/ai/providers/[id]                // Provider details
/api/ai/providers/[id]/test          // Provider testing
/api/ai/provider-status               // Health monitoring
/api/ai/provider-comparison           // Performance comparison

// Model & Prompt Management
/api/ai/models                         // Available models
/api/ai/models/[id]                  // Model configuration
/api/ai/prompts                       // Prompt templates
/api/ai/prompts/[id]                 // Prompt CRUD
/api/ai/prompts/[id]/test           // Prompt testing
```

## High Priority (Test Second)

### 🟡 Platform Administration (40 endpoints)
Multi-tenant management and organization administration.

```typescript
// Organization Management
/api/platform/organizations           // Org listing
/api/platform/organizations/[id]      // Org details
/api/platform/feedback                // User feedback
/api/platform/analytics/export       // Analytics export

// Tag Management System
/api/platform/tags                    // Tag listing
/api/platform/tags/[id]              // Tag CRUD
/api/platform/tags/bulk              // Bulk operations
/api/platform/tags/duplicates        // Duplicate detection
/api/platform/tags/analytics         // Usage analytics
/api/platform/tags/performance       // Performance metrics
/api/platform/tags/suggestions       // AI suggestions
/api/platform/tags/saved-searches    // Search templates

// AI Management Console
/api/platform/ai-management/overview          // Dashboard
/api/platform/ai-management/monitoring        // Real-time monitoring
/api/platform/ai-management/spending         // Cost tracking
/api/platform/ai-management/experiments      // A/B testing
/api/platform/ai-management/features         // Feature flags
/api/platform/ai-management/budgets          // Budget controls
```

### 🟡 Export & Reporting (20 endpoints)
Data export and report generation functionality.

```typescript
// Document Generation
/api/export/word                      // Word export
/api/export/word/[id]                // Export status
/api/export/zip                      // ZIP creation
/api/export/csv                      // Data export

// Analytics Export
/api/platform/costs/export           // Cost reports
/api/platform/analytics/export       // Usage analytics
/api/monitoring/costs/analytics      // Cost analysis
/api/monitoring/performance/recent   // Performance data
```

### 🟡 Admin Dashboard (25 endpoints)
Administrative functions and monitoring.

```typescript
// User Management
/api/admin/users                     // User listing
/api/admin/users/[id]               // User details
/api/admin/users/export             // User data export
/api/admin/invitations              // Invitation management

// System Monitoring
/api/dashboard/metrics               // System metrics
/api/dashboard/activity             // Activity feed
/api/monitoring/costs               // Cost monitoring
/api/monitoring/performance         // Performance metrics
```

## Medium Priority (Test Third)

### 🟢 AI Analytics & Insights (30 endpoints)
Advanced AI analytics and optimization features.

```typescript
// Analytics Endpoints
/api/ai/analytics/roi-analysis              // ROI calculations
/api/ai/analytics/trend-forecasting        // Trend analysis
/api/ai/analytics/smart-insights           // AI insights
/api/ai/analytics/provider-performance     // Provider metrics
/api/ai/analytics/optimization-recommendations // Optimization

// Console & Dashboard
/api/ai/console/ws                         // WebSocket connection
/api/ai/dashboard/events                   // Event stream
/api/ai/experiments/[id]                  // Experiment details
/api/ai/features/[featureId]              // Feature configuration
```

### 🟢 Advanced Features (27 endpoints)
Extended functionality and advanced features.

```typescript
// Pipeline Management
/api/ai/pipeline/models              // Pipeline models
/api/ai/pipeline/rules              // Processing rules
/api/ai/pipeline/prompts            // Pipeline prompts
/api/ai/pipeline/providers          // Provider config

// Testing & Validation
/api/ai/testing/sample-photos       // Test photos
/api/ai/testing/ab-experiment       // A/B testing
/api/ai/response-schemas            // Response validation
/api/ai/response-schemas/[id]       // Schema management
```

### 🟢 Bulk Operations (25 endpoints)
Batch processing and bulk management.

```typescript
// Bulk Photo Operations
/api/photos/bulk-tag                // Bulk tagging
/api/photos/bulk-delete             // Bulk deletion
/api/photos/bulk-move               // Bulk move
/api/photos/bulk-export             // Bulk export

// Platform Bulk Operations
/api/platform/ai-management/bulk/operations // Bulk AI ops
/api/platform/ai-management/models/bulk     // Bulk model config
/api/platform/ai-management/experiments/bulk // Bulk experiments
```

## Low Priority (Test Last)

### 🔵 Debug & Development (10 endpoints)
Development and debugging endpoints.

```typescript
/api/debug-user                     // User debugging
/api/debug/check-photos             // Photo validation
/api/debug/test-connection          // Connection testing
/api/debug/clear-cache              // Cache management
```

### 🔵 Legacy & Deprecated (15 endpoints)
Endpoints scheduled for removal or rarely used.

```typescript
/api/v1/*                           // Legacy v1 endpoints
/api/deprecated/*                   // Deprecated features
```

## Testing Strategy by Priority

### Phase 1A: Critical Security (Day 1)
```bash
# Test authentication and authorization
npm run test:api -- --grep "auth|security"

# Validate organization isolation
npm run test:api -- --grep "organization context"
```

### Phase 1B: Core Workflows (Day 2)
```bash
# Test photo management pipeline
npm run test:api -- --grep "photos|upload"

# Test AI processing
npm run test:api -- --grep "ai|process"
```

### Phase 1C: Platform Features (Day 3)
```bash
# Test admin functions
npm run test:api -- --grep "admin|platform"

# Test export functionality
npm run test:api -- --grep "export|download"
```

### Phase 1D: Advanced Features (Day 4)
```bash
# Test analytics and monitoring
npm run test:api -- --grep "analytics|monitoring"

# Test bulk operations
npm run test:api -- --grep "bulk"
```

### Phase 1E: Complete Coverage (Day 5)
```bash
# Run full test suite
npm run test:api-contracts

# Generate coverage report
npm run test:api-contracts -- --coverage
```

## Endpoint Risk Matrix

| Category | Count | Risk Level | Test Priority | Coverage Target |
|----------|-------|------------|---------------|-----------------|
| Auth & Security | 15 | Critical | Day 1 | 100% |
| Photo Core | 30 | Critical | Day 1-2 | 100% |
| AI Processing | 25 | Critical | Day 2 | 100% |
| Platform Admin | 40 | High | Day 3 | 100% |
| Export & Reports | 20 | High | Day 3 | 100% |
| Admin Dashboard | 25 | High | Day 3 | 95% |
| AI Analytics | 30 | Medium | Day 4 | 90% |
| Advanced Features | 27 | Medium | Day 4 | 85% |
| Bulk Operations | 25 | Medium | Day 4 | 90% |
| Debug & Dev | 10 | Low | Day 5 | 50% |
| Legacy | 15 | Low | Optional | 0% |

## Quick Reference: Most Critical Endpoints

These 10 endpoints MUST be tested first:

1. `/api/auth/session/refresh` - Session management
2. `/api/auth/profile` - User context
3. `/api/photos` (GET) - Organization isolation
4. `/api/photos` (POST) - Upload pipeline
5. `/api/ai/process-dual` - AI processing
6. `/api/photos/bulk-download` - Bulk operations
7. `/api/platform/organizations` - Multi-tenancy
8. `/api/admin/users` - Access control
9. `/api/export/word` - Document generation
10. `/api/ai/analytics/summary` - ⚠️ Missing auth

## Coverage Tracking

```typescript
// Track coverage progress
const coverageTracker = {
  critical: {
    total: 70,
    tested: 0,
    percentage: 0,
  },
  high: {
    total: 85,
    tested: 0,
    percentage: 0,
  },
  medium: {
    total: 82,
    tested: 0,
    percentage: 0,
  },
  low: {
    total: 25,
    tested: 0,
    percentage: 0,
  },
  
  get overall() {
    const total = this.critical.total + this.high.total + 
                  this.medium.total + this.low.total;
    const tested = this.critical.tested + this.high.tested + 
                   this.medium.tested + this.low.tested;
    return {
      total,
      tested,
      percentage: (tested / total * 100).toFixed(1),
    };
  },
};
```

## Notes for AI Agents

1. **Start with Critical Priority** - These endpoints have security implications
2. **Test error cases** - Each endpoint should handle invalid input gracefully
3. **Validate schemas strictly** - Use Zod for comprehensive schema validation
4. **Check organization context** - Every endpoint must respect multi-tenancy
5. **Monitor test execution time** - Keep smoke tests under 30 seconds
6. **Track coverage incrementally** - Update coverage metrics after each test file

**Target**: 100% coverage of Critical and High priority endpoints (155 total) provides 70% overall coverage and covers all user-facing functionality.