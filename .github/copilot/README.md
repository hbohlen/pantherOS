# GitHub Copilot Coding Agent Configuration

This directory contains the configuration and setup files for GitHub Copilot Coding Agent with enhanced capabilities for NixOS development.

## Overview

This configuration enables GitHub Copilot with:

- **5 MCP Servers** for specialized capabilities
- **VPS SSH Access** for remote NixOS builds
- **Testing Tools** for configuration validation
- **Automated Setup** scripts

## Quick Start

### 1. Run the Setup Script

```bash
cd /home/runner/work/pantherOS/pantherOS
./.github/copilot/setup-environment.sh
```

This interactive script will:
- Verify prerequisites (Nix, Node.js, Git, SSH)
- Configure Nix with flakes support
- Set up SSH access to your VPS (optional)
- Test MCP servers
- Validate your NixOS configuration

### 2. Configure GitHub Secrets

Add these secrets to your repository (Settings → Secrets and variables → Actions):

**Required for Brave Search:**
- `BRAVE_API_KEY` - Get from https://brave.com/search/api/

**Required for VPS Access:**
- `VPS_SSH_KEY` - Private SSH key for VPS authentication
- `VPS_HOST` - VPS hostname or IP address
- `VPS_USER` - SSH username (e.g., "nixos" or "root")
- `VPS_PORT` - SSH port (optional, defaults to 22)

### 3. Test Your Setup

```bash
# Test local build
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel

# Test VPS connection
ssh nixos-vps 'echo "Connected!"'

# Test VPS build
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'
```

## Files in This Directory

### Core Configuration

- **`action-setup.yml`** - Main configuration file defining MCP servers, VPS access, and available commands
- **`SETUP.md`** - Comprehensive setup guide with detailed instructions
- **`README.md`** (this file) - Quick reference and overview

### Setup and Testing

- **`setup-environment.sh`** - Interactive setup script for local environment and VPS configuration
- **`test-config-example.nix`** - Example NixOS configuration for testing

## MCP Servers

### Sequential Thinking
**Command:** `npx -y @modelcontextprotocol/server-sequential-thinking`  
**Purpose:** Complex reasoning and step-by-step planning  
**Use for:** Architecture decisions, multi-step migrations, debugging

### Brave Search
**Command:** `npx -y @modelcontextprotocol/server-brave-search`  
**Purpose:** Web search and real-time information  
**Use for:** Finding documentation, checking versions, researching solutions  
**Requires:** `BRAVE_API_KEY` secret

### Context7
**Command:** `npx -y @context7/mcp-server`  
**Purpose:** Enhanced code understanding and semantic analysis  
**Use for:** Impact analysis, finding related code, understanding dependencies

### NixOS MCP
**Command:** `npx -y @nixos/mcp-server`  
**Purpose:** NixOS-specific operations  
**Use for:** Package search, option lookup, configuration validation

### DeepWiki
**Command:** `npx -y @deepwiki/mcp-server`  
**Purpose:** Deep documentation and wiki search  
**Use for:** Finding specific docs, wiki integration, historical info

## VPS Access

### Available Commands

#### Push Configuration
```bash
rsync -avz --exclude='.git' --exclude='result' ./ nixos-vps:~/pantherOS/
```

#### Build on VPS
```bash
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'
```

#### Test (Dry Run)
```bash
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'
```

#### Apply Configuration
```bash
ssh nixos-vps 'cd ~/pantherOS && sudo nixos-rebuild switch --flake .#hetzner-vps'
```

### Workflow Example

1. Make changes to configuration files
2. Test locally: `nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel`
3. Push to VPS: `rsync -avz ./ nixos-vps:~/pantherOS/`
4. Build on VPS: `ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'`
5. Dry-run: `ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'`
6. Apply: `ssh nixos-vps 'cd ~/pantherOS && sudo nixos-rebuild switch --flake .#hetzner-vps'`

## Using Copilot with This Setup

### Example Prompts

**Using Sequential Thinking:**
```
@copilot Plan a migration from systemd-networkd to NetworkManager using sequential thinking
```

**Using Brave Search:**
```
@copilot Search for the latest stable version of the niri Wayland compositor
```

**Using NixOS MCP:**
```
@copilot Find NixOS packages for terminal emulators and show their options
```

**Combined Approach:**
```
@copilot I want to add a new service to my NixOS config. Use brave-search to find 
best practices, sequential-thinking to plan the implementation, and nixos-mcp to 
find the right options. Then help me test it on the VPS.
```

### Working with VPS

```
@copilot Help me push my current configuration to the VPS and build it there
```

```
@copilot The build failed on the VPS. Help me debug it by checking the logs
```

```
@copilot Test my firewall configuration changes on the VPS using a dry-run first
```

## Testing

### Local Testing
```bash
# Validate flake
nix flake check

# Show outputs
nix flake show

# Build configuration
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel

# Format code
nixpkgs-fmt .
```

### VPS Testing
```bash
# Connection test
ssh nixos-vps 'echo "Connected"'

# Nix version
ssh nixos-vps 'nix --version'

# Build test
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'

# Dry-run
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'
```

### MCP Server Testing
```bash
# Test sequential-thinking
npx -y @modelcontextprotocol/server-sequential-thinking --version

# Test brave-search (requires API key)
BRAVE_API_KEY=your_key npx -y @modelcontextprotocol/server-brave-search --help
```

## Troubleshooting

### Common Issues

**SSH Connection Failed**
- Verify VPS is running: `ping $VPS_HOST`
- Check key permissions: `chmod 600 ~/.ssh/copilot_vps`
- Test with verbose output: `ssh -vvv nixos-vps`

**Build Failed**
- Check flake syntax: `nix flake check`
- Update flake inputs: `nix flake update`
- Review error logs: `nix log <derivation>`

**MCP Server Not Working**
- Verify Node.js: `node --version`
- Test npx: `npx -y cowsay hello`
- Check API keys in secrets

**Disk Space Issues**
- Clean garbage: `sudo nix-collect-garbage -d`
- Check space: `df -h /nix/store`

See `SETUP.md` for detailed troubleshooting steps.

## Security Best Practices

1. **SSH Keys**
   - Use dedicated keys for Copilot
   - Store private keys only in GitHub Secrets
   - Restrict key permissions: `chmod 600`

2. **VPS Access**
   - Create dedicated user with minimal privileges
   - Disable root login
   - Use SSH keys only (no passwords)
   - Configure firewall properly

3. **API Keys**
   - Never commit keys to repository
   - Store in GitHub Secrets
   - Rotate regularly
   - Monitor usage

4. **Configuration Safety**
   - Always test locally first
   - Use dry-run before applying
   - Keep backups of working configs
   - Know how to rollback

## Support

For detailed information, see:
- **Setup Guide:** `SETUP.md` - Comprehensive setup instructions
- **Configuration:** `action-setup.yml` - Full configuration reference
- **NixOS Manual:** https://nixos.org/manual/nixos/stable/
- **GitHub Copilot Docs:** https://docs.github.com/en/copilot

## Version

Current version: **1.0.0**

Last updated: 2025-12-02

## Contributing

To improve this configuration:
1. Test your changes thoroughly
2. Update documentation
3. Submit a pull request

## License

Follows the repository's license.
