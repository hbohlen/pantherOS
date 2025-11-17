# NixOS Migration Inventory

## System Overview
- **OS**: CachyOS Linux (rolling release)
- **Kernel**: 6.12.56-3-cachyos-lts (GCC 15.2.1)
- **CPU**: AMD Ryzen AI 7 350 w/ Radeon 860M (16 cores)
- **RAM**: ~15.5 GB
- **Display**: Wayland (Niri compositor)
- **Init**: systemd

---

## 1. Applications & Packages

### Desktop Applications
- **1Password** - Password manager with desktop app and SSH agent
- **Ghostty** - Terminal emulator (primary)
- **Alacritty** - Terminal emulator (secondary)
- **Firefox** - Web browser
- **Code - OSS** - VSCode fork
- **Micro** - Lightweight editor
- **Claude Desktop** - Anthropic client

### Cloud/API Tools
- **GitHub CLI** - `gh`
- **1Password CLI** - `op`
- **NVM** - Node version manager
- **UV** - Python package manager (0.9.9)
- **Bun** - JavaScript runtime (1.3.2)

---

## 2. System Services

### Enabled Services
| Service | Purpose | NixOS |
|---------|---------|-------|
| `ananicy-cpp.service` | Process prioritization | ⚠️ Check compatibility |
| `avahi-daemon.service` | mDNS/DNS-SD | ⚠️ Conditional |
| `bluetooth.service` | Bluetooth management | ⚠️ Conditional |
| `getty@.service` | Terminal login | ✅ Required |
| `NetworkManager.service` | Network management | ✅ Native |
| `nix-daemon.service` | Nix package manager | ✅ Native |
| `podman.service` | Container runtime | ✅ Native |
| `sddm.service` | Display manager | ✅ Native |
| `systemd-resolved.service` | DNS resolver | ✅ Native |
| `systemd-timesyncd.service` | NTP time sync | ✅ Native |
| `ufw.service` | Firewall | ❌ **Replace** with NixOS firewall |
| `valkey.service` | Redis cache | ✅ Native |

---

## 3. User Services

### Running Services
- `niri.service` - Window compositor
- `pipewire.service` - Audio/video pipeline
- `pipewire-pulse.service` - PulseAudio via PipeWire
- `wireplumber.service` - PipeWire session manager
- `gnome-keyring-daemon.service` - Credential storage
- `gvfs-daemon.service` - Virtual filesystem layer
- `dconf.service` - Settings database
- `xdg-desktop-portal.service` - Sandbox integration
- `polkit.service` - Authorization manager
- `power-profiles-daemon.service` - Power management

### Key Services (Disabled but Available)
- `waybar.service` - Status bar
- `mako.service` - Notification daemon

---

## 4. Shell & Terminal

### Shell Configuration
| Shell | Config Location | Notes |
|-------|----------------|-------|
| **Zsh** (default) | `~/.zshrc` | Powerlevel10k theme, CachyOS config |
| **Fish** (active) | `~/.config/fish/` | NVM via bass, CachyOS config |
| **Bash** | `~/.bashrc` | Minimal config |

### Terminal Emulator
- **Ghostty** - Primary terminal
  - Font: 12pt, no decorations, blur radius 32px
  - Padding: 12px, Material 3 UI elements
  - Custom color scheme (dank-colors)

### Shell Tools
- **Modern CLI**: `fzf`, `bat`, `rg`, `exa`, `fd`, `tree`, `zoxide`, `tmux 3.5a`
- **Version Control**: `lazygit`, `gh`

---

## 5. Desktop / WM

### Window Manager
- **Niri** - Scrollable-tiling Wayland compositor
  - Monitor: DP-1 (2560×1440@360Hz)
  - Gaps: 4-5px, Borders: 2-4px
  - Custom colors: Blue accents (#a3c9ff), rounded corners
  - **Keybindings**:
    - `Mod+D` - Toggle overview
    - `Mod+Space` - Application launcher (DMS)
    - `Mod+V` - Clipboard (DMS)
    - Media keys - Volume/brightness control

### Display Manager
- **SDDM** - Simple Desktop Display Manager
  - Autologin enabled for user `hbohlen`

### UI Components
- **Waybar** - Status bar (installed, not running)
  - Modules: appmenu, taskbar, window, workspaces, tray, audio, clock
  - Font: Sarasa UI SC 10pt

- **Mako** - Notification daemon
  - Position: top-right, max visible: 10, timeout: 10s

---

## 6. Theming

### GTK/Qt Theming
| Component | Config | Theme |
|-----------|--------|-------|
| **GTK3** | `~/.config/gtk-3.0/settings.ini` | cachyos-nord |
| **GTK4** | `~/.config/gtk-4.0/settings.ini` | cachyos-nord |
| **Kvantum** | `~/.config/Kvantum/kvantum.kvconfig` | Nordic-Darker-Solid |

### Font & Icons
- Font: Fira Sans 10pt
- Icons: Adwaita
- Cursor: capitaine-cursors (24px)

---

## 7. Dev Tools & Runtimes

### Languages & Runtimes
- **Python 3.13.7** - pip, uv 0.9.9
- **Node.js** v24.11.1 (v20.19.5 installed)
- **Rust** 1.91.1 (rustup 1.28.2)
- **Go** 1.25.4

### Package Managers
- **Python**: `uv`, `pip`, `pipx`
- **Node.js**: `npm`, `bun`
- **Rust**: `cargo`
- **Go**: Standard toolchain

### LSP Servers (Global)
- `rust-analyzer` - Rust
- `gopls` - Go
- `pyright` - Python
- `prettier` - Formatting
- `ruff` - Python linting

### Global NPM Packages
- `@anthropic-ai/claude-code`, `promptfoo`, `claude-flow`
- `@qodo/command`, `agentdb`, `npm-check`

### Build Tools
- `make` (aliased to `make -j16`)
- `podman-compose`

---

## 8. Containers & Virtualization

### Container Runtime
- **Podman** - Rootless containers
  - Service: `podman.service` (enabled)
  - **Not installed**: `docker`, `docker-compose`
  - Compose: `podman-compose` available

### Nix Ecosystem
- `nix`, `nix-env`, `nix-shell`
- **Missing**: `nix-index`, `nix-prefetch-*`

---

## 9. Networking

### Network Management
- **NetworkManager** - Configured and active
- **WiFi** - Managed via NetworkManager
- **DNS** - systemd-resolved

### Internet Tools
- **Tailscale** - Not installed (planned for NixOS)
- **VPN** - No OpenVPN/WireGuard setup (Tailscale planned)

---

## 10. Security & Auth

### Credential Management
- **1Password** - Desktop app + CLI
  - SSH keys managed via 1Password agent
- **GNOME Keyring** - User credential storage

### Firewall
- **UFW** - Enabled but **will be replaced** with NixOS firewall

### Authentication
- **Polkit** - Authorization framework
- **SDDM** - Display manager with autologin

---

## 11. AI/ML Tools

### Installed
- **Claude CLI** - Anthropic API client
- **NVM** - Node.js version management
- **UV** - Fast Python package manager

### Missing (Not installed)
- **No CUDA/cuDNN** - AMD GPU (Radeon 860M)
- **No PyTorch/TensorFlow** - No AI/ML stack installed
- **No Jupyter** - Data science tools not present

---

## 12. Config Files & Key Settings

### Shell Configs
- `~/.zshrc` - Powerlevel10k, CachyOS, Anthropic API, bun completions
- `~/.config/fish/config.fish` - NVM via bass, CachyOS config
- `~/.bashrc` - Minimal, Anthropic API, custom env
- `~/.local/bin/env` - PATH management for `~/.local/bin`

### Desktop Configs
- `~/.config/niri/config.kdl` - Window management, DMS integration, keybindings
- `~/.config/ghostty/config` - Terminal settings, Material 3 UI
- `~/.config/mako/config` - Notification settings
- `~/.config/waybar/config` - Status bar configuration

### Application Configs
- `~/.gitconfig` - User: Hayden Boehlen, GitHub CLI integration
- `~/.config/micro/settings.json` - Catppuccin theme
- `~/.config/gh/config.yml` - HTTPS protocol, custom aliases

### Theming Configs
- `~/.config/gtk-3.0/settings.ini` - Adwaita icons, Fira Sans, dark theme
- `~/.config/gtk-4.0/settings.ini` - Consistent with GTK3
- `~/.config/Kvantum/kvantum.kvconfig` - Nordic-Darker-Solid

---

## 13. NixOS Mapping Notes

### System Configuration
```nix
# System services
networking.networkmanager.enable = true;
services.nix-daemon.enable = true;  # default on NixOS
services.displayManager.sddm.enable = true;
virtualisation.podman.enable = true;
services.redis.enable = true;

# Replace UFW
networking.firewall.enable = true;
networking.firewall.allowedTCPPorts = [ 22 80 443 ];
```

### Home Manager Configuration
```nix
# Shells
programs.fish.enable = true;
programs.zsh.enable = true;

# Terminals
programs.alacritty.enable = true;  # Ghostty needs custom module
services.mako.enable = true;

# Desktop
programs.niri = {
  enable = true;
  settings = import ./niri-config.kdl;
};

# Dev tools
programs.git.config = {
  user.name = "Hayden Boehlen";
  user.email = "bohlenhayden@gmail.com";
};

# Applications
programs.gh.enable = true;
home.packages = [
  pkgs.1password
  pkgs.micro
  pkgs.vscode
  pkgs.firefox
];
```

### Custom Modules Required
1. **OpNix** - 1Password CLI integration
2. **Ghostty** - Package + config module
3. **DMS** - Niri overlay system
4. **Datadog** - Monitoring agent

### VPS Services
```nix
# Attic cache
services.atticd = {
  enable = true;
  settings.storage = {
    type = "s3";
    # B2 configuration
  };
};

# Reverse proxy
services.caddy = {
  enable = true;
  configFile = secrets.caddyConfig;
};

# Tailscale
services.tailscale = {
  enable = true;
  useRoutingFeatures = "both";
};
```

### Development Shells
```nix
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs-24_x
    python313
    rustc
    go
    uv
    bun
    rust-analyzer
    gopls
    pyright
  ];
};
```

### Priority Actions
1. ✅ **Native support** - Most services have NixOS modules
2. ⚠️ **Custom modules** - OpNix, Ghostty, DMS, Datadog
3. ❌ **Remove/replace** - UFW → NixOS firewall, bass → native NVM
4. 📦 **Package** - Attic, Tailscale, Datadog, custom apps

### Migration Strategy
1. **Phase 1**: System services (Nix, NetworkManager, SDDM)
2. **Phase 2**: Home Manager (shells, basic apps, git)
3. **Phase 3**: Desktop environment (Niri, Mako, theming)
4. **Phase 4**: Development tools (LSPs, devShells)
5. **Phase 5**: Custom modules (OpNix, Attic, DMS)
6. **Phase 6**: VPS infrastructure (Attic cache, Caddy, Tailscale)
