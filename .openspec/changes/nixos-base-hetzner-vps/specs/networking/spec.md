# Networking Specification

## ADDED Requirements

### Dual Stack Networking with DHCP

**Requirement**: Configure networking for both IPv4 and IPv6 with automatic DHCP addressing.

**Configuration**:
```nix
networking.useDHCP = true;
networking.enableIPv6 = true;
networking.hostName = "hetzner-vps";
networking.domain = "hbohlen.systems";
```

**Rationale**: Hetzner provides native IPv6 support and DHCP simplifies initial configuration while supporting future IPv6-only services.

#### Scenario: Initial Network Configuration
**Given**: Fresh system installation on Hetzner VPS  
**When**: System boots for the first time  
**Then**:
- IPv4 address obtained via DHCP
- IPv6 address configured automatically
- Hostname and domain properly set
- Network connectivity established

#### Scenario: Network Service Integration
**Given**: System running with configured networking  
**When**: Additional network services are configured  
**Then**:
- Both IPv4 and IPv6 available for service binding
- Hostname resolution works correctly
- DNS queries function properly
- Network interfaces show correct addresses

### Tailscale VPN Integration

**Requirement**: Enable Tailscale VPN with server routing features for secure management access.

**Configuration**:
```nix
services.tailscale = {
  enable = true;
  useRoutingFeatures = "server";
  interface = "tailscale0";
};
```

**Rationale**: Tailscale provides encrypted, zero-trust networking with automatic NAT traversal and centralized access control.

#### Scenario: VPN Connectivity Establishment
**Given**: System boots with Tailscale configured  
**When**: Tailscale service starts  
**Then**:
- Tailscale interface created (tailscale0)
- Connection to tailnet established
- MagicDNS resolves hostname
- Encrypted communication available

#### Scenario: Remote Management Access
**Given**: Tailscale connected to tailnet  
**When**: Administrator connects from remote device  
**Then**:
- Secure VPN tunnel established
- SSH access available via Tailscale IP
- All management traffic encrypted
- MagicDNS name resolution functional

### Firewall Configuration with Default-Deny Policy

**Requirement**: Implement firewall with default-deny policy and explicit service allow rules.

**Configuration**:
```nix
networking.firewall = {
  enable = true;
  allowedUDPPorts = [ 80 443 ];
  trustedInterfaces = [ "tailscale0" ];
  extraCommands = [
    # Allow established connections
    "iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT"
    # Allow Tailscale traffic
    "iptables -A INPUT -i tailscale0 -j ACCEPT"
    # Default deny policy
    "iptables -A INPUT -j DROP"
  ];
};
```

**Rationale**: Default-deny policy minimizes attack surface while allowing required services and VPN access.

#### Scenario: Public Service Access
**Given**: Firewall configured with default-deny  
**When**: Public web services are running  
**Then**:
- HTTP (80) and HTTPS (443) accessible from internet
- All other public access blocked by default
- Established connections allowed through
- VPN traffic unrestricted

#### Scenario: Tailscale-Only Services
**Given**: Services listening on internal ports  
**When**: Access attempted from VPN  
**Then**:
- Tailscale interface traffic allowed
- Services accessible via VPN IP
- No direct internet exposure
- Service ports blocked from public internet

#### Scenario: Attack Prevention
**Given**: Default-deny firewall active  
**When**: Unauthorized access attempted  
**Then**:
- All unsolicited traffic dropped
- No port scanning results exposed
- Service discovery blocked
- Attack surface minimized

### Port Classification and Access Control

**Public Ports** (Internet accessible):
- 80: HTTP traffic for Caddy reverse proxy
- 443: HTTPS traffic for Caddy reverse proxy

**Tailscale-Only Ports** (VPN accessible):
- 4096: OpenCode service port
- 6379: Redis/Valkey database
- 6380: Redis/Valkey cluster port
- 3000: Application services
- 8126: Datadog monitoring

#### Scenario: Service Discovery Protection
**Given**: Internal service ports configured  
**When**: External network scan performed  
**Then**:
- Only public ports (80, 443) respond
- Internal service ports show no response
- Tailscale-only ports inaccessible from internet
- Network topology obscured

## Implementation Details

### Network Interface Configuration
```nix
{ config, lib, pkgs, ... }:

{
  networking = {
    useDHCP = true;
    enableIPv6 = true;
    hostName = "hetzner-vps";
    domain = "hbohlen.systems";
    
    # Network interfaces
    interfaces = {
      eth0 = {
        ipv4.addresses = [{
          address = "auto";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "auto";
          prefixLength = 64;
        }];
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 80 443 ];
    trustedInterfaces = [ "tailscale0" ];
  };
}
```

### Dependencies
- `systemd-networkd`: Network configuration and management
- `iptables`: Firewall rules management
- `tailscale`: VPN client service
- `systemd-resolved`: DNS resolution with MagicDNS

### Testing Requirements
1. **Connectivity Test**: Both IPv4 and IPv6 connectivity verified
2. **Tailscale Test**: VPN connection established and stable
3. **Firewall Test**: Port access restrictions enforced
4. **DNS Test**: Hostname resolution functional
5. **Service Test**: Required services accessible via appropriate networks

### Security Considerations
- **VPN-First**: All management via encrypted VPN
- **Minimal Exposure**: Only required ports publicly accessible
- **Stateful Firewall**: Track connection state for performance
- **Audit Logging**: Log dropped packets for security monitoring

### Integration Points
- **Boot System**: Network services start after network configuration
- **SSH Service**: Depends on networking and firewall
- **Reverse Proxy**: Requires public port access (80, 443)
- **Monitoring**: Network interface monitoring integration
- **Backup Services**: Network connectivity for remote backup

### Performance Optimization
- **Connection Tracking**: Efficient stateful packet filtering
- **IPv6 Support**: Native IPv6 routing and filtering
- **Tailscale Optimization**: Server routing features enabled
- **Firewall Efficiency**: Minimal rule processing overhead

### Monitoring and Alerting
- **Interface Status**: Monitor network interface state
- **VPN Connectivity**: Track Tailscale connection status
- **Firewall Events**: Log and alert on suspicious traffic
- **DNS Resolution**: Monitor hostname resolution functionality

### Validation Criteria
- [ ] IPv4 and IPv6 connectivity established
- [ ] Tailscale VPN connects successfully
- [ ] MagicDNS resolves hostname
- [ ] Public ports (80, 443) accessible from internet
- [ ] Tailscale-only ports accessible via VPN only
- [ ] Firewall blocks unauthorized access
- [ ] Network services start correctly
- [ ] DNS resolution functional
- [ ] SSH accessible via Tailscale IP
- [ ] System logs show normal network activity

---

**Spec Version**: 1.0  
**Last Updated**: 2025-11-19  
**Capability**: networking  
**Change ID**: nixos-base-hetzner-vps