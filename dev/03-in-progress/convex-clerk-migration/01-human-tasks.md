# Human Tasks - Convex + Clerk Migration

**Important**: These tasks require human intervention as Claude Code cannot perform account creation, domain configuration, or external service setup.

**Estimated Time**: 2-3 hours total
**Prerequisites**: Credit card for paid services (if scaling beyond free tiers)
**Urgency**: Complete before Phase 1 implementation begins

---

## ⚠️ Critical Prerequisites

### Account Creation & Setup

#### 1. Convex Account Setup
**Timeline**: 30 minutes
**Requirements**: GitHub account for authentication

**Steps**:
1. Visit [convex.dev](https://convex.dev)
2. Sign up with GitHub account
3. Create new project: "minerva-machine-safety"
4. Note down:
   - **Convex URL**: `https://your-project.convex.cloud`
   - **Deploy Key**: For CI/CD (if needed)

**Verification**:
- [ ] Can access Convex dashboard
- [ ] Project created successfully
- [ ] Have Convex URL ready for environment variables

#### 2. Clerk Account Setup
**Timeline**: 45 minutes
**Requirements**: Email account, credit card for production features

**Steps**:
1. Visit [clerk.com](https://clerk.com)
2. Create account with business email
3. Create new application: "Minerva Machine Safety"
4. Configure authentication providers:
   - [ ] Email/Password (required)
   - [ ] Google OAuth (recommended for engineers)
   - [ ] Microsoft OAuth (if applicable for organization)
5. Set up organization support (for multi-tenant architecture)
6. Configure domain settings:
   - Development: `localhost:3000`
   - Production: `your-domain.com` (when ready)

**Critical Information to Save**:
- **Publishable Key**: `pk_test_...` (for frontend)
- **Secret Key**: `sk_test_...` (for backend)
- **Webhook Signing Key**: For webhook verification
- **JWT Template**: For integration tokens

**Verification**:
- [ ] Can access Clerk dashboard
- [ ] Application created with correct settings
- [ ] All authentication keys available
- [ ] Organization support enabled

#### 3. Environment Configuration
**Timeline**: 15 minutes

Create these environment variable files:

**.env.local** (Development):
```bash
# Convex
NEXT_PUBLIC_CONVEX_URL="https://your-project.convex.cloud"

# Clerk
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_test_..."
CLERK_SECRET_KEY="sk_test_..."
CLERK_WEBHOOK_SECRET="whsec_..."

# Existing Google Cloud Vision (keep for Phase 4)
GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
GOOGLE_CLOUD_PROJECT_ID="your-project-id"

# PostHog (if keeping analytics)
NEXT_PUBLIC_POSTHOG_KEY="your-posthog-key"
```

**.env.production** (Future):
```bash
# Convex Production
NEXT_PUBLIC_CONVEX_URL="https://your-prod-project.convex.cloud"

# Clerk Production
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_live_..."
CLERK_SECRET_KEY="sk_live_..."
CLERK_WEBHOOK_SECRET="whsec_..."
```

**Verification**:
- [ ] Environment files created
- [ ] All keys properly formatted
- [ ] No keys committed to git (.env.* in .gitignore)

---

## 🚀 Optional Enhancements

### Domain & DNS Setup (Future)
**When**: Before production deployment
**Timeline**: 30 minutes + DNS propagation

**Steps**:
1. Configure custom domain in Clerk dashboard
2. Update DNS records for authentication redirects
3. Set up SSL certificates (usually automatic)
4. Test authentication flow with custom domain

### Monitoring & Analytics Setup
**When**: Phase 5 or 6
**Timeline**: 45 minutes

**Options**:
- **Convex Built-in**: Monitoring included
- **External**: Sentry, LogRocket, or similar
- **Analytics**: PostHog, Mixpanel, or similar

---

## 🔍 Verification Checklist

Before proceeding to Phase 1, verify:

### Convex Setup ✅
- [ ] Account created and accessible
- [ ] Project "minerva-machine-safety" exists
- [ ] Convex URL available and working
- [ ] Can access project dashboard

### Clerk Setup ✅
- [ ] Account created with business email
- [ ] Application "Minerva Machine Safety" exists
- [ ] All authentication keys saved securely
- [ ] Organization support enabled
- [ ] Test authentication providers configured

### Environment Configuration ✅
- [ ] .env.local created with all required variables
- [ ] All keys are valid and properly formatted
- [ ] Environment files not committed to git
- [ ] Can run `npm run dev` without environment errors

### Integration Test ✅
- [ ] Both services accessible from browser
- [ ] No CORS or authentication errors in console
- [ ] Ready to begin Phase 1 development

---

## ⏰ Timeline & Dependencies

### Immediate (Phase 0)
- **Account Creation**: Must be completed first
- **Environment Setup**: Blocks all development work
- **Integration Verification**: Ensures smooth Phase 1 start

### Future Phases
- **Domain Setup**: Required before production deployment
- **Monitoring Setup**: Can be done during Phase 5/6
- **Production Keys**: Required for production deployment

---

## 🆘 Troubleshooting

### Common Issues

**Convex URL Not Working**:
- Check project is deployed (may need `npx convex dev` first)
- Verify URL format: `https://[project-name].convex.cloud`

**Clerk Keys Invalid**:
- Ensure using test keys for development
- Check key format: `pk_test_` for publishable, `sk_test_` for secret
- Regenerate keys if compromised

**Environment Variables Not Loading**:
- Check file name: `.env.local` (not `.env`)
- Restart development server after changes
- Verify no typos in variable names

**Authentication Errors**:
- Check domain configuration in Clerk dashboard
- Verify CORS settings allow localhost:3000
- Ensure all required Clerk providers are enabled

---

## 📞 Support Contacts

### Convex Support
- **Documentation**: [docs.convex.dev](https://docs.convex.dev)
- **Discord**: [Convex Discord](https://convex.dev/community)
- **Email**: support@convex.dev

### Clerk Support
- **Documentation**: [clerk.com/docs](https://clerk.com/docs)
- **Discord**: [Clerk Discord](https://clerk.com/discord)
- **Email**: support@clerk.com

---

**Next Step**: Once all tasks completed, proceed to Phase 1 implementation
**Estimated Total Time**: 2-3 hours for complete setup
**Critical Path**: Account creation → Environment setup → Integration verification