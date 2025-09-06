# Archive Photos & Soft Delete Implementation Plan

**Status:** Planning Phase  
**Created:** 2025-07-21  
**Priority:** Medium-High  
**Estimated Effort:** 15-20 hours  

## Overview

This plan outlines a comprehensive implementation of:
1. **Archive Photos** - Move photos to archive state with 30-day retention
2. **Soft Delete System** - Unified soft delete across all entities  
3. **Cascading Deletion Strategy** - Handle organization and entity deletion with child relationships

## Current Database Analysis

### Entity Hierarchy
```
organizations (root level)
├── users (belongs to organization)
├── sites (belongs to organization, optional created_by user)  
├── projects (belongs to organization, optional created_by user)
├── photos (belongs to organization, uploader_id user, optional project_id)
├── albums (belongs to organization, creator_id user)
└── supporting tables (audit_logs, ai_* tables, upload_sessions, etc.)
```

### Existing Soft Delete Patterns
- `organizations.is_active` - Boolean deactivation flag
- `sites.is_active` - Boolean deactivation flag
- `projects.status` - Enum: 'active', 'archived', 'completed'
- `user_sessions.is_active` - Session management flag

### Current Deletion Strategy
- **Hard cascading deletes** with ON DELETE CASCADE constraints
- **Storage cleanup triggers** for photos and user avatars
- **SET NULL constraints** for some optional foreign keys
- **No unified soft delete approach**

## Implementation Strategy

### Phase 1: Soft Delete Infrastructure (4-5 hours)

#### 1.1 Database Schema Changes
```sql
-- Create soft delete columns for core tables
ALTER TABLE photos ADD COLUMN 
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES users(id) ON DELETE SET NULL,
  deletion_reason TEXT;

ALTER TABLE albums ADD COLUMN
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE projects ADD COLUMN
  deleted_at TIMESTAMPTZ, 
  deleted_by UUID REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE users ADD COLUMN
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE organizations ADD COLUMN
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES users(id) ON DELETE SET NULL;
```

#### 1.2 Indexes for Performance
```sql
-- Add indexes for soft delete queries
CREATE INDEX idx_photos_deleted_at ON photos(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_albums_deleted_at ON albums(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_projects_deleted_at ON projects(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_organizations_deleted_at ON organizations(deleted_at) WHERE deleted_at IS NOT NULL;
```

#### 1.3 Soft Delete Helper Functions
```sql
-- Generic soft delete function
CREATE OR REPLACE FUNCTION soft_delete(
  table_name TEXT,
  record_id UUID,
  deleter_id UUID,
  reason TEXT DEFAULT NULL
) RETURNS BOOLEAN;

-- Restore from soft delete
CREATE OR REPLACE FUNCTION restore_soft_deleted(
  table_name TEXT,
  record_id UUID,
  restorer_id UUID
) RETURNS BOOLEAN;

-- Check if record is soft deleted
CREATE OR REPLACE FUNCTION is_soft_deleted(
  table_name TEXT,
  record_id UUID
) RETURNS BOOLEAN;
```

### Phase 2: Archive Photos Feature (3-4 hours)

#### 2.1 Archive-Specific Columns
```sql
-- Add archive functionality to photos
ALTER TABLE photos ADD COLUMN
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id) ON DELETE SET NULL,
  archive_reason TEXT,
  archive_batch_id UUID; -- For bulk operations tracking

-- Archive batch tracking table
CREATE TABLE archive_batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  criteria JSONB, -- Store archive criteria (date range, project, etc.)
  photo_count INTEGER,
  completed_at TIMESTAMPTZ
);
```

#### 2.2 Archive Management Functions
```sql
-- Archive single photo
CREATE OR REPLACE FUNCTION archive_photo(
  photo_id UUID,
  archiver_id UUID,
  reason TEXT DEFAULT 'Manual archive'
) RETURNS BOOLEAN;

-- Bulk archive by criteria
CREATE OR REPLACE FUNCTION archive_photos_bulk(
  organization_id UUID,
  archiver_id UUID,
  criteria JSONB, -- {project_id, date_range, tags, etc.}
  reason TEXT DEFAULT 'Bulk archive'
) RETURNS UUID; -- Returns batch_id

-- Restore archived photo
CREATE OR REPLACE FUNCTION restore_archived_photo(
  photo_id UUID,
  restorer_id UUID
) RETURNS BOOLEAN;
```

#### 2.3 30-Day Auto-Cleanup
```sql
-- Cleanup job for permanent deletion after 30 days
CREATE OR REPLACE FUNCTION cleanup_archived_photos()
RETURNS INTEGER AS $$
DECLARE
  cleanup_count INTEGER;
BEGIN
  -- Permanently delete photos archived > 30 days ago
  WITH deleted_photos AS (
    DELETE FROM photos 
    WHERE archived_at IS NOT NULL 
    AND archived_at < NOW() - INTERVAL '30 days'
    RETURNING id, storage_path, thumbnail_path
  )
  SELECT COUNT(*) INTO cleanup_count FROM deleted_photos;
  
  -- Log cleanup operation
  INSERT INTO audit_logs (organization_id, action, details)
  SELECT DISTINCT organization_id, 'auto_cleanup_archived_photos', 
    jsonb_build_object('deleted_count', cleanup_count)
  FROM photos WHERE archived_at < NOW() - INTERVAL '30 days';
  
  RETURN cleanup_count;
END;
$$ LANGUAGE plpgsql;

-- Schedule cleanup job (requires pg_cron extension or external scheduler)
-- SELECT cron.schedule('cleanup-archived-photos', '0 2 * * *', 'SELECT cleanup_archived_photos();');
```

### Phase 3: Cascading Deletion Strategy (4-5 hours)

#### 3.1 Photo Deletion Cascade
When a photo is soft deleted:
```sql
CREATE OR REPLACE FUNCTION cascade_soft_delete_photo()
RETURNS TRIGGER AS $$
BEGIN
  -- Junction tables: hard delete (no historical value)
  DELETE FROM photo_tags WHERE photo_id = NEW.id;
  DELETE FROM album_photos WHERE photo_id = NEW.id;
  DELETE FROM photo_shares WHERE photo_id = NEW.id;
  
  -- Preserve notes and AI results for audit/analytics
  UPDATE photo_notes 
  SET deleted_at = NEW.deleted_at, deleted_by = NEW.deleted_by 
  WHERE photo_id = NEW.id AND deleted_at IS NULL;
  
  UPDATE ai_processing_results 
  SET deleted_at = NEW.deleted_at, deleted_by = NEW.deleted_by 
  WHERE photo_id = NEW.id AND deleted_at IS NULL;
  
  -- Queue storage cleanup (delayed for restoration possibility)
  INSERT INTO storage_cleanup_queue (file_path, scheduled_for)
  VALUES (NEW.storage_path, NOW() + INTERVAL '7 days'),
         (NEW.thumbnail_path, NOW() + INTERVAL '7 days');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### 3.2 Organization Deletion Cascade
When an organization is soft deleted:
```sql
CREATE OR REPLACE FUNCTION cascade_soft_delete_organization()
RETURNS TRIGGER AS $$
BEGIN
  -- Soft delete all child entities
  UPDATE users SET 
    deleted_at = NEW.deleted_at, 
    deleted_by = NEW.deleted_by 
  WHERE organization_id = NEW.id AND deleted_at IS NULL;
  
  UPDATE projects SET 
    deleted_at = NEW.deleted_at, 
    deleted_by = NEW.deleted_by 
  WHERE organization_id = NEW.id AND deleted_at IS NULL;
  
  UPDATE photos SET 
    deleted_at = NEW.deleted_at, 
    deleted_by = NEW.deleted_by 
  WHERE organization_id = NEW.id AND deleted_at IS NULL;
  
  UPDATE sites SET 
    deleted_at = NEW.deleted_at, 
    deleted_by = NEW.deleted_by 
  WHERE organization_id = NEW.id AND deleted_at IS NULL;
  
  UPDATE albums SET 
    deleted_at = NEW.deleted_at, 
    deleted_by = NEW.deleted_by 
  WHERE organization_id = NEW.id AND deleted_at IS NULL;
  
  -- Audit the cascade operation
  INSERT INTO audit_logs (organization_id, user_id, action, details)
  VALUES (NEW.id, NEW.deleted_by, 'organization_cascaded_delete', 
    jsonb_build_object('deleted_at', NEW.deleted_at));
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### 3.3 Project Deletion Options
```sql
-- Flexible project deletion with photo handling options
CREATE OR REPLACE FUNCTION delete_project_with_options(
  project_id UUID,
  deleter_id UUID,
  photo_action TEXT DEFAULT 'orphan' -- 'delete', 'archive', 'orphan'
) RETURNS JSONB AS $$
DECLARE
  result JSONB;
  photo_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO photo_count FROM photos WHERE project_id = $1;
  
  CASE photo_action
    WHEN 'delete' THEN
      UPDATE photos SET 
        deleted_at = NOW(), deleted_by = deleter_id,
        deletion_reason = 'Project deletion cascade'
      WHERE project_id = $1;
      
    WHEN 'archive' THEN  
      UPDATE photos SET 
        archived_at = NOW(), archived_by = deleter_id,
        archive_reason = 'Project archived'
      WHERE project_id = $1;
      
    WHEN 'orphan' THEN
      UPDATE photos SET project_id = NULL WHERE project_id = $1;
  END CASE;
  
  -- Soft delete the project
  UPDATE projects SET 
    deleted_at = NOW(), deleted_by = deleter_id 
  WHERE id = $1;
  
  RETURN jsonb_build_object(
    'project_id', $1,
    'photo_count', photo_count,
    'photo_action', photo_action
  );
END;
$$ LANGUAGE plpgsql;
```

### Phase 4: RLS Policy Updates (2-3 hours)

#### 4.1 Update Existing Policies
```sql
-- Update photos policies to exclude soft deleted by default
DROP POLICY IF EXISTS "Users can view organization photos" ON photos;
CREATE POLICY "Users can view non-deleted organization photos" ON photos
  FOR SELECT USING (
    organization_id IN (
      SELECT organization_id FROM users 
      WHERE id = auth.uid() AND deleted_at IS NULL
    )
    AND deleted_at IS NULL
    AND (archived_at IS NULL OR current_setting('app.include_archived', true)::boolean = true)
  );

-- Admin policy to view deleted content
CREATE POLICY "Admins can view deleted content" ON photos
  FOR SELECT USING (
    organization_id IN (
      SELECT organization_id FROM users 
      WHERE id = auth.uid() AND role IN ('admin', 'platform_admin')
    )
  );
```

#### 4.2 Archive-Specific Policies
```sql
-- Policy for archived photos
CREATE POLICY "Users can archive organization photos" ON photos
  FOR UPDATE USING (
    organization_id IN (
      SELECT organization_id FROM users 
      WHERE id = auth.uid() AND deleted_at IS NULL
    )
    AND deleted_at IS NULL
  );

-- Restoration policy (admin only)
CREATE POLICY "Admins can restore deleted photos" ON photos
  FOR UPDATE USING (
    organization_id IN (
      SELECT organization_id FROM users 
      WHERE id = auth.uid() AND role IN ('admin', 'platform_admin')
    )
  );
```

### Phase 5: API Endpoints (3-4 hours)

#### 5.1 Archive Management Endpoints
```typescript
// Archive single photo
POST /api/photos/[id]/archive
{
  reason?: string;
}

// Bulk archive photos  
POST /api/photos/bulk-archive
{
  criteria: {
    project_id?: string;
    date_range?: { start: string; end: string };
    tag_ids?: string[];
  };
  reason?: string;
}

// View archived photos
GET /api/photos?include_archived=true

// Restore archived photo
POST /api/photos/[id]/restore

// Permanently delete (admin only)
DELETE /api/photos/[id]/permanent
```

#### 5.2 Organization & Project Deletion
```typescript
// Delete organization with cascade
DELETE /api/organizations/[id]
{
  confirmation: string; // Must match organization name
}

// Delete project with photo options
DELETE /api/projects/[id]
{
  photo_action: 'delete' | 'archive' | 'orphan';
  confirmation: string;
}
```

### Phase 6: UI Components (4-5 hours)

#### 6.1 Archive Management UI
- **Archive Modal** - Single photo archive with reason
- **Bulk Archive** - Multi-select photos with criteria filters  
- **Archive Filter** - Toggle to show/hide archived photos
- **Restore Button** - Restore archived photos (admin)

#### 6.2 Deletion Confirmation UI
- **Organization Deletion** - Multi-step confirmation with impact preview
- **Project Deletion** - Photo action selector with preview
- **Permanent Delete** - Admin-only with extra warnings

## Benefits & Considerations

### Benefits
1. **Data Recovery** - Soft deletes allow restoration of accidentally deleted content
2. **Audit Trail** - Complete deletion history for compliance
3. **Storage Optimization** - Archive old photos while maintaining accessibility
4. **Flexible Deletion** - Different strategies for different entity types
5. **Performance** - Proper indexing maintains query performance

### Considerations  
1. **Storage Costs** - Soft deleted data continues consuming storage
2. **Query Complexity** - Need to filter deleted records in most queries
3. **Data Privacy** - Consider regulations requiring true data deletion
4. **Maintenance** - Need cleanup jobs for permanent deletion
5. **Migration Complexity** - Large existing datasets need careful migration

## Migration Strategy

### Phase 1: Schema Migration
1. Add columns to existing tables (non-breaking)
2. Create indexes and functions
3. Test with small dataset

### Phase 2: Application Updates
1. Update queries to respect soft delete flags
2. Deploy new API endpoints
3. Update RLS policies

### Phase 3: UI Rollout
1. Deploy archive management features
2. Update deletion workflows  
3. Add admin restoration tools

### Phase 4: Cleanup Implementation
1. Deploy automated cleanup jobs
2. Monitor storage usage
3. Tune retention policies

## Success Metrics

- **Recovery Success Rate** - % of soft deleted items successfully restored
- **Storage Efficiency** - Archive storage costs vs active storage
- **User Satisfaction** - Reduced accidental deletion tickets
- **Performance Impact** - Query performance after soft delete implementation
- **Compliance Score** - Audit trail completeness for deleted data

## Future Enhancements

1. **Automated Archive Rules** - Archive photos older than X days automatically
2. **Bulk Restoration** - Restore multiple items at once
3. **Archive Analytics** - Usage patterns of archived content
4. **Storage Tiering** - Move archived photos to cheaper storage
5. **Compliance Export** - Export deletion audit trails for compliance reporting