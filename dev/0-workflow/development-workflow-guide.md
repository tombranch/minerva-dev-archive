# Minerva Development Workflow Guide

## 🎯 Overview

This guide outlines the complete development workflow for the Minerva project, incorporating all the quality gates and automation we've implemented to prevent technical debt accumulation.

## 🚀 Quick Start

### Daily Development Commands
```bash
# Start development
npm run dev

# Quick validation (before committing)
npm run validate:staged

# Full validation (before PR)
npm run validate:all

# Monitor project health
npm run monitor:all
```

## 📋 Complete Development Workflow

### 1. **Starting Work**

```bash
# Pull latest changes
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Start development server
npm run dev
```

### 2. **During Development**

#### **File-Level Quality (Automatic)**
- ✅ **Auto-formatting on save** (Prettier)
- ✅ **Real-time type checking** (TypeScript)
- ✅ **Immediate lint feedback** (ESLint)

#### **Quick Validation Commands**
```bash
# Check your changes quickly
npm run validate:staged        # Only staged files
npm run lint:fix              # Auto-fix lint issues
npm run format                # Format all files
```

### 3. **Before Committing**

#### **Option A: Fast Development Mode (Default)**
```bash
git add .
git commit -m "your commit message"
```
- ✅ **Automatic staged-file validation**
- ✅ **Security checks** (blocking)
- ✅ **Quality issues as warnings** (non-blocking)
- ⚡ **Fast feedback** (usually < 30 seconds)

#### **Option B: Full Validation Mode**
```bash
# For important commits or before PR
npm run validate:all
git add .
git commit -m "your commit message"
```

### 4. **Before Creating PR**

#### **Complete Pre-PR Checklist**
```bash
# 1. Full validation
npm run validate:all

# 2. Check technical debt status
npm run monitor:debt:compare

# 3. Performance check
npm run monitor:performance

# 4. Clean up temporary files
npm run clean:root:dry

# 5. Run all tests
npm run test:all
```

### 5. **Creating Pull Request**

#### **PR Creation Process**
1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub**
   - ✅ **Automatic validation** triggers
   - ✅ **Security scanning**
   - ✅ **Code quality checks**
   - ✅ **Test execution**
   - ✅ **Build validation**

3. **Add E2E testing** (if needed)
   - Add label: `e2e-test` to PR
   - ✅ **Automatic E2E test execution**

#### **PR Validation Pipeline**
The PR will automatically run:
- 🔒 **Security & Dependencies**
- 🔍 **Code Quality** (lint, format, type check)
- 🧪 **Testing** (unit tests with coverage)
- 🏗️ **Build Validation**
- 🎭 **E2E Testing** (if labeled)

### 6. **Monitoring & Maintenance**

#### **Weekly Health Checks**
```bash
# Monday morning routine
npm run monitor:all            # Check overall health
npm run clean:all              # Clean up artifacts
```

#### **Monthly Deep Analysis**
```bash
# Technical debt trends
npm run monitor:debt:compare

# Performance trends
npm run monitor:performance:compare

# Clean up logs
npm run clean:logs
```

## 🎯 Progressive Quality Gates

### **Level 1: File Save (IDE)**
- **Automatic formatting** on save
- **Real-time type checking**
- **Immediate lint feedback**

### **Level 2: Pre-commit (Staged Files)**
- **Command**: `npm run pre-commit:staged`
- **Speed**: < 30 seconds
- **Behavior**: Security (blocking) + Quality (warnings)

### **Level 3: Pre-push/PR (Full Project)**
- **Command**: `npm run validate:all`
- **Speed**: 2-5 minutes
- **Behavior**: All checks blocking

### **Level 4: CI/CD (Automated)**
- **Trigger**: PR creation/update
- **Features**: Complete validation pipeline
- **Monitoring**: Automated regression detection

## 🚨 Emergency Procedures

### **Skip Validation (Emergency Only)**
```bash
# Skip pre-commit hooks
git commit --no-verify -m "emergency fix"

# Skip CI validation
git push --no-verify
```

### **Force Cleanup**
```bash
# Clean everything
npm run clean:all

# Reset monitoring baseline
rm logs/tech-debt-history.json
rm logs/performance-history.json
npm run monitor:all
```

### **Fix Validation Failures**
```bash
# Auto-fix common issues
npm run lint:fix
npm run format

# Check what's wrong
npm run validate:staged
npm run monitor:debt
```

## 📊 Understanding Feedback

### **Pre-commit Messages**

#### **✅ Success**
```
✅ ALL CHECKS PASSED
🎉 Commit proceeding...
```

#### **⚠️ Warnings (Non-blocking)**
```
⚠️ COMMIT ALLOWED WITH WARNINGS
💡 Consider fixing issues before pushing
🔧 Use npm run lint:fix && npm run format to auto-fix
```

#### **❌ Blocked**
```
❌ BLOCKED: Security issues found:
  • Potential secret in file.js
🔧 To fix: Remove secrets from staged files
```

### **Monitoring Reports**

#### **Technical Debt Status**
- **Green**: Errors decreasing or stable
- **Yellow**: Minor increase in errors
- **Red**: Significant regression detected

#### **Performance Status**
- **Green**: No significant regressions
- **Yellow**: Minor performance impact
- **Red**: Significant performance regression

## 🛠️ Troubleshooting

### **Common Issues**

#### **"Pre-commit hook fails"**
```bash
# Try fast mode
npm run pre-commit:staged

# Check what's failing
npm run validate:staged

# Emergency bypass
git commit --no-verify
```

#### **"Build fails in CI"**
```bash
# Test locally first
npm run build

# Check for environment issues
npm run validate:all
```

#### **"Too many lint errors"**
```bash
# Auto-fix what's possible
npm run lint:fix

# Check current status
npm run monitor:debt
```

#### **"Performance regression detected"**
```bash
# Check what changed
npm run monitor:performance:compare

# Clean and rebuild
npm run clean:all
npm run build
```

## 📈 Success Metrics

### **Project Health Indicators**
- **ESLint Errors**: Target < 50, Alert > 100
- **TypeScript Errors**: Target 0, Alert > 10
- **Test Coverage**: Target > 80%, Alert < 70%
- **Build Time**: Alert if > 20% increase
- **Bundle Size**: Alert if > 10% increase

### **Developer Experience Metrics**
- **Pre-commit Speed**: Target < 30 seconds
- **Validation Feedback**: Immediate for staged files
- **CI Pipeline**: Target < 10 minutes
- **Developer Satisfaction**: Warnings vs blocks in dev mode

## 🎉 Best Practices

### **Commit Messages**
```bash
# Good examples
git commit -m "feat(auth): add user login validation"
git commit -m "fix(ui): resolve mobile navigation issue"
git commit -m "refactor(api): improve error handling"
```

### **Branch Naming**
```bash
feature/user-authentication
fix/mobile-navigation-bug
refactor/api-error-handling
hotfix/security-vulnerability
```

### **PR Descriptions**
- **What**: Brief description of changes
- **Why**: Reason for the change
- **Testing**: How it was tested
- **Screenshots**: For UI changes

This workflow ensures high code quality while maintaining developer productivity and preventing technical debt accumulation.
