# PantherOS Skills

## Overview

This directory contains all available skills for pantherOS system, organized by category and designed for seamless integration with opencode-skills plugin.

## Quick Start

### List Available Skills

```bash
skills_list
```

### Run a Skill

```bash
skills_<skill-name> [options]
```

### Get Skill Information

```bash
skills_info <skill-name>
```

## Categories

### Deployment

Skills for building, testing, and deploying NixOS configurations.

- **pantheros-deployment-orchestrator**: Automates Phase 3 build, test, and deployment process
- _More deployment skills coming soon..._

### Hardware

Skills for hardware discovery, documentation, and optimization.

- **pantheros-hardware-scanner**: Scans and documents hardware specifications
- _More hardware skills coming soon..._

### Development

Skills for module development, code generation, and testing.

- **pantheros-module-generator**: Generates NixOS modules with templates
- _More development skills coming soon..._

### Security

Skills for security management, secrets handling, and hardening.

- **pantheros-secrets-manager**: Manages 1Password integration and secrets
- _More security skills coming soon..._

### AI Workflow

Skills for AI memory management and workflow automation.

- **ai-memory-manager**: Manages AI memory layer and persistence
- **ai-memory-pod**: Manages AI memory container infrastructure
- **ai-memory-plugin**: Integrates AI memory with OpenCode SDK
- _More AI workflow skills coming soon..._

## Skill Structure

Each skill follows a consistent structure:

```
skill-name/
├── SKILL.md              # Skill documentation and metadata
├── scripts/              # Executable scripts
│   ├── main.sh          # Main entry point
│   └── helpers.sh       # Helper functions
├── references/           # Reference documentation
│   └── workflow.md      # Workflow documentation
└── assets/              # Additional assets (optional)
```

## Integration with OpenCode

### Plugin Integration

The opencode-skills plugin automatically discovers and integrates skills:

1. **Discovery**: Skills are automatically discovered by plugin
2. **Execution**: Skills can be executed directly from OpenCode agents
3. **Integration**: Skills can call other skills and share context
4. **Monitoring**: Skill execution is logged and monitored

### Agent Usage

Agents can invoke skills using `skills_` prefix:

```python
# Example from an agent
result = await task(
    description="Run hardware scanner",
    prompt="skills_hardware-scanner yoga --output-format json",
    subagent_type="general"
)
```

## Development

### Creating New Skills

1. Choose appropriate category
2. Copy template from `templates/`
3. Implement skill functionality
4. Add documentation and tests
5. Update index with `skill-indexer.py`

### Skill Structure

```
skill-name/
├── SKILL.md              # Skill documentation and metadata
├── scripts/              # Executable scripts
├── references/           # Reference documentation
└── assets/              # Additional assets (optional)
```

### Standards

See `standards/` directory for:

- Skill structure guidelines
- Metadata standards
- Quality criteria
- Development best practices

## Tools

### Skill Indexer

```bash
python tools/skill-indexer.py
```

Regenerates skill index and documentation.

### Skill Validator

```bash
python tools/skill-validator.py <skill-name>
```

Validates skill structure and quality.

### Skill Migrator

```bash
./tools/skill-migrator.sh
```

Migrates skills from project-level to .opencode/skills.

## Contributing

1. Choose appropriate category for new skill
2. Copy template from `templates/`
3. Implement skill functionality
4. Add comprehensive documentation
5. Test with opencode-skills plugin
6. Update index and documentation

## Support

For skill-related issues:

1. Check skill documentation
2. Review standards and guidelines
3. Test with validation tools
4. Check opencode-skills plugin logs

---

_Last updated: 2024-12-01_
