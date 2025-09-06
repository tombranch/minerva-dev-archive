# TODO Implementation Guide - Phase 2

**Project**: Fix All Validation Issues - Phase 2  
**Created**: 2025-08-31 15:55:00  
**Phase 1 Complete**: Sessions 1-6 (99.7% TypeScript error reduction)  
**Phase 2 Target**: 26 TODOs → Complete functional implementation  
**Sessions**: 7 (Convex), 8 (Clerk), 9 (Validation)

## 🎯 Phase 2 Overview

**Current State**: 26 strategic TODO placeholders added during Phase 1 cleanup  
**Goal**: Convert all TODOs to functional implementations for production readiness  
**Architecture**: Complete Supabase → Convex (database) + Clerk (auth) migration  

### TODO Distribution
- **17 Convex TODOs**: Database queries, mutations, data operations
- **9 Clerk TODOs**: Authentication, user management, admin features
- **Target Duration**: 90-110 minutes total (3 focused sessions)

---

## 🗄️ Session 7: Convex Database Implementation (17 TODOs)

**Duration**: 30-40 minutes  
**Target**: Convert all database operations to Convex  
**Impact**: Functional admin features, AI analytics, profile management

### Admin API Routes (5 Convex TODOs)

#### 1. `app/api/admin/users/route.ts` (Priority: HIGH)
**Current TODO**: 
```typescript
// TODO: Replace with Convex user queries
const users: unknown[] = [];
return createNextSuccessResponse(users);
```

**Implementation Required**:
- Replace with Convex user query: `api.users.list`
- Add organization filtering: `{ organizationId }`
- Add pagination support: `{ limit, offset }`
- Add user role filtering
- Add search functionality

**Expected Code Pattern**:
```typescript
const convexUsers = await convex.query(api.users.list, {
  organizationId: user.organizationId,
  limit: parseInt(limit as string) || 50,
  offset: parseInt(offset as string) || 0,
  searchTerm: search as string,
});
```

#### 2. `app/api/admin/users/bulk/route.ts` (Priority: HIGH)
**Current TODO**: 
```typescript
// TODO: Replace with Convex batch user operations
const result = { success: true, updated: 0 };
return createNextSuccessResponse(result);
```

**Implementation Required**:
- Batch user operations: invite, update roles, deactivate
- Use Convex mutations for bulk operations
- Add transaction support for data consistency
- Add proper error handling for partial failures

**Expected Code Pattern**:
```typescript
const results = await Promise.allSettled(
  userIds.map(userId => 
    convex.mutation(api.users.updateRole, { userId, role })
  )
);
```

#### 3. `app/api/admin/users/export/route.ts` (Priority: MEDIUM)
**Current TODO**: Export user data with Convex queries

#### 4. `app/api/admin/users/invite/route.ts` (Priority: HIGH)
**Current TODO**: User invitation system with Convex

#### 5. `app/api/admin/users/analytics/route.ts` (Priority: MEDIUM)
**Current TODO**: User analytics and reporting with Convex aggregations

### AI API Routes (6 Convex TODOs)

#### 6. `app/api/ai/add-tag/route.ts` (Priority: HIGH)
**Current TODO**:
```typescript
// TODO: Replace with Convex photo tagging
const result = { success: true, tagId: 'mock' };
return createNextSuccessResponse(result);
```

**Implementation Required**:
- Photo tagging with Convex mutations
- Add tag to photo: `api.photos.addTag`
- Update AI confidence scores
- Track tagging history

#### 7. `app/api/ai/analytics/accuracy-trends/route.ts` (Priority: MEDIUM)
**Current TODO**: AI accuracy trend analysis with Convex

#### 8. `app/api/ai/analytics/enhanced/route.ts` (Priority: MEDIUM)
**Current TODO**: Enhanced AI analytics with Convex aggregations

#### 9. `app/api/ai/analytics/optimization-recommendations/route.ts` (Priority: LOW)
**Current TODO**: AI optimization recommendations with Convex

#### 10. `app/api/ai/analytics/processing-efficiency/route.ts` (Priority: MEDIUM)
**Current TODO**: Processing efficiency tracking with Convex

#### 11. Additional AI route (Priority: LOW)
**Current TODO**: Additional Convex integration

### Profile & Component TODOs (6 Convex TODOs)

#### 12. `app/(protected)/profile/setup/page.tsx` (Priority: HIGH)
**Current TODO**:
```typescript
// TODO: Replace with Convex user creation
console.log("Profile creation - migrating to Convex:", userData);
```

**Implementation Required**:
- Create user profile with Convex mutation
- Handle organization assignment
- Profile data validation and sanitization
- Success/error state management

**Expected Code Pattern**:
```typescript
const createProfile = useMutation(api.users.create);
await createProfile({
  email: userData.email,
  firstName: userData.firstName,
  lastName: userData.lastName,
  organizationId: userData.organizationId,
  role: "engineer"
});
```

#### 13-17. Additional Profile/Upload TODOs (Priority: MEDIUM-LOW)
- Photo upload integration with Convex
- Profile update operations
- Organization switching
- Data synchronization
- Progress tracking

---

## 🔐 Session 8: Clerk Authentication Implementation (9 TODOs)

**Duration**: 25-35 minutes  
**Target**: Complete all authentication and admin features  
**Impact**: Functional admin panels, user feedback, authentication flows

### Authentication Layer (4 Clerk TODOs)

#### 18. `lib/auth-middleware.ts` (Priority: HIGH)
**Current State**: Core validateSession implemented, but needs completion
**Current TODO**: Complete Clerk session handling

**Implementation Required**:
- Enhanced user role validation
- Organization context validation
- Permission checking middleware
- Error handling improvements

#### 19. `components/feedback/feedback-dropdown.tsx` (Priority: MEDIUM)
**Current TODO**:
```typescript
// TODO: Replace with Clerk authentication and Convex storage
console.log("Feedback submission - migrating to Convex:", {...});
```

**Implementation Required**:
- Get user context from Clerk
- Submit feedback to Convex
- User identification and organization context
- Success/error feedback to user

**Expected Code Pattern**:
```typescript
const { user } = useAuth();
const submitFeedback = useMutation(api.feedback.create);

await submitFeedback({
  userId: user.id,
  organizationId: user.organizationId,
  message: feedbackData.message,
  type: feedbackData.type,
});
```

#### 20-21. Additional Authentication TODOs (Priority: MEDIUM)
- Profile management with Clerk
- Organization switching with Clerk context

### Admin Pages (5 Clerk TODOs)

#### 22. `app/(protected)/admin/feedback/page.tsx` (Priority: MEDIUM)
**Current TODO**:
```typescript
// TODO: Replace with Clerk authentication
const user = null; // Mock during migration
```

**Implementation Required**:
- Get authenticated user from Clerk
- Validate admin permissions
- Load feedback data from Convex
- Admin-only interface functionality

**Expected Code Pattern**:
```typescript
const { user } = useAuth();
const { data: feedbacks } = useQuery(api.feedback.list, {
  organizationId: user.organizationId
});

if (!hasAdminAccess(user)) {
  return <UnauthorizedPage />;
}
```

#### 23. `app/(protected)/admin/invitations/page.tsx` (Priority: HIGH)
**Current TODO**: Clerk admin authentication for invitations management

#### 24. `app/(protected)/admin/layout.tsx` (Priority: HIGH)
**Current TODO**: Clerk admin authentication for layout protection

#### 25. `app/(protected)/admin/organization/page.tsx` (Priority: MEDIUM)  
**Current TODO**: Clerk admin authentication for organization management

#### 26. `app/(protected)/admin/users/page.tsx` (Priority: HIGH)
**Current TODO**: Clerk admin authentication for user management

---

## 🧪 Session 9: Final Production Validation (0 TODOs)

**Duration**: 15-20 minutes  
**Target**: Validate 100% TODO completion and production readiness  
**Validation**: End-to-end testing, build verification, deployment readiness

### Validation Checklist
- [ ] Search codebase for remaining TODO comments (should be 0)
- [ ] TypeScript validation: `pnpm run typecheck` (should be 0 errors)
- [ ] Production build: `pnpm run build` (should succeed)
- [ ] Test suite: `pnpm run test` (all tests passing)
- [ ] Validation suite: `pnpm run validate:all` (should be 100%)

### Critical User Workflows
- [ ] User authentication and organization access
- [ ] Photo upload and AI processing
- [ ] Admin user management
- [ ] AI analytics and reporting
- [ ] Profile management and feedback systems

---

## 📋 Implementation Priority Matrix

### Session 7 Priority Ranking (Convex TODOs)
**HIGH Priority (Must Complete)**:
1. `app/api/admin/users/route.ts` - Core user management
2. `app/api/admin/users/bulk/route.ts` - Bulk operations
3. `app/api/admin/users/invite/route.ts` - User invitations  
4. `app/api/ai/add-tag/route.ts` - Photo tagging functionality
5. `app/(protected)/profile/setup/page.tsx` - Profile creation

**MEDIUM Priority (Should Complete)**:
6. Admin user analytics and export
7. AI analytics routes (3-4 routes)
8. Profile management components

**LOW Priority (Nice to Have)**:  
9. AI optimization recommendations
10. Additional profile/upload features

### Session 8 Priority Ranking (Clerk TODOs)
**HIGH Priority (Must Complete)**:
1. `lib/auth-middleware.ts` - Core authentication
2. `app/(protected)/admin/invitations/page.tsx` - Admin invitations
3. `app/(protected)/admin/layout.tsx` - Admin layout protection
4. `app/(protected)/admin/users/page.tsx` - User management

**MEDIUM Priority (Should Complete)**:
5. `components/feedback/feedback-dropdown.tsx` - User feedback
6. `app/(protected)/admin/feedback/page.tsx` - Feedback management
7. `app/(protected)/admin/organization/page.tsx` - Organization management

---

## 🔧 Implementation Patterns

### Convex Integration Patterns

#### Query Pattern
```typescript
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

const { data, isLoading, error } = useQuery(api.tableName.functionName, {
  organizationId: user.organizationId,
  // other parameters
});
```

#### Mutation Pattern
```typescript
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

const createItem = useMutation(api.tableName.create);

const handleSubmit = async (data) => {
  try {
    await createItem({
      organizationId: user.organizationId,
      ...data
    });
  } catch (error) {
    console.error("Failed to create item:", error);
  }
};
```

### Clerk Integration Patterns

#### Authentication Check Pattern
```typescript
import { useAuth } from "@clerk/nextjs";

const { user, isLoaded, isSignedIn } = useAuth();

if (!isLoaded) return <LoadingSpinner />;
if (!isSignedIn) return <RedirectToLogin />;

// Use user.id, user.organizationId, etc.
```

#### Permission Check Pattern
```typescript
import { hasPermission } from "@/lib/services/clerk-auth-service-client";

const canManageUsers = hasPermission(user, "manage_users");
const canAccessAdmin = hasPermission(user, "admin_access");

if (!canAccessAdmin) {
  return <UnauthorizedPage />;
}
```

---

## ⚠️ Critical Dependencies & Risks

### Convex Schema Dependencies
- Ensure Convex schema includes all required tables: `users`, `photos`, `feedback`
- Verify organization-scoped data access patterns
- Confirm mutation permissions and validation

### Clerk Configuration Dependencies
- Verify Clerk metadata fields: `role`, `organizationId`
- Confirm permission-based access control
- Test organization switching functionality

### Build Dependencies
- Validate that all TODO replacements maintain TypeScript compliance
- Ensure proper error handling patterns
- Test build process after each major TODO completion

---

## 🚀 Getting Started with Phase 2

### Pre-Session Setup
```bash
cd /home/tom-branch/dev/projects/minerva/convex-feature-migration
pnpm run typecheck  # Should show ~5 errors (all TODO-related)
```

### Session 7 Execution
```bash
/clear  # Clear context for focused session
# Begin with high-priority admin routes
# Focus on user management and photo tagging
# Test each implementation incrementally
```

### Session 8 Execution  
```bash
/clear  # Clear context for focused session
# Begin with auth middleware completion
# Focus on admin page authentication
# Test authentication flows
```

### Session 9 Validation
```bash
# Final validation suite
pnpm run validate:all  # Target: 100% pass rate
pnpm run build  # Should complete successfully
```

---

**Created**: 2025-08-31 15:55:00  
**Maintained By**: Claude Code Planning  
**Next Update**: After Session 7 completion  

*This guide provides the complete roadmap for implementing all 26 TODOs added during Phase 1, achieving 100% production readiness.*