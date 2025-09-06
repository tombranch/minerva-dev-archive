# Phase 2: Critical Infrastructure Implementation Plan
**Target**: Replace critical TODOs with real implementations
**Estimated Time**: 2-3 hours
**Priority**: CRITICAL - Production blockers

## Phase 2A: Email Service Integration (45 minutes)

### Current State
`lib/services/admin/organization-service.ts` lines 268, 271:
```typescript
// TODO: Replace with actual email service integration
// TODO: Add actual email sending logic here
```

### Implementation Plan

#### Step 1: Choose Email Service Provider (5 minutes)
Research and select between:
- **SendGrid** (recommended - reliable, good free tier)
- **Postmark** (developer-friendly)
- **Nodemailer + SMTP** (flexible but more setup)

Use Context7 to get latest documentation for chosen provider.

#### Step 2: Environment Configuration (10 minutes)
Add to environment variables:
```bash
# Email Service Configuration
EMAIL_SERVICE_PROVIDER=sendgrid
SENDGRID_API_KEY=your_sendgrid_api_key
SENDGRID_FROM_EMAIL=noreply@yourdomain.com
SENDGRID_FROM_NAME="Minerva Platform"

# Or for Postmark
POSTMARK_SERVER_TOKEN=your_postmark_token
POSTMARK_FROM_EMAIL=noreply@yourdomain.com
```

#### Step 3: Create Email Service Module (15 minutes)
Create `lib/services/email-service.ts`:
```typescript
interface EmailService {
  sendOrganizationInvitation(params: {
    email: string;
    organizationName: string;
    inviterName: string;
    role: string;
    inviteUrl: string;
  }): Promise<{ success: boolean; messageId?: string }>;
}

export const emailService: EmailService = {
  // Real implementation with chosen provider
}
```

#### Step 4: Update Organization Service (10 minutes)
Replace TODO sections with real email service calls:
```typescript
const result = await emailService.sendOrganizationInvitation({
  email,
  organizationName: org.name,
  inviterName: user.full_name,
  role,
  inviteUrl: `${process.env.NEXT_PUBLIC_SITE_URL}/invite/${inviteCode}`
});

if (!result.success) {
  throw new Error('Failed to send invitation email');
}
```

#### Step 5: Testing (5 minutes)
- Create test invitation
- Verify email delivery
- Test error handling

**Commit**: `feat: implement email service integration for organization invitations`

---

## Phase 2B: API Key Management (45 minutes)

### Current State
`lib/services/admin/organization-service.ts` lines 345, 348:
```typescript
// TODO: Implement key rotation logic with Supabase service role
// TODO: Add actual key reset logic here
```

### Implementation Plan

#### Step 1: Research Supabase Admin API (10 minutes)
Use Context7 to research:
- Supabase Management API for key rotation
- Service role key management
- Security best practices for key rotation

#### Step 2: Create Supabase Admin Client (10 minutes)
Create `lib/supabase-admin.ts`:
```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!, // Full admin access
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

export { supabaseAdmin };
```

#### Step 3: Implement Key Rotation (15 minutes)
Replace TODO with real implementation:
```typescript
// Generate new API keys through Supabase Management API
const rotateApiKeys = async (organizationId: string, keyType: 'anon' | 'service_role') => {
  const managementApi = supabaseAdmin.functions.invoke('rotate-api-keys', {
    body: { organizationId, keyType }
  });

  // Update organization record with new keys
  const { error } = await supabase
    .from('organizations')
    .update({
      [`${keyType}_key`]: newKey,
      key_rotated_at: new Date().toISOString()
    })
    .eq('id', organizationId);

  if (error) throw error;
  return newKey;
};
```

#### Step 4: Add Environment Variables (5 minutes)
```bash
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
SUPABASE_PROJECT_REF=your_project_ref
```

#### Step 5: Testing (5 minutes)
- Test key rotation functionality
- Verify new keys work
- Test error scenarios

**Commit**: `feat: implement Supabase API key rotation with service role integration`

---

## Phase 2C: AI Prompt Service Integration (90 minutes)

### Current State
Multiple files need prompt service integration:
- `components/ai/prompt-manager/PromptHistory.tsx` lines 42, 64
- `components/ai/console/PipelineControl/PromptEditor.tsx` line 308
- `app/api/ai/prompts/[id]/performance/route.ts` lines 63, 64

### Implementation Plan

#### Step 1: Design Prompt Service Architecture (15 minutes)
Create comprehensive prompt service interface:
```typescript
// lib/services/ai-prompt-service.ts
interface PromptService {
  // CRUD operations
  getPrompt(id: string): Promise<Prompt>;
  createPrompt(prompt: CreatePromptRequest): Promise<Prompt>;
  updatePrompt(id: string, updates: UpdatePromptRequest): Promise<Prompt>;
  deletePrompt(id: string): Promise<void>;

  // Version management
  getPromptVersions(id: string): Promise<PromptVersion[]>;
  restorePromptVersion(id: string, versionId: string): Promise<Prompt>;
  createPromptVersion(id: string, content: string): Promise<PromptVersion>;

  // Performance and analytics
  getPromptPerformance(id: string): Promise<PromptPerformance>;
  getPromptUsageStats(id: string): Promise<PromptUsageStats>;
}
```

#### Step 2: Create Database Schema (15 minutes)
Create migration for prompt management:
```sql
-- Create prompts table
CREATE TABLE prompts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  template TEXT NOT NULL,
  organization_id UUID REFERENCES organizations(id),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create prompt_versions table
CREATE TABLE prompt_versions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  prompt_id UUID REFERENCES prompts(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  template TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create prompt_performance table
CREATE TABLE prompt_performance (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  prompt_id UUID REFERENCES prompts(id) ON DELETE CASCADE,
  usage_count INTEGER DEFAULT 0,
  success_rate DECIMAL(5,2) DEFAULT 0,
  avg_response_time INTEGER DEFAULT 0,
  last_used_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Step 3: Implement Prompt Service (30 minutes)
Create real implementation with Supabase integration:
```typescript
export const aiPromptService: PromptService = {
  async getPrompt(id: string): Promise<Prompt> {
    const { data, error } = await supabase
      .from('prompts')
      .select('*, prompt_versions(*)')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  },

  async getPromptVersions(id: string): Promise<PromptVersion[]> {
    const { data, error } = await supabase
      .from('prompt_versions')
      .select('*')
      .eq('prompt_id', id)
      .order('version_number', { ascending: false });

    if (error) throw error;
    return data;
  },

  async getPromptPerformance(id: string): Promise<PromptPerformance> {
    const { data, error } = await supabase
      .from('prompt_performance')
      .select('*')
      .eq('prompt_id', id)
      .single();

    if (error) throw error;
    return data;
  }

  // ... implement remaining methods
};
```

#### Step 4: Update API Endpoints (15 minutes)
Replace mock implementations in:
- `app/api/ai/prompts/[id]/route.ts`
- `app/api/ai/prompts/[id]/performance/route.ts`

```typescript
// GET /api/ai/prompts/[id]/performance/route.ts
export async function GET(request: Request, { params }: { params: { id: string } }) {
  try {
    const performance = await aiPromptService.getPromptPerformance(params.id);
    const prompt = await aiPromptService.getPrompt(params.id);

    return NextResponse.json({
      promptName: prompt.name,
      promptVersion: prompt.version_number,
      usageCount: performance.usage_count,
      successRate: performance.success_rate,
      avgResponseTime: performance.avg_response_time
    });
  } catch (error) {
    return createErrorResponse('Failed to fetch prompt performance', 500);
  }
}
```

#### Step 5: Update Components (10 minutes)
Replace TODO comments with real service calls:
```typescript
// components/ai/prompt-manager/PromptHistory.tsx
const loadVersions = async () => {
  try {
    setLoading(true);
    const data = await aiPromptService.getPromptVersions(prompt.id);
    setVersions(data);
  } catch (error) {
    console.error('Failed to load prompt versions:', error);
  } finally {
    setLoading(false);
  }
};

// components/ai/console/PipelineControl/PromptEditor.tsx
const currentUserId = useAuth().user?.id || 'anonymous';
```

#### Step 6: Testing (5 minutes)
- Test prompt CRUD operations
- Test version history functionality
- Test performance metrics retrieval

**Commit**: `feat: implement comprehensive AI prompt service with version history and performance tracking`

---

## Quality Gates for Phase 2

### Before Implementation
- [ ] All environment variables documented
- [ ] Database migration scripts created
- [ ] Service interfaces properly typed

### During Implementation
- [ ] Each step maintains existing functionality
- [ ] Proper error handling added
- [ ] TypeScript strict mode compliance
- [ ] No `any` types introduced

### After Implementation
- [ ] All TODOs in Phase 2 files removed
- [ ] Unit tests added for new services
- [ ] Integration tests pass
- [ ] Manual testing completed

### Success Criteria
- ✅ Organization invitations send real emails
- ✅ API key rotation works with Supabase
- ✅ Prompt service fully functional with database persistence
- ✅ All placeholder implementations replaced
- ✅ Zero TODO comments in Phase 2 files

**Next Phase**: Phase 3 - Replace remaining placeholder implementations