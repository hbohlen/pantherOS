# Change: Add Niri Window Manager

## Why

To provide a modern, scrollable-tiling Wayland window manager on personal devices (zephyrus and yoga), replacing traditional desktop environments with Niri's efficient, keyboard-driven workflow. Niri will be integrated with DankMaterialShell to provide seamless keybindings and auto-start functionality, creating a cohesive desktop experience focused on productivity and minimal resource usage.

## What Changes

- Add `niri` flake input from [sodiboo/niri-flake](https://github.com/sodiboo/niri-flake) with proper follows configuration
- Import Niri homeModules in personal device configurations
- Enable Niri integration features in DankMaterialShell (enableKeybinds, enableSpawn)
- Configure Niri as the window manager on personal devices
- **DEPENDENCY**: Requires `add-dank-material-shell` change to be completed first

## Impact

- Affected specs: window-manager (new capability)
- Affected code: flake.nix (new inputs), personal device host configs (new imports and enable)
- Replaces default desktop environment with Niri window manager on personal devices
- Server configurations (hetzner-vps, ovh-vps) remain unchanged
