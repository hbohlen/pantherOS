# Spec: Reverse Proxy Service

## ADDED Requirements

### Requirement: Caddy Package with Cloudflare Plugin
**Type**: ADDED  
**Priority**: Critical  
**Component**: flake.nix

#### Scenario: Build Caddy with Cloudflare DNS Plugin
```nix
# In flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  
  outputs = { self, nixpkgs, ... }: {
    packages.x86_64-linux.caddy = 
      nixpkgs.caddy.overrideAttrs (old: {
        buildInputs = old.buildInputs or [ ] ++ [
          # Cloudflare DNS plugin - requires build from source with plugins
          # This is a placeholder - actual implementation needs custom derivation
        ];
      });
  };
}
```

**Rationale**: Caddy needs Cloudflare DNS plugin for DNS-01 ACME challenges.

**Validation**:
- Package builds successfully
- Plugin is included in binary
- Version matches expected Caddy 2.x

### Requirement: Caddy Module Options
**Type**: ADDED  
**Priority**: Critical  
**Component**: hosts/hetzner-vps/caddy.nix

#### Scenario: Enable Caddy Service
```nix
{ lib, config, pkgs, ... }:

{
  options = {
    services.caddy = {
      enable = lib.mkEnableOption "Caddy reverse proxy";
      
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.caddy;
        description = "Caddy package to use";
      };
      
      configFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to Caddyfile";
      };
      
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/caddy";
        description = "Directory for Caddy data (certificates, etc.)";
      };
    };
  };
}
```

**Rationale**: Module needs configurable options for enable/disable, package selection, and configuration.

**Validation**:
- Options have correct types (bool, package, path)
- Defaults are sensible
- Documentation is clear

### Requirement: Systemd Service Configuration
**Type**: ADDED  
**Priority**: Critical  
**Component**: hosts/hetzner-vps/caddy.nix

#### Scenario: Caddy Service Starts on Boot
```nix
config = lib.mkIf config.services.caddy.enable {
  systemd.services.caddy = {
    description = "Caddy Web Server";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    
    serviceConfig = {
      Type = "notify";
      ExecStart = "${config.services.caddy.package}/bin/caddy run --config ${config.services.caddy.configFile}";
      ExecReload = "${config.services.caddy.package}/bin/caddy reload --config ${config.services.caddy.configFile}";
      Restart = "on-failure";
      RestartSec = "5s";
      User = "caddy";
      Group = "caddy";
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ config.services.caddy.dataDir ];
      LoadCredential = [ "cloudflare-token:/run/secrets/cloudflare-token" ];
    };
  };
}
```

**Rationale**: Caddy needs systemd service management with proper security settings.

**Validation**:
- Service starts successfully
- Service restarts on failure
- File permissions are correct
- Credentials are loaded

### Requirement: Data Directory Setup
**Type**: ADDED  
**Priority**: Medium  
**Component**: hosts/hetzner-vps/caddy.nix

#### Scenario: Certificate Storage Directory
```nix
config = lib.mkIf config.services.caddy.enable {
  systemd.tmpfiles.rules = [
    "d ${config.services.caddy.dataDir} 0750 caddy caddy - -"
  ];
}
```

**Rationale**: Certificates and ACME data need persistent storage.

**Validation**:
- Directory exists with correct permissions
- Owned by caddy:caddy
- Survives reboots

### Requirement: Caddy User and Group
**Type**: ADDED  
**Priority**: Medium  
**Component**: hosts/hetzner-vps/caddy.nix

#### Scenario: Create Dedicated Caddy User
```nix
config = lib.mkIf config.services.caddy.enable {
  users.users.caddy = {
    isSystemUser = true;
    group = "caddy";
    home = config.services.caddy.dataDir;
    createHome = true;
  };
  
  users.groups.caddy = { };
}
```

**Rationale**: Run Caddy as non-root user for security.

**Validation**:
- User exists with correct settings
- Group exists
- No shell access
- Minimal privileges

## MODIFIED Requirements

### Requirement: Caddyfile Configuration
**Type**: MODIFIED  
**Priority**: High  
**Component**: hosts/hetzner-vps/caddy.nix

#### Scenario: Basic Caddyfile Structure
```caddyfile
# Global options
{
  debug
  admin localhost:2019
}

# Email for ACME
acme email admin@hbohlen.systems
acme dns cloudflare { env.CLOUDFLARE_API_TOKEN }

# Logging
log {
  output file /var/log/caddy/access.log {
    roll_size 100mb
    roll_keep 5
  }
  level DEBUG
}

# Error handling
errors {
  log {
    output file /var/log/caddy/error.log {
      roll_size 100mb
      roll_keep 5
    }
  }
}
```

**Rationale**: Configuration needs debug mode, admin endpoint, ACME setup, and logging.

**Validation**:
- Syntax is valid Caddyfile
- All sections are present
- Paths are correct

## REMOVED Requirements

### Requirement: Hardcoded Secrets
**Type**: REMOVED  
**Priority**: High  
**Component**: All configuration files

#### Scenario: No Hardcoded Cloudflare Tokens
```nix
# BAD - Don't do this
config.services.caddy.environment.CLOUDFLARE_API_TOKEN = "secret-token-here";

# GOOD - Use OpNix
config.services.caddy.environment.CLOUDFLARE_API_TOKEN = "@opnix-cloudflare-token";
```

**Rationale**: Secrets must never be committed to repository.

**Validation**:
- Grep finds no hardcoded tokens
- All secrets reference OpNix

## Integration Points

### With NixOS System
- Service integrates with systemd
- Uses NixOS networking
- Respects firewall rules
- Follows NixOS user management

### With Flake
- Package from nixpkgs
- Custom derivation for plugins
- Version locked to nixos-25.05

### With Other Services
- Proxy to localhost backends
- Port 80/443 exposed externally
- Admin port 2019 only on localhost

## Testing Requirements

### Build Tests
```bash
nix build .#caddy
nixos-rebuild build .#hetzner-vps
```

### Service Tests
```bash
systemctl status caddy
journalctl -u caddy -n 50
curl http://localhost:2019/config
```

### Config Validation
```bash
${pkgs.caddy}/bin/caddy validate --config Caddyfile
```

## Acceptance Criteria

- [ ] Caddy package builds with Cloudflare plugin
- [ ] Module options are well-defined with types
- [ ] Systemd service starts successfully
- [ ] Caddy runs as caddy user
- [ ] Data directory exists with correct permissions
- [ ] Admin endpoint accessible on localhost:2019
- [ ] Debug mode enabled for development
- [ ] No hardcoded secrets in configuration

## Related Specs

- [ACME Cloudflare](acme-cloudflare/spec.md) - Uses ACME configuration
- [Tailscale Access Control](tailscale-access-control/spec.md) - Applies IP filtering
- [Secrets Integration](secrets-integration/spec.md) - Provides Cloudflare token
