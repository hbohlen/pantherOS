# Implementation Tasks: Firewall and Networking

## 1. Firewall Module
- [ ] 1.1 Create `modules/networking/firewall.nix` with nftables configuration
- [ ] 1.2 Define default firewall rules (allow SSH, drop everything else)
- [ ] 1.3 Create rule templates for common services (web, database, monitoring)
- [ ] 1.4 Add port management options (TCP/UDP, ranges)
- [ ] 1.5 Implement zone-based firewall configuration
- [ ] 1.6 Add logging and packet tracking options

## 2. VPN Module
- [ ] 2.1 Create `modules/networking/vpn.nix` module structure
- [ ] 2.2 Configure WireGuard integration with NixOS
- [ ] 2.3 Enhance Tailscale configuration with auto-start and routes
- [ ] 2.4 Create VPN profile system (work, personal, etc.)
- [ ] 2.5 Add split-tunneling configuration options
- [ ] 2.6 Implement VPN status monitoring

## 3. DNS Module
- [ ] 3.1 Create `modules/networking/dns.nix` for DNS configuration
- [ ] 3.2 Configure systemd-resolved or dnsmasq
- [ ] 3.3 Add DNS-over-HTTPS (DoH) support
- [ ] 3.4 Integrate DNS filtering/ad-blocking (optional)
- [ ] 3.5 Configure DNS fallback and caching
- [ ] 3.6 Add custom DNS record support for local development

## 4. Network Security Hardening
- [ ] 4.1 Enable kernel network security parameters (syn cookies, reverse path filtering)
- [ ] 4.2 Configure IPv6 privacy extensions
- [ ] 4.3 Disable unused network protocols
- [ ] 4.4 Enable connection tracking and rate limiting
- [ ] 4.5 Configure secure default MTU and TCP settings
- [ ] 4.6 Add fail2ban integration for brute-force protection

## 5. Network Profiles
- [ ] 5.1 Create network profile system (workstation, server, router)
- [ ] 5.2 Define profile-specific firewall rules
- [ ] 5.3 Configure profile-specific network services
- [ ] 5.4 Add host-specific overrides
- [ ] 5.5 Document profile selection and customization

## 6. Diagnostic Tools
- [ ] 6.1 Add network diagnostic package collection
- [ ] 6.2 Include tools: tcpdump, netcat, nmap, iperf3, mtr, dig, whois
- [ ] 6.3 Create network testing scripts
- [ ] 6.4 Add network status dashboard script
- [ ] 6.5 Include bandwidth monitoring tools

## 7. Integration and Testing
- [ ] 7.1 Integrate firewall module with existing configurations
- [ ] 7.2 Test firewall rules don't block essential services
- [ ] 7.3 Verify VPN connectivity and routing
- [ ] 7.4 Test DNS resolution and filtering
- [ ] 7.5 Validate network security hardening
- [ ] 7.6 Test rollback scenario (ensure SSH access maintained)

## 8. Documentation
- [ ] 8.1 Document firewall configuration options and examples
- [ ] 8.2 Create VPN setup guide for WireGuard and Tailscale
- [ ] 8.3 Document DNS configuration options
- [ ] 8.4 Add network troubleshooting guide
- [ ] 8.5 Create network security best practices documentation
- [ ] 8.6 Document common network profile patterns
