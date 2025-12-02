# Design: Zephyrus Optimization

## Architecture
The configuration will follow a modular approach, leveraging NixOS modules and Home Manager.

### Module Structure
- `modules/hardware/asus-rog.nix`: ROG-specific settings (battery charge limit, etc.).
- `modules/core/storage.nix`: General storage optimizations (TRIM, swappiness).
- `modules/desktop-shells/dankmaterial/`: Enhanced DMS configuration.
- `modules/security/1password.nix`: 1Password system-level integration.

### Power Management Strategy
We will use `services.power-profiles-daemon` as the primary mechanism.
- **AC**: Performance
- **Battery**: Balanced/Power Saver
- **Charge Limit**: 80% (via `hardware.asus.battery.chargeUpto`)

### Storage Strategy
- **Filesystem**: BTRFS with subvolumes for `/`, `/nix`, `/home`, `/var/log`.
- **Optimization**: `services.fstrim.enable = true`, `vm.swappiness = 10`.

### Desktop Stack
- **Compositor**: Niri (Wayland)
- **Shell**: DankMaterialShell (Qt/QML)
- **Theming**: Matugen for generating colors from wallpaper.

## Verification
Each component will have associated verification commands:
- Power: `powerprofilesctl list`
- Storage: `systemctl status fstrim.timer`
- Security: `op --version`
