# Desktop Environments & Shells

Configuration patterns for desktop environments and shell applications.

## Desktop Shell Integration

```nix
# DankMaterialShell integration
DankMaterialShell = {
  enable = true;
  # Shell configuration
};

# Include shell modules
modules = [
  DankMaterialShell.nixosModules.dankMaterialShell
];
```

- **Enable shell explicitly**: Set shell enable options clearly
- **Configure in module context**: Configure shell features in dedicated modules
- **Separate shell from window manager**: Keep shell and window manager configuration separate

## Window Manager Configuration

```nix
# Niri (scrollable-tiling Wayland window manager)
programs.niri = {
  enable = true;
  # Niri specific configuration
};
```

- **Configure per window manager**: Use appropriate options for each WM
- **Document keybindings**: Comment on custom keybindings
- **Group related settings**: Organize WM configuration logically

## System Services for Desktop

```nix
# Enable display manager if needed
services.xserver.displayManager.gdm.enable = true;

# Enable desktop environment
services.xserver.desktopManager.xfce.enable = true;

# Or for Wayland compositors
programs.waybar = {
  enable = true;
  # Status bar configuration
};
```

- **Use NixOS options**: Prefer built-in NixOS options for desktop services
- **Configure display manager**: Set up appropriate display manager for the desktop
- **Document desktop choice**: Comment on why specific desktop is used

## Desktop Widgets & Panels

```nix
# Widget configuration in DankMaterialShell
dankMaterialShell.widgets = {
  enable = true;
  widgetConfig = {
    media-controls = {
      enable = true;
    };
    network-status = {
      enable = true;
    };
    system-monitoring = {
      enable = true;
      showCpu = true;
      showMemory = true;
    };
  };
};
```

- **Enable widgets explicitly**: Set `enable = true` for widgets you use
- **Configure per widget**: Each widget should have specific configuration
- **Document widget purpose**: Comment on what each widget displays
- **Group related widgets**: Organize widgets by function

## Application Launchers

```nix
# Application launcher configuration
programs.rofi = {
  enable = true;
  # OR
programs.dmenu = {
  enable = true;
};
```

- **Configure application launcher**: Set up a launcher for application access
- **Set keybindings**: Configure keyboard shortcuts for launcher
- **Document launcher choice**: Comment on why specific launcher is used

## System Tray & Status Bar

```nix
# Status bar configuration (waybar, polybar, etc.)
programs.waybar = {
  enable = true;
  config = ''
    {
      "modules": [...]
    }
  '';
};
```

- **Configure status bar**: Set up status bar with system information
- **Show essential information**: Display battery, network, volume, etc.
- **Use JSON for complex config**: Store complex configuration in JSON format
- **Document status items**: Comment on what information is displayed

## Theme Configuration

```nix
# Theming for desktop components
services.greetd = {
  gtkgreetEnable = true;
  # Theming configuration
};
```

- **Use consistent theming**: Apply consistent theme across desktop
- **Configure color scheme**: Set up appropriate colors for light/dark mode
- **Document theme choice**: Comment on theme preferences
- **Keep theme modular**: Organize theme configuration separately

## Hotkey Configuration

```nix
# Keybinding configuration
services.xserver.windowManager.i3 = {
  extraConfig = ''
    # Keybindings
    bindsym $mod+Return exec terminal
    bindsym $mod+d exec dmenu_run
  '';
};
```

- **Document keybindings**: Comment on important keybindings
- **Use consistent mod key**: Use consistent modifier key across desktop
- **Group related bindings**: Organize keybindings by function
- **Avoid conflicts**: Ensure keybindings don't conflict with applications

## Policy Kit & Permissions

```nix
# Polkit configuration for desktop permissions
security.polkit.enable = true;

# Or for DankMaterialShell
dankMaterialShell.polkit = {
  enable = true;
  # Polkit configuration
};
```

- **Configure polkit**: Set up PolicyKit for privilege escalation
- **Document permission model**: Comment on how permissions work
- **Keep security in mind**: Ensure privileged operations are properly secured
- **Test permissions**: Verify that normal users can perform necessary tasks

## Hardware-Specific Configuration

```nix
# Laptop-specific configuration
hardware = {
  enable = true;
  laptop = {
    trackpad = {
      enable = true;
      # Trackpad configuration
    };
  };
};
```

- **Configure hardware features**: Set up touchpad, special keys, etc.
- **Document hardware quirks**: Comment on hardware-specific workarounds
- **Test functionality**: Verify hardware features work correctly
- **Keep hardware config separate**: Separate hardware-specific configuration

## Startup & Autostart

```nix
# Autostart configuration
systemd.user.services.app-name = {
  Unit.Description = "Application";
  Service.ExecStart = "${pkgs.app}/bin/app";
  Install.WantedBy = ["default.target"];
};
```

- **Use systemd for autostart**: Prefer systemd user services for autostart
- **Document startup order**: Comment on dependencies between autostart services
- **Disable unnecessary autostart**: Only autostart essential applications
- **Use WantedBy=default.target**: Standard target for user services
