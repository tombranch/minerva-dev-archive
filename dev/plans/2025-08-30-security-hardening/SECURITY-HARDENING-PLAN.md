# Security Hardening - Session Implementation Plan

**Total Duration**: 2-2.5 hours across 6 sessions
**Objective**: Address 5 critical security vulnerabilities to achieve 100% production readiness
**Status**: 📋 Planning Complete - Ready for Implementation
**Approach**: Session-based implementation (10-20 min focused sessions)

## 🎯 Executive Summary

Following the comprehensive production review report, this plan addresses **5 critical security vulnerabilities** that are blocking production deployment. The implementation uses a proven session-based approach to systematically address authorization bypasses, input validation gaps, and testing infrastructure issues.

### Critical Security Issues Identified
1. **Authorization Bypass Vulnerability** - Any authenticated user can access any photo by ID
2. **Export Authorization Bypass** - Users can export data from organizations they don't belong to  
3. **API Credential Exposure** - Google Cloud credentials processed insecurely
4. **Missing Input Validation** - Insufficient validation in AI processing pipeline
5. **Testing Infrastructure Broken** - Vitest configuration errors preventing test execution

## 📊 Success Metrics

### Technical Success Criteria
- [ ] Zero authorization bypass vulnerabilities remaining
- [ ] All organization-scoped operations properly validated
- [ ] Input validation comprehensive for file uploads
- [ ] API credentials handled securely
- [ ] Testing infrastructure functional with security tests
- [ ] Generic error messages implemented (no information disclosure)

### Security Success Criteria  
- [ ] Authorization Coverage: 100% (from 40%)
- [ ] Input Validation Coverage: 95% (from 30%)
- [ ] Error Security: 100% (from 60% - no information disclosure)
- [ ] Access Control: 100% (from 50% - complete organization scoping)

### Quality Gates
- [ ] All TypeScript errors resolved
- [ ] Security audit passes with 90%+ coverage
- [ ] Test suite executes successfully
- [ ] Production deployment approved

## 🗓️ Session Timeline

### Session 1: Authorization Framework (20 mins) - Foundation Security
**Objective**: Create reusable authorization helpers for organization-scoped operations

### Session 2: Secure Core Functions (20 mins) - Photo Access Control
**Objective**: Fix critical authorization bypass in photos.ts functions

### Session 3: Export Security (20 mins) - Data Protection
**Objective**: Secure data export functions with proper access controls

### Session 4: Input Validation & AI Security (20 mins) - Processing Security
**Objective**: Secure file uploads and AI credential handling

### Session 5: Testing Infrastructure (15 mins) - Quality Assurance
**Objective**: Fix Vitest configuration and enable security testing

### Session 6: Error Handling & Final Validation (15 mins) - Information Security
**Objective**: Secure error responses and conduct final security audit

## 🏗️ Session-Based Implementation Guide

### Session 1: Authorization Framework (20 minutes)
**Status**: 📋 **READY TO START**
**Duration**: 20 minutes
**Objective**: Implement comprehensive authorization helpers

#### Session Workflow:
- [ ] **EXPLORE** (3 mins): Review current helpers.ts and identify authorization patterns
- [ ] **PLAN** (5 mins): Design authorization helper functions and validation logic
- [ ] **CODE** (10 mins): Implement validateOrganizationAccess and related helpers
- [ ] **COMMIT** (2 mins): Validate TypeScript, commit with security message

#### Session Tasks:
- [ ] Implement `validateOrganizationAccess` core validation function
- [ ] Add `getCurrentUserWithOrganization` for user/org retrieval
- [ ] Create `ensureOrganizationAccess` simplified validation helper
- [ ] Add `validatePhotoOwnership` for photo-specific access control
- [ ] Implement proper error messages for authorization failures

#### Files to Modify:
- `convex/helpers.ts` - Add authorization validation functions

#### Success Criteria:
- [ ] Authorization helpers implemented with proper typing
- [ ] Error messages provide security without information disclosure
- [ ] TypeScript compilation passes
- [ ] Clean commit with descriptive security message

#### Context Management:
- [ ] **Use /clear if switching from unrelated work**
- [ ] **Session fits comfortably within context window**
- [ ] **TodoWrite updated with progress**

---

### Session 2: Secure Core Functions (20 minutes)
**Status**: 📋 **READY TO START**
**Duration**: 20 minutes
**Objective**: Fix authorization bypass vulnerabilities in photos.ts

#### Session Workflow:
- [ ] **EXPLORE** (3 mins): Review photos.ts functions and identify vulnerable endpoints
- [ ] **PLAN** (5 mins): Map authorization requirements for each function
- [ ] **CODE** (10 mins): Implement organization validation in critical functions
- [ ] **COMMIT** (2 mins): Test functions, validate security, commit changes

#### Session Tasks:
- [ ] Fix `getById` function authorization bypass (convex/photos.ts:226-238)
- [ ] Add organization validation to `update` function
- [ ] Secure `deletePhoto` function with proper ownership checks
- [ ] Update other photo management functions with authorization
- [ ] Implement consistent error handling patterns

#### Vulnerable Code to Fix:
```typescript
// BEFORE (VULNERABLE)
export const getById = query({
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Authentication required");
    
    // ❌ MISSING: Organization membership validation
    return await ctx.db.get(args.id);
  },
});

// AFTER (SECURE) - Use new helpers
export const getById = query({
  handler: async (ctx, args) => {
    const { photo } = await validatePhotoOwnership(ctx, args.id);
    return photo;
  },
});
```

#### Files to Modify:
- `convex/photos.ts` - Add authorization to getById, update, deletePhoto functions

#### Success Criteria:
- [ ] All photo functions require proper authorization
- [ ] Users can only access photos within their organization
- [ ] Error messages are secure and consistent
- [ ] TypeScript compilation passes without errors

---

### Session 3: Export Security (20 minutes)
**Status**: 📋 **READY TO START**  
**Duration**: 20 minutes
**Objective**: Secure data export functions with access controls and XSS protection

#### Session Workflow:
- [ ] **EXPLORE** (3 mins): Review export.ts functions and identify security gaps
- [ ] **PLAN** (5 mins): Design organization access validation for exports
- [ ] **CODE** (10 mins): Implement authorization and output sanitization
- [ ] **COMMIT** (2 mins): Test export security, validate implementation

#### Session Tasks:
- [ ] Fix `exportPhotos` authorization bypass (convex/export.ts:59-84)
- [ ] Add organization membership validation to all export functions
- [ ] Implement rate limiting for export operations
- [ ] Add XSS protection for HTML report generation
- [ ] Sanitize CSV output to prevent injection attacks

#### Vulnerable Code to Fix:
```typescript
// BEFORE (VULNERABLE)  
export const exportPhotos = mutation({
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Authentication required");
    
    // ❌ MISSING: Organization access validation
    const photos = await ctx.db.query("photos")
      .withIndex("by_organization", (q) => q.eq("organizationId", args.organizationId))
      .collect();
  },
});

// AFTER (SECURE)
export const exportPhotos = mutation({
  handler: async (ctx, args) => {
    await ensureOrganizationAccess(ctx, args.organizationId);
    // Now safe to proceed with export...
  },
});
```

#### Files to Modify:
- `convex/export.ts` - Add authorization to exportPhotos and related functions

#### Success Criteria:  
- [ ] Users can only export data from their own organization
- [ ] Export functions include rate limiting protection
- [ ] HTML/CSV output is properly sanitized
- [ ] Authorization errors provide secure messages

---

### Session 4: Input Validation & AI Security (20 minutes)
**Status**: 📋 **READY TO START**
**Duration**: 20 minutes  
**Objective**: Secure file uploads and AI credential handling

#### Session Workflow:
- [ ] **EXPLORE** (3 mins): Review AI processing pipeline and credential handling
- [ ] **PLAN** (5 mins): Design file validation and secure credential patterns
- [ ] **CODE** (10 mins): Implement validation middleware and secure credentials
- [ ] **COMMIT** (2 mins): Test file processing security, validate changes

#### Session Tasks:
- [ ] Implement file type and size validation for uploads
- [ ] Add image format verification for AI processing
- [ ] Secure Google Cloud credential handling (convex/aiProcessing.ts:758-768)
- [ ] Add input sanitization for file metadata
- [ ] Implement proper validation error responses

#### Vulnerable Code to Fix:
```typescript
// BEFORE (VULNERABLE)
const credentials = {
  private_key: process.env.GOOGLE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
  client_email: process.env.GOOGLE_CLIENT_EMAIL,
  // ❌ RISK: Plain text processing of sensitive data
};

// AFTER (SECURE) - Add validation and secure handling
const credentials = validateAndSecureCredentials({
  private_key: process.env.GOOGLE_PRIVATE_KEY,
  client_email: process.env.GOOGLE_CLIENT_EMAIL,
});
```

#### Files to Modify:
- `convex/aiProcessing.ts` - Secure credential handling
- `convex/files.ts` - Add file upload validation  
- `lib/ai/providers/google-vision.ts` - Input validation for AI processing

#### Success Criteria:
- [ ] File uploads validate type, size, and format
- [ ] API credentials handled securely without exposure risk
- [ ] Malicious file processing prevented
- [ ] Proper validation error messages implemented

---

### Session 5: Testing Infrastructure (15 minutes)
**Status**: 📋 **READY TO START**
**Duration**: 15 minutes
**Objective**: Fix Vitest configuration and enable security testing

#### Session Workflow:
- [ ] **EXPLORE** (2 mins): Analyze Vitest ESM/CJS compatibility error
- [ ] **PLAN** (3 mins): Design configuration fix and security test approach
- [ ] **CODE** (8 mins): Fix configuration and add basic security tests
- [ ] **COMMIT** (2 mins): Validate test execution, commit infrastructure fix

#### Session Tasks:  
- [ ] Fix Vitest ESM/CJS compatibility issues in vitest.config.ts
- [ ] Resolve `@vitejs/plugin-react` configuration problem
- [ ] Create basic authorization tests for new helpers
- [ ] Add security-focused test cases for vulnerable functions  
- [ ] Ensure test suite executes successfully

#### Configuration Issue to Fix:
```
Error [ERR_REQUIRE_ESM]: require() of ES Module /home/tom-branch/dev/projects/minerva/convex-feature-migration/node_modules/vite/dist/node/index.js from /home/tom-branch/dev/projects/minerva/convex-feature-migration/node_modules/@vitejs/plugin-react/dist/index.cjs not supported.
```

#### Files to Modify:
- `vitest.config.ts` - Fix ESM/CJS compatibility
- `tests/security/` - Add basic authorization tests (new directory)

#### Success Criteria:
- [ ] Test suite executes without configuration errors
- [ ] Basic security tests pass for authorization helpers
- [ ] Coverage reports generate successfully
- [ ] Foundation for comprehensive security testing established

---

### Session 6: Error Handling & Final Validation (15 minutes)
**Status**: 📋 **READY TO START**
**Duration**: 15 minutes
**Objective**: Secure error responses and conduct final security audit

#### Session Workflow:
- [ ] **EXPLORE** (2 mins): Review error handling patterns across functions
- [ ] **PLAN** (3 mins): Design secure error response strategy
- [ ] **CODE** (8 mins): Implement secure error handling, final validation
- [ ] **COMMIT** (2 mins): Security audit, comprehensive validation, final commit

#### Session Tasks:
- [ ] Replace detailed error messages with secure generic responses
- [ ] Implement proper internal logging for debugging
- [ ] Conduct final security audit of all modified functions
- [ ] Validate all TypeScript types and compilation
- [ ] Run comprehensive test suite

#### Error Security Patterns:
```typescript
// BEFORE (INFORMATION DISCLOSURE)
throw new Error(`Photo not found with ID: ${photoId} in organization ${orgId}`);

// AFTER (SECURE)  
throw new Error("Access denied: Resource not found");
// Log internally: logger.warn("Photo access attempt", { photoId, userId, orgId });
```

#### Files to Modify:
- Multiple Convex files - Update error messages
- Add logging configuration for internal security monitoring

#### Success Criteria:
- [ ] All error messages secure (no sensitive information disclosed)
- [ ] Internal logging implemented for security monitoring
- [ ] Complete security audit passes
- [ ] All 5 critical security issues resolved
- [ ] Production deployment approved

## 🧠 Session Management Protocol

### Context Window Management
- **200K token limit**: Avoid using final 20% for complex tasks
- **Use /clear between sessions**: Especially when switching contexts
- **Reference this plan**: Instead of repeating context between sessions
- **Monitor token usage**: Proactively manage approaching limits

### Session Execution Protocol
- **Before Session**: Use /clear if continuing from unrelated work, check TodoWrite
- **During Session**: Follow EXPLORE → PLAN → CODE → COMMIT structure  
- **After Session**: Commit changes, update TodoWrite, clear context if switching

### Quality Assurance Integration
- **Test incrementally**: Don't wait until session end
- **Validate types continuously**: Run TypeScript checks during development
- **Security validation**: Test authorization after each critical change
- **Document handoffs**: Clear notes between sessions for security context

## 🔄 Getting Started

### Prerequisites
1. Review and approve this plan
2. Ensure development environment is ready (`pnpm` configured)
3. Create security hardening branch: `git checkout -b security-hardening-fixes`
4. Clear context if needed: Use `/clear` before starting

### Session 1 Kickoff
1. Reference this plan document (don't repeat in context)
2. Update TodoWrite with Session 1 progress
3. Begin with EXPLORE phase - review `convex/helpers.ts`
4. Follow Session 1 workflow exactly as documented above

### Emergency Rollback Plan
If any session introduces breaking changes:
1. `git reset --hard HEAD~1` (rollback last commit)
2. Review session plan for issues
3. Restart session with corrected approach
4. Document lessons learned in session tracker

## 🔐 Security Validation Checklist

### Pre-Implementation
- [ ] All vulnerable code locations identified
- [ ] Authorization patterns designed
- [ ] Input validation requirements documented
- [ ] Error handling strategy defined

### Post-Implementation  
- [ ] Authorization bypass vulnerabilities resolved
- [ ] Organization-scoped access controls implemented
- [ ] Input validation comprehensive
- [ ] API credentials secured
- [ ] Testing infrastructure functional
- [ ] Error messages secure (no information disclosure)
- [ ] Production deployment approved

## 📋 Risk Mitigation

### Session-Level Risks
- **Context overflow**: Use /clear between sessions, reference plan document
- **Breaking changes**: Test incrementally, have rollback plan ready
- **Time overrun**: Strict 20-minute session limits, move incomplete work to next session

### Security Implementation Risks
- **Authorization gaps**: Comprehensive review of all organization-scoped operations
- **Performance impact**: Validate authorization helpers don't slow critical paths
- **User experience**: Ensure error messages are helpful while remaining secure

### Integration Risks
- **Testing conflicts**: Separate security tests from existing test infrastructure
- **Deployment issues**: Full validation before production deployment
- **Rollback complexity**: Each session creates clean commit points for rollback

---

**Planning Completed**: August 30, 2025  
**Implementation Target**: 2-2.5 hours total across 6 sessions  
**Success Target**: 100% production readiness achieved  
**Maintained By**: Claude Code - Session-Based Development System

---

*This plan provides a comprehensive, session-based approach to resolving all critical security vulnerabilities while maintaining code quality and ensuring production readiness. Each session is designed for autonomous execution with clear boundaries and commit points.*