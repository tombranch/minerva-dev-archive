# TODO & Placeholder Detection Agent

## Agent Description
Specialized agent that scans code for incomplete implementations, TODOs, placeholders, and temporary code that shouldn't reach production. Ensures code completeness and production readiness.

## Detection Patterns

### 1. TODO Comments

#### 🚨 Critical TODOs (Block Production)
```typescript
// TODO: Implement authentication
// FIXME: Memory leak in photo processing
// HACK: Temporary workaround for API bug
// XXX: This code is broken
// BUG: Race condition in upload
```

#### ⚠️ Standard TODOs (Should Fix)
```typescript
// TODO: Add error handling
// TODO: Optimize performance  
// TODO: Add unit tests
// TODO: Refactor this function
// TODO: Add type safety
```

#### ℹ️ Future TODOs (Document for Later)
```typescript
// TODO: Consider caching strategy
// TODO: Add dark mode support
// TODO: Implement batch operations
// TODO: Add keyboard shortcuts
```

### 2. Placeholder Implementations

#### 🚨 Empty Functions
```typescript
// ❌ Empty implementation
function calculateRisk(): number {
  // TODO: Implement risk calculation
  return 0;
}

// ❌ Placeholder return
function processPhoto(photo: Photo): ProcessResult {
  return null; // placeholder
}

// ❌ Unimplemented async
async function uploadToCloud(file: File): Promise<string> {
  throw new Error('Not implemented');
}
```

#### 🚨 Mock Data
```typescript
// ❌ Hardcoded mock responses
const mockPhotos = [
  { id: '1', name: 'test.jpg' }, // Remove before production
  { id: '2', name: 'sample.png' }
];

// ❌ Development-only data
const DEV_USER = { id: 'dev-user', role: 'admin' };

// ❌ Placeholder API endpoints
const API_URL = 'http://localhost:3000/api'; // Change for production
```

### 3. Temporary Code Patterns

#### 🚨 Debug Code
```typescript
// ❌ Console logs in production
console.log('Debug: Processing photo', photo.id);
console.warn('This should not appear in production');
debugger; // Remove debug statements

// ❌ Development flags
if (process.env.NODE_ENV === 'development') {
  // This logic shouldn't be in production code
}

// ❌ Test data
const isTestMode = true; // Remove test flags
```

#### 🚨 Commented Out Code
```typescript
// ❌ Dead code blocks
/*
function oldImplementation() {
  // This was the old way of doing things
  return legacyProcess();
}
*/

// // Commented out for testing
// validateInput(data);

// ❌ Alternative implementations
function newWay() {
  // return oldWay(); // Remove old implementation
  return improvedWay();
}
```

### 4. Incomplete Error Handling

#### 🚨 Missing Error Cases
```typescript
// ❌ No error handling
async function uploadPhoto(file: File) {
  const result = await api.upload(file);
  return result; // What if upload fails?
}

// ❌ Generic error handling
try {
  await riskyOperation();
} catch (error) {
  // TODO: Handle specific error types
  throw error;
}

// ❌ Swallowed errors
function processData(data: unknown) {
  try {
    return JSON.parse(data as string);
  } catch {
    return {}; // Hiding errors
  }
}
```

### 5. Placeholder Values

#### 🚨 Hardcoded Values
```typescript
// ❌ Magic numbers
const MAX_FILE_SIZE = 5000000; // TODO: Make configurable
const RETRY_ATTEMPTS = 3; // Should be in config

// ❌ Placeholder strings
const DEFAULT_MESSAGE = 'Lorem ipsum dolor sit amet';
const PLACEHOLDER_URL = 'https://example.com/placeholder';

// ❌ Temporary IDs
const TEMP_USER_ID = 'temp-user-123';
const DEFAULT_PROJECT_ID = 'default-project';
```

## Detection Rules

### 1. Comment Pattern Matching
```regex
// High Priority Patterns
/TODO|FIXME|HACK|XXX|BUG/i

// Standard TODO Patterns  
/TODO:/i
/FIXME:/i
/NOTE:/i

// Development Markers
/DEBUG|TEST|TEMP|PLACEHOLDER/i
```

### 2. Code Pattern Detection
```typescript
// Empty function bodies
function.*\{\s*(\/\/.*\n)?\s*\}

// Placeholder returns
return\s+(null|undefined|0|false|\[\]|\{\})\s*;?\s*\/\/.*placeholder

// Throw not implemented
throw\s+new\s+Error\s*\(\s*['"](Not implemented|TODO)/i

// Console statements
console\.(log|warn|error|debug)

// Debugger statements
debugger\s*;
```

### 3. Configuration Issues
```typescript
// Development URLs
http://localhost
127.0.0.1
0.0.0.0

// Test credentials
test@example.com
password123
api-key-123

// Development flags
NODE_ENV.*development
DEBUG.*true
TEST_MODE.*true
```

## Severity Classifications

### 🚨 Critical (Block Production)
- Security placeholders (API keys, passwords)
- Empty core business logic functions
- Unhandled error cases in critical paths
- Debug/test code that exposes sensitive data
- Broken authentication/authorization

### ⚠️ High Priority (Fix Before Merge)
- TODOs in main application flow
- Missing error handling in user-facing features
- Placeholder UI text visible to users
- Incomplete validation logic
- Missing null checks

### 📝 Medium Priority (Address Soon)
- Performance TODOs
- Code organization improvements
- Missing unit tests
- Documentation gaps
- Refactoring opportunities

### ℹ️ Low Priority (Track for Future)
- Enhancement ideas
- Optimization opportunities
- Future feature placeholders
- Code style improvements

## Scanning Strategies

### 1. File-Based Scanning
```typescript
// Scan specific file types
const scanPatterns = [
  '**/*.ts',
  '**/*.tsx', 
  '**/*.js',
  '**/*.jsx',
  '**/*.vue',
  '**/*.svelte'
];

// Exclude patterns
const excludePatterns = [
  'node_modules/**',
  'dist/**',
  '*.test.*',
  '*.spec.*',
  'dev/**' // Development documentation
];
```

### 2. Context-Aware Detection
```typescript
// Different rules for different contexts
const productionFiles = [
  'app/**',
  'lib/**', 
  'components/**'
];

const testFiles = [
  '**/*.test.*',
  '**/*.spec.*',
  'tests/**',
  'e2e/**'
];

// More lenient rules for test files
// Stricter rules for production code
```

### 3. Integration Points
```typescript
// API routes - critical
'app/api/**/*.ts'

// Components - user-facing
'components/**/*.tsx'

// Database - data integrity
'lib/db/**/*.ts'

// Authentication - security critical
'lib/auth/**/*.ts'
```

## Report Format

### Summary Report
```markdown
## Code Completeness Audit

### Overview
- Files scanned: 156
- Total issues found: 23
- Critical issues: 3
- Production blockers: 1

### 🚨 Critical Issues (3)
1. **app/api/auth/route.ts:45** - Empty authentication function
2. **lib/db/migrations.ts:12** - TODO: Add error handling for migration failures
3. **components/PhotoUpload.tsx:89** - Placeholder API endpoint in production code

### ⚠️ High Priority (8)
1. **app/api/photos/route.ts:23** - Missing input validation
2. **components/Dashboard.tsx:156** - TODO: Add loading states
3. **lib/utils/image-processing.ts:78** - Hardcoded max file size

### 📝 Medium Priority (12)
- Performance optimization TODOs: 5
- Missing error handling: 4  
- Code refactoring notes: 3

### Recommendations
1. **Immediate Action**: Fix critical authentication gap
2. **Before Merge**: Address all high priority items
3. **Next Sprint**: Plan medium priority improvements
```

### Detailed Issue Report
```markdown
## Issue Details

### 🚨 CRITICAL: Empty Authentication Function
**File**: `app/api/auth/route.ts:45`
**Line**: `function validateToken(token: string): boolean {`
**Issue**: Function body is empty with TODO comment
**Impact**: Authentication bypass vulnerability
**Action**: Implement token validation immediately

### ⚠️ HIGH: Missing Input Validation  
**File**: `app/api/photos/route.ts:23`
**Code**: 
```typescript
export async function POST(request: Request) {
  const data = await request.json();
  // TODO: Add validation
  return processPhoto(data);
}
```
**Issue**: No input validation on photo upload endpoint
**Risk**: Potential data corruption or security issues
**Suggestion**: Add Zod schema validation
```

## Integration with Development Workflow

### 1. Pre-Commit Hooks
```bash
# Check for production blockers
npm run check:todos:critical

# Scan staged files only
npm run check:todos:staged
```

### 2. CI/CD Pipeline
```yaml
# GitHub Actions integration
- name: Scan for TODOs and Placeholders
  run: npm run check:todos:production
  if: github.ref == 'refs/heads/main'
```

### 3. IDE Integration
```json
// VS Code settings
{
  "todo-tree.regex.regex": "((//|#|<!--|;|/\\*|^)\\s*($TAGS)|^\\s*- \\[ \\])",
  "todo-tree.general.tags": [
    "TODO",
    "FIXME", 
    "HACK",
    "XXX",
    "BUG",
    "PLACEHOLDER"
  ]
}
```

## Best Practices

### ✅ Good TODO Practices
```typescript
// ✅ Specific and actionable
// TODO: Replace with proper error boundary component (Issue #123)

// ✅ Include context and priority
// TODO: [P1] Add retry logic for network failures - needed for reliability

// ✅ Reference tracking system
// TODO: Implement caching (Story: USER-456)
```

### ❌ Poor TODO Practices
```typescript
// ❌ Vague and unhelpful
// TODO: Fix this

// ❌ No priority or context
// TODO: Make better

// ❌ Left indefinitely
// TODO: This was added 6 months ago
```

This agent ensures code reaches production only when it's complete, properly implemented, and free of development artifacts.