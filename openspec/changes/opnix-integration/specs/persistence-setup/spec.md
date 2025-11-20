# Spec Delta: Token Persistence Configuration

## Overview
This specification defines the requirements for ensuring the 1Password service account token persists across system reboots, enabling automated rebuilds and maintaining secret management functionality.

## ADDED Requirements

### Configure impermanence for token directory
**Requirement**: Configure the impermanence module to preserve the 1Password service account token directory across system reboots for automated rebuild functionality.

**File**: `hosts/servers/hetzner-cloud/default.nix`  
**Type**: ADDED

#### Scenario: Token directory added to persistence
Given the impermanence configuration, when `/root/.config/op` is added to persistence, then:
- Directory survives system reboots
- Directory is preserved across nixos-rebuild switches
- Directory exists in `/persist/root/.config/op` after reboot

#### Scenario: Existing persistence configuration maintained
Given the current impermanence setup, when token persistence is added, then:
- Existing persistent directories remain configured
- No conflicts with current persistence patterns
- Token persistence follows established impermanence conventions

### Token file survives various operations
**Requirement**: Ensure the 1Password service account token file persists across system reboots, configuration rebuilds, and package updates to maintain continuous secret management capability.

**File**: `hosts/servers/hetzner-cloud/default.nix`  
**Type**: ADDED

#### Scenario: Token survives system reboot
Given the persistence configuration, when the system reboots, then:
- `/root/.config/op/token` continues to exist
- OpNix service can access the token after reboot
- No manual token re-entry required

#### Scenario: Token survives nixos-rebuild switch
Given the persistence configuration, when `nixos-rebuild switch` is executed, then:
- Token file remains accessible after configuration change
- OpNix service continues functioning with new configuration
- No service interruption from secret management perspective

#### Scenario: Token survives system updates
Given the persistence configuration, when system packages are updated, then:
- Token persists across package manager operations
- Service account authentication remains valid
- No credential refresh required after updates

### Proper directory permissions for persistence
**Requirement**: Configure proper ownership and permissions for the persistent token directory to maintain security while ensuring the OpNix service can access the token file.

**File**: `hosts/servers/hetzner-cloud/default.nix`  
**Type**: ADDED

#### Scenario: Persistent directory has correct ownership
Given the persistence configuration, when `/persist/root/.config/op` is created, then:
- Directory is owned by `root:root`
- Directory has mode `0700` (accessible only by root)
- No permission conflicts with service operation

#### Scenario: Token file permissions are maintained
Given the persistence configuration, when token is written to persistent location, then:
- File ownership is `root:root`
- File mode is `0600` (readable/writable only by root)
- Security is maintained in persistent storage

## Implementation Details

### Persistence Configuration
```nix
{
  # ... other configuration

  environment.persistence."/persist".directories = [
    # Existing persistent directories
    "/root/.ssh",
    "/root/.config/btop",
    
    # OpNix token persistence
    "/root/.config/op"
  ];
}
```

### Directory Structure
```
/persist/
└── root/
    └── .config/
        └── op/
            └── token  # Service account token file
```

### Permission Model
- **Directory**: `/persist/root/.config/op` - mode `0700`, owner `root:root`
- **Token file**: `/persist/root/.config/op/token` - mode `0600`, owner `root:root`
- **Runtime location**: `/root/.config/op/token` - mode `0600`, owner `root:root`

## Validation Criteria

### Persistence Verification
- [ ] Directory `/persist/root/.config/op` exists after system boot
- [ ] Token file persists across multiple reboots
- [ ] Directory permissions are correct (`0700` for directory, `0600` for file)
- [ ] Ownership is `root:root` for directory and file

### Service Continuity
- [ ] OpNix service starts successfully after reboot
- [ ] Secret retrieval works without manual intervention
- [ ] No authentication errors due to missing token
- [ ] Service status shows active after system operations

### Security Validation
- [ ] Persistent directory is not world-readable
- [ ] Token file is not world-accessible
- [ ] No sensitive data exposed in persistent storage beyond token
- [ ] Impermanence principles maintained for all other data

## Dependencies
- **Impermanence Module**: Requires impermanence to be configured
- **Service Configuration**: Requires OpNix service to be enabled
- **User Setup**: Requires root user to exist (always true for NixOS)

## Related Capabilities
- **Service Configuration**: Token persistence supports service operation
- **Bootstrap Process**: Token setup leverages persistence mechanism
- **Secret Mappings**: Service must have persistent token to fetch secrets

## Security Considerations

### Token Protection
- Token stored only in persistent location, not in nix store
- File permissions prevent unauthorized access
- No token exposure in system logs or configuration files

### Persistence Security Model
- Only token persists, not individual secrets
- Secrets remain in ramfs (cleared on reboot)
- Consistent with impermanence security model

### Access Control
- Only root can access persistent token directory
- Service account has read-only access to 1Password
- No privilege escalation through token persistence

## Operational Considerations

### Backup Strategy
- Token backed up automatically via impermanence
- No separate backup procedure required
- 1Password serves as source of truth for all secrets

### Recovery Procedures
- Token regeneration possible via 1Password service account
- Clear procedures for token rotation if compromised
- Graceful handling of token expiration

### Monitoring
- Token file existence can be monitored
- Service status indicates token availability
- No secret content logging (only access patterns)

## Error Handling

### Missing Persistent Directory
- Directory creation handled by impermanence module
- Appropriate error messages if persistence fails
- Service handles missing token gracefully

### Permission Issues
- Clear errors when directory permissions are incorrect
- Automatic correction where possible
- Fallback procedures for permission problems

### Disk Space Issues
- Minimal storage requirements (token is small file)
- No impact on impermanence functionality
- Clear handling if persistence storage is unavailable