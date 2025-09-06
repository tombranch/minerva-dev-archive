# Phase 4: Frontend-Backend Integration

**Objective**: Complete Convex integration across all frontend features  
**Duration**: Day 3-4 (10 hours)  
**Priority**: 🔴 CRITICAL - Features non-functional without proper integration  
**Success Criteria**: All UI components connected to Convex, real-time features working

## 📋 Phase Overview

With authentication fixed, legacy code removed, and types restored, this phase focuses on properly connecting all frontend components to the Convex backend. This includes implementing real-time subscriptions, file storage integration, and ensuring all CRUD operations work end-to-end.

## 🎯 Deliverables

1. ✅ All UI components using Convex queries and mutations
2. ✅ Real-time subscriptions implemented
3. ✅ File upload/storage integration complete
4. ✅ Search and filtering working with Convex
5. ✅ Export functionality connected
6. ✅ Admin features fully integrated

## 📝 Detailed Implementation Tasks

### Task 1: Photo Management Integration

**File: `/components/photos/photo-grid.tsx`**

Update to use Convex data structure:
```typescript
import { Doc, Id } from "@/convex/_generated/dataModel";
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

interface PhotoGridProps {
  photos: Doc<"photos">[];
  viewMode: "grid" | "list";
  selectedIds: Set<string>;
  onPhotoSelect: (id: string) => void;
  onPhotoClick: (photo: Doc<"photos">) => void;
  onPhotoDelete: (id: string) => void;
  onPhotoEdit: (photo: Doc<"photos">) => void;
  isLoading: boolean;
}

export function PhotoGrid({
  photos,
  viewMode,
  selectedIds,
  onPhotoSelect,
  onPhotoClick,
  onPhotoDelete,
  onPhotoEdit,
  isLoading,
}: PhotoGridProps) {
  // Get photo URLs from Convex storage
  const getPhotoUrl = (fileId: Id<"_storage">) => {
    // This will be implemented with Convex storage URL generation
    return `/api/storage/${fileId}`;
  };
  
  if (isLoading) {
    return <PhotoGridSkeleton />;
  }
  
  if (!photos || photos.length === 0) {
    return <EmptyState />;
  }
  
  return (
    <div className={viewMode === "grid" ? "grid grid-cols-3 gap-4" : "space-y-2"}>
      {photos.map((photo) => (
        <PhotoCard
          key={photo._id}
          photo={photo}
          isSelected={selectedIds.has(photo._id)}
          onSelect={() => onPhotoSelect(photo._id)}
          onClick={() => onPhotoClick(photo)}
          onDelete={() => onPhotoDelete(photo._id)}
          onEdit={() => onPhotoEdit(photo)}
          imageUrl={getPhotoUrl(photo.fileId)}
          thumbnailUrl={photo.thumbnailId ? getPhotoUrl(photo.thumbnailId) : undefined}
        />
      ))}
    </div>
  );
}
```

**File: `/components/photos/photo-detail-modal.tsx`**

Integrate with Convex for real-time updates:
```typescript
import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Id } from "@/convex/_generated/dataModel";

interface PhotoDetailModalProps {
  photoId: string;
  onClose: () => void;
  onEdit: (photo: any) => void;
  onDelete: (photoId: string) => void;
}

export function PhotoDetailModal({
  photoId,
  onClose,
  onEdit,
  onDelete,
}: PhotoDetailModalProps) {
  // Real-time photo data
  const photo = useQuery(api.photos.get, { 
    photoId: photoId as Id<"photos"> 
  });
  
  // Get related data
  const aiResults = useQuery(api.aiProcessing.getResults, 
    photo ? { photoId: photo._id } : "skip"
  );
  
  const tags = useQuery(api.tags.getForPhoto,
    photo ? { photoId: photo._id } : "skip"
  );
  
  // Mutations
  const updateDescription = useMutation(api.photos.updateDescription);
  const addTag = useMutation(api.tags.add);
  const removeTag = useMutation(api.tags.remove);
  
  if (!photo) {
    return <LoadingSpinner />;
  }
  
  return (
    <Modal open onClose={onClose}>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <img 
            src={`/api/storage/${photo.fileId}`}
            alt={photo.originalFilename}
            className="w-full"
          />
        </div>
        
        <div className="space-y-4">
          <h2 className="text-2xl font-bold">{photo.originalFilename}</h2>
          
          {/* Editable description */}
          <EditableText
            value={photo.description || ""}
            onSave={(value) => 
              updateDescription({ photoId: photo._id, description: value })
            }
            placeholder="Add description..."
          />
          
          {/* Tags with real-time updates */}
          <div className="flex flex-wrap gap-2">
            {tags?.map((tag) => (
              <Badge key={tag._id} variant="secondary">
                {tag.name}
                <button
                  onClick={() => removeTag({ tagId: tag._id })}
                  className="ml-1"
                >
                  ×
                </button>
              </Badge>
            ))}
            <AddTagButton
              onAdd={(tagName) => 
                addTag({ photoId: photo._id, name: tagName })
              }
            />
          </div>
          
          {/* AI Results */}
          {aiResults && (
            <AIResultsDisplay results={aiResults} />
          )}
          
          {/* Metadata */}
          <PhotoMetadata photo={photo} />
          
          {/* Actions */}
          <div className="flex gap-2">
            <Button onClick={() => onEdit(photo)}>Edit</Button>
            <Button 
              variant="destructive"
              onClick={() => {
                onDelete(photo._id);
                onClose();
              }}
            >
              Delete
            </Button>
          </div>
        </div>
      </div>
    </Modal>
  );
}
```

### Task 2: Upload System Integration

**File: `/components/upload/upload-zone.tsx`**

Integrate with Convex file storage:
```typescript
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useUploadFiles } from "@/hooks/use-upload-files";

export function UploadZone() {
  const generateUploadUrl = useMutation(api.files.generateUploadUrl);
  const createPhoto = useMutation(api.photos.create);
  const { uploadFiles, progress, isUploading } = useUploadFiles();
  
  const handleDrop = async (acceptedFiles: File[]) => {
    try {
      // Process each file
      const uploadPromises = acceptedFiles.map(async (file) => {
        // Generate upload URL from Convex
        const uploadUrl = await generateUploadUrl();
        
        // Upload file to Convex storage
        const result = await fetch(uploadUrl, {
          method: "POST",
          headers: { "Content-Type": file.type },
          body: file,
        });
        
        const { storageId } = await result.json();
        
        // Create photo record in database
        const photo = await createPhoto({
          originalFilename: file.name,
          fileId: storageId,
          fileSize: file.size,
          mimeType: file.type,
          width: 0, // Will be updated by AI processing
          height: 0,
        });
        
        return photo;
      });
      
      const photos = await Promise.all(uploadPromises);
      toast.success(`Uploaded ${photos.length} photos`);
      
      // Trigger AI processing for each photo
      for (const photo of photos) {
        await triggerAIProcessing(photo._id);
      }
    } catch (error) {
      toast.error("Upload failed");
      console.error(error);
    }
  };
  
  return (
    <Dropzone onDrop={handleDrop}>
      {({ getRootProps, getInputProps, isDragActive }) => (
        <div
          {...getRootProps()}
          className={cn(
            "border-2 border-dashed rounded-lg p-8 text-center",
            isDragActive && "border-primary bg-primary/5"
          )}
        >
          <input {...getInputProps()} />
          {isUploading ? (
            <UploadProgress progress={progress} />
          ) : (
            <UploadPrompt isDragActive={isDragActive} />
          )}
        </div>
      )}
    </Dropzone>
  );
}
```

**File: `/hooks/use-upload-files.ts` (NEW)**

```typescript
import { useState, useCallback } from "react";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

interface UploadProgress {
  [filename: string]: number;
}

export function useUploadFiles() {
  const [progress, setProgress] = useState<UploadProgress>({});
  const [isUploading, setIsUploading] = useState(false);
  
  const generateUploadUrl = useMutation(api.files.generateUploadUrl);
  
  const uploadFile = useCallback(async (file: File) => {
    // Track progress
    setProgress(prev => ({ ...prev, [file.name]: 0 }));
    
    // Get upload URL
    const uploadUrl = await generateUploadUrl();
    
    // Create upload with progress tracking
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      
      xhr.upload.addEventListener("progress", (e) => {
        if (e.lengthComputable) {
          const percentComplete = (e.loaded / e.total) * 100;
          setProgress(prev => ({ ...prev, [file.name]: percentComplete }));
        }
      });
      
      xhr.addEventListener("load", () => {
        if (xhr.status === 200) {
          const response = JSON.parse(xhr.responseText);
          resolve(response);
        } else {
          reject(new Error(`Upload failed: ${xhr.statusText}`));
        }
      });
      
      xhr.addEventListener("error", () => {
        reject(new Error("Upload failed"));
      });
      
      xhr.open("POST", uploadUrl);
      xhr.setRequestHeader("Content-Type", file.type);
      xhr.send(file);
    });
  }, [generateUploadUrl]);
  
  const uploadFiles = useCallback(async (files: File[]) => {
    setIsUploading(true);
    setProgress({});
    
    try {
      const results = await Promise.all(files.map(uploadFile));
      return results;
    } finally {
      setIsUploading(false);
      setProgress({});
    }
  }, [uploadFile]);
  
  return {
    uploadFiles,
    uploadFile,
    progress,
    isUploading,
  };
}
```

### Task 3: Search and Filtering Integration

**File: `/components/photos/photo-filters.tsx`**

Connect filters to Convex queries:
```typescript
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useAuth } from "@/hooks/useAuth";

interface PhotoFiltersProps {
  filters: FilterState;
  onFilterChange: (key: string, value: any) => void;
  projects: any[];
}

export function PhotoFilters({
  filters,
  onFilterChange,
  projects,
}: PhotoFiltersProps) {
  const { user } = useAuth();
  
  // Get filter options from Convex
  const tags = useQuery(api.tags.list, 
    user?.organizationId ? {
      organizationId: user.organizationId,
    } : "skip"
  );
  
  const users = useQuery(api.users.listInOrganization,
    user?.organizationId ? {
      organizationId: user.organizationId,
    } : "skip"
  );
  
  const aiLabels = useQuery(api.aiProcessing.getUniqueLabels,
    user?.organizationId ? {
      organizationId: user.organizationId,
    } : "skip"
  );
  
  return (
    <div className="border-b p-4 space-y-4">
      <div className="flex gap-4">
        {/* Search */}
        <Input
          placeholder="Search photos..."
          value={filters.searchQuery}
          onChange={(e) => onFilterChange("searchQuery", e.target.value)}
          className="max-w-sm"
        />
        
        {/* Project filter */}
        <Select
          value={filters.projectId}
          onValueChange={(value) => onFilterChange("projectId", value)}
        >
          <SelectTrigger className="w-48">
            <SelectValue placeholder="All projects" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">All projects</SelectItem>
            {projects?.map((project) => (
              <SelectItem key={project._id} value={project._id}>
                {project.name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        
        {/* Uploader filter */}
        <Select
          value={filters.uploaderId}
          onValueChange={(value) => onFilterChange("uploaderId", value)}
        >
          <SelectTrigger className="w-48">
            <SelectValue placeholder="All uploaders" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">All uploaders</SelectItem>
            {users?.map((user) => (
              <SelectItem key={user._id} value={user._id}>
                {user.name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        
        {/* AI Status filter */}
        <Select
          value={filters.aiProcessingStatus}
          onValueChange={(value) => onFilterChange("aiProcessingStatus", value)}
        >
          <SelectTrigger className="w-48">
            <SelectValue placeholder="AI status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">All statuses</SelectItem>
            <SelectItem value="pending">Pending</SelectItem>
            <SelectItem value="processing">Processing</SelectItem>
            <SelectItem value="completed">Completed</SelectItem>
            <SelectItem value="failed">Failed</SelectItem>
          </SelectContent>
        </Select>
      </div>
      
      {/* Tag filter */}
      <div className="flex gap-2 items-center">
        <span className="text-sm text-muted-foreground">Tags:</span>
        <div className="flex gap-2">
          {tags?.map((tag) => (
            <Badge
              key={tag._id}
              variant={filters.tags?.includes(tag.name) ? "default" : "outline"}
              className="cursor-pointer"
              onClick={() => {
                const currentTags = filters.tags || [];
                const newTags = currentTags.includes(tag.name)
                  ? currentTags.filter(t => t !== tag.name)
                  : [...currentTags, tag.name];
                onFilterChange("tags", newTags);
              }}
            >
              {tag.name} ({tag.count})
            </Badge>
          ))}
        </div>
      </div>
      
      {/* Date range filter */}
      <DateRangePicker
        value={filters.dateRange}
        onChange={(range) => onFilterChange("dateRange", range)}
      />
      
      {/* Machine type filter (from AI) */}
      {aiLabels && aiLabels.machineTypes && (
        <Select
          value={filters.machineType}
          onValueChange={(value) => onFilterChange("machineType", value)}
        >
          <SelectTrigger className="w-48">
            <SelectValue placeholder="Machine type" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">All types</SelectItem>
            {aiLabels.machineTypes.map((type) => (
              <SelectItem key={type} value={type}>
                {type}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      )}
      
      {/* Risk level filter */}
      <Select
        value={filters.riskLevel}
        onValueChange={(value) => onFilterChange("riskLevel", value)}
      >
        <SelectTrigger className="w-48">
          <SelectValue placeholder="Risk level" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="">All levels</SelectItem>
          <SelectItem value="low">Low Risk</SelectItem>
          <SelectItem value="medium">Medium Risk</SelectItem>
          <SelectItem value="high">High Risk</SelectItem>
        </SelectContent>
      </Select>
    </div>
  );
}
```

### Task 4: Real-time Subscriptions

**File: `/components/photos/real-time-indicator.tsx` (NEW)**

```typescript
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useEffect, useState } from "react";

export function RealTimeIndicator() {
  const [isConnected, setIsConnected] = useState(true);
  
  // Subscribe to connection status
  const status = useQuery(api.system.connectionStatus);
  
  useEffect(() => {
    if (status) {
      setIsConnected(status.connected);
    }
  }, [status]);
  
  return (
    <div className="flex items-center gap-2">
      <div className={cn(
        "w-2 h-2 rounded-full",
        isConnected ? "bg-green-500" : "bg-red-500"
      )} />
      <span className="text-xs text-muted-foreground">
        {isConnected ? "Live" : "Reconnecting..."}
      </span>
    </div>
  );
}
```

**File: `/hooks/use-real-time-photos.ts` (NEW)**

```typescript
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useEffect, useRef } from "react";
import { toast } from "sonner";

export function useRealTimePhotos(organizationId: string | null) {
  const prevPhotosRef = useRef<any[]>([]);
  
  const photos = useQuery(api.photos.list,
    organizationId ? { organizationId } : "skip"
  );
  
  useEffect(() => {
    if (!photos) return;
    
    const prevPhotos = prevPhotosRef.current;
    
    // Detect new photos
    const newPhotos = photos.filter(
      photo => !prevPhotos.some(p => p._id === photo._id)
    );
    
    // Detect deleted photos
    const deletedPhotos = prevPhotos.filter(
      photo => !photos.some(p => p._id === photo._id)
    );
    
    // Show notifications for changes
    if (newPhotos.length > 0) {
      toast.info(`${newPhotos.length} new photo(s) added`);
    }
    
    if (deletedPhotos.length > 0) {
      toast.info(`${deletedPhotos.length} photo(s) removed`);
    }
    
    prevPhotosRef.current = photos;
  }, [photos]);
  
  return photos;
}
```

### Task 5: Export Functionality

**File: `/components/export/export-dialog.tsx`**

Connect to Convex export functions:
```typescript
import { useMutation, useAction } from "convex/react";
import { api } from "@/convex/_generated/api";

export function ExportDialog({
  selectedPhotoIds,
  onClose,
}: {
  selectedPhotoIds: string[];
  onClose: () => void;
}) {
  const [format, setFormat] = useState<"csv" | "json" | "pdf">("csv");
  const [isExporting, setIsExporting] = useState(false);
  
  const generateExport = useAction(api.export.generate);
  
  const handleExport = async () => {
    setIsExporting(true);
    
    try {
      const result = await generateExport({
        photoIds: selectedPhotoIds,
        format,
        includeAIResults: true,
        includeTags: true,
      });
      
      // Download the exported file
      const blob = new Blob([result.data], { 
        type: result.mimeType 
      });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `export-${Date.now()}.${format}`;
      a.click();
      URL.revokeObjectURL(url);
      
      toast.success("Export completed");
      onClose();
    } catch (error) {
      toast.error("Export failed");
      console.error(error);
    } finally {
      setIsExporting(false);
    }
  };
  
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Export Photos</DialogTitle>
          <DialogDescription>
            Export {selectedPhotoIds.length} selected photos
          </DialogDescription>
        </DialogHeader>
        
        <div className="space-y-4">
          <RadioGroup value={format} onValueChange={setFormat}>
            <div className="flex items-center space-x-2">
              <RadioGroupItem value="csv" id="csv" />
              <Label htmlFor="csv">CSV - Spreadsheet format</Label>
            </div>
            <div className="flex items-center space-x-2">
              <RadioGroupItem value="json" id="json" />
              <Label htmlFor="json">JSON - Developer format</Label>
            </div>
            <div className="flex items-center space-x-2">
              <RadioGroupItem value="pdf" id="pdf" />
              <Label htmlFor="pdf">PDF - Report format</Label>
            </div>
          </RadioGroup>
        </div>
        
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleExport} disabled={isExporting}>
            {isExporting ? <LoadingSpinner /> : "Export"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
```

### Task 6: Admin Features Integration

**File: `/app/(protected)/admin/dashboard/page.tsx`**

Connect admin dashboard to Convex:
```typescript
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { AdminGuard } from "@/components/admin/AdminGuard";

export default function AdminDashboard() {
  const stats = useQuery(api.admin.getStats);
  const recentActivity = useQuery(api.admin.getRecentActivity);
  const systemHealth = useQuery(api.monitoring.getSystemHealth);
  
  return (
    <AdminGuard>
      <div className="space-y-6">
        <h1 className="text-3xl font-bold">Admin Dashboard</h1>
        
        {/* Statistics Cards */}
        <div className="grid grid-cols-4 gap-4">
          <StatCard
            title="Total Users"
            value={stats?.totalUsers || 0}
            change={stats?.userGrowth}
          />
          <StatCard
            title="Total Photos"
            value={stats?.totalPhotos || 0}
            change={stats?.photoGrowth}
          />
          <StatCard
            title="Storage Used"
            value={formatBytes(stats?.storageUsed || 0)}
            change={stats?.storageGrowth}
          />
          <StatCard
            title="AI Processed"
            value={stats?.aiProcessed || 0}
            change={stats?.aiGrowth}
          />
        </div>
        
        {/* System Health */}
        <Card>
          <CardHeader>
            <CardTitle>System Health</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <HealthIndicator
                label="API Response Time"
                value={systemHealth?.apiResponseTime}
                threshold={200}
                unit="ms"
              />
              <HealthIndicator
                label="Database Queries"
                value={systemHealth?.dbQueryTime}
                threshold={100}
                unit="ms"
              />
              <HealthIndicator
                label="AI Processing Queue"
                value={systemHealth?.aiQueueLength}
                threshold={50}
                unit="items"
              />
              <HealthIndicator
                label="Error Rate"
                value={systemHealth?.errorRate}
                threshold={1}
                unit="%"
              />
            </div>
          </CardContent>
        </Card>
        
        {/* Recent Activity */}
        <Card>
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
          </CardHeader>
          <CardContent>
            <ActivityFeed activities={recentActivity || []} />
          </CardContent>
        </Card>
      </div>
    </AdminGuard>
  );
}
```

### Task 7: Storage URL Resolution

**File: `/convex/files.ts`**

Add storage URL generation:
```typescript
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

export const generateUploadUrl = mutation({
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

export const getUrl = query({
  args: { storageId: v.string() },
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);
  },
});

export const deleteFile = mutation({
  args: { storageId: v.string() },
  handler: async (ctx, args) => {
    await ctx.storage.delete(args.storageId);
  },
});
```

**File: `/app/api/storage/[id]/route.ts` (NEW)**

Proxy for serving Convex storage files:
```typescript
import { NextRequest, NextResponse } from "next/server";
import { ConvexHttpClient } from "convex/browser";
import { api } from "@/convex/_generated/api";

const convex = new ConvexHttpClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const url = await convex.query(api.files.getUrl, {
      storageId: params.id,
    });
    
    if (!url) {
      return new NextResponse("File not found", { status: 404 });
    }
    
    // Fetch the file from Convex storage
    const response = await fetch(url);
    const blob = await response.blob();
    
    return new NextResponse(blob, {
      headers: {
        "Content-Type": response.headers.get("Content-Type") || "application/octet-stream",
        "Cache-Control": "public, max-age=31536000",
      },
    });
  } catch (error) {
    console.error("Storage fetch error:", error);
    return new NextResponse("Internal error", { status: 500 });
  }
}
```

## ✅ Validation Checklist

### Integration Testing
```bash
# Test photo operations
pnpm test components/photos
pnpm test hooks/use-photos

# Test upload functionality
pnpm test components/upload
pnpm test hooks/use-upload-files

# Test real-time features
pnpm test hooks/use-real-time-photos
```

### Manual Testing Checklist
- [ ] Photos load and display correctly
- [ ] Upload works with progress tracking
- [ ] Real-time updates when photos added/deleted
- [ ] Search and filters work properly
- [ ] Photo details modal shows all data
- [ ] Tags can be added/removed
- [ ] Export generates correct files
- [ ] Admin dashboard shows real stats
- [ ] File URLs resolve correctly
- [ ] AI processing triggers on upload

### Performance Testing
```bash
# Check bundle size
pnpm run analyze

# Test real-time performance
# Open multiple browser tabs and verify updates sync

# Check network requests
# Verify Convex subscriptions are efficient
```

## 🔄 Rollback Plan

If integration causes critical issues:

1. **Revert to mock data temporarily:**
   ```typescript
   // Use mock data while fixing integration
   const photos = useMockPhotos() || useQuery(api.photos.list, ...);
   ```

2. **Disable real-time features:**
   ```typescript
   // Fall back to polling
   useInterval(() => refetch(), 5000);
   ```

3. **Use local storage for uploads:**
   ```typescript
   // Store locally first, sync later
   await saveToLocalStorage(file);
   await syncToConvex();
   ```

## 📊 Success Metrics

- [ ] All UI components using Convex queries
- [ ] Real-time updates working across sessions
- [ ] File upload/download functional
- [ ] Search returns correct results
- [ ] Filters apply properly
- [ ] Export generates valid files
- [ ] Admin features show real data
- [ ] No console errors in browser
- [ ] Network tab shows efficient queries

## 🚀 Next Steps

After completing Phase 4:
1. Test all user workflows end-to-end
2. Verify real-time features across multiple sessions
3. Check performance metrics
4. Update MASTER-TRACKER.md with completion status
5. Document any integration issues in GAPS-LOG.md
6. Proceed to Phase 5: Test Suite Restoration

## 📝 Implementation Notes

**Convex Integration Patterns:**
- Use `useQuery` for reactive data fetching
- Use `useMutation` for data modifications
- Use `useAction` for complex server operations
- Implement proper loading and error states
- Handle "skip" conditions for conditional queries

**Real-time Considerations:**
- Convex queries are reactive by default
- Updates propagate automatically
- No need for manual refetch or polling
- Consider optimistic updates for better UX

**Storage Best Practices:**
- Generate upload URLs server-side
- Use storage IDs, not direct URLs
- Implement proper access control
- Cache URLs when appropriate
- Handle large files with streaming

---

*Phase 4 brings the application to life with full frontend-backend integration and real-time capabilities.*