CachyOS ROG Zephyrus Optimization Context
System Information
Distribution: CachyOS (Arch-based, performance-optimized)
Device: ASUS ROG Zephyrus (model TBD - to be determined from hardware inventory)
Storage Configuration: 2TB Crucial P310 Plus NVMe SSD + Default SSD
Usage Profile: Development workstation, NO gaming
Desktop Environment: DankMaterialShell + Niri compositor
Target Model: MiniMax M2 via opencode.ai
Core Optimization Objectives

1. Power Management Intelligence
AC Plugged In: Maximum performance mode
Battery >40%: Balanced performance mode
Battery <40%: Battery saver mode
Battery Health: 80% charge limit via asusctl
Hardware Integration: Full ROG-specific tool integration
2. Storage Optimization Strategy
NVMe SSDs: Enable TRIM/discard, optimize schedulers (mq-deadline/none)
BTRFS Subvolumes:
/nix - Nix store isolation
/var/lib/containers - Podman rootless containers
~/dev - Development workspace
/var - System variables
/var/log - Log files
/var/cache - System cache
3. Shell Environment Transformation
Primary Shell: Fish (extensive configuration)
Remove: All ZSH installations and configs
Keep: Bash (compatibility only)
Plugin Manager: Fisher with curated plugin ecosystem
Terminal: Ghostty only (remove all others)
4. Authentication & Security
1Password: Complete reinstallation and integration
CLI + Desktop app
SSH agent configuration
Helium browser integration (helium &)
Service account for development secrets
PolicyKit: mate-polkit ONLY (remove others)
Complete Cleanup: Remove existing 1Password installations/caches
5. Desktop Environment Stack
Compositor: Niri (scrollable tiling)
Desktop Shell: DankMaterialShell (quickshell + Go backend)
Package Source: paru -S dms-shell-bin
Theming: Material Design with auto-generation
Services: Systemd user integration
6. Development Environment
Containers: Podman rootless (no Docker)
Package Manager: paru/yay for AUR
Version Control: Git with 1Password SSH integration
Secrets: 1Password service account tokens
Critical Technical Requirements
Hardware Detection Dependencies
bash

# Essential packages for hardware inventory

lscpu, lspci, dmidecode, lsblk, btrfs-progs, asusctl, power-profiles-daemon
Power Management Stack
bash

# ROG laptop specific

asusctl           # ASUS control utility
supergfxctl       # GPU switching (if hybrid)
power-profiles-daemon  # Profile management
acpi              # Power state monitoring
1Password Installation Requirements
bash

# Prerequisites

mate-polkit       # PolicyKit agent
gnupg            # GPG verification
wget             # CLI download
DankMaterialShell Dependencies
bash

# Core components

quickshell        # QML shell framework
dms-shell-bin     # Main shell package
niri             # Compositor
accountsservice  # User management
matugen          # Color theming
dgop             # System monitoring
cliphist         # Clipboard history
File System Structure
/etc/udev/rules.d/          # Power management rules
~/.config/fish/             # Fish shell configuration
~/.config/DankMaterialShell/ # DMS configuration
~/.config/niri/             # Niri compositor config
~/.config/1Password/        # (to be cleaned and recreated)
~/.config/op/               # 1Password CLI config
~/.local/bin/               # Custom scripts
/opt/device-tools/          # Device management utilities
Verification Framework
Each optimization stage requires specific verification tests:

1.

Hardware Detection: Validate CPU model, GPU type, RAM specs, storage devices
2.
Power Profiles: Test AC/battery state detection and profile switching
3.
Storage: Verify BTRFS subvolumes, SSD optimization settings
4.
Shell Environment: Confirm Fish plugins, Fisher installation, removed shells
5.
1Password: Test CLI authentication, SSH agent, browser integration
6.
DMS/Niri: Validate compositor integration, theming, systemd services
Risk Mitigation
Backup Strategy: Before major changes, create system restore points
Incremental Changes: Apply optimizations one at a time with verification
Rollback Procedures: Document undo steps for each optimization
Non-Disruptive: User explicitly requested NO restarts/logouts during process
Expected Deliverables
1.
device-cli.fish: Comprehensive system management tool
2.
hardware-inventory.fish: Detailed hardware detection script
3.
Optimized Configurations: All config files for power, storage, shell, desktop
4.
Verification Scripts: Test suites for each optimization domain
5.
Documentation: Complete setup guide and maintenance procedures
Sharding Strategy
Each prompt focuses on a specific domain with:

Clear objectives and success criteria
Required packages and dependencies
Configuration file changes
Verification tests
Rollback procedures
Integration with other components
This context provides the foundation for all subsequent optimization prompts.
