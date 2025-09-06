# Phase 1: Authentication System Core Fix

**Objective**: Restore complete authentication functionality with Clerk integration  
**Duration**: Day 1 (8 hours)  
**Priority**: 🔴 CRITICAL - Blocking all other functionality  
**Success Criteria**: All authentication flows working with zero TypeScript errors in auth components

## 📋 Phase Overview

The authentication system is fundamentally broken with missing methods that pages expect (`resetPassword`, `updatePassword`) and type mismatches between Clerk's user structure and the application's expectations. This phase will completely fix the authentication layer to provide a solid foundation for the rest of the migration.

## 🎯 Deliverables

1. ✅ Complete useAuth hook with all required methods
2. ✅ Clerk authentication helpers for password management
3. ✅ Fixed user type mappings between Clerk and application
4. ✅ Updated authentication components using Clerk patterns
5. ✅ Zero TypeScript errors in authentication code

## 📝 Detailed Implementation Tasks

### Task 1: Analyze Current Authentication Implementation
**Files to examine:**
- `/hooks/useAuth.ts` - Current incomplete implementation
- `/app/(auth)/forgot-password/page.tsx` - Expects resetPassword method
- `/app/(auth)/reset-password/page.tsx` - Expects updatePassword method
- `/app/(protected)/admin/layout.tsx` - Expects user property
- `/app/(protected)/profile/setup/page.tsx` - Expects initializeAuth method
- `/lib/services/auth-service.ts` - Authentication service layer
- `/stores/auth-store.ts` - Authentication state management
- `/types/auth.ts` - Authentication type definitions

**Analysis checklist:**
- [ ] Document all missing methods and their expected signatures
- [ ] Map Clerk user structure to application user structure
- [ ] Identify all Supabase patterns that need replacement
- [ ] List all components using authentication

### Task 2: Implement Missing Authentication Methods
**File: `/hooks/useAuth.ts`**

**Add resetPassword method:**
```typescript
import { useClerk } from "@clerk/nextjs";

// Add to useAuth hook
const resetPassword = useCallback(async (email: string) => {
  try {
    const { client } = clerk;
    
    // Create magic link flow for password reset
    const signIn = await client.signIns.create({
      identifier: email,
      strategy: "reset_password_email_code",
    });
    
    // Send the reset email
    await signIn.prepareFirstFactor({
      strategy: "reset_password_email_code",
      emailAddressId: signIn.supportedFirstFactors.find(
        factor => factor.strategy === "reset_password_email_code"
      )?.emailAddressId!
    });
    
    return { success: true };
  } catch (error) {
    console.error("Password reset error:", error);
    return { 
      success: false, 
      error: error instanceof Error ? error.message : "Failed to send reset email" 
    };
  }
}, [clerk]);
```

**Add updatePassword method:**
```typescript
const updatePassword = useCallback(async (
  code: string, 
  newPassword: string
) => {
  try {
    const { client } = clerk;
    
    // Complete password reset with code
    const result = await client.signIns.attemptFirstFactor({
      strategy: "reset_password_email_code",
      code,
      password: newPassword,
    });
    
    if (result.status === "complete") {
      await setActive({ session: result.createdSessionId });
      return { success: true };
    }
    
    return { success: false, error: "Invalid or expired code" };
  } catch (error) {
    console.error("Password update error:", error);
    return { 
      success: false, 
      error: error instanceof Error ? error.message : "Failed to update password" 
    };
  }
}, [clerk, setActive]);
```

**Add initializeAuth method:**
```typescript
const initializeAuth = useCallback(async () => {
  try {
    // Initialize or refresh the Clerk session
    await clerk.load();
    
    // Get fresh user data if signed in
    if (isSignedIn) {
      await clerkUser?.reload();
    }
    
    return { success: true };
  } catch (error) {
    console.error("Auth initialization error:", error);
    setSessionError(error instanceof Error ? error.message : "Auth initialization failed");
    return { success: false };
  }
}, [clerk, isSignedIn, clerkUser, setSessionError]);
```

**Update return statement:**
```typescript
return {
  // State from Clerk
  user: authUser,
  profile: null,
  isLoading: !clerkUser && isSignedIn,
  isAuthenticated: isSignedIn || false,
  sessionError,
  userId,
  orgId,
  
  // Actions
  signOut: signOutUser,
  resetPassword,      // NEW
  updatePassword,     // NEW
  initializeAuth,     // NEW
  clearError,
  setSessionError,
  
  // Utility methods
  hasRole,
  hasPermission,
  canAccess,
};
```

### Task 3: Fix User Type Mappings
**File: `/types/auth.ts`**

**Update UseAuthReturn interface:**
```typescript
export interface UseAuthReturn {
  user: AuthUser | null;
  profile: UserProfile | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  sessionError: string | null;
  userId: string | null;
  orgId: string | null;
  
  // Actions
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<{ success: boolean; error?: string }>;
  updatePassword: (code: string, newPassword: string) => Promise<{ success: boolean; error?: string }>;
  initializeAuth: () => Promise<{ success: boolean }>;
  clearError: () => void;
  setSessionError: (error: string) => void;
  
  // Utility methods
  hasRole: (roles: UserRole[]) => boolean;
  hasPermission: (permission: Permission) => boolean;
  canAccess: (orgId: string) => boolean;
}
```

**Create Clerk-specific type helpers:**
```typescript
// Add to types/auth.ts
export interface ClerkUserMetadata {
  role?: UserRole;
  organizationId?: string;
  firstName?: string;
  lastName?: string;
}

export function mapClerkUserToAuthUser(
  clerkUser: any, // ClerkUser type from @clerk/types
  orgId: string | null
): AuthUser {
  return {
    id: clerkUser.id,
    email: clerkUser.emailAddresses[0]?.emailAddress || "",
    organizationId: orgId,
    role: (clerkUser.publicMetadata?.role as UserRole) || "engineer",
    firstName: clerkUser.firstName || undefined,
    lastName: clerkUser.lastName || undefined,
    createdAt: clerkUser.createdAt?.toISOString(),
    updatedAt: clerkUser.updatedAt?.toISOString(),
  };
}
```

### Task 4: Update Authentication Pages
**File: `/app/(auth)/forgot-password/page.tsx`**

Fix the implementation to properly use the new resetPassword method:
```typescript
// Lines 28-29 - resetPassword is now available
const { resetPassword } = useAuth(); // This will now work

// Update handleSubmit to match new signature
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  setError("");
  setIsSubmitting(true);

  if (!email) {
    setError("Please enter your email address");
    setIsSubmitting(false);
    return;
  }

  try {
    const result = await resetPassword(email);
    if (result.success) {
      setIsSuccess(true);
    } else {
      setError(result.error || "Password reset failed");
    }
  } catch (err) {
    setError(err instanceof Error ? err.message : "An unexpected error occurred");
  } finally {
    setIsSubmitting(false);
  }
};
```

**File: `/app/(auth)/reset-password/page.tsx`**

Update to use the new updatePassword method:
```typescript
// Get code from URL params
const searchParams = useSearchParams();
const code = searchParams.get("code") || "";

const { updatePassword } = useAuth();

const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  
  if (!code) {
    setError("Invalid reset link");
    return;
  }
  
  if (password !== confirmPassword) {
    setError("Passwords do not match");
    return;
  }
  
  setIsSubmitting(true);
  
  const result = await updatePassword(code, password);
  if (result.success) {
    toast.success("Password updated successfully");
    router.push("/login");
  } else {
    setError(result.error || "Failed to update password");
  }
  
  setIsSubmitting(false);
};
```

### Task 5: Fix Admin Layout Authentication
**File: `/app/(protected)/admin/layout.tsx`**

Update to use proper Clerk authentication:
```typescript
import { useAuth } from "@/hooks/useAuth";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, isAuthenticated, isLoading } = useAuth();
  
  if (isLoading) {
    return <LoadingSpinner />;
  }
  
  if (!isAuthenticated || !user) {
    redirect("/login");
  }
  
  if (user.role !== "admin" && user.role !== "platform_admin") {
    redirect("/unauthorized");
  }
  
  return <>{children}</>;
}
```

### Task 6: Remove Supabase User Patterns
**Files to update:**
- `/app/(protected)/photos/page-original.tsx` - Remove user_metadata references
- `/app/(protected)/photos/page-simplified.tsx` - Remove user_metadata references
- `/components/admin/admin-header.tsx` - Remove user_metadata references

**Pattern to replace:**
```typescript
// OLD Supabase pattern
user?.user_metadata?.organization_id

// NEW Clerk pattern
user?.organizationId
```

**Update all instances:**
```typescript
// In page-original.tsx lines 59, 72
organizationId: user?.organizationId,
projectId: projectIdFromUrl || filters.projectId,

// In admin-header.tsx line 86
const orgName = user?.organizationId ? "Organization" : "Platform";
```

### Task 7: Create Authentication Test Utilities
**File: `/lib/auth/test-utils.ts` (NEW)**

```typescript
import { vi } from "vitest";

export const mockClerkUser = {
  id: "user_123",
  emailAddresses: [{ emailAddress: "test@example.com" }],
  firstName: "Test",
  lastName: "User",
  publicMetadata: { role: "engineer" },
  createdAt: new Date(),
  updatedAt: new Date(),
};

export const mockUseAuth = () => ({
  user: {
    id: "user_123",
    email: "test@example.com",
    organizationId: "org_123",
    role: "engineer" as const,
    firstName: "Test",
    lastName: "User",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  profile: null,
  isLoading: false,
  isAuthenticated: true,
  sessionError: null,
  userId: "user_123",
  orgId: "org_123",
  signOut: vi.fn(),
  resetPassword: vi.fn().mockResolvedValue({ success: true }),
  updatePassword: vi.fn().mockResolvedValue({ success: true }),
  initializeAuth: vi.fn().mockResolvedValue({ success: true }),
  clearError: vi.fn(),
  setSessionError: vi.fn(),
  hasRole: vi.fn().mockReturnValue(true),
  hasPermission: vi.fn().mockReturnValue(true),
  canAccess: vi.fn().mockReturnValue(true),
});

export const setupAuthMocks = () => {
  vi.mock("@/hooks/useAuth", () => ({
    useAuth: mockUseAuth,
  }));
  
  vi.mock("@clerk/nextjs", () => ({
    useAuth: () => ({
      isSignedIn: true,
      userId: "user_123",
      orgId: "org_123",
    }),
    useUser: () => ({
      user: mockClerkUser,
    }),
    useClerk: () => ({
      signOut: vi.fn(),
      client: {
        signIns: {
          create: vi.fn(),
        },
      },
    }),
    ClerkProvider: ({ children }: any) => children,
  }));
};
```

## ✅ Validation Checklist

### TypeScript Validation
```bash
# Check for auth-related TypeScript errors
npx tsc --noEmit 2>&1 | grep -E "(auth|Auth|login|Login|password|Password)"

# Should return: 0 errors
```

### Component Testing
```bash
# Test authentication pages
pnpm test app/\(auth\)

# Test protected layouts
pnpm test app/\(protected\)

# Test auth hook
pnpm test hooks/useAuth
```

### Manual Testing Checklist
- [ ] Login flow works with email/password
- [ ] Logout clears session properly
- [ ] Forgot password sends reset email
- [ ] Reset password with code updates password
- [ ] Protected routes redirect when not authenticated
- [ ] Admin routes check role properly
- [ ] User data displays correctly in UI

## 🔄 Rollback Plan

If authentication changes break the application:

1. **Immediate rollback:**
   ```bash
   git stash
   git checkout feature/production-fixes
   ```

2. **Partial rollback:**
   - Keep Clerk configuration
   - Revert only the breaking changes
   - Use mock authentication temporarily

3. **Alternative approach:**
   - Implement minimal auth wrapper
   - Use Clerk components directly
   - Defer complex flows to Phase 4

## 📊 Success Metrics

- [ ] 0 TypeScript errors in `/hooks/useAuth.ts`
- [ ] 0 TypeScript errors in `/app/(auth)/**`
- [ ] All auth pages render without errors
- [ ] resetPassword method implemented and working
- [ ] updatePassword method implemented and working
- [ ] initializeAuth method implemented and working
- [ ] No more user_metadata references (Supabase pattern)
- [ ] All auth-related tests passing

## 🚀 Next Steps

After completing Phase 1:
1. Run `pnpm run validate:quick` to ensure no TypeScript errors
2. Test all authentication flows manually
3. Update MASTER-TRACKER.md with completion status
4. Document any discovered gaps in GAPS-LOG.md
5. Proceed to Phase 2: Legacy Code Elimination

## 📝 Implementation Notes

**Critical Considerations:**
- Clerk uses a different password reset flow than traditional systems
- The magic link/code approach requires email configuration
- Session management is handled by Clerk, not local storage
- User metadata should be stored in Clerk's publicMetadata

**Common Pitfalls to Avoid:**
- Don't mix Clerk and Supabase patterns
- Don't store sensitive data in publicMetadata
- Don't bypass Clerk's session management
- Don't hardcode organization IDs

---

*Phase 1 provides the authentication foundation required for all other functionality. Complete this phase thoroughly before proceeding.*