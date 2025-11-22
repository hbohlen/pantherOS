# Post-Deployment Verification Checklist

This checklist helps verify that the pantherOS deployment to Hetzner Cloud VPS was successful and all components are working correctly.

## Network and Connectivity

### [ ] SSH Access
- [ ] SSH connection to server works with your SSH key
- [ ] Root user can connect via SSH
- [ ] Regular user (hbohlen) can connect via SSH
- [ ] Password authentication is disabled
- [ ] Root login is disabled (use sudo instead)

### [ ] Tailscale Configuration
- [ ] Tailscale service is running: `systemctl status tailscale`
- [ ] Server is connected to Tailscale network: `tailscale status`
- [ ] Server has appropriate IP address in Tailscale network
- [ ] Exit node configuration is properly set up (if applicable)

### [ ] Internet Connectivity
- [ ] Server can access internet: `ping 8.8.8.8`
- [ ] DNS resolution works: `nslookup google.com`
- [ ] Nix can fetch packages from internet

## System Configuration

### [ ] NixOS Configuration
- [ ] Correct NixOS version is running: `nixos-version`
- [ ] System configuration matches flake: `nix flake show .#hetzner-vps`
- [ ] Hostname is correctly set for hetzner-vps
- [ ] Timezone is correctly set

### [ ] Disk Configuration
- [ ] Btrfs filesystem is properly configured (if using Btrfs)
- [ ] All expected subvolumes exist and are mounted correctly
- [ ] Disk layout matches disko configuration
- [ ] Swap space is configured and active

### [ ] User Configuration
- [ ] Regular user (hbohlen) exists and can log in
- [ ] User has appropriate sudo access
- [ ] Home-manager configuration is applied
- [ ] SSH keys are properly configured

## Security Configuration

### [ ] Firewall
- [ ] Firewall service is active and running
- [ ] Only necessary ports are open (SSH, Tailscale, web services if any)
- [ ] Unnecessary services are not accessible from public internet

### [ ] Services Security
- [ ] SSH configuration restricts access appropriately
- [ ] Encrypted swap is active if configured
- [ ] Security updates are configured to apply automatically

## Service Verification

### [ ] Essential Services
- [ ] Tailscale service is active and running
- [ ] Podman service is active (if configured): `systemctl status podman`
- [ ] Caddy service is active (if configured): `systemctl status caddy`
- [ ] All configured services are running as expected

### [ ] Container Configuration (if applicable)
- [ ] Podman is properly configured for rootless containers
- [ ] Container registry access works
- [ ] Any configured containers are running (if applicable)

## Performance and Optimization

### [ ] System Performance
- [ ] CPU governor is set to performance mode (for server)
- [ ] Memory management is optimized for server workloads
- [ ] I/O scheduler is appropriate for SSD storage

### [ ] Monitoring (if configured)
- [ ] System monitoring services are running
- [ ] Logging configuration is active
- [ ] Any configured alerting systems are operational

## Backup and Recovery

### [ ] Backup Configuration
- [ ] Btrfs snapshots are configured if using Btrfs impermanence
- [ ] Backup scripts are scheduled and running (if configured)
- [ ] Snapshot retention policy is in place

### [ ] Recovery Procedures
- [ ] NixOS generations are properly configured for rollback
- [ ] System can be rolled back to previous configuration if needed
- [ ] Bootloader configuration allows for accessing previous generations

## Custom Applications and Tools

### [ ] Development Tools
- [ ] Git is configured and working
- [ ] Any specified development tools are available
- [ ] Editor configurations are applied (if specified)

### [ ] AI Tools Integration (if configured)
- [ ] AI tools specified in configuration are available
- [ ] Sandboxing for AI tools is properly configured
- [ ] Project context access works for AI tools

## Network Services (if configured)

### [ ] Web Services
- [ ] Caddy reverse proxy is configured (if applicable)
- [ ] SSL certificates are properly configured (if applicable)
- [ ] Any web applications are accessible via configured endpoints

### [ ] Container Orchestration
- [ ] Podman is working correctly
- [ ] Container networking is properly configured
- [ ] Any configured container services are running

---

**Verification completed by:** _______________ **Date:** _______________

**Server:** _______________ (hostname/ip)

**Notes:**