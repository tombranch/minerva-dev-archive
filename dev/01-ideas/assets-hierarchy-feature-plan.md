# Assets Hierarchy Feature Plan

## Overview

Add a flexible, infinite-depth asset hierarchy system to Minerva that allows users to organize photos by physical and logical assets within sites. This creates a structure like: `Site → LineA → Machine1 → Infeed → Motor` where users can organize photos at any level of granularity.

## Current System Analysis

### Existing Hierarchy
**Organizations → Sites → Projects → Photos**
- Organizations: Multi-tenant root entities
- Sites: Physical locations with Google Places integration  
- Projects: Work units (optionally linked to sites)
- Photos: Individual images linked to projects

### Key Findings
- Strong database foundation with RLS policies and multi-tenancy
- No existing drag-and-drop or tree view components
- Card-based UI throughout using shadcn/ui
- Photos currently only associate with projects, not directly with sites
- AI tagging system already categorizes machine types, components, hazards

## Proposed Asset System

### Core Concept
**Assets** are a new entity type that creates flexible hierarchies within sites:
- Assets belong to one site (organization_id for multi-tenancy)
- Assets can have parent assets (self-referencing hierarchy)
- Assets can contain photos directly
- Assets can be included in projects
- Infinite depth hierarchy support

### Asset Types (Flexible)
- **Facility Level**: Building, Floor, Area, Zone
- **Production Level**: Line, Cell, Station, Workstation  
- **Equipment Level**: Machine, Tool, Fixture, Conveyor
- **Component Level**: Motor, Pump, Sensor, Actuator
- **Custom Types**: User-defined for specific industries

## Technical Implementation Plan

### 1. Database Schema

```sql
-- Core Assets Table
CREATE TABLE assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  site_id UUID REFERENCES sites(id) NOT NULL,
  parent_asset_id UUID REFERENCES assets(id), -- Self-referencing hierarchy
  name VARCHAR(255) NOT NULL,
  asset_type VARCHAR(100), -- Flexible type system
  description TEXT,
  metadata JSONB DEFAULT '{}', -- Custom properties per asset type
  hierarchy_path LTREE, -- PostgreSQL LTREE for efficient queries
  sort_order INTEGER DEFAULT 0, -- User-defined ordering
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);

-- Indexes for performance
CREATE INDEX assets_organization_id_idx ON assets(organization_id);
CREATE INDEX assets_site_id_idx ON assets(site_id);
CREATE INDEX assets_parent_id_idx ON assets(parent_asset_id);
CREATE INDEX assets_hierarchy_path_idx ON assets USING GIST(hierarchy_path);
CREATE INDEX assets_type_idx ON assets(asset_type);

-- Photo-Asset relationship (many-to-many for flexibility)
CREATE TABLE photo_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID REFERENCES photos(id) ON DELETE CASCADE,
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  UNIQUE(photo_id, asset_id)
);

-- Project-Asset relationship (many-to-many)
CREATE TABLE project_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  UNIQUE(project_id, asset_id)
);

-- RLS Policies
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE photo_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_assets ENABLE ROW LEVEL SECURITY;

-- Asset hierarchy maintenance function
CREATE OR REPLACE FUNCTION update_asset_hierarchy_path()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.parent_asset_id IS NULL THEN
    NEW.hierarchy_path = NEW.id::text::ltree;
  ELSE
    SELECT hierarchy_path || NEW.id::text::ltree
    INTO NEW.hierarchy_path
    FROM assets 
    WHERE id = NEW.parent_asset_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_asset_hierarchy_path_trigger
  BEFORE INSERT OR UPDATE OF parent_asset_id ON assets
  FOR EACH ROW EXECUTE FUNCTION update_asset_hierarchy_path();
```

### 2. UI/UX Components

#### Core Tree View Component
```typescript
// components/assets/asset-tree-view.tsx
interface AssetTreeNode {
  id: string;
  name: string;
  assetType: string;
  children: AssetTreeNode[];
  photoCount: number;
  isExpanded: boolean;
}

interface AssetTreeViewProps {
  siteId: string;
  selectedAssetId?: string;
  onAssetSelect: (assetId: string) => void;
  onAssetMove: (assetId: string, newParentId: string | null) => void;
  isDragEnabled?: boolean;
}
```

#### Asset Manager Interface
```typescript
// components/assets/asset-manager.tsx
interface AssetManagerProps {
  siteId: string;
  mode: 'view' | 'select' | 'manage';
  onAssetCreate: (asset: CreateAssetData) => void;
  onAssetUpdate: (assetId: string, updates: UpdateAssetData) => void;
  onAssetDelete: (assetId: string) => void;
}
```

### 3. User Experience Design

#### Navigation Patterns
1. **Primary Navigation**: Add "Assets" to main sidebar
2. **Breadcrumb Navigation**: Show full hierarchy path
3. **Tree View**: Collapsible/expandable with visual hierarchy
4. **Context Actions**: Right-click menus for CRUD operations

#### Drag & Drop Functionality
- **Asset Reordering**: Drag assets within same parent
- **Asset Moving**: Drag assets to new parent locations
- **Photo Assignment**: Drag photos onto assets
- **Visual Feedback**: Drop zones, hover states, invalid drop indicators

#### Mobile Considerations
- **Collapsible Tree**: Touch-friendly expand/collapse
- **Swipe Actions**: Swipe for asset options
- **Responsive Breadcrumbs**: Truncate long paths
- **Modal Asset Picker**: Full-screen selection on mobile

### 4. Integration Points

#### Enhanced Photo Organization
```typescript
// Photos can be associated with multiple assets
interface PhotoAssetAssociation {
  photoId: string;
  assetId: string;
  primaryAsset: boolean; // One primary asset per photo
}

// Asset-based photo filtering
interface PhotoFilter {
  assetIds: string[];
  includeChildAssets: boolean; // Include photos from child assets
  assetTypes: string[];
}
```

#### Project Enhancement
```typescript
// Projects can span multiple assets
interface ProjectAssetScope {
  projectId: string;
  assetIds: string[];
  includeChildAssets: boolean;
}
```

#### Search & Reporting
- **Asset-based search**: Find photos by asset hierarchy
- **Hierarchical reports**: Export organized by asset structure
- **Asset analytics**: Photo distribution across hierarchy

### 5. API Design

#### Asset CRUD Operations
```typescript
// lib/api/assets.ts
export interface AssetAPI {
  // Hierarchy operations
  getAssetTree(siteId: string): Promise<AssetTreeNode[]>;
  getAssetPath(assetId: string): Promise<AssetBreadcrumb[]>;
  getAssetChildren(assetId: string): Promise<Asset[]>;
  
  // CRUD operations
  createAsset(data: CreateAssetData): Promise<Asset>;
  updateAsset(id: string, data: UpdateAssetData): Promise<Asset>;
  deleteAsset(id: string): Promise<void>;
  moveAsset(id: string, newParentId: string | null): Promise<void>;
  
  // Photo associations
  associatePhotoWithAsset(photoId: string, assetId: string): Promise<void>;
  removePhotoFromAsset(photoId: string, assetId: string): Promise<void>;
  getAssetPhotos(assetId: string, includeChildren: boolean): Promise<Photo[]>;
}
```

### 6. Migration Strategy

#### Phase 1: Foundation
1. Create assets table and relationships
2. Build core tree view component
3. Add basic asset CRUD operations
4. Implement asset-photo associations

#### Phase 2: Integration
1. Enhance photo grid with asset display
2. Add asset selection to photo upload
3. Integrate with existing project system
4. Update search and filtering

#### Phase 3: Advanced Features
1. Implement drag & drop functionality
2. Add bulk asset operations
3. Asset-based reporting and exports
4. Mobile UX optimizations

#### Phase 4: Migration Tools
1. Site-to-asset migration utility
2. Bulk asset creation from CSV
3. Asset template system for common hierarchies
4. Data validation and cleanup tools

## User Stories

### Asset Management
- **As a safety manager**, I want to create a hierarchy like "Building A → Floor 2 → Assembly Line → Station 3 → Robot Arm" so I can organize photos by exact equipment location
- **As a maintenance technician**, I want to drag and drop assets to reorganize the hierarchy when equipment is moved
- **As a plant engineer**, I want to upload photos directly to specific assets without needing to create projects first

### Photo Organization
- **As a user**, I want to see photos organized by asset hierarchy in a tree view so I can quickly find equipment-specific images
- **As a safety inspector**, I want to associate one photo with multiple assets (e.g., a photo showing both motor and pump) for comprehensive documentation
- **As a manager**, I want to view all photos for an asset and its sub-components to get a complete equipment overview

### Project Integration
- **As a project manager**, I want to include multiple assets in a single project (e.g., entire production line upgrade) for scope management
- **As a contractor**, I want to see which assets are included in my assigned projects so I know what equipment to document

## Technical Considerations

### Performance
- **LTREE indexing** for fast hierarchy queries
- **Lazy loading** of tree nodes for large hierarchies  
- **Efficient photo counting** with cached aggregates
- **Optimistic updates** for drag & drop operations

### Scalability
- **Multi-level caching** for frequently accessed trees
- **Pagination** for assets with many photos
- **Background processing** for hierarchy updates
- **Database partitioning** for large organizations

### Security
- **RLS policies** inherit from organization/site security
- **Asset-level permissions** for fine-grained access control
- **Audit trails** for all asset hierarchy changes
- **Validation** to prevent circular references

### Data Integrity
- **Cascade deletes** handled carefully to preserve photos
- **Orphan detection** and cleanup procedures
- **Hierarchy validation** to maintain tree structure
- **Backup strategies** for critical asset data

## Future Enhancements

### AI Integration
- **Auto-categorization** of uploaded photos to appropriate assets based on image analysis
- **Asset suggestions** based on photo content and existing hierarchy
- **Duplicate asset detection** to maintain clean hierarchies

### Advanced Features
- **Asset templates** for common industry hierarchies
- **Bulk operations** for mass asset creation/updates
- **Asset workflows** for maintenance and inspection processes
- **Integration APIs** for external asset management systems

### Analytics
- **Asset utilization** reporting (photos per asset over time)
- **Hierarchy optimization** suggestions based on usage patterns
- **Asset health** tracking through photo analysis trends

## Success Metrics

### User Adoption
- Percentage of photos associated with assets vs. projects only
- Average hierarchy depth utilized per organization
- User engagement with tree view vs. traditional list views

### Efficiency Gains
- Time reduction in photo organization workflows
- Improved photo findability through asset-based search
- Reduced duplicate asset creation

### System Performance
- Tree view load times under 2 seconds for hierarchies up to 1000 assets
- Drag & drop operations complete in under 500ms
- Photo association updates process in under 100ms

## Conclusion

The Assets Hierarchy feature will transform Minerva from a project-based photo organizer into a comprehensive facility documentation system. By providing infinite-depth asset hierarchies with intuitive drag-and-drop management, users can organize photos exactly how their physical facilities are structured.

The implementation leverages Minerva's existing strong foundation while adding powerful new capabilities that scale from small shops with simple hierarchies to large manufacturers with complex multi-level equipment structures.

This feature positions Minerva as the definitive tool for industrial safety photo documentation, providing the organizational flexibility that safety managers, maintenance teams, and plant engineers need to effectively manage their visual documentation workflows.