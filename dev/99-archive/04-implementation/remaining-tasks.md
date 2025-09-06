# Remaining Tasks - Minerva Project

Generated: 2025-07-27

## 🚨 Critical Issues (Priority 1)

### 1. Fix Queue Status JSON Parsing Error
**File**: `app/api/ai/queue-status/[organizationId]/route.ts:120`
**Error**: `SyntaxError: Unexpected end of JSON input`
**Fix**: The `queue_items` field is already JSONB in the database, no need to parse
```typescript
// Change from:
const queue = queueStatus?.queue_items ? JSON.parse(queueStatus.queue_items) : [];
// To:
const queue = queueStatus?.queue_items || [];
```

### 2. Create Missing Database Table
**Error**: `relation "public.organization_settings" does not exist`
**Fix**: Create migration for `organization_settings` table or update API to use existing tables

### 3. Fix SSE Controller State Error
**File**: `app/api/ai/dashboard/events/route.ts:45`
**Error**: `TypeError: Invalid state: Controller is already closed`
**Fix**: Add controller state check before enqueuing messages

### 4. Fix Undefined Variable in ExperimentManager
**File**: `components/ai/console/TestingLab/ExperimentManager.tsx`
**Error**: `ReferenceError: experimentsData is not defined`
**Fix**: Ensure proper data initialization or default values

## 🔧 TypeScript Issues (Priority 2)

### Type Safety Violations (256+ occurrences)
See `typescript-safety-audit.md` for detailed breakdown:
- **Critical**: 51 files with `any` types
- **Focus Areas**:
  - API route handlers (highest risk)
  - Component props
  - External library integrations
  - Test files

### Specific TypeScript Errors to Fix:
1. **photos/page-simplified.tsx**:
   - `projectIds` property doesn't exist (should be `projectId`)
   - Missing `isOpen` prop in PhotoDetailModal
   - Type mismatches in filters object

2. **Test Files**:
   - Missing mock implementations
   - Implicit `any` parameters
   - Property mismatches in test factories

## 🧪 Test Failures (Priority 3)

### Failing Test Suites:
1. **AI Management E2E Tests**
   - Playwright configuration issue with beforeEach
   
2. **Performance Tests**
   - Large dataset tests timing out
   - Mock data not matching expected structures

3. **Security Tests**
   - Authentication test expecting 401 but getting 200

## 📝 TODO Comments (Priority 4)

### High Priority TODOs:
1. **Email Service** (`lib/email-service.ts`)
   - Install and configure nodemailer
   
2. **User Activity Tracking** (`app/api/platform/users/[id]/route.ts`)
   - Implement last_seen_at tracking

3. **AI Processing Priority** (`app/api/ai/dashboard/queue-status/route.ts`)
   - Implement priority system for queue items

### Medium Priority TODOs:
- Cost optimization calculations
- Retry attempt tracking
- Historical data calculations for trends
- Admin role checks for sensitive endpoints

## 🚀 Performance Optimizations

1. **SSE/WebSocket Performance**
   - Implement connection pooling
   - Add heartbeat mechanism
   - Handle reconnection gracefully

2. **Database Query Optimization**
   - Add indexes for frequent queries
   - Implement query result caching
   - Optimize N+1 queries in photo fetching

## 🔒 Security Enhancements

1. **Authentication**
   - Add CSRF token validation
   - Implement rate limiting on auth endpoints
   - Add session timeout handling

2. **Data Validation**
   - Add input sanitization
   - Implement proper error boundaries
   - Add request validation middleware

## 📦 Deployment Preparation

1. **Environment Configuration**
   - Verify all environment variables
   - Update production database migrations
   - Configure monitoring and logging

2. **Build Optimization**
   - Fix remaining build warnings
   - Optimize bundle sizes
   - Configure CDN for static assets

## 🎯 Next Sprint Priorities

1. **Week 1**: Fix critical runtime errors (Priority 1)
2. **Week 2**: Address TypeScript safety issues (Priority 2)
3. **Week 3**: Fix failing tests and implement missing features (Priority 3-4)

## 📊 Metrics to Track

- Error rate reduction
- TypeScript coverage improvement
- Test suite pass rate
- Performance benchmarks
- User experience metrics

---

**Note**: This list is based on the debugging session completed on 2025-07-27. Update priorities based on user feedback and production monitoring.