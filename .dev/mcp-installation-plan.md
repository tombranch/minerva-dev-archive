# 🚀 MCP Server Installation Plan for Claude Code

**Objective**: Install and configure essential MCP servers to enhance Claude Code capabilities
**Status**: Ready to execute
**Estimated Time**: 15-20 minutes

---

## 📋 **Installation Strategy**

### **Phase 1: Essential MCP Servers (Start Here)**
Install the most useful servers first to get immediate benefits.

### **Phase 2: Advanced MCP Servers**
Add specialized servers for enhanced functionality.

### **Phase 3: API-Based Servers**
Install servers requiring API keys (optional).

---

## 🎯 **PHASE 1: ESSENTIAL SERVERS** (Start with these)

### 1. **Context7** - Documentation & Web Content Access 🔥
**Why Essential**: Provides real-time, up-to-date documentation access
```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp@latest
```
**Test**: Use "use context7" in Claude Code prompts

### 2. **Filesystem** - Local File Access 📁
**Why Essential**: Access your local development files
```bash
claude mcp add filesystem -s user -- npx -y @modelcontextprotocol/server-filesystem ~/dev ~/Documents ~/Downloads
```
**Test**: Ask Claude to "list files in my ~/dev directory"

### 3. **Convex** - Database Management 🗄️
**Why Essential**: You already have Convex installed, just need MCP integration
```bash
claude mcp add convex -s user -- npx -y convex@latest mcp start
```
**Test**: Ask Claude to query your Convex deployment

### 4. **Puppeteer** - Browser Automation 🎭
**Why Essential**: Web automation and testing capabilities
```bash
claude mcp add puppeteer -s user -- npx -y @modelcontextprotocol/server-puppeteer
```
**Test**: Ask Claude to "take a screenshot of google.com"

---

## 🚀 **PHASE 2: ADVANCED SERVERS** (After Phase 1)

### 5. **GitHub** - Repository Integration 🐙
**Why Useful**: Official GitHub integration for repository management
```bash
claude mcp add github -s user -- npx -y @github/github-mcp-server
```
**Requirements**: GitHub token (use existing gh cli auth)

### 6. **Sequential Thinking** - Enhanced Reasoning 🧠
**Why Useful**: Improved logical reasoning capabilities
```bash
claude mcp add sequential-thinking -s user -- npx -y @modelcontextprotocol/server-sequential-thinking
```

### 7. **Web Fetch** - HTTP Requests 🌐
**Why Useful**: Make HTTP requests and API calls
```bash
claude mcp add fetch -s user -- npx -y @kazuph/mcp-fetch
```

---

## 🔑 **PHASE 3: API-BASED SERVERS** (Optional - Requires API Keys)

### 8. **Firecrawl** - Web Scraping 🔥
**Requirements**: API key from https://firecrawl.dev/app/api-keys
```bash
claude mcp add firecrawl -s user -- env FIRECRAWL_API_KEY=yfc-3897898914f6423aa8005384677ff39a npx -y firecrawl-mcp
```

### 9. **Brave Search** - Web Search 🔍
**Requirements**: API key from https://brave.com/search/api/
```bash
claude mcp add brave-search -s user -- env BRAVE_API_KEY=your-api-key npx -y @modelcontextprotocol/server-brave-search
```

---

## 📝 **STEP-BY-STEP EXECUTION PLAN**

### **✅ Pre-Installation Checklist**
- [ ] Claude Code is working properly (no Windows path errors)
- [ ] You have internet connectivity
- [ ] npm/npx is available in your PATH

### **🎯 Phase 1 Execution (15 minutes)**

#### **Step 1: Install Context7** (2 minutes)
```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp@latest
```
**Expected**: Download and installation success message
**Test**: Start Claude Code, type `/mcp` to verify

#### **Step 2: Install Filesystem** (2 minutes)
```bash
claude mcp add filesystem -s user -- npx -y @modelcontextprotocol/server-filesystem ~/dev ~/Documents ~/Downloads
```
**Expected**: Server added to global user config
**Test**: Ask Claude "what files are in my ~/dev directory?"

#### **Step 3: Install Convex** (3 minutes)
```bash
claude mcp add convex -s user -- npx -y convex@latest mcp start
```
**Expected**: Convex MCP server integration success
**Test**: Ask Claude about your Convex deployment status

#### **Step 4: Install Puppeteer** (8 minutes - downloads Chromium)
```bash
claude mcp add puppeteer -s user -- npx -y @modelcontextprotocol/server-puppeteer
```
**Expected**: Chromium download (large), then success
**Test**: Ask Claude to take a screenshot of a website

#### **Step 5: Verify Installation**
```bash
claude mcp list
```
**Expected**: List of 4 installed MCP servers
**Test**: In Claude Code, use `/mcp` command

---

## 🔧 **Troubleshooting Commands**

### **Check Installation Status**
```bash
# List all installed MCP servers
claude mcp list

# Check Claude Code MCP status
# (run inside Claude Code session)
/mcp
```

### **Common Issues & Fixes**

#### **Issue**: "Command not found: claude"
**Fix**: Make sure Claude Code CLI is installed
```bash
npm install -g @anthropic-ai/claude-code
```

#### **Issue**: MCP server not appearing in Claude Code
**Fix**: Restart Claude Code session after installation

#### **Issue**: Permission errors during installation
**Fix**: Check npm permissions or use sudo (not recommended)

#### **Issue**: Network timeout during Puppeteer install
**Fix**: Run on stable internet connection, Puppeteer downloads ~100MB Chromium

---

## 🎯 **Success Metrics**

### **After Phase 1, you should be able to:**
- ✅ Use `/mcp` in Claude Code to see 4 active servers
- ✅ Ask Claude to access documentation with "use context7"
- ✅ Have Claude read local files from your ~/dev directory
- ✅ Query your Convex database through Claude
- ✅ Take screenshots of websites via Claude

### **Enhanced Capabilities You'll Gain:**
- 📚 **Real-time documentation** access (no more outdated APIs)
- 📁 **Local file system** integration
- 🗄️ **Database querying** through natural language
- 🎭 **Web automation** capabilities
- 🚀 **Significantly enhanced Claude Code experience**

---

## 📋 **Quick Reference Card**

### **Essential Commands**
```bash
# Install Phase 1 (copy/paste block)
claude mcp add context7 -- npx -y @upstash/context7-mcp@latest
claude mcp add filesystem -s user -- npx -y @modelcontextprotocol/server-filesystem ~/dev ~/Documents ~/Downloads
claude mcp add convex -s user -- npx -y convex@latest mcp start
claude mcp add puppeteer -s user -- npx -y @modelcontextprotocol/server-puppeteer

# Verify installation
claude mcp list
```

### **Test Commands (in Claude Code)**
```bash
/mcp                           # List active MCP servers
"use context7 to find..."      # Test documentation access
"list files in ~/dev"          # Test filesystem access
"query my convex deployment"   # Test database access
"take screenshot of google"    # Test browser automation
```

---

## 🎉 **Ready to Start!**

**Recommended approach:**
1. **Start with Phase 1** - Install the 4 essential servers
2. **Test each one** as you go to ensure they're working
3. **Once Phase 1 is solid**, proceed to Phase 2 for advanced features
4. **Phase 3 is optional** - only if you need web scraping/search

**Time Investment**: 15-20 minutes for massive Claude Code enhancement

**Ready?** Copy the Phase 1 commands above and start with Context7! 🚀

---

*MCP Installation Plan created with [Claude Code](https://claude.ai/code) - Minerva Development Environment*
