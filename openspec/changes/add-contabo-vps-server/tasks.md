# Implementation Tasks - Add Contabo VPS Server

## 1. Hardware Detection & Initial Setup

- [ ] 1.1 Create setup script (`scripts/setup-contabo-vps.sh`)
  - Install Determinate Nix
  - Run NixOS facter to detect hardware
  - Output hardware specs and facter.json

- [ ] 1.2 Run setup script on Contabo server
  - Boot into NixOS ISO
  - Execute setup script
  - Document hardware output (CPU, RAM, disk, network interfaces)
  - Save facter.json to local repo

## 2. Initial Configuration Files (Using Hetzner/OVH as Reference)

- [ ] 2.1 Create `hosts/servers/contabo-vps/` directory

- [ ] 2.2 Create `meta.nix` (basic server metadata)

- [ ] 2.3 Create `hardware.nix`
  - Identify correct kernel modules based on facter
  - Configure KVM guest support
  - Set serial console parameters
  - Enable QEMU guest agent (if available)

- [ ] 2.4 Create initial `disko.nix`
  - Detect boot type (BIOS vs UEFI) from facter
  - Design 250GB storage layout
  - Create 14-15 Btrfs subvolumes (similar to Hetzner but optimized for 250GB)
  - Configure compression per subvolume type
  - Set 10GB swap for 48GB RAM system
  - Add @journal subvolume for systemd-journal

- [ ] 2.5 Create initial `default.nix`
  - Base configuration from OVH (likely BIOS boot)
  - Update hostname to `contabo-vps`
  - Configure network interface name from facter
  - Add bootloader configuration
  - Configure performance tuning for 12-core CPU
  - Add Podman container runtime
  - Add Tailscale VPN
  - Add 1Password OpNix secrets
  - Add SSH hardening
  - Add Home Manager for hbohlen user
  - Add maintenance services (cache cleanup, btrfs checks)

## 3. Flake Integration

- [ ] 3.1 Update `flake.nix`
  - Add `nixosConfigurations.contabo-vps` to flake outputs
  - Include all necessary modules (disko, home-manager, opnix)
  - Reference hardware.nix and default.nix

- [ ] 3.2 Run flake validation
  - Execute `nix flake check`
  - Resolve any errors

## 4. Deployment Verification Script

- [ ] 4.1 Create `scripts/verify-contabo-deployment.fish`
  - Adapt from Hetzner verification script
  - Check flake for contabo-vps configuration
  - Build contabo-vps configuration
  - Report deployment readiness

- [ ] 4.2 Create `scripts/verify-contabo-deployment.sh` (Bash variant)
  - Same functionality as Fish version

## 5. Initial Setup Script for Contabo

- [ ] 5.1 Create `scripts/setup-contabo-vps.sh`
  - Download and install NixOS live ISO
  - Boot into NixOS environment
  - Install Determinate Nix
  - Run facter to detect hardware:
    ```bash
    nix eval --impure --expr 'builtins.fromJSON (builtins.readFile "/proc/device-tree/system-information.json" or "{}")'
    # Or use nixos-facter-modules approach
    ```
  - Output facter.json
  - Provide next steps

## 6. Documentation

- [ ] 6.1 Create `CONTABO_DEPLOYMENT.md`
  - Document Contabo-specific deployment steps
  - Include hardware specs from facter
  - Provide nixos-anywhere deployment command
  - Post-deployment verification steps
  - Troubleshooting guide specific to Contabo

- [ ] 6.2 Update `scripts/README.md`
  - Add Contabo verification script documentation
  - Add setup script documentation

## 7. Fine-Tuning (After Actual Hardware Detection)

- [ ] 7.1 Update `hardware.nix` based on actual facter output
  - Confirm kernel modules
  - Verify CPU features
  - Check network interface names

- [ ] 7.2 Optimize `disko.nix` for actual disk layout
  - Confirm disk device ID from facter
  - Verify boot type
  - Adjust partition sizes if needed

- [ ] 7.3 Optimize `default.nix` based on actual performance characteristics
  - Kernel parameters may need tuning for Contabo's KVM
  - Network interface name(s) from facter
  - Bootloader configuration from facter

- [ ] 7.4 Run verification script
  - Test flake validation
  - Test configuration build
  - Review any warnings or errors

## 8. Deployment and Testing

- [ ] 8.1 Put Contabo server in rescue mode (if available)

- [ ] 8.2 Run nixos-anywhere deployment
  - Execute deployment to Contabo server
  - Monitor for errors

- [ ] 8.3 Post-deployment verification
  - Verify btrfs subvolumes
  - Check container runtime
  - Test Tailscale connectivity
  - Verify SSH access
  - Test 1Password OpNix integration

- [ ] 8.4 Performance baseline
  - Measure disk performance
  - Monitor container creation speed
  - Test build performance

## 9. Final Documentation and Commit

- [ ] 9.1 Update all documentation with actual hardware specs

- [ ] 9.2 Commit changes to feature branch
  - Configuration files
  - Setup script
  - Verification script
  - Documentation

- [ ] 9.3 Create pull request
  - Document Contabo VPS addition
  - Reference hardware specs from facter
  - Include deployment verification results

## Notes

- **Hardware Detection:** Requires running setup script on actual Contabo server to get accurate facter.json
- **Boot Type:** Will likely be BIOS (like OVH) but will be confirmed by facter
- **Storage:** 250GB allows for larger NVMe cache than Hetzner (480GB) but less than some options
- **Network:** Interface name unknown until facter output (likely `enp*s*` or `ens*`)
- **Performance:** 12 cores and 48GB RAM support more intensive workloads than Hetzner

## References

- Hetzner VPS configuration: `hosts/servers/hetzner-vps/`
- OVH VPS configuration: `hosts/servers/ovh-vps/`
- Existing verification scripts: `scripts/verify-hetzner-deployment.*`
- Deployment guide: `HETZNER_DEPLOYMENT.md`
