# How To: Set Up Development Environment

> **Category:** How-To Guide  
> **Audience:** Contributors, Developers  
> **Last Updated:** 2025-11-17

This guide explains how to set up a development environment for contributing to pantherOS.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Development Shells](#development-shells)
- [Editor Configuration](#editor-configuration)
- [Workflow](#workflow)

## Prerequisites

### Required Software

1. **Nix Package Manager** with flakes enabled
   ```bash
   # Check if Nix is installed
   nix --version
   
   # Enable flakes
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. **Git**
   ```bash
   git --version
   ```

3. **SSH Key** configured on GitHub
   ```bash
   # Generate if needed
   ssh-keygen -t ed25519 -C "your_email@example.com"
   
   # Add to GitHub: https://github.com/settings/keys
   ```

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/hbohlen/pantherOS.git
cd pantherOS
```

### 2. Set Up Secrets

Follow the [Secrets Management Guide](manage-secrets.md) to configure required secrets.

**Quick setup using direnv:**

```bash
# Create .envrc
cat > .envrc <<'EOF'
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN")
export MCP_CONFIG_PATH=".github/mcp-servers.json"
EOF

direnv allow
```

### 3. Enter Development Shell

```bash
# Enter default development shell
nix develop

# Or enter specific shell
nix develop .#nix     # For Nix development
nix develop .#mcp     # For AI-assisted development
```

### 4. Verify Setup

```bash
# Check tools are available
nix --version
nixpkgs-fmt --version
nil --version

# Test flake
nix flake check

# Try building a configuration
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
```

## Development Shells

pantherOS provides multiple development shells for different use cases.

### Default Shell (General Development)

**Tools included:**
- Git, Neovim, Fish shell
- Starship prompt
- direnv for environment management

```bash
nix develop
```

### Nix Development Shell

**Tools included:**
- `nil` - Nix language server
- `nixpkgs-fmt` - Code formatter
- `nix-eval-lsp` - Evaluation language server

```bash
nix develop .#nix

# Format Nix files
nixpkgs-fmt *.nix

# Check syntax
nix flake check
```

### MCP Development Shell (AI-Assisted)

**Tools included:**
- Node.js 20
- PostgreSQL client
- Docker
- All MCP servers configured
- Git and development tools

```bash
nix develop .#mcp

# Verify MCP servers
cat $MCP_CONFIG_PATH

# Test GitHub MCP server
npx -y @modelcontextprotocol/server-github
```

### Language-Specific Shells

**Rust:**
```bash
nix develop .#rust
cargo --version
rustc --version
```

**Node.js:**
```bash
nix develop .#node
node --version
npm --version
```

**Python:**
```bash
nix develop .#python
python --version
pip --version
```

**Go:**
```bash
nix develop .#go
go version
```

## Editor Configuration

### VS Code / Cursor

**Recommended extensions:**
- `jnoortheen.nix-ide` - Nix language support
- `GitHub.copilot` - AI assistance
- `eamodio.gitlens` - Git integration
- `arrterian.nix-env-selector` - Nix environment selector

**Install extensions:**
```bash
code --install-extension jnoortheen.nix-ide
code --install-extension GitHub.copilot
code --install-extension eamodio.gitlens
```

**Using Dev Container:**

The repository includes a dev container configuration:

```bash
# Open in VS Code
code .

# VS Code will prompt to reopen in container
# Or use Command Palette: "Dev Containers: Reopen in Container"
```

### Neovim

**Configuration included in development shells:**

```bash
# Enter shell with Neovim configured
nix develop

# Use Neovim
nvim flake.nix
```

**LSP support:**
- Nix: `nil` language server
- Python: `pyright`
- Rust: `rust-analyzer`
- Go: `gopls`

## Workflow

### Daily Development

1. **Start development session:**
   ```bash
   cd pantherOS
   nix develop .#nix
   ```

2. **Make changes:**
   ```bash
   # Edit files
   nvim hosts/servers/ovh-cloud/configuration.nix
   
   # Format code
   nixpkgs-fmt *.nix
   ```

3. **Test changes:**
   ```bash
   # Check syntax
   nix flake check
   
   # Build configuration
   nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
   ```

4. **Commit changes:**
   ```bash
   git add .
   git commit -m "feat: add new configuration"
   git push
   ```

### Using Spec-Driven Development

**Before implementing features:**

1. Check for existing specs: `ls docs/specs/`
2. Create a spec if needed: `/speckit.specify` (in GitHub Copilot)
3. Follow the workflow in [Spec-Driven Workflow Guide](../contributing/spec-driven-workflow.md)

**Creating a new feature:**

```bash
# 1. Create spec
/speckit.specify "Add PostgreSQL database support"

# 2. Clarify requirements
/speckit.clarify

# 3. Create implementation plan
/speckit.plan

# 4. Generate tasks
/speckit.tasks

# 5. Implement (or use automated implementation)
/speckit.implement
```

### Testing Configurations

**Local testing:**
```bash
# Build without deploying
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# Test in VM
nixos-rebuild build-vm --flake .#ovh-cloud
./result/bin/run-ovh-cloud-vm
```

**Remote testing:**
```bash
# Deploy to test server
nixos-rebuild switch --flake .#ovh-cloud \
  --target-host user@test-server \
  --use-remote-sudo
```

### Updating Dependencies

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Review changes
git diff flake.lock
```

### Code Review

Before submitting PRs:

1. **Format code:**
   ```bash
   nixpkgs-fmt *.nix
   ```

2. **Check for errors:**
   ```bash
   nix flake check
   ```

3. **Test builds:**
   ```bash
   nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
   ```

4. **Review changes:**
   ```bash
   git status
   git diff
   ```

## Troubleshooting

### Nix Flake Check Fails

```bash
# Get detailed error
nix flake check --show-trace

# Check specific configuration
nix eval .#nixosConfigurations.ovh-cloud.config.system.build.toplevel --show-trace
```

### Development Shell Won't Start

```bash
# Clear Nix cache
nix-collect-garbage -d

# Update flake
nix flake update

# Try with explicit path
nix develop .#default
```

### LSP Not Working

```bash
# Verify LSP is installed
nil --version

# Restart editor/LSP server
# In VS Code: Command Palette → "Developer: Reload Window"
# In Neovim: `:LspRestart`
```

### Build Fails

```bash
# Clean build artifacts
rm -rf result

# Try clean build
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel --rebuild

# Check for syntax errors
nix flake check --show-trace
```

## See Also

- **[Spec-Driven Workflow](../contributing/spec-driven-workflow.md)** - Complete development methodology
- **[Manage Secrets](manage-secrets.md)** - Set up secrets and environment variables
- **[Deploy New Server](deploy-new-server.md)** - Deployment guide
- **[Contributing Guide](../contributing/)** - Contribution guidelines
- **[Architecture Overview](../architecture/overview.md)** - System architecture
