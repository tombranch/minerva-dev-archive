# MCP Server Setup Guide

## Overview

Model Context Protocol (MCP) servers extend Claude Code with additional capabilities. This project uses two MCP servers:

- **Context7**: Documentation and context search capabilities
- **Serena**: Semantic retrieval and code editing toolkit

## Installation Status

Both MCP servers are configured and working in this project.

## Configuration

### Context7 MCP Server

**Purpose**: Documentation search and context retrieval from various sources.

**Configuration** (in `~/.claude.json`):
```json
"context7": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp"],
  "env": {}
}
```

**Test Command**:
```bash
npx -y @upstash/context7-mcp
# Should output: "Context7 Documentation MCP Server running on stdio"
```

### Serena MCP Server

**Purpose**: Semantic retrieval and editing capabilities, coding agent toolkit.

**Prerequisites**: 
- `uv` (Python package manager) must be installed

**Configuration** (in `~/.claude.json`):
```json
"serena": {
  "type": "stdio", 
  "command": "uvx",
  "args": [
    "--from",
    "git+https://github.com/oraios/serena",
    "serena", 
    "start-mcp-server"
  ],
  "env": {}
}
```

**Test Command**:
```bash
uvx --from git+https://github.com/oraios/serena serena start-mcp-server
# First run builds from source (~30 seconds)
```

## Troubleshooting

### Common Issues

1. **Context7 "command not found"**
   - Ensure configuration uses separate `command` and `args` fields
   - Don't use: `"command": "npx -y @upstash/context7-mcp"`
   - Use: `"command": "npx", "args": ["-y", "@upstash/context7-mcp"]`

2. **Serena build failures**
   - Ensure `uv` is installed: `uv --version`
   - First-time setup requires internet connection for Git clone
   - Allow ~30 seconds for initial build

3. **Duplicate configurations**
   - Check both user-level and project-level MCP configurations
   - Remove duplicates to prevent conflicts

### Verification

Check MCP server status:
```bash
claude /mcp
```

Or run with debug output:
```bash
claude --debug
```

## Usage

Both servers integrate automatically with Claude Code once configured. No additional commands needed during normal usage.

**Context7 capabilities**:
- Documentation search
- Context retrieval
- Web content analysis

**Serena capabilities**:
- Semantic code search
- Advanced editing operations
- Code analysis and refactoring suggestions

## Last Updated

2025-08-11 - Initial setup and troubleshooting completed