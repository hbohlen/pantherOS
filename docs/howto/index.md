# How-To Guides

> **Category:** How-To Guides  
> **Audience:** All Users  
> **Last Updated:** 2025-11-17

Task-oriented guides for common operations in pantherOS. Each guide provides step-by-step instructions to accomplish a specific task.

## Table of Contents

- [Getting Started](#getting-started)
- [Development](#development)
- [Operations](#operations)
- [Security](#security)

## Getting Started

### For New Users

**[Set Up Development Environment](setup-development.md)**
- Install prerequisites (Nix, Git)
- Clone repository
- Configure development shells
- Set up editor integration
- Verify your setup

**[Deploy a New Server](deploy-new-server.md)**
- Prerequisites and requirements
- Step-by-step deployment using nixos-anywhere
- Verification and post-deployment configuration
- Troubleshooting common issues

## Development

### Development Workflows

**[Set Up Development Environment](setup-development.md)**
- Development shell options (default, nix, mcp, language-specific)
- Editor configuration (VS Code, Neovim)
- Daily development workflow
- Testing configurations

**Using Spec-Driven Development:**

See the [Spec-Driven Workflow Guide](../contributing/spec-driven-workflow.md) for:
- Creating feature specifications
- Using Spec Kit commands
- Implementing features following specs
- Quality assurance workflows

### Code Management

**[Manage Secrets](manage-secrets.md)**
- Set up 1Password CLI
- Store and retrieve secrets
- Use secrets in development
- Best practices and troubleshooting

## Operations

### Deployment

**[Deploy a New Server](deploy-new-server.md)**
- Deploy pantherOS to cloud VPS
- Configure system settings
- Verify deployment
- Update and maintain

**System Updates:**

```bash
# Update flake dependencies
nix flake update

# Apply system updates
nixos-rebuild switch --flake .#hostname
```

**Rollback System:**

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or select from GRUB at boot
```

### Maintenance

**Update Configuration:**

1. Edit configuration files
2. Test build locally: `nix build .#nixosConfigurations.hostname.config.system.build.toplevel`
3. Deploy: `nixos-rebuild switch --flake .#hostname`

**Clean Up Old Generations:**

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations
sudo nix-collect-garbage -d

# Keep only last 3 generations
sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system
```

## Security

### Secrets Management

**[Manage Secrets](manage-secrets.md)**
- Complete guide to secrets management
- 1Password CLI setup and workflows
- Using direnv for automatic secret loading
- Security best practices

**Quick Reference:**

```bash
# Load secrets from 1Password
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN")

# Using direnv (automatic)
# Create .envrc with op read commands
direnv allow
```

### SSH Access

**Add SSH Keys:**

Edit `hosts/servers/hostname/configuration.nix`:

```nix
users.users.username.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... your-key"
];
```

**Disable Password Authentication:**

```nix
services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };
};
```

## Additional Guides

### Planned Guides

> **Note:** The following guides will be added as features are implemented:

- **Troubleshoot Common Issues** - Debug and fix common problems
- **Migrate to Dual Disk** - Set up RAID or dual-disk configuration
- **Configure Monitoring** - Set up observability stack
- **Manage Containers** - Podman/Docker container management
- **Configure VPN** - Tailscale network setup
- **Set Up CI/CD** - Automated deployment pipelines

## Quick Tips

### Check System Status

```bash
# View system information
nixos-version

# Check service status
systemctl status sshd
systemctl status tailscale

# View system logs
journalctl -xe
```

### Test Before Deploying

```bash
# Syntax check
nix flake check

# Build test
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# Dry run
nixos-rebuild dry-build --flake .#hostname
```

### Find Configuration Options

```bash
# Search for options
nix search nixpkgs postgresql

# View option documentation
nixos-option services.postgresql
```

## Getting Help

### Documentation

- **[Architecture Documentation](../architecture/)** - System design and decisions
- **[Reference Documentation](../reference/)** - Configuration and specifications
- **[Operations Documentation](../ops/)** - Hardware and operations
- **[Infrastructure Documentation](../infra/)** - NixOS tooling and concepts

### External Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://nixos.wiki/)
- [Nix Package Search](https://search.nixos.org/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

### Community

- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Matrix Chat](https://matrix.to/#/#nixos:nixos.org)
- [r/NixOS Subreddit](https://www.reddit.com/r/NixOS/)

## Contributing

Found an issue with a guide? Want to add a new guide?

1. Check [Contributing Guidelines](../contributing/)
2. Follow [Spec-Driven Workflow](../contributing/spec-driven-workflow.md)
3. Create a spec first for new guides
4. Submit a pull request

## See Also

- **[Spec-Driven Workflow](../contributing/spec-driven-workflow.md)** - Development methodology
- **[Feature Specifications](../specs/)** - Formal feature specs
- **[Contributing Guide](../contributing/)** - How to contribute
- **[Tools Documentation](../tools/)** - Tool-specific guides
