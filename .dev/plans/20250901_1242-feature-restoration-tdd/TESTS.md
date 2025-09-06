# 🧪 Comprehensive Test Specifications - Feature Restoration TDD

**Project**: Minerva Machine Safety Photo Organizer  
**Architecture**: Convex + Clerk (Post-Migration)  
**Test Strategy**: Test-Driven Development (Red-Green-Refactor)  
**Coverage Target**: >80% unit, >70% integration, 100% critical paths  
**Testing Frameworks**: Vitest (unit), Playwright (E2E), Testing Library (React)  

---

## 📊 Test Coverage Matrix

| Feature Domain | Unit Tests | Integration Tests | E2E Tests | Performance Tests | Security Tests |
|----------------|------------|-------------------|-----------|-------------------|----------------|
| Admin Dashboard | ✅ Required | ✅ Required | ✅ Required | ⚡ Optional | 🔒 Required |
| AI Processing | ✅ Required | ✅ Required | ✅ Required | ⚡ Required | 🔒 Required |
| Search & Filter | ✅ Required | ✅ Required | ✅ Required | ⚡ Required | ⚡ Optional |
| Notes System | ✅ Required | ✅ Required | ⚡ Optional | ⚡ Optional | 🔒 Required |
| Export Features | ✅ Required | ✅ Required | ✅ Required | ⚡ Required | 🔒 Required |

---

## 🎯 Priority 1: Admin Dashboard Test Specifications

### 1.1 Admin Authentication & Authorization Tests

#### Test ID: ADMIN-AUTH-001
**Test Category**: Security / Authentication  
**Test Type**: Unit + Integration + E2E  
**Priority**: CRITICAL  

**Given-When-Then Scenarios**:
```gherkin
Feature: Admin Role-Based Access Control

Scenario: Super Admin Access
  Given a user with super_admin role
  When they access the admin dashboard
  Then they should see all admin features
  And have full CRUD permissions on all resources
  And see cross-organization data

Scenario: Organization Admin Access  
  Given a user with org_admin role
  When they access the admin dashboard
  Then they should see organization-specific features
  And have CRUD permissions within their organization
  And NOT see cross-organization data

Scenario: Non-Admin Access Denial
  Given a user with regular user role
  When they attempt to access /admin/*
  Then they should be redirected to /unauthorized
  And see appropriate error message
  And the attempt should be logged

Scenario: JWT Token Validation
  Given an expired or invalid JWT token
  When making admin API requests
  Then the request should return 401
  And trigger re-authentication flow
  And preserve intended destination
```

**Test Implementation Requirements**:
```typescript
// Unit Tests Required
- [ ] Test role validation logic in isolation
- [ ] Test permission checking functions
- [ ] Test JWT validation utilities
- [ ] Test organization boundary enforcement

// Integration Tests Required  
- [ ] Test Clerk integration for role retrieval
- [ ] Test Convex auth validation in mutations
- [ ] Test middleware chain execution
- [ ] Test cross-organization access prevention

// E2E Tests Required
- [ ] Full admin login flow with different roles
- [ ] Permission boundary testing
- [ ] Session timeout handling
- [ ] Multi-tab session synchronization
```

### 1.2 Organization Management Tests

#### Test ID: ADMIN-ORG-001
**Test Category**: CRUD Operations  
**Test Type**: Unit + Integration  
**Priority**: HIGH  

**Test Scenarios**:
```typescript
describe('Organization Management', () => {
  describe('Create Organization', () => {
    // RED Phase - Write these tests first (must fail)
    it('should validate required fields')
    it('should enforce unique slug constraint')
    it('should set default limits')
    it('should create Clerk organization')
    it('should sync with Convex database')
    it('should handle creation failures gracefully')
    it('should emit creation events')
    it('should update audit log')
  })

  describe('Update Organization', () => {
    it('should validate update permissions')
    it('should prevent slug conflicts')
    it('should update storage limits')
    it('should sync changes with Clerk')
    it('should maintain data consistency')
    it('should handle partial updates')
    it('should track update history')
  })

  describe('Delete Organization', () => {
    it('should require super_admin role')
    it('should check for active users')
    it('should archive associated photos')
    it('should handle cascade deletion')
    it('should create deletion audit record')
    it('should send notification emails')
    it('should provide recovery window')
  })

  describe('Organization Analytics', () => {
    it('should calculate storage usage')
    it('should count active users')
    it('should track photo uploads')
    it('should generate usage reports')
    it('should identify trends')
    it('should export analytics data')
  })
})
```

### 1.3 User Management Tests

#### Test ID: ADMIN-USER-001
**Test Category**: User Administration  
**Test Type**: Unit + Integration + E2E  
**Priority**: HIGH  

**Acceptance Criteria Tests**:
```typescript
// User Listing Tests
- [ ] Paginated user list with 20 users per page
- [ ] Sortable by name, email, role, created date
- [ ] Filterable by organization, role, status
- [ ] Searchable by name and email
- [ ] Real-time updates when users join/leave
- [ ] Export user list to CSV

// User Creation Tests  
- [ ] Create user with email invitation
- [ ] Assign roles during creation
- [ ] Set organization membership
- [ ] Validate email uniqueness
- [ ] Send welcome email
- [ ] Track invitation status

// User Update Tests
- [ ] Update user roles
- [ ] Change organization assignment
- [ ] Suspend/reactivate accounts
- [ ] Reset user passwords
- [ ] Update profile information
- [ ] Maintain audit trail

// Bulk Operations Tests
- [ ] Bulk role assignment
- [ ] Bulk organization transfer
- [ ] Bulk account suspension
- [ ] Bulk email notifications
- [ ] Progress tracking for bulk operations
- [ ] Rollback capability for failures
```

### 1.4 Admin Dashboard UI Component Tests

#### Test ID: ADMIN-UI-001
**Test Category**: React Components  
**Test Type**: Unit + Integration  
**Priority**: MEDIUM  

**Component Test Matrix**:
```typescript
// AdminLayout Component
describe('AdminLayout', () => {
  it('renders navigation based on user role')
  it('highlights active route')
  it('handles mobile responsive menu')
  it('shows organization selector for super_admin')
  it('displays user profile dropdown')
  it('handles logout correctly')
})

// OrganizationTable Component
describe('OrganizationTable', () => {
  it('renders organizations with pagination')
  it('handles sorting by columns')
  it('implements search functionality')
  it('shows action buttons based on permissions')
  it('handles loading and error states')
  it('updates in real-time with Convex')
})

// UserManagementPanel Component
describe('UserManagementPanel', () => {
  it('displays user list with avatars')
  it('implements infinite scroll')
  it('shows role badges correctly')
  it('handles user search')
  it('opens edit modal on row click')
  it('confirms before deletion')
})

// AdminAnalyticsDashboard Component
describe('AdminAnalyticsDashboard', () => {
  it('renders usage charts')
  it('displays key metrics cards')
  it('handles date range selection')
  it('exports data on request')
  it('refreshes data periodically')
  it('shows loading skeletons')
})
```

---

## 🤖 Priority 2: AI Processing System Test Specifications

### 2.1 Google Vision API Integration Tests

#### Test ID: AI-VISION-001
**Test Category**: External API Integration  
**Test Type**: Unit + Integration  
**Priority**: CRITICAL  

**Test Scenarios**:
```typescript
describe('Google Vision API Integration', () => {
  describe('API Client Initialization', () => {
    it('should initialize with valid credentials')
    it('should handle missing credentials gracefully')
    it('should implement retry logic')
    it('should respect rate limits')
    it('should cache client instance')
  })

  describe('Image Analysis', () => {
    it('should detect machine safety labels')
    it('should identify text in images')
    it('should detect safety hazards')
    it('should calculate confidence scores')
    it('should handle API errors')
    it('should timeout after 30 seconds')
    it('should validate image formats')
  })

  describe('Response Processing', () => {
    it('should map labels to safety categories')
    it('should filter by confidence threshold')
    it('should aggregate similar tags')
    it('should prioritize safety-critical tags')
    it('should handle empty responses')
    it('should normalize tag formats')
  })
})
```

### 2.2 Batch Processing Queue Tests

#### Test ID: AI-BATCH-001
**Test Category**: Queue Management  
**Test Type**: Unit + Integration  
**Priority**: HIGH  

**Queue Processing Tests**:
```typescript
describe('AI Batch Processing Queue', () => {
  // Queue Management
  it('should add photos to processing queue')
  it('should process in FIFO order')
  it('should handle priority processing')
  it('should limit concurrent processing')
  it('should implement exponential backoff')
  it('should handle queue overflow')
  
  // Processing Status
  it('should update processing status in real-time')
  it('should emit progress events')
  it('should track success/failure rates')
  it('should maintain processing history')
  it('should calculate average processing time')
  
  // Error Handling
  it('should retry failed processing')
  it('should quarantine problematic images')
  it('should alert on repeated failures')
  it('should maintain error logs')
  it('should provide manual retry option')
  
  // Performance
  it('should process 100 images in < 5 minutes')
  it('should optimize batch sizes dynamically')
  it('should handle memory efficiently')
  it('should clean up completed jobs')
  it('should scale with load')
})
```

### 2.3 AI Results Storage & Retrieval Tests

#### Test ID: AI-STORAGE-001
**Test Category**: Data Persistence  
**Test Type**: Unit + Integration  
**Priority**: HIGH  

**Storage Operation Tests**:
```typescript
// Convex AI Results Storage
describe('AI Results Persistence', () => {
  describe('Storing AI Results', () => {
    it('should store tags with confidence scores')
    it('should link results to photos')
    it('should maintain processing metadata')
    it('should handle large tag sets')
    it('should prevent duplicate processing')
    it('should update existing results')
  })

  describe('Retrieving AI Results', () => {
    it('should fetch results by photo ID')
    it('should filter by confidence threshold')
    it('should aggregate results by category')
    it('should support pagination')
    it('should cache frequently accessed results')
    it('should handle missing results')
  })

  describe('Real-time Updates', () => {
    it('should broadcast new results')
    it('should update UI automatically')
    it('should handle subscription cleanup')
    it('should batch updates efficiently')
    it('should maintain consistency')
  })
})
```

### 2.4 Machine Safety Category Tests

#### Test ID: AI-SAFETY-001
**Test Category**: Domain Logic  
**Test Type**: Unit  
**Priority**: CRITICAL  

**Safety Category Validation**:
```typescript
describe('Machine Safety Categories', () => {
  // Category Mapping
  it('should map conveyor belt variations')
  it('should identify hydraulic equipment')
  it('should detect emergency stops')
  it('should classify PPE requirements')
  it('should recognize safety barriers')
  
  // Risk Assessment
  it('should calculate risk levels')
  it('should identify critical hazards')
  it('should suggest safety controls')
  it('should generate safety scores')
  it('should track compliance status')
  
  // Reporting
  it('should generate safety reports')
  it('should identify trends')
  it('should create audit trails')
  it('should export compliance data')
  it('should alert on critical findings')
})
```

---

## 🔍 Priority 3: Search & Filtering Test Specifications

### 3.1 Search Engine Tests

#### Test ID: SEARCH-ENGINE-001
**Test Category**: Search Functionality  
**Test Type**: Unit + Integration + Performance  
**Priority**: HIGH  

**Search Implementation Tests**:
```typescript
describe('Photo Search Engine', () => {
  describe('Text Search', () => {
    it('should search photo titles')
    it('should search descriptions')
    it('should search AI tags')
    it('should support partial matches')
    it('should handle typos (fuzzy search)')
    it('should rank by relevance')
    it('should highlight matches')
  })

  describe('Filter Combinations', () => {
    it('should filter by date range')
    it('should filter by organization')
    it('should filter by project')
    it('should filter by risk level')
    it('should filter by machine type')
    it('should combine multiple filters')
    it('should maintain filter state')
  })

  describe('Performance', () => {
    it('should return results in < 200ms')
    it('should handle 10,000+ photos')
    it('should implement pagination')
    it('should cache search results')
    it('should debounce input')
    it('should cancel outdated requests')
  })
})
```

### 3.2 Advanced Filter Tests

#### Test ID: SEARCH-FILTER-001
**Test Category**: Filtering Logic  
**Test Type**: Unit + Integration  
**Priority**: MEDIUM  

**Filter Validation Tests**:
```typescript
// Complex Filter Scenarios
- [ ] Date range with timezone handling
- [ ] Multi-select category filters
- [ ] Numeric range filters (file size, dimensions)
- [ ] Boolean filters (processed, starred, shared)
- [ ] Nested filters (project within organization)
- [ ] Exclusion filters (NOT conditions)
- [ ] Saved filter presets
- [ ] Filter reset functionality
- [ ] Filter URL persistence
- [ ] Filter export/import
```

---

## 📝 Priority 4: Notes System Test Specifications

### 4.1 Note CRUD Operations

#### Test ID: NOTES-CRUD-001
**Test Category**: Data Operations  
**Test Type**: Unit + Integration  
**Priority**: MEDIUM  

**CRUD Test Suite**:
```typescript
describe('Notes Management', () => {
  // Create Tests
  it('should create text notes')
  it('should support markdown formatting')
  it('should attach to photos')
  it('should validate note length')
  it('should set author metadata')
  
  // Read Tests
  it('should fetch notes by photo')
  it('should paginate long note lists')
  it('should show note history')
  it('should display author info')
  it('should handle deleted photos')
  
  // Update Tests
  it('should edit own notes')
  it('should track edit history')
  it('should prevent concurrent edits')
  it('should validate permissions')
  it('should maintain timestamps')
  
  // Delete Tests
  it('should soft delete notes')
  it('should require confirmation')
  it('should check permissions')
  it('should maintain audit log')
  it('should allow restoration')
})
```

---

## 📤 Priority 5: Export System Test Specifications

### 5.1 Export Format Tests

#### Test ID: EXPORT-FORMAT-001
**Test Category**: File Generation  
**Test Type**: Unit + Integration  
**Priority**: MEDIUM  

**Export Generation Tests**:
```typescript
describe('Export Functionality', () => {
  describe('PDF Export', () => {
    it('should generate valid PDF')
    it('should include photos')
    it('should format metadata')
    it('should handle large datasets')
    it('should compress file size')
  })

  describe('Excel Export', () => {
    it('should create XLSX format')
    it('should organize in sheets')
    it('should include formulas')
    it('should handle special characters')
    it('should limit row count')
  })

  describe('Word Export', () => {
    it('should generate DOCX format')
    it('should embed images')
    it('should format as report')
    it('should include TOC')
    it('should handle pagination')
  })

  describe('Performance', () => {
    it('should export 100 photos in < 10s')
    it('should stream large exports')
    it('should show progress')
    it('should handle cancellation')
    it('should clean up temp files')
  })
})
```

---

## 🧪 Test Data Management Strategy

### Test Data Requirements

```typescript
// Test Data Factories
interface TestDataFactories {
  // User Factory
  createTestUser(overrides?: Partial<User>): User
  createAdminUser(): User
  createOrgAdmin(): User
  
  // Organization Factory
  createTestOrg(overrides?: Partial<Organization>): Organization
  createOrgWithLimits(): Organization
  
  // Photo Factory
  createTestPhoto(overrides?: Partial<Photo>): Photo
  createPhotoWithAI(): Photo
  createBatchPhotos(count: number): Photo[]
  
  // AI Results Factory
  createAIResults(photoId: string): AIResult
  createSafetyTags(): SafetyTag[]
  
  // Project Factory
  createTestProject(orgId: string): Project
}

// Test Database Seeding
interface TestDatabaseSeeder {
  // Seed Functions
  seedBasicData(): Promise<void>
  seedLargeDataset(): Promise<void>
  seedEdgeCases(): Promise<void>
  
  // Cleanup Functions
  cleanupTestData(): Promise<void>
  resetDatabase(): Promise<void>
}

// Mock Data Providers
interface MockProviders {
  // External API Mocks
  mockGoogleVisionAPI(): void
  mockClerkAPI(): void
  mockStorageAPI(): void
  
  // Internal Service Mocks
  mockEmailService(): void
  mockNotificationService(): void
  mockAnalyticsService(): void
}
```

---

## 🔄 Integration Test Specifications

### API Integration Tests

```typescript
describe('API Integration Tests', () => {
  describe('Admin API Endpoints', () => {
    // GET /api/admin/organizations
    it('should return paginated organizations')
    it('should require admin authentication')
    it('should filter by status')
    it('should sort by creation date')
    
    // POST /api/admin/organizations
    it('should create new organization')
    it('should validate required fields')
    it('should check slug uniqueness')
    it('should sync with Clerk')
    
    // PUT /api/admin/organizations/:id
    it('should update organization')
    it('should validate permissions')
    it('should maintain audit log')
    it('should handle conflicts')
    
    // DELETE /api/admin/organizations/:id
    it('should archive organization')
    it('should check dependencies')
    it('should cascade updates')
    it('should notify users')
  })

  describe('AI Processing API', () => {
    // POST /api/ai/analyze
    it('should queue photo for analysis')
    it('should validate image format')
    it('should return job ID')
    it('should handle duplicates')
    
    // GET /api/ai/status/:jobId
    it('should return processing status')
    it('should include progress')
    it('should handle invalid IDs')
    
    // GET /api/ai/results/:photoId
    it('should return AI results')
    it('should include confidence scores')
    it('should cache responses')
  })
})
```

---

## 🎭 E2E Test Specifications

### Critical User Workflows

```typescript
describe('E2E User Workflows', () => {
  describe('Admin Workflow', () => {
    it('should complete full admin session', async () => {
      // Login as admin
      await loginAsAdmin()
      
      // Navigate to admin dashboard
      await navigateToAdminDashboard()
      
      // Create new organization
      await createOrganization({
        name: 'Test Org',
        slug: 'test-org'
      })
      
      // Add users to organization
      await inviteUsers(['user1@test.com', 'user2@test.com'])
      
      // Configure organization settings
      await updateOrgSettings({
        maxPhotos: 1000,
        maxStorage: 10GB
      })
      
      // View analytics
      await viewOrgAnalytics()
      
      // Export report
      await exportAnalyticsReport('PDF')
      
      // Logout
      await logout()
    })
  })

  describe('Photo Upload & AI Processing', () => {
    it('should complete photo workflow', async () => {
      // Login and navigate
      await login()
      await navigateToUpload()
      
      // Upload multiple photos
      await uploadPhotos([
        'test-photo-1.jpg',
        'test-photo-2.jpg',
        'test-photo-3.jpg'
      ])
      
      // Wait for AI processing
      await waitForProcessing()
      
      // View AI results
      await viewAIResults()
      
      // Add manual tags
      await addManualTags(['custom-tag-1', 'custom-tag-2'])
      
      // Search photos
      await searchPhotos('conveyor belt')
      
      // Export results
      await exportSearchResults('Excel')
    })
  })

  describe('Search & Filter Workflow', () => {
    it('should find photos using filters', async () => {
      // Apply multiple filters
      await applyFilters({
        dateRange: { from: '2024-01-01', to: '2024-12-31' },
        riskLevel: ['high', 'critical'],
        machineType: ['conveyor', 'hydraulic'],
        hasNotes: true
      })
      
      // Verify results
      await verifyFilteredResults()
      
      // Save filter preset
      await saveFilterPreset('High Risk Machines')
      
      // Clear and reapply
      await clearFilters()
      await loadFilterPreset('High Risk Machines')
    })
  })
})
```

---

## 🔐 Security Test Specifications

### Authentication & Authorization Tests

```typescript
describe('Security Tests', () => {
  describe('Authentication', () => {
    it('should enforce JWT expiration')
    it('should validate token signatures')
    it('should prevent token replay')
    it('should handle concurrent sessions')
    it('should implement rate limiting')
  })

  describe('Authorization', () => {
    it('should enforce role-based access')
    it('should validate organization boundaries')
    it('should prevent privilege escalation')
    it('should audit access attempts')
    it('should handle permission changes')
  })

  describe('Data Protection', () => {
    it('should sanitize user inputs')
    it('should prevent SQL injection')
    it('should block XSS attempts')
    it('should validate file uploads')
    it('should enforce CORS policies')
  })

  describe('API Security', () => {
    it('should require authentication')
    it('should validate request signatures')
    it('should implement rate limiting')
    it('should handle DDOS attempts')
    it('should log suspicious activity')
  })
})
```

---

## ⚡ Performance Test Specifications

### Load & Performance Tests

```typescript
describe('Performance Tests', () => {
  describe('Load Testing', () => {
    it('should handle 100 concurrent users')
    it('should process 1000 photos/hour')
    it('should maintain <200ms response time')
    it('should scale horizontally')
    it('should handle traffic spikes')
  })

  describe('Database Performance', () => {
    it('should optimize query execution')
    it('should implement proper indexing')
    it('should handle large datasets')
    it('should maintain connection pools')
    it('should cache frequently accessed data')
  })

  describe('Frontend Performance', () => {
    it('should achieve >90 Lighthouse score')
    it('should lazy load components')
    it('should implement code splitting')
    it('should optimize bundle size')
    it('should cache static assets')
  })
})
```

---

## 📈 Test Metrics & KPIs

### Coverage Requirements

| Metric | Target | Critical Path |
|--------|--------|---------------|
| Unit Test Coverage | >80% | 95% |
| Integration Coverage | >70% | 85% |
| E2E Coverage | >60% | 100% |
| Branch Coverage | >75% | 90% |
| Security Tests | 100% | 100% |

### Performance Benchmarks

| Operation | Target | Maximum |
|-----------|--------|---------|
| API Response | <200ms | 500ms |
| Photo Upload | <2s | 5s |
| AI Processing | <30s | 60s |
| Search Results | <100ms | 200ms |
| Export Generation | <10s | 30s |

### Quality Gates

- [ ] All tests passing in CI/CD
- [ ] No critical security vulnerabilities
- [ ] Performance benchmarks met
- [ ] Coverage thresholds achieved
- [ ] Zero high-priority bugs
- [ ] Documentation complete
- [ ] Code review approved

---

## 🔄 Test Execution Strategy

### Continuous Testing Pipeline

```yaml
# Test Execution Order
1. Pre-commit:
   - Linting
   - Type checking
   - Unit tests (affected only)

2. CI Pipeline:
   - Full unit test suite
   - Integration tests
   - Security scans
   - Performance tests

3. Pre-deployment:
   - E2E test suite
   - Load testing
   - Accessibility tests
   - Cross-browser tests

4. Post-deployment:
   - Smoke tests
   - Health checks
   - Performance monitoring
   - Error tracking
```

### Test Environment Configuration

```typescript
// Test Environment Setup
interface TestEnvironment {
  // Database
  database: 'test-convex-instance'
  
  // Authentication
  auth: {
    provider: 'clerk-test-mode',
    testUsers: ['admin', 'org-admin', 'user']
  }
  
  // External APIs
  apis: {
    googleVision: 'mocked',
    storage: 'in-memory',
    email: 'test-smtp'
  }
  
  // Feature Flags
  features: {
    aiProcessing: true,
    export: true,
    analytics: true
  }
}
```

---

## 📝 Test Documentation Standards

### Test Documentation Requirements

1. **Test Case Documentation**
   - Clear test description
   - Acceptance criteria
   - Test data requirements
   - Expected results
   - Edge cases covered

2. **Test Execution Reports**
   - Execution timestamp
   - Environment details
   - Pass/fail status
   - Performance metrics
   - Coverage reports

3. **Bug Reports**
   - Reproduction steps
   - Expected vs actual behavior
   - Environment details
   - Screenshots/videos
   - Severity assessment

4. **Test Maintenance Log**
   - Test updates
   - Reason for changes
   - Impact assessment
   - Review approval
   - Version tracking

---

**Document Version**: 1.0.0  
**Created**: September 1, 2025  
**Status**: Ready for TDD Implementation  
**Next Step**: Begin Phase 1 with Red-Green-Refactor cycles