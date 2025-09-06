# Minerva Quick Reference Card

## 🚀 Daily Commands

### **Start Development**
```bash
npm run dev                    # Start development server
npm run dev:safe              # Start with process management
```

### **Quick Validation**
```bash
npm run validate:staged        # Fast staged-file check
npm run lint:fix              # Auto-fix lint issues
npm run format                # Format code
```

### **Before Committing**
```bash
git add .
git commit -m "your message"   # Auto-runs staged validation
```

### **Before PR**
```bash
npm run validate:all          # Full validation
npm run monitor:debt:compare  # Check technical debt
npm run test:all              # Run all tests
```

## 🎯 Progressive Quality Gates

| Level | Trigger | Speed | Behavior |
|-------|---------|-------|----------|
| **1. File Save** | IDE | Instant | Auto-format, real-time checks |
| **2. Pre-commit** | `git commit` | <30s | Security (block) + Quality (warn) |
| **3. Pre-PR** | Manual | 2-5min | All checks blocking |
| **4. CI/CD** | PR | 5-10min | Complete validation pipeline |

## 📊 Monitoring Commands

```bash
npm run monitor:debt           # Check technical debt
npm run monitor:performance    # Performance analysis
npm run monitor:all            # Run all monitoring
```

## 🧹 Cleanup Commands

```bash
npm run clean:root:dry         # Preview cleanup
npm run clean:root             # Clean root directory
npm run clean:all              # Full cleanup
```

## 🚨 Emergency Commands

```bash
git commit --no-verify         # Skip pre-commit hooks
npm run clean:all              # Force cleanup
npm run lint:fix && npm run format  # Quick fixes
```

## 📈 Status Indicators

### **✅ Good**
- ESLint errors < 50
- TypeScript errors = 0
- Test coverage > 80%
- Pre-commit < 30s

### **⚠️ Warning**
- ESLint errors 50-100
- TypeScript errors 1-10
- Test coverage 70-80%
- Performance regression < 20%

### **❌ Alert**
- ESLint errors > 100
- TypeScript errors > 10
- Test coverage < 70%
- Performance regression > 20%

## 🔧 Common Fixes

### **Lint Errors**
```bash
npm run lint:fix              # Auto-fix
npm run format                # Format code
```

### **Type Errors**
```bash
npx tsc --noEmit              # Check types
npm run monitor:debt          # See current status
```

### **Test Failures**
```bash
npm test                      # Run tests
npm run test:watch            # Watch mode
npm run test:coverage         # With coverage
```

### **Build Failures**
```bash
npm run build                 # Test build
npm run clean:all             # Clean and retry
```

## 📋 Workflow Checklist

### **Daily Development**
- [ ] `npm run dev` - Start development
- [ ] Make changes with IDE auto-formatting
- [ ] `npm run validate:staged` - Quick check
- [ ] `git commit` - Commit with auto-validation

### **Before PR**
- [ ] `npm run validate:all` - Full validation
- [ ] `npm run monitor:debt:compare` - Check debt
- [ ] `npm run test:all` - All tests pass
- [ ] `git push` - Push branch
- [ ] Create PR with proper description

### **Weekly Maintenance**
- [ ] `npm run monitor:all` - Health check
- [ ] `npm run clean:all` - Cleanup
- [ ] Review monitoring reports in `logs/`

## 🎯 Key Benefits

✅ **No more massive cleanup campaigns**  
✅ **Fast feedback loops** (< 30 seconds)  
✅ **Automated regression detection**  
✅ **Progressive quality enforcement**  
✅ **Self-maintaining codebase**  

## 📞 Help

- **Full Guide**: `dev/0-workflow/development-workflow-guide.md`
- **Scripts Docs**: `scripts/README.md`
- **Emergency**: Use `--no-verify` to bypass hooks
