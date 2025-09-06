# Validation Workflow Guide

This guide covers the comprehensive validation system for the Minerva project, designed to catch issues at different stages of development.

## 🚀 Validation Hierarchy

### 1. **Staged Files Validation** ⚡ (20-30s)
```bash
npm run pre-commit
# OR automatic on git commit
git commit -m "your changes"
```

**What it does:**
- ✅ Security check (blocking for real secrets)
- ✅ Auto-fixes formatting and linting where possible
- ✅ TypeScript check with strict mode
- ✅ Build compatibility test
- **Scope:** Staged files only
- **Philosophy:** Fast feedback with auto-fixing

### 2. **Quick Project Validation** ⚡ (30-60s)
```bash
npm run validate:quick
```

**What it does:**
- ✅ Formatting check (whole project)
- ✅ ESLint check (whole project)
- ✅ TypeScript check (whole project)
- ✅ Dependency integrity check
- **Scope:** Entire codebase
- **Use case:** Development workflow, quick project health check

### 3. **Comprehensive Validation** 🔍 (2-5 mins)
```bash
npm run validate:all
```

**What it does:**
- ✅ All quick validation checks
- ✅ Security scan (entire project)
- ✅ Unit test suite
- ✅ Full production build test
- ✅ Environment validation
- **Scope:** Entire codebase + build + tests
- **Use case:** Pre-PR validation, deployment readiness

## 📋 Legacy Commands (Aliased)
```bash
npm run check              # Alias for validate:all
```

## 🎯 Recommended Workflow

### During Development
```bash
# Quick health check while coding
npm run validate:quick

# Test specific changes
git add . && npm run pre-commit
```

### Before Creating PR
```bash
# Comprehensive validation
npm run validate:all

# If all passes, create PR
gh pr create --title "Feature: your changes"
```

### Git Integration
```bash
# Automatic validation (pre-commit hook)
git commit -m "feat: implement new feature"
# Runs pre-commit validation automatically

# Skip validation if absolutely needed
git commit -m "wip: quick save" --no-verify
```

## 🔧 Configuration Files

### Pre-commit Hook
- Location: `.husky/pre-commit`
- Script: `scripts/maintenance/pre-commit-unified.js`

### Validation Scripts
- Quick: `scripts/maintenance/validate-quick.js`
- Full: `scripts/maintenance/validate-all.js`
- Build check: `scripts/maintenance/pre-commit-build-check.js`

### TypeScript Configuration
- Main config: `tsconfig.json` (strict mode enabled)
- All validation uses main config for consistency

## 🚨 Handling Validation Failures

### Common Issues and Fixes

#### Formatting Issues
```bash
npm run format        # Auto-fix formatting
npm run format:check  # Check formatting without fixing
```

#### Linting Issues
```bash
npm run lint:fix      # Auto-fix linting issues
npm run lint          # Check linting without fixing
```

#### TypeScript Errors
```bash
npx tsc --noEmit      # See all type errors
```

#### Build Failures
```bash
npm run build         # Full build test
npm run dev           # Start dev server to debug
```

#### Test Failures
```bash
npm test              # Run unit tests
npm run test:watch    # Watch mode for debugging
```

## 📊 Understanding Output

### Success Indicators
- ✅ Green checkmarks for passed checks
- 🔧 Auto-fix indicators when issues were resolved automatically
- ⚡ Timing information for performance monitoring

### Failure Indicators
- ❌ Red X marks for failed checks
- 💡 Suggested fix commands
- 📊 Issue counts and categories
- 📂 Log file locations (when created)

### Performance Targets
- **Pre-commit:** 20-30 seconds
- **Quick validation:** 30-60 seconds
- **Full validation:** 2-5 minutes

## 🔄 Migration from Old System

### Removed (Simplified)
- ❌ Dev/prod mode distinction
- ❌ `MINERVA_PRODUCTION_MODE` environment variable
- ❌ `tsconfig.production.json` (used main config instead)
- ❌ Separate dev and production pre-commit scripts

### New Unified Approach
- ✅ Single pre-commit path for all developers
- ✅ Consistent validation using production-grade settings
- ✅ Auto-fixing capabilities where possible
- ✅ Clear performance targets and user experience

## 🐛 Troubleshooting

### Pre-commit Hook Not Running
```bash
# Reinstall git hooks
npm run prepare

# Check hook exists
ls -la .husky/pre-commit
```

### Validation Scripts Not Found
```bash
# Check scripts exist
ls scripts/maintenance/pre-commit-*.js
ls scripts/maintenance/validate-*.js

# Reinstall dependencies
npm ci
```

### Performance Issues
```bash
# Clean up node processes
npm run cleanup

# Clear Next.js cache
rm -rf .next
npm run dev:safe
```

### Emergency Bypass
```bash
# Skip all validation (use sparingly)
git commit --no-verify -m "emergency fix"

# Or set in environment temporarily
export SKIP_VALIDATION=true
git commit -m "quick fix"
```

## 📈 Metrics and Monitoring

### Timing Benchmarks
- Monitor validation performance with built-in timing
- Target performance within documented ranges
- Report performance degradation to team

### Issue Tracking
- Validation failures create log files for debugging
- Track recurring issues for process improvement
- Use issue counts in summaries for project health metrics

## 🔮 Future Improvements

### Planned Enhancements
- Parallel test execution for faster full validation
- Smart caching for unchanged files
- Integration with CI/CD pipeline validation
- Custom validation rules for specific file types

### Community Contributions
- Validation rules are configurable via standard tool configs
- ESLint rules: `.eslintrc.js`
- Prettier config: `.prettierrc`
- TypeScript config: `tsconfig.json`