# Dev Folder - Legacy Documentation Archive

⚠️ **NOTICE: This folder is now archived. Active project management has moved to GitHub Projects.**

**GitHub Project Board**: https://github.com/users/tombranch/projects/4
**GitHub Issues**: https://github.com/tombranch/minerva/issues

## Migration Status

✅ **Completed**: GitHub Projects setup with automation
✅ **Completed**: Key issues migrated to GitHub Issues
✅ **Completed**: Workflow automation configured

## Current Structure (Archive Only)

### 00-context/
**Status:** Archived - Context now shared via GitHub Issues and PR descriptions
**Contents:** Historical context files and session notes

### 01-ideas/
**Status:** Migrated to GitHub Issues with `idea` label
**Contents:** Historical idea documents (archived)

### 02-staging/ & 03-in-progress/
**Status:** Migrated to GitHub Issues with appropriate labels
**Contents:** Historical implementation plans (archived)

### 04-completed/
**Status:** Archived - Completed work tracked in GitHub Issues
**Contents:** Historical completion reports and retrospectives

### 99-archive/
**Purpose:** Historical archive of previous folder structures
**Contents:** All previous development documentation

## New Workflow (GitHub Projects)

```
GitHub Issues → Project Board → Implementation → PR → Done
```

1. **Create Issue**: Use GitHub issue templates for features/bugs
2. **Project Board**: Issues automatically added to project board
3. **Implementation**: Work tracked via PR linking to issues
4. **Completion**: Issues auto-close when PRs merge

## GitHub Projects Benefits

- **Professional Workflow**: Industry-standard project management
- **Automated Tracking**: Issues move through stages automatically
- **Better Collaboration**: Even for solo development, better history and searchability
- **AI Agent Integration**: GitHub API allows AI agents to create/update issues
- **Real-time Updates**: Status changes reflected immediately across all views

## Quick Commands

```bash
# Create new feature issue
gh issue create --title "[FEATURE] Your feature name" \
  --body "Description of the feature" \
  --label "feature,needs-triage"

# Create bug report
gh issue create --title "[BUG] Bug description" \
  --body "Steps to reproduce..." \
  --label "bug,needs-triage"

# List current issues
gh issue list --state open

# View project board
open https://github.com/users/tombranch/projects/4
```

## Migration Completed

**Date**: September 2025
**Status**: ✅ Complete
**Active Issues**: Check GitHub Issues
**Project Board**: https://github.com/users/tombranch/projects/4
