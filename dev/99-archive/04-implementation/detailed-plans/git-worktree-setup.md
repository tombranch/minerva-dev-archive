# Git Worktree Setup for Multiple Claude Code Instances

This guide explains how to set up multiple git worktrees for running separate Claude Code instances in different VS Code windows.

## Overview

Git worktrees allow you to have multiple working directories from the same repository, each checked out to different branches. This is perfect for:
- Running multiple Claude Code instances simultaneously
- Working on different features in parallel
- Testing/debugging while maintaining a clean main branch
- Comparing implementations side-by-side

## Current Repository Status

- **Main repository**: `C:\Users\Tom\dev\minerva` (main branch)
- **Worktrees directory**: `C:\Users\Tom\dev\minerva\worktrees\` (already exists)
- **Available branches**: main, origin/main

## Setup Commands

### 1. Create Worktrees for Different Purposes

```bash
# Feature development worktree
git worktree add worktrees/feature-dev -b feature-dev

# Experimental/testing worktree
git worktree add worktrees/experimental -b experimental

# Bug fixes worktree
git worktree add worktrees/bugfix -b bugfix

# Clean testing environment (uses main branch)
git worktree add worktrees/testing main

# Documentation updates
git worktree add worktrees/docs -b docs-update
```

### 2. List All Worktrees

```bash
git worktree list
```

Expected output:
```
C:/Users/Tom/dev/minerva              2c757a9 [main]
C:/Users/Tom/dev/minerva/worktrees/feature-dev    [feature-dev]
C:/Users/Tom/dev/minerva/worktrees/experimental   [experimental]
C:/Users/Tom/dev/minerva/worktrees/testing        [main]
```

## VS Code Workspace Setup

### Option 1: Individual VS Code Windows
Open each worktree in a separate VS Code window:
```bash
code C:\Users\Tom\dev\minerva\worktrees\feature-dev
code C:\Users\Tom\dev\minerva\worktrees\experimental
code C:\Users\Tom\dev\minerva\worktrees\testing
```

### Option 2: Multi-Root Workspace
Create a VS Code workspace file (`minerva-worktrees.code-workspace`):
```json
{
  "folders": [
    {
      "name": "Main",
      "path": "."
    },
    {
      "name": "Feature Dev",
      "path": "./worktrees/feature-dev"
    },
    {
      "name": "Experimental",
      "path": "./worktrees/experimental"
    },
    {
      "name": "Testing",
      "path": "./worktrees/testing"
    }
  ],
  "settings": {
    "typescript.preferences.includePackageJsonAutoImports": "on"
  }
}
```

## Claude Code Configuration

### Environment Setup for Each Worktree

Each worktree needs its own environment configuration:

1. **Copy essential files** to each worktree:
   ```bash
   # Copy environment files (if they exist)
   cp .env.local worktrees/feature-dev/
   cp .env.local worktrees/experimental/
   cp .env.local worktrees/testing/
   ```

2. **Shared node_modules**: All worktrees share the same `node_modules` from the main repository, so no additional npm install needed.

3. **Database considerations**: 
   - All worktrees use the same local Supabase instance
   - Consider using different database schemas for isolation if needed
   - Use `./scripts/supabase-start.bat` from any worktree

### Claude Code Usage

Start Claude Code in each worktree:
```bash
# Terminal 1: Feature development
cd worktrees/feature-dev
claude-code

# Terminal 2: Experimental work
cd worktrees/experimental
claude-code

# Terminal 3: Testing environment
cd worktrees/testing
claude-code
```

## Workflow Examples

### Example 1: Feature Development + Testing
```bash
# Main development
cd worktrees/feature-dev
git checkout -b new-feature
# Work with Claude Code here

# Testing in parallel
cd worktrees/testing
npm run test
npm run dev
# Use Claude Code for debugging
```

### Example 2: Comparison Development
```bash
# Approach A
cd worktrees/feature-dev
git checkout -b approach-a
# Implement solution A with Claude Code

# Approach B
cd worktrees/experimental
git checkout -b approach-b
# Implement solution B with Claude Code

# Compare results side-by-side in VS Code
```

## Important Considerations

### Shared Resources
- **Node modules**: Shared across all worktrees
- **Git history**: Shared repository history
- **Database**: Same local Supabase instance
- **Port conflicts**: Different worktrees can't run dev server simultaneously on same port

### Development Server Management
Only one worktree can run `npm run dev` at a time (port 3000 conflict). Solutions:
```bash
# Worktree 1: Default port
npm run dev

# Worktree 2: Different port
npm run dev -- --port 3001

# Worktree 3: Different port
npm run dev -- --port 3002
```

### Git Operations
- `git push`, `git pull` affect all worktrees
- Each worktree has its own staging area
- Commits are per-worktree but shared history

## Cleanup Commands

Remove worktrees when done:
```bash
# Remove specific worktree
git worktree remove worktrees/feature-dev

# Remove all worktrees and clean up
git worktree prune
```

## Best Practices

1. **Branch naming**: Use descriptive branch names for each worktree
2. **Regular cleanup**: Remove unused worktrees to avoid clutter
3. **Environment isolation**: Consider using different `.env` files if needed
4. **Port management**: Use different ports for dev servers
5. **Database state**: Be aware that all worktrees share the same database

## Claude Code Benefits

- **Parallel development**: Work on multiple features simultaneously
- **Safe experimentation**: Test ideas without affecting main branch
- **Quick context switching**: No need to stash/commit when switching tasks
- **Comparison**: Easy to compare different approaches side-by-side
- **Isolation**: Each Claude Code instance has its own context and history

## Troubleshooting

### Common Issues
1. **Port conflicts**: Use different ports for dev servers
2. **Environment variables**: Ensure each worktree has proper `.env` files
3. **Node modules**: Shared, so package changes affect all worktrees
4. **Git conflicts**: Be careful with concurrent git operations

### Verification Commands
```bash
# Check worktree status
git worktree list

# Check branch in each worktree
cd worktrees/feature-dev && git branch
cd worktrees/experimental && git branch

# Test development setup
cd worktrees/feature-dev && npm run dev -- --port 3001
```

This setup provides maximum flexibility for parallel development with multiple Claude Code instances while maintaining clean separation of concerns.