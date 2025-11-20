# Security Model Architecture

This document defines the comprehensive security model for the pantherOS infrastructure, including network security, secrets management, and host-specific security policies.

## Security Architecture Overview

pantherOS implements a zero-trust security model with layered defense mechanisms designed for personal infrastructure across 4 hosts with varying security requirements.

### Core Security Principles

1. **Zero Trust Networking**: No implicit trust between hosts or networks
2. **Defense in Depth**: Multiple security layers for each host type
3. **Principle of Least Privilege**: Minimal access rights for each service and user
4. **Secrets Management**: Centralized secrets with environment-specific access
5. **Audit and Monitoring**: Comprehensive logging and access tracking

## Tailscale Mesh Network

Tailscale serves as the primary network layer for secure host-to-host communication.

### Network Topology

```
Tailnet Architecture:
├── yoga (workstation) - Leaf node
├── zephyrus (workstation) - Leaf node  
├── hetzner-vps (server) - Exit node + relay
└── ovh-vps (server) - Exit node + relay
```

**Design Decisions:**
- **Exit Nodes**: Servers provide exit node capability for workstations
- **Relay Mode**: Primary server (hetzner-vps) acts as relay for traffic
- **Dimensional Network**: All hosts can reach each other via Tailscale
- **No Direct Internet**: All services hidden behind Tailscale overlay

### Access Control Lists (ACLs)

ACLs define granular network access between hosts:

```nix
# ACL Configuration via Tailscale API
{
  aclRules = [
    # Workstations to servers (limited access)
    {
      action = "accept";
      protocol = "tcp";
      sources = ["tag:workstation"];
      destinations = ["tag:server:22"];  # SSH only
      ports = ["22/TCP"];
    }
    
    # Workstations to services (via reverse proxy)
    {
      action = "accept";
      protocol = "tcp";
      sources = ["tag:workstation"];
      destinations = ["tag:server:80", "tag:server:443"];
      ports = ["80/TCP", "443/TCP"];
    }
    
    # Server to server (full access)
    {
      action = "accept";
      protocol = "tcp";
      sources = ["tag:server"];
      destinations = ["tag:server"];
      ports = ["*/*"];
    }
    
    # DNS resolution
    {
      action = "accept";
      protocol = "udp";
      sources = ["*"];  # All hosts
      destinations = ["tag:server:53"];
      ports = ["53/UDP"];
    }
  ];
}
```

### Tailscale Integration

#### Service Configuration
```nix
# modules/nixos/services/tailscale.nix
{ config, lib, ... }:

{
  options.services.tailscale = {
    enable = lib.mkEnableOption "Tailscale mesh networking";
    exitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable this host as Tailscale exit node";
    };
    hostType = lib.mkOption {
      type = lib.types.enum [ "workstation" "server" ];
      description = "Host type for ACL tagging";
    };
  };
  
  config = lib.mkIf config.services.tailscale.enable {
    # Tailscale package
    environment.systemPackages = [ pkgs.tailscale ];
    
    # Systemd service
    systemd.services.tailscale = {
      enable = true;
      after = [ "network-pre.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock";
        ExecStartPre = [
          "${pkgs.tailscale}/bin/tailscale up --host-tag=${config.services.tailscale.hostType}"
        ];
      };
    };
    
    # Exit node configuration for servers
    systemd.services.tailscale.postStart = lib.mkIf config.services.tailscale.exitNode [
      "${pkgs.tailscale}/bin/tailscale up --advertise-exit-node"
    ];
    
    # Firewall integration
    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ 41641 ];  # Tailscale default port
      allowedTCPPorts = lib.mkIf config.services.tailscale.exitNode [ 41641 ];
    };
  };
}
```

#### Host Tagging Strategy
```nix
# Tag configuration for ACLs
{
  tags = {
    "workstation" = [ "yoga" "zephyrus" ];
    "server" = [ "hetzner-vps" "ovh-vps" ];
    "development" = [ "hetzner-vps" ];  # Development servers only
    "production" = [ "ovh-vps" ];      # Production servers only
  };
}
```

## Secrets Management

### 1Password Integration

1Password serves as the single source of truth for all secrets, managed via the `pantherOS` service account.

#### Service Account Configuration
```nix
# flake.nix inputs
{
  inputs = {
    opnix = {
      url = "github:thedave42/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, opnix, ... }: {
    nixosConfigurations = {
      yoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          opnix.nixosModules.opnix
          {
            opnix = {
              # 1Password integration
              enable = true;
              vault = "pantherOS";
              serviceAccount = "pantherOS";
              
              # Environment mapping
              environments = {
                "hetzner-vps" = {
                  host = "hetzner-vps";
                  vault = "pantherOS";
                };
                "ovh-vps" = {
                  host = "ovh-vps"; 
                  vault = "pantherOS";
                };
                "yoga" = {
                  host = "yoga";
                  vault = "pantherOS";
                };
                "zephyrus" = {
                  host = "zephyrus";
                  vault = "pantherOS";
                };
              };
            };
            
            # Host-specific configuration continues
          }
        ];
      };
    };
  };
}
```

#### SSH Key Management
SSH keys are stored in 1Password and retrieved dynamically:

```nix
# modules/shared/secrets/ssh.nix
{ config, lib, ... }:

{
  options.security.ssh = {
    enable = lib.mkEnableOption "SSH key management via 1Password";
    keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "yogaSSH" "zephyrusSSH" "desktopSSH" "phoneSSH" ];
      description = "SSH keys to retrieve from 1Password";
    };
  };
  
  config = lib.mkIf config.security.ssh.enable {
    # SSH agent via 1Password
    programs.ssh.startAgent = false;  # Disable system SSH agent
    
    # 1Password SSH agent integration
    environment.variables = {
      SSH_AUTH_SOCK = "/run/user/1000/1password/opnix-ssh.sock";
    };
    
    # Key retrieval for each environment
    system.activationScripts."1password-ssh-keys" = {
      text = ''
        #!/bin/sh
        ${pkgs.opnix}/bin/opnix get ssh-keys ${config.security.ssh.keys}
        chmod 600 ~/.ssh/id_*  # Secure SSH key permissions
      '';
      deps = [ "opnix-setup" ];
    };
  };
}
```

#### Application Secrets
```nix
# modules/nixos/services/caddy.nix
{ config, lib, ... }:

{
  options.services.caddy = {
    enable = lib.mkEnableOption "Caddy reverse proxy";
    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Domains to configure proxy for";
    };
    cloudflareApiKey = lib.mkOption {
      type = lib.types.str;
      apply = (file: "file:${file}");
      description = "Path to Cloudflare API key in 1Password";
    };
  };
  
  config = lib.mkIf config.services.caddy.enable {
    # Caddy configuration with secrets from 1Password
    environment.etc."caddy/Caddyfile".text = config.lib.opnix.getSecret "cloudflare-api-key" config.services.caddy.cloudflareApiKey;
    
    services.caddy = {
      enable = true;
      configFile = "/etc/caddy/Caddyfile";
      # Caddy environment with secrets
      environmentFile = config.lib.opnix.getEnvironmentFile "caddy-env";
    };
  };
}
```

#### Database Password Management
```nix
# modules/nixos/services/database.nix
{ config, lib, ... }:

{
  options.services.database = {
    enable = lib.mkEnableOption "Database service";
    password = lib.mkOption {
      type = lib.types.str;
      apply = (file: "file:${file}");
      description = "Database password file from 1Password";
    };
  };
  
  config = lib.mkIf config.services.database.enable {
    services.postgresql = {
      enable = true;
      passwordFile = config.services.database.password;
    };
    
    # Database backup configuration
    system.activationScripts."database-backup" = {
      text = ''
        #!/bin/sh
        ${pkgs.opnix}/bin/opnix get database-backup-password > /run/postgresql/backup-password
      '';
      deps = [ "postgresql-setup" ];
    };
  };
}
```

## Firewall Strategy

### Host-Specific Firewall Rules

Firewalls are configured differently for workstations and servers based on their security requirements.

#### Workstation Firewall (yoga, zephyrus)

```nix
# modules/nixos/security/firewall/workstation.nix
{ config, lib, ... }:

{
  config.networking.firewall = {
    enable = true;
    
    # Default allow for local services
    defaultForwardPolicy = "DROP";
    
    # Trusted interfaces (local network, Tailscale)
    trustedInterfaces = [ 
      "lo" 
      "tailscale0"
    ];
    
    # Allowed incoming connections
    allowedTCPPorts = [
      22    # SSH (restricted to Tailscale)
      80    # HTTP (local only)
      443   # HTTPS (local only)  
    ];
    
    allowedUDPPorts = [
      53    # DNS
      67    # DHCP
    ];
    
    # Outbound connections - mostly unrestricted
    allowedOutgoingPorts = [ "*" ];
    
    # Rate limiting for common services
    rateLimit = {
      enable = true;
      burst = 10;
      rate = "30/minute";
    };
  };
  
  # System hardening
  security.rkhunter = {
    enable = true;
    config = {
      EMAIL = "root@localhost";
      REPORT_WELCOME = false;
    };
  };
  
  # AppArmor for application isolation
  security.apparmor = {
    enable = true;
    profiles.enable = true;
  };
}
```

#### Server Firewall (hetzner-vps, ovh-vps)

```nix
# modules/nixos/security/firewall/server.nix
{ config, lib, ... }:

{
  config.networking.firewall = {
    enable = true;
    
    # Default deny for maximum security
    defaultForwardPolicy = "DROP";
    defaultInputPolicy = "DROP";
    
    # Trusted interfaces - Tailscale only
    trustedInterfaces = [ 
      "tailscale0"
    ];
    
    # Explicitly allowed ports
    allowedTCPPorts = [
      22    # SSH via Tailscale only
    ];
    
    # No UDP ports for servers (except via Tailscale)
    allowedUDPPorts = [ ];
    
    # Block all outgoing to internet except specific services
    allowedOutgoingPorts = [
      80    # HTTP for cert renewal
      443   # HTTPS for cert renewal
      53    # DNS
    ];
    
    # Connection tracking limits
    connectionTracking = {
      max = 1000;
     tcpEstablishedTimeout = "2d";
     tcpCloseWaitTimeout = "1m";
    };
  };
  
  # Advanced firewall with nftables
  networking.nftables = {
    enable = true;
    rules = {
      # IPv4 rules
      "ipv4" = {
        tables = {
          "filter" = {
            chains = {
              "input" = {
                policy = "DROP";
                rules = [
                  # Allow established connections
                  "ct state established,related accept"
                  # Allow loopback
                  "iif lo accept"
                  # Allow Tailscale
                  "iif tailscale0 accept"
                  # Rate limit SSH
                  "tcp dport 22 limit rate 3/minute accept"
                  # Log dropped packets
                  "log prefix \"nft-drop: \" counter"
                ];
              };
              "output" = {
                policy = "DROP";
                rules = [
                  # Allow established connections
                  "ct state established,related accept"
                  # Allow loopback
                  "oif lo accept"
                  # Allow Tailscale
                  "oif tailscale0 accept"
                  # Allow outbound for HTTP/HTTPS/DNS
                  "tcp dport {80,443} accept"
                  "udp dport 53 accept"
                ];
              };
            };
          };
        };
      };
    };
  };
  
  # Intrusion detection
  services.fail2ban = {
    enable = true;
    monitorSSH = true;
    maxRetry = 3;
    findTime = "10m";
    bantime = "1h";
  };
}
```

### SSH Security

SSH is configured with hardened security settings across all hosts.

```nix
# modules/nixos/security/ssh.nix
{ config, lib, ... }:

{
  config.services.sshd = {
    enable = true;
    ports = [ 22 ];
    
    # Hardened SSH configuration
    settings = {
      # Protocol and encryption
      Protocol = 2;
      PasswordAuthentication = false;  # Key-based only
      PubkeyAuthentication = true;
      AuthenticationMethods = "publickey";
      
      # Timeouts and limits
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      LoginGraceTime = 30;
      MaxAuthTries = 3;
      MaxSessions = 2;
      
      # Security features
      PermitRootLogin = "no";
      AllowUsers = [ "hbohlen" ];
      AllowGroups = [ "ssh-users" ];
      UsePAM = true;
      UseDNS = false;  # Disable DNS lookups for speed
      
      # Forwarding restrictions
      AllowTcpForwarding = false;
      AllowStreamLocalForwarding = false;
      X11Forwarding = false;
      
      # Logging
      SyslogFacility = "AUTH";
      LogLevel = "INFO";
    };
    
    # Chroot configuration for extra security
    chrootDirectory = "/var/empty/chroot";
    
    # SSH key restrictions
    openSSH = {
      authorizedKeysFiles = [ 
        "%h/.ssh/authorized_keys.d/%u" 
      ];
      
      # Key algorithms and restrictions
      hostKeyAlgorithms = [ 
        "ed25519-cert-v01@openssh.com"
        "ecdsa-sha2-nistp521-cert-v01@openssh.com"
        "rsa-sha2-512-cert-v01@openssh.com"
      ];
      
      knownHostsFormat = "ssh-only";  # SSH-only known hosts
    };
  };
  
  # SSH key management group
  users.groups.ssh-users = { };
  
  # Firewall integration for SSH
  networking.firewall.allowedTCPPorts = [ 22 ];
  
  # SSH agent integration with 1Password
  programs.ssh = {
    enable = true;
    startAgent = false;  # Use 1Password agent instead
    addKeysToAgent = "ask";  # Add keys to 1Password agent
    matchBlocks = {
      "*.tailscale.net" = {
        ForwardAgent = true;
        ControlMaster = "auto";
        ControlPath = "%C";
        Compression = true;
        ServerAliveInterval = 60;
      };
    };
  };
}
```

## Certificate Management

### Automated SSL/TLS Certificates

SSL certificates are managed automatically via Caddy and Cloudflare integration.

```nix
# modules/nixos/services/certificates.nix
{ config, lib, ... }:

{
  options.services.certificates = {
    enable = lib.mkEnableOption "Automated certificate management";
    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Domains to obtain certificates for";
    };
    cloudflareApiKey = lib.mkOption {
      type = lib.types.str;
      description = "Cloudflare API key from 1Password";
    };
  };
  
  config = lib.mkIf config.services.certificates.enable {
    # Caddy certificate automation
    services.caddy = {
      enable = true;
      # Enable automatic HTTPS
      autoHTTPS = true;
      # Use Cloudflare DNS for ACME challenges
      environmentFile = config.lib.opnix.getSecretFile "cloudflare-dns-token";
    };
    
    # Certificate monitoring
    systemd.timers."certificate-monitor" = {
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      serviceConfig = {
        ExecStart = "${pkgs.caddy}/bin/caddy validate --config /etc/caddy/Caddyfile";
        ExecStartPost = "${pkgs.opnix}/bin/opnix notify \"Certificate validation completed\"";
      };
    };
    
    # Backup certificates to 1Password
    system.activationScripts."backup-certificates" = {
      text = ''
        #!/bin/sh
        if [ -d "/var/lib/caddy/data/certificates" ]; then
          tar -czf /tmp/caddy-certs.tar.gz -C /var/lib/caddy/data certificates/
          ${pkgs.opnix}/bin/opnix put "caddy-certificates-$(date +%Y%m%d)" < /tmp/caddy-certs.tar.gz
          rm -f /tmp/caddy-certs.tar.gz
        fi
      '';
      deps = [ "caddy-setup" ];
    };
  };
}
```

## Security Monitoring

### Logging and Audit

```nix
# modules/nixos/security/monitoring.nix
{ config, lib, ... }:

{
  # System logging configuration
  services.rsyslog = {
    enable = true;
    logPaths = {
      # Security events
      "auth.*" = "/var/log/auth.log";
      "authpriv.*" = "/var/log/auth.log";
      
      # SSH monitoring
      "sshd.*" = "/var/log/sshd.log";
      
      # Firewall logs  
      "kern.info" = "/var/log/kern.log";
      "kern.warn" = "/var/log/kern.log";
    };
  };
  
  # Audit system for security monitoring
  services.auditd = {
    enable = true;
    config = {
      # Monitor key system calls
      rules = [
        "-w /etc/passwd -p wa -k passwd_changes"
        "-w /etc/shadow -p wa -k shadow_changes"  
        "-w /etc/sudoers -p wa -k sudoers_changes"
        "-w /var/log/ -p wa -k log_integrity"
        "-a always,exit -F arch=b64 -S execve -F auid>=1000 -F auid!=4294967295 -k execve"
      ];
    };
  };
  
  # Log rotation and retention
  services.logrotate = {
    enable = true;
    config = {
      logs = {
        "/var/log/auth.log" = {
          rotate = "weekly";
          count = 4;
          compress = true;
          delaycompress = true;
          missingok = true;
          sharedscripts = true;
        };
        "/var/log/sshd.log" = {
          rotate = "weekly";
          count = 4;
          compress = true;
          delaycompress = true;
          missingok = true;
          sharedscripts = true;
        };
      };
    };
  };
  
  # Security notifications
  systemd.services."security-notifications" = {
    enable = true;
    after = [ "auditd.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/bin/journalctl -f -k security --since \"10 minutes ago\" | ${pkgs.opnix}/bin/opnix notify";
    };
  };
}
```

## Security Validation

### Security Testing

```nix
# modules/nixos/security/testing.nix
{ config, lib, ... }:

{
  # Network security testing
  environment.systemPackages = [
    pkgs.nmap
    pkgs.ssh-audit
    pkgs.sslscan
  ];
  
  # Security configuration validation
  system.activationScripts."security-validation" = {
    text = ''
      #!/bin/sh
      
      echo "Running security validation..."
      
      # Test SSH configuration
      ${pkgs.ssh-audit}/bin/ssh-audit localhost
      
      # Test firewall rules
      ${pkgs.iptables}/bin/iptables -L -n -v
      
      # Test Tailscale connectivity
      ${pkgs.tailscale}/bin/tailscale status
      
      # Test 1Password connectivity  
      ${pkgs.opnix}/bin/opnix health
    '';
    deps = [ "tailscale-setup" "opnix-setup" ];
  };
}
```

## Security Incident Response

### Emergency Procedures

```nix
# scripts/security/emergency-response.sh
#!/bin/sh
# Security incident response script

echo "Security incident detected. Executing emergency response..."

# 1. Kill all SSH connections
pkill -f sshd

# 2. Block all external traffic (except Tailscale)
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -A INPUT -i tailscale0 -j ACCEPT
iptables -A OUTPUT -o tailscale0 -j ACCEPT

# 3. Rotate all secrets
opnix rotate-keys

# 4. Take emergency snapshot
btrfs subvolume snapshot / /btrfs_tmp/emergency-snapshot-$(date +%Y%m%d-%H%M%S)

# 5. Send alert
opnix notify "SECURITY INCIDENT: System isolated and secured"

# 6. Log incident
logger "Security incident response activated at $(date)"
```

## Cross-Reference Implementation

### Module Integration
```nix
# Central security module that imports host-specific configurations
{ config, lib, ... }:

{
  options.pantherOS.security = {
    level = lib.mkOption {
      type = lib.types.enum [ "workstation" "server" "high-security" ];
      default = "workstation";
    };
  };
  
  imports = [
    <modules/nixos/security/firewall/${config.pantherOS.security.level}>
    <modules/nixos/security/ssh.nix>
    <modules/nixos/security/monitoring.nix>
    <modules/shared/secrets/ssh.nix>
    <modules/nixos/services/tailscale.nix>
  ];
}
```

## Related Documentation

- [System Architecture Overview](./overview.md)
- [Host Classification](./host-classification.md)
- [Disk Layouts](./disk-layouts.md)
- [Module Organization](./module-organization.md)
- [Secrets Management Guide](../guides/secrets-management.md)
- [Security Hardening Guide](../guides/security-hardening.md)

---

**Maintained by:** hbohlen  
**Last Updated:** 2025-11-20  
**Version:** 1.0