# Platform AI Management System - Scope and Access Control

## ⚠️ CRITICAL: PLATFORM ADMIN INFRASTRUCTURE TOOL

**THIS IS AN INTERNAL PLATFORM ADMINISTRATION TOOL - NOT FOR END USERS**

## Executive Summary

This document provides explicit scope boundaries and access control requirements for the Platform AI Management System redesign. This system is exclusively for internal platform administration and must never be confused with end-user features.

## Scope Definition

### What This System IS

**Platform Infrastructure Management Tool**
- **Purpose**: Internal tool for platform administrators to manage AI infrastructure
- **Users**: Platform team members ONLY (admins, AI engineers, DevOps)
- **Location**: `/app/platform/ai-management/` (existing platform admin area)
- **Function**: Manages the AI capabilities that end-users consume through the main app
- **Access**: Requires `platform_admin` role in `user_profiles` table

### What This System IS NOT

**End-User Features**
- ❌ NOT a feature for Minerva app users
- ❌ NOT for organization admins or regular users
- ❌ NOT accessible through main app navigation
- ❌ NOT part of end-user photo management workflows
- ❌ NOT integrated into end-user interfaces

**Clear Distinction**
- **End-users** → Use AI features (photo tagging, chat, search) through regular Minerva app
- **Platform admins** → Use this tool to configure and optimize those AI capabilities

## Access Control Requirements

### Primary Access Control

**Role-Based Access**
```sql
-- Required role in user_profiles table
SELECT * FROM user_profiles WHERE role = 'platform_admin'
```

**Authentication Flow**
1. User must be authenticated with Supabase Auth
2. User profile must have `platform_admin` role
3. All API routes validate platform admin access
4. All database queries enforce RLS policies for platform admin access

### Implementation Locations

**Frontend Routes** (Platform Admin Only)
- `/app/platform/ai-management/` - Main dashboard area
- `/app/platform/ai-management/overview` - Global overview
- `/app/platform/ai-management/features` - Feature management
- `/app/platform/ai-management/models` - Model management
- `/app/platform/ai-management/prompts` - Prompt library
- `/app/platform/ai-management/spending` - Cost analytics
- `/app/platform/ai-management/testing` - Testing & experiments

**API Routes** (Platform Admin Only)
- `/api/platform/ai-management/features/` - Feature APIs
- `/api/platform/ai-management/models/` - Model APIs
- `/api/platform/ai-management/providers/` - Provider APIs
- `/api/platform/ai-management/prompts/` - Prompt APIs
- `/api/platform/ai-management/analytics/` - Analytics APIs
- `/api/platform/ai-management/experiments/` - Testing APIs

**Component Structure** (Platform Admin Only)
- `/components/platform/ai-management/` - All platform AI components
- `/lib/services/platform/` - Platform admin services
- `/lib/hooks/platform/` - Platform admin hooks

### Database Security

**Row Level Security Policies**
All tables enforce platform admin access:

```sql
-- Example policy pattern for all AI management tables
CREATE POLICY "ai_features_platform_admin_only" ON ai_features
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.user_id = auth.uid() 
            AND up.role = 'platform_admin'
        )
    );
```

**Protected Tables**
- `ai_features` - AI feature configurations
- `ai_models` - Model catalog and deployments
- `ai_providers` - Provider configurations
- `ai_prompts` - Prompt library
- `ai_usage_logs` - Usage and cost tracking
- `ai_spending_budgets` - Budget management
- `ai_experiments` - A/B testing data
- `feature_model_assignments` - Model-feature mappings

## Integration Boundaries

### Existing Platform Admin Structure

**Current Platform Admin Areas**
- `/app/platform/overview` - Platform overview
- `/app/platform/users` - User management
- `/app/platform/analytics` - Platform analytics
- `/app/platform/settings` - Platform settings
- `/app/platform/ai-management/` - **THIS SYSTEM** (improved)

**Navigation Integration**
- Integrates with existing platform admin sidebar
- Uses existing platform admin layout components
- Follows established platform admin design patterns
- Maintains consistent platform admin authentication

### End-User System Boundaries

**What End-Users See**
- Photo upload with AI tagging (powered by this system's configurations)
- AI chatbot assistance (using models managed by this system)
- AI-powered search results (using search infrastructure managed here)
- **End-users NEVER see the management interface**

**Data Flow**
```
End-User Action → Main App APIs → AI Services → Platform-Configured Models
                                               ↑
                              Platform Admins configure via this system
```

## Security Requirements

### Authentication & Authorization

**Multi-Layer Security**
1. **Route Protection**: Next.js middleware validates platform admin access
2. **API Validation**: Every API endpoint checks platform admin role
3. **Database Policies**: RLS enforces platform admin access at data layer
4. **Component Guards**: React components validate permissions before rendering

**Platform Admin Validation Function**
```typescript
// lib/auth/platform-admin.ts
export async function validatePlatformAdminAccess(
  supabase: SupabaseClient, 
  userId: string
): Promise<boolean> {
  const { data } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('user_id', userId)
    .single();
  
  return data?.role === 'platform_admin';
}
```

### Data Protection

**Sensitive Information Handling**
- API keys encrypted in database
- All configuration changes logged with user attribution
- Platform admin actions audited
- Cost and usage data protected by RLS policies

**Network Security**
- All API calls require authentication
- Rate limiting on platform admin endpoints
- CORS policies restrict access to authorized domains

## Operational Guidelines

### Development Workflow

**When Working on This System**
1. Always work within `/app/platform/ai-management/` directory
2. Use `/api/platform/ai-management/` for API routes
3. Test with platform admin role enabled
4. Verify RLS policies block non-platform-admin access
5. Ensure no end-user navigation links to these routes

**Testing Requirements**
- Unit tests must mock platform admin authentication
- Integration tests verify access control enforcement
- E2E tests use platform admin test accounts
- Security tests verify unauthorized access is blocked

### Deployment Considerations

**Production Deployment**
- Platform admin role must be assigned manually
- No self-service platform admin registration
- Monitor platform admin access patterns
- Alert on unauthorized access attempts

**Environment Configuration**
- Development: Local platform admin accounts for testing
- Staging: Limited platform admin accounts for validation
- Production: Minimal platform admin accounts with audit logging

## Compliance & Auditing

### Audit Requirements

**Activity Logging**
- All platform admin actions logged to `audit_logs` table
- Configuration changes tracked with before/after states
- Cost modifications logged with approver information
- Model deployments tracked with deployment history

**Access Monitoring**
- Platform admin login attempts monitored
- Unusual access patterns flagged
- Regular platform admin access reviews
- Quarterly platform admin role audits

### Compliance Standards

**Data Access**
- Platform admins have access to aggregated usage data only
- Individual user data access limited to necessary operational purposes
- Cost data access restricted to platform finance and admin roles
- AI model performance data accessible for optimization purposes

## Summary

This Platform AI Management System is exclusively an internal infrastructure management tool for platform administrators. It must never be implemented as an end-user feature or made accessible outside the platform admin area. All development, testing, and deployment must maintain strict access control and clear separation from end-user functionality.

**Key Reminders**
- ✅ Platform admin tool for AI infrastructure management
- ✅ Located at `/app/platform/ai-management/`
- ✅ Requires `platform_admin` role for all access
- ✅ Manages AI capabilities consumed by end-users
- ❌ Never accessible to end-users or organization admins
- ❌ Never part of main application navigation
- ❌ Never integrated into end-user workflows