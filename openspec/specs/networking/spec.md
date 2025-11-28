## ADDED Requirements

### Requirement: Systemd-Networkd Networking

The system SHALL use systemd-networkd for reliable, declarative network configuration.

#### Scenario: Network interface configured

- **WHEN** system boots
- **THEN** eth0 interface uses DHCP for IPv4 and accepts IPv6 RA

#### Scenario: Networkd enabled

- **WHEN** networking services start
- **THEN** systemd-networkd manages network configuration
- **AND** DHCP is disabled to avoid conflicts

#### Scenario: Network connectivity maintained

- **WHEN** system is running
- **THEN** network interfaces are properly configured and routable

### Requirement: Firewall Security

The system SHALL maintain secure firewall rules allowing only necessary services.

#### Scenario: SSH access allowed

- **WHEN** firewall is active
- **THEN** TCP port 22 is open for SSH connections

#### Scenario: Tailscale trusted

- **WHEN** Tailscale is connected
- **THEN** tailscale0 interface is trusted
- **AND** Tailscale UDP port is allowed

#### Scenario: Unnecessary ports blocked

- **WHEN** firewall rules are applied
- **THEN** only explicitly allowed ports are accessible</content>
  <parameter name="filePath">openspec/implemented/networking/spec.md
