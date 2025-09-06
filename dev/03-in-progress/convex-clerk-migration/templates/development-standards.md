# Development Standards & Templates

**Document Purpose**: Standardized patterns, templates, and best practices for the Convex + Clerk migration
**Audience**: Development team (Claude Code + Human oversight)
**Maintenance**: Update as patterns evolve during migration

---

## 🏗️ Code Templates & Patterns

### Convex Schema Template

**File**: `convex/schema.ts`
```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // Base table template with organization isolation
  [TABLE_NAME]: defineTable({
    // Required fields for all tables
    organization_id: v.string(),
    created_at: v.number(),
    updated_at: v.number(),
    created_by: v.string(),

    // Table-specific fields
    name: v.string(),
    description: v.optional(v.string()),
    is_active: v.boolean(),

    // Metadata
    metadata: v.optional(v.object({
      // Define specific metadata structure
    })),
  })
    // Required indexes for performance
    .index("by_organization", ["organization_id"])
    .index("by_created_at", ["created_at"])
    .index("by_active", ["is_active"])
    // Add table-specific indexes
    .searchIndex("search_[TABLE_NAME]", {
      searchField: "name",
      filterFields: ["organization_id", "is_active"]
    }),
});
```

### Convex Query Function Template

**File**: `convex/[feature].ts`
```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";

export const get[FeatureName] = query({
  args: {
    organizationId: v.string(),
    // Add specific query parameters
  },
  handler: async (ctx, args) => {
    // Authentication check (required for all queries)
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    // Authorization check (organization-based)
    const hasAccess = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerk_user_id", identity.subject))
      .filter((q) => q.eq(q.field("organization_id"), args.organizationId))
      .unique();

    if (!hasAccess) {
      throw new Error("Not authorized for this organization");
    }

    // Query execution
    return await ctx.db
      .query("[table_name]")
      .withIndex("by_organization", (q) =>
        q.eq("organization_id", args.organizationId)
      )
      .filter((q) => q.eq(q.field("is_active"), true))
      .order("desc")
      .collect();
  },
});
```

### Convex Mutation Function Template

**File**: `convex/[feature].ts`
```typescript
import { mutation } from "./_generated/server";
import { v } from "convex/values";

export const create[FeatureName] = mutation({
  args: {
    organizationId: v.string(),
    // Add specific creation parameters with validation
    name: v.string(),
    description: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    // Authentication check
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    // Authorization check
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerk_user_id", identity.subject))
      .unique();

    if (!user || user.organization_id !== args.organizationId) {
      throw new Error("Not authorized for this organization");
    }

    // Input validation (additional to Convex schema validation)
    if (args.name.trim().length === 0) {
      throw new Error("Name cannot be empty");
    }

    const now = Date.now();

    // Create record with audit fields
    return await ctx.db.insert("[table_name]", {
      ...args,
      organization_id: args.organizationId,
      created_by: identity.subject,
      created_at: now,
      updated_at: now,
      is_active: true,
    });
  },
});
```

### React Component Template

**File**: `components/[feature]/[component-name].tsx`
```typescript
"use client";

import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useAuth } from "@clerk/nextjs";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";

interface [ComponentName]Props {
  organizationId: string;
  // Add component-specific props
}

export function [ComponentName]({ organizationId }: [ComponentName]Props) {
  const { isSignedIn } = useAuth();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);

  // Convex queries with real-time subscriptions
  const data = useQuery(
    api.[feature].get[FeatureName],
    isSignedIn ? { organizationId } : "skip"
  );

  // Convex mutations with optimistic updates
  const createMutation = useMutation(api.[feature].create[FeatureName]);

  const handleCreate = async (formData: FormData) => {
    if (!isSignedIn) return;

    setIsLoading(true);
    try {
      await createMutation({
        organizationId,
        name: formData.get("name") as string,
        // Add other form fields
      });

      toast({
        title: "Success",
        description: "[FeatureName] created successfully",
      });
    } catch (error) {
      console.error("Create error:", error);
      toast({
        title: "Error",
        description: "Failed to create [feature]",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  if (!isSignedIn) {
    return <div>Please sign in to access this feature.</div>;
  }

  if (data === undefined) {
    return <div>Loading...</div>;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>[Feature Name] Management</CardTitle>
      </CardHeader>
      <CardContent>
        {/* Component content */}
        <div className="grid gap-4">
          {data.map((item) => (
            <div key={item._id} className="border rounded p-4">
              <h3 className="font-semibold">{item.name}</h3>
              {item.description && (
                <p className="text-sm text-muted-foreground">{item.description}</p>
              )}
            </div>
          ))}
        </div>

        {/* Action buttons */}
        <div className="mt-4">
          <Button
            onClick={() => {/* Handle action */}}
            disabled={isLoading}
          >
            {isLoading ? "Processing..." : "Add New"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
```

### API Route Template

**File**: `app/api/[feature]/route.ts`
```typescript
import { auth } from "@clerk/nextjs/server";
import { NextRequest, NextResponse } from "next/server";
import { api } from "@/convex/_generated/api";
import { ConvexHttpClient } from "convex/browser";

const convex = new ConvexHttpClient(process.env.CONVEX_URL!);

export async function GET(request: NextRequest) {
  try {
    // Authentication check
    const { userId, orgId } = auth();

    if (!userId) {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }

    if (!orgId) {
      return NextResponse.json(
        { error: "Organization context required" },
        { status: 400 }
      );
    }

    // Extract query parameters
    const { searchParams } = new URL(request.url);
    const param = searchParams.get("param");

    // Call Convex function
    const result = await convex.query(api.[feature].get[FeatureName], {
      organizationId: orgId,
      // Add query parameters
    });

    return NextResponse.json({ data: result });

  } catch (error) {
    console.error("[Feature] GET error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const { userId, orgId } = auth();

    if (!userId || !orgId) {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }

    // Parse request body
    const body = await request.json();

    // Input validation
    if (!body.name || typeof body.name !== 'string') {
      return NextResponse.json(
        { error: "Name is required" },
        { status: 400 }
      );
    }

    // Call Convex mutation
    const result = await convex.mutation(api.[feature].create[FeatureName], {
      organizationId: orgId,
      ...body,
    });

    return NextResponse.json({ data: result }, { status: 201 });

  } catch (error) {
    console.error("[Feature] POST error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

---

## 🧪 Testing Templates

### Unit Test Template

**File**: `tests/[feature]/[component].test.tsx`
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { [ComponentName] } from '@/components/[feature]/[component-name]';
import { ConvexProvider } from 'convex/react';
import { ClerkProvider } from '@clerk/nextjs';

// Mock Convex client
const mockConvexClient = {
  query: vi.fn(),
  mutation: vi.fn(),
  action: vi.fn(),
};

// Mock Clerk auth
vi.mock('@clerk/nextjs', () => ({
  useAuth: () => ({
    isSignedIn: true,
    userId: 'test-user-id',
    orgId: 'test-org-id',
  }),
  ClerkProvider: ({ children }: { children: React.ReactNode }) => children,
}));

describe('[ComponentName]', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  const renderWithProviders = (component: React.ReactNode) => {
    return render(
      <ConvexProvider client={mockConvexClient as any}>
        <ClerkProvider publishableKey="test-key">
          {component}
        </ClerkProvider>
      </ConvexProvider>
    );
  };

  it('renders loading state initially', () => {
    mockConvexClient.query.mockReturnValue(undefined);

    renderWithProviders(
      <[ComponentName] organizationId="test-org" />
    );

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('renders data when loaded', async () => {
    const mockData = [
      { _id: '1', name: 'Test Item', description: 'Test description' }
    ];

    mockConvexClient.query.mockReturnValue(mockData);

    renderWithProviders(
      <[ComponentName] organizationId="test-org" />
    );

    await waitFor(() => {
      expect(screen.getByText('Test Item')).toBeInTheDocument();
      expect(screen.getByText('Test description')).toBeInTheDocument();
    });
  });

  it('handles create action', async () => {
    mockConvexClient.query.mockReturnValue([]);
    mockConvexClient.mutation.mockResolvedValue({ _id: '2' });

    renderWithProviders(
      <[ComponentName] organizationId="test-org" />
    );

    const button = screen.getByText('Add New');
    fireEvent.click(button);

    await waitFor(() => {
      expect(mockConvexClient.mutation).toHaveBeenCalled();
    });
  });

  it('handles authentication requirement', () => {
    vi.mocked(useAuth).mockReturnValue({
      isSignedIn: false,
      userId: null,
      orgId: null,
    });

    renderWithProviders(
      <[ComponentName] organizationId="test-org" />
    );

    expect(screen.getByText('Please sign in to access this feature.')).toBeInTheDocument();
  });
});
```

### E2E Test Template

**File**: `e2e/[feature]/[workflow].spec.ts`
```typescript
import { test, expect } from '@playwright/test';

test.describe('[Feature] Workflow', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to login page and authenticate
    await page.goto('/sign-in');

    // Fill in test credentials
    await page.fill('[data-testid="email-input"]', 'test@example.com');
    await page.fill('[data-testid="password-input"]', 'testpassword');
    await page.click('[data-testid="sign-in-button"]');

    // Wait for redirect to dashboard
    await page.waitForURL('/dashboard');

    // Select test organization
    await page.click('[data-testid="org-selector"]');
    await page.click('[data-testid="test-org"]');
  });

  test('complete [feature] workflow', async ({ page }) => {
    // Navigate to feature page
    await page.goto('/[feature]');

    // Verify page loaded
    await expect(page.getByRole('heading', { name: '[Feature] Management' })).toBeVisible();

    // Create new item
    await page.click('button:has-text("Add New")');

    // Fill form
    await page.fill('[data-testid="name-input"]', 'Test Item');
    await page.fill('[data-testid="description-input"]', 'Test Description');

    // Submit form
    await page.click('button:has-text("Save")');

    // Verify item created (real-time update)
    await expect(page.getByText('Test Item')).toBeVisible();
    await expect(page.getByText('Test Description')).toBeVisible();

    // Test editing
    await page.click('[data-testid="edit-button"]');
    await page.fill('[data-testid="name-input"]', 'Updated Test Item');
    await page.click('button:has-text("Save")');

    // Verify update (real-time)
    await expect(page.getByText('Updated Test Item')).toBeVisible();

    // Test deletion
    await page.click('[data-testid="delete-button"]');
    await page.click('button:has-text("Confirm")');

    // Verify deletion
    await expect(page.getByText('Updated Test Item')).not.toBeVisible();
  });

  test('handles error states gracefully', async ({ page }) => {
    // Mock server error
    await page.route('/api/[feature]', route => {
      route.fulfill({ status: 500 });
    });

    await page.goto('/[feature]');

    // Verify error handling
    await expect(page.getByText('Error loading data')).toBeVisible();

    // Test retry functionality
    await page.click('button:has-text("Retry")');
  });

  test('validates real-time updates', async ({ page, context }) => {
    // Open two tabs to test real-time sync
    const page1 = page;
    const page2 = await context.newPage();

    await Promise.all([
      page1.goto('/[feature]'),
      page2.goto('/[feature]')
    ]);

    // Create item in first tab
    await page1.click('button:has-text("Add New")');
    await page1.fill('[data-testid="name-input"]', 'Real-time Test');
    await page1.click('button:has-text("Save")');

    // Verify it appears in second tab (real-time)
    await expect(page2.getByText('Real-time Test')).toBeVisible({ timeout: 2000 });
  });
});
```

---

## 📐 Development Standards

### Code Style Standards

**TypeScript Standards**:
```typescript
// ✅ DO: Use explicit types
interface UserData {
  id: string;
  name: string;
  email: string;
  organizationId: string;
}

// ❌ DON'T: Use any type
let userData: any = getUser();

// ✅ DO: Use type guards for unknown data
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

// ✅ DO: Use proper error handling
try {
  await mutation();
} catch (error) {
  console.error('Operation failed:', error);
  // Handle gracefully
}
```

**React Standards**:
```typescript
// ✅ DO: Use proper component typing
interface ComponentProps {
  title: string;
  count: number;
  onAction?: () => void;
}

export function Component({ title, count, onAction }: ComponentProps) {
  // Component implementation
}

// ✅ DO: Use proper hooks patterns
const [state, setState] = useState<StateType>(initialState);

// ✅ DO: Handle loading and error states
if (isLoading) return <Skeleton />;
if (error) return <ErrorBoundary error={error} />;

// ✅ DO: Use proper event handlers
const handleSubmit = useCallback(async (event: FormEvent) => {
  event.preventDefault();
  // Handle submission
}, [dependency]);
```

### Naming Conventions

**Files and Directories**:
```
components/
├── ui/                    # lowercase for UI components
├── feature-name/         # kebab-case for feature modules
│   ├── component-name.tsx # kebab-case for files
│   └── index.ts          # barrel exports
└── shared/               # lowercase for shared utilities

convex/
├── schema.ts             # lowercase for core files
├── feature_name.ts       # snake_case for Convex functions
└── _generated/           # underscore prefix for generated
```

**Code Naming**:
```typescript
// Variables and functions: camelCase
const userName = 'john';
const getUserData = () => {};

// Components and interfaces: PascalCase
interface UserData {}
function UserProfile() {}

// Constants: SCREAMING_SNAKE_CASE
const API_ENDPOINT = 'https://api.example.com';
const MAX_RETRY_COUNT = 3;

// Convex functions: camelCase
export const getUserProfile = query({...});
export const updateUserProfile = mutation({...});
```

### Error Handling Standards

**Convex Function Errors**:
```typescript
export const safeMutation = mutation({
  handler: async (ctx, args) => {
    try {
      // Authentication
      const identity = await ctx.auth.getUserIdentity();
      if (!identity) {
        throw new ConvexError("Authentication required");
      }

      // Validation
      if (!args.name?.trim()) {
        throw new ConvexError("Name is required");
      }

      // Business logic
      return await ctx.db.insert("table", args);

    } catch (error) {
      // Log error with context
      console.error("Mutation failed:", { error, args });

      // Re-throw ConvexError or wrap unknown errors
      if (error instanceof ConvexError) {
        throw error;
      }

      throw new ConvexError("Internal server error");
    }
  },
});
```

**React Component Errors**:
```typescript
export function ComponentWithErrorHandling() {
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleAction = async () => {
    setIsLoading(true);
    setError(null);

    try {
      await performAction();
    } catch (error) {
      const message = error instanceof Error
        ? error.message
        : 'An unexpected error occurred';

      setError(message);

      // Report to monitoring
      console.error('Component action failed:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (error) {
    return (
      <Alert variant="destructive">
        <AlertDescription>{error}</AlertDescription>
        <Button onClick={() => setError(null)}>Dismiss</Button>
      </Alert>
    );
  }

  return (
    // Component JSX
  );
}
```

---

## 📝 Documentation Standards

### Code Documentation

**Function Documentation**:
```typescript
/**
 * Retrieves user profile data with organization context
 *
 * @param userId - Clerk user ID
 * @param organizationId - Organization context for data isolation
 * @returns Promise resolving to user profile or null if not found
 *
 * @throws ConvexError When user is not authenticated
 * @throws ConvexError When user lacks organization access
 *
 * @example
 * ```typescript
 * const profile = await getUserProfile({
 *   userId: "user_123",
 *   organizationId: "org_456"
 * });
 * ```
 */
export const getUserProfile = query({
  args: {
    userId: v.string(),
    organizationId: v.string(),
  },
  handler: async (ctx, args) => {
    // Implementation
  },
});
```

**Component Documentation**:
```typescript
/**
 * Photo grid component with real-time updates and infinite scroll
 *
 * Features:
 * - Real-time photo updates via Convex subscriptions
 * - Infinite scroll with automatic loading
 * - Responsive grid layout
 * - Optimistic updates for user actions
 *
 * @param organizationId - Organization context for photo filtering
 * @param searchTerm - Optional search filter
 * @param onPhotoClick - Callback when photo is clicked
 *
 * @example
 * ```tsx
 * <PhotoGrid
 *   organizationId={org.id}
 *   searchTerm={searchValue}
 *   onPhotoClick={(photo) => setSelectedPhoto(photo)}
 * />
 * ```
 */
export function PhotoGrid({ organizationId, searchTerm, onPhotoClick }: PhotoGridProps) {
  // Implementation
}
```

### README Template

**Feature README**:
```markdown
# [Feature Name]

Brief description of what this feature does and why it exists.

## Features

- Real-time updates via Convex subscriptions
- Multi-organization support with data isolation
- Comprehensive search and filtering
- Responsive design for all devices

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   React UI      │    │  Convex Functions │    │   Database      │
│                 │────│                  │────│                 │
│ - Components    │    │ - Queries        │    │ - Schema        │
│ - Real-time     │    │ - Mutations      │    │ - Indexes       │
│ - State mgmt    │    │ - Actions        │    │ - Validation    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Usage

### Basic Usage
\`\`\`tsx
import { FeatureComponent } from '@/components/feature/feature-component';

function App() {
  return (
    <FeatureComponent
      organizationId={orgId}
      onAction={handleAction}
    />
  );
}
\`\`\`

### Advanced Usage
\`\`\`tsx
import { useQuery } from 'convex/react';
import { api } from '@/convex/_generated/api';

function CustomImplementation() {
  const data = useQuery(api.feature.getData, { organizationId });

  // Custom implementation
}
\`\`\`

## API Reference

### Convex Functions

#### Queries
- `api.feature.getData` - Get feature data
- `api.feature.searchData` - Search with filters

#### Mutations
- `api.feature.createItem` - Create new item
- `api.feature.updateItem` - Update existing item
- `api.feature.deleteItem` - Delete item

### Components

#### FeatureComponent
Main component for feature functionality.

**Props:**
- `organizationId: string` - Organization context
- `onAction?: () => void` - Action callback

## Testing

Run feature tests:
\`\`\`bash
npm test -- feature
npm run test:e2e -- feature
\`\`\`

## Development

### Adding New Functionality
1. Update schema in `convex/schema.ts`
2. Add Convex functions in `convex/feature.ts`
3. Create/update React components
4. Add tests for new functionality
5. Update documentation

### Performance Considerations
- Use appropriate indexes for queries
- Implement pagination for large datasets
- Use real-time subscriptions efficiently
- Optimize component re-renders

## Troubleshooting

### Common Issues
- **Authentication errors**: Verify Clerk setup and tokens
- **Real-time not working**: Check Convex subscription setup
- **Performance issues**: Review query patterns and indexes
```

---

## ✅ Quality Checklists

### Pre-Commit Checklist

```markdown
## Pre-Commit Quality Gates

### Code Quality
- [ ] Zero TypeScript errors (`npm run type-check`)
- [ ] All linting rules passed (`npm run lint`)
- [ ] Code formatted consistently (`npm run format`)
- [ ] No console.log statements in production code
- [ ] All TODO comments have GitHub issues

### Testing
- [ ] All existing tests pass (`npm test`)
- [ ] New functionality has unit tests
- [ ] Critical workflows have E2E tests
- [ ] Test coverage >90% for new code

### Security
- [ ] No hardcoded secrets or API keys
- [ ] Authentication checks in all protected routes
- [ ] Input validation for all user inputs
- [ ] SQL injection prevention (N/A for Convex)

### Performance
- [ ] No unnecessary re-renders identified
- [ ] Database queries use appropriate indexes
- [ ] Images optimized for web
- [ ] Bundle size increase <10% (if applicable)

### Documentation
- [ ] README updated for new features
- [ ] API changes documented
- [ ] Breaking changes noted
- [ ] Examples provided for complex usage
```

### Phase Completion Checklist

```markdown
## Phase [X] Completion Checklist

### Functional Requirements
- [ ] All user stories completed and tested
- [ ] Acceptance criteria met for each feature
- [ ] Real-time functionality working as expected
- [ ] Multi-organization support functional
- [ ] Error handling comprehensive and user-friendly

### Technical Quality
- [ ] Zero TypeScript errors in phase scope
- [ ] All tests passing (unit + integration + e2e)
- [ ] Performance benchmarks met
- [ ] Security requirements satisfied
- [ ] Code review completed

### Documentation
- [ ] Implementation decisions documented
- [ ] API changes documented
- [ ] User-facing features documented
- [ ] Deployment procedures updated
- [ ] Known limitations documented

### Deployment Ready
- [ ] Production deployment tested in staging
- [ ] Environment variables configured
- [ ] Monitoring and alerting configured
- [ ] Rollback procedures tested
- [ ] Team handover completed

### Stakeholder Approval
- [ ] Demo completed successfully
- [ ] Stakeholder feedback incorporated
- [ ] Go-live approval received
- [ ] Next phase planning initiated
```

---

## 🚀 Migration Phase Templates

### Phase Kickoff Template

```markdown
# Phase [X]: [Phase Name] - Kickoff

## Objectives
- Primary objective with success criteria
- Secondary objectives
- Technical goals
- Business goals

## Scope
### In Scope
- Feature A with detailed requirements
- Feature B with acceptance criteria
- Integration C with external dependencies

### Out of Scope
- Features deferred to later phases
- Non-critical optimizations
- Third-party integrations not required

## Technical Approach
### Architecture Decisions
- Key technology choices and rationale
- Integration patterns to be used
- Performance considerations

### Implementation Strategy
- Development sequence and dependencies
- Risk mitigation approaches
- Quality assurance plan

## Timeline
- Week 1: Foundation setup
- Week 2: Core functionality
- Week 3: Integration and testing
- Week 4: Polish and documentation

## Success Metrics
- Functional completion criteria
- Performance benchmarks
- Quality gates
- User acceptance criteria

## Risks & Mitigation
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Risk 1 | Medium | High | Mitigation strategy |

## Next Steps
1. Environment setup
2. Initial development sprint
3. Weekly progress reviews
4. Stakeholder demos
```

### Phase Completion Template

```markdown
# Phase [X]: [Phase Name] - Completion Report

## Executive Summary
Phase [X] has been completed successfully, delivering [key achievements]. All primary objectives met with [performance metrics]. Ready to proceed to Phase [X+1].

## Objectives Achieved
✅ Primary objective delivered with [specific metrics]
✅ Secondary objectives completed
✅ Technical goals met or exceeded
✅ Business goals achieved

## Deliverables
### Functional Deliverables
- Feature A: Complete with [metrics]
- Feature B: Complete with [metrics]
- Integration C: Functional and tested

### Technical Deliverables
- Zero TypeScript errors (was [previous count])
- Test coverage: [percentage]%
- Performance: [specific metrics]
- Documentation: Complete and reviewed

## Quality Metrics
| Metric | Target | Achieved | Status |
|--------|--------|----------|---------|
| TypeScript Errors | <5 | 0 | ✅ |
| Test Coverage | >95% | 97% | ✅ |
| Performance | <2s load | 1.2s | ✅ |

## Lessons Learned
### What Went Well
- Effective use of Context7 for documentation
- Convex real-time features exceeded expectations
- Team collaboration efficient

### Challenges Overcome
- Challenge 1 and how it was resolved
- Challenge 2 and mitigation applied
- Technical hurdles and solutions

### Improvements for Next Phase
- Process improvements identified
- Technical approach refinements
- Resource allocation optimization

## Next Phase Preparation
- Phase [X+1] prerequisites completed
- Environment prepared
- Team briefed and ready
- Stakeholder approval received

## Handover
- Documentation location: [link]
- Key contacts: [team members]
- Support procedures: [process]
- Known issues: [documented items]

**Phase Status**: ✅ COMPLETE
**Next Phase Status**: 🚀 READY TO BEGIN
```

This comprehensive development standards document provides the foundation for consistent, high-quality development throughout the migration phases. All patterns and templates should be adapted to specific feature requirements while maintaining the established standards.