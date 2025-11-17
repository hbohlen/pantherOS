# NixOS Overview

> **Category:** Infrastructure  
> **Audience:** Contributors, System Administrators  
> **Last Updated:** 2025-11-17

An introduction to NixOS concepts and how they're used in pantherOS.

## Table of Contents

- [What is NixOS?](#what-is-nixos)
- [Key Concepts](#key-concepts)
- [NixOS in pantherOS](#nixos-in-pantheros)
- [Common Patterns](#common-patterns)

## What is NixOS?

**NixOS** is a Linux distribution built on the Nix package manager. It takes a unique approach to system configuration:

- **Declarative** - You describe what you want, not how to get there
- **Reproducible** - Same configuration produces identical systems
- **Atomic** - Changes are all-or-nothing, with automatic rollback
- **Reliable** - Can't break your system by upgrading

### Why NixOS for pantherOS?

pantherOS uses NixOS because it provides:

1. **Infrastructure as Code** - System configuration is code
2. **Reproducible Deployments** - Same config, same system, every time
3. **Safe Updates** - Easy rollback if something breaks
4. **Development Parity** - Dev and prod environments match exactly

## Key Concepts

### Declarative Configuration

In traditional Linux, you configure a system imperatively:

```bash
# Traditional approach - imperative
apt install nginx
systemctl enable nginx
systemctl start nginx
vim /etc/nginx/nginx.conf
```

In NixOS, you declare what you want:

```nix
# NixOS approach - declarative
services.nginx = {
  enable = true;
  virtualHosts."example.com" = {
    locations."/".root = "/var/www";
  };
};
```

**Benefits:**
- Configuration is version controlled
- Can't forget steps
- Reproducible across machines
- Self-documenting

### Nix Language

NixOS uses the Nix language for configuration:

```nix
# Basic syntax
{
  # Attribute set (like a dictionary/object)
  key = "value";
  
  # Lists
  packages = [ pkgs.vim pkgs.git pkgs.htop ];
  
  # Functions
  networking.hostName = "server-${environment}";
  
  # Conditions
  services.ssh.enable = if isProduction then true else false;
}
```

### Nix Store

The **Nix store** (`/nix/store/`) contains all packages and dependencies:

```
/nix/store/
├── abc123-nginx-1.24.0/
├── def456-openssl-3.0.12/
└── ghi789-python-3.11.6/
```

**Key properties:**
- Packages are immutable (never modified)
- Multiple versions can coexist
- Dependencies are explicit
- Garbage collection removes unused packages

### Generations

Every system configuration creates a **generation**:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Example output:
# 1   2024-11-01 10:30:00
# 2   2024-11-05 14:20:00
# 3   2024-11-10 09:15:00 (current)
```

**Benefits:**
- Instant rollback to any generation
- No risk in trying updates
- Easy to compare configurations

### Nix Flakes

**Flakes** are the modern way to manage Nix projects:

```nix
# flake.nix
{
  description = "pantherOS configuration";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      # Configuration here
    };
  };
}
```

**Benefits:**
- Explicit dependency versions (flake.lock)
- Better reproducibility
- Easier to share and compose
- Standard interface

## NixOS in pantherOS

### Repository Structure

```
pantherOS/
├── flake.nix              # Main flake definition
├── flake.lock             # Locked dependency versions
└── hosts/
    └── servers/
        ├── ovh-cloud/     # Host-specific config
        │   ├── configuration.nix
        │   ├── disko.nix
        │   └── home.nix
        └── hetzner-cloud/
            └── ...
```

### Configuration Files

**flake.nix** - Entry point:
```nix
{
  outputs = { nixpkgs, ... }: {
    nixosConfigurations.ovh-cloud = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/servers/ovh-cloud/configuration.nix
        # Other modules...
      ];
    };
  };
}
```

**configuration.nix** - System configuration:
```nix
{ config, pkgs, ... }:

{
  # Boot configuration
  boot.loader.grub.enable = true;
  
  # Networking
  networking.hostName = "ovh-cloud";
  
  # Users
  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  
  # Services
  services.openssh.enable = true;
  
  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];
}
```

**disko.nix** - Disk configuration:
```nix
{
  disko.devices.disk.main = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        # More partitions...
      };
    };
  };
}
```

**home.nix** - User environment (Home Manager):
```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    eza
    bottom
  ];
  
  programs.fish.enable = true;
  programs.starship.enable = true;
}
```

## Common Patterns

### Installing Packages

**System-wide packages:**
```nix
environment.systemPackages = with pkgs; [
  vim
  git
  htop
];
```

**User packages (Home Manager):**
```nix
home.packages = with pkgs; [
  ripgrep
  eza
];
```

### Enabling Services

**Basic service:**
```nix
services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };
};
```

**Service with configuration:**
```nix
services.nginx = {
  enable = true;
  virtualHosts."example.com" = {
    root = "/var/www";
    locations."/api" = {
      proxyPass = "http://localhost:3000";
    };
  };
};
```

### User Management

```nix
users.users.username = {
  isNormalUser = true;
  description = "User Name";
  extraGroups = [ "wheel" "networkmanager" ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAA... user@host"
  ];
};
```

### Modules and Imports

**Importing modules:**
```nix
{
  imports = [
    ./hardware-configuration.nix
    ./modules/nginx.nix
    ./modules/postgres.nix
  ];
}
```

**Creating reusable modules:**
```nix
# modules/nginx.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.custom.nginx = {
    enable = mkEnableOption "nginx server";
  };
  
  config = mkIf config.custom.nginx.enable {
    services.nginx.enable = true;
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
```

### Development Shells

```nix
# In flake.nix
devShells.x86_64-linux.default = pkgs.mkShell {
  buildInputs = with pkgs; [
    git
    neovim
    nixpkgs-fmt
  ];
  
  shellHook = ''
    echo "Welcome to pantherOS development!"
  '';
};
```

## Learning Resources

### Official Documentation

- **[NixOS Manual](https://nixos.org/manual/nixos/stable/)** - Complete NixOS documentation
- **[Nix Package Search](https://search.nixos.org/)** - Search for packages and options
- **[NixOS Options](https://search.nixos.org/options)** - Configuration option reference

### Community Resources

- **[NixOS Wiki](https://nixos.wiki/)** - Community-maintained documentation
- **[NixOS Discourse](https://discourse.nixos.org/)** - Community forum
- **[Nix Pills](https://nixos.org/guides/nix-pills/)** - Deep dive into Nix

### pantherOS Resources

- **[Architecture Overview](../architecture/overview.md)** - System design
- **[Configuration Reference](../reference/configuration-summary.md)** - Current configuration
- **[How-To: Setup Development](../howto/setup-development.md)** - Development environment

## See Also

- **[Development Shells](dev-shells.md)** - pantherOS development environments
- **[Infrastructure Index](index.md)** - All infrastructure documentation
- **[How-To: Deploy New Server](../howto/deploy-new-server.md)** - Deployment guide
