# How to Re-enable Claude Code Quality Hooks

## Current Status
- **Hooks Status**: DISABLED (for cleanup)
- **Backup Location**: `C:\Users\Tom\.claude\settings.json.backup`
- **Current Settings**: Minimal configuration without hooks

## Re-enable Instructions

### Step 1: Verify Cleanup Completion
Before re-enabling hooks, ensure:
- [ ] All phases completed successfully
- [ ] Error count < 50 total
- [ ] Zero `any` types remain
- [ ] All tests pass: `npm test`
- [ ] Project builds: `npm run build`
- [ ] Lint passes: `npm run lint`

### Step 2: Restore Hook Configuration
```powershell
# Navigate to Claude settings directory
cd C:\Users\Tom\.claude

# Backup current minimal settings (optional)
Copy-Item "settings.json" "settings.json.cleanup-disabled"

# Restore full hooks configuration
Copy-Item "settings.json.backup" "settings.json"

# Verify restoration
Get-Content "settings.json" | Select-String "hooks"
```

### Step 3: Test Hook Functionality
Create a test file to verify hooks are working:
```powershell
# Create test file with intentional issues
@"
// Test file for hook verification
export function testHooks(param: any) {
  const unused = 'test'
  return param + 1
}
"@ | Set-Content "C:\Users\Tom\dev\minerva\test-hooks-verification.ts"
```

Edit the file using Claude to trigger hooks:
- PostToolUse hooks should run automatically
- Quality checks should report `any` type and unused variable
- File should be auto-formatted

Clean up test file:
```powershell
Remove-Item "C:\Users\Tom\dev\minerva\test-hooks-verification.ts"
```

### Step 4: Verify Hook Components
Ensure all hook scripts are present:
- [ ] `C:\Users\Tom\.claude\hooks\check-file-quality.ps1`
- [ ] `C:\Users\Tom\.claude\hooks\log-commands.ps1` 
- [ ] `C:\Users\Tom\.claude\hooks\type-check-incremental.ps1`
- [ ] `C:\Users\Tom\.claude\hooks\session-init.ps1`
- [ ] `C:\Users\Tom\.claude\hooks\quality-report.ps1`

### Step 5: Enable Session Features
Restart Claude Code session to fully activate:
- SessionStart hooks will initialize caches
- Quality checks will resume for all edits
- Command logging will be active
- Quality reports will generate

## Expected Behavior After Re-enabling

### PostToolUse Hooks (After File Edits)
- TypeScript type checking runs automatically
- ESLint validation occurs
- Prettier auto-formatting applies
- Quality issues reported to Claude

### PreToolUse Hooks (Before Commands)
- Bash commands logged to `~/.claude/logs/bash-commands.log`
- Dangerous commands blocked with warnings
- Audit trail maintained

### Session Management
- Cache initialization at startup
- Quality reports at session end
- Metrics tracking active

## Troubleshooting

### Hooks Not Running
1. Check settings file syntax: `Get-Content C:\Users\Tom\.claude\settings.json | ConvertFrom-Json`
2. Verify PowerShell execution policy: `Get-ExecutionPolicy`
3. Restart Claude Code session completely

### Permission Errors
```powershell
# Check if PowerShell scripts can run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Hook Script Errors
Check individual scripts work:
```powershell
# Test type checking script
echo '{"tool_name":"Edit","tool_input":{"file_path":"test.ts"}}' | 
  powershell -File "C:\Users\Tom\.claude\hooks\check-file-quality.ps1"
```

## Success Verification Checklist
- [ ] Hooks re-enabled without errors
- [ ] Test file edit triggers quality checks
- [ ] Session initialization runs correctly
- [ ] Command logging is active
- [ ] Quality reports generate
- [ ] No regression in error counts
- [ ] TypeScript errors caught immediately
- [ ] `any` type usage blocked

## Rollback Plan
If issues occur, disable hooks again:
```powershell
Copy-Item "C:\Users\Tom\.claude\settings.json.cleanup-disabled" "C:\Users\Tom\.claude\settings.json"
```

This will return to the minimal configuration used during cleanup.