# NixOS Configuration Patterns

## Overview

This document contains NixOS configuration patterns, best practices, and domain-specific knowledge for pantherOS infrastructure.

## Core Configuration Patterns

### Module Structure

```nix
# Standard module template
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.my-service;
in {
  options.services.my-service = {
    enable = mkEnableOption "my-service";
    
    package = mkOption {
      type = types.package;
      default = pkgs.my-service;
      description = "Package to use for my-service";
    };
    
    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Configuration for my-service";
    };
  };

  config = mkIf cfg.enable {
    # Implementation
  };
}
```

### Flake Configuration

```nix
# flake.nix structure
{
  description = "pantherOS - Personal NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    opnix.url = "github:opnix-dev/opnix";
    disko.url = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      yoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/yoga/configuration.nix
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit inputs; };
      };
      
      zephyrus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/zephyrus/configuration.nix
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit inputs; };
      };
      
      hetzner-vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/hetzner-vps/configuration.nix
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit inputs; };
      };
      
      ovh-vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/ovh-vps/configuration.nix
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
```

## Host Configuration Patterns

### Workstation Configuration

```nix
# Workstation base configuration
{ config, lib, pkgs, ... }:

{
  # System packages
  environment.systemPackages = with pkgs; [
    # Development tools
    git
    vim
    curl
    wget
    
    # Desktop environment
    niri
    ghostty
    fish
    
    # Applications
    zed-editor
    zen-browser
    _1password
  ];

  # Services
  services = {
    # Desktop
    xserver.enable = true;
    
    # Development
    podman.enable = true;
    
    # Security
    tailscale.enable = true;
  };

  # User configuration
  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "podman" ];
    shell = pkgs.fish;
  };

  # Home manager
  home-manager.users.hbohlen = {
    home.stateVersion = "23.11";
    programs = {
      fish.enable = true;
      git.enable = true;
    };
  };
}
```

### Server Configuration

```nix
# Server base configuration
{ config, lib, pkgs, ... }:

{
  # System packages (minimal)
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    htop
  ];

  # Services
  services = {
    # Security
    openssh.enable = true;
    tailscale.enable = true;
    
    # Monitoring
    fail2ban.enable = true;
  };

  # Security hardening
  security = {
    sudo.enable = false;
    sudo.wheelNeedsPassword = false;
  };

  # Networking
  networking = {
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 ];  # SSH only
  };

  # User configuration
  users.users.root = {
    openssh.authorizedKeys.keys = [
      # SSH keys from 1Password
    ];
  };
}
```

## Module Categories

### Core Modules

#### System Configuration
```nix
# modules/nixos/core/system.nix
{ config, lib, pkgs, ... }:

{
  # System settings
  system = {
    stateVersion = "23.11";
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = config.services.tailscale.enable;
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Localization
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  # Time zone
  time.timeZone = "America/New_York";
}
```

#### Boot Configuration
```nix
# modules/nixos/core/boot.nix
{ config, lib, pkgs, ... }:

{
  # Boot loader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 5;
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel modules
  boot.kernelModules = [ "kvm-intel" "vhost_vsock" ];

  # Kernel parameters
  boot.kernelParams = [
    "quiet"
    "splash"
    "intel_iommu=on"
  ];
}
```

### Service Modules

#### Tailscale Configuration
```nix
# modules/nixos/services/tailscale.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tailscale-pantheros;
in {
  options.services.tailscale-pantheros = {
    enable = mkEnableOption "Tailscale configuration for pantherOS";
    
    hostType = mkOption {
      type = types.enum [ "workstation" "server" ];
      default = "workstation";
      description = "Type of host for Tailscale configuration";
    };
    
    advertiseRoutes = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Routes to advertise via Tailscale";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = if cfg.hostType == "server" then "server" else "client";
      extraUpFlags = 
        (optional (cfg.advertiseRoutes != []) "--advertise-routes=${concatStringsSep "," cfg.advertiseRoutes}");
    };
    
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
```

#### Podman Configuration
```nix
# modules/nixos/services/podman.nix
{ config, lib, pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  # Podman socket for user access
  users.users.hbohlen.extraGroups = [ "podman" ];

  # Podman Compose
  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
```

## Security Patterns

### SSH Configuration
```nix
# modules/nixos/security/ssh.nix
{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = mkDefault "prohibit-password";
      X11Forwarding = false;
      AllowTcpForwarding = false;
      GatewayPorts = "no";
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      MaxAuthTries = 3;
      MaxSessions = 3;
    };
    
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Fail2ban for SSH
  services.fail2ban.jails.sshd = {
    enabled = true;
    filter = "sshd[mode=aggressive]";
    maxretry = 3;
    bantime = "1h";
  };
}
```

### Firewall Configuration
```nix
# modules/nixos/security/firewall.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.firewall-pantheros;
in {
  options.networking.firewall-pantheros = {
    enable = mkEnableOption "Advanced firewall for pantherOS";
    
    hostType = mkOption {
      type = types.enum [ "workstation" "server" ];
      default = "workstation";
      description = "Type of host for firewall rules";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.enable = true;
    networking.firewall.logRefusedConnections = true;
    networking.firewall.logRefusedPackets = true;
    
    # Trusted interfaces
    networking.firewall.trustedInterfaces = [ "tailscale0" "lo" ];
    
    # Base ports
    networking.firewall.allowedTCPPorts = [ 22 ];  # SSH
    networking.firewall.allowedUDPPorts = [ 41641 ];  # Tailscale
    
    # Host-specific rules
    networking.firewall.extraCommands = 
      if cfg.hostType == "server" then ''
        # Server-specific hardening
        iptables -A INPUT -p tcp --dport 22 -m limit --limit 3/min --limit-burst 3 -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -j REJECT --reject-with tcp-reset
      '' else ''
        # Workstation-specific rules
        iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        iptables -A INPUT -i tailscale0 -j ACCEPT
        iptables -A INPUT -j DROP
      '';
  };
}
```

## Development Patterns

### Development Environment
```nix
# modules/nixos/development/environment.nix
{ config, lib, pkgs, ... }:

{
  # Development packages
  environment.systemPackages = with pkgs; [
    # Languages
    nodejs
    python3
    go
    rustc
    cargo
    
    # Build tools
    gcc
    cmake
    make
    pkg-config
    
    # Version control
    git
    git-lfs
    
    # Editors
    zed-editor
    vim
    
    # Terminal
    ghostty
    fish
    tmux
  ];

  # Development services
  services = {
    # Container runtime
    podman.enable = true;
    
    # Database (if needed)
    postgresql.enable = mkDefault false;
    redis.enable = mkDefault false;
  };

  # Development user configuration
  users.users.hbohlen = {
    extraGroups = [ "docker" "podman" ];
    shell = pkgs.fish;
  };

  # Home manager development configuration
  home-manager.users.hbohlen = {
    programs = {
      fish = {
        enable = true;
        shellInit = ''
          # Development environment setup
          set -gx DEV_DIR $HOME/dev
          set -gx EDITOR zed
        '';
      };
      
      git = {
        enable = true;
        userName = "hbohlen";
        userEmail = "hbohlen@example.com";
      };
    };
  };
}
```

## Best Practices

### Module Organization
1. **Single Concern**: Each module should do one thing well
2. **Options First**: Define all options before implementation
3. **Conditional Logic**: Use `mkIf` for conditional configuration
4. **Documentation**: Document all options with descriptions
5. **Testing**: Include test configurations where possible

### Configuration Management
1. **Flake-based**: Use flakes for reproducible configurations
2. **Modular**: Break configuration into reusable modules
3. **Version Control**: Track all configuration changes
4. **Testing**: Build configurations before deployment
5. **Rollback**: Always have rollback plan

### Security Practices
1. **Principle of Least Privilege**: Minimal permissions required
2. **No Hardcoded Secrets**: Use 1Password/OpNix integration
3. **Firewall Default Deny**: Block all traffic by default
4. **Regular Updates**: Enable automatic security updates
5. **Audit Logging**: Log all security-relevant events

## Common Issues and Solutions

### Module Import Errors
```nix
# Wrong: Absolute path
imports = [
  /home/user/pantherOS/modules/nixos/services/my-service.nix
];

# Correct: Relative path
imports = [
  ../../modules/nixos/services/my-service.nix
];
```

### Option Conflicts
```nix
# Use mkIf to avoid conflicts
services.nginx.enable = mkIf config.services.web-server.enable true;
services.caddy.enable = mkIf (!config.services.web-server.enable) true;
```

### Conditional Configuration
```nix
# Good: Conditional with mkIf
config = mkIf cfg.enable {
  # Configuration only when enabled
};

# Bad: Manual condition checks
config = if cfg.enable then {
  # Configuration
} else {};
```

## Integration Points

- **Hardware Discovery**: Hardware-specific module selection
- **Security Agent**: Security module configuration
- **AI Memory Architect**: Container service configuration
- **Observability Agent**: Monitoring service setup
- **Deployment Orchestrator**: Configuration validation

---

This document provides the foundation for NixOS configuration patterns used throughout pantherOS.