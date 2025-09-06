# GitHub Projects Integration Guide

## Overview
This guide explains how to migrate from the `/dev` folder project management system to GitHub Projects for better issue tracking, project management, and workflow automation.

## Migration Strategy

### Current /dev Folder Structure
```
dev/
├── 01-ideas/           -> GitHub Issues (labeled: idea, backlog)
├── 02-staging/         -> GitHub Issues (labeled: staged, ready)
├── 03-in-progress/     -> GitHub Issues (labeled: in-progress)
├── 04-completed/       -> GitHub Issues (labeled: completed, closed)
├── 06-reports/         -> GitHub Discussions or Wiki
└── 0-workflow/         -> Repository documentation
```

### GitHub Projects Setup

#### 1. Create Project
```bash
# Create a new GitHub Project
gh project create --title "Minerva Development" --public
```

#### 2. Set Up Project Fields
- **Status**: Todo, In Progress, In Review, Done
- **Priority**: Low, Medium, High, Critical
- **Type**: Feature, Bug, Enhancement, Documentation, Research
- **Epic**: Group related issues
- **Size**: Small, Medium, Large, XL

#### 3. Create Issue Templates
```bash
# Create issue templates directory
mkdir -p .github/ISSUE_TEMPLATE
```

## Issue Templates

### Feature Request Template
```yaml
name: Feature Request
about: Suggest a new feature for the Minerva project
title: '[FEATURE] '
labels: ['feature', 'needs-triage']
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        Thanks for suggesting a feature! Please provide the following information.
  
  - type: textarea
    id: description
    attributes:
      label: Feature Description
      description: A clear description of the feature you'd like to see
      placeholder: Describe the feature...
    validations:
      required: true
  
  - type: textarea
    id: user-story
    attributes:
      label: User Story
      description: As a [user type], I want [goal] so that [benefit]
      placeholder: As a machine safety engineer, I want...
    validations:
      required: true
  
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance Criteria
      description: List the specific requirements that must be met
      placeholder: |
        - [ ] Requirement 1
        - [ ] Requirement 2
    validations:
      required: true
      
  - type: dropdown
    id: priority
    attributes:
      label: Priority
      options:
        - Low
        - Medium
        - High
        - Critical
    validations:
      required: true
```

### Bug Report Template
```yaml
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: ['bug', 'needs-triage']
assignees: []

body:
  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: A clear description of what the bug is
      placeholder: Describe the bug...
    validations:
      required: true
  
  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      description: Steps to reproduce the behavior
      placeholder: |
        1. Go to...
        2. Click on...
        3. See error
    validations:
      required: true
  
  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: What you expected to happen
    validations:
      required: true
  
  - type: textarea
    id: actual
    attributes:
      label: Actual Behavior
      description: What actually happened
    validations:
      required: true
      
  - type: textarea
    id: environment
    attributes:
      label: Environment
      description: Browser, OS, Node version, etc.
      placeholder: |
        - OS: Ubuntu 22.04
        - Browser: Chrome 118
        - Node: v18.17.0
```

## Automated Workflows

### Project Automation
```yaml
name: Project Automation
on:
  issues:
    types: [opened, closed, reopened]
  pull_request:
    types: [opened, closed, merged]

jobs:
  manage_project:
    runs-on: ubuntu-latest
    steps:
      - name: Add to project
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: https://github.com/users/tombranch/projects/1
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Issue Labeling
```yaml
name: Auto Label
on:
  issues:
    types: [opened]

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - name: Auto label issues
        uses: github/issue-labeler@v3.0
        with:
          configuration-path: .github/labeler.yml
          enable-versioned-regex: 0
          repo-token: "${{ secrets.GITHUB_TOKEN }}"
```

## Migration Process

### Phase 1: Create GitHub Project Structure
```bash
# 1. Create main project
gh project create --title "Minerva Development" --public

# 2. Create labels
gh label create "feature" --color "0e8a16" --description "New feature"
gh label create "bug" --color "d73a49" --description "Bug fix"
gh label create "enhancement" --color "a2eeef" --description "Enhancement"
gh label create "documentation" --color "0075ca" --description "Documentation"
gh label create "research" --color "7057ff" --description "Research task"
gh label create "high-priority" --color "b60205" --description "High priority"
gh label create "in-progress" --color "fbca04" --description "Currently in progress"
gh label create "needs-review" --color "5319e7" --description "Needs review"
```

### Phase 2: Migrate Existing Items
```bash
# Convert /dev folder items to GitHub Issues
# Script to parse markdown files and create issues

#!/bin/bash
# migrate-dev-to-github.sh

# Ideas to Issues
for file in dev/01-ideas/*.md; do
  title=$(head -1 "$file" | sed 's/# //')
  body=$(tail -n +2 "$file")
  gh issue create --title "$title" --body "$body" --label "idea,backlog"
done

# In-progress to Issues
for file in dev/03-in-progress/*.md; do
  title=$(head -1 "$file" | sed 's/# //')
  body=$(tail -n +2 "$file")
  gh issue create --title "$title" --body "$body" --label "in-progress"
done
```

### Phase 3: Update Development Workflow
Update the streamlined commands to integrate with GitHub:

```bash
# /plan command integration
- Create GitHub issue for the planned feature
- Link planning documents to the issue
- Set up project board tracking

# /implement command integration  
- Reference GitHub issue in commits
- Update issue status automatically
- Link PRs to issues

# /review command integration
- Create review checklist in issue
- Update issue with review results
- Close issue when review passes
```

## Benefits of GitHub Integration

### Better Project Management
- **Visual Boards**: Kanban-style project boards
- **Automated Workflows**: Issues move through stages automatically
- **Progress Tracking**: Real-time project status
- **Team Collaboration**: Even for solo development, better history

### Enhanced Development Workflow
- **Issue Linking**: Commits and PRs link to issues automatically
- **Progress Updates**: Status updates via commit messages
- **Documentation**: All project history in one place
- **Search**: Find anything across issues, PRs, and discussions

### Reporting and Analytics
- **Velocity Tracking**: How fast features are completed
- **Burn-down Charts**: Progress towards milestones
- **Issue Analytics**: Common bug patterns and feature requests
- **Time Tracking**: How long features take to implement

## Implementation Commands

### Create GitHub Project
```bash
# First refresh GitHub CLI with project scopes (requires browser authentication)
gh auth refresh -s project,read:project --hostname github.com

# Then create the project
gh project create --title "Minerva Development" --owner tombranch
```

**Note**: Requires interactive browser authentication to add project management scopes to GitHub CLI. Can be completed later when needed.

### Create Issue Templates
```bash
# Create the issue templates
mkdir -p .github/ISSUE_TEMPLATE
# Copy the templates above into separate .yml files
```

### Set up Labels
```bash
# Create all necessary labels
gh label create "feature" --color "0e8a16"
gh label create "bug" --color "d73a49"
gh label create "enhancement" --color "a2eeef"
gh label create "documentation" --color "0075ca"
gh label create "research" --color "7057ff"
gh label create "high-priority" --color "b60205"
gh label create "in-progress" --color "fbca04"
gh label create "needs-review" --color "5319e7"
```

## Integration with Streamlined Commands

The new `/plan`, `/implement`, and `/review` commands will integrate with GitHub:

- **Planning Phase**: Creates GitHub issue with planning documents
- **Implementation Phase**: Updates issue status and links PRs
- **Review Phase**: Adds review results to issue and closes when complete

This creates a complete development workflow that scales from solo development to team collaboration while maintaining all the benefits of the streamlined command structure.

## Next Steps

1. **Create GitHub Project**: Set up the main project board
2. **Migrate Existing Items**: Convert `/dev` folder contents to issues
3. **Update Commands**: Integrate GitHub API calls into streamlined commands
4. **Test Workflow**: Validate the complete planning → implementation → review cycle

This integration will provide professional project management capabilities while maintaining the streamlined development experience optimized for Claude Code.