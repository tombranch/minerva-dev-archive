# Phase 0: Prerequisites & Setup - Implementation Plan

**Duration**: 1-2 days
**Responsible**: Human operator
**Objective**: Complete all account setup and environment configuration
**Success Criteria**: Development environment ready for Phase 1

---

## 🎯 Phase Overview

Phase 0 is the foundation for the entire migration. All tasks require human intervention as they involve external service account creation, payment configuration, and environment setup. This phase must be completed before any development work can begin.

**Critical Dependencies**:
- GitHub account for Convex authentication
- Business email for Clerk account
- Credit card for production scaling (optional initially)
- Access to current environment variables

---

## 📋 Task Breakdown

### Task 1: Convex Account Setup
**Timeline**: 30 minutes
**Priority**: P1 - Blocking all development

**Detailed Steps**:
1. **Account Creation**
   - Navigate to [convex.dev](https://convex.dev)
   - Click "Sign up" and authenticate with GitHub
   - Verify email if prompted
   - Complete profile setup

2. **Project Creation**
   - Create new project: `minerva-machine-safety`
   - Select region closest to users (US East recommended)
   - Note the generated project URL: `https://[random-string].convex.cloud`

3. **Development Setup**
   - In dashboard, go to Settings → Environment Variables
   - Prepare for later: deployment key for CI/CD (if needed)
   - Verify project dashboard accessibility

**Verification Checklist**:
- [ ] Can access Convex dashboard at dashboard.convex.dev
- [ ] Project "minerva-machine-safety" visible in project list
- [ ] Project URL format: `https://[project-id].convex.cloud`
- [ ] No errors when accessing project settings

**Output Required**:
- **Convex URL**: `https://your-project-id.convex.cloud`
- **Project ID**: The unique identifier for environment variables

---

### Task 2: Clerk Account Setup
**Timeline**: 45 minutes
**Priority**: P1 - Blocking authentication development

**Detailed Steps**:
1. **Account Creation**
   - Navigate to [clerk.com](https://clerk.com)
   - Sign up with business email address
   - Complete email verification
   - Set up 2FA (recommended for security)

2. **Application Creation**
   - Click "Create Application"
   - Name: "Minerva Machine Safety"
   - Select authentication methods:
     - ✅ Email/Password (required)
     - ✅ Google OAuth (recommended)
     - ✅ Microsoft OAuth (if organization uses Office 365)

3. **Application Configuration**
   - **Development Environment**:
     - Add domain: `localhost:3000`
     - Set redirect URLs: `http://localhost:3000`
   - **Production Environment** (for later):
     - Add production domain when ready
     - Configure SSL/HTTPS redirects

4. **Organization Support Setup**
   - Navigate to "Organizations" in dashboard
   - Enable organization support
   - Configure organization creation settings:
     - Allow users to create organizations: Yes
     - Max organizations per user: 3 (adjust as needed)

5. **API Keys Collection**
   - Go to "API Keys" section
   - Copy the following (store securely):
     - **Publishable Key**: `pk_test_...` (safe for frontend)
     - **Secret Key**: `sk_test_...` (server-side only)
   - Go to "Webhooks" section (for later)
     - Note webhook signing key format: `whsec_...`

**Verification Checklist**:
- [ ] Can access Clerk dashboard at dashboard.clerk.com
- [ ] Application "Minerva Machine Safety" created
- [ ] All authentication providers configured
- [ ] Organization support enabled
- [ ] Development domain (localhost:3000) added
- [ ] All API keys available and saved securely

**Output Required**:
- **Publishable Key**: `pk_test_...`
- **Secret Key**: `sk_test_...`
- **Application ID**: For reference
- **Webhook Signing Key**: `whsec_...` (for later phases)

---

### Task 3: Environment Variable Configuration
**Timeline**: 15 minutes
**Priority**: P1 - Required for development startup

**File Creation**:

Create `.env.local` in project root:
```bash
# Convex Configuration
NEXT_PUBLIC_CONVEX_URL="https://your-project-id.convex.cloud"

# Clerk Authentication
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_test_your_key_here"
CLERK_SECRET_KEY="sk_test_your_secret_key_here"
CLERK_WEBHOOK_SECRET="whsec_your_webhook_secret_here"

# Existing Integrations (Keep for Phases 4-5)
GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
GOOGLE_CLOUD_PROJECT_ID="your-existing-project-id"

# Analytics (Keep existing)
NEXT_PUBLIC_POSTHOG_KEY="your-existing-posthog-key"

# Development Configuration
NEXT_PUBLIC_APP_ENV="development"
```

**Security Setup**:
1. Verify `.env.local` is in `.gitignore`
2. Never commit these files to git
3. Store production keys separately for later

**Verification Steps**:
1. Run `npm run dev:safe` from project root
2. Check browser console for environment variable errors
3. Verify no CORS or authentication errors
4. Test that both Convex and Clerk can be reached

**Verification Checklist**:
- [ ] `.env.local` file created with all required variables
- [ ] All keys are properly formatted (no extra quotes/spaces)
- [ ] Environment file not committed to git
- [ ] Development server starts without environment errors
- [ ] Browser console shows no authentication/CORS errors

---

## 🔍 Integration Verification

### Final Integration Test
**Timeline**: 10 minutes
**Objective**: Ensure both services are accessible and configured correctly

**Steps**:
1. Start development server: `npm run dev:safe`
2. Open browser to `http://localhost:3000`
3. Check browser developer console:
   - No CORS errors from convex.cloud domain
   - No authentication errors from clerk.com domain
   - All environment variables loading correctly

**Success Indicators**:
- ✅ Development server starts successfully
- ✅ No environment variable errors in terminal
- ✅ No CORS errors in browser console
- ✅ Can access both Convex and Clerk dashboards
- ✅ Ready to begin Phase 1 development

**Troubleshooting Checklist**:
- [ ] If Convex URL not working: Ensure project is created and URL is correct
- [ ] If Clerk keys invalid: Regenerate keys and check format
- [ ] If CORS errors: Verify localhost:3000 is added to Clerk domains
- [ ] If environment vars not loading: Restart dev server after changes

---

## 📞 Support Resources

### If You Get Stuck

**Convex Support**:
- Documentation: [docs.convex.dev](https://docs.convex.dev)
- Discord: [convex.dev/community](https://convex.dev/community)
- Email: support@convex.dev

**Clerk Support**:
- Documentation: [clerk.com/docs](https://clerk.com/docs)
- Discord: [clerk.com/discord](https://clerk.com/discord)
- Email: support@clerk.com

### Common Issues & Solutions

**"Project URL not working"**:
- Project may not be fully provisioned (wait 2-3 minutes)
- Check URL format: `https://[project-id].convex.cloud`

**"Clerk authentication failing"**:
- Verify domain configuration in Clerk dashboard
- Check API key format and regenerate if needed
- Ensure localhost:3000 is added to allowed domains

**"Environment variables not loading"**:
- File must be named `.env.local` (not `.env`)
- Restart development server after making changes
- Check for typos in variable names

---

## 🎯 Phase Completion Criteria

### Technical Readiness
- [ ] Convex account created and project accessible
- [ ] Clerk account created with application configured
- [ ] All environment variables configured correctly
- [ ] Development server starts without errors
- [ ] Both services accessible from browser

### Documentation Handover
- [ ] All API keys documented and stored securely
- [ ] Account credentials saved in secure location
- [ ] Environment setup validated and tested
- [ ] Troubleshooting steps verified

### Next Phase Preparation
- [ ] Phase 1 development environment ready
- [ ] All blocking prerequisites completed
- [ ] Claude Code can begin implementation work
- [ ] No human intervention required for Phase 1

---

## ⏭️ Transition to Phase 1

Once Phase 0 is complete:

1. **Verify completion** using all checklists above
2. **Test development environment** with `npm run dev:safe`
3. **Notify Claude Code** that Phase 0 is complete
4. **Begin Phase 1** - Foundation & Proof of Concept

**Phase 1 Preview**: Claude Code will implement AI Model Management feature using Convex + Clerk to validate the new stack and development experience.

**Estimated Phase 1 Start**: Within 1 hour of Phase 0 completion

---

**Phase Owner**: Human operator
**Phase Completion**: Required before any development begins
**Next Phase**: Phase 1 - Foundation & Proof of Concept
**Success Metric**: Zero environment/configuration errors in Phase 1 startup