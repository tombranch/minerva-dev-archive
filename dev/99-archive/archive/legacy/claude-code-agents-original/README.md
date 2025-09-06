# Claude Code Built-in Agents for Startup Development

A comprehensive collection of 25 specialized Claude Code built-in agents designed to cover all aspects of startup development, from technical implementation to go-to-market strategy.

## Built-in Agent System

These agents work with Claude Code's built-in agent system where each agent has:
- **Dedicated context window** - Maintains conversation state
- **Specialized system prompt** - Tailored for specific tasks  
- **Full tool access** - Can use all Claude Code tools
- **Task delegation** - Invoked via the Task tool

## Quick Reference

### Technical Agents (13)
| Agent Name | Purpose | Best For |
|------------|---------|----------|
| **Code Writer** | **🔥 WRITES ACTUAL CODE** | **Feature implementation, bug fixes, complete solutions** |
| Code Reviewer | Comprehensive code quality reviews | Pre-deployment reviews, PR analysis |
| PRD Writer | Product Requirements Documents | Feature planning, stakeholder alignment |
| Architecture Reviewer | System design and architecture analysis | Scalability planning, tech decisions |
| Security Auditor | Security vulnerability analysis | Compliance, penetration testing prep |
| Database Expert | PostgreSQL/Supabase optimization | Query optimization, schema design |
| Testing Strategist | Test coverage and strategy | Test planning, QA strategy |
| Performance Optimizer | Frontend/backend performance | Speed optimization, resource usage |
| DevOps Engineer | CI/CD and infrastructure | Deployment automation, monitoring |
| UI/UX Reviewer | User experience analysis | Design feedback, usability testing |
| API Designer | RESTful API design | API architecture, documentation |
| Business Analyst | Business metrics and impact | ROI analysis, KPI tracking |
| Documentation Writer | Technical documentation | API docs, user guides |

### Go-to-Market Agents (12)
| Agent Name | Purpose | Best For |
|------------|---------|----------|
| Marketing Strategist | Marketing campaigns and strategy | Launch planning, brand positioning |
| Sales Strategist | Sales process and pricing | Revenue optimization, funnel design |
| Content Creator | Blog and social content | Content marketing, thought leadership |
| Growth Hacker | Growth experiments and viral mechanics | User acquisition, retention tactics |
| Customer Success | Retention and expansion | Churn reduction, upselling |
| Financial Analyst | Financial modeling and metrics | Fundraising, unit economics |
| Legal Advisor | Compliance and contracts | Terms of service, privacy policy |
| SEO Specialist | Search engine optimization | Organic traffic, keyword strategy |
| Data Analyst | Analytics and insights | Performance measurement, reporting |
| Partnership Manager | Strategic alliances | B2B partnerships, integrations |
| Product Manager | Product roadmap and features | Prioritization, user research |
| PR & Communications | External communications | Media relations, crisis management |

## Installation

See [setup-guide.md](./setup-guide.md) for detailed installation instructions.

### Quick Setup

**Built-in Agent Creation:**
1. Open Claude Code
2. Click the "Agents" section in the left sidebar
3. Click "Create new agent" 
4. Use the system prompts from the agent `.md` files in this repository
5. Configure tools and test the agent

**Recommended First Agents:**
- **Code Writer** (for actual coding tasks)
- **Code Reviewer** (for quality assurance)
- **Security Auditor** (for security reviews)
- **Architecture Reviewer** (for system design)

## Usage Examples

### Using Built-in Agents with Task Tool

**Code Implementation Workflow:**
```
# 1. Implement a new feature
Task("Implement photo batch upload with progress tracking", subagent_type="Code Writer")

# 2. Review the implementation
Task("Review the batch upload code for security issues", subagent_type="Security Auditor")

# 3. Optimize performance
Task("Optimize the batch upload for large files", subagent_type="Performance Optimizer")
```

**Product Development Workflow:**
```
# 1. Create requirements
Task("Write PRD for AI photo tagging feature", subagent_type="PRD Writer")

# 2. Design architecture
Task("Review scalability of the AI processing pipeline", subagent_type="Architecture Reviewer")

# 3. Plan go-to-market
Task("Create launch strategy for manufacturing sector", subagent_type="Marketing Strategist")
```

## Agent Categories

### 🛠️ Development & Engineering
- Code Review, Architecture, Security, Database, Testing, Performance, DevOps, API Design

### 📊 Product & Design
- PRD Writer, Product Manager, UI/UX Reviewer, Documentation Writer

### 💰 Business & Revenue
- Sales Strategy, Financial Analysis, Business Analysis, Customer Success

### 📈 Marketing & Growth
- Marketing Strategy, Content Creation, SEO, Growth Hacking, PR & Communications

### 🤝 Operations & Legal
- Legal Advisor, Partnership Manager, Data Analysis

## Best Practices

1. **Use agents early and often** - Incorporate them into your regular workflow
2. **Combine agents** - Use multiple agents for comprehensive analysis
3. **Customize prompts** - Adapt project-level agents to your specific needs
4. **Track metrics** - Use analytics agents to measure impact
5. **Iterate based on feedback** - Refine agent prompts based on results

## Directory Structure

```
claude-code-agents/
├── README.md (this file)
├── technical-agents/
│   └── [12 technical agent files]
├── go-to-market-agents/
│   └── [12 go-to-market agent files]
└── setup-guide.md
```

## Contributing

To add new agents or improve existing ones:
1. Follow the existing file format
2. Include clear use cases and examples
3. Test the agent thoroughly
4. Update this README with new agents

## Support

For questions or improvements:
- Review individual agent files for detailed prompts
- Check setup-guide.md for installation help
- Customize prompts based on your specific industry or needs