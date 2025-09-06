# Email Setup Plan for machinesafety.app

**Domain**: `machinesafety.app` (purchased through Vercel)  
**Goal**: Set up professional email with contact@machinesafety.app for receiving, noreply@machinesafety.app for sending, and reliable 2FA delivery.

## Current State Analysis

- ✅ Domain: `machinesafety.app` registered through Vercel
- ✅ Resend debug tools implemented (`app/api/debug/email/route.ts`)
- ✅ Email service infrastructure ready (`lib/email-service.ts`)
- ❌ No incoming email configured
- ❌ No outgoing email from domain configured
- ❌ SMTP currently using placeholder values

## Recommended Email Solution

**Architecture**:
1. **Cloudflare Email Routing**: Free email forwarding (contact@machinesafety.app → your Gmail)
2. **Resend**: Send transactional emails from your domain (already partially set up)
3. **Dedicated Gmail**: For 2FA (free, reliable)

**Benefits**:
- ✅ Professional contact email at no cost
- ✅ Ability to send emails from your domain  
- ✅ Reliable 2FA delivery
- ✅ Easy migration to paid Gmail later
- ✅ No vendor lock-in

## Implementation Plan

### Phase 1: Cloudflare Email Routing (Incoming)

**Objective**: Set up free email forwarding for contact@machinesafety.app

**Steps**:
1. **Create Cloudflare account** at cloudflare.com
2. **Add machinesafety.app domain** to Cloudflare
   - Choose free plan
   - Update nameservers at Vercel (or keep Vercel DNS and add records manually)
3. **Configure Email Routing**:
   - Navigate to Email → Email Routing
   - Enable Email Routing for machinesafety.app
   - Add route: `contact@machinesafety.app` → forward to your personal Gmail
4. **Add required DNS records**:
   - MX records for email routing
   - TXT records for verification
5. **Test incoming email**: Send test email to contact@machinesafety.app

**DNS Records Needed**:
```
Type: MX
Name: machinesafety.app
Value: route.mail.cloudflare.net
Priority: 10

Type: TXT  
Name: machinesafety.app
Value: v=spf1 include:_spf.mx.cloudflare.net ~all
```

### Phase 2: Resend Configuration (Outgoing)

**Objective**: Configure Resend to send emails from noreply@machinesafety.app

**Steps**:
1. **Create Resend account** at resend.com
2. **Add and verify domain**:
   - Add machinesafety.app domain in Resend dashboard
   - Get verification DNS records
3. **Add DNS records for Resend**:
   - SPF record (if not conflicting with Cloudflare)
   - DKIM records
   - DMARC record
4. **Generate API key** in Resend dashboard
5. **Add environment variables**:
   ```bash
   RESEND_API_KEY=re_your_api_key_here
   FROM_EMAIL=noreply@machinesafety.app
   ```
6. **Test email sending** via existing debug API at `/api/debug/email?action=test-send&email=your@email.com`

**DNS Records for Resend**:
```
Type: TXT
Name: machinesafety.app  
Value: v=spf1 include:_spf.mx.cloudflare.net include:spf.resend.com ~all

Type: TXT
Name: resend._domainkey.machinesafety.app
Value: [DKIM key from Resend dashboard]

Type: TXT
Name: _dmarc.machinesafety.app
Value: v=DMARC1; p=quarantine; rua=mailto:dmarc@machinesafety.app
```

### Phase 3: Application Integration

**Objective**: Update Minerva app to use new email configuration

**Files to Update**:
1. **Environment Variables** (`.env.local`):
   ```bash
   # Update these existing values
   RESEND_API_KEY=re_your_actual_api_key
   FROM_EMAIL=noreply@machinesafety.app
   NEXT_PUBLIC_APP_URL=https://machinesafety.app  # for production
   
   # Add admin contact email
   ADMIN_EMAIL=contact@machinesafety.app
   ```

2. **Email Service** (`lib/email-service.ts`):
   - Replace SMTP configuration with Resend
   - Update FROM email address
   - Test invitation and password reset emails

3. **Contact Forms**: Update any contact forms to reference new email

**Testing Steps**:
1. Test contact form submissions
2. Test user invitation emails
3. Test password reset emails
4. Verify email delivery and formatting

### Phase 4: 2FA Email Setup

**Objective**: Set up reliable 2FA email delivery

**Steps**:
1. **Create dedicated Gmail account** for 2FA:
   - Something like `minerva-auth@gmail.com`
   - Enable 2FA on this account for security
2. **Configure 2FA systems** to use dedicated Gmail:
   - Supabase Auth (if using email 2FA)
   - Any other services requiring 2FA
3. **Test 2FA email delivery**

### Phase 5: Production Configuration

**Objective**: Prepare for production deployment

**Steps**:
1. **Update production environment** variables in Vercel
2. **Test end-to-end email flow** in production
3. **Monitor email delivery** using Resend dashboard
4. **Set up email alerts** for delivery failures

## DNS Configuration Summary

**For Cloudflare Email Routing + Resend**:
```dns
# MX Record for incoming email (Cloudflare)
MX  @  route.mail.cloudflare.net  10

# SPF Record (combined for both services)
TXT @  "v=spf1 include:_spf.mx.cloudflare.net include:spf.resend.com ~all"

# DKIM for Resend
TXT resend._domainkey  "[DKIM-key-from-resend-dashboard]"

# DMARC policy
TXT _dmarc  "v=DMARC1; p=quarantine; rua=mailto:dmarc@machinesafety.app"
```

## Cost Breakdown

- **Cloudflare Email Routing**: Free
- **Resend**: Free tier (3,000 emails/month)
- **Gmail for 2FA**: Free
- **Total Monthly Cost**: $0

**Free Tier Limits**:
- Cloudflare: Unlimited forwarding
- Resend: 3,000 emails/month, 100/day
- Perfect for startup/development phase

## Monitoring & Maintenance

**Regular Tasks**:
1. Monitor Resend delivery rates in dashboard
2. Check email forwarding is working (send test emails monthly)
3. Review bounce/spam reports
4. Update DNS records if needed

**Upgrade Path**:
- When ready to pay: Upgrade to Google Workspace for full Gmail integration
- Resend paid plans start at $20/month for higher limits
- Easy migration path maintains all existing functionality

## Security Considerations

1. **SPF/DKIM/DMARC**: Properly configured to prevent spoofing
2. **API Keys**: Store securely in environment variables
3. **Rate Limiting**: Resend provides built-in rate limiting
4. **Monitoring**: Set up alerts for unusual email patterns

## Fallback Options

**If Cloudflare Email Routing doesn't work**:
- **Zoho Mail**: Free tier with custom domain
- **ImprovMX**: Free email forwarding service
- **ForwardEmail**: Open source email forwarding

**If Resend doesn't work**:
- **Postmark**: Similar API, good deliverability
- **SendGrid**: Free tier available
- **Amazon SES**: Very cheap, requires more setup

## Next Steps

1. Start with Phase 1 (Cloudflare Email Routing)
2. Test incoming email before proceeding
3. Move to Phase 2 (Resend setup)
4. Test outgoing email functionality
5. Complete integration and testing

**Timeline**: Can be completed in 1-2 hours with proper preparation.