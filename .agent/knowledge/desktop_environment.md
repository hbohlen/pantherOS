# Desktop Environment Stack

## Overview
The **pantherOS** desktop environment is a custom hybrid stack designed for modern Wayland performance and a polished Material Design aesthetic. It combines **Niri** as the compositor and **DankMaterialShell** as the shell interface.

## Components

### 1. Compositor: Niri
-   **Type**: Scrollable Tiling Wayland Compositor.
-   **Configuration**: `modules/window-managers/niri/`.
-   **Key Features**:
    -   Infinite scrolling workspace.
    -   Tiling layout with dynamic resizing.
    -   Animations and visual effects.
-   **Integration**:
    -   Upstream module is disabled (`disabledModules`) to avoid conflicts.
    -   Local module (`modules/window-managers/niri/default.nix`) manages the service and configuration.
    -   `programs.niri.enable = true` (in local module).

### 2. Shell: DankMaterialShell
-   **Type**: Desktop Shell (Qt/QML based).
-   **Configuration**: `modules/desktop-shells/dankmaterial/`.
-   **Key Features**:
    -   Material Design 3 aesthetics.
    -   Custom widgets (Network, Audio, Battery, System).
    -   Dynamic theming based on wallpaper (via Matugen).
-   **Services**:
    -   `services.nix` defines systemd user services for feeding data to widgets (audio, network, power, system usage).
    -   Integrates with `pipewire`, `networkmanager`, `upower`, `geoclue2`.

### 3. Theming
-   **Tool**: Matugen.
-   **Mechanism**: Generates colors from the current wallpaper and applies them to:
    -   GTK applications (via `adw-gtk3` / `libadwaita`).
    -   Qt applications (via `adwaita-qt` / `qt6ct`).
    -   Niri borders and UI elements.
    -   DankMaterialShell widgets.

## Configuration Details
-   **Home Manager Integration**: Much of the user-specific configuration (keybinds, specific theme settings) is intended to be managed via Home Manager, though system-level services are defined in NixOS modules.
-   **Hardware Acceleration**: Fully enabled for both Intel and NVIDIA GPUs (Prime offload) on the Zephyrus.

## Troubleshooting
-   **Widgets not updating**: Check systemd user services: `systemctl --user status dankmaterial-*`.
-   **Theme not applying**: Verify Matugen generated files in `~/.config/` and ensure apps are configured to use them.
