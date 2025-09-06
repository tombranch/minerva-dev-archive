# Claude Code Built-in Agents Setup Guide

This guide will walk you through creating and configuring the Claude Code built-in agents for your startup development needs.

## Prerequisites

- Claude Code desktop application installed
- Access to the Agents section in Claude Code
- Basic understanding of the Task tool

## Built-in Agent System Overview

Claude Code's built-in agents provide:
- **Dedicated context windows** - Each agent maintains its own conversation state
- **Specialized system prompts** - Tailored for specific tasks
- **Full tool access** - Can use all Claude Code tools and file operations  
- **Task delegation** - Invoked via `Task(description, subagent_type="Agent Name")`

## Creating Built-in Agents

### Step-by-Step Agent Creation

1. **Open Claude Code**
2. **Navigate to Agents section** (left sidebar)
3. **Click "Create new agent"**
4. **Configure the agent:**
   - **Name**: Use exact names from the agent files (e.g., "Code Writer")
   - **Description**: Brief description of the agent's purpose
   - **System Prompt**: Copy the system prompt from the agent's `.md` file
   - **Tools**: Enable all tools (agents need full access)

### Agent Permissions and Colors

## Tool Selection Guide
**High-level options (use these first):**
- ☒ **All tools** - Full access to all capabilities
- ☒ **Read-only tools** - Can read files, search, and analyze
- ☒ **Edit tools** - Can modify and create files  
- ☒ **Execution tools** - Can run commands and scripts
- ☒ **MCP tools** - Access to external integrations

## Technical Agents

- [x] **Code Writer** - 🟢 Green - **All tools**
- [x] **Code Reviewer** - 🟡 Yellow - **Read-only tools**
- [x] **Architecture Reviewer** - 🟣 Purple - **Read-only tools**
- [x] **API Designer** - 🔵 Blue - **Read-only + Edit tools** + MCP: context7
- [x] **Database Expert** - 🟠 Orange - **All tools** (needs Bash for migrations)
- [x] **DevOps Engineer** - 🔴 Red - **All tools**
- [x] **Documentation Writer** - 🟤 Brown - **Read-only + Edit tools** + MCP: context7
- [x] **Performance Optimizer** - 🟨 Light Yellow - **Read-only tools** + MCP: ide
- [x] **Quality Assurance Agent** - 🟧 Light Orange - **Read-only tools** + MCP: ide
- [x] **Security Auditor** - 🟥 Light Red - **Read-only tools**
- [x] **Testing Strategist** - 🟩 Light Green - **All tools** (needs execution for tests)
- [x] **Todo Placeholder Detector** - ⬜ White - **Read-only tools**
- [x] **TypeScript Safety Validator** - 🟦 Light Blue - **Read-only tools** + MCP: ide
- [x] **UI UX Reviewer** - 🟪 Light Purple - **Read-only tools**
- [ ] **Business Analyst** - 🟫 Light Brown - **Read-only tools**
- [x] **PRD Writer** - ⬛ Black - **Read-only + Edit tools**
- [x] **Production Readiness Checklist** - 🟢 Lime - **Read-only + Execution tools** + MCP: ide

## Go-to-Market Agents

- [ ] **Product Manager** - 🔵 Navy - **Read-only + Edit tools**
- [ ] **Content Creator** - 🟣 Violet - **Read-only + Edit tools**
- [ ] **Customer Success** - 🟢 Teal - **Read-only tools**
- [ ] **Data Analyst** - 🟡 Gold - **Read-only tools**
- [ ] **Financial Analyst** - 🟠 Amber - **Read-only tools**
- [ ] **Growth Hacker** - 🔴 Crimson - **Read-only tools**
- [ ] **Legal Advisor** - ⚫ Dark Gray - **Read-only tools**
- [ ] **Marketing Strategist** - 🟤 Maroon - **Read-only + Edit tools**
- [ ] **Partnership Manager** - 🟨 Cream - **Read-only tools**
- [ ] **PR Communications** - 🟩 Mint - **Read-only + Edit tools**
- [ ] **Sales Strategist** - 🟧 Peach - **Read-only tools**
- [ ] **SEO Specialist** - 🟥 Pink - **Read-only tools**

## Granular Tool Controls (Only if needed)

**When high-level categories don't fit exactly, use these specific tools:**

**Analysis Agents needing IDE integration:**
- Performance Optimizer: Add `getDiagnostics (ide)`
- TypeScript Safety Validator: Add `getDiagnostics (ide)`  
- Quality Assurance Agent: Add `getDiagnostics (ide)` + `executeCode (ide)`

**Documentation Agents needing library docs:**
- API Designer: Add `get-library-docs (context7)`
- Documentation Writer: Add `get-library-docs (context7)`

**System Agents needing specific execution:**
- Production Readiness Checklist: Add `getDiagnostics (ide)` but disable general Bash

### Tool Permission Guidelines

**Core Analysis Tools (All Agents):**
- **Task** - Essential for agent delegation and task management
- **Read, Glob, Grep, LS** - Basic file navigation and analysis

**Code Modification Tools:**
- **Edit, MultiEdit, Write** - For agents that create or modify files
- **NotebookRead/Edit** - For Jupyter notebook work (if applicable)

**Execution Tools:**
- **Bash** - For DevOps, Database, and Testing agents that run commands
- **executeCode (ide)** - For agents that need to run code snippets

**Research Tools:**
- **WebFetch, WebSearch** - For agents needing external information

**Development Tools:**
- **TodoWrite** - Task tracking (mainly for Code Writer)
- **getDiagnostics (ide)** - For type checking and error analysis
- **get-library-docs (context7)** - For accessing library documentation

**Security Notes:**
- Each agent is granted only the minimal tools needed for their function
- MCP tools require separate server configuration
- Bash access is limited to agents that specifically need command execution
- IDE tools provide safer code execution than direct Bash access

### System Prompt Location

For each agent, find the system prompt in the **"System Prompt"** section of the corresponding `.md` file in:
- `technical-agents/[agent-name].md`
- `go-to-market-agents/[agent-name].md`

## Project-Level Agent Installation

Project-level agents are stored within your project and only available when working in that project.

### Setup Steps

1. In your project root, create the directory structure:
   ```bash
   mkdir -p .claude/slash-commands
   ```

2. Copy the relevant agent `.md` files to `.claude/slash-commands/`

3. The agents will be automatically available when you open the project in Claude Code

## Quick Installation Script

For bulk installation, you can use this PowerShell script (Windows):

```powershell
# Set paths
$sourceDir = "C:\Users\Tom\dev\minerva\dev\claude-code-agents"
$projectDir = "C:\Users\Tom\dev\minerva\.claude\slash-commands"

# Create project directory
New-Item -ItemType Directory -Force -Path $projectDir

# Copy project-level agents
Copy-Item "$sourceDir\technical-agents\architecture-reviewer.md" $projectDir
Copy-Item "$sourceDir\technical-agents\database-expert.md" $projectDir
Copy-Item "$sourceDir\technical-agents\ui-ux-reviewer.md" $projectDir
Copy-Item "$sourceDir\go-to-market-agents\product-manager.md" $projectDir

Write-Host "Project-level agents installed successfully!"
```

## Verifying Installation

1. In Claude Code, type `/` to see available commands
2. Your new agents should appear in the autocomplete list
3. Test an agent by typing its command (e.g., `/code-review`)

## Usage Tips

### Invoking Agents

```bash
# Basic usage
/code-review

# With specific context
/code-review "Review the authentication module for security issues"

# Combining multiple agents
/arch-review "Review system scalability"
/db-review "Optimize related database queries"
```

### Best Practices

1. **Start with high-impact agents**: Begin with code-review, security-audit, and write-prd
2. **Customize prompts**: Modify agent prompts to match your specific needs
3. **Create shortcuts**: For frequently used agents, create shorter aliases
4. **Document usage**: Keep notes on which agents work best for specific tasks

## Troubleshooting

### Agent Not Appearing

1. Restart Claude Code after adding new agents
2. Check file permissions on the `.claude` directory
3. Ensure the `.md` file is properly formatted

### Agent Not Working Correctly

1. Verify the prompt is complete (check for truncation)
2. Test with a simple request first
3. Check for syntax errors in the prompt

### Performance Issues

1. Limit the number of active agents
2. Use project-level agents for project-specific commands
3. Archive unused agents rather than deleting

## Customization Guide

### Modifying Agent Prompts

1. Open the agent's `.md` file
2. Locate the prompt section
3. Modify the instructions while maintaining the structure
4. Save and restart Claude Code

### Creating Custom Agents

Use this template:

```markdown
# [Agent Name] Agent

**Command:** `/command-name`  
**Type:** System-level or Project-level  
**Category:** [Category]

## Purpose

[Brief description of what this agent does]

## Prompt

```
[Your custom prompt here]
```

## Use Cases

1. [Use case 1]
2. [Use case 2]

## Example Usage

```bash
/command-name "Specific request"
```
```

## Maintenance

### Updating Agents

1. Pull latest changes from the repository
2. Compare with your customized versions
3. Merge improvements while preserving customizations

### Backing Up Agents

1. Regularly backup your `.claude` directory
2. Use version control for custom agents
3. Document any modifications made

## Support Resources

- Review individual agent files for detailed documentation
- Check the main README.md for agent categories and use cases
- Customize prompts based on your industry needs
- Share successful customizations with the community

## Next Steps

1. Install your first 5 high-priority agents
2. Test each agent with real tasks
3. Customize prompts based on results
4. Gradually add more agents as needed
5. Create project-specific agents for unique needs