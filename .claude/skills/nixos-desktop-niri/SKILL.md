---
name: NixOS Desktop Niri
description: Configure Niri window manager with DankMaterialShell theming and quickshell for a modern, efficient desktop experience. When setting up Niri WM, configuring desktop shells, or managing Wayland window managers.
---
# NixOS Desktop Niri

## When to use this skill:

- Setting up Niri window manager as the desktop environment
- Configuring Niri workspaces, layouts, and window rules
- Installing and configuring DankMaterialShell
- Setting up quickshell for quick access panels and launchers
- Configuring Wayland-specific applications and settings
- Setting up display manager to use Niri by default
- Configuring Niri keybindings and shortcuts
- Integrating Niri with other desktop components
- Customizing Niri theme and appearance
- Setting up multi-monitor support with Niri

## Best Practices
- disabledModules = [ &quot;programs/wayland/niri.nix&quot; ]; services.niri.enable = true; services.displayManager.defaultSession = &quot;niri&quot;;
- programs.dankMaterialShell.enable = true; enableSystemMonitoring = true; enableDynamicTheming = true;
- imports = [ ./modules/window-managers/niri ./modules/desktop-shells/dankmaterial ];
