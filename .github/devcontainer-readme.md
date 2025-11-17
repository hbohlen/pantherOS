# Development Container Configuration

This document explains the pantherOS development container setup and how to use it with GitHub Copilot and Spec Kit.

## Overview

The devcontainer is configured with:
- **NixOS/Nix** - Package manager and build system
- **Python 3.11** - For Spec Kit and AI tools
- **Node.js 20** - For MCP servers and JavaScript tools
- **Docker** - For container-based development
- **GitHub CLI** - For GitHub integration
- **uv** - Fast Python package installer
- **specify-cli** - GitHub Spec Kit tool

## Quick Start

### Opening in VS Code

1. Install [VS Code Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open the repository in VS Code
3. When prompted, click "Reopen in Container"
4. Wait for container build and setup (this may take several minutes on first run)

### Verifying Installation

Once the container is running, verify tools are installed:

```bash
# Check Nix
nix --version

# Check Python
python3 --version

# Check Node
node --version

# Check uv
uv --version

# Check specify-cli
specify --version

# Run Spec Kit validation
specify check
```

## Features Explained

### NixOS Base Image
```json
"image": "nixos/nix:latest"
```
Provides the Nix package manager for reproducible builds and NixOS configuration development.

### Python 3.11
```json
"ghcr.io/devcontainers/features/python:1": {
  "version": "3.11"
}
```
Required for GitHub Spec Kit (specify-cli) and AI development tools. Python 3.11+ is needed for modern type hints and performance.

### Node.js 20
```json
"ghcr.io/devcontainers/features/node:1": {
  "version": "20"
}
```
Required for MCP servers and JavaScript-based development tools. See [MCP Setup Guide](MCP-SETUP.md) for details.

### Docker-in-Docker
```json
"ghcr.io/devcontainers/features/docker-in-docker:2": {}
```
Enables running Docker containers inside the devcontainer for testing containerized applications.

### GitHub CLI
```json
"ghcr.io/devcontainers/features/github-cli:1": {}
```
Provides `gh` command for GitHub API access and automation.

## VS Code Extensions

The devcontainer automatically installs these extensions:

### NixOS Development
- **jnoortheen.nix-ide** - Nix language support with formatting and LSP
- **bbenoist.nix** - Nix syntax highlighting
- **arrterian.nix-env-selector** - Nix environment selection
- **mkhl.direnv** - direnv integration for environment management

### GitHub Copilot & AI
- **github.copilot** - AI-powered code completion
- **github.copilot-chat** - AI chat interface for development
  - Use `/speckit.*` commands here for Spec-Driven Development

### Development Tools
- **github.vscode-pull-request-github** - GitHub PR integration
- **eamodio.gitlens** - Git visualization and history
- **ms-azuretools.vscode-docker** - Docker container management

## Post-Create Setup

The `postCreateCommand` runs automatically when the container is created:

```bash
# Install Nix cachix for faster builds
nix-env -iA nixpkgs.cachix && cachix use nix-community

# Install uv (Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install specify-cli (GitHub Spec Kit)
export PATH="$HOME/.local/bin:$PATH"
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

This ensures:
1. Nix binary cache is configured for faster downloads
2. `uv` is installed for Python package management
3. `specify-cli` is installed for Spec-Driven Development
4. All tools are available immediately after container creation

## Using GitHub Copilot with Spec Kit

### Prerequisites

1. GitHub Copilot subscription
2. VS Code with Copilot extensions installed (automatic in devcontainer)
3. Repository opened in devcontainer

### Available Slash Commands

Open GitHub Copilot Chat (Ctrl/Cmd + Shift + I) and use these commands:

#### Core Workflow
- `/speckit.constitution` - Review or update project principles
- `/speckit.specify` - Create feature specification
- `/speckit.plan` - Generate implementation plan
- `/speckit.tasks` - Break down into tasks
- `/speckit.implement` - Execute implementation

#### Quality & Analysis
- `/speckit.clarify` - Ask clarifying questions about specs
- `/speckit.analyze` - Analyze spec consistency
- `/speckit.checklist` - Generate quality checklist
- `/speckit.taskstoissues` - Convert tasks to GitHub issues

### Example Workflow in Copilot Chat

```
User: /speckit.constitution

Copilot: [Reviews pantherOS constitution and principles]

User: /speckit.specify Add PostgreSQL database support with automatic backups

Copilot: [Creates specification in .specify/specs/NNN-postgresql/spec.md]

User: /speckit.clarify

Copilot: [Asks questions about backup strategy, retention, etc.]

User: [Answers questions]

Copilot: [Updates specification]

User: /speckit.plan

Copilot: [Creates technical implementation plan]

User: /speckit.tasks

Copilot: [Generates task breakdown]

User: /speckit.implement

Copilot: [Implements the feature according to plan]
```

### Best Practices

1. **Start with Constitution**
   - Run `/speckit.constitution` to review project principles
   - Ensures compliance with pantherOS standards

2. **Specify Before Coding**
   - Always use `/speckit.specify` first
   - Clarify requirements before implementation
   - Use `/speckit.clarify` for complex features

3. **Review Plans**
   - Check `/speckit.plan` output before implementation
   - Ensure NixOS patterns are followed
   - Verify closure size considerations

4. **Incremental Implementation**
   - `/speckit.tasks` breaks work into manageable pieces
   - Review tasks before running `/speckit.implement`
   - Test incrementally with `nix build`

5. **Quality Gates**
   - Use `/speckit.analyze` to check consistency
   - Run `/speckit.checklist` for validation criteria
   - Follow pantherOS constitution requirements

## Manual Installation (If Needed)

If the automatic setup fails, you can manually install tools:

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add to PATH (add to ~/.bashrc or ~/.zshrc for persistence)
export PATH="$HOME/.local/bin:$PATH"

# Install specify-cli
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Verify installation
specify --version

# Run Spec Kit check
specify check
```

## Volume Mounts

The devcontainer uses volume mounts for persistence:

```json
"mounts": [
  "source=/nix,target=/nix,type=volume",
  "source=${localWorkspaceFolder}/.direnv,target=${containerWorkspaceFolder}/.direnv,type=bind,consistency=cached"
]
```

- **/nix volume** - Persists Nix store across container rebuilds (faster subsequent builds)
- **.direnv bind** - Shares direnv configuration between host and container

## Environment Variables

The devcontainer automatically sets up PATH for installed tools. To verify:

```bash
echo $PATH
# Should include: /home/nixos/.local/bin for uv tools
```

## Troubleshooting

### specify command not found

**Cause:** PATH not set correctly or installation failed.

**Solution:**
```bash
# Check if specify is installed
ls ~/.local/bin/specify

# If not, reinstall
export PATH="$HOME/.local/bin:$PATH"
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Add to shell config for persistence
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### postCreateCommand failed

**Cause:** Network issues, permission problems, or script errors.

**Solution:**
1. Check VS Code Output → Dev Containers for errors
2. Rebuild container: Command Palette → "Dev Containers: Rebuild Container"
3. If issues persist, run commands manually (see Manual Installation above)

### Nix builds are slow

**Cause:** Nix cache not configured or volume not persisted.

**Solution:**
```bash
# Verify cachix is configured
cachix use nix-community

# Check Nix volume is mounted
df -h | grep /nix

# If volume is missing, rebuild container
```

### VS Code extensions not loading

**Cause:** Container not fully initialized or extension installation failed.

**Solution:**
1. Wait for "Installing Extensions..." to complete in VS Code status bar
2. Reload window: Command Palette → "Developer: Reload Window"
3. Check Extensions view for installation status
4. Manually install missing extensions if needed

## Integration with MCP Servers

The devcontainer is configured to work with MCP servers for AI-assisted development. See:

- [MCP Setup Guide](MCP-SETUP.md) - Full MCP server configuration
- [MCP Verification Report](MCP-VERIFICATION-REPORT.md) - Verification and testing

Required environment variables for MCP servers:
- `GITHUB_TOKEN` - GitHub API access
- `BRAVE_API_KEY` - Web search capability (optional)
- `POSTGRES_CONNECTION_STRING` - AgentDB connection (optional)

Set these in VS Code settings or `.env` file. See [Secrets Quick Reference](SECRETS-QUICK-REFERENCE.md).

## Development Workflow

### Typical Development Session

1. **Start Container**
   ```bash
   # VS Code will prompt, or use Command Palette:
   # "Dev Containers: Reopen in Container"
   ```

2. **Verify Environment**
   ```bash
   specify check
   nix flake check
   ```

3. **Start Development**
   ```bash
   # Enter Nix development shell
   nix develop

   # Or enter specific shell
   nix develop .#mcp
   ```

4. **Use Spec Kit**
   - Open GitHub Copilot Chat
   - Use `/speckit.*` commands
   - Follow Spec-Driven Development workflow

5. **Test Changes**
   ```bash
   # Build configuration
   nix build .#nixosConfigurations.ovh-cloud

   # Run tests if available
   nix flake check
   ```

### Working with Multiple Nix Shells

pantherOS provides multiple development shells:

```bash
# Default shell - general development
nix develop

# Nix-specific development
nix develop .#nix

# MCP server development
nix develop .#mcp

# AI infrastructure development
nix develop .#ai

# Language-specific shells
nix develop .#rust
nix develop .#node
nix develop .#python
nix develop .#go
```

## Additional Resources

- [Spec Kit Integration Guide](../docs/tools/spec-kit.md) - Complete Spec Kit documentation
- [GitHub Copilot Instructions](copilot-instructions.md) - Copilot usage patterns
- [MCP Setup Guide](MCP-SETUP.md) - MCP server configuration
- [pantherOS Constitution](../.specify/memory/constitution.md) - Project principles

## Contributing

To improve the devcontainer configuration:

1. Edit `.github/devcontainer.json`
2. Test changes locally:
   - Rebuild container: "Dev Containers: Rebuild Container"
   - Verify all tools are installed
   - Test Spec Kit commands
3. Update this documentation
4. Submit PR with clear description

---

**Last Updated:** 2025-11-17  
**Version:** 1.0.0
