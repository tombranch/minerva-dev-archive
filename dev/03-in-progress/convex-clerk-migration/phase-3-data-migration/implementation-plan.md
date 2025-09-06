# Phase 3: Data Layer Implementation - Clean Development

**Duration**: Already included in Phase 1, Day 3
**Objective**: Complete photo management with Convex storage
**Status**: Core implemented on Day 3 of Phase 1
**Environment**: Clean development - no data migration needed

---

## 🎯 Phase Overview

In our clean development approach, the data layer is built directly with Convex from Day 3 of Phase 1. No migration from Supabase is needed - we implement the optimal schema and storage solution from the start.

**What Gets Implemented**:
- ✅ **Convex Schema**: Photos, tags, categories, collections
- ✅ **File Storage**: Direct Convex storage (no Supabase Storage)
- ✅ **Real-time Queries**: Live updates for all data
- ✅ **Search Indexes**: Full-text search on photos
- ✅ **Relationships**: User-Photo-Organization associations
- ✅ **Batch Operations**: Bulk upload and processing

**No Migration = Optimal Architecture from Start**

---

## 📊 Schema Design (Day 3 Implementation)

### Complete Data Schema (`convex/schema.ts`)

```typescript
import { defineSchema, defineTable } from "convex/server"
import { v } from "convex/values"

export default defineSchema({
  // Core photo storage
  photos: defineTable({
    // Identification
    title: v.string(),
    description: v.optional(v.string()),
    
    // File storage
    storageId: v.string(), // Convex storage reference
    url: v.string(),       // Public URL for display
    thumbnailId: v.optional(v.string()), // Thumbnail storage ID
    thumbnailUrl: v.optional(v.string()),
    
    // Metadata
    size: v.number(),
    mimeType: v.string(),
    width: v.optional(v.number()),
    height: v.optional(v.number()),
    capturedAt: v.optional(v.number()),
    location: v.optional(v.object({
      lat: v.number(),
      lng: v.number(),
      name: v.optional(v.string()),
    })),
    
    // AI Processing
    aiStatus: v.union(
      v.literal("pending"),
      v.literal("processing"),
      v.literal("completed"),
      v.literal("failed")
    ),
    aiProcessedAt: v.optional(v.number()),
    aiError: v.optional(v.string()),
    
    // Machine Safety Categories
    machineType: v.optional(v.string()), // e.g., "Conveyor Belt", "Press"
    hazardTypes: v.optional(v.array(v.string())), // e.g., ["Pinch Point", "Sharp Edge"]
    safetyControls: v.optional(v.array(v.string())), // e.g., ["Emergency Stop", "Guard"]
    riskLevel: v.optional(v.union(
      v.literal("low"),
      v.literal("medium"),
      v.literal("high"),
      v.literal("critical")
    )),
    
    // Organization & User
    organizationId: v.string(),
    userId: v.string(),
    uploadSessionId: v.optional(v.string()),
    
    // Timestamps
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_organization", ["organizationId"])
    .index("by_user", ["userId"])
    .index("by_ai_status", ["aiStatus"])
    .index("by_upload_session", ["uploadSessionId"])
    .index("by_created", ["createdAt"])
    .searchIndex("search_photos", {
      searchField: "title",
      filterFields: ["organizationId", "aiStatus", "machineType"]
    }),

  // AI-detected tags
  tags: defineTable({
    photoId: v.id("photos"),
    name: v.string(),
    confidence: v.number(),
    category: v.string(), // "object", "hazard", "control", "component"
    boundingBox: v.optional(v.object({
      x: v.number(),
      y: v.number(),
      width: v.number(),
      height: v.number(),
    })),
    createdAt: v.number(),
  })
    .index("by_photo", ["photoId"])
    .index("by_name", ["name"])
    .index("by_category", ["category"]),

  // Photo collections/albums
  collections: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    coverPhotoId: v.optional(v.id("photos")),
    isPublic: v.boolean(),
    organizationId: v.string(),
    userId: v.string(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_organization", ["organizationId"])
    .index("by_user", ["userId"]),

  // Many-to-many: photos in collections
  collectionPhotos: defineTable({
    collectionId: v.id("collections"),
    photoId: v.id("photos"),
    addedAt: v.number(),
    addedBy: v.string(),
  })
    .index("by_collection", ["collectionId"])
    .index("by_photo", ["photoId"]),

  // Upload sessions for batch processing
  uploadSessions: defineTable({
    organizationId: v.string(),
    userId: v.string(),
    totalFiles: v.number(),
    processedFiles: v.number(),
    failedFiles: v.number(),
    status: v.union(
      v.literal("uploading"),
      v.literal("processing"),
      v.literal("completed"),
      v.literal("failed")
    ),
    startedAt: v.number(),
    completedAt: v.optional(v.number()),
  })
    .index("by_organization", ["organizationId"])
    .index("by_user", ["userId"])
    .index("by_status", ["status"]),

  // Already defined in Phase 2
  users: defineTable({
    clerkUserId: v.string(),
    email: v.string(),
    name: v.string(),
    avatarUrl: v.optional(v.string()),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_clerk_id", ["clerkUserId"]),

  organizations: defineTable({
    clerkOrgId: v.string(),
    name: v.string(),
    slug: v.string(),
    logoUrl: v.optional(v.string()),
    
    // Limits
    maxPhotos: v.number(),
    maxStorage: v.number(), // in bytes
    currentPhotos: v.number(),
    currentStorage: v.number(),
    
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_clerk_id", ["clerkOrgId"]),
})
```

---

## 🔄 Core Functions (Day 3-4 Implementation)

### Photo Upload with Storage

```typescript
// convex/photos.ts
import { mutation } from "./_generated/server"
import { v } from "convex/values"

export const uploadPhoto = mutation({
  args: {
    title: v.string(),
    storageId: v.string(),
    size: v.number(),
    mimeType: v.string(),
    width: v.optional(v.number()),
    height: v.optional(v.number()),
    uploadSessionId: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity()
    if (!identity) throw new Error("Not authenticated")
    
    const orgId = identity.orgId
    if (!orgId) throw new Error("No organization selected")
    
    // Get storage URL
    const url = await ctx.storage.getUrl(args.storageId)
    if (!url) throw new Error("Failed to get storage URL")
    
    // Create photo record
    const photoId = await ctx.db.insert("photos", {
      ...args,
      url,
      aiStatus: "pending",
      organizationId: orgId,
      userId: identity.subject,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    })
    
    // Schedule AI processing
    await ctx.scheduler.runAfter(0, api.ai.processPhoto, { photoId })
    
    return photoId
  },
})

export const generateUploadUrl = mutation({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity()
    if (!identity) throw new Error("Not authenticated")
    
    // Generate secure upload URL
    return await ctx.storage.generateUploadUrl()
  },
})
```

### Real-time Photo Queries

```typescript
// convex/photos.ts
import { query } from "./_generated/server"
import { v } from "convex/values"

export const listPhotos = query({
  args: {
    limit: v.optional(v.number()),
    cursor: v.optional(v.string()),
    aiStatus: v.optional(v.string()),
    searchTerm: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity()
    if (!identity?.orgId) return []
    
    let photos = ctx.db
      .query("photos")
      .withIndex("by_organization", q => 
        q.eq("organizationId", identity.orgId)
      )
    
    if (args.searchTerm) {
      photos = ctx.db
        .query("photos")
        .withSearchIndex("search_photos", q =>
          q.search("title", args.searchTerm)
            .eq("organizationId", identity.orgId)
        )
    }
    
    if (args.aiStatus) {
      photos = photos.filter(q => q.eq(q.field("aiStatus"), args.aiStatus))
    }
    
    return await photos
      .order("desc")
      .take(args.limit || 50)
  },
})

// Real-time upload session status
export const getUploadSession = query({
  args: { sessionId: v.id("uploadSessions") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.sessionId)
  },
})
```

---

## 🚀 Storage Implementation

### Direct Convex Storage Benefits

**No External Dependencies**:
- Built-in file storage with Convex
- 10GB free tier included
- $0.20/GB after free tier
- Automatic CDN distribution
- Secure signed URLs

**Implementation**:
```typescript
// app/components/upload/photo-uploader.tsx
import { useMutation } from "convex/react"
import { api } from "@/convex/_generated/api"

export function PhotoUploader() {
  const generateUploadUrl = useMutation(api.photos.generateUploadUrl)
  const uploadPhoto = useMutation(api.photos.uploadPhoto)
  
  const handleUpload = async (file: File) => {
    // Get upload URL
    const uploadUrl = await generateUploadUrl()
    
    // Upload to Convex storage
    const response = await fetch(uploadUrl, {
      method: "POST",
      body: file,
    })
    const { storageId } = await response.json()
    
    // Create photo record
    await uploadPhoto({
      title: file.name,
      storageId,
      size: file.size,
      mimeType: file.type,
    })
  }
  
  // Component UI...
}
```

---

## ✅ Phase 3 Deliverables

All implemented as part of Phase 1:

- [x] Complete schema design
- [x] Photo CRUD operations
- [x] File upload to Convex storage
- [x] Real-time queries and subscriptions
- [x] Search functionality
- [x] Batch upload support
- [x] Collections/albums
- [x] Tag management
- [x] Organization limits

---

## 📝 Key Differences from Supabase

**Advantages of Convex Approach**:
1. **No RLS Policies**: Security at function level
2. **Built-in Storage**: No separate storage service
3. **Real-time by Default**: All queries are reactive
4. **Type Safety**: Schema generates TypeScript types
5. **Simpler Relations**: No complex joins needed

**What We Don't Need**:
- PostgreSQL migrations
- Storage bucket configuration
- RLS policy management
- Separate real-time setup
- Manual type generation

---

## 🚀 Next Steps

With data layer complete:
- **Phase 4**: AI processing pipeline
- **Phase 5**: Advanced features (export, analytics)
- **Phase 6**: Production optimization

The clean development approach means we have the ideal architecture from day one!