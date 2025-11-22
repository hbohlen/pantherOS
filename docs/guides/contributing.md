# Contributing to PantherOS

We welcome contributions to PantherOS! This guide explains how to get involved and contribute effectively.

## Code of Conduct

Please follow our Code of Conduct to ensure a welcoming and respectful environment for all contributors.

## How to Contribute

There are many ways to contribute to PantherOS:

### Reporting Issues
- Use the GitHub issue tracker to report bugs
- Provide detailed information about the issue
- Include environment information and steps to reproduce
- Check existing issues before opening a new one

### Improving Documentation
- Fix typos and grammatical errors
- Clarify unclear documentation
- Add examples or tutorials
- Improve organization and navigation

### Code Contributions
- Fix bugs (see the "good first issue" tag)
- Implement new features
- Improve existing functionality
- Write tests

### Proposing Changes
- Use the OpenSpec framework for major changes
- Propose changes through the proper channels
- Follow the established change management process

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork to your local machine
3. Create a development branch
4. Make your changes
5. Test your changes thoroughly
6. Commit your changes with clear, descriptive messages
7. Push your changes to your fork
8. Create a pull request to the main repository

## Development Workflow

### Using OpenSpec for Changes

For significant changes, PantherOS uses the OpenSpec methodology:

1. **Proposal**: Create a change proposal in `openspec/changes/`
2. **Tasks**: Define specific tasks to implement the change
3. **Implementation**: Implement the change following the tasks
4. **Validation**: Verify that requirements are met

### Git Workflow

- Create a new branch for each contribution
- Use descriptive branch names
- Write clear, concise commit messages
- Include "Fixes #issue-number" in commit messages when applicable
- Keep commits focused on a single change

Example commit message:
```
modules: Add Btrfs optimization settings for servers

- Add compression and optimization settings for server workloads
- Include SSD-specific optimizations
- Update documentation for the new options

Fixes #123
```

### Testing

- Test changes in a virtual environment before applying to real systems
- Verify that modules work with the enable/disable pattern
- Test dependencies between modules
- Ensure changes don't break existing functionality

## Documentation Standards

### Markdown Style

- Use consistent heading hierarchy
- Use proper code block syntax with language specification
- Link to related documentation when appropriate
- Use descriptive alt text for images

### Writing Style

- Use clear, concise language
- Write in the present tense
- Use active voice when possible
- Be specific and avoid ambiguous terms

## Technical Requirements

### Nix Code Standards

- Follow Nixpkgs coding conventions
- Use appropriate option types
- Implement proper error handling
- Include helpful descriptions for options
- Use consistent naming conventions

### Module Development

- Follow the module patterns described in the Module Development Guide
- Use the `pantherOS.` prefix for all options
- Implement enable/disable patterns using `mkEnableOption`
- Handle dependencies correctly with `mkIf`

## Community

- Join our community discussions
- Ask questions when you're unsure
- Help other contributors when you can
- Be respectful and patient with others

## Questions?

If you have questions about contributing to PantherOS:
- Check the existing documentation
- Open an issue for technical questions
- Reach out to the maintainers

Thank you for your interest in contributing to PantherOS!