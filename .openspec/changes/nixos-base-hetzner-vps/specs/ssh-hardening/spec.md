# SSH Hardening Specification

## ADDED Requirements

### Key-Only Authentication

**Requirement**: Configure OpenSSH to accept only key-based authentication with no password authentication allowed.

**Configuration**:
```nix
services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
    PubkeyAuthentication = true;
    AuthenticationMethods = "publickey";
  };
};
```

**Rationale**: Eliminates brute force attack vectors and aligns with modern security best practices.

#### Scenario: Administrative Access
**Given**: System configured with SSH key-only authentication  
**When**: Administrator attempts SSH connection with valid key  
**Then**:
- SSH connection established successfully
- No password prompt presented
- Key-based authentication completes
- User gains shell access

#### Scenario: Unauthorized Access Attempt
**Given**: SSH service running with key-only authentication  
**When**: Attacker attempts password-based access  
**Then**:
- Connection rejected immediately
- No password authentication available
- Access denied with appropriate error
- Event logged for security monitoring

### ED25519 Key Format Requirement

**Requirement**: Enforce ED25519 key format for enhanced security over traditional RSA keys.

**Configuration**:
```nix
services.openssh = {
  settings = {
    HostKeyAlgorithms = "ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
    PubkeyAcceptedKeyTypes = "ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
    KexAlgorithms = "curve25519-sha256,curve25519-sha256@libssh.org";
  };
};
```

**Rationale**: ED25519 provides stronger cryptographic security with better performance than RSA keys.

#### Scenario: ED25519 Key Connection
**Given**: User possesses ED25519 SSH key  
**When**: Connection attempted to server  
**Then**:
- ED25519 key accepted and used for authentication
- Strong cryptographic algorithm employed
- Connection established successfully
- No fallback to weaker algorithms

#### Scenario: Legacy Key Handling
**Given**: User attempts connection with RSA key  
**When**: RSA key presented for authentication  
**Then**:
- RSA-SHA2-512/256 keys accepted (legacy support)
- ED25519 keys preferred for new connections
- Upgrade path available for users
- Security maintained during transition

### Root Login Restrictions

**Requirement**: Allow root login but prohibit password authentication, requiring key-based access only.

**Configuration**:
```nix
services.openssh = {
  settings = {
    PermitRootLogin = "prohibit-password";
    AllowUsers = [ "root" "opencode" ];
  };
};
```

**Rationale**: Root access needed for system administration but must be secured with key-only authentication.

#### Scenario: Root Key Access
**Given**: Root user has configured SSH key  
**When**: Root SSH connection attempted  
**Then**:
- Root login permitted with key authentication
- No password prompt available
- Full administrative access granted
- Security logging captures access

#### Scenario: Root Password Block
**Given**: Attempt to login as root with password  
**When**: Password authentication attempted  
**Then**:
- Login rejected immediately
- "prohibit-password" enforced
- Authentication fails cleanly
- Security event logged

### Global Password Authentication Disable

**Requirement**: Completely disable password authentication across all users and services.

**Configuration**:
```nix
services.openssh = {
  settings = {
    PasswordAuthentication = false;
    ChallengeResponseAuthentication = false;
    KbdInteractiveAuthentication = false;
    PAM = {
      enable = false;
    };
  };
};
```

**Rationale**: Prevents all forms of password-based authentication, including keyboard-interactive and PAM-based methods.

#### Scenario: Authentication Method Testing
**Given**: SSH service configured with all password auth disabled  
**When**: Various authentication methods tested  
**Then**:
- Password authentication rejected
- Keyboard-interactive authentication blocked
- PAM authentication disabled
- Only public key methods accepted

## Implementation Details

### SSH Service Configuration
```nix
{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      # Authentication
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
      AuthenticationMethods = "publickey";
      
      # Key algorithms
      HostKeyAlgorithms = "ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
      PubkeyAcceptedKeyTypes = "ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
      KexAlgorithms = "curve25519-sha256,curve25519-sha256@libssh.org";
      
      # Security hardening
      Protocol = 2;
      X11Forwarding = false;
      AllowTcpForwarding = false;
      PermitTunnel = false;
      UsePAM = false;
      
      # Logging and monitoring
      LogLevel = "INFO";
      SyslogFacility = "AUTH";
      
      # Connection handling
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      
      # Access control
      AllowUsers = [ "root" "opencode" ];
      DenyUsers = [ ];
    };
  };
}
```

### Dependencies
- `openssh`: SSH server implementation
- `systemd`: Service management and logging
- `shadow`: User account management for SSH key storage

### Security Hardening Features

#### Algorithm Security
- **ED25519 preferred**: Modern, secure key exchange
- **RSA-SHA2 support**: Legacy compatibility
- **Strong KEX**: Curve25519 key exchange only

#### Service Restrictions
- **Protocol 2 only**: Disable legacy SSHv1
- **No X11 forwarding**: Prevent GUI attack vectors
- **No TCP forwarding**: Block tunneling attempts
- **No PAM**: Eliminate authentication complexity

#### Access Control
- **User restriction**: Only allow specific users
- **Key-only auth**: No fallback to passwords
- **Connection limits**: Prevent resource exhaustion

### Testing Requirements
1. **Key Authentication Test**: Valid keys connect successfully
2. **Password Rejection Test**: Password attempts fail
3. **Root Access Test**: Root key access works
4. **Algorithm Test**: ED25519 preferred, RSA-SHA2 supported
5. **Access Control Test**: Unauthorized users blocked
6. **Connection Test**: Service stability under load

### Security Considerations
- **Key Management**: Secure storage and distribution
- **Audit Logging**: All authentication attempts logged
- **Fail2ban Integration**: Prevent brute force attempts (future)
- **Regular Updates**: Keep SSH server updated

### Integration Points
- **Network Layer**: Depends on networking and firewall
- **User Management**: SSH key distribution and management
- **Tailscale**: VPN required for management access
- **Monitoring**: SSH access logs and alerts
- **Backup**: SSH key backup and recovery

### Key Distribution Strategy
1. **ED25519 keys**: Primary authentication method
2. **RSA-SHA2 keys**: Legacy support during transition
3. **Key storage**: `~/.ssh/authorized_keys` for each user
4. **Key rotation**: Regular key updates recommended
5. **Backup**: Secure key backup procedures

### Monitoring and Alerting
- **Access Logs**: Monitor successful/failed logins
- **Key Usage**: Track key-based authentication
- **Brute Force**: Alert on repeated failed attempts
- **Unusual Access**: Monitor access patterns

### Validation Criteria
- [ ] SSH service starts successfully
- [ ] Key-based authentication works for all users
- [ ] Password authentication completely disabled
- [ ] Root login available with keys only
- [ ] ED25519 keys preferred and functional
- [ ] RSA-SHA2 keys supported for legacy
- [ ] Unauthorized users denied access
- [ ] All authentication attempts logged
- [ ] Service stable under normal load
- [ ] No security vulnerabilities detected

---

**Spec Version**: 1.0  
**Last Updated**: 2025-11-19  
**Capability**: ssh-hardening  
**Change ID**: nixos-base-hetzner-vps