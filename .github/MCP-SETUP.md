# MCP Servers and Environment Configuration Guide

This guide helps you set up Model Context Protocol (MCP) servers and custom development environments for the pantherOS project.

## Overview

pantherOS now includes comprehensive MCP server configurations and enhanced development environments to support AI-assisted development, NixOS configuration management, and the AI infrastructure roadmap.

## Quick Start

### 1. Choose Your Development Environment

pantherOS provides multiple specialized development shells:

```bash
# General development with MCP support
nix develop .#mcp

# AI infrastructure development
nix develop .#ai

# Language-specific environments
nix develop .#nix    # Nix development
nix develop .#rust   # Rust development
nix develop .#node   # Node.js development
nix develop .#python # Python development
nix develop .#go     # Go development
```

### 2. Configure MCP Servers

MCP servers are configured in `.github/mcp-servers.json`. Set up required environment variables:

```bash
# Required for GitHub MCP server
export GITHUB_TOKEN="your_github_personal_access_token"

# Optional for web search
export BRAVE_API_KEY="your_brave_api_key"

# Optional for AgentDB integration
export POSTGRES_CONNECTION_STRING="postgresql://user:pass@localhost:5432/agentdb"
```

### 3. Test MCP Server Connection

```bash
# Enter MCP development environment
nix develop .#mcp

# Test GitHub MCP server (requires GITHUB_TOKEN)
npx -y @modelcontextprotocol/server-github

# Test filesystem access
npx -y @modelcontextprotocol/server-filesystem .
```

## MCP Servers Overview

### Essential Servers

| Server | Purpose | Required Env Vars |
|--------|---------|-------------------|
| **github** | Repository operations, issues, PRs, code search | `GITHUB_TOKEN` |
| **filesystem** | Local file access to pantherOS repository | None |
| **git** | Git operations and repository management | None |
| **brave-search** | Web search for NixOS docs and troubleshooting | `BRAVE_API_KEY` (optional) |

### NixOS-Specific Servers

| Server | Purpose | Dependencies |
|--------|---------|--------------|
| **nix-search** | Package search wrapper | Nix CLI |
| **fetch** | HTTP requests for packages and documentation | None |

### AI Infrastructure Servers

| Server | Purpose | Required Env Vars |
|--------|---------|-------------------|
| **postgres** | Database operations for AgentDB | `POSTGRES_CONNECTION_STRING` |
| **memory** | Knowledge graph memory for patterns | None |
| **sequential-thinking** | Enhanced reasoning for complex decisions | None |

### Testing Servers

| Server | Purpose | Dependencies |
|--------|---------|--------------|
| **puppeteer** | Browser automation for desktop testing | Chromium |
| **docker** | Container management for deployments | Docker |

## Development Environment Details

### MCP Development Shell (`nix develop .#mcp`)

**Optimized for:** AI-assisted development with full MCP support

**Includes:**
- Node.js 20 for MCP servers
- PostgreSQL and SQLite for AgentDB
- Docker for testing deployments
- Nix tools (nil, nixpkgs-fmt)
- Modern utilities (ripgrep, fd, bat, jq)

**Auto-configured:**
- Creates `.opencode/` directory structure
- Sets `MCP_CONFIG_PATH` environment variable
- Displays helpful development tips

### AI Development Shell (`nix develop .#ai`)

**Optimized for:** AI infrastructure development per `ai_infrastructure/` plans

**Includes:**
- Python 3 with NumPy and Pandas
- Node.js for MCP tooling
- Database tools (PostgreSQL, SQLite, Redis)
- tmux for session management

**Use cases:**
- AgentDB integration development
- Documentation analysis systems
- MiniMax M2 optimization work
- Agentic-flow integration

## Integration with AI Infrastructure Plans

### AgentDB Integration

The MCP servers support the AgentDB integration plan (`ai_infrastructure/01_agentdb_integration_plan.md`):

1. **PostgreSQL MCP Server**: Direct database access for vector operations
2. **Memory MCP Server**: Knowledge graph for pattern learning
3. **Sequential Thinking**: Enhanced reasoning for complex configurations

**Setup:**
```bash
# Create AgentDB database
createdb agentdb

# Set connection string
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"

# Enter AI dev environment
nix develop .#ai

# Follow Phase 1 setup from ai_infrastructure/01_agentdb_integration_plan.md
```

### OpenCode Integration

For OpenCode MCP integration, copy the configuration:

```bash
# Create OpenCode MCP directory
mkdir -p ~/.opencode/mcp

# Copy MCP server configuration
cp .github/mcp-servers.json ~/.opencode/mcp/servers.json

# Edit paths to match your setup
$EDITOR ~/.opencode/mcp/servers.json
```

## GitHub Copilot Integration

MCP servers can be used with GitHub Copilot in supported IDEs:

1. **VS Code**: Configure in Copilot settings
2. **Codespaces**: Use provided `.github/devcontainer.json`
3. **CLI**: Use `gh copilot` commands with MCP context

## Docker Development Container

For containerized development, use the provided Dev Container configuration:

```bash
# With VS Code
code --folder-uri vscode-remote://dev-container+${PWD}

# With GitHub Codespaces
gh codespace create --repo hbohlen/pantherOS
```

**Features:**
- NixOS base image
- Docker-in-Docker support
- Pre-configured VS Code extensions
- Auto-installs Nix community cache

## Troubleshooting

### MCP Server Not Found

```bash
# Ensure Node.js is available
which node  # Should show Node.js 20

# Manually install MCP server
npm install -g @modelcontextprotocol/server-github
```

### Authentication Issues

```bash
# GitHub token
gh auth login
export GITHUB_TOKEN=$(gh auth token)

# Verify token
curl -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user
```

### Database Connection Issues

```bash
# Test PostgreSQL connection
psql $POSTGRES_CONNECTION_STRING -c "SELECT version();"

# Start local PostgreSQL (if needed)
nix-shell -p postgresql --run "postgres -D /tmp/pgdata"
```

## Best Practices

### Environment Variables

Store environment variables securely:

```bash
# Create .envrc for direnv
cat > .envrc <<EOF
export GITHUB_TOKEN=\$(gh auth token)
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
EOF

# Allow direnv
direnv allow
```

### MCP Server Selection

Choose MCP servers based on your task:

- **NixOS configuration**: github, git, filesystem, nix-search, fetch
- **AI development**: postgres, memory, sequential-thinking
- **Testing**: puppeteer, docker
- **General**: github, filesystem, git, brave-search

### Performance Optimization

```bash
# Use local MCP servers when possible
# Avoid remote MCP servers in hot loops
# Cache MCP responses for repeated queries
```

## Additional Resources

- **MCP Documentation**: https://modelcontextprotocol.io/
- **pantherOS AI Plans**: See `ai_infrastructure/` directory
- **NixOS Manual**: https://nixos.org/manual/
- **GitHub Copilot Tips**: `.github/copilot-instructions.md`

## Contributing

When adding new MCP servers:

1. Update `.github/mcp-servers.json`
2. Document in this file
3. Add to appropriate dev shell in `flake.nix`
4. Update `.github/copilot-instructions.md`

## Support

- **Issues**: Open a GitHub issue
- **Discussions**: Use GitHub Discussions
- **Documentation**: Check `system_config/` and `ai_infrastructure/`
