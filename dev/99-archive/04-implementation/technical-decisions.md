# Technical Decisions & Architecture Notes

## Core Architecture Decisions

### Technology Stack Selection
**Decision Date:** Early 2025  
**Status:** ✅ Validated in production

#### Frontend Stack
- **Next.js 15** with App Router - Modern React framework with excellent performance
- **React 19** - Latest React with concurrent features and improved performance  
- **TypeScript** (strict mode) - Type safety and developer experience
- **Tailwind CSS v4** - Utility-first CSS with CSS-in-JS approach
- **shadcn/ui** - Comprehensive component library with accessibility

**Rationale:** Modern, performant stack with excellent developer experience and production stability.

#### Backend & Database
- **Supabase** (remote hosted) - PostgreSQL database with built-in auth and real-time
- **Row Level Security (RLS)** - Multi-tenant data isolation at database level
- **PostgreSQL** - Robust relational database with excellent full-text search
- **Vercel** - Serverless deployment with global edge network

**Rationale:** Fully managed backend reducing operational complexity while providing enterprise-grade security and performance.

#### AI & Processing
- **Google Cloud Vision API** - Reliable, accurate image analysis service
- **Server-side processing** - Consistent performance across devices
- **Batch processing** - Optimize API usage and reduce costs

**Rationale:** Google Cloud Vision provides best balance of accuracy, performance, and cost for equipment detection use case.

### Database Architecture Decisions

#### Multi-Tenancy Strategy
**Decision:** Row Level Security (RLS) policies for data isolation  
**Alternative Considered:** Separate databases per tenant  
**Rationale:** RLS provides better resource utilization while maintaining complete security isolation

```sql
-- Example RLS policy for photos table
CREATE POLICY "photos_tenant_isolation" ON photos
FOR ALL TO authenticated
USING (project_id IN (
  SELECT id FROM projects 
  WHERE owner_id = auth.uid() OR 
  id IN (SELECT project_id FROM project_members WHERE user_id = auth.uid())
));
```

#### Search Implementation
**Decision:** PostgreSQL full-text search with GIN indexes  
**Alternative Considered:** Elasticsearch, Algolia  
**Rationale:** Native PostgreSQL search provides excellent performance with simpler architecture

```sql
-- Full-text search index
CREATE INDEX photos_search_idx ON photos 
USING GIN(to_tsvector('english', title || ' ' || description || ' ' || 
  COALESCE((SELECT string_agg(name, ' ') FROM tags 
    JOIN photo_tags ON tags.id = photo_tags.tag_id 
    WHERE photo_tags.photo_id = photos.id), '')));
```

#### Performance Optimization
**Decision:** Composite indexes for common query patterns  
**Implementation:** Strategic index placement based on actual usage patterns

```sql
-- Common query optimization
CREATE INDEX photos_project_date_idx ON photos (project_id, created_at DESC);
CREATE INDEX photos_tags_lookup_idx ON photo_tags (photo_id, tag_id);
```

### Authentication & Security Decisions

#### Authentication Provider
**Decision:** Supabase Auth with email/password and OAuth providers  
**Rationale:** Integrated with database, supports enterprise SSO, handles security best practices

#### Security Model
- **JWT tokens** for stateless authentication
- **RLS policies** for data access control
- **API rate limiting** to prevent abuse
- **Input validation** at all API boundaries
- **Audit logging** for compliance requirements

### Frontend Architecture Decisions

#### Component Strategy
**Decision:** shadcn/ui as primary component library  
**Rationale:** Provides consistent design system with full customization control

#### State Management
**Decision:** Zustand for client state, TanStack Query for server state  
**Alternative Considered:** Redux, SWR  
**Rationale:** Lightweight, minimal boilerplate, excellent TypeScript support

#### Mobile Strategy
**Decision:** Responsive PWA rather than native mobile app  
**Rationale:** Faster development, single codebase, excellent mobile performance with modern web APIs

### AI Processing Decisions

#### Processing Location
**Decision:** Server-side AI processing  
**Alternative Considered:** Client-side processing  
**Rationale:** Consistent performance, better security, centralized model management

#### Caching Strategy
**Decision:** Aggressive caching of AI results with content-based cache keys  
**Implementation:** Redis-compatible caching through Vercel KV

```typescript
// AI result caching strategy
const cacheKey = `ai_result_${sha256(imageBuffer)}_${modelVersion}`;
const cachedResult = await kv.get(cacheKey);
if (cachedResult) return cachedResult;
```

#### Error Handling
**Decision:** Graceful degradation with manual fallback options  
**Implementation:** Allow manual tagging when AI processing fails

## Recent Technical Decisions (2025)

### Enhanced Workflow System Architecture
**Decision Date:** July-August 2025  
**Status:** ✅ Implemented and validated

#### Agent Coordination System
**Decision:** Context-passing architecture with workflow state management  
**Implementation:** JSON-based state file with structured agent communication

```typescript
interface WorkflowContext {
  workflowId: string;
  featureName: string;
  phase: 'planning' | 'implementation' | 'review' | 'deployment';
  agentSequence: AgentExecution[];
  sharedDecisions: TechnicalDecision[];
  qualityGates: QualityGateStatus;
}
```

#### Quality Gate System
**Decision:** Automated quality gates with agent validation  
**Rationale:** Prevent issues from reaching production through systematic validation

#### Command Architecture
**Decision:** Slash command system with specialized agent orchestration  
**Implementation:** 6 core commands (`/prd`, `/feature`, `/review`, `/deploy`, `/refactor`, `/hotfix`) with 16 specialized agents

### Folder Structure Decisions
**Decision Date:** August 2025  
**Status:** ✅ Implemented

#### Flattened Structure Approach
**Decision:** Numbered, flattened folders over nested hierarchy  
**Rationale:** Reduces cognitive load, improves navigation, maintains workflow integration

```
01-claude-comms/  # Communication hub
02-ideas/         # Innovation pipeline  
03-prds/          # Requirements
04-implementation/ # Development execution
05-completion/    # Success documentation
06-workflow/      # Enhanced workflow system
99-archive/       # Historical preservation
```

## Performance Decisions

### Image Optimization
**Decision:** Multi-tier image processing with WebP format  
**Implementation:** Original + compressed + thumbnail versions

```typescript
// Image processing pipeline
const variants = {
  original: { quality: 100, format: 'jpeg' },
  compressed: { quality: 80, format: 'webp', maxWidth: 1920 },
  thumbnail: { quality: 70, format: 'webp', maxWidth: 400 }
};
```

### Caching Strategy
**Decision:** Multi-level caching (CDN + Application + Database)  
- **CDN:** Static assets and images via Vercel Edge Network
- **Application:** API responses and computed results
- **Database:** Query result caching for expensive operations

### Bundle Optimization
**Decision:** Code splitting with Next.js dynamic imports  
**Implementation:** Route-based splitting with component lazy loading

## Security Decisions

### Data Protection
**Decision:** Encryption at rest and in transit with key rotation  
**Implementation:** Supabase handles encryption, application handles secure transmission

### API Security
**Decision:** Rate limiting, input validation, and request logging  
**Implementation:** Vercel Edge Functions with custom middleware

```typescript
// API security middleware
export const withAuth = (handler: ApiHandler) => async (req, res) => {
  const token = await verifyJWT(req.headers.authorization);
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  return handler(req, res, token);
};
```

### Audit Trail
**Decision:** Comprehensive audit logging for all data modifications  
**Implementation:** Automated logging through database triggers and application middleware

## Development Workflow Decisions

### Code Quality Standards
**Decision:** TypeScript strict mode with zero `any` types  
**Enforcement:** ESLint rules and pre-commit hooks

### Testing Strategy
**Decision:** Vitest for unit tests, Playwright for E2E tests  
**Coverage Target:** 80% minimum for new features

### Deployment Strategy
**Decision:** Continuous deployment with automated quality gates  
**Implementation:** Vercel with preview deployments and production promotion

## Decision Review Process

### Regular Architecture Reviews
- **Monthly:** Review recent technical decisions for effectiveness
- **Quarterly:** Assess overall architecture health and evolution needs
- **Annually:** Major technology stack evaluation and planning

### Decision Documentation
- **Decision Record:** Document rationale, alternatives, and consequences
- **Implementation Notes:** Technical details and lessons learned
- **Success Metrics:** Measure effectiveness of technical decisions
- **Retrospective Analysis:** Regular review of decision outcomes

## Future Technical Decisions Pending

### Real-time Features Architecture
**Question:** WebSocket vs Server-Sent Events vs Supabase Realtime  
**Timeline:** Next quarter  
**Considerations:** Scalability, complexity, feature requirements

### Advanced AI Integration
**Question:** Custom model training vs multi-provider strategy  
**Timeline:** Next 6 months  
**Considerations:** Accuracy improvements, cost implications, maintenance complexity

### Microservices Evolution
**Question:** Monolith vs microservices for scaling  
**Timeline:** Next year  
**Considerations:** Team size, deployment complexity, service boundaries

These technical decisions provide the foundation for Minerva's robust, scalable, and maintainable architecture while supporting rapid development through the enhanced workflow system.