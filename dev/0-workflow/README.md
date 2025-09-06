# Minerva Development Workflow Documentation

## 📁 Overview

This directory contains comprehensive workflow documentation for the Minerva project, designed to help developers work efficiently with our new quality assurance system.

## 📚 Documentation Files

### **🚀 [Development Workflow Guide](./development-workflow-guide.md)**
**Complete step-by-step workflow for daily development**
- Full development lifecycle from start to PR
- Progressive quality gates explanation
- Monitoring and maintenance procedures
- Best practices and success metrics

### **⚡ [Quick Reference Card](./quick-reference.md)**
**Essential commands and shortcuts for daily use**
- Most common commands
- Status indicators
- Emergency procedures
- Workflow checklists

### **🔧 [Troubleshooting Guide](./troubleshooting-guide.md)**
**Solutions for common issues and problems**
- Pre-commit hook issues
- Build and development problems
- Testing and CI failures
- Emergency procedures

## 🎯 Quick Start

### **New to the Project?**
1. Read the **[Development Workflow Guide](./development-workflow-guide.md)** first
2. Bookmark the **[Quick Reference Card](./quick-reference.md)** for daily use
3. Keep the **[Troubleshooting Guide](./troubleshooting-guide.md)** handy for issues

### **Daily Development**
```bash
# Essential commands
npm run dev                    # Start development
npm run validate:staged        # Quick validation
git commit -m "your message"   # Auto-validated commit
npm run validate:all          # Pre-PR validation
```

## 🎯 Key Concepts

### **Progressive Quality Gates**
Our system uses 4 levels of validation:

1. **File Save** (IDE) - Instant formatting and checks
2. **Pre-commit** (Staged) - Fast validation with warnings
3. **Pre-PR** (Full) - Complete validation, all blocking
4. **CI/CD** (Automated) - Comprehensive pipeline

### **Development Modes**

#### **Development Mode** (Default)
- ✅ Fast staged-file validation
- ✅ Security checks (blocking)
- ⚠️ Quality issues as warnings (non-blocking)
- ⚡ Quick feedback (< 30 seconds)

#### **Production Mode**
- ✅ Full project validation
- ❌ All checks blocking
- 🔒 Strict quality enforcement
- ⏱️ Comprehensive (2-5 minutes)

## 📊 Monitoring System

### **Technical Debt Tracking**
```bash
npm run monitor:debt           # Current status
npm run monitor:debt:compare   # Trend analysis
```

### **Performance Monitoring**
```bash
npm run monitor:performance    # Current metrics
npm run monitor:performance:compare  # Regression detection
```

### **Health Checks**
```bash
npm run monitor:all            # Complete health check
npm run clean:all              # Cleanup artifacts
```

## 🚨 Emergency Procedures

### **Skip Validation (Emergency Only)**
```bash
git commit --no-verify         # Skip pre-commit
git push --no-verify          # Skip pre-push
```

### **Quick Fixes**
```bash
npm run lint:fix              # Auto-fix lint issues
npm run format                # Format code
npm run clean:all             # Clean artifacts
```

### **Complete Reset**
```bash
# Nuclear option
npm run clean:all
rm -rf node_modules
npm install
```

## 🎉 Benefits of This System

### **Prevents Technical Debt**
- ✅ **No more massive cleanup campaigns** like the recent 700+ error fix
- ✅ **Progressive quality enforcement** catches issues early
- ✅ **Automated monitoring** tracks trends and regressions

### **Improves Developer Experience**
- ⚡ **Fast feedback** with staged-file validation
- ⚠️ **Warnings instead of blocks** in development mode
- 🔄 **Automated fixes** for common issues
- 📊 **Clear status indicators** and reporting

### **Ensures Code Quality**
- 🔒 **Security scanning** prevents secret leaks
- 🎯 **Import organization** maintains consistency
- 📈 **Performance monitoring** catches regressions
- 🧪 **Comprehensive testing** in CI/CD pipeline

## 📈 Success Metrics

The system tracks these key indicators:

| Metric | Target | Alert |
|--------|--------|-------|
| ESLint Errors | < 50 | > 100 |
| TypeScript Errors | 0 | > 10 |
| Test Coverage | > 80% | < 70% |
| Pre-commit Speed | < 30s | > 60s |
| Build Time | Stable | +20% |
| Bundle Size | Stable | +10% |

## 🔄 Workflow Integration

### **Git Hooks**
- **Pre-commit**: Automatic staged-file validation
- **Pre-push**: Optional full validation
- **Post-commit**: Cleanup and monitoring

### **GitHub Actions**
- **PR Validation**: Complete quality pipeline
- **Security Scanning**: TruffleHog integration
- **E2E Testing**: On-demand with labels

### **IDE Integration**
- **Auto-formatting**: Prettier on save
- **Real-time checking**: ESLint and TypeScript
- **Import organization**: Automatic sorting

## 📞 Getting Help

### **Documentation Hierarchy**
1. **Quick Reference** - For daily commands
2. **Workflow Guide** - For complete processes
3. **Troubleshooting** - For specific issues
4. **Scripts README** - For technical details

### **Common Resources**
- **Scripts documentation**: `scripts/README.md`
- **Monitoring reports**: `logs/` directory
- **Configuration files**: Root directory
- **Git hooks**: `.husky/` directory

### **Support Channels**
- Check **troubleshooting guide** first
- Review **monitoring reports** in `logs/`
- Use **emergency procedures** if needed
- Consult **scripts documentation** for technical details

## 🎯 Remember

This system is designed to **help you maintain high code quality** while **preserving developer productivity**. The progressive quality gates ensure that:

- **Development is fast** with quick feedback
- **Quality is maintained** through automated checks
- **Technical debt is prevented** through monitoring
- **Emergencies are handled** with bypass options

The goal is **zero surprise cleanup campaigns** and **consistent, high-quality code** without sacrificing development speed.
