# Claude Code Implementation Prompt for AI Management Platform

## Feature Implementation Request

Use this prompt with the `/feature` command in a new Claude Code session to implement the AI Management Platform fixes:

---

**Feature Request:**

I need you to implement the complete AI Management Platform fixes for the Minerva Machine Safety Photo Organizer. This is a Next.js 15 application with TypeScript, Supabase database, and shadcn/ui components.

## Current Status & Issues

The AI Management Platform is 65% complete with critical production blockers. I have a comprehensive analysis and fix plan at:
- Issue analysis: `C:\Users\Tom\dev\minerva\dev\01-claude-comms\to-fix.md`
- Detailed fix plan: `C:\Users\Tom\dev\minerva\dev\04-implementation\detailed-plans\ai-management-platform-fix-plan.md`

## Critical Issues to Fix

### 1. Database Schema Problems
- **Missing table error**: `column platform_ai_features_1.feature_type does not exist` (Error 42703)
- **Incomplete TypeScript types**: 20+ AI management tables missing from `types/database.ts`
- **RLS function conflicts**: `is_platform_admin()` references non-existent `user_profiles` table

### 2. Extensive Mock Data Usage
- **Overview API**: Complete mock implementation in `/api/platform/ai-management/overview/route.ts`
- **Multiple components**: Mock data with hardcoded values and setTimeout delays
- **Production blocker**: Users will see fake spending data, metrics, and provider information

### 3. Select Component Validation Errors
- **Models page**: `<SelectItem value="">` causing React validation failures
- **Prompt library**: Similar Select component errors
- **Multiple locations**: 8+ components with empty string Select values

### 4. Non-Functional Features
- **Feature management**: "Prompts", "Testing", "Settings" tabs show "Coming Soon"
- **Testing wizard**: Modal closes without creating experiments
- **Navigation**: Feature health cards redirect to 404 pages
- **Global settings**: Non-functional buttons throughout interface

## Implementation Requirements

### Phase 1: Foundation (Week 1)
1. **Fix database schema issues**
   - Create missing `platform_ai_features` table with `feature_type` column
   - Update `types/database.ts` with all AI management table definitions
   - Fix RLS function conflicts in migrations

2. **Replace mock data in Overview API**
   - Remove hardcoded spending, metrics, and provider data
   - Implement real database queries for platform overview
   - Connect to actual AI provider status APIs

3. **Fix Select component validation errors**
   - Replace empty string values with meaningful identifiers
   - Fix Models and Prompts page Select components
   - Add proper validation for dynamic values

### Phase 2: Features (Week 2)
1. **Implement feature management tabs**
   - Build functional Prompts, Testing, Settings components
   - Remove "Coming Soon" placeholders
   - Add real configuration and persistence

2. **Fix navigation and routing**
   - Create missing detail pages for feature health cards
   - Fix 404 navigation errors
   - Implement proper routing structure

3. **Complete testing and experiments**
   - Fix experiment wizard to actually create experiments
   - Implement A/B testing framework
   - Build analytics dashboard

### Phase 3: Polish (Week 3-4)
1. **UI/UX improvements**
   - Fix dark mode consistency issues (see screenshot at `C:\Users\Tom\dev\minerva\dev\01-claude-comms\screenshots\Screenshot 2025-08-04 062946.png`)
   - Resolve KPI text overflow problems
   - Improve responsive design

2. **Performance optimization**
   - Remove setTimeout delays from production code
   - Optimize database queries
   - Implement proper caching

3. **Testing and documentation**
   - Add comprehensive test coverage
   - Update API documentation
   - Create user guides

## Technical Specifications

### Architecture Requirements
- **Framework**: Next.js 15 with App Router
- **Database**: Supabase PostgreSQL with RLS policies
- **UI Components**: shadcn/ui exclusively
- **Styling**: Tailwind CSS v4 with dark mode support
- **State Management**: Zustand + TanStack Query
- **Authentication**: Platform admin authentication required

### Key Files to Modify
- `app/api/platform/ai-management/overview/route.ts` - Remove mock data
- `app/platform/ai-management/models/page.tsx` - Fix Select errors
- `app/platform/ai-management/features/page.tsx` - Implement tabs
- `types/database.ts` - Add missing table definitions
- `supabase/migrations/` - Create new migration for missing tables

### Quality Standards
- **TypeScript**: Strict mode, zero 'any' types
- **Testing**: >80% coverage for new features
- **Performance**: <3s page load, <500ms API responses
- **Accessibility**: WCAG 2.1 AA compliance
- **Mobile**: Mobile-first responsive design

## Success Criteria

The implementation is complete when:
- [ ] Zero database schema errors (no missing columns/tables)
- [ ] All mock data replaced with real database connections
- [ ] No Select component validation errors
- [ ] All navigation links functional (no 404 errors)
- [ ] Feature management tabs fully operational
- [ ] Testing wizard creates actual experiments
- [ ] Dark mode working consistently across all pages
- [ ] Performance targets met (<3s load times)

## Agent Usage Strategy

Please use the following specialized agents during implementation:

1. **database-architect**: For schema fixes and migration creation
2. **typescript-safety-validator**: For types/database.ts updates and type safety
3. **todo-placeholder-detector**: To find and replace remaining mock data
4. **ui-ux-reviewer**: For dark mode fixes and responsive design
5. **quality-assurance-specialist**: For comprehensive testing and validation
6. **performance-optimizer**: For removing delays and optimizing queries
7. **security-auditor**: For platform admin authentication validation

## Context Files

Before starting, please review these files for complete context:
- `C:\Users\Tom\dev\minerva\CLAUDE.md` - Project overview and architecture
- `C:\Users\Tom\dev\minerva\dev\01-claude-comms\to-fix.md` - Specific issues found
- `C:\Users\Tom\dev\minerva\dev\04-implementation\detailed-plans\ai-management-platform-fix-plan.md` - Comprehensive fix plan

Start with the database schema fixes as they are the critical path blocking all other development.

---

**Use this prompt with:** `/feature implement AI Management Platform fixes according to comprehensive fix plan`