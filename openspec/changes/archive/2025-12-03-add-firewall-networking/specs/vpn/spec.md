# VPN Specification

## ADDED Requirements

### Requirement: VPN Configuration
The system SHALL support multiple VPN protocols (WireGuard, Tailscale) with declarative configuration.

#### Scenario: Configure WireGuard tunnel
- **WHEN** WireGuard interface is defined
- **THEN** tunnel is created with specified peers and keys
- **AND** routing is configured for VPN traffic
- **AND** tunnel starts automatically on boot

#### Scenario: Configure Tailscale mesh network
- **WHEN** Tailscale is enabled
- **THEN** node joins configured tailnet
- **AND** magic DNS is available for peer resolution
- **AND** exit nodes can be configured

### Requirement: VPN Profiles
The system SHALL support multiple VPN profiles for different use cases with easy switching.

#### Scenario: Activate VPN profile
- **WHEN** switching to a VPN profile (work, personal, etc.)
- **THEN** appropriate VPN connections are activated
- **AND** routing tables are updated
- **AND** DNS configuration reflects profile settings

#### Scenario: Split tunneling
- **WHEN** split tunneling is configured
- **THEN** only specified traffic routes through VPN
- **AND** local traffic bypasses VPN
- **AND** split tunnel rules are enforced by routing

### Requirement: VPN Monitoring
The system SHALL provide status monitoring and automatic recovery for VPN connections.

#### Scenario: Monitor VPN connection status
- **WHEN** querying VPN status
- **THEN** connection state is reported (up, down, connecting)
- **AND** peer information is available
- **AND** bandwidth usage is tracked

#### Scenario: Automatic VPN reconnection
- **WHEN** VPN connection drops
- **THEN** system attempts automatic reconnection
- **AND** retry attempts are exponentially backed off
- **AND** connection failures are logged
