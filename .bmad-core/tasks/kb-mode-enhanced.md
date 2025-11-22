<!-- Powered by BMAD™ Core -->
<!-- Enhanced KB Mode with OpenCode + Claude Memory Integration -->

# Enhanced KB Mode Interaction Task

## Purpose

Provide a dynamic, user-friendly interface to the combined BMad knowledge base, OpenCode context files, and Claude Memory data. This enhanced version reads from live project sources and offers integrated workflows.

## Instructions

When entering KB mode (\*kb-mode), follow these steps:

### 1. Welcome and Dynamic Context Loading

Announce entering KB mode with a brief, friendly introduction and load dynamic context from:
- OpenCode context files (project-specific knowledge)
- Claude Memory data (sessions, decisions, patterns)
- BMad core knowledge base
- Current project workflows

### 2. Present Dynamic Topic Areas

Offer a dynamically-generated list of main topic areas based on current project state:

**Current KB Topics (dynamically loaded):**

1. **🎯 Project Context** - Current project state and objectives
2. **🔄 Active Workflows** - OpenCode workflows and BMad task templates
3. **🤖 Agents & Skills** - Available agents (OpenCode + BMad) and specialized skills
4. **📚 Knowledge Base** - BMad core knowledge + Claude Memory insights
5. **🔍 Recent Research** - Latest research findings from OpenCode /swarm-research
6. **📊 Current Gaps** - Live gap analysis from /gap-analyze
7. **💡 Patterns & Solutions** - Claude Memory patterns + OpenCode essential patterns
8. **⚙️ Technical Stack** - NixOS, TypeScript, OpenCode system information
9. **🖥️ Host Profiles** - Hardware specifications (yoga, zephyrus, hetzner-vps, ovh-vps)
10. **📋 Session History** - Claude Memory sessions, decisions, and task tracking

Or ask me about anything else related to pantherOS, BMad-Method, OpenCode, or Claude Memory!

### 3. Dynamic Content Loading

For each topic, dynamically load content from:

**Project Context** → `.opencode/context/project/project-context.md`
**Active Workflows** → `.opencode/workflows/*.md` + `.bmad-core/tasks/*.md`
**Agents & Skills** → `.opencode/agent/*.md` + `.opencode/skills/*.md`
**Knowledge Base** → `.bmad-core/data/bmad-kb.md`
**Recent Research** → Claude Memory knowledge items (category: research)
**Current Gaps** → Run `/gap-analyze` command or load from memory
**Patterns & Solutions** → Claude Memory patterns + `.opencode/context/core/essential-patterns.md`
**Technical Stack** → `.opencode/context/domain/nixos-configuration.md`
**Host Profiles** → `.opencode/context/domain/hardware-specifications.md`
**Session History** → Claude Memory sessions and decisions

### 4. Contextual Responses with Integration

- Wait for user's specific question or topic selection
- Provide focused, relevant information from the appropriate source(s)
- **Include integration suggestions** - "Would you like to run X workflow?" or "Should I save this to Claude Memory?"
- Offer to dive deeper or explore related topics
- Keep responses concise unless user asks for detailed explanations

### 5. Interactive Exploration with Commands

- After answering, suggest related topics or OpenCode commands they might find helpful
- Maintain conversational flow rather than data dumping
- Use examples when appropriate
- Reference specific documentation sections when relevant
- **Suggest cross-system actions**: "This pattern could be saved to Claude Memory for future reference"

### 6. Integrated Commands

When user expresses interest in specific actions, offer integrated commands:

```bash
# Research workflow
"Research this topic" → /swarm-research + claude-memory knowledge add

# Gap analysis
"Analyze gaps" → /gap-analyze + claude-memory task add

# Pattern capture
"This is a useful pattern" → claude-memory pattern add

# Decision tracking
"Record this decision" → claude-memory decision

# Handoff
"Generate handoff" → claude-memory handoff --opencode
```

### 7. Exit with Unified Summary

When user is done or wants to exit KB mode:

- Summarize key points discussed if helpful
- Show integrated options: "You can continue with /gap-analyze, run /swarm-research on X, or save patterns with claude-memory"
- Remind them they can return to KB mode anytime with \*kb-mode
- Suggest next steps based on what was discussed
- Offer to save session summary to Claude Memory

## Enhanced KB Mode Flow

### Initial Entry
```
User: *kb-mode

Assistant: I've entered Enhanced KB Mode with access to:
• BMad knowledge base (25+ tasks, 11 agents)
• OpenCode context (TypeScript, NixOS, hardware, workflows)
• Claude Memory (sessions, decisions, patterns, tasks)
• Live gap analysis and research capabilities

What would you like to explore?
```

### Topic Selection Example
```
User: Tell me about NixOS configuration

Assistant: I'll pull the latest NixOS configuration patterns from OpenCode:

**NixOS Configuration Patterns:**
• Flake-based configuration structure
• Module patterns (system, services, security, development)
• Host-specific configurations (yoga, zephyrus, servers)
• Security hardening (SSH, firewall, fail2ban)

Would you like to:
1. See specific host configuration (e.g., "show me yoga hardware")
2. Run gap analysis on NixOS config (/gap-analyze nixos)
3. Research latest NixOS patterns (/swarm-research nixos)
4. Save this information to Claude Memory (claude-memory knowledge add)

What interests you?
```

### Cross-System Integration Example
```
User: I discovered a new pattern for NixOS module design

Assistant: Great! Let me help you capture this. Would you like to:

1. Save it to Claude Memory as a pattern (claude-memory pattern add)
2. Add it to OpenCode context files (/.opencode/context/domain/nixos-configuration.md)
3. Create a BMad task template for it
4. All of the above

You can say "save to memory" or "add to context" or whatever you prefer!

This pattern will then be available in future KB mode sessions and integrated into your workflow.
```

## Implementation Notes

### Dynamic Content Loading

The KB mode should:
1. Read OpenCode context files using available tools
2. Query Claude Memory using claude-memory commands
3. Pull BMad task and agent information
4. Combine into coherent, contextual responses

### Cross-System Awareness

Always be aware of:
- What OpenCode commands are available
- What Claude Memory data exists
- What BMad workflows are active
- How systems can be integrated

### User Experience Goals

- Seamless transition between systems
- Context preservation
- Actionable suggestions
- Integrated workflows
- Learning and knowledge capture

## Example Complete Interaction

**User**: \*kb-mode

**Assistant**: I've entered Enhanced KB Mode with access to:
• BMad knowledge base (25+ tasks, 11 agents)
• OpenCode context (TypeScript, NixOS, hardware, workflows)
• Claude Memory (sessions, decisions, patterns, tasks)
• Live gap analysis and research capabilities

**What would you like to explore?**

1. **🎯 Project Context** - Current project state and objectives
2. **🔄 Active Workflows** - OpenCode workflows and BMad task templates
3. **🤖 Agents & Skills** - Available agents and specialized skills
4. **📚 Knowledge Base** - BMad core knowledge + Claude Memory insights
5. **🔍 Recent Research** - Latest research findings
6. **📊 Current Gaps** - Live gap analysis
7. **💡 Patterns & Solutions** - Patterns and essential patterns
8. **⚙️ Technical Stack** - NixOS, TypeScript, OpenCode system
9. **🖥️ Host Profiles** - Hardware specifications
10. **📋 Session History** - Memory sessions and decisions

Or ask me about anything else related to pantherOS!

**User**: Tell me about the technical stack

**Assistant**: **pantherOS Technical Stack:**

**Core Infrastructure:**
• **NixOS** - Declarative Linux configuration
• **Nix Flakes** - Package management and configuration
• **Home Manager** - User environment management
• **Disko** - Declarative disk partitioning (Btrfs)

**AI/Development Tools:**
• **TypeScript/Node.js** - OpenCode agent system
• **BMad Method** - 11 specialized agents, 25+ tasks
• **Claude Memory** - Persistent AI memory (v1.11.1)
• **OpenCode** - AI coding platform with custom agents

**Development Environment:**
• **Fish Shell** - Default shell
• **Zed Editor** - Code editor
• **Niri** - Window manager
• **Ghostty** - Terminal emulator

**Infrastructure:**
• **4 Hosts**: yoga (Lenovo), zephyrus (ASUS), hetzner-vps, ovh-vps
• **Tailscale** - VPN and network security
• **Podman** - Container runtime
• **1Password + OpNix** - Secrets management

**Would you like to:**
1. Dive deeper into NixOS configuration patterns
2. Explore OpenCode agent system
3. See host-specific configurations
4. Run gap analysis on the stack
5. Research latest updates to any component

What interests you most?

**User**: Show me gap analysis

**Assistant**: **Current Gap Analysis** (Running /gap-analyze...)

[Gap analysis would be executed, showing:]
• Missing documentation
• Incomplete modules
• Deprecated patterns
• Security improvements
• Performance optimizations

**Identified Gaps:**
1. Hardware optimization documentation incomplete
2. Security audit needed for server configurations
3. Missing monitoring setup
4. Backup strategy needs improvement

**Actions:**
• These gaps have been saved as tasks in Claude Memory
• Priority: High for security audit
• Would you like me to start researching solutions (/swarm-research security-audit)?
• Or generate implementation plan (create-doc implementation-plan)?

How would you like to proceed?
