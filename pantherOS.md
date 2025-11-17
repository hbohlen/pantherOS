
# Overview
This project is a personal NixOS configuration featuring multi-host, flake-based, modular and reproducable developer infrastructure. It aims to create a declarative configuration for solo, personal programming and development workflows. I am a solo, student developer working on many personal programming projects and need a way to manage, reproduce and declare development infrastructure. This aims to solves the problem of configuration drift experienced between personal device developer workstation configurations and between cloud VPS servers. The ability to have a declarative, modular, and reproducable framework to build my personal development infrastructure creates an initial effort required to build the NixOS configuration, but offers a future payoff in speed and efficiency for managing and deployments.

## Hosts
### Lenovo Yoga 7 2-in-1 14AKP10
- Host name - `yoga`
- Configured for lightweight programming and web browsing for research. Should prioritize battery life over raw speed and performance.
- CPU -
- GPU -
- RAM - 
- Disk - 

### ASUS ROG Zephyrus M16 GU603ZW
- Host name - `zephyrus`
- Configured for best speed and performance. Multiple power profiles present ranging from battery efficient to plugged-in raw performance. Optimized for heavy development workflows utilizing Podman containers, multi-SSD optimizations, AI coding CLI tools like Claude Code CLI, Zed IDE, opencode.ai CLI, etc.
- CPU -
- GPU -
- RAM -
- Disk -

## Servers

### Hetzner Cloud VPS
- Host name - `hetzner-vps`
- Configure for optimal performance for running a personal codespace on the server. Tuned for being able to run AI coding CLI tools like Claude Code. Tuned for Podman container hosting. Secured with Tailscale, 1password CLI service account secrets and OpNix. Reverse Proxies via Caddy.
-  CPU - 
- GPU - if applicable
- RAM -
- Disk -

### OVH Cloud VPS
- Host name -
- Secondary VPS server tuned the same as the `hetzner` VPS.
- CPU -
- GPU -
- RAM -
- Disk -

## Secrets Management
All secrets managed with `_1password` service account and [OpNix](https://github.com/brizzbuzz/opnix). For personal devices, `_1password-gui` will be installed and integrated with the Biometric Unlock/System authentication polkit to allow for authentication through 1password.

## Disk Configuration
[Disko](https://github.com/nix-community/disko) will be used to create `disko.nix` files for each `host`. The filesystem should be `btrfs`. There should be optimal sub-volume layouts. All personal coding projects will live in the `~/dev`. Podman and Podman Compose will be used, so potential sub-volume. Optimizations for SSD longevity.

## Security

The development infrastructure will be secured with a Tailscale Tailnet. This includes, personal devices, VPS servers, containers, services, etc. There need to be more research done on role/ACL setups, tags, and other features offered by Tailscale that would benefit the infrastructure.

Proper, firewall configuration should be configured. IMPORTANT: THE firewall should always be configured in accordance to me using Tailscale. Then proper ports or firewall rules should never lead to me being locked out of SSHing to the server.

## SSH

1password will be the acting SSH agent.

## DNS and Proxy

Cloudflare will be used for DNS services. Caddy will be used for Reverse Proxy configurations. I will need to acquire a domain and determine how to use Cloudflare, Caddy and Tailscale so I can deploy a web UI from one of the VPS servers, so that the Web page is only loads and is accessible from devices on my tailnet. Any other visitors, outside my tailnet,should lead to the page not loading.

## devShell

There should be a fully configured `devShell` for my programming. It should auto-activate upon entering the `~/dev` folder as this is where I place all my programming projects.

### fish

`fish` should be fully-configured and set to the default shell. There should be complete compatibility configurations for completions.

### Ghostty

`ghostty` should be the default and only terminal installed.

#todo : Research how to install `ghostty` on NixOS and determine package name
#todo : Research NixOS-specific compatibility and troubleshooting solutions
#todo: Research potential compatibility issues with other applications and services in my tool chain
#todo : Create implementation examples and code snippets
## Additional packages

Additional packages should be included to extend the ease-of-use and Quality-of-Life. Packages examples could be, but not limited to, `zoxide`, `exa`, `ripgrep`, `fzf`, `tmux`, `zellij`. These are just examples. More research needs to be done on the standard packages to install, as well as analyzing other development tools I use in my workflows to determine packages that align with my tooling.
- #todo: Analyze tools in my developer workflow
- #todo : Research packages recommend to integrate with tool-specific chains
- #todo : Reseach each of the recommendations and their use-case and features
- #todo : Decide on which package recommendations to include

## Compositor / WM

Niri will be used for the window-manager Compositor. I will also be using [Dank Linux](https://danklinux.com/) including the [DankMaterialShell](https://danklinux.com/docs/dankmaterialshell/overview), [DankGreeter](https://danklinux.com/docs/dankgreeter/), [DankGop](https://danklinux.com/docs/dgop/), [DankSearch](https://danklinux.com/docs/danksearch/).

### Niri

The [niri-flake](https://github.com/sodiboo/niri-flake) needs to be added to the configuration for NixOS compatibility. The `niri-flake` can be added like this:

```nix
niri = {
  url = "github:sodiboo/niri-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

and then imported into `home-manager` like this:

```nix
imports = [
  inputs.niri.homeModules.niri
];
```

Once that is configured, DankMaterialShell can be configured.
## DankMaterialShell

Importing `DankMaterialShell` niri modules:

```nix
imports = [
  inputs.dankMaterialShell.homeModules.dankMaterialShell.default
  inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
];
```

Enabling niri integration features:

```
programs.dankMaterialShell = {
  enable = true;
  niri = {
    enableKeybinds = true;   # Automatic keybinding configuration
    enableSpawn = true;      # Auto-start DMS with niri
  };
};
```

This will automatically configure keybindings for launcher, notifications, settings, and all other DankMaterialShell features.

### Essential packages needed for Niri, DankMaterialShell, fish, Ghostty, `_1password`, `_1password-gui`, polkit.

DankMaterialShell defaults to `mate-polkit`, so this should be considered for `_1password` and `_1password-gui` compatibility. 

DankMaterialShell automatically configured `ghostty` and `fish` completions.

- Required Packages
	- `wl-clipboard` - Wayland clipboard utilities (required for clipboard operations)
	-  `accountsservice` - User account information (required dependency)
	- `xdg-desktop-portal-gtk` - Desktop portal for file pickers and other integrations
- Recommended Packages
	- `matugen` - Dynamic wallpaper-based theming
	- - `cliphist` - Clipboard history management manual_packages.go:93-96
	- `hyprpicker` - Color picker functionality opensuse.go:141
	- `dgop` - System monitoring tool for CPU/GPU/memory metrics
- Niri-specific
	- `xwayland-satellite` - XWayland support for legacy X11 applications (like some 1Password components if needed)

## Languages and frameworks

All languages should have properly configured, where applicable, a package manager, LSP, and formatter. Package manager managers, LSP, and formatter should all be completely compatible with all the other tools on the system, especially for AI coding agent CLIs.
- Node
	- Should be properly configured for `nvm` and `npm` usage.
- JavaScript/Typescript
- ReactJS
- Python
- Go
- Rust
- Nix

## Apps

### Zed IDE

### Zen Browser

### 1password GUI

### [`numtide/nix-ai-tools`](https://github.com/numtide/nix-ai-tools)

This should be used to install multiple AI tools.
#### opencode
`github:numtide/nix-ai-tools#opencode`

#### qwen-code
`github:numtide/nix-ai-tools#qwen-code`

#### claude-code
`github:numtide/nix-ai-tools#claude-code`

#### claude-code-acp
`github:numtide/nix-ai-tools#claude-code-acp`

#### codex-acp
`github:numtide/nix-ai-tools#codex-acp`

#### gemini-cli
`github:numtide/nix-ai-tools#gemini-cli`

#### catnip
`github:numtide/nix-ai-tools#catnip`


## System Authentication

The configuration should completely configure polkit and PAM for compatibility all present tooling and system configurations. The polkit used should be `mate-polkit` as DankMaterialShell integrated with this polkit natively. `_1password` should also be completely compatible with `mate-polkit`. No other polkit should be configured unless absolutely necessary to avoid complications.

`_1password` should handle password prompts and biometric unlocks. When a password prompt is triggered, `_1password`should show to the prompt. If the `_1password-gui` app is open and logged in, I should be able to just press `authenticate` without needing to enter my `_1password` account password or my user password.

# Modules
# System 
The NixOS configuration should be completely, and fully modular. Each module should be grouped with related modules and there should be a nested modular structure, where modules are single-concern. This creates easier readability and reproducibility.

## home-manager

Each `home-manager` package should be fully modular. Each package should maintain completely modular structure.


## config, settings and dotfiles

`home-manager` should manage all configurations, settings, and dotfiles. For applications that require config files to be in particular directories, they should be properly setup so the service or application can find the needed configuration file. Configuration, settings and dotfiles should be split into modules as well, if possible, to allow for easier readability and modifications.

The opencode.ai AI coding assistant CLI configuration should be managed with `home-manager`. The global config file is typically stored at the path `~/.config/opencode/opencode.jsonc`. opencode.ai features the ability for custom agents, rules, tools, plugins, commands, etc. The global path for those reside in `~/.config/opencode/{agent,tool,plugin, command}`.

Claude Code `settings.json` as well as any other configuration files should be considered.








[[DankMaterialShell]]
