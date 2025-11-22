# PantherOS Documentation Style Guide

This document establishes standards for writing and formatting documentation in the PantherOS project.

## Markdown Formatting Standards

### Document Structure

#### Title Headers
- Use H1 (`#`) for the main title (only one per document)
- Use H2 (`##`) for major sections
- Use H3 (`###`) for subsections
- Use H4 (`####`) sparingly for specific subpoints
- Avoid H5 and H6 headers

```markdown
# Document Title
## Major Section
### Subsection
#### Specific Topic
```

#### Code Blocks
- Always specify the language for syntax highlighting
- Use fenced code blocks with triple backticks
- Add line breaks before and after code blocks

```markdown
Use:
```bash
command example
```

Not:
```
command example
```
```

#### Lists
- Use hyphens for unordered lists: `-`
- Use numbers for ordered lists: `1.`, `2.`, etc.
- Maintain consistent indentation (2 spaces)
- Use blank lines around lists for readability

```markdown
- First item
- Second item
  - Nested item

1. First step
2. Second step
```

### Writing Style

#### Voice and Tone
- Use clear, concise language
- Write in the present tense when possible
- Use active voice when appropriate
- Maintain technical accuracy
- Be specific rather than vague

#### Terminology
- Use consistent technical terms throughout
- Define terms when first introduced
- Use PantherOS-specific terminology consistently:
  - PantherOS (capitalized when referring to the project)
  - nixOS (lowercase when referring to the base system)
  - OpenSpec (capitalized when referring to the methodology)

#### Links and References
- Use descriptive link text rather than URLs
- Cross-reference related documents when appropriate
- Use relative links for internal references
- Use absolute links for external references

```markdown
Use:
- See the [Architecture Guide](./architecture.md) for more details
- For more on this topic, see [module development](./module-development.md)

Not:
- See architecture.md for more details
- Go to ./module-development.md for more information
```

## Documentation Templates

### Guide Template
Use this template for new guide documents:

```markdown
# [Guide Title]

[One-paragraph overview of what this guide covers]

## Prerequisites

[What the reader needs to know or have before reading]

## [Main Section Title]

[Content for the main section]

### [Subsection Title]

[Content for the subsection]

## [Next Section]

[Content for the next section]

## Summary

[Summary of key points covered in the guide]

## Next Steps

[What the reader should do next after reading this guide]
```

### Reference Document Template
Use this template for reference documents:

```markdown
# [Reference Title]

[Brief description of what this document contains]

## [Category/Section 1]

### [Subsection]

[Reference content with specific information]

## [Category/Section 2]

### [Subsection]

[More reference content]

## Quick Lookup

[Quick reference section for common information]
```

### Tutorial Template
Use this template for tutorial documents:

```markdown
# [Tutorial Title]: A Step-by-Step Guide

[Description of what the tutorial will teach the reader to accomplish]

## Prerequisites

[What the reader needs to complete this tutorial]

## Step 1: [Action Name]

[Detailed instructions for the first step]

### Step 1a: [Sub-action if needed]

[Details for sub-step]

## Step 2: [Next Action]

[Detailed instructions for the second step]

## ...

## Summary

[Brief summary of what was accomplished]

## Next Steps

[What the reader might do next after completing this tutorial]

## Troubleshooting

[Common issues and solutions related to the tutorial]
```

### Context Document Template
Use this template for context documents:

```markdown
# [Context Document Title]

[Overview of what context this document provides]

## [Main Context Area]

[Detailed information about this context area]

### Background

[Historical context or background information]

### Current State

[Current situation or implementation]

### Important Details

[Specific information that provides context]
```

## Specific Formatting Rules

### Code and Commands
- Use inline code formatting (`) for file names, commands, and technical terms
- Use bold formatting (**text**) for important terms or UI elements
- Use italics (*text*) for emphasis when appropriate

```markdown
Use:
- Edit the `configuration.nix` file
- Run the **nixos-rebuild** command
- Navigate to the *modules/nixos/* directory
```

### Tables
When using tables, ensure proper formatting:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
| Value 4  | Value 5  | Value 6  |
```

### Notes and Warnings
For special information, use blockquotes:

```markdown
> **Note**: Additional information that might be helpful.

> **Warning**: Critical information that readers should pay attention to.

> **Tip**: Helpful hints or best practices.
```

## Quality Standards

### Completeness
- Include all necessary information for the document type
- Provide examples where helpful
- Consider the reader's likely questions
- Include appropriate cross-references

### Clarity
- Use simple, direct sentences
- Break up complex ideas into smaller sections
- Use headings to organize content logically
- Avoid jargon or explain it when used

### Accuracy
- Verify all technical information
- Keep examples up-to-date with current implementations
- Test commands and procedures where possible
- Review for technical correctness

### Consistency
- Follow the formatting standards in this guide
- Use consistent terminology throughout
- Maintain the same level of detail across similar documents
- Ensure cross-references are accurate and up-to-date

## Template Files

### Creating New Templates
For frequently used document types, store templates in `docs/templates/`:

- `guide-template.md` - Template for guide documents
- `tutorial-template.md` - Template for tutorial documents
- `reference-template.md` - Template for reference documents
- `context-template.md` - Template for context documents

## Review Process

### Self-Review Checklist
Before finalizing a document, check:

- [ ] Title is clear and descriptive
- [ ] Structure follows appropriate template
- [ ] Formatting is consistent and follows standards
- [ ] Content is accurate and up-to-date
- [ ] Links are valid and working
- [ ] Terminology is consistent with project standards
- [ ] Document serves its intended purpose
- [ ] Grammar and spelling are correct

### Peer Review
Consider having another contributor review important documents for:
- Technical accuracy
- Clarity and completeness
- Consistency with project standards
- Formatting and style compliance
```

This document serves as the comprehensive style guide for PantherOS documentation. All documentation should follow the standards outlined here to ensure consistency and quality throughout the project.