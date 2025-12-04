# Quick Reference Card - GitHub Copilot with NixOS

## Setup (One-Time)

```bash
# Run setup script
./.github/copilot/setup-environment.sh

# Add secrets to GitHub: Settings → Secrets and variables → Actions
# - BRAVE_API_KEY
# - VPS_SSH_KEY, VPS_HOST, VPS_USER, VPS_PORT
```

## MCP Servers Cheat Sheet

| Server                  | Purpose               | Example Use                                           |
| ----------------------- | --------------------- | ----------------------------------------------------- |
| **sequential-thinking** | Step-by-step planning | `@copilot Plan a migration using sequential thinking` |
| **brave-search**        | Web search            | `@copilot Search for NixOS 25.05 release notes`       |
| **context7**            | Code analysis         | `@copilot Analyze the impact of changing this module` |
| **nixos-mcp**           | NixOS operations      | `@copilot Find packages for terminal emulators`       |
| **deepwiki**            | Documentation search  | `@copilot Search NixOS wiki for Wayland setup`        |

## Common Commands

### Local Testing

```bash
# Validate flake
nix flake check

# Show flake outputs
nix flake show

# Build configuration
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel

# Format Nix code
nixpkgs-fmt .
# OR
nixfmt .
# OR
alejandra .

# Update flake inputs
nix flake update

# Check what would be built
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel --dry-run
```

### VPS Operations

```bash
# Test connection
ssh nixos-vps 'echo "Connected"'

# Push configuration
rsync -avz --exclude='.git' --exclude='result' ./ nixos-vps:~/pantherOS/

# Build on VPS (without applying)
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#hetzner-vps'

# Dry-run (show what would change)
ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'

# Apply configuration
ssh nixos-vps 'cd ~/pantherOS && sudo nixos-rebuild switch --flake .#hetzner-vps'

# Check system status
ssh nixos-vps 'systemctl status'

# View logs
ssh nixos-vps 'journalctl -xe'

# Rollback to previous generation
ssh nixos-vps 'sudo nixos-rebuild switch --rollback'
```

### Nix Development

```bash
# Enter development shell
nix develop

# Run command in dev shell
nix develop -c bash -c "command"

# Build specific output
nix build .#nixosConfigurations.hetzner-vps.config.system.build.etc

# Evaluate expression
nix eval .#nixosConfigurations.hetzner-vps.config.networking.hostName

# Search packages
nix search nixpkgs firefox

# Show package info
nix search nixpkgs --json firefox | jq
```

### Maintenance

```bash
# Garbage collection (local)
nix-collect-garbage -d

# Garbage collection (VPS)
ssh nixos-vps 'sudo nix-collect-garbage -d'

# List generations
nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Check disk usage
df -h /nix/store
ssh nixos-vps 'df -h /nix/store'

# Optimize store
nix-store --optimize
ssh nixos-vps 'sudo nix-store --optimize'
```

## Copilot Prompt Templates

### Configuration Changes

```
@copilot I want to add [feature] to my NixOS config.
Use nixos-mcp to find the right options, sequential-thinking
to plan the changes, and help me test it on the VPS.
```

### Debugging

```
@copilot The build failed with [error]. Use brave-search to
find solutions and help me debug this issue.
```

### Research

```
@copilot Use brave-search to research [topic] and deepwiki to
find relevant documentation. Then use sequential-thinking to
plan how to implement this in my NixOS config.
```

### Code Review

```
@copilot Use context7 to analyze this configuration change and
tell me what systems it will affect.
```

### Complete Workflow

```
@copilot I want to [task]. Please:
1. Use brave-search to research best practices
2. Use sequential-thinking to plan the implementation
3. Use nixos-mcp to find the right packages and options
4. Help me implement and test locally
5. Guide me through testing on the VPS
```

## File Locations

- **Configuration:** `.github/copilot/action-setup.yml`
- **Setup Guide:** `.github/copilot/SETUP.md`
- **Setup Script:** `.github/copilot/setup-environment.sh`
- **Test Example:** `.github/copilot/test-config-example.nix`
- **Full README:** `.github/copilot/README.md`

## Typical Workflow

1. **Make changes locally**

   ```bash
   vim hosts/servers/hetzner-vps/default.nix
   ```

2. **Test locally**

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

5. **Dry-run**

   ```bash
   ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild dry-build --flake .#hetzner-vps'
   ```

6. **Apply (if tests pass)**

   ```bash
   ssh nixos-vps 'cd ~/pantherOS && sudo nixos-rebuild switch --flake .#hetzner-vps'
   ```

7. **Verify**

   ```bash
   ssh nixos-vps 'systemctl status'
   ```

8. **Rollback (if needed)**
   ```bash
   ssh nixos-vps 'sudo nixos-rebuild switch --rollback'
   ```

## SSH Config

Add to `~/.ssh/config`:

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

## Environment Variables

For local MCP testing:

```bash
export BRAVE_API_KEY="your-api-key-here"
export VPS_HOST="your-vps-host.com"
export VPS_USER="nixos"
export VPS_PORT="22"
```

## Troubleshooting Quick Fixes

| Problem               | Quick Fix                                                  |
| --------------------- | ---------------------------------------------------------- |
| SSH connection failed | `ssh -vvv nixos-vps` (check verbose output)                |
| Permission denied     | `chmod 600 ~/.ssh/copilot_vps`                             |
| Flake check failed    | `nix flake check --show-trace`                             |
| Build failed          | `nix log <derivation>` or `nix build --show-trace`         |
| Out of disk space     | `sudo nix-collect-garbage -d && sudo nix-store --optimize` |
| MCP not working       | `node --version` and `npx -y cowsay hello`                 |
| Can't apply config    | Check user has sudo: `ssh nixos-vps 'sudo -l'`             |

## Emergency Rollback

**On VPS (if you can still SSH):**

```bash
ssh nixos-vps 'sudo nixos-rebuild switch --rollback'
```

**On VPS console (if SSH is broken):**

```bash
# At GRUB menu, select previous generation
# OR
sudo nixos-rebuild switch --rollback
```

## Help & Documentation

- **Full Setup Guide:** `.github/copilot/SETUP.md`
- **NixOS Manual:** https://nixos.org/manual/nixos/stable/
- **Package Search:** https://search.nixos.org/
- **Options Search:** https://search.nixos.org/options
- **NixOS Wiki:** https://nixos.wiki/
- **Copilot Docs:** https://docs.github.com/en/copilot

## Version: 1.0.0
