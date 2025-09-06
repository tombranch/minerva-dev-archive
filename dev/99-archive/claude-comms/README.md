# Claude Communication Hub

## 📡 Purpose

This folder serves as your direct communication hub with Claude Code, providing organized channels for different types of interaction and context sharing.

## 📁 Folder Structure

### 📝 **session-notes/**
**Purpose:** Prepare context and notes for Claude sessions
**Use when:** Starting new development sessions, sharing project context
**Examples:**
- Current project status for Claude
- Specific problems you want Claude to help solve
- Context about recent changes or decisions

### 🐛 **errors-and-logs/**
**Purpose:** Debug information and error reports for systematic troubleshooting
**Use when:** Encountering bugs, build failures, or technical issues
**Examples:**
- TypeScript compilation errors
- Test failure logs
- Runtime errors and stack traces
- Build process logs

### 💭 **quick-thoughts/**
**Purpose:** Rapid ideas and observations to share with Claude
**Use when:** Having spontaneous insights, questions, or observations
**Examples:**
- "What if we tried X approach for Y problem?"
- Quick UX observations
- Performance improvement ideas
- Architecture questions

### 🔄 **context-sharing/**
**Purpose:** Files specifically for giving Claude comprehensive project context
**Use when:** Need to share large amounts of context, code snippets, or project state
**Examples:**
- Code snippets for review or improvement
- Feature specifications for implementation
- Error contexts requiring deep analysis
- Project state summaries

## 🎯 Integration with Enhanced Workflow

### Workflow Command Integration
```bash
# Before using workflow commands, share context
echo "Current feature: Advanced Search UI" > claude-comms/session-notes/current-focus.md

# Use enhanced commands with shared context
/prd advanced search with AI-powered filtering
/feature advanced search with AI-powered filtering
```

### Agent Context Sharing
The enhanced workflow system automatically references files in this folder:
- **Agent context injection** reads from `context-sharing/`
- **Error analysis agents** access `errors-and-logs/`
- **Session continuity** maintained through `session-notes/`

## 📝 Usage Guidelines

### File Naming Conventions
```bash
# Session notes
session-notes/YYYY-MM-DD-session-focus.md
session-notes/current-project-status.md

# Errors and logs  
errors-and-logs/YYYY-MM-DD-error-description.txt
errors-and-logs/build-failure-analysis.md

# Quick thoughts
quick-thoughts/YYYY-MM-DD-idea-summary.md
quick-thoughts/performance-optimization-ideas.md

# Context sharing
context-sharing/feature-specification.md
context-sharing/code-review-request.md
```

### Best Practices

#### 📝 Session Notes
- **Be specific** about what you want to accomplish
- **Include relevant background** context and recent changes
- **State your goals clearly** for the session
- **Update regularly** with progress and new focus areas

#### 🐛 Errors and Logs
- **Include full error messages** and stack traces
- **Provide context** about what you were trying to do
- **Include relevant code snippets** that might be causing issues
- **Note any attempted solutions** and their results

#### 💭 Quick Thoughts
- **Keep it conversational** - these are informal notes
- **Include your reasoning** behind ideas
- **Ask specific questions** when you have them
- **Reference specific files or features** when relevant

#### 🔄 Context Sharing
- **Provide comprehensive context** for complex requests
- **Include all relevant information** in one place
- **Structure information clearly** with headings and sections
- **Update context** as situations evolve

## 🔄 Workflow Integration Examples

### Starting a New Feature
```bash
# 1. Prepare session context
echo "Starting work on photo bulk operations feature
- Need to implement ZIP download functionality
- Backend APIs already exist  
- Focus on frontend UI implementation
- Integration with existing upload system" > claude-comms/session-notes/bulk-operations-focus.md

# 2. Share technical context
cp relevant-code-snippets.md claude-comms/context-sharing/bulk-operations-context.md

# 3. Use enhanced workflow
/prd photo bulk operations with ZIP download
```

### Debugging Session
```bash
# 1. Log the error
echo "TypeScript compilation error in photo upload component
Error: Property 'onProgress' does not exist on type 'UploadOptions'
File: src/components/PhotoUpload.tsx:45
Context: Trying to add progress callback for upload status" > claude-comms/errors-and-logs/upload-progress-error.txt

# 2. Request help
echo "Need help fixing TypeScript error in photo upload progress tracking
See errors-and-logs/upload-progress-error.txt for details" > claude-comms/session-notes/debug-upload-progress.md

# 3. Use debug workflow
/debug TypeScript errors in photo upload component
```

### Code Review Session
```bash
# 1. Share code for review
cp src/components/SearchInterface.tsx claude-comms/context-sharing/search-interface-review.tsx

# 2. Prepare review context
echo "Please review SearchInterface component for:
- Performance optimizations
- TypeScript type safety
- UI/UX best practices
- Integration with existing search API
See context-sharing/search-interface-review.tsx" > claude-comms/session-notes/search-interface-review.md

# 3. Use review workflow
/review src/components/SearchInterface.tsx
```

## 🧹 Maintenance

### Regular Cleanup (Monthly)
- **Archive old session notes** - move completed sessions to archive
- **Clean up resolved errors** - move fixed issues to archive  
- **Consolidate quick thoughts** - organize ideas into actionable items
- **Update context files** - keep shared context current

### Organization Tips
- **Use dates** in filenames for temporal organization
- **Be descriptive** in filenames - future you will thank you
- **Keep active files** in main folders, archive completed items
- **Cross-reference** between folders when context spans multiple areas

This communication hub ensures effective collaboration with Claude Code while maintaining organized records of all interactions and contexts.