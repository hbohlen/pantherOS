# Home Manager Configuration

Guidelines for managing user environments with Home Manager.

## Basic Structure

```nix
home-manager = {
  useGlobalPkgs = true;  # Use system nixpkgs
  useUserPackages = true;  # Enable user package management
  backupFileExtension = "hm-bak";  # Backup extension

  users.username = {
    home = {
      username = "username";
      homeDirectory = "/home/username";
      stateVersion = "25.05";
    };

    # Configuration options
  };
};
```

- **Set stateVersion**: Use the same stateVersion as system configuration
- **Use global nixpkgs**: Set `useGlobalPkgs = true` for consistency
- **Enable user packages**: Set `useUserPackages = true` to manage user packages
- **Configure backup**: Set a meaningful backup file extension

## XDG Base Directory Specification

```nix
xdg.enable = true;  # Enable XDG base directory support

# Link configuration files
xdg.configFile."app-name" = {
  source = ../../../path/to/config;
  recursive = true;
};

# Set environment variables
xdg.configFile.".config/file" = {
  text = ''  # Or use source
    setting=value
  '';
};
```

- **Enable XDG support**: Always set `xdg.enable = true`
- **Use xdg.configFile**: Prefer XDG directories for application config
- **Use symbolic linking**: Link source files instead of copying
- **Set recursive for directories**: Use `recursive = true` for directory configs

## Package Management

```nix
home.packages = with pkgs; [
  # List user packages here
  package1
  package2
];

# Avoid system packages here
# Use environment.systemPackages for system-wide packages
```

- **Keep separate from system**: User packages in Home Manager, system packages in NixOS
- **Use with pkgs**: Leverage nixpkgs attribute set
- **Organize by category**: Group related packages (dev tools, editors, etc.)
- **Document special packages**: Comment on non-obvious package choices

## Program Configuration

```nix
programs = {
  program-name = {
    enable = true;
    # Configuration options
  };
};
```

- **Use program modules**: Prefer built-in Home Manager program modules
- **Group related programs**: Organize program configuration logically
- **Set enable explicitly**: Always use `enable = true` for programs you configure
- **Document custom settings**: Comment on non-default configurations

## Shell Configuration

```nix
programs.bash = {
  enable = true;
  bashrcInit = {
    enable = true;
    post = ''
      # Add shell initialization commands
      export EDITOR=nvim
    '';
  };
};
```

- **Use shell modules**: Configure shells through program modules
- **Set environment in shell init**: Export variables in shell initialization
- **Keep shell config modular**: Don't put everything in .bashrc
- **Document shell-specific settings**: Comment on shell customizations

## Editor Configuration

```nix
programs.nixvim = {
  enable = true;
  # NixVim configuration
};

# OR for Neovim
programs.neovim = {
  enable = true;
  plugins = with pkgs.vimPlugins; [
    plugin1
    plugin2
  ];
  extraConfig = ''
    " Additional configuration
  '';
};
```

- **Use nixvim for Nix-based config**: Prefer declarative Neovim configuration
- **Or use neovim with plugins**: For plugin-based configuration
- **Document editor choice**: Comment on why specific editor is configured
- **Set as default editor**: Export EDITOR environment variable

## Home Directory Files

```nix
home.file.".config/app/config" = {
  source = ./path/to/source-file;
  recursive = true;  # For directories
};

# OR with explicit content
home.file.".config/app/config" = {
  text = ''
    key=value
    setting=true
  '';
};
```

- **Use home.file for config**: Manage dotfiles and config with Home Manager
- **Prefer source linking**: Link to source files when possible
- **Use text for simple configs**: Inline simple configuration
- **Set recursive for directories**: Use `recursive = true` for directory trees

## Environment Variables

```nix
home.sessionVariables = {
  EDITOR = "nvim";
  VISUAL = "nvim";
  # Add session variables here
};
```

- **Set in sessionVariables**: Use Home Manager's sessionVariables
- **Group related variables**: Organize environment variables logically
- **Document purpose**: Comment on non-obvious environment variables
- **Use standard names**: Follow conventions (EDITOR, PATH, etc.)

## Home Manager in NixOS Module

```nix
# In NixOS configuration (system level)
home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
  users.username = {
    # User configuration here
  };
};
```

- **Enable in NixOS**: Home Manager can be used as a NixOS module
- **Keep user config separate**: User configuration in user section
- **Share nixpkgs**: Use system nixpkgs for consistency
- **Document user setup**: Comment on user-specific configuration needs
