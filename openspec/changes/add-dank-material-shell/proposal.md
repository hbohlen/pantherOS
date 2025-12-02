# Change: Add DankMaterialShell

## Why

To provide a comprehensive, modern material design shell experience on personal devices (zephyrus and yoga), enhancing the user interface with DankMaterialShell - a full-featured shell configuration including themes, plugins, system monitoring, clipboard management, and extensive customization options from <https://danklinux.com/docs/dankmaterialshell/nixos>.

## What Changes

- Add `dgop` and `DankMaterialShell` flake inputs with proper follows configuration
- Support both NixOS module (system-wide) and home-manager module (per-user) installation methods
- Import DankMaterialShell homeModules and/or nixosModules in personal device configurations
- Enable comprehensive DankMaterialShell configuration with feature toggles:
  - System monitoring (dgop), clipboard history (cliphist, wl-clipboard)
  - VPN management, brightness controls, color picker tool
  - Dynamic theming (matugen), audio visualizer (cava)
  - Calendar integration (khal), system sound feedback (qt6-multimedia)
- Configure niri Wayland compositor integration with automatic keybindings and auto-start
- Support custom Quickshell package configuration
- Configure default settings and session management for first-run experience (home-manager only)
- Enable declarative plugin support for extensibility (home-manager only)
- Set up systemd auto-start and restart-on-change functionality
- Provide polkit agent conflict resolution for niri-flake users
- Document troubleshooting for auto-start, dependencies, and keybinding conflicts
- **DEPENDENCY**: Requires `add-personal-device-hosts` change to be completed first

## Impact

- Affected specs: shell-configuration (modified - comprehensive update with installation methods, niri integration, and advanced customization)
- Affected code: 
  - flake.nix (new inputs: dgop, dankMaterialShell with follows)
  - personal device host configs (module imports, feature toggles, niri integration)
  - optional niri configuration (polkit agent conflict resolution)
- Adds rich shell functionality and visual improvements without affecting existing server configurations
- Introduces dependencies on core (Quickshell, dgop) and optional packages (matugen, cava, khal, cliphist, wl-clipboard, qt6-multimedia, niri-flake)
- Provides two installation methods: NixOS module (system-wide) and home-manager module (per-user with additional features)
- Enables seamless niri compositor integration with automatic keybindings and spawn configuration
