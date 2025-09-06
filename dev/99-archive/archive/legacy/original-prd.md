### 5.7. User Feedback System
* **Contextual Feedback Collection**: Floating feedback button using shadcn/ui Sheet component with context awareness
* **Feature-Specific Rating**: Quick 1-5 star rating system for AI tagging, search, upload, and overall experience
* **Bug Reporting**: Simple form for reporting issues with automatic context capture (browser, page, user action)
* **Suggestion Submission**: Open text field for feature requests and improvements
* **Feedback Status Tracking**: Users can see the status of their submitted feedback (new, reviewed, addressed)
* **Anonymous Option**: Users can choose to submit feedback anonymously for honest input

### 5.8. AI Correction Tracking & Learning
* **Automatic Correction Logging**: Every tag addition/removal and description edit is automatically logged with context
* **Confidence Score Tracking**: Store AI confidence levels alongside user corrections for training data quality
* **Suggestion Acceptance Rates**: Track which AI suggestions users accept vs. reject for model improvement
* **Pattern Recognition**: Identify common correction patterns to improve AI accuracy over time
* **Training Data Pipeline**: Structured data collection for future custom model training
* **User Correction Analytics**: Dashboard showing AI improvement trends and user correction patterns (admin view)

### 5.9. Basic Connection Resilience (MVP Enhancement)
* **Automatic Upload Retries**: The application will automatically retry failed photo uploads a few times to handle intermittent network connectivity in industrial environments.
* **Connection Status Indicator**: A simple, clear indicator in the UI will show users if their connection is currently online or offline.

### User Feedback & Analytics
* As a user, I want to quickly rate my experience with specific features so the development team can improve the app
* As a user, I want to report bugs or suggest improvements through an easy feedback mechanism
* As a user, I want to see that my feedback is being considered and addressed
* As an admin, I want to see aggregated feedback data to understand user satisfaction and pain points

### AI Learning & Improvement
* As a user, I want my corrections to AI suggestions to help improve the system for everyone
* As a user, I want to see that the AI is getting better over time based on team corrections
* As an admin, I want to track AI improvement metrics and identify common correction patterns
* As an admin, I want to export correction data for future custom model training# Product Requirements Document (PRD): Machine Safety Photo Organizer - MVP

**Document Version:** 3.0  
**Date:** June 30, 2025

## 1. Introduction / Executive Summary

The Machine Safety Photo Organizer is a web-based application designed to solve the critical photo discovery and organization challenge faced by machine safety engineers. Currently, engineers managing 200-400 photos per week struggle with a fragmented workflow: photos taken on mobile devices → Google Photos → PC download → SharePoint folders → manual searching for the right photo when writing reports.

The core problem isn't photo capture or storage—it's **finding the right photo when you need it**. Engineers waste significant time searching through poorly organized SharePoint folders and remembering which photos contain specific hazards or controls.

This MVP focuses on intelligent photo organization and rapid discovery, providing AI-powered tagging with confidence levels, smart grouping suggestions, and intuitive search capabilities. Built with modern technologies (Next.js, Supabase, shadcn/ui), the application will initially serve as a single-tenant solution for internal validation, with architecture designed for future multi-tenant expansion.

## 2. Goals (MVP)

**Primary Goals:**
* **Accelerate Photo Discovery**: Reduce time spent searching for specific photos from minutes to seconds through intelligent tagging and search
* **Automate Initial Organization**: Provide confidence-based AI tagging that auto-applies high-certainty tags and suggests medium-certainty options
* **Enable Smart Photo Grouping**: Automatically identify and suggest related photos (e.g., multiple angles of the same machine or control system)
* **Seamlessly Integrate with Current Workflow**: Support easy export/download to maintain compatibility with existing Word document reporting process
* **Validate Core Value Proposition**: Confirm that intelligent organization significantly improves engineer productivity and report quality

**Secondary Goals:**
* Establish foundation for future multi-tenant architecture with PostgreSQL database design
* Create mobile-responsive interface using modern web technologies for office and limited field use
* Build extensible framework for future features (risk assessment integration, voice-to-text, native mobile apps)

## 3. Target Audience

**Primary Users:**
* Machine Safety Engineers in manufacturing environments
* Risk Assessment Specialists working with industrial machinery
* Safety consultants managing multiple client projects

**User Context:**
* Managing 200-400 photos per week per engineer
* Working primarily in office environment for MVP with mobile-responsive access
* Focus on manufacturing plant machinery (excludes mobile plant equipment like forklifts)
* Android phone users, tech-savvy
* Currently using SharePoint folder structures organized by customer/project/photos
* Existing workflow: Phone photos → Google Photos → PC download → SharePoint → Word reports

## 4. User Stories (MVP)

### Photo Upload & AI Processing
* As an engineer, I want to drag and drop multiple photos with clear upload progress so I can quickly add photos from my current workflow
* As an engineer, I want to optionally assign photos to a site and project during upload to maintain organization without being forced to categorize everything
* As an engineer, I want the system to automatically apply tags when the AI is highly confident (80%+) so obvious classifications happen without my input
* As an engineer, I want to see suggested tags for medium-confidence items (60-80%) so I can quickly approve or reject them
* As an engineer, I want AI-generated descriptions that help me remember what each photo shows

### Smart Discovery & Organization  
* As an engineer, I want to search for photos by typing hazard types (e.g., "estop", "pinch point") so I can quickly find relevant safety evidence
* As an engineer, I want to filter photos by control types (e.g., "light curtain", "guarding") to find specific safety measures
* As an engineer, I want to filter photos by site and project to focus on specific work contexts without being required to categorize everything
* As an engineer, I want the system to suggest groups of related photos (e.g., "8 photos appear to be of the same conveyor system") so I can organize project documentation efficiently
* As an engineer, I want the system to suggest site/project assignments based on photo content and previous uploads to speed up organization
* As an engineer, I want to view photos in a responsive grid that works seamlessly on my phone and desktop

### Current Workflow Integration
* As an engineer, I want to easily download selected photos so I can add them to my Word document reports
* As an engineer, I want to download photos organized by project to match my current SharePoint folder structure
* As an engineer, I want to create custom albums for specific projects that match my current folder structure
* As an engineer, I want to bulk assign photos to sites and projects after upload to organize existing photo libraries
* As an engineer, I want to add detailed notes to photos for report writing context

### User Management (Single Tenant)
* As a team member, I want to access all photos uploaded by our department so we can collaborate on projects
* As an engineer, I want to see who uploaded each photo and when for project tracking
* As a user, I want real-time updates when colleagues add or modify photos so our collaboration stays synchronized

## 5. Features (MVP Detail)

### 5.1. Confidence-Based AI Tagging
* **High Confidence Auto-Tagging (80%+)**: Automatically applies tags without user intervention
* **Medium Confidence Suggestions (60-80%)**: Displays suggested tags with easy approve/reject interface using shadcn/ui Badge components
* **Tag Categories Focus**:
  * **Machine Types**: Press, Lathe, Conveyor, Robot, CNC, Packaging Line
  * **Hazard Types**: Pinch Point, Entanglement, Crushing, Electrical, Sharp Edge, Burn Risk
  * **Control Types**: E-Stop, Guarding, Light Curtain, Interlock, Barrier, Warning Signage
  * **Components**: Motor, Control Panel, Actuator, Belt, Robot Arm, Workstation
* **AI-Generated Descriptions**: Concise, editable descriptions focusing on safety-relevant details
* **Smart Site/Project Suggestions**: AI analyzes photo content and user patterns to suggest site and project assignments
* **Future Consideration**: Alignment with AS4024 standards for post-MVP enhancement

### 5.2. Sites & Projects Organization (Optional)
* **Flexible Hierarchy**: Optional site (customer/facility) and project (work scope) assignment
* **Upload Integration**: Combobox selectors during upload with "create new" options using shadcn/ui components
* **Autocomplete & Suggestions**: Smart suggestions based on previous uploads and photo analysis
* **Retroactive Organization**: Bulk assignment tools for organizing existing photo libraries
* **No Forced Categorization**: Users can upload and organize photos without requiring site/project assignment
* **Current Workflow Alignment**: Structure mirrors existing SharePoint customer/project/photos folder hierarchy

### 5.3. Smart Photo Discovery
* **Intelligent Search**: Full-text search across tags, descriptions, notes, sites, and projects with PostgreSQL search capabilities
* **Command Interface**: shadcn/ui Command component for fast search with keyboard navigation
* **Multi-Filter Interface**: Combine filters for machine type, hazard type, control type, site, project, date, uploader using Select and Checkbox components
* **Smart Grouping Suggestions**: 
  * Automatic identification of photo series (same machine, different angles)
  * Project-based grouping recommendations
  * Site-based organization suggestions
  * "Find similar photos" feature for individual images
* **Quick Filters**: One-click access to common searches (e.g., "All E-Stops", "Untagged Photos", "Current Project")
* **Project Views**: Filter to show only photos from specific projects or sites for focused work
* **Real-time Search Results**: Instant updates as colleagues add photos via Supabase real-time subscriptions

### 5.4. Mobile-Responsive Interface
* **Next.js Responsive Design**: Built with Tailwind CSS breakpoints for optimal experience across devices
* **shadcn/ui Components**: Touch-friendly interactions with proper mobile sizing
* **Next.js Image Optimization**: Automatic WebP conversion, lazy loading, and responsive images with blur placeholders
* **Touch-Friendly Interactions**: Easy tag management and photo browsing on mobile devices
* **Progressive Loading**: Thumbnail → medium → full size image strategy for fast mobile performance
* **Responsive Grid**: Adapts from desktop multi-column to mobile single-column layout using CSS Grid

### 5.5. Project Organization & Export
* **Custom Albums**: User-created groups using shadcn/ui Dialog and Form components
* **Project-Based Downloads**: Export photos organized by site/project with folder structure maintained
* **Bulk Operations**: Multi-select photos for batch tagging, site/project assignment, album assignment, or download using DataTable with row selection
* **Download Management**: Single photo or batch download with original filenames preserved and organized by project
* **SharePoint Integration Ready**: Download structure matches customer/project/photos hierarchy for easy SharePoint upload
* **Notes System**: Detailed, searchable notes using shadcn/ui Textarea with auto-save functionality

### 5.6. Single-Tenant Architecture (Internal Use)
* **Department Access**: All team members can view/edit all photos and metadata with Row Level Security
* **User Attribution**: Clear indication of who uploaded each photo and when
* **Data Structure**: PostgreSQL database designed for multi-tenant expansion with proper foreign key relationships
* **Supabase Authentication**: Email/password with department-wide access and secure session management
* **Real-time Collaboration**: Live updates when team members modify photos or metadata

## 6. Technical Implementation

### 6.1. Technology Stack
* **Frontend**: Next.js 14 (App Router) with TypeScript for type safety and optimal performance
* **UI Framework**: shadcn/ui components with Tailwind CSS for beautiful, accessible components and rapid styling
* **Backend**: Supabase for modern, scalable infrastructure
  * **PostgreSQL Database**: Photo metadata, tags, descriptions, notes, user data with ACID compliance and complex queries. Production instances will have automated daily backups and Point-in-Time Recovery (PITR) enabled.
  * **Supabase Storage**: Photo files with automatic optimization, CDN delivery, and WebP conversion
  * **Supabase Auth**: User authentication with Row Level Security policies
  * **Edge Functions**: Deno-based serverless functions for AI processing with global edge deployment
* **AI Processing**: Google Cloud Gemini Vision API via Supabase Edge Functions or Next.js API routes
* **State Management**: TanStack Query for server state caching, optimistic updates, and mutation retries + Zustand for client state
* **Analytics**: PostHog for user behavior tracking, performance monitoring, and feature usage analytics
* **Deployment**: Vercel for optimal Next.js hosting with automatic edge optimization and image processing

### 6.2. Database Architecture
```sql
-- Supabase PostgreSQL Schema with Row Level Security

-- Organizations table
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Users table  
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email TEXT NOT NULL UNIQUE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'engineer' CHECK (role IN ('engineer', 'admin')),
  first_name TEXT,
  last_name TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Sites table
CREATE TABLE sites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  customer TEXT,
  location TEXT,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Projects table
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'on_hold')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Photos table with full-text search
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  site_id UUID REFERENCES sites(id) ON DELETE SET NULL,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  uploader_id UUID REFERENCES users(id) ON DELETE SET NULL,
  storage_path TEXT NOT NULL,
  original_filename TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  width INTEGER,
  height INTEGER,
  ai_tags JSONB DEFAULT '[]',
  user_tags JSONB DEFAULT '[]',
  ai_confidence JSONB DEFAULT '{}',
  ai_description TEXT,
  user_description TEXT,
  notes TEXT,
  processing_status TEXT DEFAULT 'pending' CHECK (processing_status IN ('pending', 'processing', 'completed', 'failed')),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector('english', 
      COALESCE(ai_description, '') || ' ' || 
      COALESCE(user_description, '') || ' ' || 
      COALESCE(notes, '') || ' ' ||
      COALESCE(original_filename, '')
    )
  ) STORED,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Albums table
CREATE TABLE albums (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  creator_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Album photos junction table
CREATE TABLE album_photos (
  album_id UUID REFERENCES albums(id) ON DELETE CASCADE,
  photo_id UUID REFERENCES photos(id) ON DELETE CASCADE,
  added_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (album_id, photo_id)
);

-- Indexes for performance
CREATE INDEX idx_photos_organization_id ON photos(organization_id);
CREATE INDEX idx_photos_project_id ON photos(project_id);
CREATE INDEX idx_photos_site_id ON photos(site_id);
CREATE INDEX idx_photos_created_at ON photos(created_at DESC);
CREATE INDEX idx_photos_ai_tags ON photos USING GIN(ai_tags);
CREATE INDEX idx_photos_user_tags ON photos USING GIN(user_tags);
CREATE INDEX idx_photos_search_vector ON photos USING GIN(search_vector);

-- Row Level Security policies
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE album_photos ENABLE ROW LEVEL SECURITY;

-- RLS policies for single-tenant with multi-tenant foundation
CREATE POLICY "Users can only access their organization's data" 
  ON photos FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can only access their organization's sites" 
  ON sites FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can only access their organization's projects" 
  ON projects FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can only access their organization's albums" 
  ON albums FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

-- User feedback table
CREATE TABLE user_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  feedback_type TEXT NOT NULL CHECK (feedback_type IN ('feature_rating', 'bug_report', 'suggestion', 'general')),
  feature_name TEXT, -- e.g., 'ai_tagging', 'search', 'upload'
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  context_data JSONB, -- Page URL, user action, relevant IDs
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'reviewed', 'addressed')),
  created_at TIMESTAMP DEFAULT NOW()
);

-- AI correction tracking table
CREATE TABLE ai_corrections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID REFERENCES photos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  correction_type TEXT NOT NULL CHECK (correction_type IN ('tag_added', 'tag_removed', 'description_edited', 'suggestion_accepted', 'suggestion_rejected')),
  ai_original_value TEXT, -- What AI suggested
  ai_confidence_score DECIMAL(3,2), -- AI confidence level
  user_final_value TEXT, -- What user changed it to
  context_data JSONB, -- Photo metadata, other tags present, etc.
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for feedback and corrections
CREATE INDEX idx_user_feedback_organization_id ON user_feedback(organization_id);
CREATE INDEX idx_user_feedback_created_at ON user_feedback(created_at DESC);
CREATE INDEX idx_ai_corrections_photo_id ON ai_corrections(photo_id);
CREATE INDEX idx_ai_corrections_correction_type ON ai_corrections(correction_type);
CREATE INDEX idx_ai_corrections_created_at ON ai_corrections(created_at DESC);

-- RLS policies for feedback and corrections
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_corrections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their organization's feedback" 
  ON user_feedback FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can only access their organization's corrections" 
  ON ai_corrections FOR ALL 
  USING (organization_id = (SELECT organization_id FROM users WHERE id = auth.uid()));

-- Real-time subscriptions for collaboration
CREATE OR REPLACE FUNCTION notify_photo_changes()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('photo_changes', row_to_json(NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER photo_changes_trigger
  AFTER INSERT OR UPDATE ON photos
  FOR EACH ROW EXECUTE FUNCTION notify_photo_changes();
```

### 6.3. AI Processing Workflow
1. **Image Upload**: Photo uploaded to Supabase Storage with automatic optimization and metadata extraction
2. **Edge Function Trigger**: Supabase Edge Function or Next.js API route processes image asynchronously
3. **AI Analysis**: Gemini Vision API analyzes image for tags, descriptions, and confidence scores
4. **Confidence Processing**: Results categorized by confidence level (80%+ auto-apply, 60-80% suggest)
5. **Database Update**: Results stored in PostgreSQL with real-time updates to UI via Supabase subscriptions
6. **Smart Suggestions**: AI analyzes patterns across organization's photos to suggest site/project assignments
7. **Search Indexing**: Full-text search vector automatically updated for instant searchability

### 6.4. Component Architecture (shadcn/ui)
```typescript
// Key UI components leveraging shadcn/ui for consistent design
- Button, Input, Textarea (form elements with consistent styling)
- Dialog, Sheet (modals and sidebars for photo details, settings, and feedback)
- Select, Combobox (dropdowns with search for sites, projects, tags)
- Badge (tag chips with consistent styling and interactions)
- Card (photo containers with hover states and consistent spacing)
- Tabs, Accordion (organization and navigation)
- Progress (upload indicators with smooth animations)
- Tooltip (helpful hints and descriptions)
- Command (fast search interface with keyboard navigation)
- DataTable (photo lists with sorting, filtering, and bulk operations)
- Form (consistent form validation and error handling)
- Alert (user feedback and notifications)
- Separator (visual organization)
- Avatar (user identification)
- DropdownMenu (context menus for photo actions)
- RadioGroup, Checkbox (feedback rating and correction options)
- Popover (contextual feedback collection)

// Custom components built on shadcn/ui
- PhotoCard: Card + Badge + DropdownMenu
- TagSelector: Combobox + Badge management with correction tracking
- PhotoUpload: Dialog + Progress + Form
- FilterSidebar: Sheet + Select + Checkbox combinations
- PhotoGrid: Custom grid with DataTable-like functionality
- FeedbackWidget: Popover + Form + RadioGroup for contextual feedback
- CorrectionTracker: Background component that logs all AI interactions
```

### 6.5. Performance Optimizations
* **Next.js Image Component**: Automatic WebP conversion, lazy loading, responsive images with blur placeholders for optimal photo loading
* **Edge Deployment**: Global CDN via Vercel for fast photo delivery and reduced latency
* **Database Indexing**: PostgreSQL indexes on commonly filtered fields (tags, project_id, created_at) and full-text search vectors
* **Real-time Updates**: Supabase subscriptions for collaborative features without polling, reducing server load
* **Progressive Loading**: Thumbnail (200px WebP) → medium (800px WebP) → full size loading strategy
* **Component Optimization**: React.memo and proper dependency arrays for photo grid performance
* **Virtual Scrolling**: Handle 1000+ photos with react-window integration for smooth scrolling
* **Caching & Connection Handling**: TanStack Query with stale-while-revalidate for optimal user experience and automatic retry logic for mutations to handle intermittent network failures.
* **Edge Functions**: Deno-based processing with faster cold starts than traditional serverless
* **Automatic Compression**: Supabase Storage automatic image optimization and WebP conversion

### 6.6. Performance Targets
* **Upload Speed**: Batch uploads of 20+ photos in under 2 minutes with parallel processing
* **Search Response**: Sub-second response for keyword searches via PostgreSQL full-text search with proper indexing
* **AI Processing**: Tag suggestions available within 10 seconds of upload via Edge Functions with global deployment
* **Mobile Performance**: Gallery loads in under 3 seconds on mobile with Next.js Image optimization and progressive loading
* **Real-time Updates**: Collaborative changes reflected in UI within 500ms via Supabase subscriptions
* **Core Web Vitals**: LCP < 2.5s, FID < 100ms, CLS < 0.1 for optimal user experience

## 7. Success Metrics (MVP)

### 7.1. Core Value Metrics
* **Time to Find Photo**: Target 80% reduction in time spent searching for specific photos (from 2-3 minutes to 15-30 seconds)
* **Tagging Accuracy**: 70%+ of auto-applied tags accepted without modification by users
* **Search Usage**: 80%+ of photo discovery happens through search/filter vs. manual browsing
* **Weekly Photo Volume**: Successfully handle 400+ photos uploaded per user per week without performance degradation

### 7.2. User Adoption Metrics
* **Daily Active Users**: 90%+ of department engineers using daily within 4 weeks of deployment
* **Photo Upload Rate**: Average 200+ photos uploaded per user per week, matching current workflow volume
* **Feature Utilization**: 
  * 60%+ of users creating custom albums within 2 weeks
  * 80%+ of users using search functionality weekly
  * 40%+ of photos assigned to sites/projects within 4 weeks
* **User Satisfaction**: NPS score of 50+ after 8 weeks of use based on workflow improvement

### 7.3. Technical Performance
* **System Reliability**: 99%+ uptime during business hours with Vercel SLA
* **Processing Speed**: 95% of photos processed and tagged within 30 seconds of upload
* **Search Performance**: 95% of searches return results in under 1 second
* **Mobile Usage**: 30%+ of interactions happen on mobile devices, validating responsive design

### 7.4. Business Impact & Learning Metrics
* **Workflow Efficiency**: Measurable reduction in time from photo capture to report inclusion
* **Photo Organization**: 60%+ reduction in "orphaned" photos (photos that can't be found when needed)
* **Team Collaboration**: Increased photo sharing and reuse across team members
* **AI Improvement**: Month-over-month improvement in AI tagging accuracy based on user corrections
* **User Satisfaction**: Feature-specific satisfaction scores and overall app NPS
* **Feedback Response**: Average time to acknowledge and address user feedback

## 8. Risk Assessment & Mitigation

### 8.1. Technical Risks
* **AI API Costs**: 400 photos/week = ~$50-100/month for Gemini Vision API calls
  * *Mitigation*: Monitor usage via Supabase Edge Function logs, implement cost alerts, batch processing optimization, consider API rate limiting
* **Performance at Scale**: Large photo libraries may impact PostgreSQL query performance and UI responsiveness
  * *Mitigation*: Implement proper indexing strategy, pagination with cursor-based navigation, virtual scrolling, automated image compression pipeline
* **AI Accuracy**: Off-the-shelf models may not recognize specialized industrial equipment accurately
  * *Mitigation*: Conservative confidence thresholds, easy user correction interface, plan for custom model training post-MVP, collect correction data for future improvements
* **Storage Costs**: Photo storage could scale significantly with 400+ photos/week per user
  * *Mitigation*: Supabase Storage automatic compression, WebP conversion, implement tiered storage strategy, monitor storage usage

### 8.2. Business Risks
* **User Adoption**: Engineers may resist changing established workflows
  * *Mitigation*: Focus on augmenting current process rather than replacing it, provide easy export to maintain SharePoint compatibility, gradual rollout with power users first
* **Integration Challenges**: May not seamlessly fit with SharePoint/Word workflow
  * *Mitigation*: Prioritize download/export functionality that maintains folder structure, gather user feedback early in development cycle
* **Data Migration**: Users have existing photo libraries that need organization
  * *Mitigation*: Build bulk import tools, retroactive organization features, provide migration assistance

### 8.3. Product Risks
* **Feature Complexity**: Too many features may overwhelm users in MVP
  * *Mitigation*: Progressive disclosure of features, optional nature of sites/projects, focus on core workflow first
* **Mobile Performance**: Poor mobile experience could limit adoption
  * *Mitigation*: Mobile-first responsive design, Next.js Image optimization, performance monitoring

## 9. Non-Goals (MVP)

**Explicitly Out of Scope:**
* Native mobile applications (post-MVP roadmap item)
* In-app photo annotation/editing tools (arrows, shapes, cropping)
* Direct SharePoint integration (download/export supported instead)
* Automated report generation features
* Multi-tenant architecture (single organization MVP, but database designed for expansion)
* AS4024 compliance enforcement (future consideration for specialized features)
* **Advanced user roles/permissions** (basic role support in database schema for future)
* **Full Offline Functionality**: The application requires an internet connection. The MVP includes basic resilience to *intermittent* network drops for uploads, but does not support a full offline workflow (this is a post-MVP item).
* **Integration with other safety management systems**
* Custom AI model training (using off-the-shelf Gemini Vision for MVP)
* Video file support (photos only for MVP)
* Advanced photo editing (resize, crop, filters)
* API access for third-party integrations
* White-label or custom branding options

## 10. Future Roadmap (Post-MVP)

### Phase 2: Enhanced Intelligence (Months 3-6)
* **AI Model Training**: Custom model training on industrial safety imagery using collected correction data from MVP
* **AS4024 Compliance**: Automated compliance checking and recommendations based on Australian safety standards
* **Voice-to-Text Integration**: Voice notes and descriptions for faster data entry
* **Advanced Search**: Semantic search capabilities and natural language queries
* **Smart Recommendations**: AI-powered suggestions for safety improvements based on photo analysis
* **Feedback Analytics**: Advanced analytics dashboard for user feedback trends and feature usage patterns

### Phase 3: Multi-Tenant Platform (Months 6-9)
* **Organization Management**: Multi-tenant architecture with billing and subscription management
* **Advanced User Roles**: Granular permissions (viewer, editor, admin, auditor)
* **White-label Deployment**: Custom branding and domain options for enterprise clients
* **API Access**: RESTful API for third-party integrations
* **Enterprise Security**: SSO integration, advanced audit logging, compliance certifications

### Phase 4: Complete Safety Platform (Months 9-12)
* **Risk Assessment Workflow**: Integrated risk assessment tools and templates
* **SRS Generation**: Safety Requirements Specification document generation
* **Validation and Compliance Tracking**: Workflow for safety validation and regulatory compliance
* **Native Mobile Applications**: iOS and Android apps for field work with offline capabilities
* **3D Reconstruction**: Generate 3D models from multiple photo angles for virtual inspections

### Phase 5: Advanced Analytics (Months 12+)
* **Safety Analytics Dashboard**: Trend analysis and safety metrics across projects
* **Predictive Safety**: AI-powered predictions for potential safety issues
* **Industry Benchmarking**: Compare safety practices against industry standards
* **Automated Report Generation**: Complete safety reports with AI-generated recommendations

## 11. Timeline & Implementation Plan

### Development Phases

**Phase 1: Foundation (Weeks 1-3)**
* Next.js + Supabase + shadcn/ui project setup
* Database schema implementation with RLS policies
* Basic authentication and user management
* Core layout and navigation with shadcn/ui components

**Phase 2: Core Features (Weeks 4-6)**
* Photo upload with Supabase Storage integration
* AI processing pipeline with Gemini Vision API
* Basic photo grid and search functionality
* Tag management interface

**Phase 3: Organization Features (Weeks 7-9)**
* Sites and projects implementation
* Advanced filtering and search
* Album creation and management
* Export and download functionality

**Phase 4: Polish & Performance (Weeks 10-12)**
* Mobile responsiveness optimization
* Performance tuning and caching
* User testing and feedback incorporation
* Production deployment and monitoring

### Deployment Strategy
* **Development Environment**: Supabase development project + Vercel preview deployments
* **Staging Environment**: Supabase staging project + Vercel staging deployment
* **Production Environment**: Supabase production project + Vercel production deployment
* **Monitoring**: Vercel Analytics + Supabase Dashboard + error tracking

### Success Evaluation Timeline
* **Week 6**: Internal team testing begins with core features
* **Week 8**: Department-wide rollout
* **Week 12**: Success metrics evaluation and Phase 2 planning
* **Week 16**: User satisfaction survey and feature prioritization for next phase

## 13. Multi-Agent Development Strategy

### Agent Distribution & High-Level Goals

This section outlines the parallel development approach using Git worktrees and Claude Code agents, with each agent responsible for specific feature areas to maximize development velocity while maintaining code quality.

#### Agent 1: Foundation & Infrastructure
**Primary Goal**: Establish solid technical foundation for all other agents
**Key Deliverables**:
- Next.js 14 + TypeScript + Tailwind project setup with optimal configuration
- shadcn/ui component library integration and theme customization
- Supabase integration (database connection, auth setup, storage configuration)
- Basic routing structure and layout components
- Development tooling (ESLint, Prettier, Git hooks)
- Deployment pipeline to Vercel with environment configuration

**Success Criteria**: Other agents can immediately start building features on a stable foundation

#### Agent 2: Authentication & User Management
**Primary Goal**: Secure user access and single-tenant organization structure
**Key Deliverables**:
- Supabase Auth integration with email/password authentication
- User registration and login flows with proper error handling
- Single-tenant organization setup and user role management
- Row Level Security (RLS) policy implementation and testing
- User profile management and session handling
- Basic admin capabilities for user management

**Success Criteria**: Users can securely register, login, and access organization-specific data

#### Agent 3: Photo Upload & Storage
**Primary Goal**: Efficient photo ingestion pipeline with AI processing trigger
**Key Deliverables**:
- Drag-and-drop upload interface with progress tracking
- Supabase Storage integration with automatic image optimization
- Batch upload handling with parallel processing
- File validation (format, size) and error handling
- AI processing pipeline trigger (Edge Function or API route)
- Upload status management and retry logic

**Success Criteria**: Users can upload 20+ photos efficiently with immediate AI processing

#### Agent 4: AI Processing & Tagging System
**Primary Goal**: Intelligent photo analysis with confidence-based tagging
**Key Deliverables**:
- Gemini Vision API integration via Supabase Edge Functions
- Confidence-based tagging logic (80%+ auto-apply, 60-80% suggest)
- Tag management UI with shadcn/ui Badge components
- AI description generation and editing interface
- Processing status indicators and error handling
- AI correction tracking system for future model training

**Success Criteria**: Photos are automatically tagged with high accuracy and users can easily refine results

#### Agent 5: Search & Discovery Engine
**Primary Goal**: Fast, intuitive photo discovery with advanced filtering
**Key Deliverables**:
- Full-text search implementation using PostgreSQL search vectors
- Multi-filter interface with shadcn/ui Select and Command components
- Smart grouping suggestions and similar photo detection
- Advanced search with autocomplete and quick filters
- TanStack Query integration for optimal caching and performance
- Virtual scrolling for large photo libraries

**Success Criteria**: Users can find specific photos in seconds using various search methods

#### Agent 6: Organization & Export Features
**Primary Goal**: Flexible photo organization matching current workflows
**Key Deliverables**:
- Sites and projects optional hierarchy with smart suggestions
- Album creation and management with drag-and-drop functionality
- Bulk operations (multi-select, batch assignment, tagging)
- Export functionality maintaining SharePoint folder structure
- Notes system with auto-save and search integration
- Retroactive organization tools for existing photo libraries

**Success Criteria**: Users can organize photos to match current SharePoint workflows and export seamlessly

#### Agent 7: Feedback & Analytics System
**Primary Goal**: User engagement and continuous improvement mechanisms
**Key Deliverables**:
- PostHog integration for comprehensive analytics and user behavior tracking
- Event tracking for core actions (photo uploads, AI tag usage, search patterns, export usage)
- Performance monitoring (upload speed, AI processing time, search response time)
- User journey funnels (signup → first upload → first export)
- Contextual feedback collection with shadcn/ui Sheet and Form components
- Feature-specific rating system (1-5 stars) with context capture
- Bug reporting and suggestion submission forms
- AI correction logging and analytics for training data collection
- Basic admin dashboard for feedback review and AI improvement metrics
- Feedback status tracking and user notification system

**Success Criteria**: Users actively provide feedback, AI correction data is collected, and usage patterns are understood through PostHog analytics

#### Agent 8: Mobile Optimization & Performance
**Primary Goal**: Excellent mobile experience and optimal performance across devices
**Key Deliverables**:
- Mobile-responsive design refinement using Tailwind breakpoints
- Touch-friendly interactions and gesture support
- Progressive image loading with Next.js Image component optimization
- Performance optimization (virtual scrolling, lazy loading, caching)
- Mobile-specific UI improvements and navigation patterns
- Cross-browser testing and accessibility improvements

**Success Criteria**: Seamless mobile experience with desktop-quality functionality

## 12. Immediate Next Steps
**Dependency Management**: Agents work in sequence where needed, with clear handoff protocols
**Integration Points**: Regular integration testing as features are merged
**Quality Assurance**: Each agent includes comprehensive testing of their components
**Documentation**: Each agent documents their implementation for future maintenance

*Note: Detailed multi-agent development strategy, Git worktree management, and merge protocols are documented separately in the Development Strategy document.*

### Technical Setup (Week 1)
1. **Repository Setup**: Create GitHub repository with proper branching strategy
2. **Project Initialization**: Next.js 14 + TypeScript + Tailwind + shadcn/ui setup
3. **Supabase Configuration**: Database setup, RLS policies, Edge Functions configuration
4. **Development Environment**: Local development setup with environment variables
5. **CI/CD Pipeline**: Vercel deployment pipeline with staging and production environments

### Design & Planning (Week 1-2)
1. **UI/UX Wireframes**: Create basic wireframes for key screens using shadcn/ui patterns
2. **Database Schema Finalization**: Review and implement PostgreSQL schema with proper indexes
3. **API Design**: Define Edge Function interfaces for AI processing
4. **Component Architecture**: Plan shadcn/ui component usage and customizations

### Team Preparation
1. **Development Standards**: Establish coding standards, commit conventions, and review processes
2. **Testing Strategy**: Define testing approach (unit, integration, E2E)
3. **User Feedback Plan**: Establish process for collecting and incorporating user feedback
4. **Documentation**: Set up technical documentation and user guides

### Risk Mitigation Preparation
1. **Cost Monitoring**: Set up billing alerts for Gemini API usage
2. **Performance Baseline**: Establish performance monitoring and alerting
3. **Backup Strategy**: Implement database backup and recovery procedures
4. **Security Review**: Conduct security assessment of RLS policies and authentication flow

This comprehensive PRD provides a solid foundation for multi-agent development with clear technical specifications, realistic timelines, and measurable success criteria. The modern tech stack (Next.js + Supabase + shadcn/ui) will enable rapid development while providing the scalability and performance needed for the photo-intensive workflow.
