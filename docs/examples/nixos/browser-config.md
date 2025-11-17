# Browser Toggle Module

## Enrichment Metadata

| Attribute | Value |
|-----------|-------|
| **Purpose** | Toggle between Brave and Zen browsers with single option |
| **Layer** | `modules/apps/` |
| **Type** | NixOS module with custom options |
| **Dependencies** | None (browsers from nixpkgs) |
| **Conflicts** | None |
| **Platforms** | `x86_64-linux` primarily |
| **Maintenance** | Stable |

---

## Configuration Points

### Options
- `pantherOS.desktop.browser`: enum ["brave" "zen"]
  - Default: "zen"
  - Sets system-wide default browser
  - Configures MIME associations
  - Sets $BROWSER environment variable

---

## Code Implementation

```nix
# modules/apps/browser.nix
{ lib, pkgs, config, ... }:
let 
  browsers = [ "brave" "zen" ];
  cfg = config.pantherOS.desktop.browser;
in {
  options.pantherOS.desktop.browser = lib.mkOption {
    type = lib.types.enum browsers;
    default = "zen";
    description = ''
      Default browser to install and set as $BROWSER.
      Options: brave (proprietary but popular) or zen (Firefox-based, privacy-focused)
    '';
  };

  config = let
    pkg = if cfg == "brave"
          then pkgs.brave
          else pkgs.zen-browser;
    
    desktopFile = if cfg == "brave" 
                  then "brave-browser.desktop"
                  else "zen.desktop";
    
    binName = if cfg == "brave"
              then "brave"
              else "zen-browser";
  in {
    # Install browser package
    environment.systemPackages = [ pkg ];
    
    # Set $BROWSER environment variable
    environment.variables.BROWSER = lib.mkDefault binName;
    
    # Set default browser for XDG/MIME
    xdg.mime.defaultApplications = {
      "text/html" = desktopFile;
      "x-scheme-handler/http" = desktopFile;
      "x-scheme-handler/https" = desktopFile;
      "x-scheme-handler/about" = desktopFile;
      "x-scheme-handler/unknown" = desktopFile;
    };
    
    # Note: Brave is unfree, ensure allowUnfree is set
    nixpkgs.config.allowUnfree = lib.mkIf (cfg == "brave") true;
  };
}
```

---

## Integration Pattern

### Per-Host Configuration

```nix
# hosts/yoga/default.nix - Workstation with Brave
{
  imports = [
    ../../modules/apps/browser.nix
  ];
  
  pantherOS.desktop.browser = "brave";
}

# hosts/desktop/default.nix - Desktop with Zen
{
  imports = [
    ../../modules/apps/browser.nix
  ];
  
  pantherOS.desktop.browser = "zen";
}

# hosts/servers/ovh/default.nix - Server can also have browser for debugging
{
  imports = [
    ../../modules/apps/browser.nix
  ];
  
  pantherOS.desktop.browser = "zen";  # Lighter weight for remote usage
}
```

### Testing Different Browsers

```bash
# Switch browser without rebuilding
BROWSER=zen-browser xdg-open https://example.com

# Change system default
# Edit host config, change browser option, rebuild
sudo nixos-rebuild switch --flake .#yoga
```

---

## Validation Steps

### 1. Build Check
```bash
nix build .#nixosConfigurations.yoga.config.system.build.toplevel
```

### 2. Deploy and Verify
```bash
sudo nixos-rebuild switch --flake .#yoga

# Check installed package
which brave || which zen-browser

# Check environment variable
echo $BROWSER
```

### 3. Test MIME Associations
```bash
# Should open in configured browser
xdg-open https://example.com

# Check MIME database
xdg-mime query default text/html
# Expected: brave-browser.desktop or zen.desktop
```

### 4. Verify Desktop File
```bash
# Find desktop file
find /run/current-system -name "brave-browser.desktop" -o -name "zen.desktop"

# Test desktop file launch
gtk-launch $(xdg-mime query default text/html) https://example.com
```

### Expected Results:
- Browser package installed
- $BROWSER variable set correctly
- URLs open in configured browser
- Desktop integration working

---

## Troubleshooting

### Brave Not Installing (Unfree License)
```nix
# Ensure allowUnfree is set in base config
# modules/base/nix.nix
{
  nixpkgs.config.allowUnfree = true;
}
```

### Zen Desktop File Not Found
```bash
# Check available desktop files in Zen package
nix-store -q --references $(which zen-browser) | grep desktop

# The desktop file name may vary by channel
# Update desktopFile variable in module accordingly
```

### Browser Doesn't Open URLs
```bash
# Check XDG settings
echo $XDG_CURRENT_DESKTOP

# Ensure xdg-utils is installed
which xdg-open

# Test direct browser launch
brave https://example.com
# or
zen-browser https://example.com
```

---

## Related Modules

- **Base Nix**: [`nixos/nix-base.nix.md`](./nix-base.nix.md) - allowUnfree setting
- **Desktop Environment**: See `DESKTOP_ENVIRONMENT_GUIDE.md`
- **pantherOS Brief**: [`03_PANTHEROS_NIXOS_BRIEF.md`](../../project_briefs/03_PANTHEROS_NIXOS_BRIEF.md)

---

## Browser Comparison

### Brave
- **Pros**: Chromium-based, built-in ad blocking, crypto wallet
- **Cons**: Proprietary license (unfree), Chromium monoculture
- **Best for**: Users who need Chrome compatibility, crypto features

### Zen
- **Pros**: Firefox-based, privacy-focused, open source, vertical tabs
- **Cons**: Newer/less mature, smaller extension ecosystem than Chrome
- **Best for**: Privacy-conscious users, Firefox fans, developers

---

## Advanced Customization

### Adding Third Browser Option

```nix
let 
  browsers = [ "brave" "zen" "firefox" ];
in {
  options.pantherOS.desktop.browser = lib.mkOption {
    type = lib.types.enum browsers;
    default = "zen";
  };

  config = let
    pkg = if cfg == "brave" then pkgs.brave
          else if cfg == "zen" then pkgs.zen-browser
          else pkgs.firefox;
    
    desktopFile = if cfg == "brave" then "brave-browser.desktop"
                  else if cfg == "zen" then "zen.desktop"
                  else "firefox.desktop";
    
    binName = if cfg == "brave" then "brave"
              else if cfg == "zen" then "zen-browser"
              else "firefox";
  in {
    # ... rest of config
  };
}
```

### Per-User Browser in Home Manager

```nix
# home/hayden/default.nix
{ config, pkgs, ... }:
{
  home.sessionVariables = {
    BROWSER = "firefox";  # Override system default
  };
  
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };
}
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-15 | Initial enriched documentation |
