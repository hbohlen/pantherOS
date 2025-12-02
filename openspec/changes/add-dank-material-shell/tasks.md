## 1. Flake Configuration

- [x] 1.1 Add dgop input to flake.nix
- [x] 1.2 Add DankMaterialShell input to flake.nix with follows
- [x] 1.3 Update flake outputs to include new inputs

## 2. Personal Device Integration

- [x] 2.1 Add DankMaterialShell homeModules import to zephyrus host
- [x] 2.2 Add DankMaterialShell nixosModules import to zephyrus host
- [x] 2.3 Enable programs.dankMaterialShell on zephyrus host
- [x] 2.4 Add DankMaterialShell homeModules import to yoga host
- [x] 2.5 Add DankMaterialShell nixosModules import to yoga host
- [x] 2.6 Enable programs.dankMaterialShell on yoga host

## 3. DankMaterialShell Core Configuration

- [x] 3.1 Configure systemd service (enable, restartIfChanged)
- [x] 3.2 Configure core feature toggles (enableSystemMonitoring, enableClipboard, enableBrightnessControl, enableColorPicker)
- [x] 3.3 Configure visual features (enableDynamicTheming, enableAudioWavelength, enableSystemSound)
- [x] 3.4 Configure integration features (enableVPN, enableCalendarEvents)

## 4. Niri Integration Configuration

- [x] 4.1 Add niri-flake input to flake.nix (if using niri)
- [x] 4.2 Import niri homeModules in personal device configs
- [x] 4.3 Import dankMaterialShell.homeModules.dankMaterialShell.niri module
- [x] 4.4 Configure niri.enableKeybinds for automatic keybinding setup
- [x] 4.5 Configure niri.enableSpawn for DankMaterialShell auto-start
- [x] 4.6 Disable niri-flake-polkit service if using DMS polkit agent

## 5. Advanced Customization (Home-Manager)

- [x] 5.1 Configure custom Quickshell package if needed (quickshell.package)
- [x] 5.2 Configure default settings (default.settings for theme, dynamicTheming, etc.)
- [x] 5.3 Configure default session state (default.session)
- [x] 5.4 Set up declarative plugin support structure (plugins with enable and src)

## 6. Verification and Testing

- [x] 6.1 Test flake build with new inputs and dependencies
- [x] 6.2 Verify both NixOS module and home-manager module installation methods
- [x] 6.3 Verify DankMaterialShell auto-starts with systemd service
- [x] 6.4 Verify DankMaterialShell auto-starts with niri compositor (if configured)
- [x] 6.5 Test all enabled features (system monitoring, clipboard, brightness controls, etc.)
- [x] 6.6 Verify dependency resolution for optional features
- [x] 6.7 Test default settings application on first launch
- [x] 6.8 Test custom Quickshell package configuration
- [x] 6.9 Test declarative plugin installation
- [x] 6.10 Verify niri keybindings work correctly
- [x] 6.11 Verify polkit agent conflict resolution

## 7. Documentation

- [x] 7.1 Document installation methods (NixOS vs home-manager)
- [x] 7.2 Document niri integration requirements and setup
- [x] 7.3 Document feature toggles and configuration options
- [x] 7.4 Document troubleshooting for auto-start, dependencies, and keybinding conflicts
- [x] 7.5 Document module file references for advanced configuration
