# PHASE 2: Complete Convex Backend Implementation

**Duration**: 60-75 minutes  
**Objective**: Implement ALL database operations with Convex  
**Priority**: HIGH - Core functionality depends on complete Convex integration  
**Status**: 📋 Ready for Implementation  
**Prerequisites**: Phase 1 completed (build working, Supabase removed)

---

## 🎯 Phase Objectives

**PRIMARY GOAL**: Replace ALL TODO placeholders with functional Convex implementation

**SUCCESS CRITERIA**:
- ✅ All core Convex queries and mutations implemented
- ✅ Photo management fully functional with Convex
- ✅ File storage working with Convex file storage
- ✅ Real-time updates operational
- ✅ User management integrated with Convex
- ✅ TODO count reduced from 650 to ~400
- ✅ Core user workflows operational (view photos, basic upload)

**DELIVERABLES**:
- Complete Convex schema implementation
- All CRUD operations via Convex
- Real-time functionality working
- File storage system migrated
- Core API routes fully functional

---

## 📊 Implementation Scope Analysis

### **Current TODO Distribution** (from Phase 1 outcome):
- **app directory**: 22 TODOs - Focus on API routes
- **lib directory**: 15 TODOs - Focus on services and utilities  
- **hooks directory**: 7 TODOs - Focus on data hooks
- **components directory**: 7 TODOs - Focus on data-dependent components
- **stores directory**: 4 TODOs - Focus on state management

**Priority Implementation Order**:
1. **Convex Schema & Functions** (Backend foundation)
2. **Core API Routes** (Photo management, file storage)
3. **Data Hooks** (Frontend data access)
4. **Service Layer** (Business logic)
5. **State Management** (UI integration)

### **Convex Architecture Patterns** (Context7 Research)

**Modern Convex Implementation Patterns**:
```typescript
// Pattern 1: Efficient Database Queries with indexes
const photos = await ctx.db.query("photos")
  .withIndex("by_organization", (q) => q.eq("organizationId", organizationId))
  .collect();

// Pattern 2: Proper Model Layer Organization  
// convex/model/photos.ts (Business logic)
export async function getPhotosByOrganization(ctx: QueryCtx, organizationId: string) {
  const user = await getCurrentUser(ctx);
  return await ctx.db.query("photos")
    .withIndex("by_organization", q => q.eq("organizationId", organizationId))
    .collect();
}

// Pattern 3: File Storage with Convex
const uploadUrl = await ctx.storage.generateUploadUrl();
const storageId = await ctx.storage.store(file);
const fileUrl = await ctx.storage.getUrl(storageId);
```

---

## 🏗️ Implementation Workflow

### **ANALYZE Phase** (10-12 minutes)

**Task 1: Convex Schema Review**
```bash
# Check current Convex schema
cat convex/schema.ts

# Review existing Convex functions  
ls -la convex/
find convex/ -name "*.ts" -exec echo "=== {} ===" \; -exec head -20 {} \;
```

**Task 2: TODO Priority Analysis**
```bash
# Find all Convex-related TODOs
grep -r "TODO.*Convex" . --include="*.ts" --include="*.tsx" | head -20

# Find critical API routes from Phase 1
ls -la app/api/photos/
grep -r "TODO.*Replace with Convex" app/api/ | wc -l
```

**Task 3: Data Flow Mapping**
- Map current TODO placeholders to required Convex operations
- Identify data relationships and dependencies
- Plan implementation order based on dependencies

### **DESIGN Phase** (12-15 minutes)

**Strategy 1: Complete Convex Schema**
- Ensure all required tables exist in schema
- Add proper indexes for query performance
- Include file storage configuration

**Strategy 2: Convex Function Architecture**
```
convex/
├── schema.ts           # Complete data schema
├── photos.ts          # Photo CRUD operations  
├── users.ts           # User management
├── organizations.ts   # Organization data
├── files.ts           # File storage operations
├── ai_processing.ts   # AI processing queue
├── feedback.ts        # User feedback system
└── model/            # Business logic layer
    ├── photos.ts      # Photo business logic
    ├── users.ts       # User business logic
    └── auth.ts        # Authentication helpers
```

**Strategy 3: API Route Implementation Pattern**
```typescript
// Standard pattern for API routes
import { api } from "@/convex/_generated/api";
import { fetchQuery, fetchMutation } from "convex/nextjs";

export const GET = createAPIHandler(config, async (context) => {
  const result = await fetchQuery(api.photos.list, {
    organizationId: context.organizationId,
    ...context.query
  });
  
  return ResponseFormatter.success(result);
});
```

### **IMPLEMENT Phase** (30-40 minutes)

#### **Step 1: Complete Convex Schema** (8-10 minutes)

**File**: `convex/schema.ts`
```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // Users table
  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    firstName: v.optional(v.string()),
    lastName: v.optional(v.string()),
    role: v.union(v.literal("user"), v.literal("admin"), v.literal("platform_admin")),
    organizationId: v.string(),
    isActive: v.boolean(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_clerk_id", ["clerkId"])
    .index("by_organization", ["organizationId"])
    .index("by_email", ["email"]),

  // Organizations table
  organizations: defineTable({
    name: v.string(),
    slug: v.string(),
    isActive: v.boolean(),
    settings: v.optional(v.object({
      aiProcessing: v.boolean(),
      fileRetention: v.number(),
    })),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_slug", ["slug"]),

  // Photos table  
  photos: defineTable({
    organizationId: v.string(),
    uploaderId: v.string(),
    storageId: v.optional(v.string()), // Convex file storage ID
    originalFilename: v.string(),
    mimeType: v.string(),
    fileSize: v.number(),
    width: v.optional(v.number()),
    height: v.optional(v.number()),
    userDescription: v.optional(v.string()),
    aiDescription: v.optional(v.string()),
    tags: v.array(v.string()),
    aiProcessingStatus: v.union(
      v.literal("pending"),
      v.literal("processing"), 
      v.literal("completed"),
      v.literal("failed")
    ),
    uploadStatus: v.union(
      v.literal("uploading"),
      v.literal("completed"),
      v.literal("failed")
    ),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_organization", ["organizationId"])
    .index("by_uploader", ["uploaderId"])
    .index("by_ai_status", ["aiProcessingStatus"])
    .index("by_upload_status", ["uploadStatus"]),

  // AI Processing Queue
  aiProcessingQueue: defineTable({
    photoId: v.id("photos"),
    organizationId: v.string(),
    status: v.union(
      v.literal("pending"),
      v.literal("processing"),
      v.literal("completed"), 
      v.literal("failed")
    ),
    provider: v.string(),
    retryCount: v.number(),
    processingStartedAt: v.optional(v.number()),
    processingCompletedAt: v.optional(v.number()),
    errorMessage: v.optional(v.string()),
    result: v.optional(v.object({
      tags: v.array(v.string()),
      description: v.string(),
      confidence: v.number(),
    })),
  })
    .index("by_photo", ["photoId"])
    .index("by_status", ["status"])
    .index("by_organization", ["organizationId"]),

  // Feedback system
  feedback: defineTable({
    userId: v.string(),
    organizationId: v.string(),
    type: v.union(v.literal("bug"), v.literal("feature"), v.literal("general")),
    title: v.string(),
    description: v.string(),
    status: v.union(
      v.literal("open"),
      v.literal("in_progress"), 
      v.literal("resolved"),
      v.literal("closed")
    ),
    priority: v.union(v.literal("low"), v.literal("medium"), v.literal("high")),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_organization", ["organizationId"])
    .index("by_user", ["userId"])
    .index("by_status", ["status"]),
});
```

#### **Step 2: Core Convex Functions Implementation** (15-20 minutes)

**File**: `convex/photos.ts`
```typescript
import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { getCurrentUser } from "./model/auth";

// Query: List photos for organization
export const list = query({
  args: {
    organizationId: v.string(),
    limit: v.optional(v.number()),
    cursor: v.optional(v.string()),
    tags: v.optional(v.array(v.string())),
  },
  handler: async (ctx, args) => {
    const user = await getCurrentUser(ctx);
    if (!user) throw new Error("Unauthorized");
    
    // Verify user belongs to organization
    if (user.organizationId !== args.organizationId && user.role !== "platform_admin") {
      throw new Error("Access denied");
    }

    const photos = await ctx.db
      .query("photos")
      .withIndex("by_organization", (q) => q.eq("organizationId", args.organizationId))
      .filter((q) => q.eq(q.field("uploadStatus"), "completed"))
      .take(args.limit || 20);

    return photos;
  },
});

// Query: Get single photo
export const get = query({
  args: { id: v.id("photos") },
  handler: async (ctx, args) => {
    const user = await getCurrentUser(ctx);
    if (!user) throw new Error("Unauthorized");
    
    const photo = await ctx.db.get(args.id);
    if (!photo) throw new Error("Photo not found");
    
    // Check access
    if (photo.organizationId !== user.organizationId && user.role !== "platform_admin") {
      throw new Error("Access denied");
    }
    
    return photo;
  },
});

// Mutation: Create photo record
export const create = mutation({
  args: {
    organizationId: v.string(),
    originalFilename: v.string(),
    mimeType: v.string(),
    fileSize: v.number(),
    width: v.optional(v.number()),
    height: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const user = await getCurrentUser(ctx);
    if (!user) throw new Error("Unauthorized");
    
    const photoId = await ctx.db.insert("photos", {
      ...args,
      uploaderId: user._id,
      tags: [],
      aiProcessingStatus: "pending",
      uploadStatus: "uploading",
      createdAt: Date.now(),
      updatedAt: Date.now(),
    });
    
    return photoId;
  },
});

// Mutation: Complete upload
export const completeUpload = mutation({
  args: {
    id: v.id("photos"),
    storageId: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await getCurrentUser(ctx);
    if (!user) throw new Error("Unauthorized");
    
    const photo = await ctx.db.get(args.id);
    if (!photo) throw new Error("Photo not found");
    
    if (photo.uploaderId !== user._id && user.role !== "admin") {
      throw new Error("Access denied");
    }
    
    await ctx.db.patch(args.id, {
      storageId: args.storageId,
      uploadStatus: "completed",
      updatedAt: Date.now(),
    });
    
    // Queue for AI processing
    await ctx.db.insert("aiProcessingQueue", {
      photoId: args.id,
      organizationId: photo.organizationId,
      status: "pending",
      provider: "google_vision",
      retryCount: 0,
    });
    
    return args.id;
  },
});

// Query: Get upload URL
export const getUploadUrl = mutation({
  args: {},
  handler: async (ctx) => {
    const user = await getCurrentUser(ctx);
    if (!user) throw new Error("Unauthorized");
    
    return await ctx.storage.generateUploadUrl();
  },
});

// Query: Get file URL
export const getFileUrl = query({
  args: { storageId: v.string() },
  handler: async (ctx, args) => {
    const user = await getCurrentUser(ctx);
    if (!user) throw new Error("Unauthorized");
    
    return await ctx.storage.getUrl(args.storageId);
  },
});
```

**File**: `convex/model/auth.ts`
```typescript
import { QueryCtx } from "./_generated/server";

export async function getCurrentUser(ctx: QueryCtx) {
  const identity = await ctx.auth.getUserIdentity();
  if (!identity) return null;
  
  const user = await ctx.db
    .query("users")
    .withIndex("by_clerk_id", (q) => q.eq("clerkId", identity.subject))
    .first();
    
  return user;
}

export async function requireAuth(ctx: QueryCtx) {
  const user = await getCurrentUser(ctx);
  if (!user) throw new Error("Authentication required");
  return user;
}

export function checkUserRole(user: any, allowedRoles: string[]) {
  return allowedRoles.includes(user.role);
}
```

#### **Step 3: API Routes Implementation** (10-12 minutes)

**File**: `app/api/photos/route.ts`
```typescript
import { api } from "@/convex/_generated/api";
import { fetchQuery, fetchMutation } from "convex/nextjs";
import {
  createAPIHandler,
  RateLimitPresets,
  ResponseFormatter,
} from "@/lib/api/unified-handler";
import { ValidationUtils } from "@/lib/api/validation-middleware";
import {
  photoCreateSchema,
  photoListQuerySchema,
} from "@/lib/validation-schemas";

// GET /api/photos - List photos
export const GET = createAPIHandler(
  {
    auth: { required: true, requireOrg: true },
    rateLimit: RateLimitPresets.authenticated,
    validation: ValidationUtils.createConfig({
      query: photoListQuerySchema,
    }),
  },
  async (context) => {
    const photos = await fetchQuery(api.photos.list, {
      organizationId: context.organizationId!,
      ...context.query,
    });
    
    return ResponseFormatter.success(photos);
  }
);

// POST /api/photos - Create photo record
export const POST = createAPIHandler(
  {
    auth: { required: true, requireOrg: true },
    rateLimit: RateLimitPresets.authenticated,
    validation: ValidationUtils.createConfig({
      body: photoCreateSchema,
    }),
  },
  async (context) => {
    // Create photo record
    const photoId = await fetchMutation(api.photos.create, {
      organizationId: context.organizationId!,
      ...context.body,
    });
    
    // Get upload URL
    const uploadUrl = await fetchMutation(api.photos.getUploadUrl, {});
    
    return ResponseFormatter.created({
      photoId,
      uploadUrl,
    });
  }
);
```

**Similar pattern for other API routes**:
- `app/api/photos/process/route.ts` - Photo processing
- `app/api/photos/signed-urls/route.ts` - File URLs
- `app/api/photos/download/route.ts` - File downloads

#### **Step 4: Data Hooks Implementation** (5-7 minutes)

**File**: `hooks/use-photos.ts`
```typescript
import { api } from "@/convex/_generated/api";
import { useQuery } from "convex/react";
import { useAuth } from "@/stores/auth-store";

export function usePhotos(organizationId?: string) {
  const { user } = useAuth();
  
  const photos = useQuery(
    api.photos.list,
    organizationId ? { organizationId } : "skip"
  );
  
  return {
    photos: photos || [],
    isLoading: photos === undefined,
    error: null, // TODO: Add error handling
  };
}

export function usePhoto(id?: string) {
  const photo = useQuery(
    api.photos.get,
    id ? { id } : "skip"
  );
  
  return {
    photo,
    isLoading: photo === undefined,
    error: null,
  };
}
```

**File**: `hooks/use-ai-processing-status.ts`
```typescript
import { api } from "@/convex/_generated/api";
import { useQuery } from "convex/react";

export function useAIProcessingStatus(organizationId?: string) {
  const processingQueue = useQuery(
    api.aiProcessing.getStatus,
    organizationId ? { organizationId } : "skip"
  );
  
  return {
    queue: processingQueue || [],
    isLoading: processingQueue === undefined,
    pendingCount: processingQueue?.filter(item => item.status === "pending").length || 0,
    processingCount: processingQueue?.filter(item => item.status === "processing").length || 0,
  };
}
```

### **VALIDATE Phase** (8-10 minutes)

**Validation Sequence**:
```bash
# 1. Verify Convex deployment
echo "=== Deploying Convex functions ==="
pnpm exec convex deploy

# 2. Test build with new Convex code
echo "=== Testing build ==="
pnpm run build
# Expected: Should build successfully

# 3. Test core API endpoints
echo "=== Testing API endpoints ==="
pnpm run dev:safe &
DEV_PID=$!
sleep 5

# Test photo listing (should return 501 or empty data, not error)
curl -s http://localhost:3000/api/photos || echo "API responded"

kill $DEV_PID

# 4. Verify TODO count reduced
echo "=== Checking TODO reduction ==="
grep -r "TODO:" --include="*.ts" --include="*.tsx" . | wc -l
# Expected: ~400 (down from 650)

# 5. Check TypeScript errors
echo "=== Checking TypeScript ==="
timeout 30 npx tsc --noEmit --skipLibCheck
# Expected: Minimal errors
```

### **VERIFY Phase** (3-5 minutes)

**Final Phase 2 Verification**:
- [ ] **Convex functions deploy successfully**
- [ ] **Build continues to work with new Convex code**  
- [ ] **Core API routes return structured responses (not just errors)**
- [ ] **Data hooks properly structured for Convex**
- [ ] **TODO count reduced to ~400**
- [ ] **No new TypeScript errors introduced**

---

## 🚨 Implementation Priorities

### **MUST IMPLEMENT** (Core functionality):
1. **Photos CRUD** - Core photo operations
2. **File Storage** - Upload/download functionality  
3. **User Authentication** - Convex auth integration
4. **Organization Data** - Multi-tenant support

### **SHOULD IMPLEMENT** (Important features):
5. **AI Processing Queue** - Background AI processing
6. **Real-time Updates** - Live data synchronization
7. **Data Validation** - Input validation and sanitization

### **COULD IMPLEMENT** (Nice to have):
8. **Advanced Search** - Complex photo queries
9. **Analytics** - Usage tracking
10. **Audit Logging** - Action tracking

---

## 📁 File Implementation Summary

### **New Files to CREATE**:
```
convex/schema.ts - Complete Convex schema
convex/photos.ts - Photo operations
convex/users.ts - User management
convex/organizations.ts - Organization data
convex/files.ts - File storage
convex/model/auth.ts - Authentication helpers
convex/model/photos.ts - Photo business logic
```

### **Files to MODIFY** (Replace TODOs with Convex):
```
app/api/photos/route.ts - Main photo API
app/api/photos/process/route.ts - Photo processing
app/api/photos/signed-urls/route.ts - File URLs
hooks/use-photos.ts - Photo data hooks
hooks/use-ai-processing-status.ts - AI processing status
lib/photo-service.ts - Photo business logic
```

### **Expected Outcome**:
- **Convex functions**: 6-8 new function files
- **API routes**: 10+ routes with full Convex implementation  
- **Data hooks**: 5+ hooks with Convex queries
- **TODO reduction**: 650 → 400 (250 TODOs resolved)
- **Functionality**: Core photo workflows operational

---

## 🔄 Dependencies & Handoff

### **Prerequisites from Phase 1**:
- ✅ Build working (`pnpm run build` succeeds)
- ✅ All Supabase dependencies removed
- ✅ Development server starts without errors

### **Deliverables to Phase 3**:
- ✅ Complete Convex backend functionality
- ✅ Core API routes operational  
- ✅ Data persistence working
- ✅ File storage implemented
- ✅ Real-time capabilities established

### **Critical for Phase 3**:
- **Authentication integration points ready**
- **User management data flows established**
- **Organization context properly implemented**

---

**Phase 2 Created**: 2025-08-31  
**Prerequisites**: Phase 1 completion  
**Estimated Duration**: 60-75 minutes  
**Next Phase**: Phase 3 - Complete Frontend & Authentication Integration  

**This phase establishes the complete Convex backend foundation enabling all user-facing functionality in Phase 3.**