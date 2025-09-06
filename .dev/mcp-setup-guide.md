# MCP Server Setup Guide for Minerva Project

## Overview
Model Context Protocol (MCP) servers extend Claude Code's capabilities by providing specialized tools and integrations. This guide documents the essential MCP servers for the Minerva project.

## Currently Available MCP Servers

### ✅ Context7 - Documentation & Research
**Status**: Active and configured
**Purpose**: Documentation search, web content analysis, and context retrieval
**Capabilities**:
- Search up-to-date documentation for technologies
- Analyze web content and extract relevant information
- Access library documentation and API references
- Verify implementation patterns and best practices

**Usage in Commands**:
- `/plan` - Research best practices and implementation patterns
- `/implement` - Verify API compatibility and get code examples
- All agents use Context7 for staying current with documentation

### ✅ Playwright - Browser Automation & E2E Testing
**Status**: Installed and ready
**Purpose**: Browser automation, testing, and web page interaction
**Capabilities**:
- Run end-to-end tests across multiple browsers
- Take screenshots and generate visual test reports
- Automate web interactions and form submissions
- Cross-browser compatibility testing

**Installation**: `pnpm exec playwright install chromium`

### ✅ GitHub - Repository Management
**Status**: Active via GitHub CLI (gh v2.45.0)
**Purpose**: Repository management and Git operations
**Capabilities**:
- Create and manage pull requests
- Handle issue tracking and project management
- Repository search and code analysis
- Release management and deployment

**Usage**: Available through `gh` command and GitHub API integration

### ✅ Supabase - Database Management (Current)
**Status**: Active for current database operations
**Purpose**: Database management and operations
**Capabilities**:
- Schema management and migrations
- Data analysis and querying
- Real-time subscription management
- Storage and authentication management

**Installation**: Already integrated via `@supabase/supabase-js`

### ✅ Sentry - Error Monitoring
**Status**: Partially configured
**Purpose**: Error monitoring and performance tracking
**Capabilities**:
- Error tracking and debugging
- Performance monitoring
- Release tracking and deployment monitoring
- User session replay and analysis

**Installation**: Already integrated via `@sentry/nextjs`

## Recommended Additional MCP Servers

### ✅ Firecrawl - Web Scraping & Content Extraction
**Status**: Available (requires Node.js 22+ and API key)
**Purpose**: Web scraping and content analysis
**Installation**:
```bash
# Test installation (requires FIRECRAWL_API_KEY)
npx -y firecrawl-mcp

# For Claude Code CLI
claude mcp add-json firecrawl '{"type":"stdio","command":"npx","args":["-y","firecrawl-mcp"],"env":{"FIRECRAWL_API_KEY":"your-api-key"}}'
```

**Requirements**:
- Node.js 22.0.0+ (current: v18.19.1 - needs upgrade)
- Firecrawl API key from https://firecrawl.dev/app/api-keys

**Use Cases**:
- Research competitor features and implementations
- Extract documentation from websites
- Analyze industry best practices
- Content research for feature planning

### ✅ Convex - Future Database Management
**Status**: Installed and ready (v1.26.2)
**Purpose**: Next-generation database for migration target
**Installation**: ✅ Complete
```bash
# Already installed via pnpm add convex@latest

# Test MCP server
npx convex mcp start --help

# For Claude Code CLI
claude mcp add-json convex '{"type":"stdio","command":"npx","args":["convex","mcp","start"]}'
```

**Available Tools**:
- `status` - Query deployments and deployment selector
- `tables` - List all tables in a deployment
- `runOneoffQuery` - Execute sandboxed JavaScript queries (read-only)
- `functionSpec` - Function metadata and specifications
- `logs` - Fetch recent function execution log entries

**Use Cases**:
- Schema-in-code development
- Real-time database operations
- Built-in authentication and file storage
- Type-safe database operations

## MCP Server Configuration

### Claude Code Integration
MCP servers are automatically available to Claude Code when properly installed. Check status:
```bash
# List available MCP servers
claude /mcp
```

### Environment Setup
Ensure MCP servers can access necessary environment variables:
```bash
# Add to your environment setup
export GITHUB_TOKEN="your_github_token"
export SUPABASE_URL="your_supabase_url"
export SUPABASE_ANON_KEY="your_supabase_key"
export SENTRY_DSN="your_sentry_dsn"
```

## Usage Patterns

### In Planning Phase
```bash
# Use Context7 for research
/plan "implement real-time notifications"
# Context7 automatically researches:
# - Next.js 15 real-time patterns
# - Supabase real-time subscriptions
# - WebSocket implementation best practices
```

### During Implementation
```bash
# Context7 verifies API compatibility
/implement plan-real-time-notifications.md
# Playwright runs automated tests
# GitHub creates commits and manages PRs
```

### For Testing & Deployment
```bash
# Playwright runs comprehensive e2e tests
/review "real-time notifications feature"
# Sentry tracks deployment and errors
# GitHub manages release process
```

## MCP Server Benefits for Solo Development

### Reduced Context Switching
- No need to manually search documentation
- Automated testing and validation
- Integrated deployment workflows

### Enhanced Quality
- Up-to-date best practices through Context7
- Comprehensive testing via Playwright
- Error tracking through Sentry

### Improved Productivity
- Automated repository management
- Real-time documentation access
- Integrated development workflows

## Troubleshooting

### Context7 Issues
```bash
# Verify Context7 is responding
# Should show available web search and documentation tools
claude /mcp
```

### Playwright Issues
```bash
# Reinstall browsers if needed
pnpm exec playwright install --force
```

### GitHub CLI Issues
```bash
# Check authentication
gh auth status
# Re-authenticate if needed
gh auth login
```

### Sentry Configuration
```bash
# Verify Sentry configuration
pnpm exec sentry-wizard --integration nextjs
```

## Future Enhancements

### Planned MCP Servers
1. **Linear/Jira MCP** - Better project management than GitHub Projects
2. **Vercel MCP** - Enhanced deployment management
3. **PostHog MCP** - Advanced analytics integration
4. **Custom Minerva MCP** - Project-specific tools and workflows

### Integration Opportunities
- Automated deployment pipelines through GitHub + Vercel MCP
- Enhanced error monitoring through Sentry + performance tracking
- Advanced analytics through PostHog integration
- Custom workflow automation for photo processing features

This MCP setup significantly enhances Claude Code's capabilities while maintaining the streamlined workflow designed for solo development.