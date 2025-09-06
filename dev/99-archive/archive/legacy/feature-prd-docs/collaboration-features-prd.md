# Product Requirements Document (PRD): Enhanced Collaboration & Activity Tracking

**Document Version:** 1.0  
**Date:** July 12, 2025  
**Parent Project:** Minerva Machine Safety Photo Organizer  
**Phase:** Post-MVP Enhancement for Closed Beta Launch

## 1. Introduction / Executive Summary

The Minerva Photo Organizer has reached 85% MVP completion with a solid foundation for collaboration. As we prepare for closed beta launch starting with your internal team and expanding to external companies, we need enhanced collaboration features that provide complete visibility into team activities, robust activity tracking, and secure cross-company photo sharing capabilities.

This PRD defines the collaboration and activity tracking enhancements needed to transform Minerva from a single-user photo management tool into a comprehensive team collaboration platform for machine safety professionals. The focus is on transparency, accountability, and seamless team coordination while maintaining the security and organization structure already established.

## 2. Problem Statement & Current State

### Current Capabilities (85% Complete)
✅ **Strong Foundation**:
- Multi-user authentication with organization isolation
- User attribution for uploads and basic actions
- Comprehensive audit logging infrastructure
- Row Level Security (RLS) for data protection
- Basic sharing capabilities

### Missing Collaboration Elements
❌ **Real-Time Collaboration**: No live updates when teammates modify content  
❌ **Activity Visibility**: Limited visibility into what teammates are doing  
❌ **Cross-Company Sharing**: No secure sharing between organizations  
❌ **Enhanced Attribution**: Basic tracking doesn't show full activity context  
❌ **Team Communication**: No comments, mentions, or discussion features  
❌ **Presence Indicators**: Users don't know who else is working on projects

### Business Need for Beta Launch
- **Internal Team Coordination**: Need full visibility of team activities for project management
- **External Company Collaboration**: Secure sharing with partner organizations for joint safety assessments
- **Accountability & Tracking**: Complete audit trails for safety compliance and reporting
- **User Confidence**: Teams need to see and trust that their collaborative work is properly tracked

## 3. Goals & Success Criteria

### Primary Goals
- **Complete Activity Transparency**: Every user action is visible and traceable to its source
- **Real-Time Team Coordination**: Live updates and presence indicators for seamless collaboration
- **Secure Cross-Company Sharing**: Safe, controlled photo and project sharing between organizations
- **Enhanced User Confidence**: Teams trust the system to track and preserve all collaborative work

### Success Metrics
- **Adoption**: 90%+ of team members actively using collaboration features within 2 weeks
- **Engagement**: 50%+ increase in cross-team photo sharing and reuse
- **Transparency**: 100% of user actions tracked and visible in activity feeds
- **External Sharing**: Successful collaboration with at least 1 external company during beta
- **User Satisfaction**: NPS 70+ for collaboration features specifically

## 4. User Stories

### Internal Team Collaboration
- As an engineer, I want to see who is currently viewing or working on the same project so I can coordinate with them
- As an engineer, I want to know when a teammate modifies photos or tags in my project so I stay informed
- As an engineer, I want to see a complete activity timeline for any photo showing who did what and when
- As a team lead, I want to see all team activity in one place so I can track project progress
- As an engineer, I want to @mention teammates in photo comments so they're notified of important findings

### Cross-Company Collaboration (Beta)
- As a safety consultant, I want to securely share specific photos with client engineers so they can review and provide feedback
- As an engineer, I want to share a project folder with external safety auditors so they can access relevant documentation
- As a project manager, I want to create time-limited sharing links for photos so external stakeholders can view them securely
- As an admin, I want to control what data can be shared externally and track all external sharing activities

### Activity Tracking & Attribution
- As an engineer, I want to see the complete history of any photo including uploads, AI processing, tag changes, and shares
- As a team lead, I want to understand which team members are most active in photo organization and tagging
- As an engineer, I want to see which AI suggestions were accepted vs. rejected by different users for quality insights
- As an admin, I want comprehensive audit trails for compliance and safety reporting purposes

### Enhanced User Experience
- As an engineer, I want notifications when shared photos are modified so I know about important updates
- As an engineer, I want to comment on photos to provide context and ask questions to teammates
- As an engineer, I want to see user avatars and names throughout the interface so I know who contributed what
- As a user, I want to control my notification preferences so I'm informed but not overwhelmed

## 5. Technical Requirements

### 5.1. Real-Time Collaboration Infrastructure

#### WebSocket Integration
```typescript
// Real-time connection management
interface RealtimeConnection {
  userId: string;
  organizationId: string;
  connectionId: string;
  currentPage: string;
  lastSeen: Date;
  isActive: boolean;
}

// Presence tracking for photos and projects
interface UserPresence {
  photoId?: string;
  projectId?: string;
  action: 'viewing' | 'editing' | 'uploading';
  timestamp: Date;
}
```

#### Live Updates System
- **Pusher/Supabase Realtime**: WebSocket connections for instant updates
- **Presence Broadcasting**: Show who's currently viewing photos/projects
- **Activity Broadcasting**: Instant notifications for tag changes, uploads, comments
- **Conflict Prevention**: Warning when multiple users edit the same content

### 5.2. Enhanced Activity Tracking

#### Expanded Audit System
```sql
-- Enhanced audit logs with context
ALTER TABLE audit_logs ADD COLUMN context_data JSONB;
ALTER TABLE audit_logs ADD COLUMN activity_type TEXT;
ALTER TABLE audit_logs ADD COLUMN related_users UUID[];
ALTER TABLE audit_logs ADD COLUMN session_id TEXT;

-- Photo activity tracking
CREATE TABLE photo_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID REFERENCES photos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'uploaded', 'viewed', 'tagged', 'described', 'shared', 'commented', 
    'ai_processed', 'exported', 'moved_to_project', 'favorited'
  )),
  details JSONB, -- Activity-specific details
  ip_address INET,
  user_agent TEXT,
  session_id TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- User sessions for presence tracking
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  session_id TEXT NOT NULL UNIQUE,
  device_info JSONB,
  current_page TEXT,
  is_active BOOLEAN DEFAULT true,
  last_activity TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### Activity Feed System
- **Personal Activity**: Track all user actions for personal history
- **Team Activity**: Organization-wide activity feed for team coordination
- **Photo Activity**: Complete timeline for each photo showing all interactions
- **Project Activity**: Project-level activity showing all team contributions

### 5.3. Cross-Company Collaboration

#### Secure Sharing Infrastructure
```sql
-- External sharing system
CREATE TABLE external_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  shared_by UUID REFERENCES users(id) ON DELETE SET NULL,
  share_type TEXT NOT NULL CHECK (share_type IN ('photo', 'project', 'album')),
  resource_id UUID NOT NULL,
  target_organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  target_user_email TEXT,
  permissions JSONB DEFAULT '{"view": true, "comment": false, "download": false}',
  expires_at TIMESTAMP,
  access_count INTEGER DEFAULT 0,
  last_accessed TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

-- Public link sharing
CREATE TABLE public_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  share_token TEXT NOT NULL UNIQUE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  resource_type TEXT NOT NULL CHECK (resource_type IN ('photo', 'album', 'project')),
  resource_id UUID NOT NULL,
  permissions JSONB DEFAULT '{"view": true, "download": false}',
  expires_at TIMESTAMP NOT NULL,
  max_views INTEGER,
  current_views INTEGER DEFAULT 0,
  password_hash TEXT, -- Optional password protection
  created_at TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);
```

#### Guest User System
- **Temporary Access**: External users can view shared content without full accounts
- **Limited Permissions**: Controlled access to only shared resources
- **Activity Tracking**: Full audit trail of external user activities
- **Expiration Management**: Automatic cleanup of expired access

### 5.4. Enhanced User Interface Components

#### Real-Time Presence Indicators
```typescript
// User presence component
<UserPresence 
  photoId={photo.id}
  showActiveUsers={true}
  showRecentActivity={true}
  maxUsers={5}
/>

// Activity timeline component
<ActivityTimeline 
  photoId={photo.id}
  includeAI={true}
  includeViews={false}
  maxItems={20}
/>

// Live notification component
<NotificationCenter 
  realTime={true}
  types={['mentions', 'shares', 'comments', 'tag_changes']}
  position="top-right"
/>
```

#### Enhanced Photo Detail View
- **User Attribution**: Clear display of uploader, AI processor, and all contributors
- **Activity Timeline**: Chronological list of all photo interactions
- **Current Viewers**: Live list of users currently viewing the photo
- **Quick Actions**: Comment, share, mention, and tag buttons with real-time updates

#### Activity Dashboard
- **Team Overview**: Real-time dashboard showing all team activities
- **Personal Activity**: User's own activity history and statistics
- **Project Activity**: Activity filtered by specific projects or sites
- **External Sharing**: Overview of all cross-company sharing activities

### 5.5. Communication & Notification System

#### Comment System
```sql
-- Photo comments
CREATE TABLE photo_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID REFERENCES photos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  mentioned_users UUID[], -- Array of mentioned user IDs
  parent_comment_id UUID REFERENCES photo_comments(id) ON DELETE CASCADE,
  is_resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### @Mention System
- **User Mentions**: @username functionality in comments
- **Automatic Notifications**: Email and in-app notifications for mentions
- **Permission Aware**: Only mention users with access to the content
- **Context Preservation**: Maintain context of where mention occurred

#### Notification Management
```typescript
interface NotificationPreferences {
  mentions: boolean;
  photoShares: boolean;
  projectUpdates: boolean;
  aiProcessingComplete: boolean;
  tagChanges: boolean;
  comments: boolean;
  weeklyDigest: boolean;
  emailNotifications: boolean;
  pushNotifications: boolean;
}
```

## 6. Implementation Plan

### Phase 1: Real-Time Foundation (Week 1)
**Goal**: Establish real-time infrastructure
- Implement WebSocket connection management (Pusher or Supabase Realtime)
- Add user session tracking and presence detection
- Create basic live update system for photo modifications
- Add real-time indicators to photo detail views

### Phase 2: Enhanced Activity Tracking (Week 2)
**Goal**: Complete activity visibility
- Expand audit logging with detailed context
- Implement photo activity timeline component
- Create team activity dashboard
- Add user attribution displays throughout UI

### Phase 3: Comment & Communication System (Week 3)
**Goal**: Enable team communication
- Implement photo comment system with threading
- Add @mention functionality with notifications
- Create notification center with real-time updates
- Build user notification preferences management

### Phase 4: Cross-Company Sharing (Week 4)
**Goal**: Enable secure external collaboration
- Implement external sharing system with permissions
- Create public link sharing with expiration
- Add guest user access for external stakeholders
- Build sharing management dashboard

### Phase 5: Advanced Features & Polish (Week 5)
**Goal**: Enhance user experience
- Add advanced presence indicators (typing, viewing)
- Implement activity filtering and search
- Create email notification templates
- Add sharing analytics and usage tracking

### Phase 6: Testing & Beta Preparation (Week 6)
**Goal**: Prepare for beta launch
- Comprehensive testing of collaboration features
- Performance optimization for real-time features
- Security audit of sharing and access controls
- User training materials and documentation

## 7. Security & Privacy Considerations

### Data Protection
- **Organization Isolation**: Strict RLS policies prevent cross-organization data access
- **Sharing Audit**: Complete audit trail of all external sharing activities
- **Access Control**: Granular permissions for shared content
- **Data Encryption**: All shared data encrypted in transit and at rest

### External Sharing Security
- **Expiration Management**: All external shares have mandatory expiration dates
- **Access Limits**: View count limits and IP restrictions for public shares
- **Permission Granularity**: Fine-grained control over what external users can do
- **Revocation**: Instant revocation of external access when needed

### Privacy Controls
- **User Consent**: Clear consent for activity tracking and sharing
- **Data Minimization**: Only track necessary activities for functionality
- **User Control**: Users can control their visibility and notification preferences
- **GDPR Compliance**: Right to deletion and data export for user activities

## 8. User Experience Guidelines

### Real-Time Feedback
- **Immediate Updates**: Changes appear instantly without page refresh
- **Clear Indicators**: Visual cues for who's online and what they're doing
- **Non-Intrusive**: Presence and activity indicators don't obstruct main content
- **Contextual**: Show relevant activity and presence based on current user focus

### Activity Transparency
- **Clear Attribution**: Always show who did what and when
- **Contextual Information**: Provide enough context to understand activities
- **Timeline Clarity**: Chronological ordering with clear timestamps
- **Actionable Items**: Easy access to related content from activity items

### Collaboration Workflow
- **Seamless Sharing**: One-click sharing with smart permission defaults
- **Clear Permissions**: Always visible what permissions are granted
- **Easy Communication**: Quick access to comments and mentions
- **Progress Visibility**: Clear indicators of project collaboration status

## 9. Success Metrics & KPIs

### Adoption Metrics
- **User Engagement**: Daily/weekly active collaboration feature usage
- **Feature Adoption**: Percentage of users using comments, sharing, real-time features
- **Cross-Team Usage**: Number of photos shared between team members
- **External Collaboration**: Successful cross-company sharing activities

### Productivity Metrics
- **Time to Information**: Reduction in time to find relevant photos/projects
- **Collaboration Efficiency**: Faster project completion with team coordination
- **Communication Reduction**: Decrease in external communication (emails, calls)
- **Knowledge Sharing**: Increase in photo reuse and knowledge transfer

### Quality Metrics
- **Activity Accuracy**: Correctness of activity tracking and attribution
- **System Reliability**: Uptime and performance of real-time features
- **User Satisfaction**: NPS scores specifically for collaboration features
- **Security Incidents**: Zero unauthorized access to shared content

### Business Impact
- **Beta Success**: Successful onboarding of external company during beta
- **User Retention**: Increased user retention with collaboration features
- **Team Productivity**: Measurable improvement in safety assessment workflows
- **Expansion Readiness**: Foundation for multi-tenant platform launch

## 10. Risk Assessment & Mitigation

### Technical Risks
- **Real-Time Performance**: WebSocket connections could impact performance
  - *Mitigation*: Implement connection pooling, optimize message frequency, graceful degradation
- **Data Privacy**: Enhanced tracking could raise privacy concerns
  - *Mitigation*: Clear privacy controls, user consent, transparent data usage policies
- **Security Vulnerabilities**: External sharing increases attack surface
  - *Mitigation*: Comprehensive security testing, penetration testing, access auditing

### User Experience Risks
- **Feature Overwhelm**: Too many collaboration features could confuse users
  - *Mitigation*: Progressive disclosure, user onboarding, feature toggles
- **Performance Impact**: Real-time features could slow down the application
  - *Mitigation*: Performance budgets, optimization testing, caching strategies

### Business Risks
- **Beta Failure**: External company collaboration could fail during beta
  - *Mitigation*: Thorough internal testing, gradual rollout, backup communication channels
- **Compliance Issues**: Enhanced tracking could create compliance challenges
  - *Mitigation*: Legal review, compliance documentation, audit-ready logging

## 11. Future Enhancements (Post-Beta)

### Advanced Collaboration
- **Video Calls**: Integrated video calling for photo discussions
- **Screen Sharing**: Share screens during photo review sessions
- **Workflow Automation**: Automated notifications and task assignments
- **Integration APIs**: Connect with external project management tools

### AI-Powered Collaboration
- **Smart Mentions**: AI suggestions for relevant team members to mention
- **Activity Insights**: AI analysis of team collaboration patterns
- **Conflict Detection**: AI detection of potential collaboration conflicts
- **Recommendation Engine**: AI recommendations for photo sharing and tagging

### Enterprise Features
- **Advanced Analytics**: Detailed collaboration analytics for team managers
- **Compliance Reporting**: Automated compliance reports based on activity data
- **Custom Workflows**: Organization-specific collaboration workflows
- **SSO Integration**: Enterprise single sign-on for external collaboration

This comprehensive collaboration enhancement will transform Minerva into a powerful team coordination platform while maintaining its core strength in intelligent photo organization. The phased implementation ensures a smooth transition from the current MVP to a full-featured collaboration platform ready for beta launch and external company partnerships.