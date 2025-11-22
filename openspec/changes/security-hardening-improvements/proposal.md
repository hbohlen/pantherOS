# Change: NixOS Security Hardening Improvements

## Why

Based on current 2025 NixOS security research, there are several hardening best practices that should be integrated into pantherOS to enhance security posture and reduce attack surface. Current security configurations are minimal and don't leverage modern systemd hardening features available in NixOS.

## What Changes

- Add systemd service hardening module with configurable security profiles
- Implement network security hardening with proper firewall rules
- Add security auditing tools integration (lynis, systemd-analyze security)
- Create security baseline configuration for servers vs workstations
- Add kernel hardening parameters
- Implement file system integrity monitoring
- Add security scanning automation

## Impact

- Affected specs: `security-hardening`
- Affected code: `modules/nixos/security/hardening.nix`, `modules/shared/security/`
- New security baseline for all host configurations

---

# ADDED Requirements

## Requirement: Systemd Service Hardening

The system SHALL provide automated systemd service hardening with configurable security profiles.

#### Scenario: Service hardening profile applied
- **WHEN** administrator enables security hardening profile
- **THEN** systemd services are configured with restrictive permissions, network isolation, and file system access controls according to NixOS security best practices

#### Scenario: Security audit compliance
- **WHEN** security audit is performed
- **THEN** system meets or exceeds baseline security hardening requirements for deployed services

## Requirement: Network Security Hardening

The system SHALL implement comprehensive network security controls with proper firewall segmentation and access controls.

#### Scenario: Tailscale-only access
- **WHEN** Tailscale VPN is active
- **THEN** all network services shall be accessible only via Tailscale interfaces, with public internet access blocked except for essential system updates

#### Scenario: Firewall rule violation detection
- **WHEN** unauthorized network access attempt is detected
- **THEN** attempt shall be blocked and logged with security alert

## Requirement: Security Auditing Integration

The system SHALL integrate security auditing tools and provide automated security baseline verification.

#### Scenario: Security scan execution
- **WHEN** administrator initiates security scan
- **THEN** system shall run lynis audit, systemd-analyze security checks, and generate compliance report with actionable recommendations

#### Scenario: Continuous security monitoring
- **WHEN** security monitoring is enabled
- **THEN** system shall continuously monitor critical security configurations and alert on deviations from established baseline

## Requirement: Kernel Hardening

The system SHALL apply kernel-level hardening parameters appropriate for host classification (workstation vs server).

#### Scenario: Server kernel hardening
- **WHEN** host is classified as server
- **THEN** kernel shall be configured with restrictive sysctl settings, disabled vulnerable modules, and enhanced memory protection

#### Scenario: Workstation kernel hardening
- **WHEN** host is classified as workstation
- **THEN** kernel shall balance security with usability, applying sensible hardening while maintaining hardware compatibility

## Requirement: File System Integrity

The system SHALL provide file system integrity monitoring and protection for critical system directories.

#### Scenario: Integrity violation detection
- **WHEN** unauthorized modification to critical system files is detected
- **THEN** system shall alert administrator and initiate automatic remediation according to security policy

#### Scenario: Btrfs security configuration
- **WHEN** Btrfs filesystem is used
- **THEN** appropriate security features shall be enabled including subvolume permissions, snapshot protection, and compression with integrity verification