# MCP Servers Documentation

## Overview

This document provides comprehensive information about all Model Context Protocol (MCP) servers configured for the Minerva project. MCP servers extend Claude Code with additional capabilities for development, testing, monitoring, and deployment.

## Active MCP Servers

### 1. Context7 📚
**Purpose**: Documentation search and context retrieval
- **Configuration**: `npx -y @upstash/context7-mcp`
- **Type**: HTTP MCP Server (`https://mcp.context7.com/mcp`)
- **Capabilities**:
  - Documentation searches across various sources
  - Web content analysis and retrieval
  - Context-aware documentation fetching
  - Library documentation access
- **Usage**: Automatic integration with Claude Code for documentation queries
- **Status**: ✅ Active and working

### 2. Serena 🔧
**Purpose**: Semantic code editing and analysis toolkit
- **Configuration**: `uvx --from git+https://github.com/oraios/serena serena start-mcp-server`
- **Type**: STDIO MCP Server
- **Capabilities**:
  - Semantic code search and navigation
  - Advanced code editing operations
  - Symbol-based code analysis
  - Intelligent refactoring suggestions
  - Memory management for project context
- **Usage**: Automatic integration for complex code operations
- **Status**: ✅ Active and working

### 3. Playwright 🎭
**Purpose**: Browser automation and testing
- **Configuration**: `npx @playwright/mcp@latest`
- **Type**: STDIO MCP Server
- **Capabilities**:
  - Browser automation for testing
  - Web page interaction and testing
  - Screenshot and visual testing
  - Cross-browser compatibility testing
- **Usage**: E2E testing and browser automation tasks
- **Status**: ✅ Active and working

### 4. Supabase 🗄️
**Purpose**: Database management and operations
- **Configuration**: `npx -y @supabase/mcp-server-supabase@latest`
- **Type**: STDIO MCP Server (Read-only mode)
- **Project**: `vyjgfysepbkaquganpdi`
- **Capabilities**:
  - Database schema management
  - Migration operations
  - Query execution and analysis
  - Table and data management
  - Branch operations for development databases
- **Environment**: Uses `SUPABASE_ACCESS_TOKEN`
- **Usage**: Database operations and schema management
- **Status**: ✅ Active and working

### 5. GitHub 🐙
**Purpose**: Repository management and Git operations
- **Configuration**: `npx -y @modelcontextprotocol/server-github@latest`
- **Type**: STDIO MCP Server
- **Capabilities**:
  - Repository file management
  - Pull request creation and management
  - Issue tracking and management
  - Branch operations
  - Code search across repositories
  - Release management
- **Environment**: Uses `GITHUB_PERSONAL_ACCESS_TOKEN`
- **Usage**: Git operations and repository management
- **Status**: ✅ Active and working

### 6. Sentry 🚨
**Purpose**: Error monitoring and performance tracking
- **Configuration**: `npx -y @sentry/mcp-server@latest`
- **Type**: STDIO MCP Server
- **Capabilities**:
  - Error tracking and analysis
  - Performance monitoring
  - Issue management
  - Release tracking
  - User and event analysis
  - Documentation search for Sentry SDKs
- **Environment**: Uses `SENTRY_AUTH_TOKEN`
- **Usage**: Error monitoring and debugging
- **Status**: ✅ Active and working

### 7. Firecrawl 🔥
**Purpose**: Web scraping and content extraction
- **Configuration**: `npx -y @mendable/firecrawl-mcp-server@latest`
- **Type**: STDIO MCP Server
- **Capabilities**:
  - Web page scraping and content extraction
  - Batch URL processing
  - Structured data extraction
  - Web content analysis
  - Site mapping and crawling
- **Environment**: Uses `FIRECRAWL_API_KEY`
- **Usage**: Web scraping and content analysis
- **Status**: ✅ Active and working

## Configuration Details

### Windows Command Wrapper
All MCP servers use the Windows `cmd /c` wrapper for proper execution:
```json
{
  "command": "cmd",
  "args": ["/c", "npx", "package-name"]
}
```

### Environment Variables
MCP servers use the following environment variables:
- `SUPABASE_ACCESS_TOKEN` - Supabase database access
- `GITHUB_PERSONAL_ACCESS_TOKEN` - GitHub repository access
- `SENTRY_AUTH_TOKEN` - Sentry error monitoring access
- `FIRECRAWL_API_KEY` - Firecrawl web scraping access

## Usage Guidelines

### When to Use Each Server

**Context7**: 
- Documentation searches
- Library reference lookups
- Web content analysis
- Research tasks

**Serena**:
- Complex code refactoring
- Symbol-based navigation
- Semantic code search
- Project memory management

**Playwright**:
- E2E test development
- Browser automation
- Visual testing
- Cross-browser validation

**Supabase**:
- Database schema changes
- Migration operations
- Data analysis
- Development database management

**GitHub**:
- Repository management
- Pull request operations
- Issue tracking
- Code search

**Sentry**:
- Error investigation
- Performance analysis
- Release monitoring
- Issue management

**Firecrawl**:
- Web research
- Content extraction
- Competitive analysis
- Data collection

### Best Practices

1. **Leverage MCP servers** for their specialized capabilities rather than manual operations
2. **Combine servers** for complex workflows (e.g., GitHub + Sentry for release monitoring)
3. **Use Context7** for research before implementation
4. **Use Serena** for complex code operations and refactoring
5. **Monitor MCP server status** regularly with `claude /mcp`

## Troubleshooting

### Common Issues
1. **Server connection failures**: Check environment variables and network connectivity
2. **Authentication errors**: Verify API tokens and permissions
3. **Windows execution issues**: Ensure `cmd /c` wrapper is used
4. **Timeout issues**: Check server responsiveness and network latency

### Debugging
- Use `claude --debug` for detailed MCP server logs
- Check log files in `C:\Users\Tom\AppData\Local\claude-cli-nodejs\Cache\`
- Verify configuration in `.claude.json`

## Status Monitoring

Check MCP server status with:
```bash
claude /mcp
```

This displays:
- Connection status for each server
- Configuration warnings
- Server details and capabilities

## Last Updated

2025-08-12 - Complete documentation of all active MCP servers