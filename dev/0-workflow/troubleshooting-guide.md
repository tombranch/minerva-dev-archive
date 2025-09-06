# Troubleshooting Guide

## 🚨 Common Issues & Solutions

### **Pre-commit Hook Issues**

#### **Issue: "Security check failed - potential secret detected"**
```bash
# Check what was detected
git diff --cached

# Common false positives:
# - Mock API keys with asterisks (sk-****)
# - Test tokens in test files
# - Documentation examples

# Solutions:
1. Remove actual secrets from staged files
2. Use environment variables instead
3. Add to .env.example with placeholder values
4. Emergency bypass: git commit --no-verify
```

#### **Issue: "Pre-commit hook is too slow"**
```bash
# Use fast mode instead
npm run pre-commit:staged

# Or check what's taking time
npm run validate:staged --verbose

# Emergency bypass
git commit --no-verify
```

#### **Issue: "Lint errors blocking commit"**
```bash
# Auto-fix what's possible
npm run lint:fix

# Format code
npm run format

# Check remaining issues
npm run lint

# If in dev mode, should only be warnings
# Check if you're in production mode
echo $MINERVA_PRODUCTION_MODE
```

### **Build & Development Issues**

#### **Issue: "npm run dev fails"**
```bash
# Check for port conflicts
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Clean and restart
npm run clean:all
npm install
npm run dev
```

#### **Issue: "Build fails with ESLint errors"**
```bash
# ESLint is now enabled during builds
# Fix the errors first
npm run lint:fix

# Check current error count
npm run monitor:debt

# If too many errors, temporarily disable
# (Not recommended - fix the root cause)
```

#### **Issue: "TypeScript errors in build"**
```bash
# Check type errors
npx tsc --noEmit

# See current status
npm run monitor:debt

# Fix incrementally or create baseline
npm run monitor:debt:save
```

### **Testing Issues**

#### **Issue: "Tests fail in CI but pass locally"**
```bash
# Run tests in CI mode locally
npm run test:ci

# Check for environment differences
npm run validate:all

# Clean test artifacts
npm run clean:all
npm run test:ci
```

#### **Issue: "E2E tests not running in PR"**
```bash
# E2E tests only run with label
# Add label "e2e-test" to your PR

# Or run locally
npm run test:e2e
```

### **Performance Issues**

#### **Issue: "Performance regression detected"**
```bash
# Check what changed
npm run monitor:performance:compare

# Common causes:
# - Large bundle size increase
# - Slow build times
# - New dependencies

# Solutions:
npm run clean:all
npm run build
npm run monitor:performance:save
```

#### **Issue: "Bundle size too large"**
```bash
# Analyze bundle
npm run build
npm run monitor:performance

# Check for:
# - Unused dependencies
# - Large imports
# - Duplicate packages

# Use bundle analyzer
npx @next/bundle-analyzer
```

### **Monitoring & Reporting Issues**

#### **Issue: "Technical debt monitor shows high error count"**
```bash
# Check current status
npm run monitor:debt

# See trend
npm run monitor:debt:compare

# This is expected after major changes
# Create new baseline if needed
rm logs/tech-debt-history.json
npm run monitor:debt:save
```

#### **Issue: "Monitoring reports missing"**
```bash
# Reports are saved in logs/ directory
ls logs/

# Generate new reports
npm run monitor:all

# Check if logs directory exists
mkdir -p logs
npm run monitor:debt:save
```

### **Git & CI Issues**

#### **Issue: "PR validation fails"**
```bash
# Check which step failed in GitHub Actions
# Common failures:

# 1. Security check
# - Remove secrets from code
# - Use environment variables

# 2. Code quality
# - Run npm run lint:fix
# - Run npm run format

# 3. Tests
# - Run npm run test:all locally
# - Check for environment issues

# 4. Build
# - Run npm run build locally
# - Check for missing environment variables
```

#### **Issue: "Can't push to remote"**
```bash
# Check if pre-push hooks are blocking
git push --no-verify

# Or fix issues first
npm run validate:all
git push
```

### **Environment Issues**

#### **Issue: "Environment variables not working"**
```bash
# Check .env.local exists
ls -la .env.local

# Check for required variables
npm run validate:all

# Copy from example
cp .env.example .env.local
# Edit with your values
```

#### **Issue: "Different behavior in production mode"**
```bash
# Check if production mode is enabled
echo $MINERVA_PRODUCTION_MODE

# Disable for development
unset MINERVA_PRODUCTION_MODE
# or
export MINERVA_PRODUCTION_MODE=false
```

## 🔧 Emergency Procedures

### **Complete Reset**
```bash
# Nuclear option - reset everything
git stash
npm run clean:all
rm -rf node_modules
rm package-lock.json
npm install
npm run dev
```

### **Skip All Validation**
```bash
# Emergency commit (use sparingly)
git commit --no-verify -m "emergency fix"
git push --no-verify
```

### **Reset Monitoring Baseline**
```bash
# Start fresh monitoring
rm logs/tech-debt-history.json
rm logs/performance-history.json
npm run monitor:all
```

## 📞 Getting Help

### **Check Status First**
```bash
npm run monitor:all           # Overall health
npm run validate:staged       # Quick validation
git status                    # Git status
```

### **Common Log Locations**
- **Monitoring reports**: `logs/tech-debt-*.json`, `logs/performance-*.json`
- **Test results**: `logs/test-results.*`
- **Build logs**: `.next/` directory
- **Git hooks**: `.husky/` directory

### **Useful Debug Commands**
```bash
# Check what's staged
git diff --cached

# Check recent commits
git log --oneline -5

# Check current branch
git branch

# Check remote status
git status -v
```

### **When All Else Fails**
1. **Check the logs** in `logs/` directory
2. **Run monitoring** with `npm run monitor:all`
3. **Try emergency bypass** with `--no-verify`
4. **Reset to clean state** with complete reset procedure
5. **Ask for help** with specific error messages

Remember: The new system is designed to help, not hinder. Most issues can be resolved with auto-fix commands or by understanding what the validation is trying to prevent.
