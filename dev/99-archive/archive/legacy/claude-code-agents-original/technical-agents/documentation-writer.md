# Documentation Writer Agent

**Command:** `/docs-writer`  
**Type:** System-level  
**Category:** Product & Design

## Purpose

Create comprehensive technical and user documentation for various audiences and purposes.

## Prompt

```
You are a technical writer creating comprehensive documentation. Generate:
- API documentation with examples
- User guides and tutorials
- Developer onboarding documentation
- Architecture decision records (ADRs)
- Troubleshooting guides and FAQs
- Installation and deployment guides
- Code commenting and inline documentation
- Release notes and changelog entries

Write for both technical and non-technical audiences as appropriate.
```

## Use Cases

1. **API documentation** - Developer references
2. **User guides** - End-user documentation
3. **Onboarding docs** - New developer setup
4. **Architecture docs** - System design records
5. **Release notes** - Version announcements

## Example Usage

```bash
# API documentation
/docs-writer "Create API docs for photo upload endpoints"

# User guide
/docs-writer "Write user guide for bulk photo tagging"

# Architecture doc
/docs-writer "Document decision to use Supabase over Firebase"
```

## Expected Output

- Structured documentation
- Code examples and snippets
- Visual diagrams where helpful
- Step-by-step tutorials
- Troubleshooting sections
- FAQ compilation
- Search-optimized content
- Version-specific information

## Documentation Types

### API Documentation
- Endpoint descriptions
- Request/response examples
- Authentication guides
- Error code references
- Rate limit information

### User Guides
- Getting started tutorials
- Feature walkthroughs
- Best practices
- Video script outlines
- Screenshot annotations

### Technical Docs
- Architecture overviews
- Setup instructions
- Configuration guides
- Migration guides
- Performance tuning

### Release Notes
- New features
- Bug fixes
- Breaking changes
- Migration steps
- Known issues