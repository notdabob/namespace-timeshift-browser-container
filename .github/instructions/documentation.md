---
applyTo: 
  - "*.md"
  - "docs/*.md"
---

# Documentation Development Instructions

## Documentation Standards and Best Practices

### Markdown Formatting
- Use consistent heading hierarchy (# for main title, ## for sections)
- Include table of contents for documents longer than 3 sections
- Use code blocks with language specification for syntax highlighting
- Include descriptive link text instead of bare URLs
- Use consistent bullet point formatting with dashes (-)

### Content Organization
- Start with clear project overview and purpose statement
- Include "Quick Start" or "Getting Started" section early
- Group related information into logical sections
- Use numbered lists for sequential procedures
- Include cross-references between related documents

### Technical Documentation Guidelines
- Include complete command examples with expected output
- Document all required dependencies and prerequisites
- Provide troubleshooting sections for common issues
- Include both basic and advanced configuration examples
- Document all environment variables and configuration options

### Code Documentation
- Include comprehensive docstrings for all Python functions and classes
- Use type hints where appropriate for function parameters
- Document API endpoints with request/response examples
- Include security considerations for all features
- Provide integration examples for common use cases

### User-Focused Writing
- Write for system administrators with basic Docker knowledge
- Use clear, actionable language for procedures
- Include context and rationale for configuration choices
- Provide alternative approaches for different environments
- Test all documented procedures for accuracy

### Repository Documentation Structure

#### README.md - Primary Entry Point
- Project overview with key benefits highlighted
- One-command deployment instructions
- Feature overview with emoji icons for visual appeal
- Quick troubleshooting section
- Links to detailed documentation

#### PROXMOX-SETUP.md - Deployment Guide
- Detailed step-by-step setup procedures
- Prerequisites and system requirements
- Network configuration requirements
- Troubleshooting common deployment issues
- Advanced configuration options

#### CLAUDE.md - Development Guidance
- Project architecture and component descriptions
- Development workflow and best practices
- Tool usage and ecosystem guidance
- Version management and commit procedures
- File organization and structure documentation

#### docs/CHANGELOG.md - Version History
- Semantic versioning with clear increment rules
- Detailed change descriptions with categories (Added, Fixed, Enhanced)
- Dates and version numbers for all releases
- Breaking changes clearly highlighted
- Migration guidance between versions

### Visual Elements and Formatting

#### Code Examples
- Include complete, runnable command examples
- Show expected output where helpful
- Use syntax highlighting for all code blocks
- Include error examples and troubleshooting steps
- Test all code examples for accuracy

#### Tables and Lists
- Use tables for structured data comparison
- Include headers for all table columns
- Use bullet points for feature lists
- Use numbered lists for sequential procedures
- Align table columns for readability

#### Diagrams and Architecture
- Include ASCII art diagrams for architecture overview
- Use consistent symbols and formatting in diagrams
- Provide both high-level and detailed architecture views
- Include network flow diagrams where applicable
- Keep diagrams simple and focused

### Cross-Reference Standards
- Link to related sections within documents
- Include external links to official documentation
- Provide GitHub issue/PR links for bug reports
- Reference specific commit hashes for important changes
- Include links to related tools and dependencies

### Maintenance and Updates
- Keep documentation current with code changes
- Update version numbers consistently across all files
- Review documentation during code review process
- Test documented procedures with each release
- Archive outdated documentation appropriately

### Security Documentation
- Document default credentials and security implications
- Include security best practices for deployment
- Document all network access requirements
- Provide guidance for production security hardening
- Include security update procedures

### Performance and Troubleshooting
- Document expected resource requirements
- Include performance tuning guidance
- Provide diagnostic commands and procedures
- Document log file locations and formats
- Include recovery procedures for common failures

### Accessibility and Internationalization
- Use clear, simple language for non-native speakers
- Avoid cultural references and idioms
- Include pronunciation guides for technical terms
- Provide alternative text for images and diagrams
- Structure content for screen reader compatibility