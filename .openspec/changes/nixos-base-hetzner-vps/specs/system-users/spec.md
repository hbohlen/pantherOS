# System Users Specification

## ADDED Requirements

### Root User SSH Key Authentication

**Requirement**: Configure root user with SSH key authentication for administrative access while prohibiting password-based authentication.

**Configuration**:
```nix
users.users.root = {
  openssh.authorizedKeys.keys = [
    # ED25519 SSH key to be provided at deployment
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host"
  ];
};
```

**Rationale**: Root access required for system administration but must be secured with key-only authentication.

#### Scenario: Root Administrative Access
**Given**: Root user configured with SSH key  
**When**: Administrator attempts SSH connection as root  
**Then**:
- SSH connection established using key authentication
- Root shell access granted
- Full system administration privileges available
- No password authentication options presented

#### Scenario: Root Key Management
**Given**: Need to update root SSH key  
**When**: Key rotation or replacement required  
**Then**:
- New key can be configured via NixOS configuration
- Old key removed from authorized_keys
- Key update applied on next system rebuild
- Administrative continuity maintained

### OpenCode System User Creation

**Requirement**: Create dedicated system user 'opencode' for OpenCode service execution with appropriate group memberships.

**Configuration**:
```nix
users.users.opencode = {
  isSystemUser = true;
  group = "opencode";
  description = "OpenCode service user";
  home = "/var/lib/opencode";
  createHome = true;
};

users.groups.opencode = {
  members = [ "opencode" ];
};
```

**Rationale**: Service isolation requires dedicated user account with minimal privileges and appropriate group access.

#### Scenario: OpenCode Service Execution
**Given**: OpenCode service user created  
**When**: OpenCode service starts  
**Then**:
- Service runs under opencode user account
- Minimal system privileges assigned
- Service files owned by opencode user
- Process isolation from system services

#### Scenario: Group-Based Access Control
**Given**: opencode user member of system groups  
**When**: Service requires specific access  
**Then**:
- Group membership provides necessary permissions
- Service operates with restricted privileges
- Audit trail maintained for service actions
- Security boundaries preserved

### OnePassword Integration Group

**Requirement**: Add opencode user to 'onepassword-secrets' group for future OpNix integration.

**Configuration**:
```nix
users.users.opencode = {
  extraGroups = [ "onepassword-secrets" ];
};
```

**Rationale**: Future integration with OpNix for secret management requires appropriate group membership.

#### Scenario: Secrets Access
**Given**: OpenCode service user in onepassword-secrets group  
**When**: OpNix services configured (future)  
**Then**:
- Service can access 1Password secrets via OpNix
- Group membership enables secret retrieval
- No hardcoded secrets in configuration
- Secure secret management pathway available

### User Access Control

**Requirement**: Configure SSH access control to allow only specified users.

**Configuration**:
```nix
services.openssh.settings.AllowUsers = [ "root" "opencode" ];
```

**Rationale**: Restricts SSH access to only necessary users, reducing attack surface.

#### Scenario: Authorized User Access
**Given**: SSH access control configured  
**When**: Allowed user attempts connection  
**Then**:
- User authentication proceeds normally
- SSH access granted upon successful auth
- Only authorized users can connect
- Access control enforced at authentication

#### Scenario: Unauthorized User Block
**Given**: SSH access control active  
**When**: Unauthorized user attempts connection  
**Then**:
- Connection denied before authentication
- User not present in AllowUsers list
- Access rejected immediately
- Event logged for security monitoring

## Implementation Details

### User and Group Configuration
```nix
{ config, lib, pkgs, ... }:

{
  # System users
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host"
    ];
  };

  users.users.opencode = {
    isSystemUser = true;
    group = "opencode";
    description = "OpenCode service user";
    home = "/var/lib/opencode";
    createHome = true;
    extraGroups = [ "onepassword-secrets" ];
    shell = "/bin/sh";
    uid = 999;
  };

  users.groups.opencode = {
    system = true;
    gid = 999;
  };

  # Additional groups for future integration
  users.groups."onepassword-secrets" = {
    system = true;
  };
}
```

### SSH Key Management
- **Root Key**: ED25519 format for enhanced security
- **Key Storage**: NixOS configuration for declarative key management
- **Key Rotation**: Update via configuration rebuild
- **Backup Strategy**: Secure key backup procedures required

### Service User Configuration
- **UID/GID**: System-assigned (999) for isolation
- **Home Directory**: `/var/lib/opencode` for service files
- **Shell**: `/bin/sh` for minimal environment
- **Groups**: Minimal group memberships for security

### Security Considerations

#### Principle of Least Privilege
- **Root Access**: Required for administration only
- **OpenCode User**: Minimal privileges for service operation
- **Group Memberships**: Only necessary groups assigned
- **SSH Access**: Restricted to authorized users only

#### Access Control
- **SSH AllowList**: Explicit user enumeration
- **Group-Based Permissions**: Controlled access to resources
- **Service Isolation**: Separate user for service processes
- **Key-Only Authentication**: No password access

### Dependencies
- `shadow`: User and group management
- `openssh`: SSH service and key authentication
- `systemd`: Service management for OpenCode (future)
- `opnix`: 1Password integration (future)

### Integration Points
- **SSH Service**: Depends on user configuration
- **OpenCode Service**: Will run as opencode user (future)
- **OpNix Integration**: Requires onepassword-secrets group (future)
- **File Permissions**: Service files owned by appropriate users
- **Process Management**: User context for service processes

### User Environment Setup

#### Root User Environment
- **Shell**: Standard shell for administration
- **Home Directory**: `/root` for admin files
- **SSH Access**: Key-based only
- **Privileges**: Full system access

#### OpenCode User Environment
- **Shell**: Minimal shell (`/bin/sh`)
- **Home Directory**: `/var/lib/opencode` for service
- **SSH Access**: Key-based for debugging
- **Privileges**: Restricted for service operation

### Testing Requirements
1. **User Creation Test**: All users created with correct attributes
2. **Group Membership Test**: Users in correct groups
3. **SSH Key Test**: Root key authentication functional
4. **Access Control Test**: SSH allowlist enforced
5. **Permission Test**: Service user has minimal privileges
6. **Integration Test**: Group access for future services

### Migration Considerations
- **Existing Users**: Preserve any existing user configurations
- **Key Migration**: Import existing SSH keys if any
- **Data Migration**: Handle existing service data
- **Configuration Updates**: Maintain backward compatibility

### Validation Criteria
- [ ] Root user created with SSH key authentication
- [ ] OpenCode user created with system attributes
- [ ] Appropriate group memberships assigned
- [ ] SSH access control restricts to authorized users
- [ ] Service user has minimal system privileges
- [ ] Home directories created with proper ownership
- [ ] User IDs assigned correctly
- [ ] Authentication methods work as configured
- [ ] Security boundaries maintained
- [ ] Future integration ready (OpNix groups)

---

**Spec Version**: 1.0  
**Last Updated**: 2025-11-19  
**Capability**: system-users  
**Change ID**: nixos-base-hetzner-vps