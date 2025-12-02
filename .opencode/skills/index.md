# PantherOS Skills Index

## Overview

This index provides a comprehensive listing of all available skills in pantherOS system, organized by category and functionality.

## Quick Reference

- **Total Skills**: 8
- **Categories**: 5
- **Last Updated**: 2024-12-01

## Categories

### Deployment

#### pantheros-deployment-orchestrator

- **Description**: Automates Phase 3 build, test, and deployment process
- **Path**: `categories/deployment/pantheros-deployment-orchestrator`
- **Tags**: deployment, automation, nixos, build, test
- **Usage**: `skills_deployment-orchestrator <hostname> [options]`
- **Scripts**: deploy.sh, build-all.sh, rollback.sh
- **Status**: Available (migrated)

### Hardware

#### pantheros-hardware-scanner

- **Description**: Scans and documents hardware specifications
- **Path**: `categories/hardware/pantheros-hardware-scanner`
- **Tags**: hardware, scanning, documentation, nixos
- **Usage**: `skills_hardware-scanner <hostname> [options]`
- **Scripts**: scan-hardware.sh, generate-profile.py
- **Status**: Available (migrated)

### Development

#### pantheros-module-generator

- **Description**: Generates NixOS modules with templates
- **Path**: `categories/development/pantheros-module-generator`
- **Tags**: development, modules, nixos, templates
- **Usage**: `skills_module-generator <type> <name> [options]`
- **Scripts**: generate-module.sh, validate-module.py
- **Status**: Available (migrated)

### Security

#### pantheros-secrets-manager

- **Description**: Manages 1Password integration and secrets
- **Path**: `categories/security/pantheros-secrets-manager`
- **Tags**: security, secrets, 1password, opnix
- **Usage**: `skills_secrets-manager <action> [options]`
- **Scripts**: setup-secrets.sh, inventory.sh, rotate.sh
- **Status**: Available (migrated)

### AI Workflow

#### ai-memory-manager

- **Description**: Manages AI memory layer and persistence
- **Path**: `categories/ai-workflow/ai-memory-manager`
- **Tags**: ai, memory, falkordb, graphiti
- **Usage**: `skills_ai-memory-manager <action> [options]`
- **Scripts**: memory-manager.sh, backup.sh, restore.sh
- **Status**: Available (new)

#### ai-memory-pod

- **Description**: Manages AI memory container infrastructure
- **Path**: `categories/ai-workflow/ai-memory-pod`
- **Tags**: ai, podman, containers, deployment
- **Usage**: `skills_ai-memory-pod <action> [options]`
- **Scripts**: deploy-pod.sh, update-pod.sh, monitor-pod.sh
- **Status**: Available (new)

#### ai-memory-plugin

- **Description**: Integrates AI memory with OpenCode SDK
- **Path**: `categories/ai-workflow/ai-memory-plugin`
- **Tags**: ai, plugin, opencode, sdk
- **Usage**: `skills_ai-memory-plugin <action> [options]`
- **Scripts**: install-plugin.sh, configure.sh, test.sh
- **Status**: Available (new)

#### skills-orchestrator

- **Description**: Manages skills lifecycle and integration
- **Path**: `categories/ai-workflow/skills-orchestrator`
- **Tags**: skills, management, integration, orchestration
- **Usage**: `skills_skills-orchestrator <action> [options]`
- **Scripts**: migrate-skills.sh, index-skills.py, validate-skills.py
- **Status**: Available (new)

## Usage

### Using Skills

#### List All Skills

```bash
skills_list
```

#### Filter by Category

```bash
skills_list --category deployment
skills_list --category hardware
skills_list --category development
skills_list --category security
skills_list --category ai-workflow
```

#### Search Skills

```bash
skills_list --search hardware
skills_list --search deployment
skills_list --search memory
```

#### Execute Skills

```bash
# Deployment
skills_deployment-orchestrator yoga
skills_deployment-orchestrator hetzner-vps --dry-run

# Hardware
skills_hardware-scanner zephyrus --output-format json
skills_hardware-scanner yoga --optimize

# Development
skills_module-generator service my-web-service
skills_module-generator profile development-workstation

# Security
skills_secrets-manager setup
skills_secrets-manager inventory
skills_secrets-manager rotate ssh-keys

# AI Workflow
skills_ai-memory-manager start
skills_ai-memory-pod deploy
skills_ai-memory-plugin install
skills_skills-orchestrator migrate
```

### Integration with OpenCode

#### Agent Usage

Agents can invoke skills using `skills_` prefix:

```python
# Example from an agent
result = await task(
    description="Run hardware scanner",
    prompt="skills_hardware-scanner yoga --output-format json",
    subagent_type="general"
)
```

#### Context Integration

Skills receive context from OpenCode agents:

- Agent information and session ID
- User request and project context
- Skill-specific parameters
- Execution environment details

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
│   ├── main.sh          # Main entry point
│   └── helpers.sh       # Helper functions
├── references/           # Reference documentation
│   └── workflow.md      # Workflow documentation
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

## Integration

### OpenCode Skills Plugin

The opencode-skills plugin provides:

- **Automatic Discovery**: Skills are automatically discovered
- **Seamless Execution**: Skills can be executed from agents
- **Context Integration**: Skills receive agent context
- **Performance Tracking**: Skill execution is monitored

### Agent Integration

Agents can:

- **Discover Skills**: Query available skills
- **Execute Skills**: Run skills with parameters
- **Track Performance**: Monitor skill execution
- **Handle Errors**: Manage skill failures gracefully

## Quality Metrics

### Skill Quality

- **Documentation**: All skills have comprehensive documentation
- **Testing**: Skills include tests and validation
- **Integration**: Skills integrate with opencode-skills plugin
- **Performance**: Skills execute efficiently and reliably

### Coverage

- **Categories**: All major domains covered
- **Functionality**: Core capabilities available
- **Integration**: Seamless agent integration
- **Extensibility**: Easy to add new skills

## Future Enhancements

### Planned Skills

- **Performance Monitor**: System performance monitoring
- **Backup Manager**: Automated backup and recovery
- **Security Auditor**: Security audit and compliance checking
- **Documentation Generator**: Automated documentation generation
- **Test Runner**: Comprehensive test execution

### Platform Integration

- **Multi-Platform**: Support for different platforms
- **Cloud Integration**: Cloud service integration
- **API Integration**: External API integration
- **Workflow Integration**: Workflow engine integration

---

_This index is automatically generated. Do not edit manually._
