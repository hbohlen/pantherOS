# Shell Modules: Fish

## Overview
This directory contains modules for shell configuration and terminal utilities.

## Modules

### Fish Shell
- **File**: `modules/home-manager/shell/fish.nix`
- **Purpose**: Fish shell configuration with completions and plugins
- **Options**:
  - `programs.fish.enable` - Enable Fish shell (default: false)
- **Usage**: Configure Fish as default shell with plugins
- **Dependencies**: None

### fnm (Fast Node Manager)
- **File**: `modules/home-manager/shell/fnm.nix`
- **Purpose**: Fast Node.js version manager with Fish integration
- **Options**:
  - `programs.fnm.enable` - Enable fnm (default: false)
- **Usage**: Replace nvm with fnm for Node.js version management
- **Dependencies**: Fish shell

## Usage Examples

### Basic Fish Setup
```nix
{ programs.fish = {
  enable = true;
  shellInit = ''
    set -g fish_greeting
  '';
}; }
```

### fnm with Fish
```nix
{ programs.fnm = {
  enable = true;
}; }
```

### Complete Shell Setup
```nix
{ 
  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting
      alias ll "ls -la"
    '';
  };
  
  programs.fnm = {
    enable = true;
  };
}
```

## Related
- [Development Modules](../development/)
- [Terminal Applications](../applications/)
- [Module Development Guide](../../guides/module-development.md)