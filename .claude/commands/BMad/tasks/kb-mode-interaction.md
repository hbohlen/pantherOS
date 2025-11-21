# /kb-mode-interaction Task

When this command is used, execute the following task:

<!-- Powered by BMAD™ Core -->
<!-- Updated to use Enhanced KB Mode with OpenCode + Claude Memory Integration -->

# Enhanced KB Mode Interaction Task

## Purpose

Provide a dynamic, user-friendly interface to the combined BMad knowledge base, OpenCode context files, and Claude Memory data. This enhanced version reads from live project sources and offers integrated workflows.

## Instructions

When entering KB mode (\*kb-mode), follow these steps:

### 1. Welcome and Dynamic Context Loading

Announce entering Enhanced KB Mode with access to:
- BMad knowledge base (25+ tasks, 11 agents)
- OpenCode context (TypeScript, NixOS, hardware, workflows)
- Claude Memory (sessions, decisions, patterns, tasks)
- Live gap analysis and research capabilities

### 2. Present Dynamic Topic Areas

Offer a dynamically-generated list of main topic areas:

**Enhanced KB Topics (dynamically loaded):**

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

### 3. Contextual Responses with Integration

- Wait for user's specific question or topic selection
- Provide focused, relevant information from appropriate sources
- **Include integration suggestions** - "Would you like to run X workflow?"
- Offer cross-system commands when relevant
- Keep responses concise unless user asks for detailed explanations

### 4. Cross-System Integration

Always be ready to:
- Execute OpenCode commands (/swarm-research, /gap-analyze, etc.)
- Save to Claude Memory (knowledge, patterns, decisions, tasks)
- Reference BMad task templates
- Combine data from multiple systems

### 5. Exit with Options

When user is done:
- Summarize key points discussed
- Suggest next steps (OpenCode commands, Memory actions, etc.)
- Offer to save session summary to Claude Memory
- Remind them they can return to KB mode anytime with \*kb-mode

## Example Enhanced Interaction

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
