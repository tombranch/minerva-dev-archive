# Agent 2: Navigation Restructure Brief

**Duration:** 3-4 days  
**Priority:** High  
**Dependencies:** Can start immediately, coordinate with Agent 1 for Smart Albums integration

## Mission

Restructure the main navigation from 9 items to 5, move settings to avatar menu, remove analytics and AI management pages, and update all routing/redirects. This creates a cleaner, more focused user experience while maintaining access to essential features.

## Objectives

1. Update sidebar navigation to show only 5 main sections
2. Implement avatar dropdown menu with settings and admin access
3. Remove Analytics and AI Management from main navigation
4. Update all routes and implement proper redirects
5. Ensure mobile responsiveness
6. Document changes and create handover materials

## Current vs New Navigation Structure

### Current (9 items)
1. Dashboard
2. Photos
3. Upload
4. Projects
5. Search
6. Analytics
7. Sites
8. AI Management
9. Settings

### New (5 items)
1. Photos (with integrated upload)
2. Projects
3. Sites
4. Search
5. Smart Albums

### Avatar Menu Items
- Profile
- Settings
- Organization
- Help & Support
- Admin Dashboard (role-based)
- Super Admin (role-based)
- Sign Out

## Implementation Requirements

### Component Updates

#### Sidebar Component (`components/layout/sidebar.tsx`)
```typescript
// New navigation structure
const navigationItems = [
  { name: 'Photos', href: '/photos', icon: PhotoIcon },
  { name: 'Projects', href: '/projects', icon: FolderIcon },
  { name: 'Sites', href: '/sites', icon: MapPinIcon },
  { name: 'Search', href: '/search', icon: SearchIcon },
  { name: 'Smart Albums', href: '/smart-albums', icon: SparklesIcon }
];
```

#### Avatar Menu (`components/layout/avatar-menu.tsx`)
- Create new dropdown component
- Implement role-based menu items
- Add keyboard navigation support
- Ensure mobile compatibility

### Route Updates

#### Redirects to Implement
```typescript
// middleware.ts
const redirects = {
  '/dashboard': '/photos',
  '/': '/photos',
  '/upload': '/photos?upload=true',
  '/analytics': '/admin/analytics',
  '/ai': '/admin/ai-management',
  '/settings': '/profile/settings'
};
```

#### Remove These Routes
- `/app/dashboard/page.tsx` → Delete
- `/app/analytics/page.tsx` → Delete
- `/app/ai/page.tsx` → Delete
- `/app/upload/page.tsx` → Delete
- `/app/settings/page.tsx` → Move to `/app/profile/settings/page.tsx`

### Database Updates
```sql
-- Update user preferences for default landing page
UPDATE user_profiles 
SET preferences = jsonb_set(preferences, '{landingPage}', '"photos"')
WHERE preferences->>'landingPage' = 'dashboard';
```

## Implementation Steps

1. **Day 1: Sidebar Component Update**
   - Update navigation items array
   - Remove deprecated navigation links
   - Update active state logic
   - Test responsive behavior

2. **Day 2: Avatar Menu Implementation**
   - Create avatar dropdown component
   - Implement role-based visibility
   - Add menu animations
   - Test keyboard navigation

3. **Day 3: Route Migration**
   - Set up redirects in middleware
   - Delete deprecated pages
   - Update all internal links
   - Test all navigation paths

4. **Day 4: Testing & Polish**
   - Mobile responsiveness testing
   - Cross-browser testing
   - Update E2E tests
   - Documentation and handover

## Key Files to Create/Modify

### New Files
- `components/layout/avatar-menu.tsx`
- `app/(protected)/profile/settings/page.tsx`
- `app/(protected)/smart-albums/page.tsx`
- `docs/navigation-migration-guide.md`

### Modified Files
- `components/layout/sidebar.tsx`
- `middleware.ts`
- `app/layout.tsx`
- `lib/constants/navigation.ts`
- `tests/e2e/navigation.spec.ts`

### Deleted Files
- `app/(protected)/dashboard/page.tsx`
- `app/(protected)/analytics/page.tsx`
- `app/(protected)/ai/page.tsx`
- `app/(protected)/upload/page.tsx`
- `app/(protected)/settings/page.tsx`

## Mobile Optimization Requirements

### Responsive Breakpoints
- Mobile: < 768px (auto-collapse sidebar)
- Tablet: 768px - 1024px (collapsible sidebar)
- Desktop: > 1024px (expanded sidebar)

### Touch Interactions
- Swipe gestures for sidebar open/close
- Touch-friendly tap targets (min 44px)
- Bottom sheet pattern for mobile menus

## Testing Checklist

- [ ] All routes redirect properly
- [ ] No broken links in the application
- [ ] Avatar menu works on all screen sizes
- [ ] Keyboard navigation fully functional
- [ ] Role-based menu items show/hide correctly
- [ ] Mobile gestures work smoothly
- [ ] Page transitions are smooth

## Documentation Requirements

### Migration Guide
Create comprehensive guide covering:
- URL changes and redirects
- New navigation structure
- How to access moved features
- Avatar menu functionality

### Developer Documentation
- Component API changes
- New routing patterns
- Mobile breakpoint strategy
- Animation/transition details

### Handover Document
Create `HANDOVER-AGENT-2.md` including:
- All navigation changes made
- Redirect mapping table
- Component architecture decisions
- Mobile optimization details
- Known issues or limitations
- Suggested future improvements

## Success Criteria

- [ ] Sidebar shows exactly 5 navigation items
- [ ] All old routes redirect to new locations
- [ ] Avatar menu fully functional with all items
- [ ] Mobile navigation works smoothly
- [ ] No broken links anywhere in app
- [ ] All tests passing
- [ ] Load time improved by removing complex pages

## Coordination with Other Agents

- Coordinate with Agent 1 for Smart Albums navigation item
- Agent 3 will need updated navigation for Photos page
- Share component updates early
- Document any breaking changes

## Important Considerations

1. **Backwards Compatibility**: Ensure bookmarked URLs still work
2. **User Communication**: Plan for notifying users of changes
3. **Analytics Tracking**: Update event tracking for new navigation
4. **Search Indexing**: Update sitemap for new structure
5. **Performance**: Measure navigation performance improvements

## Edge Cases to Handle

- Users mid-upload when visiting old upload URL
- Deep links to removed analytics pages
- Keyboard shortcuts referencing old navigation
- Browser back button behavior with redirects
- PWA cached routes

Remember to maintain a smooth user experience during the transition!