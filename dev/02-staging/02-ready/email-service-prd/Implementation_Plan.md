# Email Service Implementation Plan

**Project**: Enhanced Email Service for Minerva Machine Safety Photo Organizer  
**PRD Reference**: Enhanced_Email_Service_PRD.md  
**Timeline**: 5 weeks total (2 weeks minimum viable)  
**Start Date**: TBD  

## Key Decisions - August 15, 2025

### ✅ DNS Strategy: Stay with Vercel DNS
- **Decision**: Continue using Vercel DNS (no migration to Cloudflare)
- **Reason**: Centralized management, zero migration risk, automatic SSL
- **Impact**: Simplified implementation, reduced complexity

### ✅ Subdomain Change: your.machinesafety.app
- **Decision**: Use `your.machinesafety.app` instead of `app.machinesafety.app`
- **Reason**: Better user experience - "your" implies personal ownership
- **Impact**: Update all references in implementation

## Overview

This implementation plan breaks down the email service PRD into actionable development tasks, organized by phase and sprint. Each task includes technical specifications, acceptance criteria, and integration points with the existing Minerva codebase.

## Phase 1: Foundation Infrastructure (Week 1)

### Sprint 1.1: Subdomain & DNS Setup (Days 1-2)

#### Task 1.1.1: Subdomain Configuration
**Owner**: DevOps/Developer  
**Effort**: 2 hours  
**Dependencies**: Access to Vercel DNS settings

**Implementation Details**:
- Configure `auth.machinesafety.app` subdomain in Vercel
- Configure `your.machinesafety.app` subdomain (UPDATED from app.machinesafety.app)
- Document DNS configuration for future reference

**Subdomain Decision Update - August 15, 2025**:
- **Changed from**: `app.machinesafety.app` 
- **Changed to**: `your.machinesafety.app`
- **Reason**: Better user experience - "your" implies personal ownership and engagement

**Acceptance Criteria**:
- [ ] `auth.machinesafety.app` resolves correctly
- [ ] `your.machinesafety.app` resolves correctly (UPDATED)
- [ ] DNS propagation verified globally (use tools like DNS Checker)

**Technical Integration**:
```typescript
// Update next.config.js if needed for subdomain handling
const nextConfig = {
  async rewrites() {
    return [
      {
        source: '/auth/:path*',
        destination: 'https://auth.machinesafety.app/:path*'
      }
    ]
  }
}
```

#### Task 1.1.2: DNS Strategy Documentation
**Owner**: Developer  
**Effort**: 1 hour  
**Dependencies**: Task 1.1.1

**Implementation Details**:
- Document current DNS configuration
- Plan DNS record additions for email services
- Create DNS change management process

**Deliverable**: `dns-configuration.md` in project docs

### Sprint 1.2: Cloudflare Email Routing (Days 3-5)

#### Task 1.2.1: Cloudflare Account Setup
**Owner**: Human (Account Management)  
**Effort**: 30 minutes  
**Dependencies**: Access to domain management

**Implementation Steps**:
1. Create Cloudflare account
2. Add `machinesafety.app` domain
3. Choose DNS management strategy (full migration vs. record addition)

#### Task 1.2.2: Email Routing Configuration
**Owner**: Human + Developer  
**Effort**: 2 hours  
**Dependencies**: Task 1.2.1, Gmail account setup

**Implementation Details**:
- Enable Email Routing in Cloudflare
- Configure forwarding rules:
  ```
  contact@machinesafety.app → minerva.system@gmail.com
  support@machinesafety.app → minerva.system@gmail.com
  security@auth.machinesafety.app → minerva.system@gmail.com
  dmarc-reports@machinesafety.app → minerva.system@gmail.com
  ```

**DNS Records Required**:
```dns
MX  @  route.mail.cloudflare.net  10
TXT @  "v=spf1 include:_spf.mx.cloudflare.net ~all"
```

**Acceptance Criteria**:
- [ ] Email forwarding works for all configured addresses
- [ ] Test emails delivered to Gmail within 5 minutes
- [ ] DNS records properly configured and propagated

#### Task 1.2.3: Gmail Organization Setup
**Owner**: Human  
**Effort**: 30 minutes  
**Dependencies**: Task 1.2.2

**Implementation Details**:
- Create Gmail filters for auto-labeling
- Set up folder structure for email organization
- Configure notifications for critical emails

**Gmail Filter Examples**:
```
Filter 1: from:(contact@machinesafety.app) → Label: "Contact"
Filter 2: from:(support@machinesafety.app) → Label: "Support"
Filter 3: from:(security@auth.machinesafety.app) → Label: "Security" + Star
Filter 4: subject:(DMARC) → Label: "DMARC Reports"
```

## Phase 2: Transactional Email Service (Week 2)

### Sprint 2.1: Resend Integration (Days 1-3)

#### Task 2.1.1: Resend Account & Domain Setup
**Owner**: Human  
**Effort**: 1 hour  
**Dependencies**: Cloudflare account access

**Implementation Steps**:
1. Create Resend account
2. Add `machinesafety.app` domain
3. Add `auth.machinesafety.app` subdomain
4. Generate API keys

**Domain Verification Requirements**:
- DNS records from Resend dashboard
- DKIM keys for both domains
- Domain verification completion

#### Task 2.1.2: Enhanced DNS Configuration
**Owner**: Developer + Human  
**Effort**: 2 hours  
**Dependencies**: Task 2.1.1

**DNS Records to Add**:
```dns
# Enhanced SPF (combined services)
TXT @     "v=spf1 include:_spf.mx.cloudflare.net include:spf.resend.com ~all"
TXT auth  "v=spf1 include:spf.resend.com ~all"

# DKIM for both domains
TXT resend._domainkey       "[DKIM-key-from-resend-dashboard]"
TXT resend._domainkey.auth  "[DKIM-key-from-resend-dashboard]"

# Enhanced DMARC with reporting
TXT _dmarc      "v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@machinesafety.app"
TXT _dmarc.auth "v=DMARC1; p=reject; rua=mailto:auth-dmarc@machinesafety.app"
```

#### Task 2.1.3: Environment Variables Setup
**Owner**: Developer  
**Effort**: 30 minutes  
**Dependencies**: Task 2.1.1

**Environment Configuration**:
```bash
# Add to .env.local and Vercel environment
RESEND_API_KEY=re_your_api_key_here

# Email addresses by type
FROM_EMAIL_AUTH=noreply@auth.machinesafety.app
FROM_EMAIL_SECURITY=security@auth.machinesafety.app
FROM_EMAIL_VERIFY=verify@auth.machinesafety.app
FROM_EMAIL_GENERAL=noreply@machinesafety.app
FROM_EMAIL_SYSTEM=system@machinesafety.app

# Contact emails
ADMIN_EMAIL=minerva.system@gmail.com
SUPPORT_EMAIL=minerva.system@gmail.com
SECURITY_EMAIL=minerva.system@gmail.com
```

### Sprint 2.2: Email Service Refactoring (Days 4-5)

#### Task 2.2.1: Email Service Enhancement
**Owner**: Developer  
**Effort**: 6 hours  
**Dependencies**: Existing `lib/email-service.ts`

**Implementation Details**:
- Extend existing email service to support multiple domains
- Add email type enumeration
- Implement template selection logic
- Replace SMTP with Resend API

**Code Structure**:
```typescript
// lib/email-service.ts enhancements
export enum EmailType {
  AUTH = 'auth',
  SECURITY = 'security',
  VERIFY = 'verify',
  GENERAL = 'general',
  SYSTEM = 'system'
}

export interface EmailConfig {
  from: string;
  domain: string;
  rateLimit: { perHour: number; perDay: number };
}

const emailConfig: Record<EmailType, EmailConfig> = {
  [EmailType.AUTH]: {
    from: process.env.FROM_EMAIL_AUTH!,
    domain: 'auth.machinesafety.app',
    rateLimit: { perHour: 10, perDay: 50 }
  },
  // ... other types
}
```

**Integration Points**:
- Update existing debug endpoint: `app/api/debug/email/route.ts`
- Maintain backward compatibility with current email service usage
- Add TypeScript strict mode compliance

**Acceptance Criteria**:
- [ ] Existing email functionality preserved
- [ ] New email types properly configured
- [ ] Debug endpoint updated and functional
- [ ] TypeScript compilation without errors

#### Task 2.2.2: Template System Implementation
**Owner**: Developer  
**Effort**: 4 hours  
**Dependencies**: Task 2.2.1

**Implementation Details**:
- Create email template system with different styles
- Implement template selection based on email type
- Add branded templates for different use cases

**Template Categories**:
```typescript
// Email templates by type
const templates = {
  auth: {
    style: 'minimal-security',
    colors: { primary: '#dc2626', bg: '#ffffff' },
    subject: '[Minerva Auth] {{action}}'
  },
  general: {
    style: 'branded',
    colors: { primary: '#2563eb', bg: '#f8fafc' },
    subject: 'Minerva - {{action}}'
  },
  security: {
    style: 'urgent-security',
    colors: { primary: '#dc2626', bg: '#fef2f2' },
    subject: '[SECURITY ALERT] {{action}}'
  }
}
```

## Phase 3: Authentication Integration (Week 3)

### Sprint 3.1: Supabase Auth Integration (Days 1-3)

#### Task 3.1.1: Authentication Email Updates
**Owner**: Developer  
**Effort**: 4 hours  
**Dependencies**: Phase 2 completion, Supabase configuration

**Implementation Details**:
- Update Supabase Auth email templates
- Configure custom SMTP settings if needed
- Update authentication flow to use new email service

**Supabase Configuration Updates**:
```sql
-- Update auth email templates in Supabase dashboard
-- Configure custom SMTP if using Resend directly
```

**Code Integration**:
```typescript
// Update auth API routes
// app/api/auth/[...nextauth]/route.ts or relevant auth endpoints
await emailService.sendEmail({
  type: EmailType.AUTH,
  to: user.email,
  template: '2fa-code',
  data: { code, expiresAt }
})
```

#### Task 3.1.2: Security Event Notifications
**Owner**: Developer  
**Effort**: 3 hours  
**Dependencies**: Task 3.1.1

**Implementation Details**:
- Add security event tracking
- Implement automated security alerts
- Create security notification templates

**Security Events to Track**:
- Login from new device/location
- Multiple failed login attempts
- Password changes
- Account security setting changes

### Sprint 3.2: Contact & Support Integration (Days 4-5)

#### Task 3.2.1: Contact Form Updates
**Owner**: Developer  
**Effort**: 2 hours  
**Dependencies**: Phase 2 completion

**Implementation Details**:
- Update existing contact forms to use new email addresses
- Implement proper routing for support vs. general inquiries
- Add confirmation emails for contact form submissions

#### Task 3.2.2: Support Ticket System
**Owner**: Developer  
**Effort**: 4 hours  
**Dependencies**: Task 3.2.1

**Implementation Details**:
- Create basic support ticket routing
- Implement auto-responses for support emails
- Add ticket numbering and tracking

## Phase 4: Advanced Features (Week 4)

### Sprint 4.1: Email Queue & Reliability (Days 1-3)

#### Task 4.1.1: Redis Setup
**Owner**: Developer + Human  
**Effort**: 2 hours  
**Dependencies**: Redis service account (Upstash recommended)

**Implementation Steps**:
1. Create Upstash Redis account (free tier)
2. Configure Redis connection in application
3. Add Redis URL to environment variables

**Environment Addition**:
```bash
REDIS_URL=redis://username:password@hostname:port
EMAIL_QUEUE_ENABLED=true
```

#### Task 4.1.2: Email Queue Implementation
**Owner**: Developer  
**Effort**: 6 hours  
**Dependencies**: Task 4.1.1

**Implementation Details**:
- Create email queue service using Redis
- Implement job processing with retry logic
- Add queue monitoring and health checks

**Code Structure**:
```typescript
// lib/email-queue.ts
export class EmailQueue {
  async addToQueue(email: EmailJob): Promise<string>
  async processQueue(): Promise<void>
  async retryFailedEmails(): Promise<void>
  async getQueueStats(): Promise<QueueStats>
}
```

### Sprint 4.2: Rate Limiting & Security (Days 4-5)

#### Task 4.2.1: Rate Limiting Implementation
**Owner**: Developer  
**Effort**: 4 hours  
**Dependencies**: Redis setup

**Implementation Details**:
- Implement per-user, per-type rate limiting
- Add suspicious pattern detection
- Create rate limit violation alerts

#### Task 4.2.2: Enhanced Monitoring
**Owner**: Developer  
**Effort**: 4 hours  
**Dependencies**: Task 4.2.1

**Implementation Details**:
- Add email delivery monitoring
- Implement health checks for email services
- Create monitoring dashboard endpoints

## Phase 5: Production Deployment (Week 5)

### Sprint 5.1: Production Configuration (Days 1-2)

#### Task 5.1.1: Environment Setup
**Owner**: Developer + Human  
**Effort**: 2 hours  
**Dependencies**: Production Vercel access

**Implementation Steps**:
1. Update production environment variables in Vercel
2. Verify DNS records in production environment
3. Test email delivery from production domain

#### Task 5.1.2: Load Testing
**Owner**: Developer  
**Effort**: 4 hours  
**Dependencies**: Task 5.1.1

**Implementation Details**:
- Create email load testing scripts
- Test rate limiting under load
- Verify queue processing performance

### Sprint 5.2: Go-Live & Monitoring (Days 3-5)

#### Task 5.2.1: Production Deployment
**Owner**: Developer  
**Effort**: 2 hours  
**Dependencies**: All previous phases

**Implementation Steps**:
1. Deploy to production with feature flags
2. Gradually enable email features
3. Monitor delivery rates and performance

#### Task 5.2.2: Post-Launch Monitoring
**Owner**: Developer + Human  
**Effort**: Ongoing  
**Dependencies**: Task 5.2.1

**Monitoring Tasks**:
- Daily delivery rate monitoring
- Weekly DMARC report review
- Monthly performance optimization review

## Testing Strategy

### Unit Tests
- Email service functionality
- Template rendering
- Rate limiting logic
- Queue processing

### Integration Tests
- Email delivery end-to-end
- Authentication flow integration
- Contact form submission
- Support ticket creation

### E2E Tests
- Complete user signup flow with email verification
- Password reset flow
- Security alert generation
- Contact form submission with confirmation

## Risk Mitigation

### Technical Risks
1. **DNS Propagation Delays**: Use DNS monitoring tools, plan for 24-48h propagation
2. **Email Delivery Issues**: Implement multi-provider failover
3. **Rate Limiting False Positives**: Careful testing and gradual rollout
4. **Queue Processing Failures**: Implement dead letter queue and monitoring

### Operational Risks
1. **Account Access Issues**: Document all account credentials securely
2. **Service Dependencies**: Monitor third-party service status pages
3. **Migration Complexity**: Phased rollout with rollback plan

## Success Metrics Tracking

### Technical KPIs
- Email delivery rate: >99% for auth emails, >95% for general
- Queue processing time: <30 seconds average
- Bounce rate: <2% across all email types
- DNS uptime: 100% monitoring

### Business KPIs
- User signup completion rate improvement
- Support response time reduction
- Security incident response time
- Customer satisfaction scores

## Documentation Requirements

### Developer Documentation
- Email service API documentation
- Configuration management guide
- Troubleshooting playbook
- Integration examples

### Operational Documentation
- Account management procedures
- Monitoring and alerting setup
- Incident response procedures
- Maintenance schedules

## Rollback Plan

### Phase-by-Phase Rollback
1. **Phase 1**: Disable Cloudflare routing, revert DNS
2. **Phase 2**: Switch back to SMTP configuration
3. **Phase 3**: Revert authentication email settings
4. **Phase 4**: Disable queue processing
5. **Phase 5**: Rollback production deployment

### Emergency Procedures
- Immediate failover to backup email provider
- Manual email sending capabilities
- User communication plan for service disruptions

This implementation plan provides a comprehensive roadmap for executing the email service PRD with clear tasks, timelines, and success criteria. Each task includes specific technical details and integration points with the existing Minerva codebase.