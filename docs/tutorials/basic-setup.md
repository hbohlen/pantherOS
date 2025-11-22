# Setting Up PantherOS: A Step-by-Step Tutorial

This tutorial will guide you through setting up PantherOS on a new system, from initial installation to first boot with basic functionality.

## Prerequisites

Before starting, ensure you have:
- Compatible hardware (see Specifications)
- Internet connection
- PantherOS installation media (USB drive with NixOS installer)
- Basic familiarity with command line operations

## Phase 1: Hardware Discovery and Preparation

### Step 1: Boot from Installation Media
1. Boot your system from a NixOS installation USB
2. Select the appropriate installation option for your hardware
3. Log in as root user (no password required)

### Step 2: Hardware Discovery
Run the hardware discovery tool to generate the hardware configuration:

```bash
# Run hardware discovery for your system
nix run nixpkgs#nixos-hardware -- --system $(uname -m) --host <hostname> --output-file /tmp/hardware-configuration.nix
```

### Step 3: Partition and Format Disks
For PantherOS, we recommend a Btrfs setup with subvolumes for impermanence:

```bash
# Example using simple partitioning (adjust for your system)
# Create partitions (EFI, Swap, and Root)
# Format the root partition as Btrfs
mkfs.btrfs -L pantheros-root /dev/sda3

# Mount the root filesystem
mount /dev/sda3 /mnt

# Create Btrfs subvolumes for impermanence
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log
btrfs subvolume create /mnt/home

# Create temporary mount points
mkdir -p /mnt/{nix,persist,log,home}

# Mount subvolumes with proper options
mount -o subvol=root,compress=zstd,noatime /dev/sda3 /mnt
mount -o subvol=nix,compress=zstd,noatime /dev/sda3 /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/sda3 /mnt/persist
mount -o subvol=log,compress=zstd,noatime /dev/sda3 /mnt/log
mount -o subvol=home,compress=zstd,noatime /dev/sda3 /mnt/home
```

### Step 4: Mount EFI Partition (if applicable)
```bash
# Assuming /dev/sda1 is your EFI partition
mkfs.fat -F32 /dev/sda1
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
```

## Phase 2: System Installation

### Step 5: Create Initial Configuration
Generate a basic system configuration:

```bash
nixos-generate-config --root /mnt
```

### Step 6: Install PantherOS
First, navigate to the PantherOS source. If you're installing from the repo:

```bash
cd /tmp
git clone https://github.com/your-org/pantherOS.git
cd pantherOS
```

Then install using the appropriate host configuration:

```bash
# For a yoga configuration (adjust as needed)
nixos-install --flake .#yoga --impure --root /mnt
```

## Phase 3: Initial Configuration

### Step 7: Basic User Setup
After the first boot, set up your user account by editing the host configuration:

1. Navigate to your PantherOS repository
2. Edit the appropriate host configuration in `hosts/<hostname>/configuration.nix`
3. Add your user and SSH keys to the configuration:

```nix
pantherOS.core.users.defaultUser = {
  name = "yourusername";
  description = "Your Name";
  extraGroups = [ "networkmanager" "wheel" ];
  openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2E... your-ssh-public-key"
  ];
};
```

### Step 8: Enable Required Modules
In the same configuration, ensure core modules are enabled:

```nix
pantherOS.core.base.enable = true;
pantherOS.core.boot.enable = true;
pantherOS.core.systemd.enable = true;
pantherOS.core.networking.enable = true;
pantherOS.core.users.enable = true;

# Security modules
pantherOS.security.firewall.enable = true;
pantherOS.security.ssh.enable = true;

# Filesystem modules for Btrfs
pantherOS.filesystems.btrfs.enable = true;
pantherOS.filesystems.impermanence.enable = true;
```

## Phase 4: First Build and Deployment

### Step 9: Build the Configuration
```bash
# Build the configuration to verify everything works
sudo nixos-rebuild build --flake .#yourhostname --impure

# If successful, switch to the new configuration
sudo nixos-rebuild switch --flake .#yourhostname --impure
```

### Step 10: Reboot and Verify
```bash
sudo reboot
```

After rebooting:
1. Verify you can log in with your user account
2. Check that services are running as expected
3. Verify impermanence by creating a test file in /tmp, rebooting, and confirming it's gone

## Phase 5: Post-Installation Configuration

### Step 11: Set Up Tailscale (if desired)
```bash
# Enable Tailscale in your configuration
pantherOS.services.tailscale.enable = true;

# Then rebuild and switch
sudo nixos-rebuild switch --flake .#yourhostname --impure

# Authenticate Tailscale
sudo tailscale up
```

### Step 12: Verify System Integrity
Check that all critical services are running:

```bash
# Check system status
systemctl status

# Verify impermanence is working
btrfs subvolume list /

# Check that logs are properly configured
journalctl --since "1 hour ago"
```

## Troubleshooting Common Issues

### Issue: System won't boot after installation
**Solution**: 
1. Check BIOS/UEFI settings
2. Verify boot loader configuration in your host configuration
3. Ensure EFI partition is properly mounted and contains boot files

### Issue: Nix build fails with resource errors
**Solution**:
1. Ensure you have adequate disk space (at least 10GB free in /nix)
2. Check available memory during build process
3. Consider using `--max-jobs 1` to limit resource usage

### Issue: Impermanence not working as expected
**Solution**:
1. Verify Btrfs subvolumes are properly configured
2. Check that impermanence module is enabled
3. Review persistent vs. ephemeral directories

## Next Steps

After completing this tutorial, consider:

1. Customizing your shell environment
2. Setting up development tools
3. Configuring additional services as needed
4. Implementing hardware-specific optimizations
5. Reading more detailed guides in the documentation

## Summary

This tutorial walked you through the complete process of setting up PantherOS on a new system, including:
- Hardware discovery and preparation
- Btrfs setup for impermanence
- System installation using flake
- Initial configuration with core modules
- Verification of installed system

You now have a functional PantherOS installation with impermanence and security features enabled.