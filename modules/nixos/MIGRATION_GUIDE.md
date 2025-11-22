# Module Migration Guide
# Mapping from old module structure to new granular structure

## Core Modules Migration:
- ./core/base.nix → ./core/system/base-config.nix
- ./core/boot.nix → ./core/system/boot-config.nix
- ./core/systemd.nix → ./core/system/systemd-config.nix
- ./core/networking.nix → ./core/networking-config.nix
- ./core/users.nix → Split into:
  - ./core/users/user-management.nix
  - ./core/users/sudo-config.nix
  - ./core/users/user-defaults.nix

## Services Modules Migration:
- ./services/tailscale.nix → Split into:
  - ./services/networking/tailscale-service.nix
  - ./services/networking/tailscale-firewall.nix
- ./services/ssh.nix → ./services/ssh-service-config.nix
- Other services would follow similar patterns

## Security Modules Migration:
- ./security/firewall.nix → ./security/firewall/firewall-config.nix
- ./security/ssh.nix → ./security/ssh-security-config.nix
- Other security modules would follow similar patterns

## How to Update Your Configuration:
Instead of importing the old modules directly, use the new granular modules:

# Old way:
{ config, pkgs, ... }: {
  imports = [
    ./modules/nixos/core/users.nix
    ./modules/nixos/services/tailscale.nix
  ];
}

# New way:
{ config, pkgs, ... }: {
  imports = [
    ./modules/nixos/core/users/user-management.nix
    ./modules/nixos/core/users/sudo-config.nix
    ./modules/nixos/services/networking/tailscale-service.nix
    ./modules/nixos/services/networking/tailscale-firewall.nix
  ];
}

# Or using directory imports (recommended):
{ config, pkgs, ... }: {
  imports = [
    ./modules/nixos/core/users
    ./modules/nixos/services/networking
  ];
}