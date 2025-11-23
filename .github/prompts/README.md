# GitHub Copilot Integration Guide

This guide documents the integration between the `.opencode/` system and GitHub Copilot prompts in `.github/prompts/`.

## Overview

The GitHub Copilot integration adapts the comprehensive `.opencode/` functionality for online coding environments. It provides specialized prompts that mirror the capabilities of the local OpenAgent system while being optimized for GitHub's platform.

## Integration Architecture

### Source System: `.opencode/`
- **Universal Agent**: OpenAgent with workflow orchestration
- **Skills Framework**: 8 specialized skills across 5 categories
- **Workflow Management**: Multi-stage execution with approval gates
- **Delegation System**: Intelligent routing to specialized subagents
- **Context Management**: Static context and dynamic session handling

### Target System: `.github/prompts/`
- **Universal Coding Agent**: Core workflow coordination
- **Skills Executor**: Specialized skill invocation and execution
- **NixOS Module Developer**: Module creation and validation
- **OpenSpec Manager**: Change management and proposal handling
- **Deployment Orchestrator**: Build, test, and deployment automation

## Prompt Mapping

### Core Agent Workflows
| `.opencode/` Component | GitHub Copilot Prompt | Purpose |
|----------------------|----------------------|---------|
| `agent/openagent.md` | `universal-coding-agent.prompt.md` | Universal agent for questions, tasks, workflow coordination |
| `skills/index.md` | `skills-executor.prompt.md` | Execute specialized skills from skills framework |
| `command/module-generator.md` | `nixos-module-developer.prompt.md` | Create and validate NixOS modules |
| `command/openspec-*.md` | `openspec-manager.prompt.md` | Manage OpenSpec change proposals |
| `command/deployment-orchestrator.md` | `deployment-orchestrator.prompt.md` | Handle build, test, deployment workflows |

## Capability Adaptation

### Universal Agent Capabilities
**Original (.opencode/)**:
- 6-stage workflow (Analyze → Approve → Execute → Validate → Summarize → Confirm)
- Skills-first strategy with delegation
- Critical rules enforcement (approval gates, stop on failure, report first)
- Context management and session handling

**Adapted (GitHub Copilot)**:
- Streamlined workflow optimized for online environment
- Safety-first approach with approval requirements
- Integration with GitHub's file system and command execution
- Simplified but comprehensive process

### Skills Framework
**Original (.opencode/)**:
- 8 skills: deployment-orchestrator, hardware-scanner, module-generator, secrets-manager, ai-memory-*, skills-orchestrator
- Automatic skill discovery and execution
- Performance tracking and error handling

**Adapted (GitHub Copilot)**:
- Skill identification based on user request analysis
- Manual skill invocation with clear parameters
- Integration with GitHub's development environment
- Error handling and validation

### Workflow Management
**Original (.opencode/)**:
- Complex multi-stage workflows with decision trees
- Delegation to specialized subagents
- Session management and cleanup
- Context discovery and caching

**Adapted (GitHub Copilot)**:
- Focused workflows for specific tasks
- Direct execution with approval gates
- Simplified context handling
- Integration with GitHub's platform capabilities

## Usage Patterns

### For Universal Coding Tasks
Use `universal-coding-agent.prompt.md` for:
- General questions about pantherOS
- Multi-step task coordination
- Workflow orchestration
- Code analysis and debugging

### For Specialized Skills
Use `skills-executor.prompt.md` for:
- Hardware scanning and documentation
- Module generation
- Deployment automation
- Security management
- AI workflow tasks

### For NixOS Development
Use `nixos-module-developer.prompt.md` for:
- Creating new NixOS modules
- Modifying existing modules
- Module validation and testing
- Following pantherOS patterns

### For Change Management
Use `openspec-manager.prompt.md` for:
- Creating structured change proposals
- Managing implementation tasks
- Review and validation processes
- Documentation and tracking

### For Deployment Operations
Use `deployment-orchestrator.prompt.md` for:
- Building configurations
- Testing deployments
- Managing host-specific deployments
- Rollback and recovery

## Integration Benefits

### Consistency
- Same patterns and principles across both systems
- Consistent error handling and safety measures
- Unified approach to workflow management
- Standardized documentation and validation

### Complementarity
- `.opencode/` for local development with full automation
- `.github/prompts/` for online coding with GitHub Copilot
- Seamless transition between environments
- Shared knowledge and context

### Adaptability
- GitHub Copilot prompts optimized for online constraints
- Maintains core functionality while being platform-appropriate
- Preserves safety and quality standards
- Enables flexible usage patterns

## Best Practices

### Choosing the Right Prompt
1. **Universal Tasks**: Use `universal-coding-agent.prompt.md`
2. **Specialized Skills**: Use `skills-executor.prompt.md`
3. **NixOS Development**: Use `nixos-module-developer.prompt.md`
4. **Change Management**: Use `openspec-manager.prompt.md`
5. **Deployment**: Use `deployment-orchestrator.prompt.md`

### Maintaining Consistency
- Follow the same safety rules across all prompts
- Use consistent approval and validation processes
- Apply pantherOS patterns and conventions
- Document decisions and outcomes

### Integration Workflow
1. **Local Development**: Use `.opencode/` system with full automation
2. **Online Development**: Use `.github/prompts/` with GitHub Copilot
3. **Hybrid Approach**: Combine both systems as needed
4. **Knowledge Sharing**: Transfer context between systems

## Future Enhancements

### Planned Improvements
- Additional specialized prompts for specific workflows
- Enhanced integration with GitHub's features
- Improved context sharing between systems
- Advanced error handling and recovery

### Expansion Opportunities
- More granular skill execution prompts
- Specialized prompts for different domains
- Integration with additional GitHub features
- Enhanced documentation and tutorials

## Maintenance

### Keeping Systems in Sync
- Regular updates to both systems
- Consistent patterns and conventions
- Shared documentation and standards
- Coordinated feature development

### Quality Assurance
- Testing prompts across different scenarios
- Validation of integration points
- User feedback collection and incorporation
- Continuous improvement of both systems

---

**This integration enables seamless usage of pantherOS capabilities across both local and online development environments.**