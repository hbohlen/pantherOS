# Dank Linux Master Guide

**Last Updated:** 2025-11-15 10:16:10  
**Author:** MiniMax Agent  
**Purpose:** Complete Dank Linux reference documentation

## Executive Summary

Dank Linux is a comprehensive Linux desktop environment built around the **DankMaterialShell (DMS)** - a feature-rich desktop shell that eliminates the fragmentation typical of Wayland setups. Instead of requiring dozens of separate tools with different configurations, Dank Linux provides everything in one cohesive package.

```
██████╗  █████╗ ███╗   ██╗██╗  ██╗    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗
██╔══██╗██╔══██╗████╗  ██║██║ ██╔╝    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝
██║  ██║███████║██╔██╗ ██║█████╔╝     ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝
██║  ██║██╔══██║██║╚██╗██║██╔═██╗     ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗
██████╔╝██║  ██║██║ ╚████║██║  ██╗    �██████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝
```

## Quick Start

### One-Command Installation

```bash
curl -fsSL https://install.danklinux.com | sh
```

Supports: **Arch Linux + Derivatives, Fedora + Derivatives, Ubuntu, Debian, openSUSE, and Gentoo**

## The Dank Linux Suite

### Core Components

#### 🔧 DankMaterialShell (DMS)
**Feature-rich desktop shell built with Quickshell and Go**

- **Full Desktop Shell**: Complete panels, widgets, and system integrations
- **Unified Configuration**: One consistent approach, not 15 different syntaxes  
- **Dynamic Theming**: Automatic color generation with `matugen`, applied everywhere
- **Plugin System**: Comprehensive plugin system for limitless widget possibilities
- **Smart Defaults**: Works beautifully out of the box, customizable when you want it

#### 🔍 danksearch
**Blazingly-fast, zero-dependency indexed filesystem search service**

- **Zero Dependencies**: Written in Go, runs anywhere
- **Configurable**: One simple configuration file
- **Fast Indexing**: Index tens of thousands of files in minutes
- **Index Synching**: Automatically keeps index up to date
- **Advanced Search**: Full text search, regex, fuzzy matching
- **REST API**: OpenAPI 3.1 spec for programmatic access

#### 📊 dgop
**First-of-its-kind stateless system & process status tool**

- **Cursor-Based Sampling**: Novel technique for real-time system metrics
- **Zero Resource Overhead**: No persistent daemons or long-running samplers
- **TUI Interface**: Top-like terminal user interface
- **CLI Tools**: Advanced command-line interface
- **REST API**: OpenAPI 3.1 documented REST API

#### ⚙️ dankinstall
**Automated installer and management tool for the entire Dank Linux suite**

- **One-Command Setup**: Automated installation and configuration
- **Dependency Management**: Handles all required dependencies
- **System Integration**: Configures greeters, permissions, and services
- **Updates**: Easy update mechanism for all components

#### 📅 dcal (In Development)
**Calendar application that integrates with online and local calendars**

## Traditional Way vs. Dank Way

### Traditional Way: Package Hunting Simulator

A typical Hyprland, niri, Sway, MangoWC, dwl, or generic Wayland setup requires configuring dozen+ separate tools:

- **Status Bar**: waybar, eww, or custom scripts
- **Notifications**: mako, swaync, or dunst
- **App Launcher**: rofi, wofi, fuzzel, or tofi
- **Screen Locking**: swaylock, hyprlock, or gtklock
- **Idle Management**: swayidle, hypridle
- **System Tools**: htop, btop, nm-applet, blueman, pavucontrol
- **Audio Control**: pavucontrol, pamixer scripts
- **Brightness Control**: brightnessctl with custom bindings
- **Clipboard Manager**: clipman, cliphist, or wl-clipboard scripts
- **Wallpaper Management**: swaybg, swww, hyprpaper, or wpaperd
- **Theming**: manually configuring gtk, qt, various apps, bars, compositor gaps and colors
- **Power Management**: custom scripts or additional daemons
- **Greeter**: gdm, sddm, lightdm, greetd

**Problems**: Each tool has its own configuration format, quirks, dependencies. Hours spent writing glue scripts, debugging integration issues, discovering missing functionality.

### With Preconfigured "Dotfiles"

**Challenges**:
- **Intrusive Configurations**: Often change many configuration files
- **Compatibility Issues**: System differences can break setups
- **Complexity**: Understanding and adapting others' configurations
- **Preference Misalignment**: May not match personal workflow needs

### The Dank Way: Completely Integrated

Dank Linux replaces this fragmented ecosystem with **DankMaterialShell** - a single, integrated solution:

- ✅ **Full Desktop Shell** - Complete panels, widgets, and system integrations
- ✅ **Unified Configuration** - One consistent approach, not 15 different syntaxes
- ✅ **Intelligent Search** - `danksearch` for blazingly-fast file indexing & search
- ✅ **System Monitoring** - `dgop` comprehensive system insights without overhead
- ✅ **Dynamic Theming** - Automatic color generation with `matugen`
- ✅ **All Essentials Included** - Notifications, app launcher, system tray, media controls
- ✅ **Comprehensive Plugin System** - Limitless possibilities for new widgets
- ✅ **Smart Defaults** - Works beautifully out of the box

**Result**: "One install. One shell. Everything works."

## Installation Guide

### Prerequisites by Distribution

#### Arch Linux + Derivatives
```bash
# Install greetd for display management
sudo pacman -S greetd

# Install DMS from AUR
paru -S dankmaterialshell-git
# or
yay -S dankmaterialshell-git

# Install additional components
paru -S dgop danksearch dankinstall
```

#### Fedora + Derivatives
```bash
# Enable Dank Linux COPR repository
sudo dnf copr enable avengemedia/danklinux

# Install DMS and suite
sudo dnf install dankmaterialshell dgop danksearch dankinstall
```

#### Ubuntu/Debian
```bash
# Install system dependencies
sudo apt update
sudo apt install greetd quickshell

# Clone and install DMS
sudo git clone https://github.com/AvengeMedia/DankMaterialShell.git /opt/dankmaterialshell
sudo mkdir -p /etc/xdg/quickshell
sudo cp -r /opt/dankmaterialshell/greeter/* /etc/xdg/quickshell/

# Install additional tools
sudo apt install golang-go  # for danksearch
```

#### NixOS
```bash
# Add to configuration.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    dankmaterialshell
    dgop
    danksearch
    dankinstall
    greetd
  ];
  
  services.greetd.enable = true;
  services.greetd.settings.default_session.command = "dms-greeter --command niri";
}
```

### Greeter Setup

#### For dankinstall Users
```bash
# Automated greeter setup (run after dankinstall)
dms greeter install
dms greeter enable
dms greeter sync
```

#### Manual Greeter Configuration

1. **Edit greetd configuration**:
   ```bash
   sudo nano /etc/greetd/config.toml
   ```
   
   ```toml
   [terminal]
   vt = 1
   
   [default_session]
   user = "greeter"
   command = "dms-greeter --command niri"
   ```

2. **Disable conflicting display managers**:
   ```bash
   sudo systemctl disable gdm lightdm sddm
   ```

3. **Enable greetd service**:
   ```bash
   sudo systemctl enable greetd
   sudo systemctl start greetd
   ```

## DankMaterialShell Configuration

### Basic Configuration Structure

```
~/.config/dms/
├── config.json          # Main DMS configuration
├── widgets/             # Custom widget configurations
│   ├── launcher.json    # Application launcher settings
│   ├── system_tray.json # System tray configuration
│   ├── notifications.json # Notification settings
│   └── ...
├── themes/              # Theme configurations
└── plugins/             # Third-party plugins
```

### Essential Widgets

#### Application Launcher
```json
{
  "name": "launcher",
  "type": "launcher",
  "position": "top-left",
  "config": {
    "command": "rofi -show drun",
    "width": 400,
    "height": 600,
    "hotkey": "super+space"
  }
}
```

#### System Tray
```json
{
  "name": "system_tray",
  "type": "system_tray",
  "position": "top-right",
  "config": {
    "icon_size": 16,
    "spacing": 4
  }
}
```

#### Workspace Switcher
```json
{
  "name": "workspaces",
  "type": "workspaces",
  "position": "bottom",
  "config": {
    "show_numbers": true,
    "active_indicator": true
  }
}
```

### Keybindings Configuration

#### Essential Keybindings
```json
{
  "keybindings": {
    "super+space": "launcher",
    "super+return": "terminal",
    "super+q": "close_window",
    "super+shift+c": "reload_config",
    "alt+tab": "cycle_windows",
    "super+1..9": "workspace_1..9"
  }
}
```

#### Custom Keybindings
```json
{
  "custom_keybindings": [
    {
      "command": "danksearch",
      "key": "super+f",
      "description": "File search"
    },
    {
      "command": "dgop tui",
      "key": "super+shift+t",
      "description": "System monitoring"
    }
  ]
}
```

## Theming System

### Dynamic Theming with Matugen

Dank Linux uses `matugen` for automatic color scheme generation:

```bash
# Generate theme from wallpaper
matugen image /path/to/wallpaper.jpg

# Generate theme from color palette
matugen color "#FF6B6B" "#4ECDC4" "#45B7D1"

# Apply generated theme
matugen apply
```

### Theme Configuration

#### Custom Theme Structure
```json
{
  "name": "custom_dark",
  "type": "dark",
  "colors": {
    "background": "#1a1a1a",
    "foreground": "#ffffff",
    "primary": "#4a9eff",
    "secondary": "#ff6b6b",
    "accent": "#4ecdc4"
  },
  "gradients": {
    "header": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
    "sidebar": "linear-gradient(180deg, #2c3e50 0%, #34495e 100%)"
  }
}
```

### Application Theming

#### GTK Theme Integration
```bash
# Apply GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "Custom-Dark"

# Apply icon theme
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

# Apply cursor theme
gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
```

#### Qt Theme Integration
```bash
# Set Qt application style
export QT_STYLE_OVERRIDE=kvantum

# Use Kvantum theme manager for Qt applications
kvantummanager
```

## Development Environment

### Setting Up Development Tools

#### Essential Development Packages
```bash
# Core development tools
sudo apt install build-essential git curl wget

# Code editors
sudo apt install neovim helix code

# Development libraries
sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev

# Go tools (for danksearch)
sudo apt install golang-go

# Node.js tools
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs
```

#### Rust Development
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Install DMS development dependencies
cargo install quickshell
cargo install tauri-cli
```

#### Building from Source

```bash
# Clone DMS repository
git clone https://github.com/AvengeMedia/DankMaterialShell.git
cd DankMaterialShell

# Build DMS
cargo build --release

# Install DMS
sudo make install

# Build additional tools
cd tools/danksearch
go build -o danksearch
sudo mv danksearch /usr/local/bin/

cd ../dgop
cargo build --release
sudo mv target/release/dgop /usr/local/bin/
```

### Plugin Development

#### Creating Custom Widgets

```javascript
// Custom widget example: weather.js
module.exports = {
  name: 'weather',
  type: 'widget',
  
  init() {
    this.updateWeather();
    this.interval = setInterval(() => this.updateWeather(), 600000); // 10 minutes
  },
  
  async updateWeather() {
    try {
      const response = await fetch('https://api.weather.com/v1/current?location=YOUR_LOCATION&api_key=YOUR_KEY');
      const data = await response.json();
      this.updateDisplay(data);
    } catch (error) {
      console.error('Weather update failed:', error);
    }
  },
  
  updateDisplay(data) {
    this.setText(`${data.temperature}°C ${data.condition}`);
  },
  
  destroy() {
    if (this.interval) clearInterval(this.interval);
  }
};
```

#### Plugin Configuration
```json
{
  "plugins": [
    {
      "name": "weather",
      "path": "/path/to/weather.js",
      "config": {
        "location": "New York",
        "api_key": "your_weather_api_key",
        "update_interval": 600000
      }
    }
  ]
}
```

## System Monitoring with dgop

### Basic dgop Usage

#### Command Line Interface
```bash
# Show basic system overview
dgop

# Show specific metrics
dgop cpu          # CPU usage
dgop memory       # Memory usage
dgop disk         # Disk usage
dgop network      # Network statistics

# Show processes
dgop processes    # Top processes
dgop services     # System services
```

#### TUI Interface
```bash
# Launch interactive TUI
dgop tui

# Navigate with:
# j/k or arrow keys: Move selection
# Enter: Expand/collapse sections
# q: Quit
# r: Refresh data
```

#### Cursor-Based Sampling

dgop's unique cursor-based approach:

```bash
# Get baseline with cursor
dgop cpu --cursor

# Get delta since cursor
dgop cpu --cursor PREVIOUS_CURSOR_VALUE

# Mix different metrics
dgop meta --cursor PREVIOUS_CURSOR cpu,memory,disk
```

### REST API Usage

#### Starting the API Server
```bash
# Start REST API server
dgop api --port 8080

# Start with custom configuration
dgop api --port 8080 --host 0.0.0.0 --config /path/to/config.json
```

#### API Endpoints
```bash
# Get current system metrics
curl http://localhost:8080/api/v1/system

# Get specific metrics with cursor
curl http://localhost:8080/api/v1/cpu?cursor=PREVIOUS_CURSOR

# Get process list
curl http://localhost:8080/api/v1/processes

# Get system services
curl http://localhost:8080/api/v1/services
```

### Integration with DMS

#### Adding dgop Widget to DMS
```json
{
  "name": "system_monitor",
  "type": "dgop_widget",
  "position": "bottom-right",
  "config": {
    "api_endpoint": "http://localhost:8080",
    "refresh_interval": 5000,
    "metrics": ["cpu", "memory", "disk"],
    "display_format": "compact"
  }
}
```

## File Search with danksearch

### Basic Usage

#### Command Line Interface
```bash
# Basic file search
danksearch filename.txt

# Search by file type
danksearch --type pdf document
danksearch --type js --ext .ts "function"

# Full text search
danksearch --content "search term"

# Regular expression search
danksearch --regex "pattern.*[0-9]+"

# Fuzzy search
danksearch --fuzzy "aproximate"
```

#### Advanced Search Options
```bash
# Search in specific directories
danksearch --path /home/user/documents "budget"

# Filter by file size
danksearch --size ">=1MB" "report"
danksearch --size "<100KB" "config"

# Filter by modification time
danksearch --mtime -7 "modified"  # Last 7 days
danksearch --mtime +30 "old"      # Older than 30 days

# Case insensitive search
danksearch --case-insensitive "FILENAME.TXT"
```

### Configuration

#### Basic Configuration File
```json
{
  "index": {
    "paths": [
      "/home/user",
      "/home/user/documents",
      "/home/user/projects"
    ],
    "exclude": [
      "*.tmp",
      "node_modules",
      ".git",
      "dist"
    ],
    "extensions": {
      "text": [".txt", ".md", ".rst"],
      "code": [".js", ".ts", ".py", ".rs", ".go"],
      "documents": [".pdf", ".doc", ".docx"],
      "images": [".png", ".jpg", ".svg"],
      "archives": [".zip", ".tar", ".gz"]
    }
  },
  "search": {
    "default_limit": 100,
    "max_results": 1000,
    "highlight_matches": true
  },
  "api": {
    "enabled": true,
    "port": 8081,
    "cors_enabled": true
  }
}
```

### REST API Integration

#### Starting the Search API
```bash
# Start search API server
danksearch api --port 8081

# Start with custom config
danksearch api --config /path/to/search.json --port 8081
```

#### API Endpoints
```bash
# Search files
curl "http://localhost:8081/search?q=filename&type=text&limit=10"

# Get search suggestions
curl "http://localhost:8081/suggest?q=filen"

# Get file details
curl "http://localhost:8081/file/path/to/file.txt"

# Update search index
curl -X POST "http://localhost:8081/reindex"
```

### Integration with DMS

#### Adding Search Widget
```json
{
  "name": "file_search",
  "type": "search_launcher",
  "position": "top-center",
  "config": {
    "command": "danksearch --interactive",
    "hotkey": "super+f",
    "placeholder": "Search files...",
    "api_endpoint": "http://localhost:8081"
  }
}
```

## Advanced Configuration

### Multi-Monitor Setup

#### Monitor Configuration
```json
{
  "displays": [
    {
      "name": "HDMI-1",
      "primary": true,
      "resolution": "1920x1080",
      "refresh_rate": 60,
      "position": "0x0"
    },
    {
      "name": "HDMI-2", 
      "primary": false,
      "resolution": "2560x1440",
      "refresh_rate": 144,
      "position": "1920x0"
    }
  ],
  "workspaces": {
    "per_monitor": true,
    "auto_assign": true
  }
}
```

#### Per-Monitor Widgets
```json
{
  "widgets": [
    {
      "name": "primary_launcher",
      "monitor": "HDMI-1",
      "position": "top-left"
    },
    {
      "name": "secondary_launcher", 
      "monitor": "HDMI-2",
      "position": "top-right"
    }
  ]
}
```

### Performance Optimization

#### Resource Management
```json
{
  "performance": {
    "memory_limit": "512MB",
    "cpu_limit": 80,
    "refresh_rates": {
      "weather": 600000,    // 10 minutes
      "system_tray": 1000,  // 1 second
      "clock": 1000         // 1 second
    },
    "caching": {
      "enabled": true,
      "max_size": "100MB",
      "ttl": 3600
    }
  }
}
```

#### Widget Lazy Loading
```json
{
  "widgets": [
    {
      "name": "weather",
      "lazy_load": true,
      "load_on_demand": ["workspace_1", "workspace_2"]
    }
  ]
}
```

### Security Configuration

#### IPC Security
```json
{
  "security": {
    "ipc": {
      "enabled": true,
      "allowed_commands": [
        "danksearch",
        "dgop", 
        "systemctl",
        "playerctl"
      ],
      "blocked_commands": [
        "rm -rf",
        "sudo",
        "su"
      ]
    },
    "sandbox": {
      "enabled": true,
      "network_access": "limited"
    }
  }
}
```

## Troubleshooting

### Common Issues

#### DMS Won't Start
```bash
# Check DMS service status
systemctl status dms

# View DMS logs
journalctl -u dms -f

# Check configuration syntax
dms --validate-config

# Restart DMS
dms --reload
```

#### Greeter Issues
```bash
# Check greetd status
systemctl status greetd

# View greeter logs
journalctl -u greetd -f

# Test greeter manually
sudo -u greeter dms-greeter --command niri

# Reset greeter configuration
dms greeter disable
dms greeter enable
```

#### Performance Issues
```bash
# Check memory usage
dgop memory

# Monitor CPU usage
dgop cpu

# Check DMS resource usage
dgop processes | grep dms

# Optimize refresh rates
# Edit ~/.config/dms/config.json and reduce refresh rates
```

#### Widget Not Loading
```bash
# Validate widget configuration
dms --validate-widgets

# Check widget logs
dms --debug --widget weather

# Reload specific widget
dms --reload-widget weather
```

### Debug Mode

#### Enable Debug Logging
```bash
# Start DMS in debug mode
dms --debug

# Enable specific component debug
DMS_DEBUG=widget:weather dms

# Log to file
dms --debug --log-file /tmp/dms.log
```

#### Component-Specific Debugging
```bash
# Debug launcher
dms --debug --component launcher

# Debug theming
DMS_DEBUG=theme:* dms

# Debug plugins
DMS_DEBUG=plugin:* dms
```

## Tips and Best Practices

### Workflow Optimization

#### Efficient Keybindings
```json
{
  "keybindings": {
    "super+w": "close_window",
    "super+shift+q": "logout",
    "super+return": "terminal",
    "super+d": "show_desktop",
    "super+shift+p": "screenshot",
    "super+alt+l": "lock_screen"
  }
}
```

#### Workspace Management
```json
{
  "workspaces": {
    "names": ["Web", "Code", "Docs", "Media", "Misc"],
    "auto_name": true,
    "persistent": true,
    "move_on_create": true
  }
}
```

#### Quick Actions
```json
{
  "quick_actions": [
    {
      "name": "Toggle WiFi",
      "command": "nmcli radio wifi toggle",
      "icon": "network-wireless"
    },
    {
      "name": "Toggle Bluetooth", 
      "command": "bluetoothctl power off",
      "icon": "bluetooth"
    }
  ]
}
```

### Customization Tips

#### Creating Custom Widgets
1. Start with existing widget as template
2. Test in isolation before integrating
3. Use proper error handling
4. Document configuration options
5. Follow DMS widget API

#### Theme Development
1. Use CSS variables for consistency
2. Test on different screen sizes
3. Consider accessibility (contrast, font size)
4. Provide light and dark variants
5. Document color choices

#### Plugin Best Practices
1. Minimize resource usage
2. Implement proper cleanup
3. Use async/await for I/O operations
4. Cache results when appropriate
5. Provide configuration validation

---

**Navigation:**
- [Dank Linux Master Guide](./00_dank_linux_master_guide.md)
- [Getting Started](./01_getting_started.md)
- [Installation Guide](./02_installation_guide.md)
- [Compositor Setup](./03_compositor_setup.md)
- [Keybindings Reference](./04_keybindings_reference.md)
- [Theming Guide](./05_theming_guide.md)
- [Development Environment](./06_development_environment.md)
- [Process Management](./07_process_management.md)