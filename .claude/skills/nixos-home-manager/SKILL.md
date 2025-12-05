---
name: NixOS Home Manager
description: Configure user environment with Home Manager including nixvim for Neovim, shell completions, and dotfiles management. When setting up home.nix, configuring user programs, or managing dotfiles.
---
# NixOS Home Manager

## When to use this skill:

- Integrating Home Manager with NixOS system configuration
- Configuring home.nix for user-specific settings
- Setting up nixvim with LSP servers and plugins
- Configuring shell completions (fish, zsh, bash)
- Managing dotfiles (vimrc, bashrc, zshrc, gitconfig)
- Setting up user-level packages and programs
- Configuring Home Manager modules and options
- Managing user environment variables
- Setting up nixvim plugins and language servers
- Configuring terminal emulators and shell settings
- Creating reproducible user environments

## Best Practices
- home-manager.nixosModules.home-manager { useGlobalPkgs = true; }; home-manager.users.hbohlen = import ../../home/hbohlen/home.nix;
- nixvim from modules/home-manager/nixvim; plugins lsp keymaps; completions.files/*.fish.
