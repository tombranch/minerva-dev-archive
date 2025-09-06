# Priority Action List - Minerva AI Management Platform

**Document Version:** 3.0  
**Created:** 2025-08-07  
**Updated:** 2025-08-13  
**Author:** Tom Branch  
**Project:** Minerva Machine Safety Photo Organizer  
**Status:** Revised with MVP-focused priorities and realistic timeline

## Current State Assessment ✅
- **Production Code**: 0 TypeScript errors, build successful  
- **Security**: Clean vulnerability scan, but critical endpoint gaps identified
- **Infrastructure**: Supabase database with 18+ migrations applied
- **Overall**: 87% complete, but missing core MVP user workflows

---

## Phase 1: Security & Core MVP (Week 1) - CRITICAL
**Priority: MUST-HAVE - No deployment until complete**

### Security Hardening (Blocking Production)
1. [x] **Fix Photos page org context** (`app/(protected)/photos/page.tsx`) ⚠️
   - **Current**: Has fallback logic but still uses `user?.user_metadata?.organization_id` temp fix
   - **Action**: Replace entirely with server-validated org ID via useAuth hook
   - **Acceptance**: No client-side organization ID resolution

2. [x] **Secure analytics summary route** (`app/api/ai/analytics/summary/route.ts`) ❌
   - **Current**: No `withAuth` middleware, insecure header/query extraction
   - **Action**: Wrap with `withAuth` middleware, add organization-scoped access validation
   - **Acceptance**: Proper authentication and authorization for all requests

3. [x] **Gate test data page** (`app/platform/test-data/page.tsx`) ❌
   - **Current**: Completely open, no environment gating
   - **Action**: Add `NEXT_PUBLIC_ENABLE_TEST_DATA` environment flag
   - **Acceptance**: Page hidden in production builds

4. [x] **AI endpoints security audit** (`app/api/ai/**/*`)
   - Audit all AI endpoints for consistent `withAuth` usage
   - Add rate limiting for expensive operations
   - **Acceptance**: All AI endpoints properly authenticated and rate-limited

### Core User Flow Validation (New - Critical for MVP)
5. [x] **End-to-end photo workflow validation**
   - Photo upload → AI processing → results display
   - Organization context maintained throughout
   - **Acceptance**: Complete user workflow functions without errors

6. [x] **Authentication flow validation**
   - Login → organization selection → photos access
   - Profile setup and organization switching
   - **Acceptance**: Seamless user onboarding and context switching

7. [x] **Essential smoke tests** (Moved from Phase 4)
   - Critical path testing (<5 min validation)
   - Build/deploy verification scripts
   - Database connectivity validation
   - **Acceptance**: Automated validation suite for core functionality

---

## Phase 2: MVP Feature Completion (Week 2) - ESSENTIAL
**Priority: Core user value delivery**

8. [x] **Word Export System** (Promoted from Phase 3)
   - Template-based document generation with photo embedding
   - Safety compliance formatting for manufacturing reports
   - Metadata inclusion (timestamps, tags, organization info)
   - **Acceptance**: Users can export photo collections as formatted Word documents

9. [x] **Basic Bulk Operations** (Simplified scope)
   - Multi-photo selection interface
   - Bulk delete operations
   - Bulk tag application/removal
   - **Note**: ZIP download generation moved to Phase 4
   - **Acceptance**: Users can efficiently manage multiple photos

10. [x] **Core Admin Functions** (Simplified from original Phase 2)
    - Organization management basics (create, edit, deactivate)
    - User management essentials (invite, deactivate, role assignment)
    - **Note**: Advanced AI management console features moved to Phase 4
    - **Acceptance**: Basic multi-tenant administration works

---

## Phase 3: Quality & Stability (Week 3) - PRE-LAUNCH
**Priority: Production readiness validation**

11. [ ] **Test Infrastructure Cleanup** (New critical item)
    - Fix 74 remaining TypeScript errors in test files
    - Resolve 93 ESLint warnings from production audit
    - Stabilize CI/CD pipeline
    - **Acceptance**: Clean builds with zero warnings/errors

12. [ ] **Performance Validation** (New critical item)
    - Load testing for photo upload workflows
    - Database query optimization for large datasets
    - API response time validation (<2s for critical endpoints)
    - **Acceptance**: System performs well under expected load

13. [ ] **Basic Tag Management** (Kept from original)
    - CRUD interface for organization tags
    - Tag usage analytics
    - **Acceptance**: Organizations can manage their custom tag vocabulary

---

## Phase 4: Advanced Features (Post-MVP) - ENHANCEMENT
**Priority: Future value after successful launch**

14. [ ] **Advanced AI Management Console** (Detailed features)
    - Live Status monitoring with real-time updates
    - Advanced Prompts management with A/B testing
    - Provider comparison and cost optimization tools
    - Advanced monitoring and alerting

15. [ ] **Advanced Bulk Operations**
    - ZIP download generation with progress tracking
    - Advanced filtering and search for bulk operations
    - Scheduled bulk operations

16. [ ] **Enhanced Analytics & Testing**
    - Comprehensive test coverage expansion
    - Advanced AI analytics dashboard
    - Performance monitoring and alerting

17. [ ] **Strategic Technical Improvements**
    - tRPC migration for type-safe API contracts
    - OpenRouter integration for unified AI model access
    - Advanced caching and optimization

---

## Key Changes Made 🔧

### 1. **Security-First Approach**
- No production deployment until all Phase 1 security issues resolved
- Clear blocking status for insecure endpoints

### 2. **User-Centric MVP Focus**
- Core user workflows validated in Phase 1
- Word Export moved to Phase 2 (essential for safety compliance)
- Advanced admin features deferred to Phase 4

### 3. **Realistic Quality Gates**
- Test cleanup and performance validation required before launch
- Clear acceptance criteria for each phase

### 4. **Proper Risk Assessment**
- Security blockers clearly marked as production-blocking
- Technical debt addressed in pre-launch phase
- Enhancement features properly classified as post-MVP

## Success Metrics 📊

### Phase 1 Success: Security & Core MVP
- All security audits pass
- Core user workflow completes end-to-end
- Smoke tests run successfully

### Phase 2 Success: Feature Complete MVP  
- Users can export photos as Word documents
- Bulk operations improve user efficiency
- Basic admin functions support multi-tenancy

### Phase 3 Success: Launch Ready
- Zero TypeScript errors and ESLint warnings
- Performance benchmarks met
- System stable under expected load

### Phase 4 Success: Enhanced Platform
- Advanced admin tools increase operational efficiency
- AI management console provides deep insights
- Platform scales beyond initial user base

---

## Human Tasks