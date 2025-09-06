# Human Tasks Plan - Email Service Implementation

**Project**: Enhanced Email Service for Minerva  
**Timeline**: 5 weeks  
**Human Effort**: ~8 hours total across 5 weeks  
**Cost**: $0 (all free tiers)  

## Key Strategic Decisions - August 15, 2025

### ✅ DNS Management: Stay with Vercel DNS
- **Decision**: Continue using Vercel DNS (no migration to Cloudflare DNS)
- **Impact**: Simplified implementation, eliminates migration risk
- **Human Tasks Reduced**: No nameserver migration tasks needed

### ✅ Main Subdomain: your.machinesafety.app
- **Decision**: Use `your.machinesafety.app` instead of `app.machinesafety.app`
- **Reason**: Better user experience and engagement
- **Impact**: Update all subdomain references in tasks

## Overview

This document outlines all tasks that require human intervention during the email service implementation. Most technical implementation will be handled by developers, but these specific tasks require account setup, service configuration, and decision-making that must be done manually.

## Pre-Implementation Setup (Week 0)

### Task H0.1: Gmail Account Creation
**Time Required**: 5 minutes  
**When**: Before Phase 1 starts  
**Priority**: Critical  

**Steps**:
1. Create new Gmail account: `minerva.system@gmail.com` (or similar)
2. Enable 2-factor authentication on the account
3. Create a strong, unique password and store securely
4. Note down the account credentials for team access

**Deliverables**:
- Gmail account credentials (store in password manager)
- 2FA setup completed
- Account ready for email forwarding

**Important Notes**:
- Choose a professional email name that represents the system
- Don't use personal Gmail account for business services
- Consider using a password manager for team access

### Task H0.2: Domain Access Verification
**Time Required**: 5 minutes  
**When**: Before Phase 1 starts  
**Priority**: Critical  

**Steps**:
1. Verify access to Vercel account where `machinesafety.app` is managed
2. Confirm ability to modify DNS settings
3. Document current DNS configuration
4. Identify team members who need access

**Deliverables**:
- Confirmed Vercel account access
- DNS modification permissions verified
- Current DNS configuration documented

## Phase 1: Foundation Setup (Week 1)

### Task H1.1: Cloudflare Account Setup
**Time Required**: 15 minutes  
**When**: Day 3 of Phase 1  
**Priority**: Critical  
**Dependencies**: Gmail account (H0.1)

**Steps**:
1. Go to [cloudflare.com](https://cloudflare.com)
2. Create free account using business email
3. Add domain `machinesafety.app` to Cloudflare
4. Configure DNS strategy:
   - **DECIDED**: Keep Vercel DNS, add records manually via Vercel CLI
   - **REASON**: No migration risk, centralized management with existing setup

**Decision Update - August 15, 2025**:
- **REMOVED**: DNS migration options (decision already made)
- **SIMPLIFIED**: Use Vercel DNS exclusively for all email DNS records

**Deliverables**:
- Cloudflare account created
- Domain added to Cloudflare
- DNS management strategy chosen

### Task H1.2: Email Routing Configuration
**Time Required**: 20 minutes  
**When**: Day 4 of Phase 1  
**Priority**: Critical  
**Dependencies**: Task H1.1, Gmail account setup

**Steps**:
1. In Cloudflare dashboard, navigate to Email → Email Routing
2. Enable Email Routing for `machinesafety.app`
3. Add forwarding rules:
   ```
   contact@machinesafety.app → minerva.system@gmail.com
   support@machinesafety.app → minerva.system@gmail.com
   security@auth.machinesafety.app → minerva.system@gmail.com
   dmarc-reports@machinesafety.app → minerva.system@gmail.com
   admin@your.machinesafety.app → minerva.system@gmail.com (UPDATED subdomain)
   ```
4. Verify each rule by sending test emails
5. Confirm email delivery to Gmail account

**Testing Checklist**:
- [ ] Send test email to `contact@machinesafety.app`
- [ ] Send test email to `support@machinesafety.app`
- [ ] Send test email to `security@auth.machinesafety.app`
- [ ] Verify all emails arrive in Gmail within 5 minutes

**Deliverables**:
- Email routing rules configured
- Test emails successfully forwarded
- Forwarding functionality verified

### Task H1.3: Gmail Organization Setup
**Time Required**: 15 minutes  
**When**: Day 5 of Phase 1  
**Priority**: Medium  
**Dependencies**: Task H1.2

**Steps**:
1. In Gmail, create labels for email organization:
   - "Minerva - Contact"
   - "Minerva - Support"
   - "Minerva - Security" 
   - "Minerva - DMARC"
   - "Minerva - System"

2. Create Gmail filters for auto-labeling:
   ```
   Filter 1: 
   - From contains: contact@machinesafety.app
   - Apply label: "Minerva - Contact"
   
   Filter 2:
   - From contains: support@machinesafety.app
   - Apply label: "Minerva - Support"
   
   Filter 3:
   - From contains: security@auth.machinesafety.app
   - Apply label: "Minerva - Security"
   - Also mark as important: Yes
   
   Filter 4:
   - Subject contains: DMARC
   - Apply label: "Minerva - DMARC"
   ```

3. Set up mobile notifications for security emails
4. Create folder structure for easy email management

**Deliverables**:
- Gmail labels created
- Auto-filtering rules configured
- Notification settings optimized

## Phase 2: Service Setup (Week 2)

### Task H2.1: Resend Account Creation
**Time Required**: 15 minutes  
**When**: Day 1 of Phase 2  
**Priority**: Critical  
**Dependencies**: Cloudflare account access

**Steps**:
1. Go to [resend.com](https://resend.com)
2. Create account using business email (same as Cloudflare)
3. Navigate to Domains section
4. Add domain: `machinesafety.app`
5. Add subdomain: `auth.machinesafety.app`
6. Copy DNS verification records provided by Resend

**Domain Verification Process**:
1. Resend will provide DNS records (DKIM, TXT verification)
2. Add these records to Cloudflare DNS
3. Wait for verification (usually 5-15 minutes)
4. Confirm both domains show "Verified" status in Resend

**Deliverables**:
- Resend account created
- Both domains added and verified
- DNS records properly configured

### Task H2.2: API Key Generation & Management
**Time Required**: 10 minutes  
**When**: Day 1 of Phase 2  
**Priority**: Critical  
**Dependencies**: Task H2.1

**Steps**:
1. In Resend dashboard, navigate to API Keys
2. Create new API key with appropriate permissions:
   - Name: "Minerva Production"
   - Permissions: Send emails, View analytics
3. Copy API key immediately (won't be shown again)
4. Store API key securely in password manager
5. Share with development team for environment setup

**Security Notes**:
- Never commit API keys to version control
- Use environment variables for API key storage
- Consider separate API keys for development/production

**Deliverables**:
- Production API key generated
- API key securely stored and shared with dev team
- Permissions properly configured

### Task H2.3: DNS Records Update
**Time Required**: 20 minutes  
**When**: Day 2 of Phase 2  
**Priority**: Critical  
**Dependencies**: Task H2.1, Cloudflare account

**Steps** (UPDATED for Vercel DNS):
1. In Vercel DNS management, add records provided by Resend using CLI:
   ```bash
   # DKIM for main domain
   vercel dns add machinesafety.app resend._domainkey TXT "[DKIM-key-from-resend]"
   
   # DKIM for auth subdomain  
   vercel dns add machinesafety.app resend._domainkey.auth TXT "[DKIM-key-from-resend]"
   
   # Updated SPF record
   vercel dns add machinesafety.app @ TXT "v=spf1 include:_spf.mx.cloudflare.net include:spf.resend.com ~all"
   vercel dns add machinesafety.app auth TXT "v=spf1 include:spf.resend.com ~all"
   ```

2. Add enhanced DMARC records:
   ```bash
   vercel dns add machinesafety.app _dmarc TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@machinesafety.app"
   vercel dns add machinesafety.app _dmarc.auth TXT "v=DMARC1; p=reject; rua=mailto:auth-dmarc@machinesafety.app"
   ```

3. Verify DNS propagation using tools like DNS Checker
4. Confirm domain verification in Resend dashboard

**DNS Verification Checklist**:
- [ ] DKIM records added for both domains
- [ ] SPF records updated for both domains
- [ ] DMARC records configured
- [ ] DNS propagation verified globally
- [ ] Resend shows domains as "Verified"

**Deliverables**:
- All DNS records properly configured
- Domain verification completed in Resend
- DNS propagation confirmed

## Phase 3: Integration Support (Week 3)

### Task H3.1: Authentication Service Configuration
**Time Required**: 10 minutes  
**When**: Day 2 of Phase 3  
**Priority**: Medium  
**Dependencies**: Resend setup complete

**Steps**:
1. Access Supabase project dashboard
2. Navigate to Authentication → Email Templates
3. Update email templates to use new sender addresses:
   - Confirmation emails: `verify@auth.machinesafety.app`
   - Password reset: `noreply@auth.machinesafety.app`
   - Magic link emails: `noreply@auth.machinesafety.app`

4. If using custom SMTP in Supabase:
   - Configure SMTP settings to use Resend
   - Test email delivery through Supabase

**Configuration Notes**:
- Maintain existing template content, only update sender addresses
- Test authentication flows after changes
- Keep backup of original settings

**Deliverables**:
- Supabase email templates updated
- Authentication emails using new sender addresses
- Email delivery tested and verified

### Task H3.2: Email Testing & Validation
**Time Required**: 30 minutes  
**When**: Day 5 of Phase 3  
**Priority**: Critical  
**Dependencies**: All Phase 3 development complete

**Testing Scenarios**:
1. **Authentication Flow Testing**:
   ```
   Test Cases:
   - User signup with email verification
   - Password reset request
   - 2FA code delivery
   - Security alert generation (simulated)
   ```

2. **Contact & Support Testing**:
   ```
   Test Cases:
   - Contact form submission
   - Support ticket creation
   - Auto-response emails
   - Confirmation email delivery
   ```

3. **Email Delivery Verification**:
   ```
   Metrics to Check:
   - Delivery time (<5 minutes for all emails)
   - Gmail spam folder check
   - Email formatting and branding
   - Mobile email client compatibility
   ```

**Testing Checklist**:
- [ ] All authentication emails deliver successfully
- [ ] Contact form emails reach correct inbox
- [ ] Support emails properly labeled in Gmail
- [ ] Security emails marked as important
- [ ] No emails in spam folder
- [ ] Email formatting looks professional on mobile

**Deliverables**:
- Comprehensive testing completed
- All email flows validated
- Issues documented and resolved

## Phase 4: Advanced Setup (Week 4)

### Task H4.1: Redis Service Setup
**Time Required**: 15 minutes  
**When**: Day 1 of Phase 4  
**Priority**: Medium  
**Dependencies**: Development team request

**Steps**:
1. Go to [upstash.com](https://upstash.com) (recommended free Redis service)
2. Create account using business email
3. Create new Redis database:
   - Name: "minerva-email-queue"
   - Region: Choose closest to your Vercel deployment region
   - Plan: Free tier (10,000 commands/day)

4. Copy connection string/credentials
5. Share credentials with development team for environment setup

**Alternative Options**:
- Redis Cloud (free tier)
- AWS ElastiCache (if already using AWS)
- Railway Redis (simple setup)

**Deliverables**:
- Redis service account created
- Database provisioned and configured
- Connection credentials shared with dev team

### Task H4.2: Monitoring & Alerting Setup
**Time Required**: 20 minutes  
**When**: Day 4 of Phase 4  
**Priority**: Medium  
**Dependencies**: Email service operational

**Steps**:
1. Set up email delivery monitoring:
   - Monitor Resend dashboard daily
   - Check Gmail for DMARC reports weekly
   - Review bounce rates monthly

2. Create monitoring checklist:
   ```
   Daily Checks:
   - Resend delivery rates (target: >99%)
   - Email queue depth (if applicable)
   - Any delivery failures or bounces
   
   Weekly Checks:
   - DMARC reports in Gmail
   - DNS health check
   - Security email patterns
   
   Monthly Checks:
   - Overall email performance
   - Cost optimization review
   - User feedback analysis
   ```

3. Set up alerts for critical issues:
   - High bounce rates (>5%)
   - Service outages
   - Security alerts

**Deliverables**:
- Monitoring procedures established
- Alert thresholds configured
- Regular check schedule created

## Phase 5: Production Launch (Week 5)

### Task H5.1: Production Environment Verification
**Time Required**: 15 minutes  
**When**: Day 1 of Phase 5  
**Priority**: Critical  
**Dependencies**: Development deployment complete

**Steps**:
1. Verify production environment variables in Vercel:
   ```
   Required Variables:
   - RESEND_API_KEY (production key)
   - FROM_EMAIL_AUTH
   - FROM_EMAIL_SECURITY
   - FROM_EMAIL_GENERAL
   - ADMIN_EMAIL
   - SUPPORT_EMAIL
   ```

2. Test email delivery from production domain:
   - Send test emails from production app
   - Verify delivery to Gmail
   - Check email formatting and branding

3. Confirm DNS configuration is live:
   - Use DNS lookup tools
   - Verify MX, SPF, DKIM, DMARC records
   - Check global DNS propagation

**Production Readiness Checklist**:
- [ ] All environment variables set in production
- [ ] DNS records active and propagated
- [ ] Email delivery working from production
- [ ] Monitoring systems active
- [ ] Backup procedures documented

**Deliverables**:
- Production environment verified
- Email delivery confirmed operational
- All systems go for launch

### Task H5.2: Go-Live Monitoring
**Time Required**: 1 hour on launch day + 15 min/day for first week  
**When**: Launch day and first week  
**Priority**: Critical  
**Dependencies**: Task H5.1

**Launch Day Activities**:
1. Monitor email delivery rates in real-time
2. Watch for any delivery failures or bounces
3. Check user feedback for email-related issues
4. Verify contact forms are working properly

**First Week Monitoring**:
```
Daily Checks:
- Resend dashboard for delivery metrics
- Gmail for any delivery issues
- User reports of email problems
- System logs for email errors

Weekly Review:
- Overall delivery performance
- User experience feedback
- Any optimization opportunities
- Documentation updates needed
```

**Issue Response Plan**:
1. **Immediate Issues**: Use backup Gmail SMTP if needed
2. **Delivery Problems**: Check DNS, contact Resend support
3. **User Complaints**: Investigate specific cases, update filters
4. **Performance Issues**: Review queue processing, optimize as needed

**Deliverables**:
- Successful production launch
- Issue-free first week operation
- Performance metrics documented
- Any necessary optimizations implemented

## Account Management & Security

### Account Access Management
**Accounts Created**:
1. Gmail account (`minerva.system@gmail.com`)
2. Cloudflare account (for email routing)
3. Resend account (for transactional emails)
4. Upstash account (for Redis/queuing)

**Security Best Practices**:
- Use unique, strong passwords for all accounts
- Enable 2FA on all accounts
- Store credentials in team password manager
- Document account recovery procedures
- Regular security reviews (quarterly)

### Credential Sharing
**Team Access Requirements**:
- Gmail: Primary admin + 1 backup person
- Cloudflare: DNS management team
- Resend: Development team + DevOps
- Upstash: Development team only

**Access Documentation**:
- Maintain up-to-date account access list
- Document service-specific permissions
- Regular access review and cleanup
- Offboarding procedures for team changes

## Budget & Cost Management

### Free Tier Limits
```
Service Limits:
- Cloudflare Email Routing: Unlimited forwarding (free)
- Resend: 3,000 emails/month, 100/day (free)
- Upstash Redis: 10,000 commands/day (free)
- Gmail: Unlimited storage up to 15GB (free)

Total Monthly Cost: $0
```

### Scaling Triggers
**When to Upgrade**:
- Resend: >2,500 emails/month → Upgrade to Pro ($20/month)
- Redis: >8,000 commands/day → Upgrade to paid tier ($5/month)
- Gmail: >90% of 15GB storage → Consider Google Workspace

### Cost Monitoring
- Monthly usage review in each service dashboard
- Quarterly cost projection based on growth
- Annual budget planning for email services

## Success Metrics & KPIs

### Technical Metrics (Track Daily)
- Email delivery rate: Target >99% for auth emails
- Email bounce rate: Target <2%
- Average delivery time: Target <30 seconds
- Queue processing time: Target <30 seconds

### Business Metrics (Track Weekly)
- User signup completion rate
- Support response time
- Customer satisfaction scores
- Professional brand perception

### Operational Metrics (Track Monthly)
- Service uptime and reliability
- Cost per email sent
- Team efficiency in email management
- Security incident count (target: 0)

This comprehensive human tasks plan ensures that all manual configuration and account management activities are clearly documented, properly sequenced, and include appropriate verification steps. The total human effort required is approximately 8 hours spread across 5 weeks, making it very manageable alongside other work activities.