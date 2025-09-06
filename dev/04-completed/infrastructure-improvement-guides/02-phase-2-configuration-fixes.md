# Configuration Fixes Guide
*Comprehensive guide for fixing configuration inconsistencies*

**Priority**: Medium-High  
**Estimated Time**: 2-3 hours  
**Dependencies**: Jest migration must be completed first  
**Risk Level**: Low (mostly file path and setting corrections)

## 🎯 Configuration Overview

### Current Issues Identified
1. **Path Mismatches**: Vitest pointing to wrong setup directory
2. **Pre-commit Hooks**: Husky installed but misconfigured  
3. **Cross-platform Scripts**: PowerShell dependencies limiting compatibility
4. **Environment Inconsistencies**: Different behavior across development environments

### Target State
- All configuration paths point to correct directories
- Pre-commit hooks prevent broken commits
- Scripts work across Windows/macOS/Linux
- Consistent development environment setup

## 📋 Pre-Configuration Checklist

### Prerequisites
- [ ] Jest to Vitest migration completed successfully
- [ ] All tests passing with Vitest
- [ ] TypeScript compilation successful
- [ ] Current branch: `infrastructure-improvements` or similar

### Environment Verification
```bash
# Verify current state
npm run validate:quick 2>&1 | tee config-fixes-before.log

# Check current directory structure
ls -la test/ tests/ 2>/dev/null || echo "Directory check complete"

# Verify Husky status
ls -la .husky/ 2>/dev/null || echo "Husky directory check complete"
```

## 🔧 Fix 1: Vitest Configuration Paths

### Current Issue
```typescript
// vitest.config.ts - Line ~7
setupFiles: ['./test/setup.ts'], // INCORRECT PATH
```

### Directory Structure Verification
```bash
# Check which setup files exist
ls -la test/setup.ts 2>/dev/null && echo "✅ test/setup.ts exists"
ls -la tests/setup.ts 2>/dev/null && echo "✅ tests/setup.ts exists"

# Check test directory contents
echo "test/ contents:" && ls test/ 2>/dev/null
echo "tests/ contents:" && ls tests/ 2>/dev/null
```

### Fix Implementation
**File**: `vitest.config.ts`

```typescript
// Update setupFiles path
setupFiles: ['./tests/setup.ts'], // CORRECTED PATH

// Full context for verification:
export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'happy-dom',
    globals: true,
    setupFiles: ['./tests/setup.ts'], // ← This line
    include: [
      'tests/**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}',
      '__tests__/**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}',
    ],
    // ... rest of config
  }
});
```

### Verification Commands
```bash
# Check file content
grep -n "setupFiles" vitest.config.ts

# Test configuration
npx vitest --run --reporter=verbose tests/setup.ts

# Expected output: Should load without errors
```

**Checklist:**
- [ ] vitest.config.ts path updated
- [ ] Setup file loads without errors
- [ ] Tests can access setup configuration

## 🔧 Fix 2: Pre-commit Hooks Implementation

### Current Issue
- Husky is installed in package.json
- `.husky` directory is listed in `.gitignore`
- No pre-commit validation running

### Investigation Commands
```bash
# Check Husky installation
npm ls husky

# Check .gitignore contents
grep -n "husky" .gitignore

# Check if .husky directory exists
ls -la .husky/ 2>/dev/null || echo "No .husky directory found"
```

### Fix Implementation

#### Step 1: Update .gitignore
**File**: `.gitignore`

```bash
# Remove this line from .gitignore:
# .husky (if present)

# Or comment it out for reference:
# .husky  # Removed - pre-commit hooks should be committed
```

#### Step 2: Initialize Husky (if needed)
```bash
# Initialize Husky
npx husky install

# Create .husky directory if it doesn't exist
mkdir -p .husky
```

#### Step 3: Create Pre-commit Hook
**File**: `.husky/pre-commit`

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

echo "🔍 Running pre-commit validation..."

# Run quick validation
npm run validate:quick

echo "✅ Pre-commit validation completed"
```

#### Step 4: Make Hook Executable
```bash
chmod +x .husky/pre-commit
```

### Verification Commands
```bash
# Test pre-commit hook
./.husky/pre-commit

# Test with git (make small change)
echo "# Test" >> .gitignore
git add .gitignore
git commit -m "Test pre-commit hook"
# Should run validation before committing

# Cleanup test
git reset HEAD~1
git checkout .gitignore
```

**Checklist:**
- [ ] .gitignore updated (Husky directory no longer ignored)
- [ ] .husky/pre-commit file created
- [ ] Pre-commit hook executable
- [ ] Hook runs validation before commits
- [ ] Hook prevents commits when validation fails

## 🔧 Fix 3: Cross-Platform Script Compatibility

### Current Issues
Several scripts use Windows-specific commands:

```json
// package.json scripts with issues:
"dev:stop": "powershell -File scripts/dev/cleanup-processes.ps1",
"cleanup": "powershell -File scripts/dev/cleanup-processes.ps1",
"kill-nodes": "scripts/dev/kill-node-processes.bat",
```

### Platform Detection Script
**Create**: `scripts/dev/cleanup-cross-platform.js`

```javascript
#!/usr/bin/env node

const { execSync } = require('child_process');
const os = require('os');

function cleanupProcesses() {
  const platform = os.platform();
  
  console.log(`🧹 Cleaning up Node.js processes on ${platform}...`);
  
  try {
    switch (platform) {
      case 'win32':
        // Windows cleanup
        execSync('taskkill /f /im node.exe 2>nul || echo "No Node processes to kill"', { stdio: 'inherit' });
        execSync('npx kill-port 3000 2>nul || echo "Port 3000 already free"', { stdio: 'inherit' });
        break;
        
      case 'darwin':
      case 'linux':
        // macOS and Linux cleanup
        execSync('pkill -f node || echo "No Node processes to kill"', { stdio: 'inherit' });
        execSync('npx kill-port 3000 || echo "Port 3000 already free"', { stdio: 'inherit' });
        break;
        
      default:
        console.log('Platform not recognized, attempting generic cleanup...');
        execSync('npx kill-port 3000 || echo "Port 3000 cleanup attempted"', { stdio: 'inherit' });
    }
    
    console.log('✅ Process cleanup completed');
  } catch (error) {
    console.error('⚠️  Cleanup encountered issues:', error.message);
    process.exit(1);
  }
}

cleanupProcesses();
```

### Development Server Manager
**Create**: `scripts/dev/dev-server-cross-platform.js`

```javascript
#!/usr/bin/env node

const { spawn, execSync } = require('child_process');
const os = require('os');

function startDevServer() {
  console.log('🚀 Starting development server...');
  
  // First cleanup any existing processes
  try {
    require('./cleanup-cross-platform.js');
  } catch (e) {
    console.log('Cleanup script not available, proceeding...');
  }
  
  // Start Next.js dev server
  const devProcess = spawn('npx', ['next', 'dev', '--turbopack'], {
    stdio: 'inherit',
    shell: true
  });
  
  devProcess.on('close', (code) => {
    console.log(`Dev server exited with code ${code}`);
  });
  
  // Handle process termination
  process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down dev server...');
    devProcess.kill('SIGTERM');
    process.exit(0);
  });
}

startDevServer();
```

### Update package.json Scripts
**File**: `package.json`

```json
{
  "scripts": {
    // Replace these scripts:
    "dev:safe": "node scripts/dev/dev-server-cross-platform.js",
    "dev:stop": "node scripts/dev/cleanup-cross-platform.js", 
    "cleanup": "node scripts/dev/cleanup-cross-platform.js",
    
    // Keep these as alternatives:
    "dev:safe:windows": "bash scripts/dev/dev-server-manager.sh",
    "dev:stop:windows": "powershell -File scripts/dev/cleanup-processes.ps1",
    "kill-nodes:windows": "scripts/dev/kill-node-processes.bat"
  }
}
```

### Verification Commands
```bash
# Test cross-platform cleanup
npm run cleanup

# Test development server start (let it run briefly, then Ctrl+C)
npm run dev:safe

# Test on different platforms (if available)
# Windows: Should work with node processes
# macOS/Linux: Should work with pkill
```

**Checklist:**
- [ ] Cross-platform cleanup script created
- [ ] Cross-platform dev server script created
- [ ] package.json scripts updated
- [ ] Scripts work on current platform
- [ ] Fallback Windows-specific scripts available

## 🔧 Fix 4: Environment Configuration Consistency

### TypeScript Configuration Alignment
**File**: `tsconfig.json`

Ensure all paths are consistent across configurations:

```json
{
  "compilerOptions": {
    // Verify paths are correct
    "paths": {
      "@/*": ["./*"]  // Should point to project root
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx", 
    ".next/types/**/*.ts",
    "types/**/*.d.ts",
    "tests/**/*.ts",  // Ensure tests directory included
    "test/**/*.ts",   // Include both test directories
    "vitest.config.ts"
  ]
}
```

### ESLint Configuration Consistency
**File**: `eslint.config.mjs`

Verify ignore patterns include correct paths:

```javascript
const eslintConfig = [
  {
    ignores: [
      '**/node_modules/**',
      '.next/**',
      'dist/**', 
      'build/**',
      'coverage/**',
      'logs/**',        // Ensure logs ignored
      'scripts/logs/**', // Specific logs path
      '**/*.log',
    ],
  },
  // ... rest of config
];
```

### Environment Variables Documentation
**Create**: `.env.example`

```bash
# Required Environment Variables
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY=your_key
SUPABASE_DB_PASSWORD=your_db_password
GOOGLE_APPLICATION_CREDENTIALS=path_to_service_account_json
NEXT_PUBLIC_POSTHOG_KEY=your_posthog_key

# Development Mode (optional)
MINERVA_DEV_MODE=true
NODE_ENV=development

# Build Optimization (optional)
NODE_OPTIONS=--max-old-space-size=4096
NEXT_TELEMETRY_DISABLED=1
```

**Verification:**
```bash
# Check environment setup
node -e "console.log('Node.js:', process.version); console.log('Platform:', process.platform);"

# Verify TypeScript paths
npx tsc --showConfig | grep -A5 -B5 paths

# Test environment loading
npm run build --dry-run 2>/dev/null || echo "Build config check complete"
```

**Checklist:**
- [ ] TypeScript paths consistent
- [ ] ESLint ignores up to date
- [ ] .env.example created
- [ ] Environment variables documented

## 🔧 Fix 5: Validation Script Consistency

### Update validate-quick.js Path References
**File**: `scripts/maintenance/validate-quick.js`

Ensure validation scripts use correct paths:

```javascript
// Verify test directory scanning
function getAllProjectFiles() {
  // Ensure both test directories are scanned
  if (['tests', 'test', '__tests__'].some(dir => fs.existsSync(dir))) {
    // Include all test directories in scan
  }
}

// Update file type patterns
if (
  !entry.includes('.example') &&
  !entry.endsWith('.md') &&
  !relativePath.includes('logs/') &&
  !relativePath.includes('.git/') &&       // Add .git exclusion
  !relativePath.includes('node_modules/') && // Add node_modules exclusion
  /\.(ts|tsx|js|jsx|json|env|config)$/.test(entry)
) {
  filesToCheck.push(relativePath);
}
```

### Update validate-all.js Consistency
**File**: `scripts/maintenance/validate-all.js`

Ensure consistent behavior with validate-quick.js:

```javascript
// Same file scanning logic as validate-quick.js
// Same path handling
// Same error reporting format
```

### Verification Commands
```bash
# Test validation scripts
npm run validate:quick 2>&1 | tee validation-test.log

# Check for path-related errors
grep -i "not found\|cannot find\|enoent" validation-test.log

# Test file scanning coverage
node -e "
const fs = require('fs');
console.log('test/ exists:', fs.existsSync('test/'));
console.log('tests/ exists:', fs.existsSync('tests/'));
console.log('Files in test/:', fs.readdirSync('test/').length);
console.log('Files in tests/:', fs.readdirSync('tests/').length);
"
```

**Checklist:**
- [ ] validate-quick.js paths updated
- [ ] validate-all.js consistency verified  
- [ ] File scanning includes all test directories
- [ ] Error reporting consistent

## ✅ Configuration Verification & Testing

### Phase 1: Individual Component Testing
```bash
# Test Vitest configuration
npx vitest --run --reporter=verbose tests/setup.ts

# Test pre-commit hooks
echo "# Config test" >> README.md
git add README.md
git commit -m "Test config fixes"
git reset HEAD~1  # Undo test commit
git checkout README.md

# Test cross-platform scripts
npm run cleanup
npm run dev:safe & sleep 5 && pkill -f "next dev" || taskkill /f /im node.exe
```

### Phase 2: Integration Testing  
```bash
# Full validation pipeline
npm run validate:quick

# Build process
npm run build

# Test environment
npm run test
```

### Phase 3: Cross-Platform Verification
```bash
# Platform detection
node -e "console.log('Platform:', process.platform)"

# Script compatibility
npm run cleanup 2>&1 | grep -v "error" || echo "Cleanup script needs review"

# Path resolution
node -e "
const path = require('path');
console.log('Tests path exists:', require('fs').existsSync('./tests'));
console.log('Resolved path:', path.resolve('./tests/setup.ts'));
"
```

### Success Criteria Checklist
- [ ] Vitest loads correct setup file
- [ ] Pre-commit hooks prevent broken commits
- [ ] Scripts work on current platform
- [ ] All configuration paths resolve correctly
- [ ] TypeScript compilation succeeds
- [ ] Validation scripts run without path errors
- [ ] Build process completes successfully

## 🚨 Troubleshooting Guide

### Issue: Vitest can't find setup file
**Symptoms**: `Cannot resolve "./test/setup.ts"`
**Solution**:
1. Verify `tests/setup.ts` exists
2. Update vitest.config.ts path
3. Check file permissions

### Issue: Pre-commit hook fails
**Symptoms**: Hook runs but always fails
**Solution**:
1. Check hook file permissions: `chmod +x .husky/pre-commit`
2. Verify validation command works independently
3. Check for PATH issues in hook environment

### Issue: Cross-platform script fails
**Symptoms**: `powershell: command not found` on macOS/Linux
**Solution**:
1. Verify Node.js replacement scripts are in place
2. Update package.json script references
3. Test platform detection logic

### Issue: Path resolution errors
**Symptoms**: Files not found during validation
**Solution**:
1. Use absolute paths in configuration
2. Check working directory assumptions
3. Verify symbolic links (if any)

## 📊 Post-Configuration Checklist

### Immediate Verification (Same Day)
- [ ] All tests pass
- [ ] Build completes successfully
- [ ] Pre-commit hooks working
- [ ] Cross-platform compatibility verified
- [ ] Validation scripts updated

### Development Workflow Testing (This Week)
- [ ] Developer onboarding works with new setup
- [ ] CI/CD pipeline unaffected
- [ ] Performance impact assessed
- [ ] Documentation updated

### Long-term Monitoring (This Month)
- [ ] No configuration drift
- [ ] Pre-commit hooks remain effective
- [ ] Cross-platform feedback collected
- [ ] Further optimization opportunities identified

---

**Configuration Owner**: Development Team  
**Start Date**: _____________  
**Completion Date**: _____________  
**Status**: Not Started | In Progress | Complete  
**Success Rate**: ___% configurations fixed successfully