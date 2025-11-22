# AGENTS.md Files Audit and Update Plan

## Executive Summary

This audit reveals significant gaps in the AGENTS.md file ecosystem for the pantherOS repository. While the root `AGENTS.md` exists and provides good project-level guidance, **7 critical subdirectory AGENTS.md files are missing**, and the referenced OpenSpec AGENTS.md doesn't exist. Additionally, the OpenCode agent files in `.opencode/agent/` lack essential context about the project structure and requirements.

**Critical Issues:**
- 8 AGENTS.md files missing (including OpenSpec)
- Root AGENTS.md lacks integration points with existing skills
- OpenCode agents lack pantherOS-specific context
- No subdirectory-specific guidance for modular development
- Disconnect between referenced OpenSpec workflow and actual files

## Current State Analysis

### Existing AGENTS.md Files

| File | Status | Quality | Last Updated | Notes |
|------|--------|---------|--------------|-------|
| `/AGENTS.md` | ✅ Exists | Good | Current | Comprehensive but needs updates |
| `/openspec/AGENTS.md` | ❌ Missing | - | - | Referenced but doesn't exist |
| `/docs/AGENTS.md` | ❌ Missing | - | - | Needed for documentation work |
| `/modules/AGENTS.md` | ❌ Missing | - | - | Critical for module development |
| `/hosts/AGENTS.md` | ❌ Missing | - | - | Needed for host configuration |
| `/home/AGENTS.md` | ❌ Missing | - | - | Required for home-manager work |
| `/overlays/AGENTS.md` | ❌ Missing | - | - | Package overlay guidance needed |
| `/scripts/AGENTS.md` | ❌ Missing | - | - | Script development guidance needed |

### OpenCode Agent Files Status

| File | Status | Content Quality | Context Completeness | Notes |
|------|--------|----------------|---------------------|-------|
| `/opencode/agent/architect.md` | ✅ Exists | Basic | ❌ Needs project context | References docs that may not exist |
| `/opencode/agent/engineer.md` | ✅ Exists | Basic | ❌ Needs pantherOS context | Generic Nix guidance |
| `/opencode/agent/librarian.md` | ✅ Exists | Basic | ❌ Missing project integration | Needs access patterns |
| `/opencode/agent/reviewer.md` | ✅ Exists | Basic | ❌ Needs task context | References tasks that may not exist |

### OpenSpec Command Files Status

| File | Status | Quality | Integration | Notes |
|------|--------|---------|-------------|-------|
| `/opencode/command/openspec-proposal.md` | ✅ Exists | Good | ❌ No actual OpenSpec integration | Commands reference non-existent files |
| `/opencode/command/openspec-apply.md` | ✅ Exists | Good | ❌ No actual OpenSpec integration | Same issue |
| `/opencode/command/openspec-archive.md` | ✅ Exists | Good | ❌ No actual OpenSpec integration | Same issue |

## Detailed Gap Analysis

### Root AGENTS.md Issues

**Strengths:**
- Good project overview and structure
- Clear reading order guidance
- Practical commands and examples
- Safety warnings and emergency procedures

**Missing Integration:**
- **Skills Integration**: No reference to the 4 existing skills in `/skills/` directory
- **OpenSpec Integration**: Mentions OpenSpec but file doesn't exist
- **Phase Context**: Could better integrate with Phase 1-3 structure from brief.md
- **Tool-Specific Guidance**: Missing specific guidance for OpenCode agents
- **Modular Development**: Could expand on single-concern principle for agents

**Specific Missing Content:**
- Integration with pantheros-deployment-orchestrator skill
- Integration with pantheros-hardware-scanner skill  
- Integration with pantheros-module-generator skill
- Integration with pantheros-secrets-manager skill
- OpenSpec workflow guidance
- Task tracking integration with OpenCode agents

### Missing Subdirectory AGENTS.md Analysis

#### `/openspec/AGENTS.md` (Critical)
**Required Content:**
- OpenSpec change proposal workflow
- Specification format requirements
- Integration with pantherOS modular structure
- Change management process
- Specification validation procedures

**Context Needed:**
- How OpenSpec integrates with Phase 1-3 workflow
- Relationship between OpenSpec and skills directory
- Integration with existing TODO tracking system

#### `/docs/AGENTS.md`
**Required Content:**
- Documentation-first development approach
- Documentation templates and standards
- Integration with hardware discovery process
- Module documentation requirements
- Cross-reference management

**Key Focus Areas:**
- Hardware discovery documentation workflow
- Module documentation templates
- Architecture decision records
- Troubleshooting guide maintenance

#### `/modules/AGENTS.md`
**Required Content:**
- Single-concern principle enforcement
- Module creation workflow
- Testing and validation procedures
- Documentation requirements
- Import patterns and conventions

**Key Integration:**
- Module generator skill integration
- Hardware-specific module patterns
- Security module requirements
- Home-manager vs system module distinctions

#### `/hosts/AGENTS.md`
**Required Content:**
- Host-specific configuration workflow
- Hardware-first development approach
- Testing and deployment procedures
- Emergency recovery processes
- Cross-host consistency maintenance

**Critical Integration:**
- Hardware scanner skill usage
- Deployment orchestrator skill integration
- Host-specific hardware optimization

#### `/home/AGENTS.md`
**Required Content:**
- Home-manager module development
- User environment configuration
- Application integration patterns
- Shell and terminal configuration
- AI tools integration

**Key Areas:**
- Fish shell configuration patterns
- Ghostty terminal setup
- AI coding tools configuration
- Development environment automation

#### `/overlays/AGENTS.md`
**Required Content:**
- Package overlay development
- Version pinning strategies
- Custom package creation
- Overlay testing procedures
- Security considerations

**Integration Points:**
- flake.nix integration
- Custom package development workflow
- Version management strategies

#### `/scripts/AGENTS.md`
**Required Content:**
- Script development standards
- Error handling patterns
- Security best practices
- Testing and validation
- Documentation requirements

**Skill Integration:**
- Deployment orchestrator scripts
- Hardware scanner scripts
- Module generator scripts

### OpenCode Agent Files Issues

**General Problems:**
1. **Missing Project Context**: Agents don't understand pantherOS structure
2. **No Phase Integration**: Agents unaware of Phase 1-3 workflow
3. **No Skills Integration**: Agents can't leverage existing skills
4. **Broken References**: Agents reference files that don't exist
5. **Generic Guidance**: No pantherOS-specific patterns or conventions

**Specific Agent Issues:**

#### Architect Agent
**Current State:** References `docs/architecture/overview.md` (exists) but no context about phases
**Missing Context:**
- pantherOS Phase 1-3 workflow
- Modular architecture requirements
- Hardware-first design principles
- Integration with hardware scanner skill

#### Engineer Agent
**Current State:** Generic Nix module development guidance
**Missing Context:**
- pantherOS single-concern principle
- Module generator skill integration
- Hardware-specific module patterns
- Testing with multiple hosts

#### Librarian Agent
**Current State:** Basic validation workflow
**Missing Context:**
- pantherOS documentation standards
- Integration with hardware documentation process
- OpenSpec specification validation
- Cross-reference management

#### Reviewer Agent
**Current State:** References `tasks.md` (may not exist in expected format)
**Missing Context:**
- pantherOS TODO tracking system
- Phase-based task completion criteria
- Integration with deployment orchestrator
- Host-specific testing requirements

## Required Content for Each AGENTS.md File

### Root AGENTS.md Updates Needed

**New Sections Required:**
```markdown
## Skills Integration
- pantheros-deployment-orchestrator usage
- pantheros-hardware-scanner integration  
- pantheros-module-generator patterns
- pantheros-secrets-manager workflow

## OpenSpec Integration
- When to use OpenSpec workflow
- Integration with Phase-based development
- Specification format requirements
- Change proposal process

## Agent Integration
- How OpenCode agents work in pantherOS
- Agent-specific contexts and workflows
- Integration with skills directory
- Task delegation patterns

## Development Phases
- Phase 1: Hardware discovery workflow
- Phase 2: Module development process
- Phase 3: Host configuration and deployment
- Integration between phases
```

### Missing AGENTS.md Content Requirements

#### OpenSpec AGENTS.md Content
```markdown
# OpenSpec Integration for pantherOS

## Overview
How OpenSpec change proposals integrate with pantherOS development workflow.

## When to Use OpenSpec
- Hardware architecture changes
- Module system restructuring  
- Cross-host dependency changes
- Security model modifications

## Integration Points
- Phase 1: Hardware discovery specifications
- Phase 2: Module interface specifications
- Phase 3: Host configuration specifications
- Skills: Integration specification requirements

## Proposal Format
- Hardware change proposals
- Module interface changes
- Security model updates
```

#### Documentation AGENTS.md Content
```markdown
# Documentation Development for pantherOS

## Documentation-First Principle
Always document before implementing.

## Required Documentation Types
- Hardware specifications (Phase 1)
- Module interfaces (Phase 2)  
- Host configurations (Phase 3)
- API and integration documentation

## Documentation Workflow
1. Hardware discovery → Documentation
2. Module design → Interface docs
3. Implementation → Usage docs
4. Deployment → Operational docs

## Templates and Standards
- Hardware documentation template
- Module interface documentation
- Troubleshooting guides
```

#### Module Development AGENTS.md Content
```markdown
# Module Development for pantherOS

## Single-Concern Principle
Every module addresses exactly one concern.

## Module Categories
- System modules (nixos/)
- User modules (home-manager/)
- Shared modules (shared/)

## Development Workflow
1. Hardware analysis
2. Module design
3. Implementation
4. Documentation
5. Testing

## Integration with Skills
- Module generator skill usage
- Hardware-specific patterns
- Security requirements
```

#### Host Configuration AGENTS.md Content
```markdown
# Host Configuration for pantherOS

## Hardware-First Approach
Always scan and document hardware before configuration.

## Configuration Layers
1. Hardware detection (hardware.nix)
2. Disk layout (disko.nix)  
3. System configuration (default.nix)

## Testing and Deployment
- Build testing procedures
- Dry-run validation
- Deployment safety measures
- Rollback procedures

## Skills Integration
- Hardware scanner usage
- Deployment orchestrator workflow
```

#### Home-Manager AGENTS.md Content
```markdown
# Home-Manager Development for pantherOS

## User Environment Modules
- Shell configuration (Fish)
- Terminal setup (Ghostty)
- Application integration
- Development tools

## AI Tools Integration
- Claude Code CLI configuration
- OpenCode integration
- Development environment automation

## Workflow Integration
- Module development patterns
- Testing procedures
- Cross-host consistency
```

#### Overlays AGENTS.md Content
```markdown
# Package Overlays for pantherOS

## Overlay Development
- Custom package definitions
- Version pinning strategies
- Security considerations

## Integration
- flake.nix configuration
- Module system integration
- Testing procedures

## Best Practices
- Version management
- Security updates
- Compatibility testing
```

#### Scripts AGENTS.md Content
```markdown
# Script Development for pantherOS

## Development Standards
- Error handling patterns
- Security best practices
- Documentation requirements

## Skills Integration
- Deployment orchestrator scripts
- Hardware scanner scripts
- Module generator scripts

## Testing and Validation
- Unit testing procedures
- Integration testing
- Security validation
```

## Integration Points Analysis

### Cross-Reference Requirements

**Root → Subdirectory Integration:**
- Root AGENTS.md should reference all subdirectory AGENTS.md files
- Root should explain how agents navigate between directories
- Root should provide jumping-off points for specific workflows

**Subdirectory → Skills Integration:**
- Each subdirectory should reference relevant skills
- Skills should be presented as specialized tools for specific tasks
- Clear guidance on when to use skills vs manual work

**OpenCode → pantherOS Integration:**
- OpenCode agents need pantherOS context
- Agents should understand Phase 1-3 workflow
- Agents should know how to use skills
- Agents should follow pantherOS patterns

### Reading Order Framework

**For New Agents:**
1. **Start**: Root AGENTS.md (project overview)
2. **Understand**: brief.md (requirements)
3. **Context**: docs/README.md (documentation structure)
4. **Phase**: Check relevant phase TODO
5. **Execute**: Use appropriate subdirectory AGENTS.md
6. **Skills**: Integrate with relevant skills
7. **Validate**: Follow verification procedures

**For Specific Tasks:**
- **Documentation**: docs/AGENTS.md
- **Module Development**: modules/AGENTS.md
- **Host Configuration**: hosts/AGENTS.md
- **User Environment**: home/AGENTS.md
- **Package Development**: overlays/AGENTS.md
- **Script Development**: scripts/AGENTS.md
- **Change Proposals**: openspec/AGENTS.md

## Priority Order for Updates

### Phase 1: Critical Infrastructure (High Priority)
1. **OpenSpec AGENTS.md** - Referenced but missing, breaks OpenSpec integration
2. **Root AGENTS.md updates** - Integrate skills, fix OpenSpec references
3. **Modules AGENTS.md** - Critical for Phase 2, single-concern principle

### Phase 2: Development Support (Medium Priority)  
4. **Docs AGENTS.md** - Documentation-first development
5. **Hosts AGENTS.md** - Critical for Phase 3, hardware-first approach
6. **Home AGENTS.md** - User environment development

### Phase 3: Specialized Areas (Lower Priority)
7. **Overlays AGENTS.md** - Package development guidance
8. **Scripts AGENTS.md** - Script development standards

### Phase 4: OpenCode Integration (High Priority)
9. **Update OpenCode agent files** - Add pantherOS context
10. **Integration testing** - Verify agent workflows

## Implementation Strategy

### Step-by-Step Creation Process

#### Step 1: Create Missing AGENTS.md Files
1. Start with highest priority files
2. Use templates provided in this audit
3. Ensure cross-references are accurate
4. Test integration with existing documentation

#### Step 2: Update Root AGENTS.md
1. Add skills integration sections
2. Fix OpenSpec references
3. Update subdirectory guidance
4. Verify all cross-references work

#### Step 3: Update OpenCode Agents
1. Add pantherOS context to each agent
2. Reference specific AGENTS.md files
3. Integrate with skills directory
4. Add Phase 1-3 workflow context

#### Step 4: Integration Testing
1. Verify all links work
2. Test agent workflows end-to-end
3. Validate cross-reference integrity
4. Test with sample tasks

### Content Templates

Each AGENTS.md file should follow this structure:
```markdown
# [Directory] Development for pantherOS

## Overview
- Purpose and scope
- Integration with project phases
- Relationship to other directories

## Workflow
- Step-by-step development process
- Required tools and skills
- Integration points

## Best Practices
- pantherOS-specific patterns
- Single-concern principle
- Testing and validation

## Tools and Integration
- Relevant skills usage
- OpenCode agent integration
- Cross-directory references

## Examples
- Common workflows
- Integration examples
- Troubleshooting patterns
```

## Success Metrics

**Completion Criteria:**
- [ ] All 8 AGENTS.md files created and populated
- [ ] Root AGENTS.md references all subdirectory files
- [ ] OpenCode agents have pantherOS context
- [ ] Skills directory integrated into relevant AGENTS.md files
- [ ] Cross-references verified and working
- [ ] Reading order clearly defined
- [ ] Integration with Phase 1-3 workflow documented

**Quality Metrics:**
- Each AGENTS.md file provides actionable guidance
- Integration points are clear and accurate
- Cross-references don't lead to dead ends
- Agents can successfully complete tasks using guidance
- Documentation is consistent across all files

## Maintenance Plan

**Regular Updates:**
- Review AGENTS.md files quarterly
- Update integration points when structure changes
- Add new patterns and best practices
- Update cross-references as documentation evolves

**Integration Monitoring:**
- Monitor OpenCode agent effectiveness
- Track skill usage and integration success
- Collect feedback on guidance clarity
- Iterate on content based on usage patterns

---

**Audit completed:** 2025-11-19
**Next review:** 2025-12-19
**Priority:** High - Critical missing infrastructure
