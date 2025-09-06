# Current DNS Configuration - machinesafety.app

**Generated**: August 15, 2025  
**Domain**: machinesafety.app  
**Registrar**: Vercel  
**Nameservers**: Vercel DNS (ns1.vercel-dns.com, ns2.vercel-dns.com)  

## Current Configuration Analysis

### Domain Overview
```
Domain: machinesafety.app
Registrar: Vercel
Expiration: July 17, 2026 (336 days remaining)
Nameservers: Vercel-managed
Age: 29 days (created July 17, 2025)
```

### Current DNS Records
```dns
# Current Vercel DNS Records
*       ALIAS    cname.vercel-dns-017.com.           (wildcard)
@       ALIAS    903e3cc9eab29471.vercel-dns-017.com (apex)
@       CAA      0 issue "letsencrypt.org"           (SSL certificate authority)
```

### Current Project Assignment
- **Primary Project**: `minerva` 
- **Production URL**: https://minerva-toms-projects-69b6f2b8.vercel.app
- **Custom Domain**: Currently **NOT** assigned to machinesafety.app
- **Current Aliases**:
  - minerva-taupe.vercel.app
  - minerva-tombranch-toms-projects-69b6f2b8.vercel.app
  - minerva-toms-projects-69b6f2b8.vercel.app

## Required Changes for Email Service Implementation

### 1. Domain Assignment (Immediate Need)

**Issue**: The `machinesafety.app` domain is purchased but not assigned to the Minerva project.

**Action Required**:
```bash
# Assign the domain to the minerva project
vercel domains add machinesafety.app --project=minerva
```

**Expected Result**: 
- https://machinesafety.app will serve the Minerva application
- Automatic SSL certificate via Let's Encrypt
- Production deployment accessible via custom domain

### 2. Subdomain Configuration

**Required Subdomains**:
```
your.machinesafety.app      # Main application (UPDATED - better UX than "app")
auth.machinesafety.app      # Authentication subdomain (for email service)
www.machinesafety.app       # Optional www redirect
```

**Subdomain Decision - August 15, 2025**:
- **Changed from**: `app.machinesafety.app`
- **Changed to**: `your.machinesafety.app`
- **Reason**: Much better user experience - "your" implies personal ownership and is more engaging than generic "app"

**Vercel CLI Commands**:
```bash
# Add main subdomain to minerva project (UPDATED)
vercel domains add your.machinesafety.app minerva

# Add auth subdomain (can point to same project or separate)
vercel domains add auth.machinesafety.app minerva

# Optional: Add www redirect
vercel domains add www.machinesafety.app minerva
```

### 3. Email-Related DNS Records (Phase 1)

**Records to Add for Cloudflare Email Routing**:
```dns
# MX Record for email routing
MX  @  route.mail.cloudflare.net  10

# SPF Record for email authentication
TXT @  "v=spf1 include:_spf.mx.cloudflare.net ~all"
```

**Vercel CLI Commands**:
```bash
# Add MX record for email routing
vercel dns add machinesafety.app @ MX "route.mail.cloudflare.net" --priority=10

# Add SPF record
vercel dns add machinesafety.app @ TXT "v=spf1 include:_spf.mx.cloudflare.net ~all"
```

### 4. Enhanced DNS Records (Phase 2 - Resend Integration)

**Additional Records for Resend**:
```dns
# Enhanced SPF (replaces basic SPF)
TXT @     "v=spf1 include:_spf.mx.cloudflare.net include:spf.resend.com ~all"
TXT auth  "v=spf1 include:spf.resend.com ~all"

# DKIM Records (from Resend dashboard)
TXT resend._domainkey       "[DKIM-key-from-resend]"
TXT resend._domainkey.auth  "[DKIM-key-from-resend]"

# DMARC Records
TXT _dmarc      "v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@machinesafety.app"
TXT _dmarc.auth "v=DMARC1; p=reject; rua=mailto:auth-dmarc@machinesafety.app"
```

## DNS Management Strategy - FINAL DECISION

### ✅ DECIDED: Stay with Vercel DNS
**Decision Date**: August 15, 2025

**Key Reasons for Vercel DNS**:
- Centralized management with existing setup
- Automatic SSL for all subdomains
- Simple Vercel CLI management
- No additional service dependencies
- **Zero migration risk** - no nameserver changes needed
- **Already optimally configured** - domain purchased through Vercel

**Implementation Approach**:
- Use Vercel CLI for all DNS changes
- Maintain current nameserver setup
- Add email records manually as needed

### ❌ REJECTED: Migrate to Cloudflare DNS
**Why Not Cloudflare**:
- Requires risky nameserver migration with potential downtime
- Adds unnecessary complexity by splitting services
- Current Vercel setup already meets all requirements
- Additional service management overhead

## Recommended Implementation Approach

### Phase 0: Immediate Domain Setup
```bash
# 1. Assign apex domain to minerva project
vercel domains add machinesafety.app minerva

# 2. Add main subdomain (UPDATED to your.machinesafety.app)
vercel domains add your.machinesafety.app minerva

# 3. Verify domain assignment
vercel domains ls
```

### Phase 1: Basic Email Setup (Vercel DNS)
```bash
# 1. Add MX record for Cloudflare email routing
vercel dns add machinesafety.app @ MX "route.mail.cloudflare.net" --priority=10

# 2. Add basic SPF record
vercel dns add machinesafety.app @ TXT "v=spf1 include:_spf.mx.cloudflare.net ~all"

# 3. Add auth subdomain for future email service
vercel domains add auth.machinesafety.app minerva
```

### Phase 2: Enhanced Email DNS (After Resend Setup)
```bash
# Update SPF record (replace existing)
vercel dns rm <record-id>  # Remove old SPF
vercel dns add machinesafety.app @ TXT "v=spf1 include:_spf.mx.cloudflare.net include:spf.resend.com ~all"

# Add DKIM records (values from Resend dashboard)
vercel dns add machinesafety.app resend._domainkey TXT "[DKIM-key-from-resend]"
vercel dns add machinesafety.app resend._domainkey.auth TXT "[DKIM-key-for-auth-subdomain]"

# Add DMARC records
vercel dns add machinesafety.app _dmarc TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@machinesafety.app"
vercel dns add machinesafety.app _dmarc.auth TXT "v=DMARC1; p=reject; rua=mailto:auth-dmarc@machinesafety.app"
```

## Current Status Summary

### ✅ What's Ready
- Domain purchased and active
- Vercel nameservers configured
- Vercel CLI access confirmed
- Minerva project deployed and functional

### ❌ What's Missing
- Custom domain not assigned to project
- No email-related DNS records
- auth.machinesafety.app subdomain not configured
- your.machinesafety.app subdomain not configured (UPDATED from app.machinesafety.app)

### 🎯 Immediate Next Steps
1. **Assign domain to project** (5 minutes)
2. **Configure subdomains** (10 minutes)
3. **Add basic email DNS records** (15 minutes)

**Total Time to Email-Ready**: ~30 minutes

## Verification Commands

### Check Current DNS
```bash
# List all DNS records
vercel dns ls machinesafety.app

# Check domain assignments
vercel domains ls

# Inspect specific domain
vercel domains inspect machinesafety.app
```

### Test DNS Propagation
```bash
# Check MX records
nslookup -type=MX machinesafety.app

# Check TXT records
nslookup -type=TXT machinesafety.app

# Check subdomain resolution
nslookup auth.machinesafety.app
```

### Online DNS Tools
- **DNS Checker**: https://dnschecker.org/
- **MX Toolbox**: https://mxtoolbox.com/
- **What's My DNS**: https://www.whatsmydns.net/

## Security Considerations

### SSL Certificates
- Vercel automatically provisions SSL for all assigned domains
- Let's Encrypt certificates auto-renew
- All subdomains get SSL automatically

### DNS Security
- CAA record already configured for Let's Encrypt
- Consider adding CAA record for other providers if needed
- Monitor DNS changes for unauthorized modifications

## Migration Path to Cloudflare (Future)

If you decide to migrate to Cloudflare DNS later:

### Preparation
1. Export current DNS configuration
2. Set up Cloudflare account and add domain
3. Configure all DNS records in Cloudflare

### Migration
1. Update nameservers in Vercel domain settings
2. Wait for propagation (24-48 hours)
3. Verify all services working correctly

### Rollback Plan
1. Revert nameservers to Vercel DNS
2. Wait for propagation
3. Verify services restored

This comprehensive DNS analysis shows you have a clean, simple setup that can easily accommodate the email service requirements. The Vercel CLI approach will work perfectly for your needs.