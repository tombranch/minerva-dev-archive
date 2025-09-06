# Claude Code Quality Hooks - Enhanced Implementation Plan

## Executive Summary

This document outlines the comprehensive implementation of an advanced Claude Code hook system designed to prevent technical debt accumulation and enforce code quality standards. The enhanced hooks will transform the development workflow from reactive cleanup (like the current Phase 3 effort) to proactive quality assurance.

### Key Benefits
- **Prevent Technical Debt**: Stop issues before they accumulate
- **Enforce Standards**: Automatic type safety, reusability, and security checks
- **Reduce Manual Review**: Automated detection of incomplete work and anti-patterns
- **Improve Developer Experience**: Real-time feedback and guidance
- **Maintain Code Quality**: Consistent enforcement across all development sessions

## Current State Analysis

### Existing Hook System (Backup Configuration)
✅ **Working Components**:
- SessionStart initialization hooks
- PostToolUse file quality checking
- TypeScript incremental validation
- Command logging for audit trails
- Quality reporting at session end
- UserPromptSubmit validation for `any` types

❌ **Missing Components**:
- Hook script files don't exist in `C:\Users\Tom\.claude\hooks\`
- No mock data or TODO detection
- No component duplication prevention
- No breaking change detection
- No performance impact monitoring
- No security pattern validation

### Current Cleanup Context
- **879 TypeScript files** with ~700+ ESLint errors and ~2,500+ TypeScript errors
- Primary issues: `any` type usage (~500+ errors), unused variables (~100+ errors)
- Hooks temporarily disabled to allow cleanup
- Target: <50 total errors before re-enabling

## Phase-by-Phase Implementation

### Phase 1: Foundation Restoration (2-3 hours)
**Objective**: Restore basic hook functionality with existing scripts

#### Step 1.1: Create Missing Hook Scripts Directory
```powershell
# Create hooks directory
New-Item -ItemType Directory -Path "C:\Users\Tom\.claude\hooks" -Force
```

#### Step 1.2: Implement Core Hook Scripts

**1. session-init.ps1**
```powershell
# Initialize caches and validate environment
param($toolInput)

Write-Host "🚀 Claude Code Session Starting - Minerva Project"

# Initialize quality metrics cache
$cacheDir = "$env:USERPROFILE\.claude\cache"
New-Item -ItemType Directory -Path $cacheDir -Force

# Validate project environment
$projectRoot = "C:\Users\Tom\dev\minerva"
if (Test-Path "$projectRoot\package.json") {
    Write-Host "✅ Project environment validated"
    
    # Quick health check
    $nodeModules = Test-Path "$projectRoot\node_modules"
    $envFile = Test-Path "$projectRoot\.env.local" 
    
    Write-Host "📦 Dependencies: $(if($nodeModules){'✅'}else{'❌'})"
    Write-Host "🔧 Environment: $(if($envFile){'✅'}else{'❌'})"
} else {
    Write-Host "❌ Project root not found"
}

# Log session start
$logFile = "$env:USERPROFILE\.claude\logs\session.log"
New-Item -ItemType Directory -Path (Split-Path $logFile) -Force
Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Session started"
```

**2. check-file-quality.ps1**
```powershell
# File quality checker for post-edit validation
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    
    # Skip non-TypeScript files and test files
    if ($filePath -notmatch "\.(ts|tsx|js|jsx)$" -or $filePath -match "(test|spec|\.d\.ts)") {
        exit 0
    }
    
    $issues = @()
    
    # Check if file exists and read content
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        
        # Check for any types
        if ($content -match "\b(any)\b" -and $content -notmatch "// @ts-ignore|// eslint-disable") {
            $issues += "❌ Found 'any' type usage - violates TypeScript strict policy"
        }
        
        # Check for console.log (should use logger)
        if ($content -match "console\.(log|warn|error)" -and $filePath -notmatch "(dev|debug|test)") {
            $issues += "⚠️  Found console.log usage - consider using logger service"
        }
        
        # Check for TODO/FIXME comments
        if ($content -match "(?i)(TODO|FIXME|HACK|XXX)") {
            $issues += "📝 Found TODO/FIXME comments - ensure completion tracking"
        }
    }
    
    # Output results if issues found
    if ($issues.Count -gt 0) {
        @{
            continue = $true
            message = "File Quality Check:`n" + ($issues -join "`n")
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    # Log error but don't block workflow
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): check-file-quality error - $_"
}
```

**3. type-check-incremental.ps1**
```powershell
# Incremental TypeScript checking
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    
    # Only check TypeScript files
    if ($filePath -notmatch "\.(ts|tsx)$") { exit 0 }
    
    $projectRoot = "C:\Users\Tom\dev\minerva"
    Push-Location $projectRoot
    
    # Quick type check on specific file
    $result = & npx tsc --noEmit --skipLibCheck $filePath 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        $errors = $result | Where-Object { $_ -match "error TS" } | Select-Object -First 3
        if ($errors) {
            @{
                continue = $true
                message = "TypeScript Errors:`n" + ($errors -join "`n")
                suppressOutput = $false
            } | ConvertTo-Json -Compress
        }
    }
    
    Pop-Location
}
catch {
    Pop-Location
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): type-check error - $_"
}
```

**4. log-commands.ps1**
```powershell
# Command logging for audit trail
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $command = $input.command
    
    # Log all bash commands
    $logFile = "$env:USERPROFILE\.claude\logs\bash-commands.log"
    New-Item -ItemType Directory -Path (Split-Path $logFile) -Force
    
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $command"
    Add-Content -Path $logFile -Value $logEntry
    
    # Warn about potentially dangerous commands
    $dangerousPatterns = @("rm -rf", "del /f", "rmdir /s", "DROP TABLE", "DELETE FROM")
    $foundDangerous = $dangerousPatterns | Where-Object { $command -match [regex]::Escape($_) }
    
    if ($foundDangerous) {
        @{
            continue = $true
            message = "⚠️  Dangerous command detected: $command`nPlease review carefully before execution."
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    # Don't block command execution on logging errors
}
```

**5. quality-report.ps1**
```powershell
# Session end quality report
param($toolInput)

Write-Host "📊 Session Quality Report"

$projectRoot = "C:\Users\Tom\dev\minerva"
$logFile = "$env:USERPROFILE\.claude\logs\session-quality.log"

try {
    Push-Location $projectRoot
    
    # Quick lint check
    $lintResult = & npm run lint --silent 2>&1
    $lintErrors = ($lintResult | Measure-Object).Count
    
    # Type check
    $typeResult = & npx tsc --noEmit --skipLibCheck 2>&1
    $typeErrors = ($typeResult | Where-Object { $_ -match "error TS" } | Measure-Object).Count
    
    $report = @"
Session End Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
ESLint Errors: $lintErrors
TypeScript Errors: $typeErrors
Status: $(if($lintErrors -eq 0 -and $typeErrors -eq 0){'✅ Clean'}else{'⚠️ Issues Detected'})
"@
    
    Write-Host $report
    Add-Content -Path $logFile -Value $report
    
    Pop-Location
}
catch {
    Pop-Location
    Write-Host "❌ Error generating quality report"
}
```

#### Step 1.3: Test Basic Hook Functionality
- Create test file with intentional issues
- Verify hooks trigger correctly
- Validate error reporting works
- Test hook disable/enable cycle

### Phase 2: Enhanced Detection Hooks (4-5 hours)
**Objective**: Implement advanced code quality detection

#### Step 2.1: Mock Data/TODO Detection Hook

**detect-incomplete-work.ps1**
```powershell
# Smart detection of incomplete work, mock data, and placeholders
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    
    # Skip test files, config files, documentation
    if ($filePath -match "(test|spec|config|\.md$|\.json$)" -or $filePath -notmatch "\.(ts|tsx|js|jsx)$") {
        exit 0
    }
    
    # Skip if file is too small (likely utility)
    if ((Get-Item $filePath).Length -lt 200) { exit 0 }
    
    $content = Get-Content $filePath -Raw
    $issues = @()
    
    # TODO/FIXME pattern detection
    $todoPatterns = @("TODO:", "FIXME:", "HACK:", "XXX:", "NOTE:", "BUG:")
    foreach ($pattern in $todoPatterns) {
        if ($content -match "(?i)$pattern") {
            $matches = [regex]::Matches($content, "(?i)$pattern.*", [System.Text.RegularExpressions.RegexOptions]::Multiline)
            $issues += "📝 Found $($matches.Count) $pattern comment(s) - ensure tracking completion"
        }
    }
    
    # Mock data detection
    $mockPatterns = @(
        "mockData\s*[=:]",
        "sampleData\s*[=:]", 
        "testData\s*[=:]",
        "placeholder\w*\s*[=:]",
        "dummy\w*\s*[=:]"
    )
    foreach ($pattern in $mockPatterns) {
        if ($content -match $pattern) {
            $issues += "🎭 Mock/sample data detected - replace with real data source"
        }
    }
    
    # Placeholder implementation patterns
    $placeholderPatterns = @(
        'throw new Error\(["\']Not implemented',
        'throw new Error\(["\']TODO',
        'return null; // TODO',
        'console\.log\(["\']TODO',
        '// Placeholder implementation'
    )
    foreach ($pattern in $placeholderPatterns) {
        if ($content -match $pattern) {
            $issues += "🚧 Placeholder implementation found - needs actual logic"
        }
    }
    
    # Hardcoded values that should be configurable
    $hardcodedPatterns = @(
        'userId:\s*["\'][\w-]{8,}["\']',
        'token:\s*["\'][a-zA-Z0-9]{10,}["\']',
        'apiKey:\s*["\'][a-zA-Z0-9]{10,}["\']',
        'localhost:\d+',
        'http://[^"\']*' # HTTP URLs in production code
    )
    foreach ($pattern in $hardcodedPatterns) {
        if ($content -match $pattern) {
            $issues += "🔧 Hardcoded value detected - consider moving to configuration"
        }
    }
    
    # Incomplete conditionals
    if ($content -match 'if\s*\(\s*false\s*\)' -or $content -match 'if\s*\(\s*true\s*\)') {
        $issues += "❓ Hardcoded boolean condition found - review logic"
    }
    
    # Development/debug code
    if ($content -match 'debugger;' -and $filePath -notmatch "(dev|debug)") {
        $issues += "🐛 Debugger statement found in production code"
    }
    
    # Output results with context
    if ($issues.Count -gt 0) {
        $fileName = Split-Path $filePath -Leaf
        @{
            continue = $true
            message = "Development Quality Check ($fileName):`n" + ($issues -join "`n")
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): detect-incomplete-work error - $_"
}
```

#### Step 2.2: Component Duplication Detector

**enforce-reusability.ps1**
```powershell
# Detect duplicate components and enforce reusability
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    
    # Only check when creating new components
    if ($input.tool_name -ne "Write" -or $filePath -notmatch "components.*\.(tsx|ts)$") {
        exit 0
    }
    
    $content = Get-Content $filePath -Raw
    $issues = @()
    
    # Extract component name
    $componentMatch = [regex]::Match($content, "(?:export\s+(?:default\s+)?(?:function|const)\s+|function\s+)(\w+)")
    if (-not $componentMatch.Success) { exit 0 }
    
    $newComponentName = $componentMatch.Groups[1].Value
    
    # Search for similar components
    $projectRoot = "C:\Users\Tom\dev\minerva"
    $componentFiles = Get-ChildItem -Path "$projectRoot\components" -Recurse -Include "*.tsx" | Where-Object { $_.FullName -ne $filePath }
    
    foreach ($file in $componentFiles) {
        $existingContent = Get-Content $file.FullName -Raw
        
        # Check for similar component names
        if ($file.BaseName -like "*$newComponentName*" -or $newComponentName -like "*$($file.BaseName)*") {
            $issues += "🔄 Similar component found: $($file.Name) - consider reusing or extending"
        }
        
        # Basic structural similarity check (similar JSX patterns)
        $newJSX = [regex]::Matches($content, "<(\w+)[^>]*>") | ForEach-Object { $_.Groups[1].Value }
        $existingJSX = [regex]::Matches($existingContent, "<(\w+)[^>]*>") | ForEach-Object { $_.Groups[1].Value }
        
        if ($newJSX -and $existingJSX) {
            $commonElements = Compare-Object $newJSX $existingJSX -IncludeEqual | Where-Object { $_.SideIndicator -eq "==" }
            if ($commonElements.Count -gt 3) {
                $issues += "🎯 Structurally similar component: $($file.Name) - review for reusability"
            }
        }
    }
    
    # Check for reinventing existing shadcn/ui components
    $shadcnComponents = @("Button", "Input", "Card", "Dialog", "Alert", "Badge", "Checkbox", "Select", "Table", "Tabs")
    foreach ($component in $shadcnComponents) {
        if ($newComponentName -like "*$component*" -and $content -notmatch "from.*ui/$component") {
            $issues += "📦 Consider using existing shadcn/ui $component instead of custom implementation"
        }
    }
    
    if ($issues.Count -gt 0) {
        @{
            continue = $true
            message = "Component Reusability Check:`n" + ($issues -join "`n")
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): enforce-reusability error - $_"
}
```

#### Step 2.3: Breaking Change Detector

**detect-breaking-changes.ps1**
```powershell
# Detect potential breaking changes in APIs and exports
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    $toolName = $input.tool_name
    
    # Only check edits to existing files
    if ($toolName -ne "Edit" -and $toolName -ne "MultiEdit") { exit 0 }
    
    # Skip test files
    if ($filePath -match "(test|spec)") { exit 0 }
    
    $issues = @()
    
    # Get current content
    $currentContent = Get-Content $filePath -Raw
    
    # Check for removed exports
    $projectRoot = "C:\Users\Tom\dev\minerva"
    Push-Location $projectRoot
    
    # Use git to get previous version
    $previousContent = & git show "HEAD:$($filePath.Replace($projectRoot + '\', '').Replace('\', '/'))" 2>$null
    
    if ($previousContent) {
        # Find removed exports
        $prevExports = [regex]::Matches($previousContent, "export\s+(?:default\s+)?(?:function|const|class|interface|type)\s+(\w+)") | ForEach-Object { $_.Groups[1].Value }
        $currentExports = [regex]::Matches($currentContent, "export\s+(?:default\s+)?(?:function|const|class|interface|type)\s+(\w+)") | ForEach-Object { $_.Groups[1].Value }
        
        $removedExports = $prevExports | Where-Object { $_ -notin $currentExports }
        if ($removedExports) {
            $issues += "⚠️ Removed exports detected: $($removedExports -join ', ') - potential breaking change"
        }
        
        # Check for changed function signatures
        $prevFunctions = [regex]::Matches($previousContent, "(?:export\s+)?function\s+(\w+)\s*\([^)]*\)")
        $currentFunctions = [regex]::Matches($currentContent, "(?:export\s+)?function\s+(\w+)\s*\([^)]*\)")
        
        foreach ($prevFunc in $prevFunctions) {
            $funcName = $prevFunc.Groups[1].Value
            $currentFunc = $currentFunctions | Where-Object { $_.Groups[1].Value -eq $funcName }
            
            if ($currentFunc -and $prevFunc.Value -ne $currentFunc.Value) {
                $issues += "🔄 Function signature changed: $funcName - verify backward compatibility"
            }
        }
        
        # Check for removed/changed interfaces
        $prevInterfaces = [regex]::Matches($previousContent, "interface\s+(\w+)")
        $currentInterfaces = [regex]::Matches($currentContent, "interface\s+(\w+)")
        
        $removedInterfaces = $prevInterfaces | Where-Object { $_.Groups[1].Value -notin ($currentInterfaces | ForEach-Object { $_.Groups[1].Value }) }
        if ($removedInterfaces) {
            $issues += "📋 Removed interfaces: $($removedInterfaces.Groups[1].Value -join ', ') - check dependent code"
        }
    }
    
    Pop-Location
    
    if ($issues.Count -gt 0) {
        @{
            continue = $true
            message = "Breaking Change Detection:`n" + ($issues -join "`n")
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    Pop-Location -ErrorAction SilentlyContinue
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): detect-breaking-changes error - $_"
}
```

### Phase 3: Advanced Quality Hooks (3-4 hours)
**Objective**: Implement security, performance, and documentation hooks

#### Step 3.1: Security Pattern Validator

**security-check.ps1**
```powershell
# Security pattern validation and vulnerability detection
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    
    # Skip test files but check all code files
    if ($filePath -match "(test|spec)" -or $filePath -notmatch "\.(ts|tsx|js|jsx)$") { exit 0 }
    
    $content = Get-Content $filePath -Raw
    $issues = @()
    
    # Hardcoded secrets detection
    $secretPatterns = @(
        'password\s*[:=]\s*["\'][^"\']{8,}["\']',
        'secret\s*[:=]\s*["\'][^"\']{10,}["\']',
        'token\s*[:=]\s*["\'][a-zA-Z0-9]{20,}["\']',
        'key\s*[:=]\s*["\'][a-zA-Z0-9]{16,}["\']',
        'sk_[a-zA-Z0-9]{24,}', # Stripe secret keys
        'pk_[a-zA-Z0-9]{24,}', # Stripe publishable keys
        'AKIA[0-9A-Z]{16}' # AWS access keys
    )
    foreach ($pattern in $secretPatterns) {
        if ($content -match $pattern) {
            $issues += "🚨 CRITICAL: Potential hardcoded secret detected - move to environment variables"
        }
    }
    
    # SQL Injection risks
    if ($content -match '\$\{.*\}.*SELECT|SELECT.*\$\{.*\}' -or 
        $content -match 'query.*\+.*user|user.*\+.*query') {
        $issues += "💉 SQL Injection risk detected - use parameterized queries"
    }
    
    # Insecure HTTP usage
    if ($content -match 'http://(?!localhost)' -and $filePath -notmatch "(dev|test)") {
        $issues += "🔒 HTTP URLs detected in production code - use HTTPS"
    }
    
    # Dangerous eval usage
    if ($content -match '\beval\s*\(|Function\s*\(' -and $content -notmatch '// @security-reviewed') {
        $issues += "⚡ Dangerous eval/Function usage - potential code injection vector"
    }
    
    # Missing authentication patterns
    if ($filePath -match "app\\api" -and $content -notmatch "(auth|session|jwt|bearer)" -and 
        $content -match "export.*function.*(GET|POST|PUT|DELETE)" -and 
        $content -notmatch "// @public-endpoint") {
        $issues += "🔐 API endpoint missing authentication - add auth check or @public-endpoint comment"
    }
    
    # Insecure randomness
    if ($content -match 'Math\.random\(\)' -and $content -match "(password|token|session|id)" -and 
        $content -notmatch "crypto\.random") {
        $issues += "🎲 Insecure randomness for sensitive values - use crypto.randomBytes()"
    }
    
    # Unsafe innerHTML usage
    if ($content -match 'innerHTML\s*=' -and $content -notmatch "DOMPurify") {
        $issues += "🕸️ Unsafe innerHTML usage - potential XSS vulnerability, use DOMPurify"
    }
    
    # Missing CSRF protection patterns
    if ($filePath -match "app\\api" -and $content -match "POST|PUT|DELETE" -and 
        $content -notmatch "(csrf|xsrf|origin|referer)" -and 
        $content -notmatch "// @csrf-exempt") {
        $issues += "🛡️ API endpoint missing CSRF protection - verify origin/referer or add @csrf-exempt"
    }
    
    if ($issues.Count -gt 0) {
        @{
            continue = $true
            message = "🔒 Security Check - REVIEW IMMEDIATELY:`n" + ($issues -join "`n")
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): security-check error - $_"
}
```

#### Step 3.2: Performance Impact Monitor

**check-performance-impact.ps1**
```powershell
# Monitor performance-impacting changes
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    
    # Skip test files
    if ($filePath -match "(test|spec)" -or $filePath -notmatch "\.(ts|tsx|js|jsx)$") { exit 0 }
    
    $content = Get-Content $filePath -Raw
    $issues = @()
    
    # Large imports that could impact bundle size
    $expensiveImports = @("moment", "lodash", "axios", "^react$", "^date-fns$")
    foreach ($import in $expensiveImports) {
        if ($content -match "import.*from ['\"]$import['\"]" -and 
            $content -notmatch "import.*{.*}.*from ['\"]$import['\"]") {
            $issues += "📦 Large import detected: $import - consider tree-shaking or alternatives"
        }
    }
    
    # Expensive operations in render loops
    if ($content -match "useEffect|useMemo|useCallback" -and 
        $content -match "(fetch|axios|localStorage|JSON\.parse)" -and 
        $content -notmatch "\[\]|\[.*dependency.*\]") {
        $issues += "🔄 Expensive operation in render - add dependency array or move outside"
    }
    
    # Missing React.memo or useMemo for expensive computations
    if ($content -match "export.*function.*Component" -and 
        $content -match "(\.map\(|\.filter\(|\.reduce\()" -and 
        $content -notmatch "(memo|useMemo)" -and 
        (Get-Item $filePath).Length -gt 2000) {
        $issues += "⚡ Large component with array operations - consider React.memo or useMemo"
    }
    
    # Inefficient state updates
    if ($content -match "setState.*\+\+|setState.*--" -or 
        $content -match "useState.*\.push\(|useState.*\.splice\(") {
        $issues += "🔄 Inefficient state update pattern - use functional updates or proper immutable patterns"
    }
    
    # Missing key props in lists
    if ($content -match "\.map\(" -and $content -match "<\w+" -and 
        $content -notmatch "key=") {
        $issues += "🗝️ Missing key prop in mapped components - will cause re-render issues"
    }
    
    # Synchronous localStorage/sessionStorage in components
    if ($content -match "(localStorage|sessionStorage)\.(get|set)Item" -and 
        $content -notmatch "(useEffect|useCallback|useMemo)" -and 
        $content -match "function.*Component|export.*function") {
        $issues += "💾 Synchronous storage access in render - move to useEffect or custom hook"
    }
    
    # File size warning
    $fileSize = (Get-Item $filePath).Length
    if ($fileSize -gt 10000) {  # 10KB
        $issues += "📄 Large file size ($([math]::Round($fileSize/1024, 1))KB) - consider splitting into smaller modules"
    }
    
    if ($issues.Count -gt 0) {
        @{
            continue = $true
            message = "⚡ Performance Impact Check:`n" + ($issues -join "`n")
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): check-performance-impact error - $_"
}
```

#### Step 3.3: Documentation Completeness Check

**doc-completeness.ps1**
```powershell
# Check documentation completeness for public APIs
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    
    # Focus on library files and components
    if ($filePath -notmatch "(lib|components)" -or $filePath -notmatch "\.(ts|tsx)$") { exit 0 }
    
    $content = Get-Content $filePath -Raw
    $issues = @()
    
    # Check for exported functions without JSDoc
    $exportedFunctions = [regex]::Matches($content, "export\s+(?:async\s+)?function\s+(\w+)")
    foreach ($func in $exportedFunctions) {
        $funcName = $func.Groups[1].Value
        $funcStart = $func.Index
        
        # Look for JSDoc comment before function
        $beforeFunc = $content.Substring(0, $funcStart)
        if ($beforeFunc -notmatch "/\*\*[\s\S]*?\*/" -and 
            $beforeFunc -notmatch "//.*$funcName.*description" -and 
            $funcName -notmatch "(test|spec|mock)") {
            $issues += "📚 Exported function '$funcName' missing JSDoc documentation"
        }
    }
    
    # Check for exported interfaces/types without comments
    $exportedTypes = [regex]::Matches($content, "export\s+(interface|type)\s+(\w+)")
    foreach ($type in $exportedTypes) {
        $typeName = $type.Groups[2].Value
        $typeStart = $type.Index
        
        $beforeType = $content.Substring(0, $typeStart)
        if ($beforeType -notmatch "/\*\*[\s\S]*?\*/" -and 
            $beforeType -notmatch "//.*$typeName.*") {
            $issues += "📋 Exported type '$typeName' missing documentation"
        }
    }
    
    # Check for React components without prop documentation
    if ($filePath -match "components.*\.tsx$") {
        $componentMatch = [regex]::Match($content, "(?:export\s+(?:default\s+)?)?function\s+(\w+)\s*\(\s*(\w+)?\s*:")
        if ($componentMatch.Success) {
            $componentName = $componentMatch.Groups[1].Value
            $propsParam = $componentMatch.Groups[2].Value
            
            if ($propsParam -and $content -notmatch "/\*\*[\s\S]*?@param.*$propsParam") {
                $issues += "⚛️ React component '$componentName' props not documented"
            }
        }
    }
    
    # Check for complex utility functions without examples
    $complexFunctions = [regex]::Matches($content, "export\s+function\s+(\w+)[^{]*{[^}]{200,}}")
    foreach ($func in $complexFunctions) {
        $funcName = $func.Groups[1].Value
        if ($content -notmatch "@example[\s\S]*?$funcName" -and 
            $funcName -notmatch "(test|spec|mock)") {
            $issues += "💡 Complex function '$funcName' would benefit from usage examples"
        }
    }
    
    # Check if README needs updating for new features
    if ($input.tool_name -eq "Write" -and $filePath -match "components" -and 
        $content -match "export.*function.*Component") {
        $readmePath = "C:\Users\Tom\dev\minerva\README.md"
        if (Test-Path $readmePath) {
            $readme = Get-Content $readmePath -Raw
            $componentName = [regex]::Match($content, "export.*function\s+(\w+)").Groups[1].Value
            if ($readme -notmatch $componentName) {
                $issues += "📖 New component '$componentName' may need README documentation"
            }
        }
    }
    
    if ($issues.Count -gt 0) {
        @{
            continue = $true
            message = "📚 Documentation Completeness Check:`n" + ($issues -join "`n")
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): doc-completeness error - $_"
}
```

### Phase 4: Integration & Smart Context (2-3 hours)
**Objective**: Add context awareness and intelligent triggering

#### Step 4.1: Git Context Awareness Hook

**git-context-check.ps1**
```powershell
# Git context awareness for branch-specific rules
param($toolInput)

try {
    $input = $toolInput | ConvertFrom-Json
    $filePath = $input.file_path
    
    $projectRoot = "C:\Users\Tom\dev\minerva"
    Push-Location $projectRoot
    
    $issues = @()
    
    # Get current branch
    $currentBranch = & git branch --show-current 2>$null
    if (-not $currentBranch) { 
        Pop-Location
        exit 0 
    }
    
    # Check if editing files on wrong branch
    if ($currentBranch -eq "main" -and $input.tool_name -match "Write|Edit" -and 
        $filePath -notmatch "(README|CHANGELOG|package\.json)") {
        $issues += "🌟 Working directly on main branch - consider creating feature branch"
    }
    
    # Check for uncommitted changes when switching contexts
    $uncommittedChanges = & git status --porcelain 2>$null
    if ($uncommittedChanges -and $input.tool_name -eq "Write") {
        $changeCount = ($uncommittedChanges | Measure-Object).Count
        if ($changeCount -gt 5) {
            $issues += "📝 $changeCount uncommitted changes - consider committing current work"
        }
    }
    
    # Branch naming convention check
    if ($currentBranch -notmatch "^(feature|fix|refactor|docs)\/[a-z0-9-]+$" -and 
        $currentBranch -ne "main" -and $currentBranch -ne "develop") {
        $issues += "📛 Branch name '$currentBranch' doesn't follow convention (feature/fix/refactor/docs/name)"
    }
    
    # Check if working on multiple features simultaneously
    $modifiedFiles = & git diff --name-only HEAD 2>$null
    if ($modifiedFiles) {
        $directories = $modifiedFiles | ForEach-Object { Split-Path $_ -Parent } | Sort-Object -Unique
        if ($directories.Count -gt 3) {
            $issues += "🎯 Changes span multiple directories - consider smaller, focused commits"
        }
    }
    
    # Prevent direct edits to critical files on feature branches
    if ($currentBranch -match "^feature\/" -and 
        $filePath -match "(package\.json|tsconfig\.json|\.env)" -and 
        $input.tool_name -match "Edit|Write") {
        $issues += "⚠️ Editing configuration files on feature branch - ensure these changes are intentional"
    }
    
    Pop-Location
    
    if ($issues.Count -gt 0) {
        @{
            continue = $true
            message = "🌿 Git Context Check:`n" + ($issues -join "`n")
            suppressOutput = $false
        } | ConvertTo-Json -Compress
    }
}
catch {
    Pop-Location -ErrorAction SilentlyContinue
    Add-Content -Path "$env:USERPROFILE\.claude\logs\hook-errors.log" -Value "$(Get-Date): git-context-check error - $_"
}
```

#### Step 4.2: Enhanced Hook Configuration

**Updated settings.json Template:**
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\session-init.ps1\"",
        "timeout": 30000
      }]
    }],
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\check-file-quality.ps1\"",
            "timeout": 15000
          },
          {
            "type": "command", 
            "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\detect-incomplete-work.ps1\"",
            "timeout": 12000
          },
          {
            "type": "command",
            "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\security-check.ps1\"",
            "timeout": 10000
          },
          {
            "type": "command",
            "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\check-performance-impact.ps1\"",
            "timeout": 8000
          },
          {
            "type": "command",
            "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\git-context-check.ps1\"",
            "timeout": 5000
          }
        ]
      },
      {
        "matcher": "Edit|MultiEdit",
        "hooks": [{
          "type": "command",
          "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\type-check-incremental.ps1\"",
          "timeout": 15000
        }, {
          "type": "command",
          "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\detect-breaking-changes.ps1\"",
          "timeout": 10000
        }]
      },
      {
        "matcher": "Write",
        "hooks": [{
          "type": "command",
          "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\enforce-reusability.ps1\"",
          "timeout": 12000
        }, {
          "type": "command",
          "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\doc-completeness.ps1\"",
          "timeout": 8000
        }]
      }
    ],
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\log-commands.ps1\"",
        "timeout": 3000
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "powershell -File \"C:\\Users\\Tom\\.claude\\hooks\\quality-report.ps1\"",
        "timeout": 10000
      }]
    }],
    "UserPromptSubmit": [{
      "hooks": [{
        "type": "command",
        "command": "powershell -Command \"$input = [Console]::In.ReadToEnd() | ConvertFrom-Json; $prompt = $input.prompt.ToLower(); $issues = @(); if ($prompt -match 'any type|use any') { $issues += 'Reminder: Never use \\`any\\` type in TypeScript. Use proper types or \\`unknown\\` with type guards.' } if ($prompt -match 'delete|remove|rm -rf') { $issues += 'Caution: Review deletion commands carefully before execution.' } if ($prompt -match 'todo|fixme|placeholder') { $issues += 'Reminder: Ensure TODO/placeholder items are tracked for completion.' } if ($issues.Count -gt 0) { @{continue=$true; message=($issues -join '\\`n'); suppressOutput=$false} | ConvertTo-Json -Compress } else { @{continue=$true; suppressOutput=$true} | ConvertTo-Json -Compress }\"",
        "timeout": 2000
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(npm run lint*)",
      "Bash(npm run format*)", 
      "Bash(npx tsc*)",
      "Bash(npx eslint*)",
      "Bash(npx prettier*)",
      "Bash(git status*)",
      "Bash(git branch*)",
      "Bash(git diff*)",
      "Bash(git show*)"
    ]
  }
}
```

## Testing & Validation Strategy

### Phase 1 Testing: Basic Hook Functionality
1. **Hook Installation Test**:
   - Restore backup configuration
   - Verify all hook scripts exist and are executable
   - Test each hook individually

2. **File Quality Test**:
   ```typescript
   // Create test file with intentional issues
   export function testHooks(param: any) {
     const unused = 'test'
     console.log('TODO: implement this')
     return param + 1
   }
   ```
   - Expected: Detect `any` type, unused variable, console.log, TODO comment

3. **TypeScript Integration Test**:
   - Create file with TypeScript errors
   - Verify incremental type checking works
   - Test that errors are reported immediately

### Phase 2 Testing: Advanced Detection
1. **Mock Data Detection Test**:
   ```typescript
   const mockData = { userId: "12345", token: "abc123" }
   const sampleUsers = [{ id: 1, name: "Test User" }]
   // TODO: replace with real API
   throw new Error("Not implemented")
   ```

2. **Component Duplication Test**:
   - Create component similar to existing one
   - Verify similarity detection works
   - Test shadcn/ui component suggestions

3. **Breaking Change Test**:
   - Remove exported function
   - Change function signature  
   - Verify git diff analysis works

### Phase 3 Testing: Security & Performance
1. **Security Pattern Test**:
   ```typescript
   const apiKey = "sk_1234567890abcdef" // Should trigger warning
   const query = `SELECT * FROM users WHERE id = ${userId}` // SQL injection risk
   ```

2. **Performance Impact Test**:
   - Import large libraries without tree-shaking
   - Create expensive operations in useEffect without dependencies
   - Test file size warnings

### Phase 4 Testing: Git Integration
1. **Branch Context Test**:
   - Work on main branch (should warn)
   - Create feature branch with wrong naming
   - Test uncommitted changes detection

### Automated Test Suite
Create `test-hooks.ps1` script:
```powershell
# Comprehensive hook testing suite
Write-Host "🧪 Testing Claude Code Quality Hooks"

$testResults = @()

# Test 1: Basic hook functionality
$testFile = "C:\Users\Tom\dev\minerva\test-hook-validation.ts"
$testContent = @"
export function testFunction(param: any) {
  const unused = 'test'
  console.log('TODO: implement this')
  return param + 1
}
"@

Set-Content -Path $testFile -Value $testContent
# Simulate edit to trigger hooks
# Check hook outputs

# Test 2: Security patterns
$securityTest = @"
const apiKey = "sk_1234567890abcdef"
const query = `SELECT * FROM users WHERE id = ${userId}`
"@

# Continue with additional tests...

# Cleanup
Remove-Item $testFile -ErrorAction SilentlyContinue
```

## Timeline & Implementation Schedule

### Phase 1: Foundation (Week 1 - 2-3 hours)
- **Day 1**: Create hooks directory and basic scripts (1 hour)
- **Day 2**: Test and refine basic functionality (1 hour)  
- **Day 3**: Documentation and validation (1 hour)

### Phase 2: Advanced Detection (Week 1-2 - 4-5 hours)
- **Days 4-5**: Mock data and TODO detection (2 hours)
- **Days 6-7**: Component duplication and breaking changes (2 hours)
- **Day 8**: Testing and refinement (1 hour)

### Phase 3: Security & Performance (Week 2 - 3-4 hours)  
- **Days 9-10**: Security pattern validation (2 hours)
- **Days 11-12**: Performance monitoring and documentation (2 hours)

### Phase 4: Integration & Polish (Week 2-3 - 2-3 hours)
- **Days 13-14**: Git context awareness (1.5 hours)
- **Day 15**: Final integration and testing (1.5 hours)

**Total Implementation Time: 11-15 hours over 2-3 weeks**

## Maintenance & Monitoring

### Daily Monitoring
- Check hook execution logs: `C:\Users\Tom\.claude\logs\`
- Review quality reports for trends
- Monitor hook performance (execution times)

### Weekly Maintenance  
- Update hook patterns based on new issues discovered
- Review false positives and adjust thresholds
- Update security patterns for new vulnerabilities

### Monthly Reviews
- Analyze hook effectiveness metrics
- Update documentation and examples
- Consider new hook types based on development patterns

## Success Metrics

### Immediate Benefits (Week 1)
- ✅ Zero `any` type violations slip through
- ✅ TODO/FIXME items automatically tracked
- ✅ Security patterns caught before commit

### Medium-term Benefits (Month 1)
- 📈 50% reduction in code review time
- 📉 90% reduction in technical debt accumulation  
- 🎯 100% adherence to TypeScript strict mode

### Long-term Benefits (Quarter 1)
- 🚀 Improved development velocity
- 🛡️ Enhanced security posture
- 📚 Better documentation coverage
- 🔄 Increased component reusability

## Rollback & Safety Procedures

### Emergency Disable
```powershell
# Quick disable all hooks
Copy-Item "C:\Users\Tom\.claude\settings.json" "C:\Users\Tom\.claude\settings.json.with-hooks"
@'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "feedbackSurveyState": {
    "lastShownTime": 1754211852899
  }
}
'@ | Set-Content "C:\Users\Tom\.claude\settings.json"
```

### Selective Hook Disable
Remove specific hook configurations from settings.json while keeping others active.

### Hook Script Debugging
```powershell
# Test individual hook script
$testInput = @{
  tool_name = "Edit"
  file_path = "C:\Users\Tom\dev\minerva\test.ts"
} | ConvertTo-Json

echo $testInput | powershell -File "C:\Users\Tom\.claude\hooks\check-file-quality.ps1"
```

## Conclusion

This enhanced Claude Code hook system will transform your development workflow from reactive cleanup to proactive quality assurance. By implementing intelligent detection for incomplete work, security vulnerabilities, performance issues, and code duplication, you'll prevent the accumulation of technical debt that led to the current Phase 3 cleanup effort.

The system is designed with safety, performance, and maintainability in mind, ensuring that the hooks enhance rather than hinder your development process. With comprehensive testing, monitoring, and rollback procedures, you can deploy these hooks confidently knowing they will help maintain the high code quality standards essential for the Minerva project's continued success.