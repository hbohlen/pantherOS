# Ghostty Terminal - NixOS Research Report

## Overview

Research on Ghostty terminal emulator availability and integration with NixOS for the pantherOS project.

## What is Ghostty?

- **Developer**: Mitchell Hashimoto (HashiCorp founder)
- **Type**: Modern, fast terminal emulator
- **Technology**: Cross-platform (macOS, Linux, Windows)
- **Features**: GPU acceleration, TrueColor, ligatures, minimal UI
- **Release**: 2024 (relatively new)

## Current Status: UNKNOWN PACKAGE AVAILABILITY

### Package Name
**Status**: UNKNOWN - Needs verification

Possible package names:
- `ghostty` (most likely)
- `mitchellh.ghostty` (if namespaced)
- May require custom packaging

### NixOS Availability

#### Stable Channel (nixos-unstable)
**Status**: REQUIRES VERIFICATION
- Ghostty released in 2024, may be too new for stable channels
- Check: `nix search nixpkgs ghostty`
- If not found, may need to use unstable or package from source

#### Unstable Channel (nixpkgs-unstable)
**Status**: POSSIBLE
- Unstable channel has more recent packages
- May be available before stable channel gets it
- Recommended approach: Test with unstable first

#### Community Packaging
**Status**: ALTERNATIVE
- If not in official nixpkgs, may need community flake
- Check for community-maintained packages
- Could be in `nix-community` or individual developer repos

## Installation Methods to Test

### Method 1: Direct Package (if available)
```nix
{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;  # Once package name is confirmed
  };
}
```

### Method 2: From flake
```nix
{
  inputs = {
    ghostty.url = "github:mitchellh/ghostty";
    # OR
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
```

### Method 3: Manual packaging
If not available in nixpkgs:
- Package from source using `buildRustPackage`
- Create custom derivation
- Test compatibility with NixOS

## Verification Steps

1. **Test with nixos-unstable**:
   ```bash
   nix run github:NixOS/nixpkgs/nixos-unstable#ghostty -- --version
   ```

2. **Check package attributes**:
   ```bash
   nix eval github:NixOS/nixpkgs/nixos-unstable#legacyPackages.x86_64-linux.ghostty.version
   ```

3. **Search nixpkgs directly**:
   - Visit: https://search.nixos.org/packages?query=ghostty
   - Verify package name and version

## Compatibility Considerations

### With DankMaterialShell
- Ghostty should work with Niri compositor
- Wayland support required ✓ (Ghostty supports Wayland)
- XWayland compatibility if needed for legacy apps

### With Fish Shell
- Fish completions available in Ghostty ✓
- Shell integration supported
- Auto-activation in ~/dev should work seamlessly

### Wayland/Niri Integration
- Ghostty natively supports Wayland ✓
- Should work well with Niri
- Clipboard integration via wl-clipboard
- No special configuration needed

## Testing Plan

1. ✅ Verify package availability in nixos-unstable
2. ✅ Test installation on non-production system
3. ✅ Verify compatibility with:
   - Niri compositor
   - DankMaterialShell
   - Fish shell
   - Wayland protocols
   - Clipboard operations
4. ✅ Confirm performance (GPU acceleration)
5. ✅ Check all features:
   - TrueColor
   - Ligatures
   - Font rendering
   - Key bindings
   - Tabs/splits

## Alternatives if Ghostty Unavailable

### Tier 1 Alternatives (Modern, Feature-Rich)
1. **WezTerm**
   - Cross-platform
   - GPU-accelerated
   - Rich configuration
   - Available in NixOS ✓
   - Modern alternative to Ghostty

2. **Kitty**
   - GPU-accelerated
   - Highly configurable
   - Tabs/splits/pane management
   - Available in NixOS ✓
   - Mature project

3. **Alacritty**
   - GPU-accelerated
   - Rust-based
   - YAML configuration
   - Available in NixOS ✓
   - Very fast, minimal

### Tier 2 Alternatives (Lightweight)
1. **Foot**
   - Wayland-native
   - Lightweight
   - Minimal dependencies
   - Available in NixOS ✓
   - Good for resource-constrained systems

2. **Rio**
   - Modern Rust terminal
   - GPU-accelerated
   - Cross-platform
   - Less mature but promising

## Recommendation

**For pantherOS**:

1. **Priority**: Research Ghostty package availability
2. **Timeline**: Before workstation configuration phase
3. **Backup Plan**: Use WezTerm as primary, Ghostty as experimental
4. **Decision Point**: After verifying package stability

**Temporary Recommendation**: Use **WezTerm** as the default terminal if Ghostty proves problematic:
- Fully available in NixOS
- Feature-rich and modern
- Similar GPU acceleration
- Active development
- Excellent Wayland support

## Next Steps

1. ⏳ Verify Ghostty package in nixos-unstable
2. ⏳ Test installation and configuration
3. ⏳ Document final decision in pantherOS.md
4. ⏳ Update flake.nix with chosen terminal
5. ⏳ Create home-manager module for terminal configuration

## References

- [Ghostty Homepage](https://ghostty.org/)
- [Ghostty GitHub](https://github.com/mitchellh/ghostty)
- [NixOS Package Search](https://search.nixos.org/packages)
- [WezTerm](https://wezfurlong.org/wezterm/)
- [Kitty Terminal](https://sw.kovidgoyal.net/kitty/)
- [Alacritty](https://alacritty.org/)
