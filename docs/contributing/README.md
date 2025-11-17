# Contributing to pantherOS

Welcome to the pantherOS project! This directory contains guides for contributing to the project.

## 🔴 Start Here: Spec-Driven Development

**This project uses Spec-Driven Development (SDD).** Before contributing:

1. **Read the [Spec-Driven Workflow Guide](spec-driven-workflow.md)** 📋 (Required)
2. Check for existing specs in [`/docs/specs/`](../specs/)
3. Create or update specs BEFORE making code changes

## Contributing Guides

### Essential Reading

- **[Spec-Driven Workflow Guide](spec-driven-workflow.md)** 🔴 **MUST READ**
  - Global rules for all development
  - Complete workflow with examples
  - Behavior guidelines for contributors and AI agents
  - TODO format and spec references
  - Troubleshooting and FAQ

### Additional Guides

More guides will be added here as the project evolves:

- Development environment setup (planned)
- Testing guide (planned)
- Code review guidelines (planned)
- Documentation standards (planned)

## Quick Start for New Contributors

### 1. Understand the Project

- Read the [main README](../../README.md)
- Review the [pantherOS Constitution](../../.specify/memory/constitution.md)
- Browse existing [feature specifications](../specs/)

### 2. Set Up Your Environment

- Install Nix and enable flakes
- Clone the repository
- Review development shell options in `flake.nix`
- Set up your IDE (VS Code or Neovim recommended)

### 3. Pick a Task

**Option A: From Existing Specs**
- Browse [`/docs/specs/`](../specs/) for features in progress
- Find a spec with `tasks.md` that has unclaimed tasks
- Comment on the related issue to claim a task

**Option B: Propose New Feature**
- Create an issue using the [feature request template](../../.github/ISSUE_TEMPLATE/feature_request.md)
- Use `/speckit.specify` to create a specification
- Discuss with maintainers before implementation

**Option C: Fix Documentation**
- Documentation improvements are always welcome
- Small fixes don't require specs
- Submit PR with clear description

### 4. Create a Specification (for features)

**Use Spec Kit commands:**

```
/speckit.specify [Describe your feature]
```

This creates a specification in `/docs/specs/NNN-feature-name/`. Then:

```
/speckit.clarify     # Fill in gaps (recommended)
/speckit.plan        # Create technical design
/speckit.tasks       # Break down into tasks
```

See [Spec-Driven Workflow Guide](spec-driven-workflow.md) for complete details.

### 5. Implement

- Work on ONE task at a time
- Reference the spec in your commits and PR
- Update documentation in the same PR
- Test your changes thoroughly

### 6. Submit Pull Request

- Use the [PR template](../../.github/PULL_REQUEST_TEMPLATE.md)
- Reference related spec and task
- Ensure all checklist items completed
- Request review from maintainers

## Contribution Types

### Code Contributions

**Requires specification:**
- ✅ New features
- ✅ Major refactoring
- ✅ Breaking changes
- ✅ Architecture changes

**No spec needed:**
- ⚪ Trivial bug fixes (< 10 lines)
- ⚪ Typo corrections
- ⚪ Routine dependency updates

### Documentation Contributions

**Always welcome:**
- Fixing typos and errors
- Improving clarity
- Adding examples
- Updating outdated content

**Process:**
- Small fixes: Direct PR
- New documentation: Create issue or spec first
- Major restructuring: Discuss with maintainers

### Specification Contributions

**Help improve specs:**
- Review existing specs for clarity
- Add missing details or examples
- Clarify ambiguous requirements
- Propose improvements to spec templates

## Code of Conduct

### Be Respectful

- Treat all contributors with respect
- Welcome newcomers
- Be patient with questions
- Provide constructive feedback

### Be Collaborative

- Discuss before making major changes
- Share knowledge and help others
- Review others' contributions
- Acknowledge contributions

### Follow the Process

- Use Spec-Driven Development workflow
- Follow code and documentation standards
- Write clear commit messages
- Respond to review feedback

## Getting Help

### Documentation

- [Spec-Driven Workflow Guide](spec-driven-workflow.md) - SDD methodology
- [Feature Specifications](../specs/) - Existing specs
- [Spec Kit Tools](../tools/) - Tool documentation
- [Master Topic Map](../../00_MASTER_TOPIC_MAP.md) - Complete docs index

### Community

- **GitHub Issues** - Report bugs, request features
- **GitHub Discussions** - Ask questions, share ideas
- **Pull Requests** - Submit contributions

### Maintainers

- See [README.md](../../README.md) for project maintainers
- Tag maintainers in issues/PRs for questions
- Allow 24-48 hours for response

## Project Principles

From the [pantherOS Constitution](../../.specify/memory/constitution.md):

1. **Declarative Configuration** - All system state in Nix expressions
2. **Modular Architecture** - Clear separation of concerns
3. **Reproducibility** - Deterministic builds
4. **Security by Default** - Minimal attack surface
5. **Testing Before Deployment** - Validate changes
6. **Documentation Standards** - Comprehensive docs

## Recognition

We value all contributions:

- Code contributions
- Documentation improvements
- Specification work
- Bug reports
- Feature ideas
- Community support

Thank you for contributing to pantherOS! 🎉

---

**Questions?** Open an issue or discussion, and we'll help you get started.

**Ready to contribute?** Read the [Spec-Driven Workflow Guide](spec-driven-workflow.md) and dive in!
