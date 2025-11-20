# Spec Delta: OpNix Service Configuration

## Overview
This specification defines the requirements for enabling and configuring the OpNix service within the hetzner-vps NixOS configuration, establishing the core secret management service.

## ADDED Requirements

### Enable OpNix service
**Requirement**: Enable the OpNix systemd service in the hetzner-vps configuration to provide 1Password secret management functionality with proper service lifecycle management.

**File**: `hosts/servers/hetzner-cloud/default.nix`  
**Type**: ADDED

#### Scenario: Service enabled with basic configuration
Given the hetzner-vps host configuration, when OpNix service is enabled, then:
- `services.onepassword-secrets.enable` is set to `true`
- Service imports are added: `imports = [ inputs.opnix.nixosModules.default ];`
- Service starts automatically on system boot

#### Scenario: Service creates required directories
Given the OpNix service is enabled, when the system boots, then:
- `/run/secrets` directory is created as ramfs
- `/root/.config/op` directory is created for token storage
- Proper permissions are set on service directories

#### Scenario: Service handles missing token gracefully
Given the OpNix service is enabled but no token file exists, when the service starts, then:
- Service logs appropriate error message
- Service does not crash or prevent system boot
- Secret injection attempts fail gracefully

### Configure user access

**Requirement**: Configure user access permissions for the OpNix service to ensure appropriate users can read their assigned secrets while maintaining security boundaries.

**File**: `hosts/servers/hetzner-cloud/default.nix`  
**Type**: ADDED

#### Scenario: Root user has access
Given the service configuration, when secrets are retrieved, then:
- Root user can read all secrets in `/run/secrets/`
- Root user has permission to manage the service
- System administration tasks are not blocked

#### Scenario: Opencode user has access  
Given the service configuration, when secrets are accessed, then:
- Opencode user can read secrets owned by `opencode:opencode`
- User can access application-specific secrets
- User cannot access secrets owned by other users (caddy:caddy)

#### Scenario: Caddy user has access for reverse proxy
Given the service configuration, when reverse proxy secrets are needed, then:
- Caddy user can read secrets owned by `caddy:caddy`
- Reverse proxy can access Cloudflare API tokens
- Web service secrets are accessible to caddy process

### Configure token file location

**Requirement**: Configure the 1Password service account token file location in the OpNix service configuration to enable persistent authentication across system operations.

**File**: `hosts/servers/hetzner-cloud/default.nix`  
**Type**: ADDED

#### Scenario: Token file path configured
Given the service configuration, when 1Password API calls are made, then:
- Service looks for token at `/root/.config/op/token`
- Token file location is configurable via `services.onepassword-secrets.tokenFile`
- Default token location follows OpNix conventions

#### Scenario: Token directory persists across reboots
Given the impermanence configuration, when the system reboots, then:
- `/root/.config/op/` directory is preserved in `/persist/`
- Token file survives system reboots
- No manual token re-entry required after reboot

## Implementation Details

### Host Configuration Structure
```nix
{ inputs, lib, config, ... }:

{
  imports = [
    inputs.opnix.nixosModules.default
    # ... other imports
  ];

  services.onepassword-secrets = {
    enable = true;
    users = [ "root" "opencode" ];
    tokenFile = "/root/.config/op/token";
    outputDirectory = "/run/secrets";
  };

  environment.persistence."/persist".directories = [
    "/root/.config/op"
  ];
}
```

### Service Dependencies
- **Network**: Requires internet access to 1Password API
- **Filesystem**: Requires /run and /root/.config directories
- **Users**: Requires root and opencode users to exist

### Service Lifecycle
1. **Boot**: Service starts, creates /run/secrets ramfs
2. **Token Check**: Reads token from configured location
3. **Secret Fetch**: Retrieves secrets from 1Password via API
4. **File Creation**: Writes secrets to /run/secrets with proper permissions
5. **Runtime**: Maintains secrets in memory, exposes via filesystem

## Validation Criteria

### Service Functionality
- [ ] `systemctl status onepassword-secrets` shows active service
- [ ] Service starts without errors when token is present
- [ ] Service handles missing token gracefully
- [ ] `/run/secrets` directory is created as ramfs

### User Access
- [ ] Root can read all secrets in /run/secrets/
- [ ] Opencode user can read secrets owned by opencode:opencode
- [ ] Other users cannot read secrets they don't own
- [ ] Service user permissions work correctly

### Persistence
- [ ] `/root/.config/op` survives system reboots
- [ ] Token persistence works across nixos-rebuild switches
- [ ] No sensitive data written to persistent storage (only token)

## Dependencies
- **Flake Integration**: Requires OpNix to be available as flake input
- **Impermanence**: Requires impermanence module for persistence
- **User Management**: Requires opencode user to exist

## Related Capabilities
- **Flake Integration**: Must be completed before service configuration
- **Secret Mappings**: Builds on service to define specific secrets
- **Bootstrap Process**: Documents manual token setup for this service

## Notes
- Service is enabled but may not function until token is manually added
- Graceful failure handling is critical for initial deployment
- Persistence configuration ensures automated rebuilds work