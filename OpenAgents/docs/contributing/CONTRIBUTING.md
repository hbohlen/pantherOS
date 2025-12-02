# Contributing to OpenAgents

Thank you for your interest in contributing! This guide will help you add new components to the registry.

## Quick Start

1. Fork the repository
2. Create a new branch for your feature
3. Add your component
4. Test it works
5. Submit a pull request

## Adding New Components

### Component Types

- **Agents** (`.opencode/agent/*.md`) - Main AI agents
- **Subagents** (`.opencode/agent/subagents/*.md`) - Specialized helpers
- **Commands** (`.opencode/command/*.md`) - Slash commands
- **Tools** (`.opencode/tool/*/index.ts`) - Utility tools
- **Plugins** (`.opencode/plugin/*.ts`) - Integrations
- **Contexts** (`.opencode/context/**/*.md`) - Context files

### Component Structure

#### For Markdown Files (Agents, Commands, Contexts)

All markdown files should include YAML frontmatter:

```markdown
---
description: "Brief description of what this does"
mode: primary  # For agents only
temperature: 0.1  # Optional - for agents only
tools:  # For agents only
  read: true
  edit: true
  write: true
permissions:  # Optional
  bash:
    "*": "deny"
---

# Component Name

Your component content here...
```

**Required fields:**
- `description` - Brief description (all components)

**Agent-specific fields:**
- `mode` - Agent mode (primary, secondary, etc.)
- `model` - AI model to use
- `temperature` - Temperature setting
- `tools` - Available tools
- `permissions` - Security permissions

#### For TypeScript Files (Tools, Plugins)

Include JSDoc comments at the top:

```typescript
/**
 * Tool Name
 * 
 * Brief description of what this tool does
 */

export function myTool() {
  // Implementation
}
```

### File Naming Conventions

- **kebab-case** for file names: `my-new-agent.md`
- **PascalCase** for TypeScript types/interfaces
- **camelCase** for variables and functions

### Adding Your Component

1. **Create the component file** in the appropriate directory:
   ```bash
   # Example: Adding a new agent
   touch .opencode/agent/my-new-agent.md
   ```

2. **Add frontmatter and content** following the structure above

3. **Test your component**:
   ```bash
   # Validate structure
   ./scripts/validate-component.sh
   ```

4. **Update the registry** (automatic on merge to main):
   ```bash
   # Manual update (optional)
   ./scripts/register-component.sh
   ```

## Component Categories

When adding components, they're automatically categorized:

- **core** - Essential components included in minimal installs
- **extended** - Additional features for developer profile
- **advanced** - Experimental or specialized components

The auto-registration script assigns categories based on component type and location.

## Testing Your Component

### Local Testing

1. **Install locally**:
   ```bash
   # Test the installer
   ./install.sh --list
   ```

2. **Validate structure**:
   ```bash
   ./scripts/validate-component.sh
   ```

3. **Test with OpenCode**:
   ```bash
   opencode --agent your-new-agent
   ```

### Automated Testing

When you submit a PR, GitHub Actions will:
- Validate component structure
- Update the registry
- Run validation checks

## Pull Request Guidelines

### PR Title Format

Use conventional commits:
- `feat: add new agent for X`
- `fix: correct issue in Y command`
- `docs: update Z documentation`
- `chore: update dependencies`

### PR Description

Include:
1. **What** - What component are you adding/changing?
2. **Why** - Why is this useful?
3. **How** - How does it work?
4. **Testing** - How did you test it?

Example:
```markdown
## What
Adds a new `database-agent` for managing database migrations.

## Why
Automates common database tasks and ensures migration safety.

## How
- Scans migration files
- Validates migration order
- Runs migrations with rollback support

## Testing
- [x] Validated with `./scripts/validate-component.sh`
- [x] Tested with PostgreSQL and MySQL
- [x] Tested rollback scenarios
```

## Component Dependencies

If your component depends on others, declare them in the registry:

```json
{
  "id": "my-component",
  "dependencies": ["tool:env", "agent:task-manager"]
}
```

The installer will automatically install dependencies.

## Registry Auto-Update

The registry is automatically updated when:
- You push to `main` branch
- Changes are made to `.opencode/` directory

The GitHub Action:
1. Scans all components
2. Extracts metadata
3. Updates `registry.json`
4. Commits changes

You don't need to manually edit `registry.json`!

## Code Style

### Markdown
- Use clear, concise language
- Include examples
- Add code blocks with syntax highlighting
- Use proper heading hierarchy

### TypeScript
- Follow existing code style
- Add JSDoc comments
- Use TypeScript types (no `any`)
- Export functions explicitly

### Bash Scripts
- Use `set -e` for error handling
- Add comments for complex logic
- Use meaningful variable names
- Include help text

## Questions?

- **Issues**: Open an issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Security**: Email security issues privately

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🎉
