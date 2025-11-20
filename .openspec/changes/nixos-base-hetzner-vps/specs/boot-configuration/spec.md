# Boot Configuration Specification

## ADDED Requirements

### GRUB EFI Configuration for Hetzner Cloud

**Requirement**: Configure GRUB bootloader with EFI removable mode and appropriate kernel parameters for Hetzner Cloud VPS environment.

**Configuration**:
```nix
boot.loader.grub = {
  enable = true;
  efiInstallAsRemovable = true;
  canTouchEfiVariables = false;
};
```

**Kernel Parameters**: `console=tty0 console=ttyS0,115200`

**Rationale**: Hetzner Cloud requires EFI in removable mode and doesn't allow EFI variable touching. Serial console access essential for remote management.

#### Scenario: Initial System Boot
**Given**: Fresh NixOS installation on Hetzner CPX52 VPS  
**When**: System boots after installation  
**Then**: 
- GRUB bootloader loads successfully
- Kernel boots with both graphical and serial console
- System accessible via Hetzner web console
- No EFI variable manipulation required

#### Scenario: Remote Console Access
**Given**: System is running and accessible via Tailscale  
**When**: Administrator needs console access for troubleshooting  
**Then**:
- Serial console accessible via Hetzner web console
- Both tty0 and ttyS0 provide working console access
- Boot messages visible in both interfaces
- System recovery possible through console

### Kernel Parameter Optimization

**Requirement**: Include appropriate console and boot parameters for VPS environment.

**Parameters**: 
- `console=tty0`: Graphical console for local access
- `console=ttyS0,115200`: Serial console for remote management
- Baud rate 115200: Standard for remote console access

#### Scenario: Console Redundancy
**Given**: Network connectivity issues prevent SSH access  
**When**: Administrator needs system access  
**Then**:
- Serial console provides reliable access via Hetzner web console
- Graphical console available if local access needed
- Boot process fully visible in console output
- System recovery possible without network

## MODIFIED Requirements

### Bootloader Security

**Requirement**: Enhance GRUB configuration for production security.

**Changes**:
- Remove insecure boot options
- Enable secure boot compatibility
- Configure appropriate timeout values

#### Scenario: Security Compliance
**Given**: Production environment requirements  
**When**: Security audit is performed  
**Then**:
- No insecure boot parameters present
- GRUB configuration follows security best practices
- Boot process meets compliance requirements

### Firmware Handling

**Requirement**: Configure firmware loading for virtualized environment.

**Changes**:
- Disable EFI variable touching due to Hetzner limitations
- Use removable EFI mode for maximum compatibility
- Optimize for virtualized hardware

#### Scenario: Virtualization Compatibility
**Given**: Hetzner Cloud virtualization platform  
**When**: System boots in virtualized environment  
**Then**:
- EFI firmware loads correctly without variable manipulation
- Boot process compatible with Hetzner's virtualization
- No firmware-related errors in boot logs

## Implementation Details

### NixOS Configuration Structure
```nix
{ config, lib, pkgs, ... }:

{
  boot.loader.grub = {
    enable = true;
    efiInstallAsRemovable = true;
    canTouchEfiVariables = false;
    devices = [ "nodev" ];
  };

  boot.kernelParams = [
    "console=tty0"
    "console=ttyS0,115200"
  ];

  # Additional boot optimizations
  boot.initrd.availableKernelModules = [ "virtio" "virtio_net" ];
}
```

### Dependencies
- `grub`: Bootloader package
- `systemd`: Init system integration
- `efibootmgr`: EFI boot management (when available)

### Testing Requirements
1. **Build Test**: Configuration compiles without errors
2. **VM Test**: Boots successfully in virtual environment
3. **Console Test**: Both serial and graphical consoles functional
4. **Recovery Test**: Can recover via GRUB previous generation

### Security Considerations
- No insecure boot parameters allowed
- Secure boot compatibility maintained
- Console access properly secured
- Boot process audit trail maintained

### Integration Points
- **File System**: Btrfs subvolume layout (future)
- **Network**: Tailscale service dependencies
- **Security**: Firewall and SSH service startup order
- **Monitoring**: Boot process logging and monitoring

### Validation Criteria
- [ ] GRUB configuration generates valid boot loader
- [ ] Kernel parameters include both console types
- [ ] EFI removable mode properly configured
- [ ] Serial console baud rate set correctly
- [ ] Boot process completes without errors
- [ ] Console access functional in both modes
- [ ] Previous generation rollback available

---

**Spec Version**: 1.0  
**Last Updated**: 2025-11-19  
**Capability**: boot-configuration  
**Change ID**: nixos-base-hetzner-vps