# Change: Add DankMaterialShell Compositor Configuration

## Why

To provide comprehensive compositor-specific configuration for DankMaterialShell across niri, Hyprland, Sway, dwl/MangoWC, and labwc, including layer rules for blur effects, window rules, keybindings, environment variables, and layer shell namespace documentation to enable optimal DMS integration with Wayland compositors.

## What Changes

- Document compositor setup for niri with KDL configuration format
- Document compositor setup for Hyprland with simple config format
- Document compositor setup for Sway (i3-compatible)
- Document compositor setup for dwl/MangoWC (dynamic tiling)
- Document compositor setup for labwc (Openbox-inspired)
- Provide layer shell namespace documentation for all DMS components
- Document layer rules for blur, animation, and dim effects
- Document window rules for opacity, borders, and floating behavior
- Provide environment variable configuration for Wayland applications
- Document startup commands for DMS and services
- Include keybindings with updated IPC format: `dms ipc call <module> <action>`
- Document protocol requirements for Wayland compositors
- Provide performance tuning guidance for blur effects
- Include troubleshooting for compositor-specific issues
- **DEPENDENCY**: Requires `add-dank-material-shell` and `add-dms-ipc-documentation` changes

## Dependencies

- Depends on: `add-dank-material-shell` (must be completed first)
- Depends on: `add-dms-ipc-documentation` (must be completed first)

## Impact

- Affected specs: configuration (new compositor setup capability)
- Affected code:
  - Compositor configuration files (niri: ~/.config/niri/config.kdl, Hyprland: ~/.config/hypr/hyprland.conf, Sway: ~/.config/sway/config)
  - DMS include files (dms/binds.kdl, dms/colors.kdl, dms/layout.kdl for niri)
  - Layer rule configurations for blur and animations
  - Window rule configurations for application behavior
  - Environment variable setup for Wayland applications
- Provides optimized configurations for 5+ Wayland compositors
- Enables consistent DMS experience across different compositors
- Supports compositor-specific features (niri scrollable tiling, Hyprland overview)
- Documents 40+ layer shell namespaces for precise compositor targeting
- Does not affect NixOS module configuration, only user-level compositor configs
- Improves visual quality through proper blur and animation configuration
