# Phase 2: Legacy Code Elimination

**Objective**: Complete removal of all Supabase dependencies and legacy patterns  
**Duration**: Day 1-2 (8 hours)  
**Priority**: 🔴 CRITICAL - Blocking clean integration  
**Success Criteria**: Zero Supabase references, consistent Convex+Clerk architecture

## 📋 Phase Overview

The codebase contains significant Supabase remnants that are causing type conflicts and preventing clean Convex integration. This phase will systematically remove all legacy code, migrate necessary functionality to Convex patterns, and ensure architectural consistency throughout the application.

## 🎯 Deliverables

1. ✅ All Supabase references removed
2. ✅ Legacy page components deleted or migrated
3. ✅ API routes updated to use Convex
4. ✅ Consistent architecture patterns throughout
5. ✅ Zero references to old patterns in codebase

## 📝 Detailed Implementation Tasks

### Task 1: Identify All Legacy Code
**Files with Supabase references:**
- `/app/(protected)/photos/page-original.tsx` - Complete Supabase implementation
- `/app/(protected)/photos/page-simplified.tsx` - Simplified Supabase version
- `/app/api/smart-albums/[id]/route.ts` - Direct supabase references (lines 33, 51, 86, 114, 151, 195, 210, 225, 239)
- `/components/ai/ai-analytics-dashboard.tsx` - createClientComponentClient reference (line 65)
- Any file with `user_metadata` pattern
- Any file importing from `@supabase/` packages

**Search and document:**
```bash
# Find all Supabase imports
grep -r "@supabase" --include="*.ts" --include="*.tsx"

# Find all user_metadata references
grep -r "user_metadata" --include="*.ts" --include="*.tsx"

# Find all Supabase client references
grep -r "supabase\." --include="*.ts" --include="*.tsx"
grep -r "createClient" --include="*.ts" --include="*.tsx"
```

### Task 2: Migrate Photos Page to Convex
**File: `/app/(protected)/photos/page.tsx`**

**Current issues:**
- Mixed Convex/Supabase patterns
- Type mismatches with PhotoWithDetails
- Missing properties in Convex schema

**New implementation:**
```typescript
"use client";

import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useState, useEffect, useMemo } from "react";
import { useAuth } from "@/hooks/useAuth";
import { useRouter, useSearchParams } from "next/navigation";
import { toast } from "sonner";

// Import components (unchanged)
import { PhotoGrid } from "@/components/photos/photo-grid";
import { PhotoFilters } from "@/components/photos/photo-filters";
import { PhotoToolbar } from "@/components/photos/photo-toolbar";
import { PhotoDetailModal } from "@/components/photos/photo-detail-modal";
import { BulkOperationsModal } from "@/components/photos/bulk-operations-modal";
import { TagManagementModal } from "@/components/photos/tag-management-modal";

export default function PhotosPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const projectId = searchParams.get("project");
  const { user, isAuthenticated, isLoading: authLoading } = useAuth();
  
  // State management
  const [selectedPhotoIds, setSelectedPhotoIds] = useState<Set<string>>(new Set());
  const [viewMode, setViewMode] = useState<"grid" | "list">("grid");
  const [showFilters, setShowFilters] = useState(true);
  const [photoDetailsModal, setPhotoDetailsModal] = useState<string | null>(null);
  const [bulkOperationsModalOpen, setBulkOperationsModalOpen] = useState(false);
  const [tagManagementModal, setTagManagementModal] = useState<string | null>(null);
  
  // Filters state
  const [filters, setFilters] = useState({
    searchQuery: "",
    projectId: projectId || undefined,
    uploaderId: undefined as string | undefined,
    aiProcessingStatus: undefined as string | undefined,
    tags: [] as string[],
    dateRange: undefined as { start: Date; end: Date } | undefined,
    machineType: undefined as string | undefined,
    riskLevel: undefined as string | undefined,
  });
  
  // Convex queries
  const photos = useQuery(api.photos.list, 
    user?.organizationId ? {
      organizationId: user.organizationId,
      projectId: filters.projectId,
      uploaderId: filters.uploaderId,
      aiStatus: filters.aiProcessingStatus as any,
    } : "skip"
  );
  
  const projects = useQuery(api.projects.list,
    user?.organizationId ? {
      organizationId: user.organizationId,
    } : "skip"
  );
  
  // Convex mutations
  const deletePhoto = useMutation(api.photos.remove);
  const updatePhoto = useMutation(api.photos.update);
  const bulkDelete = useMutation(api.photos.bulkDelete);
  const bulkUpdate = useMutation(api.photos.bulkUpdate);
  
  // Client-side filtering
  const filteredPhotos = useMemo(() => {
    if (!photos) return [];
    
    let filtered = [...photos];
    
    // Search filter
    if (filters.searchQuery) {
      const query = filters.searchQuery.toLowerCase();
      filtered = filtered.filter(photo =>
        photo.originalFilename.toLowerCase().includes(query) ||
        photo.description?.toLowerCase().includes(query)
      );
    }
    
    // Tag filter
    if (filters.tags.length > 0) {
      filtered = filtered.filter(photo =>
        filters.tags.some(tag => photo.tags?.includes(tag))
      );
    }
    
    // Date range filter
    if (filters.dateRange) {
      filtered = filtered.filter(photo => {
        const photoDate = new Date(photo._creationTime);
        return photoDate >= filters.dateRange!.start && 
               photoDate <= filters.dateRange!.end;
      });
    }
    
    // Machine type filter (from AI results)
    if (filters.machineType) {
      filtered = filtered.filter(photo =>
        photo.aiResults?.detectedObjects?.some(
          obj => obj.category === "machine" && obj.label === filters.machineType
        )
      );
    }
    
    // Risk level filter
    if (filters.riskLevel) {
      filtered = filtered.filter(photo =>
        photo.aiResults?.riskLevel === filters.riskLevel
      );
    }
    
    return filtered;
  }, [photos, filters]);
  
  // Handlers
  const handleDeletePhoto = async (photoId: string) => {
    try {
      await deletePhoto({ photoId });
      toast.success("Photo deleted successfully");
    } catch (error) {
      toast.error("Failed to delete photo");
      console.error("Delete error:", error);
    }
  };
  
  const handleBulkDelete = async () => {
    if (selectedPhotoIds.size === 0) return;
    
    try {
      await bulkDelete({ photoIds: Array.from(selectedPhotoIds) });
      toast.success(`${selectedPhotoIds.size} photos deleted`);
      setSelectedPhotoIds(new Set());
      setBulkOperationsModalOpen(false);
    } catch (error) {
      toast.error("Failed to delete photos");
      console.error("Bulk delete error:", error);
    }
  };
  
  const handleUpdatePhoto = async (photoId: string, updates: any) => {
    try {
      await updatePhoto({ photoId, ...updates });
      toast.success("Photo updated successfully");
    } catch (error) {
      toast.error("Failed to update photo");
      console.error("Update error:", error);
    }
  };
  
  // Loading and error states
  if (authLoading) {
    return <div>Loading authentication...</div>;
  }
  
  if (!isAuthenticated) {
    router.push("/login");
    return null;
  }
  
  if (!user?.organizationId) {
    return <div>No organization assigned. Please contact support.</div>;
  }
  
  return (
    <div className="flex flex-col h-full">
      <PhotoToolbar
        viewMode={viewMode}
        onViewModeChange={setViewMode}
        showFilters={showFilters}
        onToggleFilters={() => setShowFilters(!showFilters)}
        selectedCount={selectedPhotoIds.size}
        onBulkAction={() => setBulkOperationsModalOpen(true)}
        onUpload={() => router.push("/upload")}
      />
      
      {showFilters && (
        <PhotoFilters
          filters={filters}
          onFilterChange={(key, value) => 
            setFilters(prev => ({ ...prev, [key]: value }))
          }
          projects={projects || []}
        />
      )}
      
      <PhotoGrid
        photos={filteredPhotos}
        viewMode={viewMode}
        selectedIds={selectedPhotoIds}
        onPhotoSelect={(id) => {
          const newSelection = new Set(selectedPhotoIds);
          if (newSelection.has(id)) {
            newSelection.delete(id);
          } else {
            newSelection.add(id);
          }
          setSelectedPhotoIds(newSelection);
        }}
        onPhotoClick={(photo) => setPhotoDetailsModal(photo._id)}
        onPhotoDelete={handleDeletePhoto}
        onPhotoEdit={(photo) => setTagManagementModal(photo._id)}
        isLoading={photos === undefined}
      />
      
      {/* Modals */}
      {photoDetailsModal && (
        <PhotoDetailModal
          photoId={photoDetailsModal}
          onClose={() => setPhotoDetailsModal(null)}
          onEdit={(photo) => setTagManagementModal(photo._id)}
          onDelete={handleDeletePhoto}
        />
      )}
      
      {bulkOperationsModalOpen && (
        <BulkOperationsModal
          selectedIds={Array.from(selectedPhotoIds)}
          onClose={() => setBulkOperationsModalOpen(false)}
          onDelete={handleBulkDelete}
          onUpdate={(updates) => {
            // Bulk update implementation
            Promise.all(
              Array.from(selectedPhotoIds).map(id =>
                updatePhoto({ photoId: id, ...updates })
              )
            ).then(() => {
              toast.success("Photos updated successfully");
              setBulkOperationsModalOpen(false);
              setSelectedPhotoIds(new Set());
            });
          }}
        />
      )}
      
      {tagManagementModal && (
        <TagManagementModal
          photoId={tagManagementModal}
          onClose={() => setTagManagementModal(null)}
          onSave={(updates) => handleUpdatePhoto(tagManagementModal, updates)}
        />
      )}
    </div>
  );
}
```

**Delete legacy files:**
```bash
rm app/(protected)/photos/page-original.tsx
rm app/(protected)/photos/page-simplified.tsx
```

### Task 3: Migrate Smart Albums API Routes
**File: `/app/api/smart-albums/[id]/route.ts`**

This file has extensive Supabase usage. Migrate to Convex:

```typescript
import { NextRequest, NextResponse } from "next/server";
import { auth } from "@clerk/nextjs/server";
import { ConvexHttpClient } from "convex/browser";
import { api } from "@/convex/_generated/api";

const convex = new ConvexHttpClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const { userId } = await auth();
  
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  
  try {
    const album = await convex.query(api.smartAlbums.get, {
      albumId: params.id,
    });
    
    if (!album) {
      return NextResponse.json({ error: "Album not found" }, { status: 404 });
    }
    
    return NextResponse.json(album);
  } catch (error) {
    console.error("Error fetching album:", error);
    return NextResponse.json(
      { error: "Failed to fetch album" },
      { status: 500 }
    );
  }
}

export async function PUT(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const { userId } = await auth();
  
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  
  try {
    const updates = await req.json();
    
    const album = await convex.mutation(api.smartAlbums.update, {
      albumId: params.id,
      ...updates,
    });
    
    return NextResponse.json(album);
  } catch (error) {
    console.error("Error updating album:", error);
    return NextResponse.json(
      { error: "Failed to update album" },
      { status: 500 }
    );
  }
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const { userId } = await auth();
  
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  
  try {
    await convex.mutation(api.smartAlbums.remove, {
      albumId: params.id,
    });
    
    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error deleting album:", error);
    return NextResponse.json(
      { error: "Failed to delete album" },
      { status: 500 }
    );
  }
}

// Add photos to album
export async function POST(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const { userId } = await auth();
  
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  
  try {
    const { photoIds } = await req.json();
    
    await convex.mutation(api.smartAlbums.addPhotos, {
      albumId: params.id,
      photoIds,
    });
    
    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error adding photos to album:", error);
    return NextResponse.json(
      { error: "Failed to add photos" },
      { status: 500 }
    );
  }
}
```

**Create Convex functions for smart albums:**
File: `/convex/smartAlbums.ts` (NEW)

```typescript
import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { Doc, Id } from "./_generated/dataModel";

export const list = query({
  args: {
    organizationId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    
    return await ctx.db
      .query("smartAlbums")
      .withIndex("by_organization", (q) =>
        q.eq("organizationId", args.organizationId)
      )
      .collect();
  },
});

export const get = query({
  args: {
    albumId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    
    return await ctx.db.get(args.albumId as Id<"smartAlbums">);
  },
});

export const create = mutation({
  args: {
    name: v.string(),
    description: v.optional(v.string()),
    rules: v.object({
      tags: v.optional(v.array(v.string())),
      dateRange: v.optional(v.object({
        start: v.string(),
        end: v.string(),
      })),
      aiLabels: v.optional(v.array(v.string())),
    }),
    organizationId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    
    return await ctx.db.insert("smartAlbums", {
      ...args,
      createdBy: identity.subject,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      photoCount: 0,
    });
  },
});

export const update = mutation({
  args: {
    albumId: v.string(),
    name: v.optional(v.string()),
    description: v.optional(v.string()),
    rules: v.optional(v.object({
      tags: v.optional(v.array(v.string())),
      dateRange: v.optional(v.object({
        start: v.string(),
        end: v.string(),
      })),
      aiLabels: v.optional(v.array(v.string())),
    })),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    
    const { albumId, ...updates } = args;
    
    await ctx.db.patch(albumId as Id<"smartAlbums">, {
      ...updates,
      updatedAt: Date.now(),
    });
    
    return await ctx.db.get(albumId as Id<"smartAlbums">);
  },
});

export const remove = mutation({
  args: {
    albumId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    
    // Remove all photo associations first
    const associations = await ctx.db
      .query("albumPhotos")
      .withIndex("by_album", (q) => q.eq("albumId", args.albumId))
      .collect();
    
    for (const assoc of associations) {
      await ctx.db.delete(assoc._id);
    }
    
    // Remove the album
    await ctx.db.delete(args.albumId as Id<"smartAlbums">);
  },
});

export const addPhotos = mutation({
  args: {
    albumId: v.string(),
    photoIds: v.array(v.string()),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    
    // Add photo associations
    for (const photoId of args.photoIds) {
      // Check if already exists
      const existing = await ctx.db
        .query("albumPhotos")
        .withIndex("by_album_photo", (q) =>
          q.eq("albumId", args.albumId).eq("photoId", photoId)
        )
        .first();
      
      if (!existing) {
        await ctx.db.insert("albumPhotos", {
          albumId: args.albumId,
          photoId,
          addedAt: Date.now(),
        });
      }
    }
    
    // Update photo count
    const count = await ctx.db
      .query("albumPhotos")
      .withIndex("by_album", (q) => q.eq("albumId", args.albumId))
      .collect();
    
    await ctx.db.patch(args.albumId as Id<"smartAlbums">, {
      photoCount: count.length,
      updatedAt: Date.now(),
    });
  },
});
```

### Task 4: Fix AI Analytics Dashboard
**File: `/components/ai/ai-analytics-dashboard.tsx`**

Remove Supabase client and use Convex:

```typescript
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useState, useMemo } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/hooks/useAuth";

export function AIAnalyticsDashboard() {
  const { user } = useAuth();
  const [timeRange, setTimeRange] = useState<"day" | "week" | "month">("week");
  
  // Fetch analytics data from Convex
  const analytics = useQuery(api.analytics.aiProcessing, 
    user?.organizationId ? {
      organizationId: user.organizationId,
      timeRange,
    } : "skip"
  );
  
  // Process data for charts
  const chartData = useMemo(() => {
    if (!analytics) return null;
    
    return {
      processedCount: analytics.processedPhotos,
      averageConfidence: analytics.averageConfidence,
      detectedObjects: analytics.topDetectedObjects,
      processingTime: analytics.averageProcessingTime,
      costBreakdown: analytics.costBreakdown,
      errorRate: analytics.errorRate,
    };
  }, [analytics]);
  
  if (!analytics) {
    return <div>Loading analytics...</div>;
  }
  
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      <Card>
        <CardHeader>
          <CardTitle>Processed Photos</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{chartData?.processedCount}</div>
          <p className="text-xs text-muted-foreground">
            Last {timeRange}
          </p>
        </CardContent>
      </Card>
      
      <Card>
        <CardHeader>
          <CardTitle>Average Confidence</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {(chartData?.averageConfidence * 100).toFixed(1)}%
          </div>
          <p className="text-xs text-muted-foreground">
            AI detection confidence
          </p>
        </CardContent>
      </Card>
      
      <Card>
        <CardHeader>
          <CardTitle>Processing Time</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {chartData?.processingTime.toFixed(2)}s
          </div>
          <p className="text-xs text-muted-foreground">
            Average per photo
          </p>
        </CardContent>
      </Card>
      
      {/* Add more cards for other metrics */}
    </div>
  );
}
```

### Task 5: Remove Supabase Dependencies
**Package.json cleanup:**
```bash
# Remove Supabase packages
pnpm remove @supabase/supabase-js @supabase/auth-helpers-nextjs @supabase/auth-helpers-react
```

**Remove Supabase configuration files:**
```bash
# Remove Supabase client files if they exist
rm lib/supabase-client.ts
rm lib/supabase-server.ts
rm lib/supabase.ts
```

### Task 6: Update Import Statements
**Global search and replace:**

Search for and update all imports:
```typescript
// OLD
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs"
import { createServerComponentClient } from "@supabase/auth-helpers-nextjs"
import { getBrowserClient } from "@/lib/supabase-client"

// NEW - Remove or replace with Convex imports
import { useQuery, useMutation } from "convex/react"
import { api } from "@/convex/_generated/api"
```

### Task 7: Environment Variable Cleanup
**File: `.env.local`**

Remove Supabase environment variables:
```bash
# Remove these lines
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
```

Ensure Convex variables are present:
```bash
NEXT_PUBLIC_CONVEX_URL=...
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=...
CLERK_SECRET_KEY=...
```

## ✅ Validation Checklist

### Code Search Validation
```bash
# Ensure no Supabase references remain
grep -r "supabase" --include="*.ts" --include="*.tsx" | wc -l
# Expected: 0

# Ensure no user_metadata references remain
grep -r "user_metadata" --include="*.ts" --include="*.tsx" | wc -l
# Expected: 0

# Check for @supabase imports
grep -r "@supabase" --include="*.ts" --include="*.tsx" | wc -l
# Expected: 0
```

### TypeScript Validation
```bash
# Check for reduced TypeScript errors
npx tsc --noEmit 2>&1 | wc -l
# Should be significantly less than 1,037
```

### Functional Testing
- [ ] Photos page loads with Convex data
- [ ] Smart albums functionality works
- [ ] AI analytics dashboard displays data
- [ ] No console errors about missing Supabase
- [ ] All CRUD operations work through Convex

## 🔄 Rollback Plan

If removal of legacy code breaks critical functionality:

1. **Restore deleted files from git:**
   ```bash
   git checkout HEAD -- app/(protected)/photos/page-original.tsx
   ```

2. **Temporary dual-mode operation:**
   - Keep Supabase read-only for data migration
   - Write to both systems temporarily
   - Gradually phase out Supabase

3. **Incremental migration:**
   - Migrate one feature at a time
   - Keep legacy code isolated
   - Use feature flags for gradual rollout

## 📊 Success Metrics

- [ ] 0 Supabase imports in codebase
- [ ] 0 user_metadata references
- [ ] All API routes using Convex
- [ ] Photos page fully functional with Convex
- [ ] Smart albums migrated to Convex
- [ ] AI dashboard using Convex analytics
- [ ] TypeScript errors reduced by at least 200

## 🚀 Next Steps

After completing Phase 2:
1. Run full codebase search to confirm no legacy code remains
2. Test all major features to ensure functionality
3. Update MASTER-TRACKER.md with completion status
4. Document any migration issues in GAPS-LOG.md
5. Proceed to Phase 3: Type System Restoration

## 📝 Implementation Notes

**Critical Considerations:**
- Convex uses different query patterns than Supabase
- Real-time subscriptions work differently in Convex
- File storage integration needs special attention
- Authentication context is handled by Clerk, not Supabase

**Migration Patterns:**
- Supabase `.from().select()` → Convex `useQuery()`
- Supabase `.insert()` → Convex `useMutation()`
- Supabase real-time → Convex reactive queries
- Supabase RLS → Convex function-level auth checks

---

*Phase 2 eliminates technical debt and establishes a clean architecture for the remaining phases.*