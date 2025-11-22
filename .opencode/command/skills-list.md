---
agent: "@subagents/skills-orchestrator"
description: "Enumerates available skills in .opencode/skills and provides usage information"
syntax: "/skills-list"
examples:
  - "/skills-list"
  - "/skills-list --category deployment"
  - "/skills-list --search hardware"
---

# Skills List Command

## Overview

The `/skills-list` command enumerates all available skills in the `.opencode/skills` directory, providing comprehensive information about skill capabilities, usage patterns, and integration with the opencode-skills plugin.

## Usage

### Syntax
```bash
/skills-list [options]
```

### Options
- `--category <name>`: Filter skills by category
- `--search <term>`: Search skills by name or description
- `--detailed`: Show detailed skill information
- `--usage`: Show usage examples only
- `--migrated`: Show only migrated skills
- `--new`: Show only newly created skills

### Examples

#### List All Skills
```bash
/skills-list
```

#### Filter by Category
```bash
/skills-list --category deployment
/skills-list --category hardware
/skills-list --category development
/skills-list --category security
/skills-list --category ai-workflow
```

#### Search Skills
```bash
/skills-list --search hardware
/skills-list --search deployment
/skills-list --search memory
```

#### Detailed Information
```bash
/skills-list --detailed
```

#### Usage Examples
```bash
/skills-list --usage
```

## Skill Categories

### Deployment Skills
Skills for building, testing, and deploying NixOS configurations.

#### pantheros-deployment-orchestrator
- **Description**: Automates Phase 3 build, test, and deployment process
- **Usage**: `skills_deployment-orchestrator <hostname> [options]`
- **Examples**:
  ```bash
  skills_deployment-orchestrator yoga
  skills_deployment-orchestrator hetzner-vps --dry-run
  skills_deployment-orchestrator zephyrus --build-only
  ```
- **Options**:
  - `--dry-run`: Test configuration without applying
  - `--build-only`: Build without activating
  - `--parallel`: Build multiple hosts in parallel
- **Integration**: Works with hardware scanner and security agent

### Hardware Skills
Skills for hardware discovery, documentation, and optimization.

#### pantheros-hardware-scanner
- **Description**: Scans and documents hardware specifications
- **Usage**: `skills_hardware-scanner <hostname> [options]`
- **Examples**:
  ```bash
  skills_hardware-scanner yoga
  skills_hardware-scanner zephyrus --output-format json
  skills_hardware-scanner hetzner-vps --optimize
  ```
- **Options**:
  - `--output-format <format>`: Output format (markdown|json|yaml)
  - `--optimize`: Include optimization recommendations
  - `--compare`: Compare with previous scans
- **Integration**: Provides data for module generator and deployment orchestrator

### Development Skills
Skills for module development, code generation, and testing.

#### pantheros-module-generator
- **Description**: Generates NixOS modules with templates
- **Usage**: `skills_module-generator <type> <name> [options]`
- **Examples**:
  ```bash
  skills_module-generator service my-web-service
  skills_module-generator module security-hardening
  skills_module-generator profile development-workstation
  ```
- **Options**:
  - `--type <type>`: Module type (service|module|profile)
  - `--template <template>`: Use specific template
  - `--options <options>`: Include specific options
- **Integration**: Works with hardware scanner for optimization

### Security Skills
Skills for security management, secrets handling, and hardening.

#### pantheros-secrets-manager
- **Description**: Manages 1Password integration and secrets
- **Usage**: `skills_secrets-manager <action> [options]`
- **Examples**:
  ```bash
  skills_secrets-manager setup
  skills_secrets-manager inventory
  skills_secrets-manager rotate ssh-keys
  skills_secrets-manager validate
  ```
- **Options**:
  - `--action <action>`: Action to perform (setup|inventory|rotate|validate)
  - `--service <service>`: Target service for action
  - `--force`: Force action without confirmation
- **Integration**: Works with deployment orchestrator and security agent

### AI Workflow Skills
Skills for AI memory management and workflow automation.

#### ai-memory-manager
- **Description**: Manages AI memory layer and persistence
- **Usage**: `skills_ai-memory-manager <action> [options]`
- **Examples**:
  ```bash
  skills_ai-memory-manager start
  skills_ai-memory-manager backup
  skills_ai-memory-manager restore --date 2024-12-01
  skills_ai-memory-manager optimize
  ```
- **Options**:
  - `--action <action>`: Action to perform (start|stop|backup|restore|optimize)
  - `--date <date>`: Date for restore operation
  - `--force`: Force action without confirmation

#### ai-memory-pod
- **Description**: Manages AI memory container infrastructure
- **Usage**: `skills_ai-memory-pod <action> [options]`
- **Examples**:
  ```bash
  skills_ai-memory-pod deploy
  skills_ai-memory-pod update
  skills_ai-memory-pod status
  skills_ai-memory-pod logs --service falkordb
  ```
- **Options**:
  - `--action <action>`: Action to perform (deploy|update|status|logs)
  - `--service <service>`: Target service (falkordb|graphiti|memory-api)
  - `--follow`: Follow log output

#### ai-memory-plugin
- **Description**: Integrates AI memory with OpenCode SDK
- **Usage**: `skills_ai-memory-plugin <action> [options]`
- **Examples**:
  ```bash
  skills_ai-memory-plugin install
  skills_ai-memory-plugin configure
  skills_ai-memory-plugin test
  skills_ai-memory-plugin status
  ```
- **Options**:
  - `--action <action>`: Action to perform (install|configure|test|status)
  - `--config <file>`: Configuration file to use
  - `--verbose`: Verbose output

## Skill Integration

### OpenCode Skills Plugin Integration

#### Automatic Discovery
The opencode-skills plugin automatically discovers skills in `.opencode/skills/`:
1. **Scanning**: Plugin scans skill directories on startup
2. **Indexing**: Skills are indexed for fast lookup
3. **Registration**: Skills are registered with the plugin
4. **Validation**: Skill structure and metadata are validated

#### Execution Patterns
Skills can be executed using the `skills_` prefix:
```bash
# Direct skill execution
skills_<skill-name> [arguments]

# From OpenCode agents
result = await task(
    description="Execute skill",
    prompt="skills_hardware-scanner yoga --output-format json",
    subagent_type="general"
)
```

#### Context Integration
Skills receive context from OpenCode agents:
```python
# Skill context structure
skill_context = {
    "agent": "agent-name",
    "session_id": "session-identifier",
    "user_request": "original user request",
    "project_context": {
        "repository": "/path/to/project",
        "branch": "current-branch",
        "working_directory": "current-dir"
    },
    "skill_parameters": {
        # Skill-specific parameters
    }
}
```

### Agent Integration

#### Skills-First Routing
OpenAgent follows skills-first routing:
1. **Skill Discovery**: Check for matching skill in `.opencode/skills/`
2. **Skill Execution**: Use skill if available and appropriate
3. **Fallback**: Delegate to subagent or use MCP if no skill exists

#### Skill Performance Tracking
Track skill execution for optimization:
```python
# Skill performance metrics
skill_metrics = {
    "skill_name": "hardware-scanner",
    "execution_count": 15,
    "success_rate": 0.93,
    "average_duration": 45.2,
    "last_execution": "2024-12-01T10:30:00Z",
    "user_satisfaction": 4.7
}
```

## Skill Development

### Creating New Skills

#### Skill Structure
```
skill-name/
├── SKILL.md              # Documentation and metadata
├── scripts/              # Executable scripts
│   ├── main.sh          # Main entry point
│   └── helpers.sh       # Helper functions
├── references/           # Reference documentation
│   └── workflow.md      # Workflow documentation
└── assets/              # Additional assets (optional)
```

#### Skill Metadata
```yaml
# SKILL.md frontmatter
---
name: skill-name
display_name: Human Readable Skill Name
description: Brief description of what the skill does
version: 1.0.0
category: deployment|hardware|development|security|ai-workflow
tags: ["tag1", "tag2", "tag3"]
author: skill-author
created_date: 2024-12-01
last_modified: 2024-12-01
dependencies:
  skills: ["required-skill-1", "required-skill-2"]
  tools: ["tool1", "tool2"]
  packages: ["package1", "package2"]
entry_point: scripts/main.sh
execution_mode: sync|async|interactive
timeout: 300
quality_score: 0.9
test_coverage: 0.8
documentation_complete: true
opencode_compatible: true
plugin_required: opencode-skills
api_version: v1
---
```

#### Skill Development Guidelines
1. **Single Purpose**: Each skill should do one thing well
2. **Clear Interface**: Well-defined inputs and outputs
3. **Error Handling**: Robust error handling and recovery
4. **Documentation**: Comprehensive documentation and examples
5. **Testing**: Include tests and validation
6. **Integration**: Design for OpenCode integration

### Skill Templates

#### Basic Skill Template
```bash
#!/bin/bash
# scripts/main.sh - Basic skill template

set -euo pipefail

# Default values
ACTION=""
VERBOSE=false
FORCE=false

# Help function
show_help() {
    cat << EOF
Usage: skills_<skill-name> [options] <action>

Actions:
  help        Show this help message
  status      Show current status
  execute     Execute main functionality

Options:
  --verbose    Enable verbose output
  --force      Force action without confirmation
  --help       Show this help message

Examples:
  skills_<skill-name> status
  skills_<skill-name> execute --verbose
EOF
}

# Logging functions
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - $1"
    fi
}

# Validation functions
validate_dependencies() {
    local missing_deps=()
    
    # Check for required tools
    for tool in tool1 tool2 tool3; do
        if ! command -v "$tool" &> /dev/null; then
            missing_deps+=("$tool")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Core functions
show_status() {
    log_info "Checking skill status..."
    
    # Status check logic here
    echo "Status: Running"
    echo "Version: 1.0.0"
    echo "Last execution: $(date)"
}

execute_action() {
    log_info "Executing main functionality..."
    
    # Main execution logic here
    validate_dependencies
    
    if [[ "$FORCE" != "true" ]]; then
        read -p "Continue with execution? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Execution cancelled"
            exit 0
        fi
    fi
    
    # Perform the action
    log_info "Action completed successfully"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        status|execute|help)
            ACTION="$1"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute action
case "$ACTION" in
    help)
        show_help
        ;;
    status)
        show_status
        ;;
    execute)
        execute_action
        ;;
    "")
        log_error "No action specified"
        show_help
        exit 1
        ;;
    *)
        log_error "Unknown action: $ACTION"
        show_help
        exit 1
        ;;
esac
```

## Skill Management

### Skill Migration
The skills orchestrator manages migration from project-level to `.opencode/skills`:
1. **Inventory**: Scan existing skills in `/skills/`
2. **Categorization**: Organize skills by category
3. **Migration**: Move skills to appropriate categories
4. **Metadata Update**: Enhance skill metadata
5. **Index Generation**: Create comprehensive skill index

### Skill Validation
Validate skill structure and quality:
```bash
# Validate skill structure
skills_validate <skill-name>

# Validate all skills
skills_validate --all

# Validate skill quality
skills_validate --quality <skill-name>
```

### Skill Testing
Test skill functionality:
```bash
# Test skill execution
skills_test <skill-name> --action <test-action>

# Test skill integration
skills_test --integration <skill-name>

# Test all skills
skills_test --all
```

## Troubleshooting

### Common Issues

#### Skill Not Found
**Problem**: Skill not found in `.opencode/skills/`
**Solution**: 
1. Check skill spelling
2. Verify skill exists in correct category
3. Run `/skills-list` to see available skills

#### Skill Execution Failed
**Problem**: Skill failed to execute
**Solution**:
1. Check skill dependencies
2. Verify skill permissions
3. Review skill logs
4. Test skill in isolation

#### Integration Issues
**Problem**: Skill not integrating with OpenCode
**Solution**:
1. Verify skill metadata format
2. Check opencode-skills plugin status
3. Validate skill structure
4. Restart plugin if needed

### Debug Mode
Enable debug mode for troubleshooting:
```bash
# Enable debug output
export SKILLS_DEBUG=true

# Run skill with debug
skills_<skill-name> --verbose --debug
```

### Log Analysis
Analyze skill execution logs:
```bash
# View skill logs
tail -f ~/.local/share/skills/logs/<skill-name>.log

# View all skill logs
tail -f ~/.local/share/skills/logs/skills.log
```

---

The `/skills-list` command provides comprehensive skill enumeration and management capabilities for the pantherOS skills ecosystem.