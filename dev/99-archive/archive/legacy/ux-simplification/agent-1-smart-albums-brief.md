# Agent 1: Smart Albums Infrastructure Brief

**Duration:** 1 week  
**Priority:** High  
**Dependencies:** None (can start immediately)

## Mission

Implement the backend infrastructure for AI-powered smart albums that automatically organize photos based on equipment types, hazards, safety controls, time periods, and sites. This feature will complement (not replace) the existing manual Projects organization system.

## Objectives

1. Design and implement database schema for smart albums
2. Create album generation algorithms based on AI tags
3. Build RESTful API endpoints for smart album management
4. Implement efficient caching for performance
5. Create background jobs for automatic album updates
6. Document the implementation and create handover materials

## Technical Requirements

### Database Schema
Implement the following tables in Supabase:

```sql
-- Smart albums table
CREATE TABLE smart_albums (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('equipment', 'hazard', 'safety_control', 'time', 'site', 'custom')),
  criteria JSONB NOT NULL,
  is_system BOOLEAN DEFAULT false,
  is_pinned BOOLEAN DEFAULT false,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User smart album preferences
CREATE TABLE user_smart_album_preferences (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  smart_album_id UUID REFERENCES smart_albums(id) ON DELETE CASCADE,
  is_hidden BOOLEAN DEFAULT false,
  is_pinned BOOLEAN DEFAULT false,
  sort_order INTEGER,
  PRIMARY KEY (user_id, smart_album_id)
);

-- Indexes for performance
CREATE INDEX idx_smart_albums_organization ON smart_albums(organization_id);
CREATE INDEX idx_smart_albums_type ON smart_albums(type);
CREATE INDEX idx_user_preferences_user ON user_smart_album_preferences(user_id);
```

### API Endpoints
Create the following endpoints in `app/api/smart-albums/`:

1. `GET /api/smart-albums` - List all smart albums for user
2. `GET /api/smart-albums/[id]` - Get specific album with photos
3. `POST /api/smart-albums` - Create custom smart album
4. `PUT /api/smart-albums/[id]` - Update album (name, criteria)
5. `DELETE /api/smart-albums/[id]` - Delete custom album
6. `POST /api/smart-albums/[id]/pin` - Pin/unpin album
7. `POST /api/smart-albums/[id]/hide` - Hide/show album
8. `GET /api/smart-albums/suggestions` - Get AI suggestions

### Album Generation Logic

#### Equipment-Based Albums
- Query photos grouped by `equipment_tags`
- Create album when equipment type has 5+ photos
- Example: "Conveyor Belts (23 photos)"

#### Hazard-Based Albums
- Group by `hazard_tags` and severity
- Example: "High Risk - Pinch Points"
- Include safety recommendations in description

#### Time-Based Albums
- Dynamic queries based on upload_date
- Types: "Today", "This Week", "Last 30 Days", "This Month"
- Auto-archive after time period passes

#### Site-Based Albums
- One album per active site
- Show recent activity and pending reviews
- Example: "Site A - Recent Activity (12 new)"

#### Custom Albums
- User-defined JSONB criteria
- Support complex queries
- Shareable with team members

### Performance Requirements
- Album list load time: < 200ms
- Photo count queries: < 100ms
- Use Redis caching for counts
- Background job for count updates

## Implementation Steps

1. **Day 1-2: Database Setup**
   - Create migration files
   - Implement RLS policies
   - Test with sample data

2. **Day 3-4: Core API Development**
   - Build album generation service
   - Implement CRUD endpoints
   - Add authentication/authorization

3. **Day 5: Caching & Performance**
   - Set up Redis caching
   - Implement count caching
   - Add background job queue

4. **Day 6: Testing & Edge Cases**
   - Unit tests for album generation
   - Integration tests for API
   - Handle edge cases

5. **Day 7: Documentation & Handover**
   - API documentation
   - Implementation guide
   - Create handover document

## Success Criteria

- [ ] All database tables created with proper indexes
- [ ] API endpoints return data in <200ms
- [ ] Albums automatically update when photos are tagged
- [ ] Caching reduces database load by 80%
- [ ] 90% test coverage for core functionality
- [ ] Complete API documentation in OpenAPI format

## Key Files to Create/Modify

### New Files
- `supabase/migrations/[timestamp]_create_smart_albums.sql`
- `app/api/smart-albums/route.ts`
- `app/api/smart-albums/[id]/route.ts`
- `app/api/smart-albums/[id]/pin/route.ts`
- `app/api/smart-albums/[id]/hide/route.ts`
- `app/api/smart-albums/suggestions/route.ts`
- `lib/services/smart-albums.ts`
- `lib/services/album-generator.ts`
- `lib/cache/smart-albums-cache.ts`
- `tests/smart-albums.test.ts`

### Modified Files
- `lib/supabase/schema.ts` - Add smart album types
- `lib/types/index.ts` - Add TypeScript interfaces

## Documentation Requirements

### API Documentation
- OpenAPI/Swagger specification
- Example requests and responses
- Error handling guidelines

### Developer Guide
- How album generation works
- Adding new album types
- Performance considerations
- Cache invalidation strategy

### Handover Document
Create `HANDOVER-AGENT-1.md` including:
- What was implemented
- Design decisions made
- Known limitations
- Future enhancement ideas
- Performance benchmarks
- Testing results

## Testing Checklist

- [ ] Unit tests for album generation logic
- [ ] Integration tests for all API endpoints
- [ ] Performance tests with 10,000+ photos
- [ ] Security tests for RLS policies
- [ ] Edge case handling (empty albums, deleted photos)
- [ ] Cache invalidation testing

## Notes for Success

1. **Start Simple**: Focus on equipment and time-based albums first
2. **Performance First**: Design with caching in mind from the start
3. **Extensibility**: Make it easy to add new album types
4. **User Control**: Always allow users to hide/customize
5. **Real-time Updates**: Use Supabase realtime for count updates

## Coordination with Other Agents

- Agent 2 will need your API endpoints for UI integration
- Agent 3 will integrate smart album filters into Photos page
- Share your TypeScript interfaces early
- Document any breaking changes immediately

## Questions to Consider

1. Should smart albums be organization-wide or user-specific?
2. How often should counts be updated (real-time vs batch)?
3. What's the maximum number of photos per album?
4. Should we support nested/hierarchical albums?
5. How to handle deleted photos in albums?

Remember to update all documentation as you work and test thoroughly before handover!