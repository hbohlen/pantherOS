# Change: Add DankMaterialShell

## Why

To provide a comprehensive, modern material design shell experience on personal devices (zephyrus and yoga), enhancing the user interface with DankMaterialShell - a full-featured shell configuration including themes, plugins, system monitoring, clipboard management, and extensive customization options from https://danklinux.com/docs/dankmaterialshell/nixos.

## What Changes

- Add `dgop` and `DankMaterialShell` flake inputs with proper follows configuration
- Import DankMaterialShell homeModules and nixosModules in personal device configurations
- Enable comprehensive DankMaterialShell configuration with feature toggles (system monitoring, clipboard, VPN, brightness, color picker, dynamic theming, audio visualizer, calendar, system sounds)
- Configure default settings and session management for first-run experience
- Set up systemd auto-start and restart-on-change functionality
- Enable plugin support for extensibility
- **DEPENDENCY**: Requires `add-personal-device-hosts` change to be completed first

## Impact

- Affected specs: shell-configuration (new capability)
- Affected code: flake.nix (new inputs), personal device host configs (imports, enable, and extensive configuration)
- Adds rich shell functionality and visual improvements without affecting existing server configurations
- Introduces dependencies on matugen, cava, khal, cliphist, wl-clipboard, and other system packages
