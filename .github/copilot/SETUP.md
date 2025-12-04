# GitHub Copilot Coding Agent Setup Guide

This document provides comprehensive instructions for setting up GitHub Copilot Coding Agent with access to NixOS testing environments and specialized MCP servers.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [MCP Servers](#mcp-servers)
- [VPS Configuration](#vps-configuration)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)

## Overview

This setup enables GitHub Copilot with:

1. **MCP Servers** for enhanced capabilities:
   - Sequential Thinking - Complex reasoning and planning
   - Brave Search - Web search and research
   - Context7 - Enhanced code understanding
   - NixOS MCP - NixOS-specific operations
   - DeepWiki - Documentation search

2. **VPS Access** for:
   - Remote NixOS configuration building
   - Testing in production-like environment
   - Hardware-specific configuration validation

3. **Testing Tools** for:
   - Local configuration validation
   - Remote build testing
   - Automated deployment checks

## Prerequisites

### Local Environment

1. **Nix Package Manager** (with flakes enabled)

   ```bash
   curl -L https://nixos.org/nix/install | sh -s -- --daemon
   ```

2. **Node.js** (for MCP servers)

   ```bash
   nix profile install nixpkgs#nodejs
   ```

3. **Git** (for version control)
   ```bash
   nix profile install nixpkgs#git
   ```

### VPS Requirements

1. **NixOS installed** on the VPS
2. **SSH access** configured
3. **User with sudo privileges** (for applying configurations)
4. **Sufficient disk space** for Nix store (~10GB minimum)

### API Keys and Credentials

1. **Brave Search API Key**: Register at https://brave.com/search/api/
2. **SSH Key Pair**: For VPS authentication
3. **VPS Access Details**: Host, user, and port

## Quick Start

### Step 1: Configure GitHub Secrets

Navigate to your repository settings and add the following secrets:

```
Settings → Secrets and variables → Actions → New repository secret
```

Required secrets:

| Secret Name     | Description             | Example                                  |
| --------------- | ----------------------- | ---------------------------------------- |
| `BRAVE_API_KEY` | Brave Search API key    | `BSA...`                                 |
| `VPS_SSH_KEY`   | Private SSH key for VPS | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `VPS_HOST`      | VPS hostname or IP      | `vps.example.com` or `192.0.2.1`         |
| `VPS_USER`      | SSH username            | `nixos` or `root`                        |
| `VPS_PORT`      | SSH port (optional)     | `22` (default)                           |

### Step 2: Generate SSH Key for VPS Access

```bash
# Generate a new SSH key pair
ssh-keygen -t ed25519 -C "copilot-nixos-access" -f ~/.ssh/copilot_vps

# Display the private key (to add to GitHub Secrets)
cat ~/.ssh/copilot_vps

# Copy the public key to your VPS
ssh-copy-id -i ~/.ssh/copilot_vps.pub user@vps-host
```

### Step 3: Configure VPS

On your VPS, ensure the following:

```bash
# 1. Enable SSH access
sudo systemctl enable sshd
sudo systemctl start sshd

# 2. Create working directory
mkdir -p ~/pantherOS

# 3. Enable Nix flakes (add to /etc/nixos/configuration.nix)
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# 4. Rebuild to apply
sudo nixos-rebuild switch
```

### Step 4: Test the Setup

```bash
# Test local build
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel

# Test VPS connection
ssh -i ~/.ssh/copilot_vps user@vps-host 'echo "Connection successful"'

# Test VPS build
ssh -i ~/.ssh/copilot_vps user@vps-host 'cd ~/pantherOS && nix --version'
```

## MCP Servers

### Sequential Thinking MCP

**Purpose**: Enables structured, step-by-step reasoning for complex problems.

**Use Cases**:

- Planning multi-step changes
- Debugging complex issues
- Architecture decisions
- Refactoring strategies

**Example Usage**:

```
@copilot Help me plan a migration from configuration A to B using sequential thinking
```

### Brave Search MCP

**Purpose**: Provides web search capabilities for real-time information.

**Use Cases**:

- Finding documentation
- Looking up package versions
- Researching best practices
- Checking compatibility

**Example Usage**:

```
@copilot Search for the latest NixOS stable release
```

**Setup Notes**:

- Requires `BRAVE_API_KEY` secret
- Free tier: 2,000 queries/month
- Get API key: https://brave.com/search/api/

### Context7 MCP

**Purpose**: Enhanced context understanding and code analysis.

**Use Cases**:

- Understanding complex codebases
- Semantic code search
- Finding related configurations
- Impact analysis

**Example Usage**:

```
@copilot Analyze the impact of changing the firewall configuration
```

### NixOS MCP

**Purpose**: NixOS-specific operations and assistance.

**Use Cases**:

- Package search
- Option lookup
- Configuration validation
- Flake operations

**Example Usage**:

```
@copilot Find NixOS options for configuring SSH
```

### DeepWiki MCP

**Purpose**: Deep search across documentation and wikis.

**Use Cases**:

- Finding specific documentation
- Wiki integration
- Knowledge base access
- Historical information

**Example Usage**:

```
@copilot Search the NixOS wiki for Wayland configuration examples
```

## VPS Configuration

### SSH Configuration

Create or update `~/.ssh/config`:

```ssh-config
Host nixos-vps
  HostName your-vps-host.com
  User nixos
  Port 22
  IdentityFile ~/.ssh/copilot_vps
  StrictHostKeyChecking accept-new
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

### Available Commands

#### Push Configuration to VPS

```bash
rsync -avz --exclude='.git' --exclude='result' ./ nixos-vps:~/pantherOS/
```

#### Build Configuration on VPS

```bash
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'
```

#### Test Configuration (Dry Run)

```bash
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'
```

#### Apply Configuration

```bash
ssh nixos-vps 'cd ~/pantherOS && sudo nixos-rebuild switch --flake .#hetzner-vps'
```

### Workflow Example

1. **Make changes locally**

   ```bash
   # Edit configuration files
   vim hosts/servers/hetzner-vps/default.nix
   ```

2. **Test locally** (if possible)

   ```bash
   nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel
   ```

3. **Push to VPS**

   ```bash
   rsync -avz --exclude='.git' --exclude='result' ./ nixos-vps:~/pantherOS/
   ```

4. **Build on VPS**

   ```bash
   ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'
   ```

5. **Test with dry-run**

   ```bash
   ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'
   ```

6. **Apply if successful**
   ```bash
   ssh nixos-vps 'cd ~/pantherOS && sudo nixos-rebuild switch --flake .#hetzner-vps'
   ```

## Testing

### Local Testing

```bash
# Validate flake
nix flake check

# Build specific configuration
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel

# Show flake outputs
nix flake show

# Format code
nixpkgs-fmt .
```

### Remote Testing

```bash
# Test VPS connection
ssh nixos-vps 'echo "Connected"'

# Check Nix version on VPS
ssh nixos-vps 'nix --version'

# Build on VPS without applying
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'

# Dry-run to see what would change
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'
```

### MCP Server Testing

```bash
# Test sequential-thinking MCP
npx -y @modelcontextprotocol/server-sequential-thinking --version

# Test other MCP servers
npx -y @modelcontextprotocol/server-brave-search --help
npx -y @context7/mcp-server --help
```

## Troubleshooting

### SSH Connection Issues

**Problem**: Cannot connect to VPS

**Solutions**:

1. Verify VPS is running: `ping $VPS_HOST`
2. Check SSH key permissions: `chmod 600 ~/.ssh/copilot_vps`
3. Test with verbose output: `ssh -vvv nixos-vps`
4. Verify SSH service on VPS: `systemctl status sshd`

### Nix Build Failures

**Problem**: Configuration fails to build

**Solutions**:

1. Check flake inputs: `nix flake update`
2. Verify syntax: `nix flake check`
3. Review error logs: `nix log <derivation-path>`
4. Test with reduced config to isolate issue

### MCP Server Issues

**Problem**: MCP server not responding

**Solutions**:

1. Verify Node.js installation: `node --version`
2. Check npx can access internet: `npx -y cowsay hello`
3. Verify API keys are set correctly
4. Check MCP server logs in Copilot output

### Permission Issues

**Problem**: Cannot apply configuration on VPS

**Solutions**:

1. Ensure user has sudo access: `ssh nixos-vps 'sudo -l'`
2. Add user to wheel group (on VPS): `sudo usermod -aG wheel username`
3. Configure passwordless sudo if needed (on VPS):
   ```nix
   security.sudo.wheelNeedsPassword = false;
   ```

### Disk Space Issues

**Problem**: Not enough space for build

**Solutions**:

1. Clean up old generations (on VPS):
   ```bash
   sudo nix-collect-garbage -d
   sudo nix-store --gc
   ```
2. Check available space: `df -h /nix/store`
3. Delete old profiles: `nix-env --list-generations --profile /nix/var/nix/profiles/system`

## Security Best Practices

### SSH Key Management

1. **Use dedicated keys**: Don't reuse personal SSH keys
2. **Restrict permissions**: `chmod 600` for private keys
3. **Regular rotation**: Rotate keys periodically
4. **Secure storage**: Store private keys only in GitHub Secrets

### VPS Access

1. **Least privilege**: Create a dedicated user with minimal permissions
2. **Disable root login**: Use sudo instead
3. **Firewall rules**: Restrict SSH to known IPs if possible
4. **SSH key only**: Disable password authentication

### API Keys

1. **Never commit**: Keep API keys out of version control
2. **Use secrets**: Store in GitHub Secrets or environment variables
3. **Monitor usage**: Track API usage to detect unauthorized access
4. **Rotate regularly**: Update keys periodically

### Configuration Safety

1. **Test first**: Always test locally before applying to VPS
2. **Dry-run**: Use `nixos-rebuild dry-build` to preview changes
3. **Backup**: Keep backups of working configurations
4. **Rollback plan**: Know how to rollback: `sudo nixos-rebuild switch --rollback`
5. **Version control**: Commit working configurations

## Advanced Configuration

### Custom MCP Servers

To add additional MCP servers, edit `.github/copilot/action-setup.yml`:

```yaml
mcp_servers:
  my-custom-server:
    command: npx
    args:
      - '-y'
      - '@my-org/custom-mcp-server'
    env:
      CUSTOM_API_KEY: ${{ secrets.CUSTOM_API_KEY }}
    description: 'My custom MCP server'
```

### Multiple VPS Targets

Configure multiple VPS servers for different environments:

```bash
# In ~/.ssh/config
Host nixos-vps-staging
  HostName staging.example.com
  User nixos
  IdentityFile ~/.ssh/copilot_vps_staging

Host nixos-vps-production
  HostName production.example.com
  User nixos
  IdentityFile ~/.ssh/copilot_vps_production
```

### Automated Testing

Create a test script:

```bash
#!/usr/bin/env bash
# test-config.sh

set -e

echo "Testing configuration..."

# Build locally
echo "Building locally..."
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel

# Push to VPS
echo "Pushing to VPS..."
rsync -avz --exclude='.git' --exclude='result' ./ nixos-vps:~/pantherOS/

# Build on VPS
echo "Building on VPS..."
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'

# Dry-run
echo "Dry-run on VPS..."
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'

echo "All tests passed!"
```

## Support and Resources

- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Nix Package Search**: https://search.nixos.org/
- **NixOS Wiki**: https://nixos.wiki/
- **GitHub Copilot Docs**: https://docs.github.com/en/copilot
- **MCP Documentation**: https://modelcontextprotocol.io/

## Version History

- **v1.0.0** (2025-12-02): Initial release
  - MCP servers: sequential-thinking, brave-search, context7, nixos-mcp, deepwiki
  - VPS SSH access configuration
  - NixOS build and test capabilities
  - Comprehensive documentation

## Contributing

To improve this setup:

1. Create a new branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request with detailed description

## License

This configuration follows the repository's license.
