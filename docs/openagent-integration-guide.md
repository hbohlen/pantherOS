# OpenAgent Integration Guide

## Overview

Your OpenAgent system is now fully integrated into your NixOS home-manager configuration. This provides a comprehensive AI-powered development environment with specialized agents, commands, and skills.

## Integration Components

### 1. **Directory Structure**
```
/home/hbohlen/dev/pantherOS/home/hbohlen/opencode/
├── agents/           # 16 agent configurations
│   ├── openagent.md  # Main universal agent
│   ├── codebase-agent.md
│   ├── system-builder.md
│   └── subagents/    # Specialized subagents
│       ├── code/     # Code development agents
│       ├── core/     # Core workflow agents
│       ├── system-builder/ # System building agents
│       └── utils/    # Utility agents
├── commands/         # 14 available commands
│   ├── context.md    # Project analysis
│   ├── openspec-proposal.md
│   ├── build-context-system.md
│   └── [12 more commands]
├── skills/           # Directory-based skills
│   └── example-skill/
├── dcp.jsonc         # DCP configuration
└── opencode.jsonc    # OpenCode configuration
```

### 2. **Home-Manager Configuration**

**File**: `/home/hbohlen/dev/pantherOS/home/hbohlen/home.nix`

#### Dotfiles Integration
- **Module-based management** via `home-manager.dotfiles.opencode-ai`
- **Configuration files** managed as dotfiles in `~/.config/opencode/`
- **Source directory preserved** for agents, commands, skills
- **Environment variables** auto-configured for all OpenAgent paths

#### Enhanced Environment Variables
```bash
OPENCODE_CONFIG_PATH    # ~/.config/opencode
OPENCODE_DATA_PATH      # ~/.local/share/opencode
OPENCODE_CACHE_PATH     # ~/.cache/opencode

# OpenAgent specific
OPENAGENT_CONTEXT_PATH
OPENAGENT_SESSIONS_PATH
OPENAGENT_AGENTS_PATH
OPENAGENT_COMMANDS_PATH
OPENAGENT_SKILLS_PATH
```

### 3. **Fish Shell Integration**

**Enhanced aliases** for OpenAgent operations:
```bash
# Basic commands
oc      # opencode
occ     # opencode --config $OPENCODE_CONFIG_PATH
oa      # opencode --agents
ocmd    # opencode --commands
oskill  # opencode --skills

# Agent management
oa-openagent    # opencode agent openagent
oa-codeagent    # opencode agent code-agent
oa-reviewer     # opencode agent reviewer
oa-tester       # opencode agent tester

# OpenSpec integration
ospec           # opencode openspec
ospec-proposal  # opencode openspec-proposal
ospec-apply     # opencode openspec-apply

# Workflow management
oa-workflow     # opencode workflow
oa-validate     # opencode validate
oa-optimize     # opencode optimize

# Quick operations
oa-test         # opencode test
oa-build        # opencode build
oa-clean        # opencode clean
oa-commit       # opencode commit

# Context management
octx            # opencode context
octx-build      # opencode build-context-system
octx-analyze    # opencode gap-analyze

# Status check
oa-status       # Display OpenAgent system status
```

### 4. **Module System**

**File**: `/home/hbohlen/dev/pantherOS/modules/home/dotfiles/opencode-ai.nix`

#### Enhanced Options
```nix
home-manager.dotfiles.opencode-ai = {
  enable = true;              # Enable OpenCode/OpenAgent
  theme = "rosepine";         # UI theme
  openAgent = {
    enable = true;            # Enable OpenAgent system
    debug = true;             # Debug mode
    dcp.enable = true;        # DCP protocol enabled
  };
};
```

#### Auto-created Directories
- `~/.cache/opencode/sessions/` - Session management
- `~/.local/share/opencode/logs/` - System logs

## Key Features

### 1. **Universal Agent (openagent.md)**
- **Safety-first** approach with approval gates
- **Dual execution paths**: conversational vs task-based
- **Comprehensive workflow**: Analyze → Approve → Execute → Validate → Summarize
- **Smart delegation** to specialized subagents

### 2. **Specialized Subagents**
- **Code agents**: build, review, test, analyze
- **Core agents**: documentation, task management
- **System builders**: agent generation, context organization
- **Utilities**: image processing, analysis

### 3. **Command System**
- **14 built-in commands** for common operations
- **OpenSpec integration** for proposal management
- **Context management** for project analysis
- **Validation and optimization** tools

### 4. **Skills System**
- **Directory-based** skill organization
- **Reusable instructions** for common tasks
- **Extensible** skill framework

### 5. **DCP (Dynamic Context Pruning)**
- **Plugin**: `@tarquinen/opencode-dcp` from npm
- **Smart pruning** of context to optimize performance
- **Deduplication** of redundant content
- **AI-powered analysis** for intelligent pruning decisions
- **Protected tools** for critical operations (task, todowrite, todoread)
- **Debug mode** enabled for development and monitoring

## Usage Examples

### 1. **Project Analysis**
```bash
octx                    # Basic context analysis
octx-analyze            # Gap analysis
```

### 2. **Agent Operations**
```bash
oa                      # List available agents
oa-reviewer             # Invoke code reviewer
```

### 3. **OpenSpec Management**
```bash
ospec-proposal          # Create new proposal
ospec-apply             # Apply approved changes
```

### 4. **System Status**
```bash
oa-status               # Check OpenAgent status
```

### 5. **Workflow Management**
```bash
oa-validate             # Validate configuration
oa-optimize             # Optimize setup
```

## Configuration Files

### Dotfiles Module Management

The OpenAgent configuration is now **managed via the dotfiles module** (`home-manager.dotfiles.opencode-ai`), which provides:

#### Automatically Managed Files
```nix
home-manager.dotfiles.opencode-ai = {
  enable = true;
  theme = "rosepine";
  openAgent = {
    enable = true;
    debug = true;
    dcp.enable = true;
  };
  plugins = [ "@tarquinen/opencode-dcp" ];
  additionalConfig = { };
};
```

#### Generated Configuration Files

**1. OpenCode Config** (`~/.config/opencode/opencode.jsonc`)
```json
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": true,
  "username": "hbohlen",
  "theme": "rosepine",
  "plugin": ["@tarquinen/opencode-dcp"]
}
```

**2. DCP Config** (`~/.config/opencode/dcp.jsonc`)
```json
{
  "enabled": true,
  "debug": true,
  "pruningMode": "smart",
  "pruning_summary": "detailed",
  "protectedTools": ["task", "todowrite", "todoread"],
  "$schema": {
    "onIdle": ["deduplication", "ai-analysis"],
    "onTool": ["deduplication"]
  }
}
```

#### Source Directory Preserved
- **Agents**: `~/.config/opencode/agents/` (from source directory)
- **Commands**: `~/.config/opencode/commands/` (from source directory)  
- **Skills**: `~/.config/opencode/skills/` (from source directory)

**DCP Plugin Features**:
- **Plugin**: `@tarquinen/opencode-dcp` (npm: https://www.npmjs.com/package/@tarquinen/opencode-dcp)
- **Smart pruning**: AI-powered context optimization
- **Deduplication**: Removes redundant content automatically
- **Protected tools**: Critical workflow tools are never pruned
- **Idle cleanup**: Runs deduplication and analysis when system is idle
- **Tool-triggered pruning**: Deduplication runs when tools are used
- **Debug mode**: Detailed pruning summaries for monitoring

## Verification

### Complete Integration Check
```bash
/home/hbohlen/dev/pantherOS/scripts/verify-openagent-integration.sh
```

### DCP Plugin Verification
```bash
/home/hbohlen/dev/pantherOS/scripts/verify-dcp-plugin.sh
```

### Dotfiles Module Verification
```bash
/home/hbohlen/dev/pantherOS/scripts/verify-dotfiles-integration.sh
```

**Verification Coverage**:
- ✅ OpenAgent system integration (16 agents, 14 commands)
- ✅ DCP plugin configuration and functionality
- ✅ Dotfiles module management of configuration files
- ✅ Environment variables and aliases setup
- ✅ Module-based configuration updates

### Configuration Management

**Update configurations** via home-manager:
```bash
home-manager switch
```

**Modify settings** by editing `/home/hbohlen/dev/pantherOS/home/hbohlen/home.nix`:
```nix
home-manager.dotfiles.opencode-ai = {
  theme = "dark";              # Change theme
  openAgent.debug = false;     # Disable debug mode
  # Add custom config files
  additionalConfig = {
    "custom-config.json" = "{\"key\": \"value\"}";
  };
};
```

**Add new plugins**:
```nix
plugins = [ 
  "@tarquinen/opencode-dcp",
  "@tarquinen/opencode-analytics"  # Add more plugins
];
```

## Next Steps

1. **Rebuild home-manager**: `home-manager switch`
2. **Test aliases**: `source ~/.config/fish/config.fish`
3. **Verify status**: Run `oa-status` in fish shell
4. **Explore agents**: Run `oa` to see available agents
5. **Try commands**: Run `ocmd` to see available commands

## Configuration Management

### Dotfiles Module Benefits

**Centralized Configuration**:
- All OpenAgent settings managed through `home-manager.dotfiles.opencode-ai`
- Configuration files auto-generated from Nix settings
- Environment variables automatically configured

**Flexible Updates**:
- Modify themes, debug modes, plugin lists via Nix configuration
- Add custom configuration files through `additionalConfig`
- Maintain source directories for agents, commands, skills

**Version Control**:
- Configuration changes tracked in git through Nix configuration
- Reproducible setup across machines
- Easy rollback to previous configurations

### Configuration Examples

**Change theme**:
```nix
home-manager.dotfiles.opencode-ai.theme = "dark";
```

**Disable debug mode**:
```nix
home-manager.dotfiles.opencode-ai.openAgent.debug = false;
```

**Add custom DCP configuration**:
```nix
home-manager.dotfiles.opencode-ai.additionalConfig = {
  "custom-dcp-rules.json" = '{"rule": "custom setting"}';
};
```

**Add plugins**:
```nix
home-manager.dotfiles.opencode-ai.plugins = [
  "@tarquinen/opencode-dcp"
  "@tarquinen/opencode-analytics"
];
```

## Architecture Benefits

- **Declarative**: All configuration in Nix files
- **Reproducible**: Same setup across machines
- **Maintainable**: Modular, well-organized structure
- **Extensible**: Easy to add new agents, commands, skills
- **Safe**: Built-in approval gates and permissions
- **Efficient**: Smart delegation and context management
- **Managed**: Dotfiles module handles configuration generation
- **Version-controlled**: All changes tracked through Nix configuration

Your OpenAgent system is production-ready and fully integrated into your NixOS workflow with intelligent DCP context pruning!